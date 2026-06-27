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

    // 🔥 SDK TERBARU
    compileSdk = 36

    // 🔥 NDK TERBARU
    ndkVersion = "27.0.12077973"

    compileOptions {

        // 🔥 JAVA 8 DESUGARING
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11

        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {

        applicationId = "com.example.workout_app"

        minSdk = 24

        targetSdk = 36

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    buildTypes {

        release {

            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

dependencies {

    // 🔥 FIX NOTIFICATION ERROR
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}

flutter {
    source = "../.."
}