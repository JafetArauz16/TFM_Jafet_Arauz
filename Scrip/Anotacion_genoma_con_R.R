
# Cargar librerias
library(data.table)    
library(dplyr)  


cat("=== Iniciando proceso de anotación manual ===\n")

# Leer rutas desde variables de entorno definidas en el archivo .slurm
ruta_data <- Sys.getenv("ARCHIVOS_DATA")
ruta_referencias <- Sys.getenv("REFERENCIAS")
ruta_salidas <- Sys.getenv("SALIDAS")

# Comprobar si las rutas se cargaron correctamente
cat("Ruta de archivos de datos: ", ruta_data, "\n")
cat("Ruta de archivos de referencia: ", ruta_referencias, "\n")

# Cargar archivos
cat("Cargando archivo de datos principal...\n")

data <- fread(file.path(ruta_data, "nhs_subjects.bim"), header = FALSE, stringsAsFactors = FALSE)
colnames(data) <- c("Chromosome", "rsID", "Genetic_Distance", "Position", "Allele_Ref", "Allele_Minor")
cat("Archivo principal cargado exitosamente. Total de rsID en archivo principal:", nrow(data), "\n")

cat("Cargando archivos de referencia (hg19 y hg38)...\n")
hg19_reference <- fread(file.path(ruta_referencias, "hg19/snp151_hg19.txt"),
                        header = FALSE, stringsAsFactors = FALSE, select = c(5, 2, 3))

hg38_reference <- fread(file.path(ruta_referencias, "hg38/snp151_hg38.txt"),
                        header = FALSE, stringsAsFactors = FALSE, select = c(5, 2, 3))

cat("Archivos de referencia cargados exitosamente.\n")

                    

# Renombrar las columnas para que coincidan con la estructura de 'data'
colnames(hg19_reference) <- c("rsID", "Chromosome", "Position")
colnames(hg38_reference) <- c("rsID", "Chromosome", "Position")

# Asegurar que los Chromosome no tengan el prefijo 'chr' (eliminar si existe)
hg19_reference$Chromosome <- gsub("chr", "", hg19_reference$Chromosome)
hg38_reference$Chromosome <- gsub("chr", "", hg38_reference$Chromosome)


# Asegurar que los rsID sean tipo carácter
hg19_reference$rsID <- as.character(hg19_reference$rsID)
hg38_reference$rsID <- as.character(hg38_reference$rsID)

# === Generar los subsets independientes ===
cat("Buscando coincidencias con hg38...\n")
# Encontrar coincidencias con hg38
hg38_subset <- merge(data, hg38_reference, by = "rsID")

hg38_subset <- hg38_subset %>% 
  select(rsID, Chromosome_Ref = Chromosome.y, Position_Ref = Position.y)

# Definir los cromosomas estándar
standard_chromosomes <- as.character(c(1:22, "X", "Y", "MT"))
# Añadir columna para identificar si el cromosoma es estándar
hg38_subset$Is_Standard <- hg38_subset$Chromosome_Ref %in% standard_chromosomes
# Ordenar para dar prioridad a los estándar (TRUE = 1, FALSE = 0)
hg38_subset <- hg38_subset[order(-hg38_subset$Is_Standard), ]
cat("Número de duplicados encontrados en hg38 antes de eliminar:", anyDuplicated(hg38_subset$rsID), "\n")

# Eliminar duplicados priorizando los estándar
hg38_subset <- hg38_subset[!duplicated(hg38_subset$rsID), ]

# Confirmar que ya no hay duplicados
cat("Número de duplicados encontrados en hg38 después de eliminar:", anyDuplicated(hg38_subset$rsID), "\n")

# Identificar anotaciones que no son estándar
non_standard_annotations <- hg38_subset[!hg38_subset$Is_Standard, ]
non_standard_rsID <- non_standard_annotations$rsID
cat("Número de anotaciones no estándar en hg38:", nrow(non_standard_annotations), "\n")


cat("Coincidencias encontradas con hg38:", nrow(hg38_subset), "\n")

# Crear un vector con los rsID que NO se encontraron en hg38
rsID_no_encontrados_hg38 <- data %>%
  filter(!rsID %in% hg38_subset$rsID) %>%  
  pull(rsID)

cat ("No fueron encontrados en hg38:", length(rsID_no_encontrados_hg38), "\n")
     
#### ahora con hg37 #####
# Filtrar 'data' solo para los rsID que no fueron encontrados en hg38
data_filtrada <- data %>% filter(rsID %in% rsID_no_encontrados_hg38)

# Encontrar coincidencias con hg19
cat("Buscando coincidencias con hg19...\n")
hg19_subset <- merge(data_filtrada, hg19_reference, by = "rsID")

hg19_subset <- hg19_subset %>% 
  select(rsID, Chromosome_Ref = Chromosome.y, Position_Ref = Position.y)

cat("Coincidencias encontradas con hg19:", nrow(hg19_subset), "\n")

# Combinar ambos subsets en un solo data frame
subset_final <- bind_rows(hg38_subset, hg19_subset)

cat("Total de coincidencias encontradas (hg38 + hg19):", nrow(subset_final), "\n")

# === Actualizar el archivo 'data' basado en el subset_final ===

# Hacer un merge para traer la anotación encontrada
cat("Número de duplicados en subset_final antes de merge final:", anyDuplicated(subset_final$rsID), "\n")

data_annotated <- merge(data, subset_final, by = "rsID", all.x = TRUE)

# Actualizar la posición y cromosoma si en 'data' estaban en cero
data_annotated <- data_annotated %>%
  mutate(
    Chromosome = ifelse(Chromosome == 0 & !is.na(Chromosome_Ref), Chromosome_Ref, Chromosome),
    Position = ifelse(Position == 0 & !is.na(Position_Ref), Position_Ref, Position)
  ) %>%
  select(Chromosome, rsID, Genetic_Distance, Position, Allele_Ref, Allele_Minor)

cat("Proceso de actualización completado. Total de filas en archivo final:", nrow(data_annotated), "\n")


# Buscar los rsID que no se encontraron en ninguna base de referencia

rsID_no_encontrados <- data_annotated %>%
  filter(Chromosome == 0 & Position == 0) %>%
  pull(rsID)

cat("Número de rsID no encontrados en ninguna referencia:", length(rsID_no_encontrados), "\n")


# Guardar los rsID no encontrados en un archivo para analizarlos después
writeLines(rsID_no_encontrados, file.path(ruta_salidas, "rsID_no_encontrados.txt"))
cat("Lista de rsID no encontrados guardada exitosamente como 'rsID_no_encontrados.txt'.\n")

# Obtener el nombre del archivo original sin la extensión
archivo_original <- tools::file_path_sans_ext("nhs_subjects.bim")

# Crear el nombre del archivo anotado
nombre_archivo_anotado <- paste0(archivo_original, "_anotada.bim")

# Guardar el archivo anotado
fwrite(data_annotated, file.path(ruta_salidas, nombre_archivo_anotado), sep = " ", col.names = FALSE)

cat("Archivos de salida guardados exitosamente en: ", ruta_salidas, "\n") 
