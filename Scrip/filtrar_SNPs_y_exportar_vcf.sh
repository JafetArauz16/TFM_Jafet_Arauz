#!/bin/bash

# ========================
# Filtrar SNPs no confiables y generar VCF final por cromosoma
# ========================

echo "======== Activando entorno Conda ========"
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Rutas
WORKDIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output"
BASE_NAME="nhs_subjects_hg19_QC_passed_HRC_corrected"
EXCLUDE_LIST="${WORKDIR}/VCF_by_Chrom/SNPs_to_exclude.txt"
FINAL_PREFIX="nhs_subjects_hg19_QC_passed_HRC_filtered_final"

cd "$WORKDIR"

echo "======== Excluyendo SNPs con 'Strand flip and Allele switch' ========"
plink --bfile "$BASE_NAME" \
  --exclude "$EXCLUDE_LIST" \
  --make-bed \
  --out "$FINAL_PREFIX"

echo "======== Generando archivo VCF comprimido ========"
plink --bfile "$FINAL_PREFIX" \
  --recode vcf-iid bgz \
  --out "$FINAL_PREFIX"

echo "======== Corrigiendo chrX a 23 (si existe) ========"
bcftools view "${FINAL_PREFIX}.vcf.gz" | sed 's/^chrX/23/' | bgzip -c > "${FINAL_PREFIX}_chr23.vcf.gz"
bcftools index "${FINAL_PREFIX}_chr23.vcf.gz"

echo "======== Dividiendo VCF por cromosoma (1–23) ========"
mkdir -p VCF_by_Chrom_Final
for chr in {1..22} 23; do
  bcftools view -r $chr "${FINAL_PREFIX}_chr23.vcf.gz" -Oz -o "VCF_by_Chrom_Final/chr${chr}.vcf.gz"
  bcftools index "VCF_by_Chrom_Final/chr${chr}.vcf.gz"
done

echo "======== FINALIZADO. Archivos VCF limpios listos para imputación ========"
ls -lh VCF_by_Chrom_Final/chr*.vcf.gz

echo "================================================================="
echo " Elaborado por Jafet Arauz - Filtrado y exportación completada"
echo "================================================================="
