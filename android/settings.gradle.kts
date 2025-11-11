import java.io.File

// --- Onde o Gradle vai buscar os plugins (AGP, Kotlin, Google, etc) ---
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // Repositório do Flutter (engine artifacts)
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }

    // Lê o caminho do SDK do Flutter do local.properties ou variável de ambiente
    val flutterSdkPath: String = run {
        val propFile = File(rootDir, "local.properties")
        val fromFile = if (propFile.exists()) {
            propFile.readLines()
                .firstOrNull { it.startsWith("flutter.sdk=") }
                ?.substringAfter("=")
        } else null
        fromFile ?: System.getenv("FLUTTER_SDK")
        ?: throw GradleException("flutter.sdk não definido em local.properties (ou defina a env var FLUTTER_SDK)")
    }

    // Permite o Flutter injetar os subprojetos dos plugins
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

// --- AQUI é onde o loader do Flutter deve ser aplicado (NÍVEL DE SETTINGS, fora do pluginManagement) ---
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

// Repositórios para resolver dependências dos subprojetos
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "hpcdigital"
include(":app")
