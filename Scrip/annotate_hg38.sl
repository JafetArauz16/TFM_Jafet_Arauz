#!/bin/bash
#SBATCH --job-name=annotate_snps
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Annotated/Logs/annotation_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Annotated/Errors/annotation_%j.err
#SBATCH --time=08:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Obtener la fecha y hora actual en formato YYYY-MM-DD_HH-MM-SS
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Definir directorios de trabajo
BASE_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Annotated"
LOGS_DIR="$BASE_DIR/Logs"
ERRORS_DIR="$BASE_DIR/Errors"
OUTPUT_DIR="$BASE_DIR/Output"

# Crear carpetas si no existen
mkdir -p "$LOGS_DIR" "$ERRORS_DIR" "$OUTPUT_DIR"

# Definir archivos de entrada
INPUT_BIM="/home/garauzaguir/TFM_Jafet_Arauz/Raw_Data/Matrix/nhs_subjects.bim"
HG19_REF="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/hg19/snp151_hg19.txt"
HG38_REF="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/hg38/snp151_hg38.txt"

# Definir archivos de salida
OUTPUT_FILE="$OUTPUT_DIR/annotated_snps_$TIMESTAMP.txt"
MISSING_SNPS="$OUTPUT_DIR/missing_snps_$TIMESTAMP.txt"

# Registrar inicio en el log
echo "Inicio de la anotación: $(date)" | tee -a "$LOGS_DIR/annotation_log.txt"

# Verificar que los archivos de entrada existen
for FILE in "$INPUT_BIM" "$HG19_REF" "$HG38_REF"; do
    if [[ ! -f "$FILE" ]]; then
        echo "Error: Archivo no encontrado -> $FILE" | tee -a "$LOGS_DIR/annotation_log.txt"
        exit 1
    fi
done

# Extraer RSIDs del archivo BIM
cut -f2 "$INPUT_BIM" > "$OUTPUT_DIR/rsid_list.txt"

# Buscar RSIDs en hg19 y extraer cromosoma y posición
grep -wFf "$OUTPUT_DIR/rsid_list.txt" "$HG19_REF" | awk '{print $5, $2, $3}' > "$OUTPUT_DIR/snps_hg19_temp.txt"

# Buscar RSIDs en hg38 y extraer cromosoma y posición
grep -wFf "$OUTPUT_DIR/rsid_list.txt" "$HG38_REF" | awk '{print $5, $2, $3}' > "$OUTPUT_DIR/snps_hg38_temp.txt"

# Unir los resultados de hg19 y hg38, priorizando hg38 cuando está disponible
awk 'NR==FNR {hg38[$1]=$2 "\t" $3; next} {if ($1 in hg38) print $1, hg38[$1]; else print $1, $2, $3}' \
    "$OUTPUT_DIR/snps_hg38_temp.txt" "$OUTPUT_DIR/snps_hg19_temp.txt" > "$OUTPUT_FILE"

# Identificar RSIDs que no se encontraron en ninguna referencia
grep -wFvf "$OUTPUT_FILE" "$OUTPUT_DIR/rsid_list.txt" > "$MISSING_SNPS"

# Contar SNPs anotados y no encontrados
SNP_COUNT=$(wc -l < "$OUTPUT_FILE")
MISSING_COUNT=$(wc -l < "$MISSING_SNPS")

# Registrar fin en el log
echo "Total SNPs anotados: $SNP_COUNT" | tee -a "$LOGS_DIR/annotation_log.txt"
echo "SNPs no encontrados: $MISSING_COUNT" | tee -a "$LOGS_DIR/annotation_log.txt"
echo "Anotación completada: $(date)" | tee -a "$LOGS_DIR/annotation_log.txt"
