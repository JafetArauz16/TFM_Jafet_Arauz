#!/bin/bash

echo ============================
echo Script: QC_convert_plink.sh
echo Descripción: Control de calidad con asignación de sexo con PLINK
echo ============================

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Variables
INPUT_BED="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output/nhs_subjects_hg19"
IMPUTATION_PREP_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output"
FIXED_DATA="${IMPUTATION_PREP_DIR}/nhs_subjects_hg19_sex_fixed"

mkdir -p "$IMPUTATION_PREP_DIR"

echo ============================
echo "[INFO] Paso 0: Eliminar variantes con _alt"
echo ============================
awk '$1 !~ /_alt/' "${INPUT_BED}.bim" > "${INPUT_BED}_filtered.bim"
cp "${INPUT_BED}.bed" "${INPUT_BED}_filtered.bed"
cp "${INPUT_BED}.fam" "${INPUT_BED}_filtered.fam"
INPUT_BED="${INPUT_BED}_filtered"

cut -f2 "${INPUT_BED}.bim" > "${IMPUTATION_PREP_DIR}/snp_no_alt.txt"
plink --bfile "$INPUT_BED" \
      --extract "${IMPUTATION_PREP_DIR}/snp_no_alt.txt" \
      --make-bed \
      --out "${INPUT_BED}_cleaned"

INPUT_BED="${INPUT_BED}_cleaned"

echo ============================
echo "[INFO] Paso 1: Inferencia de sexo automática con PLINK"
echo ============================
plink --bfile "$INPUT_BED" --impute-sex --make-bed --out "${FIXED_DATA}_tmp"

# Renombrar temporalmente
mv "${FIXED_DATA}_tmp.bed" "${FIXED_DATA}.bed"
mv "${FIXED_DATA}_tmp.bim" "${FIXED_DATA}.bim"
mv "${FIXED_DATA}_tmp.fam" "${FIXED_DATA}.fam"

# Eliminar muestras con sexo aún en 0
awk '$5 == 0 {print $1, $2}' "${FIXED_DATA}.fam" > "${IMPUTATION_PREP_DIR}/muestras_sin_sexo_asignado.txt"
SIN_SEXO=$(wc -l < "${IMPUTATION_PREP_DIR}/muestras_sin_sexo_asignado.txt")

if [ "$SIN_SEXO" -gt 0 ]; then
    echo "[INFO] Eliminando $SIN_SEXO muestras que aún no tienen sexo asignado."
    plink --bfile "$FIXED_DATA" \
          --remove "${IMPUTATION_PREP_DIR}/muestras_sin_sexo_asignado.txt" \
          --make-bed \
          --out "${FIXED_DATA}_filtered"
    mv "${FIXED_DATA}_filtered.bed" "${FIXED_DATA}.bed"
    mv "${FIXED_DATA}_filtered.bim" "${FIXED_DATA}.bim"
    mv "${FIXED_DATA}_filtered.fam" "${FIXED_DATA}.fam"
else
    echo "[INFO] Todas las muestras tienen sexo asignado correctamente."
fi

echo ============================
echo "[INFO] Paso 2: Control de calidad final"
echo ============================
plink --bfile "$FIXED_DATA" \
      --geno 0.10 \
      --mind 0.10 \
      --maf 0.01 \
      --hwe 1e-6 \
      --allow-no-sex \
      --make-bed \
      --out "${IMPUTATION_PREP_DIR}/nhs_subjects_hg19_QC_passed"

comm -23 <(awk '{print $2}' "${FIXED_DATA}.fam" | sort) \
         <(awk '{print $2}' "${IMPUTATION_PREP_DIR}/nhs_subjects_hg19_QC_passed.fam" | sort) \
         > "${IMPUTATION_PREP_DIR}/muestras_no_pasaron_QC.txt"

echo ======================================
echo Archivos finales generados:
echo "- Archivos .bed/.bim/.fam: nhs_subjects_hg19_QC_passed"
echo "- muestras_sin_sexo_asignado.txt"
echo "- muestras_no_pasaron_QC.txt"
echo ======================================

# Desactivar enviroment
conda deactivate

echo ============================
echo Proceso COMPLETADO con éxito
echo Elaborado por Jafet Arauz
echo ============================
