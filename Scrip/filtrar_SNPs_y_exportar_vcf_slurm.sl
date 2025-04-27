#!/bin/bash
#SBATCH --job-name=filtrarVCF
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/filtrarVCF_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/filtrarVCF_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2G
#SBATCH --time=00:30:00
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Activar entorno Conda
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Ejecutar scrip

bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/filtrar_SNPs_y_exportar_vcf.sh
