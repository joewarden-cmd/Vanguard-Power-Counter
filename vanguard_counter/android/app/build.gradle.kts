plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vanguard_counter"
    compileSdk = 34 // Updated to the latest stable version
    ndkVersion = "27.0.12077973" // Updated to the required NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Updated to Java 17
        targetCompatibility = JavaVersion.VERSION_17 // Updated to Java 17
    }

    kotlinOptions {
        jvmTarget = "17" // Updated to JVM target 17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.vanguard_counter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21 // Updated to the minimum SDK version supported by Flutter
        targetSdk = 34 // Updated to the latest stable version
        versionCode = 1 // Set your version code
        versionName = "1.0.0" // Set your version name
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}