#!/bin/bash
#SBATCH --job-name=Anotacion_genomas_bioconductor
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma_bioconductor/Logs/annotation_bioconductor_output_%j.txt
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma_bioconductor/Logs/annotation_bioconductor_error_%j.txt
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2G
#SBATCH -p short
#SBATCH --mail-type=BEGIN,END,FAIL      # Notificacion por correo en caso de que el analisis falle
#SBATCH --mail-user=garauzaguir@alumni.unav.es                  # Notificacion por correo en caso de que el analisis falle

# Crear la carpeta de resultados si no existe
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma_bioconductor
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma_bioconductor/Logs
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma_bioconductor/Outputs

# Definir las rutas como variables de entorno
export ARCHIVOS_DATA="/home/garauzaguir/TFM_Jafet_Arauz/Raw_Data/Matrix/"
export REFERENCIAS="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/"
export SALIDAS="/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma_bioconductor/Outputs"

# Cargar modulos y enviroment
source /home/garauzaguir/TFM_Jafet_Arauz/Programas/Miniconda3/etc/profile.d/conda.sh
conda activate GenoNexus_Env



# Ejecutar el script de R
Rscript Anotacion_genoma.R
