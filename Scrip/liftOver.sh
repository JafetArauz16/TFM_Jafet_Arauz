#!/bin/bash

# =======================
# Script: liftOver.sh
# =======================
# Descripción: Convierte un archivo .bed de hg38 a hg19 utilizando liftOver.
# =======================

# Activar Conda y cargar el environment correcto
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# =======================
# Definir rutas y archivos
# =======================
INPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma/Outputs"
LIFTOVER_CHAIN="/home/garauzaguir/TFM_Jafet_Arauz/Results/liftOver/hg38ToHg19.over.chain"
OUTPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/liftOver/Output"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
UNMAPPED_FILE="${OUTPUT_DIR}/unmapped_snps.txt"
OUTPUT_BED="${OUTPUT_DIR}/nhs_subjects_hg19.bed"

# =======================
# Crear carpeta de salida si no existe
# =======================
mkdir -p "$OUTPUT_DIR"

# =======================
# Ejecutar LiftOver
# =======================
liftOver "${INPUT_DIR}/nhs_subjects_hg38_chr.bed" "$LIFTOVER_CHAIN" "$OUTPUT_BED" "$UNMAPPED_FILE"  

#liftOver "${INPUT_DIR}/nhs_subjects_filtrada_final.bim" "$LIFTOVER_CHAIN" "$OUTPUT_BIM" "$UNMAPPED_FILE" # eliminar esta linea

# Desactivar environment
conda deactivate

echo ======================= Proceso realizado con exito =======================
echo ======================= Elaborado por Jafet Arauz =======================
