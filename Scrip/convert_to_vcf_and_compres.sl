#!/bin/bash
#SBATCH --job-name=Convert_to_VCF_and_Compress
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/convert_to_vcf_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/convert_to_vcf_%j.err
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --partition=short
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Carga entorno o módulo si aplica
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Ir al directorio donde se guardaran los resultados
cd /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output

# Ejecutar el script que convierte a VCF, genera el .gz y el .tbi
bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/convert_to_vcf.sh
