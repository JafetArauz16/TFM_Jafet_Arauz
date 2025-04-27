#!/bin/bash
#SBATCH --job-name=reconstruir_bim
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/bim_reconstruccion_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Imputation_Prep/Logs/bim_reconstruccion_%j.err
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es

# Ejecutar tu script de bash
bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/reconstruir_bim_liftover.sh
