class PosePreloader {
  static final instance = PosePreloader();
  Future<void> preload() async {}
  Future<bool> requestCameraWarmup() async => false;
}
