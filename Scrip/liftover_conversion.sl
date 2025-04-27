#!/bin/bash
#SBATCH --job-name=liftover_hg19_to_hg38
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/liftOver/Logs/liftover_%j.out
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/liftOver/Logs/liftover_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --partition=short
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=garauzaguir@alumni.unav.es


# Ejecutar el script liftOver.sh
bash /home/garauzaguir/TFM_Jafet_Arauz/Scrip/liftOver.sh

