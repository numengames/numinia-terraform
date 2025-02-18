#!/bin/bash

# Crear o limpiar el archivo de salida
output_file="collected_files.txt"
> "$output_file"

# Función para procesar archivos
process_files() {
    local dir="$1"
    
    # Encontrar todos los archivos en el directorio y subdirectorios
    find "$dir" -type f | while read -r file; do
        # Agregar una línea separadora
        echo -e "\n=== File: $file ===\n" >> "$output_file"
        
        # Agregar el contenido del archivo
        cat "$file" >> "$output_file"
    done
}

echo "Collecting files from modules..."
process_files "modules/"
process_files "environments/"
process_files "main.tf"
process_files "variables.tf"


echo "Files have been collected in $output_file"

# Hacer el script ejecutable
chmod +x collect_files.sh 