#!/bin/bash

echo "============================"
echo "Convert PLINK → VCF compatible Michigan"
echo "============================"

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Definir ruta de trabajo
WORKDIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output"
cd "$WORKDIR"

BASE="nhs_hg19_corrected"
BFILE="nhs_subjects_hg19_QC_passed_HRC_corrected"
VCF_GZ="${BASE}.vcf.gz"
VCF_SORTED="${BASE}_sorted.vcf.gz"
VCF_CHR_DIR="${WORKDIR}/VCF_by_Chrom"

# Generar VCF comprimido desde PLINK
plink --bfile "$BFILE" \
      --recode vcf bgz \
      --out "$BASE"

# Reemplazar 'chrX' por '23'
bcftools view "$VCF_GZ" | sed 's/^chrX/23/' | bgzip -c > "$VCF_SORTED"
tabix -p vcf "$VCF_SORTED"

# Dividir el VCF por cromosoma
mkdir -p "$VCF_CHR_DIR"
for CHR in {1..22} 23; do
    echo "Dividiendo cromosoma: $CHR"
    bcftools view -r "$CHR" "$VCF_SORTED" \
        -Oz -o "${VCF_CHR_DIR}/chr${CHR}.vcf.gz"
    tabix -p vcf "${VCF_CHR_DIR}/chr${CHR}.vcf.gz"
done

# Limpieza de archivos temporales
echo "Limpiando archivos intermedios..."
rm -f "$VCF_GZ" "$VCF_SORTED" "${VCF_SORTED}.tbi"

conda deactivate

echo "============================"
echo "VCF por cromosoma listo en: $VCF_CHR_DIR"
echo "Archivos temporales eliminados"
echo "============================"
