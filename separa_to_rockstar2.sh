#!/bin/bash

# Nombre del archivo de entrada
INPUT_FILE="nb_hamsp_coor_jFF_e134_isosatebh.dat"

# Crear un directorio para los snapshots separados
OUTPUT_DIR="snapshots"
mkdir -p "$OUTPUT_DIR"

# Inicializar variables
SNAP_COUNT=0
CURRENT_T=""
OUTPUT_FILE=""
START_PROCESSING=false  # Variable para saber cuando comenzar a procesar las partículas
LINE_NUMBER=0  # Contador global de líneas

# Factor de escala para posiciones x, y, z
SCALE_FACTOR=0.0007

# Leer el archivo línea por línea
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    # Detectar líneas vacías (separadores entre snapshots)
    if [[ -z "$LINE" && "$START_PROCESSING" == true ]]; then
        CURRENT_T=""
        LINE_NUMBER=0  # Reiniciar el contador de líneas para el nuevo snapshot
        continue
    fi

    # Ignorar las líneas de parámetros de la simulación (aquellas que comienzan con '#')
    if [[ "$LINE" == \#* && "$START_PROCESSING" == false ]]; then
        continue
    fi

    # A partir de la primera línea con datos de partículas, comenzamos a procesar
    if [[ "$LINE" != \#* ]]; then
        START_PROCESSING=true
    fi

    # Detectar el tiempo actual en la primera columna
    FIRST_COLUMN=$(echo "$LINE" | awk '{print $1}')

    # Si cambia el tiempo, iniciar un nuevo archivo
    if [[ "$FIRST_COLUMN" != "$CURRENT_T" && "$START_PROCESSING" == true ]]; then
        CURRENT_T="$FIRST_COLUMN"
        SNAP_COUNT=$((SNAP_COUNT + 1))
        OUTPUT_FILE="$OUTPUT_DIR/snapshot_t${SNAP_COUNT}.dat"
        echo "Creando snapshot para t=$CURRENT_T en $OUTPUT_FILE"
        LINE_NUMBER=0  # Reiniciar el número de línea para el nuevo snapshot
    fi

    # Incrementar el número de línea dentro del snapshot
    LINE_NUMBER=$((LINE_NUMBER + 1))

    # Procesar la línea: eliminar la columna del tiempo, multiplicar x, y, z por el factor y agregar el número de línea
    echo "$LINE" | awk -v scale="$SCALE_FACTOR" -v line_number="$LINE_NUMBER" '{
        # Multiplicar las columnas x, y, z (2, 3, 4) por el factor
        x = $2 * scale; y = $3 * scale; z = $4 * scale;
        # Imprimir las columnas procesadas sin incluir la primera (tiempo)
        printf "%.15e %.15e %.15e ", x, y, z;
        for (i=5; i<=NF; i++) printf "%s ", $i;
        print line_number;
    }' >> "$OUTPUT_FILE"
done < "$INPUT_FILE"

echo "Proceso completado. Snapshots guardados en el directorio '$OUTPUT_DIR'."

