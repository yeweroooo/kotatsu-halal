import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val releaseVersion = providers.gradleProperty("releaseVersion")
    .orElse(providers.environmentVariable("RELEASE_VERSION"))
    .orElse("nightly-local")

val numericVersionCode = releaseVersion.map { version ->
    version.filter(Char::isDigit).takeLast(8).toIntOrNull() ?: 1
}

android {
    namespace = "org.koitharu.kotatsu.halal"
    compileSdk = 35

    defaultConfig {
        applicationId = "org.koitharu.kotatsu.halal"
        minSdk = 26
        targetSdk = 35
        versionCode = numericVersionCode.get()
        versionName = releaseVersion.get()
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

kotlin {
    jvmToolchain(17)
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

dependencies {
    coreLibraryDesugaring(libs.desugar.jdk.libs)

    implementation(project(":")) {
        exclude(group = "org.json", module = "json")
    }
}
