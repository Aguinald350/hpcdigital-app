// android/build.gradle.kts
// Arquivo raiz simples e sem truques de diretório (evita loops/ciclos)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
