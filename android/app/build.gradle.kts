import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- begin keystore helper (KTS) ---
// vamos tentar vários locais para key.properties (mais resiliente)
val possibleKeyProps = listOf(
    rootProject.file("key.properties"),
    rootProject.file("android/key.properties"),
    rootProject.file("app/key.properties")
)
val keystorePropertiesFile = possibleKeyProps.firstOrNull { it.exists() }

val keystoreProps = Properties()
if (keystorePropertiesFile != null && keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProps.load(it) }
    println("Loaded key.properties from: ${keystorePropertiesFile.path}")
} else {
    println("No key.properties found in tried locations: ${possibleKeyProps.map { it.path }}")
}

// read environment vars (PowerShell / system)
val envStorePassword = System.getenv("HPC_STORE_PASSWORD")
val envKeyPassword = System.getenv("HPC_KEY_PASSWORD")
val envKeyAlias = System.getenv("HPC_KEY_ALIAS")
val envStoreFile = System.getenv("HPC_STORE_FILE")

// properties from file (if present)
val propStorePassword = keystoreProps.getProperty("storePassword")?.trim()
val propKeyPassword = keystoreProps.getProperty("keyPassword")?.trim()
val propKeyAlias = keystoreProps.getProperty("keyAlias")?.trim()
val propStoreFile = keystoreProps.getProperty("storeFile")?.trim()

// final values (preference: key.properties -> env -> default)
val storePasswordFinal = propStorePassword ?: envStorePassword ?: ""
val keyPasswordFinal = propKeyPassword ?: envKeyPassword ?: ""
val keyAliasFinal = propKeyAlias ?: envKeyAlias ?: "hpcdigital"
val storeFileProp = propStoreFile ?: envStoreFile ?: "app/hpcdigital.keystore"

// candidate keystore file locations to check
val candidateRoot = rootProject.file(storeFileProp)         // relative to android/ (rootProject)
val candidateModule = file(storeFileProp)                  // relative to android/app (module)
val candidatePrefixed = rootProject.file("app/$storeFileProp") // another try

println("Keystore candidates for '$storeFileProp':")
println(" - rootProject: ${candidateRoot.path} exists=${candidateRoot.exists()}")
println(" - module: ${candidateModule.path} exists=${candidateModule.exists()}")
println(" - prefixed: ${candidatePrefixed.path} exists=${candidatePrefixed.exists()}")
println("Effective key alias: $keyAliasFinal")
if (storePasswordFinal.isEmpty() || keyPasswordFinal.isEmpty()) {
    println("Warning: storePassword or keyPassword is empty. Will attempt to use environment variables or key.properties.")
}
// --- end keystore helper ---

android {
    namespace = "com.hpcdigital.app"
    compileSdk = 36

    val mapsApiKey = project.findProperty("MAPS_API_KEY") as String? ?: ""
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.hpcdigital.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = project.properties["flutter.versionCode"]?.toString()?.toInt() ?: 4
        versionName = project.properties["flutter.versionName"]?.toString() ?: "1.0.0"

        resValue("string", "MAPS_API_KEY", mapsApiKey)
    }

    signingConfigs {
        create("release") {
            // decide qual ficheiro existe e usa-o
            when {
                candidateRoot.exists() -> {
                    storeFile = candidateRoot
                    println("Using keystore from rootProject path: ${candidateRoot.path}")
                }
                candidateModule.exists() -> {
                    storeFile = candidateModule
                    println("Using keystore from module path: ${candidateModule.path}")
                }
                candidatePrefixed.exists() -> {
                    storeFile = candidatePrefixed
                    println("Using keystore from prefixed path: ${candidatePrefixed.path}")
                }
                else -> {
                    println("Keystore file not found for path: $storeFileProp. Checked candidates.")
                }
            }

            // aplica as passwords/alias (podem ser vazias — em que caso o Gradle dará erro explicito)
            storePassword = storePasswordFinal
            keyAlias = keyAliasFinal
            keyPassword = keyPasswordFinal

            println("SigningConfig.release set (storeFile=${storeFile?.path}, keyAlias=$keyAliasFinal, storePasswordPresent=${storePassword?.isNotEmpty()}, keyPasswordPresent=${keyPassword?.isNotEmpty()})")
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // só aplica signing se encontramos key.properties ou variáveis de ambiente
            signingConfig = signingConfigs.getByName("release")
        }

        getByName("debug") {
            // removido applicationIdSuffix para bater com google-services.json
            isDebuggable = true
        }
    }

    packaging {
        resources {
            excludes.add("/META-INF/{AL2.0,LGPL2.1}")
        }
    }
}

flutter {
    source = "../.."
}

/*
 * Observações:
 * - Coloca android/key.properties (na pasta android/) com:
 *     storePassword=HpcdigitalMetodista
 *     keyPassword=HpcdigitalMetodista
 *     keyAlias=hpcdigital
 *     storeFile=app/hpcdigital.keystore
 *
 * - Alternativamente define as env vars (temporárias na sessão PowerShell ou permanentes no User env):
 *     $env:HPC_STORE_PASSWORD = 'HpcdigitalMetodista'
 *     $env:HPC_KEY_PASSWORD = 'HpcdigitalMetodista'
 *     $env:HPC_KEY_ALIAS = 'hpcdigital'
 *     $env:HPC_STORE_FILE = 'app/hpcdigital.keystore'
 *
 * - Não commites key.properties nem o keystore.
 */
