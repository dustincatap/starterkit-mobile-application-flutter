import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val dartDefines = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    // Decode dart-defines, which are comma-separated and encoded in Base64, and store them in a variable.
    val defines = project.property("dart-defines").toString()
        .split(",")
        .map { entry ->
            val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
            val pair = decoded.split("=", limit = 2)
            pair[0] to (pair.getOrNull(1) ?: "")
        }
    dartDefines.putAll(defines)
}

// Check keystore file
val keystoreProperties = Properties()
val keyStorePropertiesFileName = "Distribution.keystore.properties"
val keystorePropertiesFile = file(keyStorePropertiesFileName)
val keystorePropertiesFileExists = keystorePropertiesFile.exists()
var keystoreFileExists = false

if (keystorePropertiesFileExists) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
    val keystoreFile = file(keystoreProperties["storeFile"].toString())
    keystoreFileExists = keystoreFile.exists()
    if (keystoreFileExists) {
        println("Signing with provided keystore")
    } else {
        println("Could not find signing keystore, using debug")
    }
} else {
    println("Could not find signing keystore, using debug")
}

// Uncomment this line if using google-services.json
// Decode provided base64 google-services.json
// if (dartDefines["androidGoogleServicesJson"]?.isNotBlank() == true) {
//     val encoded = dartDefines["androidGoogleServicesJson"]!!
//     val decoded = String(Base64.getDecoder().decode(encoded))
//     val googleServicesJsonFile = File("app/google-services.json")
//     googleServicesJsonFile.writeText(decoded)
// }

//  If `appIdSuffix` is not set (prod env), for some reason it will have a default value of `appIdSuffix` ¯\_(ツ)_/¯
val appIdSuffix = if (dartDefines["appIdSuffix"] != "appIdSuffix") dartDefines["appIdSuffix"] ?: "" else ""
val appIdComplete = "${dartDefines["appId"]}$appIdSuffix"
println("Building: ${dartDefines["appName"]} ($appIdComplete) for ${dartDefines["appEnvironment"]} environment")

android {
    // Make sure that the namespace matches the package in MainActivity.kt and its folder structure
    namespace = "com.mycompany.starterkit.app"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = dartDefines["appId"]
        if (appIdSuffix.isNotBlank()) {
            applicationIdSuffix = appIdSuffix
        }
        minSdk = 31
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "app_name", dartDefines["appName"] ?: "")
    }

    signingConfigs {
        if (keystoreFileExists) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"].toString()
                keyPassword = keystoreProperties["keyPassword"].toString()
                storeFile = file(keystoreProperties["storeFile"].toString())
                storePassword = keystoreProperties["storePassword"].toString()
            }
        }
    }

    buildTypes {
        release {
            multiDexEnabled = true
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            signingConfig = if (keystoreFileExists) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }

        debug {
            signingConfig = if (keystoreFileExists) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
