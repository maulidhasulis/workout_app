plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")

    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.workout_app"

    // Gunakan SDK 34 atau 35 terlebih dahulu jika SDK 36 dirasa terlalu eksperimental untuk beberapa library MLKit
    compileSdk = 36

    ndkVersion = "27.0.12077973"

    compileOptions {
        // Mengaktifkan desugaring agar fitur Java baru bisa berjalan di Android lama
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.workout_app"
        minSdk = 24
        targetSdk = 35

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Core Library Desugaring untuk mendukung kestabilan notifikasi dan library lama
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}   