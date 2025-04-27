#!/bin/bash

echo =============================
echo Generando archivos PLINK sincronizados con anotaciones
echo =============================

# Activar entorno Conda
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env
echo Entorno activado

# === Rutas ===
ORIG_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Raw_Data/Matrix"
ANOTACIONES="/home/garauzaguir/TFM_Jafet_Arauz/Results/liftOver/Output/nhs_subjects_hg19.bed"
OUTPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output"
OUTPUT_PREFIX="nhs_subjects_hg19"

BIM_ORIG="${ORIG_DIR}/nhs_subjects.bim"
BED_ORIG="${ORIG_DIR}/nhs_subjects.bed"
FAM_ORIG="${ORIG_DIR}/nhs_subjects.fam"

mkdir -p "$OUTPUT_DIR"

# === Paso 1: limpiar anotaciones ===
ANNOT_CLEAN="${OUTPUT_DIR}/anotaciones_clean.bed"
awk '$1 !~ /_alt/ {gsub("chr", "", $1); print}' "$ANOTACIONES" > "$ANNOT_CLEAN"

# === Paso 2: crear nuevo .bim con anotaciones ===
BIM_CORRECTED="${OUTPUT_DIR}/${OUTPUT_PREFIX}_corrected.bim"
awk 'NR==FNR {chr[$4]=$1; pos[$4]=$2; next}
     ($2 in pos) { $1=chr[$2]; $4=pos[$2]; print }' "$ANNOT_CLEAN" "$BIM_ORIG" > "$BIM_CORRECTED"

# === Paso 3: crear lista de SNPs válidos ===
cut -f2 "$BIM_CORRECTED" > "${OUTPUT_DIR}/snps_validos.txt"

# === Paso 4: generar archivos PLINK filtrados ===
plink --bfile "${ORIG_DIR}/nhs_subjects" \
      --extract "${OUTPUT_DIR}/snps_validos.txt" \
      --make-bed \
      --out "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp"

# === Paso 5: reemplazar .bim por el corregido ===
mv "$BIM_CORRECTED" "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp.bim"

# === Paso 6: regenerar los archivos para sincronizarlos bien ===
plink --bfile "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp" \
      --make-bed \
      --out "${OUTPUT_DIR}/${OUTPUT_PREFIX}"

# === Paso 7: limpiar archivos temporales ===
rm -f "${OUTPUT_DIR}/snps_validos.txt"
rm -f "$ANNOT_CLEAN"
rm -f "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp.bim"
rm -f "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp.bed"
rm -f "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp.fam"
rm -f "${OUTPUT_DIR}/${OUTPUT_PREFIX}_tmp.log"

# === Mostrar archivos finales ===
echo =============================
echo Archivos PLINK sincronizados y anotados generados:
ls -lh "${OUTPUT_DIR}/${OUTPUT_PREFIX}".*
echo =============================


echo ============================= Finalizado con éxito =============================
echo ============================= Elaborado por Jafet Arauz =============================



