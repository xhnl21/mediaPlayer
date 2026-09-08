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

subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            try {
                val getNamespaceMethod = androidExtension.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespaceMethod.invoke(androidExtension) as? String
                if (currentNamespace.isNullOrBlank()) {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    val pkg = if (manifestFile.exists()) {
                        val match = Regex("""package\s*=\s*["']([^"']+)["']""").find(manifestFile.readText())
                        match?.groupValues?.get(1)
                    } else null

                    val targetNamespace = pkg ?: "com.antigravity.${name.replace('-', '_')}"
                    val setNamespaceMethod = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespaceMethod.invoke(androidExtension, targetNamespace)
                }
            } catch (_: Exception) {
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
