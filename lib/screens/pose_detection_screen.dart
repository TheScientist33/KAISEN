import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionScreen extends StatefulWidget {
  final CameraDescription camera;
  const PoseDetectionScreen({super.key, required this.camera});

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  late CameraController _cam;
  late Future<void> _camInit;
  late final PoseDetector _detector;
  final _tts = FlutterTts();
  bool _busy = false;
  DateTime _lastCue = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _cam = CameraController(widget.camera, ResolutionPreset.medium, enableAudio: false);
    _camInit = _cam.initialize().then((_) async {
      _detector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.base, // accurate si perf OK
        ),
      );
      await _cam.startImageStream(_onFrame);
    });
  }

  Future<void> _onFrame(CameraImage img) async {
    if (!mounted || _busy) return;
    _busy = true;

    // Convert CameraImage -> InputImage (ML Kit)
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in img.planes) { allBytes.putUint8List(plane.bytes); }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(img.width.toDouble(), img.height.toDouble());
    final InputImageRotation rotation = InputImageRotation.rotation0deg; // ajuste si besoin
    final InputImageFormat format = InputImageFormat.nv21;

    final planeData = img.planes.map(
          (plane) => InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      ),
    ).toList();

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: img.planes.first.bytesPerRow,
        planeData: planeData,
      ),
    );

    try {
      final poses = await _detector.processImage(inputImage);
      if (poses.isNotEmpty) {
        final p = poses.first;
        // Landmarks nommés (indices ML Kit)
        final hip = p.landmarks[PoseLandmarkType.leftHip];
        final knee = p.landmarks[PoseLandmarkType.leftKnee];
        final ankle = p.landmarks[PoseLandmarkType.leftAnkle];

        if (hip != null && knee != null && ankle != null) {
          final angle = _angleDeg(
            Offset(hip.x, hip.y),
            Offset(knee.x, knee.y),
            Offset(ankle.x, ankle.y),
          );
          // Cooldown 1.5s pour éviter le spam TTS
          if (angle < 90 && DateTime.now().difference(_lastCue).inMilliseconds > 1500) {
            _lastCue = DateTime.now();
            await _tts.stop();
            await _tts.speak('Redressez vos genoux !');
          }
        }
      }
    } catch (_) {
      // ignore frame errors
    } finally {
      _busy = false;
    }
  }

  double _angleDeg(Offset a, Offset b, Offset c) {
    final ab = _vec(a, b);
    final cb = _vec(c, b);
    double r = math.atan2(cb.dy, cb.dx) - math.atan2(ab.dy, ab.dx);
    double d = (r * 180 / math.pi).abs();
    if (d > 180) d = 360 - d;
    return d;
  }

  Offset _vec(Offset p, Offset origin) => Offset(p.dx - origin.dx, p.dy - origin.dy);

  @override
  void dispose() {
    _cam.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _camInit,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Détection de pose (MVP)')),
          body: CameraPreview(_cam),
        );
      },
    );
  }
}

class Offset {
  final double dx, dy;
  const Offset(this.dx, this.dy);
}
