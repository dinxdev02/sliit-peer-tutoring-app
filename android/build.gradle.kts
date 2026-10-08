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
    if (project.name == "file_picker") {
        project.afterEvaluate {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
    if (project.name == "url_launcher_android") {
        // Match the Kotlin version already selected by this application's settings.
        project.buildscript.configurations.configureEach {
            resolutionStrategy.eachDependency {
                if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin") {
                    useVersion("2.4.0")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
