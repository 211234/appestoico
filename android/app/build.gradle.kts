import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.estoico"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        // Habilitar core library desugaring para flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.estoico"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Mínimo requerido para Google Sign-In
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Configuración de firma
    val keystorePropertiesFile = rootProject.file("key.properties")
    var storePasswordValue = ""
    var keyPasswordValue = ""
    var keyAliasValue = "upload"
    var storeFileValue = "upload-keystore.jks"
    
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.readLines().forEach { line ->
            // Limpiar la línea: eliminar BOM, espacios y caracteres invisibles
            val cleanedLine = line.trim().replace("\uFEFF", "").replace("\u200B", "")
            // Ignorar líneas vacías y comentarios
            if (cleanedLine.isEmpty() || cleanedLine.startsWith("#")) {
                return@forEach
            }
            when {
                cleanedLine.contains("storePassword=") -> {
                    storePasswordValue = cleanedLine.substringAfter("storePassword=").trim()
                }
                cleanedLine.contains("keyPassword=") -> {
                    keyPasswordValue = cleanedLine.substringAfter("keyPassword=").trim()
                }
                cleanedLine.contains("keyAlias=") -> {
                    keyAliasValue = cleanedLine.substringAfter("keyAlias=").trim()
                }
                cleanedLine.contains("storeFile=") -> {
                    storeFileValue = cleanedLine.substringAfter("storeFile=").trim()
                }
            }
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
                storeFile = file(storeFileValue)
                storePassword = storePasswordValue
            }
        }
    }

    buildTypes {
        release {
            // Usar configuración de firma si existe, sino usar debug (para desarrollo)
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring requerido por flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
