import 'dart:async';
import 'dart:html' as html;

class PosePreloader {
  static final instance = PosePreloader._();
  PosePreloader._();

  html.IFrameElement? _iframe;

  Future<void> preload() async {
    if (_iframe != null) return;
    _iframe = html.IFrameElement()
      ..src = Uri.base.resolve('pose_preload.html').toString()
      ..style.border = '0'
      ..style.width = '0'
      ..style.height = '0'
      ..style.position = 'absolute'
      ..style.left = '-9999px'
      ..style.top = '-9999px'
      ..allow = 'camera; microphone';
  }

  Future<bool> requestCameraWarmup() async {
    await preload();
    final c = Completer<bool>();
    late html.EventListener sub;
    sub = (e) {
      final data = (e as html.MessageEvent).data;
      if (data is Map && data['type'] == 'CAM_PERMISSION_RESULT') {
        html.window.removeEventListener('message', sub);
        c.complete(data['granted'] == true);
      }
    };
    html.window.addEventListener('message', sub);
    _iframe?.contentWindow?.postMessage({'type': 'WARMUP_CAMERA'}, '*');
    return c.future.timeout(const Duration(seconds: 15), onTimeout: () => false);
  }
}
