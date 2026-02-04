group = "so.daro.flutter"
version = "1.0-SNAPSHOT"

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "so.daro.flutter"
    compileSdk = 34

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDir("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 23
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    implementation("so.daro:daro-a:1.4.2")
    implementation("so.daro:daro-compose-util:1.3.1") {
        exclude(group = "so.daro", module = "daro-core")
    }
}
