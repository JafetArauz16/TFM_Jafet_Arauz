#!/bin/bash

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Incluir ruta local donde está el módulo Perl instalado con cpanm
export PERL5LIB=~/perl5/lib/perl5:$PERL5LIB

# Ejecutar script HRC-1000G-check-bim.pl
perl /home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/HRC-1000G-check-bim.pl \
  -b /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output/nhs_subjects_hg19_QC_passed.bim \
  -f /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output/nhs_subjects_hg19_QC_passed.frq \
  -r /home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/HRC.r1-1.GRCh37.wgs.mac5.sites.tab \
  -h

# Desactivar entorno
conda deactivate

# ============================
# Paso final: Mover archivos generados al subdirectorio organizado
# ============================

OUTPUT_DIR="/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/nhs_subjects_hg19_QC_passed-HRC"
mkdir -p "$OUTPUT_DIR"

echo "Moviendo archivos generados a: $OUTPUT_DIR"

# Mover todos los archivos generados por el script HRC
mv *-nhs_subjects_hg19_QC_passed-HRC.txt "$OUTPUT_DIR" 2>/dev/null

# Mover también Run-plink.sh si existe
[ -f Run-plink.sh ] && mv Run-plink.sh "$OUTPUT_DIR"

# Mover archivos de salida .log y .out si existen (manejo robusto)
shopt -s nullglob
for f in *.log; do
  mv "$f" "$OUTPUT_DIR"
done
for f in *.out; do
  mv "$f" "$OUTPUT_DIR"
done
shopt -u nullglob

echo "Archivos organizados correctamente en: $OUTPUT_DIR"

echo "============================"
echo "Proceso terminado con éxito"
echo "Elaborado por Jafet Arauz"
echo "============================"
