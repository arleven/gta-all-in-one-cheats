import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.apps.gtaallinone"
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
    applicationId = "com.apps.gtaallinone"
    minSdk = 26   // 🔥 explicitly set instead of flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

 signingConfigs {
    create("release") {
        keyAlias = keystoreProperties.getProperty("keyAlias") ?: throw GradleException("keyAlias not found in key.properties")
        keyPassword = keystoreProperties.getProperty("keyPassword") ?: throw GradleException("keyPassword not found in key.properties")
        storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) } 
            ?: throw GradleException("storeFile not found in key.properties")
        storePassword = keystoreProperties.getProperty("storePassword") ?: throw GradleException("storePassword not found in key.properties")
    }
}


    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.android.billingclient:billing:6.2.1")
}
