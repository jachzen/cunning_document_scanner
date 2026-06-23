import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use {
        localProperties.load(it)
    }
}

val flutterVersionCode =
        localProperties.getProperty("flutter.versionCode") ?: "1"

val flutterVersionName =
        localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "biz.cunning.cunning_document_scanner_example"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDir("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "biz.cunning.cunning_document_scanner_example"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}

dependencies {
}

configurations.configureEach {
    resolutionStrategy.eachDependency {
        if (
                requested.group == "org.jetbrains.kotlin" &&
                        requested.name.startsWith("kotlin-stdlib")
        ) {
            useVersion("2.2.21")
        }
    }
}