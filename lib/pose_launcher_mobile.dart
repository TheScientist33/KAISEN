import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pose_detection_screen.dart'; // <-- ton écran ML Kit (mobile)

Future<void> openPose(BuildContext context) async {
  final cameras = await availableCameras();
  final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
    orElse: () => cameras.first,
  );
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PoseDetectionScreen(camera: back)),
  );
}
