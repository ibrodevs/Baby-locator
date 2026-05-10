import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        load(FileInputStream(file))
    }
}

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        load(FileInputStream(file))
    }
}

fun propertyOrEnv(name: String, defaultValue: String = ""): String {
    val gradleValue = providers.gradleProperty(name).orNull?.trim().orEmpty()
    if (gradleValue.isNotEmpty()) return gradleValue

    val envValue = providers.environmentVariable(name).orNull?.trim().orEmpty()
    if (envValue.isNotEmpty()) return envValue

    val localValue = localProperties.getProperty(name)?.trim().orEmpty()
    if (localValue.isNotEmpty()) return localValue

    return defaultValue
}

val appNamespace = propertyOrEnv(
    name = "APP_NAMESPACE",
    defaultValue = "com.company.familysecurity",
)
val appApplicationId = propertyOrEnv(
    name = "APP_APPLICATION_ID",
    defaultValue = appNamespace,
)
val googleMapsApiKey = propertyOrEnv(
    name = "GOOGLE_MAPS_ANDROID_API_KEY",
    defaultValue = "AIzaSyD4gQlVQKoVsbDJGuYJ7GVtLQYw9N9WWW8",
)

fun signingProperty(
    fileKey: String,
    envKey: String,
): String {
    val envValue = providers.environmentVariable(envKey).orNull?.trim().orEmpty()
    if (envValue.isNotEmpty()) return envValue
    return keystoreProperties.getProperty(fileKey)?.trim().orEmpty()
}

val releaseStoreFile = signingProperty("storeFile", "ANDROID_KEYSTORE_FILE")
val releaseStorePassword = signingProperty("storePassword", "ANDROID_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingProperty("keyAlias", "ANDROID_KEY_ALIAS")
val releaseKeyPassword = signingProperty("keyPassword", "ANDROID_KEY_PASSWORD")

val hasReleaseSigning =
    releaseStoreFile.isNotEmpty() &&
        releaseStorePassword.isNotEmpty() &&
        releaseKeyAlias.isNotEmpty() &&
        releaseKeyPassword.isNotEmpty()

val isReleaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (isReleaseTaskRequested && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is not configured. Create android/key.properties " +
            "from android/key.properties.example and provide a valid upload keystore.",
    )
}

android {
    namespace = appNamespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = appApplicationId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
