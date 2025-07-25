allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

project(":keen_asr") {
    apply(plugin = "com.android.library")
    val compileOnly by configurations

    dependencies {
        compileOnly(rootProject.files("lib/KeenASR-2.0.2.aar"))
    }
}

project(":app") {
    apply(plugin = "com.android.application")
    val runtimeOnly by configurations

    dependencies {
        runtimeOnly(rootProject.files("lib/KeenASR-2.0.2.aar"))
    }
}