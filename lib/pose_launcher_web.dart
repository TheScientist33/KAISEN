import 'package:flutter/material.dart';
import 'web_pose_view.dart';

Future<void> openPose(BuildContext context) async {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const WebPoseView()),
  );
}
