import org.gradle.api.tasks.Delete
import org.gradle.kotlin.dsl.register
import org.gradle.kotlin.dsl.repositories

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    layout.buildDirectory.set(
        rootProject.layout.buildDirectory.dir(name)
    )
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}