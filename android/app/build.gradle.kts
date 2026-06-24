plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.barber_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.barber_app"
        minSdk = flutter.minSdkVersion // <-- asegúrate de que sea 21 o mayor
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11   // ✅ Java 11
        targetCompatibility = JavaVersion.VERSION_11   // ✅ Java 11
        isCoreLibraryDesugaringEnabled = true         // ✅ habilitar desugaring
    }

    kotlinOptions {
        jvmTarget = "11"                               // ✅ Kotlin JVM 11
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.10")  // ✅ Kotlin explícito
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // ✅ desugaring para flutter_local_notifications
}
