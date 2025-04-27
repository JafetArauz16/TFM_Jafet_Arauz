#!/bin/bash

echo "============================="
echo "Aplicando correcciones HRC con PLINK (set con QC y sexo corregido)"
echo "============================="

# Activar entorno Conda
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env
echo "Entorno activado"

# === Rutas ===
INPUT_PREFIX="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output/nhs_subjects_hg19_QC_passed"
CORR_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/nhs_subjects_hg19_QC_passed-HRC"
OUTPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output"
TMP_PREFIX="${OUTPUT_DIR}/TEMP_QC"

# Función para verificar archivos PLINK
check_plink_files() {
  for ext in bed bim fam; do
    if [ ! -f "$1.$ext" ]; then
      echo " Error: No se generó $1.$ext"
      exit 1
    fi
  done
}

# Paso 1: Excluir SNPs no compatibles
plink --bfile "$INPUT_PREFIX" \
      --exclude "${CORR_DIR}/Exclude-nhs_subjects_hg19_QC_passed-HRC.txt" \
      --make-bed \
      --out "${TMP_PREFIX}1"
check_plink_files "${TMP_PREFIX}1"

# Paso 2: Corregir cromosoma y posición
plink --bfile "${TMP_PREFIX}1" \
      --update-map "${CORR_DIR}/Chromosome-nhs_subjects_hg19_QC_passed-HRC.txt" \
      --update-chr \
      --make-bed \
      --out "${TMP_PREFIX}2"
check_plink_files "${TMP_PREFIX}2"

plink --bfile "${TMP_PREFIX}2" \
      --update-map "${CORR_DIR}/Position-nhs_subjects_hg19_QC_passed-HRC.txt" \
      --make-bed \
      --out "${TMP_PREFIX}3"
check_plink_files "${TMP_PREFIX}3"

# Paso 3: Corregir orientación de alelos (flip)
plink --bfile "${TMP_PREFIX}3" \
      --flip "${CORR_DIR}/Strand-Flip-nhs_subjects_hg19_QC_passed-HRC.txt" \
      --make-bed \
      --out "${TMP_PREFIX}4"
check_plink_files "${TMP_PREFIX}4"

# Paso 4: Forzar alelo A1
plink --bfile "${TMP_PREFIX}4" \
      --a1-allele "${CORR_DIR}/Force-Allele1-nhs_subjects_hg19_QC_passed-HRC.txt" \
      --make-bed \
      --out "${OUTPUT_DIR}/nhs_subjects_hg19_QC_passed_HRC_corrected"
check_plink_files "${OUTPUT_DIR}/nhs_subjects_hg19_QC_passed_HRC_corrected"

# Paso 5: Limpiar archivos temporales
rm -f "${TMP_PREFIX}"*

echo "============================="
echo " Archivos corregidos generados:"
ls -lh "${OUTPUT_DIR}/nhs_subjects_hg19_QC_passed_HRC_corrected".*
echo "============================="

echo "============================="
echo " Finalizado con éxito"
echo " Elaborado por Jafet Arauz"
echo "============================="
