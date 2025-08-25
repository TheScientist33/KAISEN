// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsu;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PosePage extends StatefulWidget {
  const PosePage({super.key});
  @override
  State<PosePage> createState() => _PosePageState();
}

class _PosePageState extends State<PosePage> {
  late final String _viewType;
  late final String _containerId;

  @override
  void initState() {
    super.initState();
    final viewId = DateTime.now().microsecondsSinceEpoch.toString();
    _viewType = 'kaisen-pose-view-$viewId';
    _containerId = 'pose-container-$viewId';

    // Enregistre une fabrique d’élément HTML pour HtmlElementView
    // (uniquement côté Web).
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final div = html.DivElement()
        ..id = _containerId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'relative'
        ..style.backgroundColor = 'black';
      // Démarre le pipeline JS après avoir inséré l’élément
      // (petit délai pour être sûr que le DOM est prêt).
      Future.delayed(const Duration(milliseconds: 50), _startJs);
      return div;
    });
  }

  Future<void> _startJs() async {
    final kaisenPose = js.context['KaisenPose'];
    if (kaisenPose == null) {
      // pose.js non chargé
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('pose.js non chargé — vérifie index.html')),
      );
      return;
    }
    // Appelle KaisenPose.start(containerId)
    await jsu.promiseToFuture(
      jsu.callMethod(kaisenPose, 'start', [_containerId]),
    );
  }

  Future<void> _stopJs() async {
    final kaisenPose = js.context['KaisenPose'];
    if (kaisenPose != null) {
      await jsu.promiseToFuture(jsu.callMethod(kaisenPose, 'stop', []));
    }
  }

  @override
  void dispose() {
    _stopJs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caméra IA (Web)')),
      body: HtmlElementView(viewType: _viewType),
    );
  }
}
