#!/bin/bash

# Constantes del sistema
rs_fis=15.0                              # Radio de escala del sistema en kpc
Mt_fis=1.25e12                           # Masa total del sistema en Msun
G_fis=4.302e-6                           # Constante gravitacional (kpc * (km/s)^2 / Msun)

# Convertir constantes a formato compatible con bc
rs_fis=$(printf "%.10f" "$rs_fis")
Mt_fis=$(printf "%.10f" "$Mt_fis")
G_fis=$(printf "%.10f" "$G_fis")

# Calcular las constantes de reescalamiento
scV=$(echo "sqrt($G_fis * $Mt_fis / $rs_fis)" | bc -l)
iscX=$(echo "1.0 / $rs_fis" | bc -l)
iscV=$(echo "1.0 / $scV" | bc -l)

echo "scV (constante de reescalamiento para velocidades): $scV"
echo "iscX (inverso para posiciones): $iscX"
echo "iscV (inverso para velocidades): $iscV"

# Verificar que las constantes se calcularon correctamente
if [[ -z "$scV" || -z "$iscX" || -z "$iscV" ]]; then
    echo "Error: Las constantes de reescalamiento no se calcularon correctamente."
    exit 1
fi

# Extraer la etiqueta del archivo parametros.h
ETIQUETA=$(grep '^etiqueta =' parametros.h | awk -F'=' '{print $2}' | tr -d ' ')
echo "Etiqueta extraída: $ETIQUETA"

# Verificar si se extrajo correctamente la etiqueta
if [[ -z "$ETIQUETA" ]]; then
    echo "Error: No se pudo encontrar una etiqueta válida en 'parametros.h'."
    exit 1
fi

# Extraer el número de partículas N del archivo parametros.h
N=$(grep '^N =' parametros.h | awk -F'=' '{print $2}' | tr -d ' ')
echo "Número de partículas: $N"

# Verificar si se extrajo correctamente el número de partículas
if [[ -z "$N" ]]; then
    echo "Error: No se pudo encontrar un número de partículas válido en 'parametros.h'."
    exit 1
fi

# Leer la columna de masas y eps de halosatebh.ascii
MASS_FILE="masses_column.dat"
EPS_FILE="eps_column.dat"
awk -v n="$N" 'NR <= n {print $1}' halosatebh.ascii > "$MASS_FILE"
awk -v n="$N" 'NR <= n {print $8}' halosatebh.ascii > "$EPS_FILE"

# Descargar los archivos correspondientes desde el servidor
COORD_FILE="nb_hamsp_coor_jFF_e134_${ETIQUETA}.dat"
echo "Descargando archivo de coordenadas: $COORD_FILE"
mcli -C ~/.mcli cp gridunam/nbody/"$COORD_FILE" .

# Ignorar la primera línea del archivo
TEMP_COORD_FILE="temp_${COORD_FILE}"
tail -n +2 "$COORD_FILE" > "$TEMP_COORD_FILE"

# Determinar el último tiempo en el archivo de coordenadas
LAST_TIME=$(tail -n 1 "$TEMP_COORD_FILE" | awk '{print $1}')
echo "Último tiempo encontrado: $LAST_TIME"

# Extraer las últimas N+1 líneas del archivo de coordenadas (para compensar la línea eliminada)
FINAL_COORD_FILE="final_coordinates_${LAST_TIME}.dat"
echo "Extrayendo las últimas $N partículas del archivo de coordenadas..."
tail -n "$((N + 1))" "$TEMP_COORD_FILE" | head -n "$N" > "$FINAL_COORD_FILE"

# Crear un archivo con reescalamiento de posiciones y velocidades (división por iscX e iscV)
RECALCULATED_COORD_FILE="recalculated_coordinates_${LAST_TIME}.dat"
echo "Reescalando posiciones y velocidades..."
awk -v iscX="$iscX" -v iscV="$iscV" '{
    posX = $2 / iscX; posY = $3 / iscX; posZ = $4 / iscX;
    velX = $5 / iscV; velY = $6 / iscV; velZ = $7 / iscV;
    printf "%.15e %.15e %.15e %.15e %.15e %.15e\n", posX, posY, posZ, velX, velY, velZ;
}' "$FINAL_COORD_FILE" > "$RECALCULATED_COORD_FILE"

# Crear el archivo final de condiciones iniciales
INITIAL_CONDITIONS_FILE="initial_conditions_${LAST_TIME}.dat"
echo "Creando archivo final con masas, posiciones, velocidades reescaladas, y eps..."
paste "$MASS_FILE" "$RECALCULATED_COORD_FILE" "$EPS_FILE" > "$INITIAL_CONDITIONS_FILE"

# Verificar si el archivo de condiciones iniciales fue creado
if [[ -f "$INITIAL_CONDITIONS_FILE" ]]; then
    echo "Archivo de condiciones iniciales creado: $INITIAL_CONDITIONS_FILE"
else
    echo "Error: No se pudo crear el archivo de condiciones iniciales."
    exit 1
fi

echo "Proceso completado con éxito."

