Script para hook pre-commit
Crea un archivo llamado pre-commit (sin extensión) dentro de una carpeta versionada, por ejemplo .githooks/, con el siguiente contenido:

bash
#!/bin/sh

echo "🔍 Ejecutando verificaciones de Dart/Flutter antes del commit..."

# 1. Formatear código con dart format (falla si algún archivo cambió)

dart format --output=none --set-exit-if-changed .

# 2. Análisis estático con flutter analyze

flutter analyze

# Si cualquiera de los comandos devuelve un error, abortar el commit

if [ $? -ne 0 ]; then
echo "❌ Se encontraron errores. Corrige los problemas y vuelve a intentar el commit."
exit 1
fi

echo "✅ Verificaciones superadas. Commit permitido."
Instrucciones de instalación
Haz ejecutable el script (desde la raíz del proyecto):

bash
chmod +x .githooks/pre-commit
Configura Git para usar tu carpeta de hooks:

bash
git config core.hooksPath .githooks
Verifica que el hook funcione intentando hacer un commit. Si hay errores de formato o análisis, el commit se bloqueará.

Opcional: limitar a archivos modificados
Si tu proyecto es grande y los comandos tardan mucho, puedes modificar el script para ejecutar el formateo y análisis solo sobre los archivos que están en el staging area:

bash
#!/bin/sh

# Obtener archivos Dart modificados en el commit

FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$')

if [ -z "$FILES" ]; then
echo "No hay archivos Dart modificados."
exit 0
fi

echo "Formateando y analizando archivos modificados..."
dart format --output=none --set-exit-if-changed $FILES
flutter analyze $FILES
Notas
dart format reemplaza al antiguo flutter format (obsoleto).

El flag --set-exit-if-changed hace que el comando falle si algún archivo necesitaba formato, obligándote a aplicarlo antes de commitear.

Puedes agregar más comandos al hook, como flutter test, dart pub get, etc.

Si trabajas con Windows, asegúrate de usar Git Bash y que el script sea compatible (puedes usar la misma sintaxis).
