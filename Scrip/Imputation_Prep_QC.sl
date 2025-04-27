#!/bin/bash
#SBATCH --job-name=Imputation_Prep_QC
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/Imputation_Prep_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/Imputation_Prep_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Crear carpetas necesarias para los logs
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Output

# Ejecutar el script de bash
bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/QC_convert_plink.sh  

