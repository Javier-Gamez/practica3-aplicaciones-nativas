plugins {
    id("com.android.kotlin.multiplatform.library")
    id("org.jetbrains.kotlin.multiplatform")
    id("org.jetbrains.kotlin.plugin.serialization")
}

kotlin {
    androidLibrary {
        namespace = "mx.ipn.escom.camaramic.shared"
        compileSdk = 36
        minSdk = 26
    }

    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64(),
    ).forEach { target ->
        target.binaries.framework {
            baseName = "Shared"
            isStatic = true
        }
    }

    applyDefaultHierarchyTemplate()

    sourceSets {
        commonMain.dependencies {
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
            implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.6.1")
        }
        androidMain.dependencies {
            implementation("androidx.core:core-ktx:1.15.0")
            implementation("androidx.camera:camera-core:1.4.0")
            implementation("androidx.camera:camera-camera2:1.4.0")
            implementation("androidx.camera:camera-lifecycle:1.4.0")
        }
    }
}
