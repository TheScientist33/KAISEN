import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraPosePage extends StatefulWidget {
  const CameraPosePage({super.key});
  @override
  State<CameraPosePage> createState() => _CameraPosePageState();
}

class _CameraPosePageState extends State<CameraPosePage> {
  CameraController? _controller;
  late final PoseDetector _poseDetector;
  final FlutterTts _tts = FlutterTts();
  bool _streaming = false;
  bool _busy = false;
  List<Pose> _poses = const [];

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: kIsWeb ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stop();
    _poseDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_controller == null || _streaming) return;
    if (kIsWeb) {
      // Web: pas de stream de frames => preview seulement pour l’instant.
      setState(() => _streaming = true);
      return;
    }
    await _controller!.startImageStream(_onFrame);
    setState(() => _streaming = true);
  }

  Future<void> _stop() async {
    if (_controller == null || !_streaming) return;
    if (!kIsWeb) {
      await _controller!.stopImageStream();
    }
    setState(() => _streaming = false);
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy) return;
    _busy = true;
    try {
      final input = _toInputImage(image, _controller!.description);
      final poses = await _poseDetector.processImage(input);
      _poses = poses;
      if (poses.isNotEmpty) {
        await _feedback(poses.first);
      }
      if (mounted) setState(() {});
    } catch (_) {} finally {
      _busy = false;
    }
  }

  Future<void> _feedback(Pose pose) async {
    final lh = pose.landmarks[PoseLandmarkType.leftHip];
    final lk = pose.landmarks[PoseLandmarkType.leftKnee];
    final la = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (lh == null || lk == null || la == null) return;
    final angle = _angle(lh, lk, la);
    if (angle < 80) {
      await _tts.setLanguage("fr-FR");
      await _tts.setSpeechRate(0.95);
      await _tts.speak("Redressez vos genoux");
    }
  }

  double _angle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final abx = a.x - b.x, aby = a.y - b.y;
    final cbx = c.x - b.x, cby = c.y - b.y;
    final dot = abx * cbx + aby * cby;
    final mag1 = math.sqrt(abx * abx + aby * aby);
    final mag2 = math.sqrt(cbx * cbx + cby * cby);
    final cos = (mag1 == 0 || mag2 == 0) ? 1.0 : (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return (180 / math.pi) * math.acos(cos);
  }

  @override
  Widget build(BuildContext context) {
    final ready = _controller?.value.isInitialized ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Caméra IA')),
      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (!kIsWeb) CustomPaint(painter: _PosePainter(_poses, _controller!.value.previewSize)),
          if (kIsWeb)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: const Text(
                  'Web: preview OK. Détection MediaPipe JS à brancher ensuite.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _start,
                child: const Text('Démarrer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _stop,
                child: const Text('Stop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convertit le frame CameraImage -> InputImage pour MLKit (Android/iOS)
InputImage _toInputImage(CameraImage image, CameraDescription description) {
  final bytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    bytes.putUint8List(plane.bytes);
  }
  final bytesAll = bytes.done().buffer.asUint8List();

  final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
  final camera = description;
  final rotation = _rotationFromCamera(camera.sensorOrientation);
  final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

  final planeData = image.planes.map(
        (Plane plane) => InputImagePlaneMetadata(
      bytesPerRow: plane.bytesPerRow,
      height: plane.height,
      width: plane.width,
    ),
  ).toList();

  final metadata = InputImageMetadata(
    size: imageSize,
    rotation: rotation,
    format: format,
    bytesPerRow: planeData.first.bytesPerRow,
    planeData: planeData,
  );

  return InputImage.fromBytes(bytes: bytesAll, metadata: metadata);
}

InputImageRotation _rotationFromCamera(int sensorOrientation) {
  final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  return rotation ?? InputImageRotation.rotation0deg;
}

/// Dessine les landmarks/squelettes par-dessus l’aperçu
class _PosePainter extends CustomPainter {
  _PosePainter(this.poses, this.previewSize);
  final List<Pose> poses;
  final Size? previewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty || previewSize == null) return;
    final paintDot = Paint()..color = Colors.lightGreenAccent..style = PaintingStyle.fill;
    final paintLine = Paint()..color = Colors.greenAccent..strokeWidth = 3;

    // rapport d’échelle pour mapper le preview à la taille du widget
    final scaleX = size.width / previewSize!.height;
    final scaleY = size.height / previewSize!.width;

    for (final pose in poses) {
      // points
      for (final lm in pose.landmarks.values) {
        canvas.drawCircle(Offset(lm.y * scaleX, lm.x * scaleY), 3, paintDot);
      }
      // segments principaux (exemple)
      void line(PoseLandmarkType a, PoseLandmarkType b) {
        final p1 = pose.landmarks[a], p2 = pose.landmarks[b];
        if (p1 == null || p2 == null) return;
        canvas.drawLine(
          Offset(p1.y * scaleX, p1.x * scaleY),
          Offset(p2.y * scaleX, p2.x * scaleY),
          paintLine,
        );
      }
      // tronc + bras + jambes (simplifié)
      line(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      line(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      line(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      line(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      line(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      line(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      line(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      line(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      line(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      line(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) => true;
}
