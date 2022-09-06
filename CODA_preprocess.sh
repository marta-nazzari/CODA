# NOTE FOR FIRST USE
# Before running the script for the first time, you need to create a conda environment using the .yml file you can find at 
# After having created the environment once, you don't need to do it anymore
# You can use the line below on the terminal to create the environments called "CODA" and "R_CODA"
# conda create --name CODA -f CODA.yml
# conda create --name R_CODA -f R_CODA.yml

## PARAMETERS TO BE INPUT BY THE USER

# conda location (e.g. "/home/user/miniconda3/etc/profile.d/conda.sh")
CondaLocation=""

## Data directories
# Raw data directory (path to raw .fastq files)
DataDir=""

# Main directory (where all subdirectories will be created)
MainDir=""

# Input raw file formats (e.g. ".fastq"/".fastq.gz")
FileFormat=""

## Specify reference genome files
# Path to genome files (note: only file path e.g. "/path/to/genome/". Don't include filenames)
GenomeDir=""	

# Genome name (e.g. "GRCm39")
GenomeName=""

# Dose genome indexing need to be performed?
# Indexing="y" (means indexing should be performed)
# OR Indexing="n" (means indexing has already been performed and doesn't need to be done again)
Indexing=""

# Name of annotation .fasta file (e.g. "GRCm39.primary_assembly.genome.fa")
# Leave empty if indexing has already been done
Fasta=""	

# Name of annotation .gtf file (e.g. "gencode.vM27.primary_assembly.annotation.gtf")
# Leave empty if indexing has already been done
Gtf=""	

# Path to miRNA library (note: only file path e.g. "/path/to/library/", do not add the organism name)
miRNAPath=""

# Database where miRNA library was downloaded (e.g. "miRBase")
miRNALib=""

# Organism name for miRge3.0 (can be any of human, mouse, fruitfly, nematode, rat, zebrafish) (e.g. "mouse")
Organism=""

## Location of R script used to merge miRge3.0 files (note: only file path e.g. "/path/to/script/". Don't include filename)
MergeMirge=""



#########################################
### DON'T CHANGE ANYTHING BELOW THIS LINE
#########################################

# This script uses the following tools: 
# Cutadapt v3.7
# FastQC v0.11.9
# miRge3.0 v0.0.9
# MultiQC v1.12
# R v3.6.3 with the libraries 'dplyr' and 'magrittr'
# RSEM v1.3.3
# STAR v2.7.10a

TrimDir=${MainDir}"1_cutadapt/"
TrimReport=${TrimDir}"cutadapt_report/"
mirgeDir=${MainDir}"2A_mirge3/"
rsemDir=${MainDir}"2B_rsem/"
QC_BB=${MainDir}"3_QC/BBMap/"
QC_fastQC=${MainDir}"3_QC/FastQC/"

FASTA=${GenomeDir}${Fasta}
GTF=${GenomeDir}${Gtf}


mkdir -p ${TrimDir}
mkdir -p ${TrimReport}
mkdir -p ${QC_BB}
mkdir -p ${QC_fastQC}
mkdir -p ${rsemDir}
mkdir -p ${mirgeDir}

chmod 777 ${MainDir}
chmod 777 ${TrimDir}
chmod 777 ${TrimReport}
chmod 777 ${QC_BB}
chmod 777 ${QC_fastQC}
chmod 777 ${rsemDir}
chmod 777 ${mirgeDir}


# source conda and activate environment
source ${CondaLocation}
conda activate CODA

### OPTIONAL - GENOME INDEXING
# Index genome for rsem 
if [ ${Indexing} == "y" ]; then
rsem-prepare-reference --gtf ${GTF} --star -p 8 ${FASTA} ${GenomeDir}${GenomeName}
Indexing="n"
fi



### 1 - Trimming: Cutadapt 

cd ${DataDir}

Samples=(*)

for S in ${!Samples[@]}; do
echo -e "Cutadapt: ${Samples[S]}" 
SampleName=$( echo ${Samples[S]} | sed "s/${FileFormat}//" )
cutadapt -u 4 -a A{8} -j 5 --minimum-length 15 --output ${TrimDir}${SampleName}.fastq.gz ${Samples[S]} > ${TrimReport}${Samples[S]}.txt
done

echo "Trimming completed!"



### 2A - miRNA mapping and quantification: miRge3.0

cd ${TrimDir}

Samples=(*fastq.gz)

for S in ${!Samples[@]}; do
echo "miRge3.0: ${Samples[S]}" 
miRge3.0 --samples ${Samples[S]} --outDir ${mirgeDir} --mir-DB ${miRNALib} --libraries-path ${miRNAPath} --organism-name ${Organism} --isoform-entropy --AtoI --gff-out -cpu 10
done

echo "miRNA quantification completed"  

## Merge miRge3.0 outputs
# Find all miRNA count files
find ${mirgeDir} -name "miR.Counts.csv" > ${MainDir}sample_list_mirge.txt

conda deactivate
conda activate R_CODA

Rscript ${MergeMirge}"merge_mirge_files.R" ${MainDir}"sample_list_mirge.txt" ${MainDir}"miRNA_counts.txt"

conda deactivate 

conda activate CODA

rm ${MainDir}sample_list_mirge.txt


### 2B - Gene mapping and quantification: rsem

cd ${TrimDir}

Samples=(*fastq.gz)

for S in ${!Samples[@]}; do

echo "rsem: ${Samples[S]}"  
rsem-calculate-expression --star --star-gzipped-read-file -p 15 --seed-length 15 --strandedness forward ${Samples[S]} --no-bam-output --time --quiet ${GenomeDir}${GenomeName} ${rsemDir}${Samples[S]}
done

## Merge rsem outputs
cd ${rsemDir}
FILELIST=$(find ${rsemDir} -name "*genes.results" -printf "%f\t")
rsem-generate-data-matrix ${FILELIST} > ${MainDir}genes_data.tsv
sed -i 's/\.genes.results//g' ${MainDir}genes_data.tsv



### 3 - QC: BBMap, FastQC, MultiQC

echo "Performing Quality Control on trimmed files"

cd ${TrimDir}

Samples=(*fastq.gz)

for S in ${!Samples[@]}; do	
reformat.sh in1=${Samples[S]} \
bhist=${QC_BB}bhist_${Samples[S]}.txt \
qhist=${QC_BB}qhist_${Samples[S]}.txt \
qchist=${QC_BB}qchist_${Samples[S]}.txt \
aqhist=${QC_BB}aqhist_${Samples[S]}.txt \
bqhist=${QC_BB}bqhist_${Samples[S]}.txt \
lhist=${QC_BB}lhist_${Samples[S]}.txt \
gchist=${QC_BB}gchist_${Samples[S]}.txt
done

fastqc -o ${QC_fastQC} ${Samples[@]}

multiqc ${MainDir} --filename ${MainDir}multiqc_report.html

conda deactivate
