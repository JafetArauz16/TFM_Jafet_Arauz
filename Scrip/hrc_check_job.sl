#!/bin/bash
#SBATCH --job-name=Bim_check
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/bim_check_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Bim_Check/bim_check_%j.err
#SBATCH --time=00:30:00
#SBATCH --mem=32G
#SBATCH --partition=short
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Carga entorno o módulo si aplica
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env

# Ir al directorio del script
cd /home/garauzaguir/TFM_Jafet_Arauz/Scrip

# Ejecutar el script 
bash hrc_check.sh


