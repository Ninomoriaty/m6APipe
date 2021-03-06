#!/bin/Rscript
## Rscript MeTDiff.R <designfile> <gtf> <compare_str> eg. Rscript MeTDiff.R designfile.txt genes.gtf 
### designfile: Sample_id, Input_filename, IP_filename, group_id
### compare_str: Compairision design (eg: A_vs_B)

library(MeTDiff)
args <- commandArgs(T)
designfile <- args[1]
annotation_file <- args[2]
compare_str <- as.character(args[3])
designtable <- read.csv(designfile,head = TRUE,stringsAsFactors=FALSE, colClasses = c("character"))
# Running MeTDiff quantification
if(length(unique(designtable$Group)) < 2){
  stop( "The count of Group is less than two, please check your designfile.")
}else if( compare_str == "two_group" ){
  # Running MeTDiff quantification without compare_str beacause of only two groups
  group_id_1 <- unique(designtable$Group)[1]
  group_id_2 <- unique(designtable$Group)[2]
}else{
  # Running MeTDiff quantification with compare_str
  group_id_1 <- strsplit(as.character(compare_str), "_vs_")[[1]][1]
  group_id_2 <- strsplit(as.character(compare_str), "_vs_")[[1]][2]
}

#setting CONTROL_SITUATION and TREATED_SITUATION 
#default 1 is CONTROL_SITUATION else are TREATED_SITUATION
filelist = grep(".bai",list.files(path = "./",pattern = ".bam"),value = TRUE,invert = TRUE)
bamlist <- NULL
for(group_id in c(group_id_1,group_id_2)){
  input = grep(paste0("input_",group_id),filelist,value = TRUE)
  ip = grep(paste0("ip_",group_id),filelist,value = TRUE)
  bamlist[[group_id]] <- cbind(input,ip)
}

##Running MeTDiff and rename the output name
output_pattern <- paste0("metdiff_diffm6A_",group_id_1,"_",group_id_2)
metdiff(GENE_ANNO_GTF=annotation_file,
        IP_BAM = bamlist[[group_id_1]][,2],
        INPUT_BAM = bamlist[[group_id_1]][,1],
        TREATED_IP_BAM = bamlist[[group_id_2]][,2],
        TREATED_INPUT_BAM = bamlist[[group_id_2]][,1],
        EXPERIMENT_NAME = output_pattern)
#set output_name
output_bed_name <- paste0("metdiff_",group_id_1,"_",group_id_2,".bed") #diff_peak.bed
bed_name <- paste0(output_pattern,"/diff_peak.xls") #choose peak.bed diff_peak.bed
xls.to.bed <- paste0("awk 'BEGIN{OFS=\"\t\"}NR>1{print $1":"$2"-"$3,$4,$18,$17,$16}' ", bed_name," > ", output_bed_name)
system(xls.to.bed)