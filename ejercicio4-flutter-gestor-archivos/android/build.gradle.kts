allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// file_picker 8.3.7 hardcodes compileSdk 34 in its own build.gradle, which is
// now too low for flutter_plugin_android_lifecycle (needs 36+). Force every
// Android module to compile against 36 -- applied directly if the subproject
// already finished evaluating (state.executed), otherwise deferred to
// afterEvaluate (calling afterEvaluate on an already-evaluated project throws).
subprojects {
    fun forceCompileSdk36() {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.compileSdkVersion(36)
    }
    if (state.executed) forceCompileSdk36() else afterEvaluate { forceCompileSdk36() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
