#!/bin/bash
# Este script toma la etiqueta del archivo parametros.h y descarga los archivos correspondientes

# Ruta del archivo parametros.h
#PARAM_FILE="parametros.h"

# Verificar si el archivo parametros.h existe
#if [[ ! -f "$PARAM_FILE" ]]; then
#    echo "Error: El archivo '$PARAM_FILE' no existe en el directorio actual."
#    exit 1
#fi

# Depuración: Imprimir contenido del archivo
#echo "Contenido del archivo $PARAM_FILE:"
#cat "$PARAM_FILE"

# Extraer la etiqueta usando el comando funcional
#ETIQUETA=$(grep '#define ETIQUETA' "" | awk '{print $3}' | tr -d ' ')
# Extraer la etiqueta del archivo parametros.h
#ETIQUETA=$(grep '#define ETIQUETA' parametros.h | awk '{print $3}' | tr -d ' ')
ETIQUETA=$(grep '^etiqueta =' parametros.h | awk -F'=' '{print $2}' | tr -d ' ')
echo "Etiqueta extraída: $ETIQUETA"


# Verificar si se extrajo correctamente la etiqueta
if [[ -z "$ETIQUETA" ]]; then
    echo "Error: No se pudo encontrar una etiqueta válida en '$PARAM_FILE'."
    exit 1
fi

# Imprimir la etiqueta extraída
echo "Etiqueta extraída: $ETIQUETA"

# Descargar los archivos correspondientes desde el servidor


# Descargar los archivos correspondientes desde el servidor
echo "Descargando archivos con etiqueta $ETIQUETA..."
mcli -C ~/.mcli cp gridunam/nbody/nb_hamsp_coor_jFF_e134_"$ETIQUETA".dat .
mcli -C ~/.mcli cp gridunam/nbody/nb_hamsp_dtis_jFF_e134_"$ETIQUETA".dat .
mcli -C ~/.mcli cp gridunam/nbody/nb_hamsp_ener_jFF_e134_"$ETIQUETA".dat .

echo "Descarga completada."
