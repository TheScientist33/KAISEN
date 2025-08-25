// Exporte la bonne implémentation selon la plateforme.
// Web (dart.library.html) -> pose_launcher_web.dart
// Sinon (Android/iOS) -> pose_launcher_mobile.dart
export 'pose_launcher_mobile.dart' if (dart.library.html) 'pose_launcher_web.dart';
