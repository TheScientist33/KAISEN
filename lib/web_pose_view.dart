// lib/web_pose_view.dart
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WebPoseView extends StatefulWidget {
  const WebPoseView({super.key});
  @override
  State<WebPoseView> createState() => _WebPoseViewState();
}

class _WebPoseViewState extends State<WebPoseView> {
  static const _viewType = 'pose-iframe';
  late final html.IFrameElement _iframe;
  final _tts = FlutterTts();

  double? _angle;
  String _status = 'Init…';
  late final html.EventListener _msgListener;

  @override
  void initState() {
    super.initState();

    _iframe = html.IFrameElement()
      ..src = 'pose_web.html'
      ..style.border = '0'
      ..allow = 'camera; microphone'
      ..allowFullscreen = true;

    web.registerViewFactory(_viewType, (int _) => _iframe);

    html.window.onMessage.listen((event) async {
      final data = event.data;
      if (data is Map) {
        final type = data['type'];
        if (type == 'POSE_ANGLE') {
          final ang = (data['angle'] as num?)?.toDouble();
          if (mounted) setState(() => _angle = ang);
        } else if (type == 'STATUS') {
          final s = data['text'] as String? ?? '';
          if (mounted) setState(() => _status = s);
        } else if (type == 'CUE') {
          final text = (data['text'] as String?) ?? '';
          if (text.isNotEmpty) {
            await _tts.stop();
            await _tts.speak(text);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détection de pose (Web)'),
        leading: const BackButton(), // ← retour au menu
      ),
      body: Stack(
        children: [
          const HtmlElementView(viewType: _viewType),
          Positioned(
            left: 12, top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(_status, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Positioned(
            right: 12, top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  'Angle genou: ${_angle?.toStringAsFixed(0) ?? "--"}°',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
