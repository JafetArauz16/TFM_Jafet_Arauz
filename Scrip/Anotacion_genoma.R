# Cargar las librerias a utilizar

library(GenomicRanges)
library(AnnotationHub)
library(VariantAnnotation)
library(BiocManager)
library(data.table)  
library(biomaRt)

cat("=== Iniciando proceso de anotación con Bioconductor ===\n")

# Cargar rutas desde las variables de entorno
ruta_data <- Sys.getenv("ARCHIVOS_DATA")
ruta_salidas <- Sys.getenv("SALIDAS")

# Cargar los datos
# cat("Cargando archivo principal...\n")
# data <- fread("nhs_subjects.bim", header = FALSE, stringsAsFactors = FALSE)
# colnames(data) <- c("Chromosome", "rsID", "GeneticDist", "Position", "Allele1", "Allele2")
# cat("Archivo principal cargado. Total de rsID en archivo principal: ", nrow(data), "\n")
cat("Cargando archivo de datos principal...\n")

data <- fread(file.path(ruta_data, "nhs_subjects.bim"), header = FALSE, stringsAsFactors = FALSE)
colnames(data) <- c("Chromosome", "rsID", "GeneticDist", "Position", "Allele1", "Allele2")
cat("Archivo principal cargado exitosamente. Total de rsID en archivo principal:", nrow(data), "\n")



# Revisar las primeras lienas de data
head(data)
str(data)


data$rsID <- as.character(data$rsID)  

# Conectar a Ensembl para hg38
cat("Conectando a Ensembl para hg38...\n")
ensembl_hg38 <- useEnsembl(biomart = "ENSEMBL_MART_SNP", dataset = "hsapiens_snp")

# Obtener la anotación en hg38
cat("Anotando con hg38...")
hg38_annotations <- getBM(
  attributes = c("refsnp_id", "chr_name", "chrom_start", "allele", "minor_allele"),
  filters = "snp_filter",
  values = data$rsID,
  mart = ensembl_hg38
)

# Renombrar columnas
colnames(hg38_annotations) <- c("rsID", "Chromosome_annot", "Position_hg38", "Allele_Ref", "Allele_Minor")
hg38_annotations$rsID <- as.character(hg38_annotations$rsID)  

# Identificar ensamblajes estándar y alternativos
standard_chromosomes <- as.character(c(1:22, "X", "Y", "MT"))
hg38_annotations$Is_Standard <- hg38_annotations$Chromosome_annot %in% standard_chromosomes

hg38_annotations <- hg38_annotations[order(-hg38_annotations$Is_Standard), ]
anyDuplicated(hg38_annotations$rsID)
cat("Número de duplicados en hg38 antes de eliminar: ", anyDuplicated(hg38_annotations$rsID), "\n")


# Eliminar duplicados en hg38_annotations
hg38_annotations <- hg38_annotations[!duplicated(hg38_annotations$rsID), ]
anyDuplicated(hg38_annotations$rsID)
cat("Número de duplicados en hg38 después de eliminar: ", anyDuplicated(hg38_annotations$rsID), "\n")


# anotaciones que no son estandar
non_standard_annotations <- hg38_annotations[!hg38_annotations$Is_Standard, ]
cat("Número de anotaciones no estándar:", nrow(non_standard_annotations), "\n")
non_standard_rsID <- non_standard_annotations$rsID

# Unir con los datos originales (asegurar orden original)
cat("Uniendo anotaciones con datos originales...\n")
annotated_data <- merge(data, hg38_annotations, by = "rsID", all.x = TRUE, sort = FALSE)

# Reemplazar Chromosome con Chromosome_annot donde existe una anotación
annotated_data[, Chromosome := ifelse(!is.na(Chromosome_annot), Chromosome_annot, Chromosome)]
annotated_data[, Position := ifelse(!is.na(Position_hg38), Position_hg38, Position)]


# Eliminar columnas innecesarias y forzar que solo queden las relevantes
annotated_data <- annotated_data[, .(rsID, Chromosome, GeneticDist, Position, Allele1, Allele2)]


# Identificar los rsID que no fueron anotados con hg38
rsID_sin_anotar <- annotated_data[Chromosome == 0, rsID]
rsID_sin_anotar <- as.character(rsID_sin_anotar)
cat("Número de rsID no encontrados en hg38:", length(rsID_sin_anotar), "\n")

##### Anotación con hg19 #####
sin_anotar <- data[rsID %in% rsID_sin_anotar]

cat("Anotando rsID faltantes con hg19...\n")
cat("Conectando a Ensembl para hg19...\n")
ensembl_hg19 <- useMart(biomart = "ENSEMBL_MART_SNP", dataset = "hsapiens_snp", host = "https://grch37.ensembl.org")

cat("Anotando rsID faltantes con hg19...\n")
hg19_annotations <- getBM(
  attributes = c("refsnp_id", "chr_name", "chrom_start", "allele", "minor_allele"),
  filters = "snp_filter",
  values = sin_anotar$rsID,
  mart = ensembl_hg19
)

colnames(hg19_annotations) <- c("rsID", "Chromosome_annot", "Position_hg37", "Allele_Ref", "Allele_Minor")
hg19_annotations$rsID <- as.character(hg19_annotations$rsID)

# Unir con los datos originales (asegurar orden original)
cat("Uniendo anotaciones con hg19...\n")
hg19_annotated <- merge(sin_anotar, hg19_annotations, by = "rsID", all.x = TRUE, sort = FALSE)

# Reemplazar Chromosome con Chromosome_annot donde existe una anotación
hg19_annotated[, Chromosome := ifelse(!is.na(Chromosome_annot), Chromosome_annot, Chromosome)]
hg19_annotated[, Position := ifelse(!is.na(Position_hg37), Position_hg37, Position)]

# Eliminar columnas innecesarias y forzar que solo queden las relevantes
hg19_annotated <- hg19_annotated[, .(rsID, Chromosome, GeneticDist, Position, Allele1, Allele2)]

# Identificar los rsID que no se encontraron ni en hg38 ni en hg19
not_found_rsID <- hg19_annotated[Chromosome == 0, rsID]
cat("Número de rsID no encontrados en ninguna referencia:", length(not_found_rsID), "\n")

# filtra la tabla de hg19 anotated solo con los que tienen anotacion 
hg19_annotated <- hg19_annotated[!rsID %in% not_found_rsID]

# combinar hg19_annotated con annotated_data y guaradarlo como anotado_final
cat("Combinando todas las anotaciones...\n")
anotado_final <- rbind(annotated_data, hg19_annotated, fill = TRUE)
anyDuplicated(anotado_final$rsID)

# Eliminar duplicados en anotado_final
cat("Número de duplicados en el archivo final antes de eliminar:", anyDuplicated(anotado_final$rsID), "\n")
anotado_final <- anotado_final[!duplicated(anotado_final$rsID), ]
anyDuplicated(anotado_final$rsID)
cat("Número de duplicados en el archivo final después de eliminar:", anyDuplicated(anotado_final$rsID), "\n")

# Guardar el archivo anotado final
cat("Guardando archivo final anotado...\n")
fwrite(anotado_final, file.path(ruta_salidas, "nhs_subjects_anotado.bim"), sep = " ", col.names = FALSE)
cat("Archivo anotado guardado exitosamente.\n")

# Guardar rsID no encontrados
cat("Guardando archivo de rsID no encontrados...\n")
writeLines(not_found_rsID, file.path(ruta_salidas, "rsID_no_encontrados.txt"))
cat("Archivo de rsID no encontrados guardado exitosamente.\n")

cat("=== Proceso completado ===\n")

