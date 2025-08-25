import 'dart:html' as html;

class PosePreloader {
  static final instance = PosePreloader._();
  PosePreloader._();

  html.IFrameElement? _iframe; // pour précharger le modèle seulement

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
    html.document.body?.append(_iframe!);
  }

  // ✅ Appelé dans onPressed du bouton/modal → geste utilisateur garanti
  Future<bool> requestCameraWarmup() async {
    try {
      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': true, 'audio': false});
      // On libère tout de suite
      for (final t in stream.getTracks()) {
        t.stop();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
