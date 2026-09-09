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

fun parseEnvFile(file: File, props: Properties) {
    if (!file.exists() || !file.isFile) return
    try {
        file.forEachLine { rawLine ->
            val line = rawLine.trim()
            if (line.isNotEmpty() && !line.startsWith("#") && line.contains("=")) {
                val idx = line.indexOf("=")
                val key = line.substring(0, idx).trim()
                var value = line.substring(idx + 1).trim()
                if ((value.startsWith("\"") && value.endsWith("\"")) ||
                    (value.startsWith("'") && value.endsWith("'"))) {
                    value = value.substring(1, value.length - 1)
                }
                if (key.isNotEmpty()) {
                    props.setProperty(key, value)
                }
            }
        }
    } catch (_: Exception) {}
}

val backendEnvProperties = Properties().apply {
    val candidates = listOf(
        rootProject.file("../../Baby-locator-backend/.env"),
        rootProject.file("../Baby-locator-backend/.env"),
        rootProject.file("../../backend/.env"),
        rootProject.file("../backend/.env"),
        File("/var/www/Baby-locator-backend/.env"),
        rootProject.file("../.env"),
        rootProject.file(".env"),
    )
    for (candidate in candidates) {
        parseEnvFile(candidate, this)
    }
}

fun propertyOrEnv(name: String, defaultValue: String = ""): String {
    val gradleValue = providers.gradleProperty(name).orNull?.trim().orEmpty()
    if (gradleValue.isNotEmpty()) return gradleValue

    val envValue = providers.environmentVariable(name).orNull?.trim().orEmpty()
    if (envValue.isNotEmpty()) return envValue

    val backendEnvValue = backendEnvProperties.getProperty(name)?.trim().orEmpty()
    if (backendEnvValue.isNotEmpty()) return backendEnvValue

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
val googleMapsApiKey = sequenceOf(
    propertyOrEnv("GOOGLE_MAPS_ANDROID_API_KEY"),
    propertyOrEnv("GOOGLE_MAPS_API_KEY"),
    propertyOrEnv("MAPS_API_KEY"),
).firstOrNull { it.isNotEmpty() } ?: "AIzaSyD4gQlVQKoVsbDJGuYJ7GVtLQYw9N9WWW8"

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
        "Release signing is not configured. upload-keystore.jks or signing credentials missing. " +
            "Silent fallback to debug signing has been disabled for production compliance.",
    )
}

android {
    namespace = appNamespace
    compileSdk = 36
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
        minSdk = 24
        targetSdk = 36
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
            } else if (isReleaseTaskRequested) {
                throw GradleException("Release build cannot be signed with debug key.")
            } else {
                signingConfig = signingConfigs.getByName("debug")
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
