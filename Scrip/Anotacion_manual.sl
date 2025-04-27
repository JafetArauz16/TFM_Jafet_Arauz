#!/bin/bash
#SBATCH --job-name=Anotacion_genomas
#SBATCH --output=/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma/Logs/annotation_output_%j.txt
#SBATCH --error=/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma/Logs/annotation_error_%j.txt
#SBATCH --time=3:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH -p medium
#SBATCH --mail-type=BEGIN,END,FAIL      # Notificacion por correo en caso de que el analisis falle
#SBATCH --mail-user=garauzaguir@alumni.unav.es                  # Notificacion por correo en caso de que el analisis falle

# Crear la carpeta de resultados si no existe
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma/Logs
mkdir -p /home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma/Outputs

# Definir las rutas como variables de entorno
export ARCHIVOS_DATA="/home/garauzaguir/TFM_Jafet_Arauz/Raw_Data/Matrix/"
export REFERENCIAS="/home/garauzaguir/TFM_Jafet_Arauz/Reference_Data/"
export SALIDAS="/home/garauzaguir/TFM_Jafet_Arauz/Results/Anotacion_genoma/Outputs"

# Cargar modulos y enviroment
conda activate GenoNexus_Env



# Ejecutar el script de R
Rscript Anotacion_genoma_con_R.R
