plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter doit rester après Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // + Google Services (Firebase)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.kaisen"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.kaisen"

        // ⚠️ Force minSdk à 21 (camera, BLE, TTS, ML Kit ok)
        minSdk = 21

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
