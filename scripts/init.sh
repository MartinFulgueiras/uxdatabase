#!/usr/bin/env bash 
#shebang: indica que bash utilizar
#=====================================================================
#Archivo: scripts/init.sh
#Propósito: Preparar la estructura de directorios y permisos tras un git clone
#Uso: bash scripts/init.sh (ejecutar desde la raíz del repositorio)
#=====================================================================

#1.Modo estricto: detiene la ejecución si cualquier comando falla
#1.Strict mode: stops execution if any command fails
set -euo pipefail

#2.Calcular la ruta absoluta del proyecto
#Setea una variable tipo global llamada PROJECT_ROOT con el path absoluto del proyecto. Asi puede ser usada para que el script corra desde cualquier lugar del sistema
#2.Project absolute path 
#Sets an environment variable called PROJECT_ROOT with the absolute path of the project. The variable can be called from anywhere in the system for script execution
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Ruta base detectada: ${PROJECT_ROOT}"

#3.Crear jerarquía de directorios para volúmenes Docker y respaldos. Flag -p crea toda la cadena en caso no exista y no falla si ya esta
#    - data/postgres/: Persistencia de la base de datos
#    - data/directus/uploads/: Archivos subidos por usuarios (imágenes, documentos)
#    - data/directus/extensions/: Plugins o personalizaciones futuras de Directus
#    - backups/: Volcados .sql y copias de seguridad manuales
#3.Directory creation for Docker volumes and backups. Flag -p creates directory chain in case needed and doesnt fail in case they exist
#    - data/postgres/: Data pesistency
#    - data/directus/uploads/: User upload files (images, documents)
#    - data/directus/extensions/: Plugins or future personalizations for Directus
#    - backups/: .sql dumb and manual backups
echo "Creando estructura de directorios..."
mkdir -p "${PROJECT_ROOT}/data/postgres"
mkdir -p "${PROJECT_ROOT}/data/directus/uploads"
mkdir -p "${PROJECT_ROOT}/data/directus/extensions"
mkdir -p "${PROJECT_ROOT}/backups"

#4.Ajustar propiedad y permisos
#    Docker monta los volúmenes usando el UID/GID del usuario que ejecuta el contenedor.
#    Usamos id -u y id -g para asignar la carpeta al usuario actual de forma segura,
#    incluso si el script se ejecuta con sudo o en entornos con perfiles distintos.
#4.Adjust property and permissions
#    Docker mounts volumes using UID/GID of the container executing user
#    Use id -u and id -g to assign the directory to the current user
#    works even if sudo is being used
echo "Aplicando propiedad al usuario actual..."
chown -R "$(id -u):$(id -g)" "${PROJECT_ROOT}/data"
chown -R "$(id -u):$(id -g)" "${PROJECT_ROOT}/backups"

# 5.Establecer permisos estándar
#    755 = propietario (lectura/escritura/ejecución), grupo/otros (lectura/ejecución)
#    Garantiza que Docker pueda escribir sin restricciones excesivas de seguridad
# 5.Establish standard permissions
#    755 = owner (read/write/execute), group/others (read/execute)
#    Ensures Docker can write without overly restrictive security settings
echo "Configurando permisos (755)..."
chmod -R 755 "${PROJECT_ROOT}/data"
chmod -R 755 "${PROJECT_ROOT}/backups"

# 6.Confirmación y guía de siguiente paso

echo "Inicialización completada."
echo "Próximo paso: cp .env.example .env && docker compose up -d"
