#!/bin/bash
#SBATCH --job-name=corregir_HRC
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/corregir_HRC_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/corregir_HRC_%j.err
#SBATCH --time=00:30:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Activar entorno
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Ejecutar el script de corrección
bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/aplicar_correcciones_HRC.sh

