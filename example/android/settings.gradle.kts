import java.util.Properties

pluginManagement {
    val flutterSdkPath =
        java.util.Properties().run {
            file("local.properties").inputStream().use { load(it) }
            getProperty("flutter.sdk")
                ?: error("flutter.sdk not set in local.properties")
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
}

include(":app")