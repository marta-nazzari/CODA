# NOTE FOR FIRST USE
# Before running the script for the first time, you need to create a conda environment using the .yml file you can find at 
# After having created the environment once, you don't need to do it anymore
# You can use the line below on the terminal to create the environment called "CODA"
# conda create --name CODA -f coda.yml

# conda location (e.g. "/home/user/miniconda3/etc/profile.d/conda.sh")
CondaLocation=""

conda activate CODA

## PARAMETERS TO BE INPUT BY THE USER

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

# Name of annotation .fasta file (e.g. "GRCm39.primary_assembly.genome.fa")
Fasta=""	

# Name of annotation .gtf file (e.g. "gencode.vM27.primary_assembly.annotation.gtf")
Gtf=""	

# Have you already performed the reference genome indexing? 
# Indexing="y" OR Indexing="n"
Indexing=""

# Path to miRNA library (note: only file path e.g. "/path/to/library/")
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
TrimDir=${MainDir}"1_cutadapt/"
TrimReport=${TrimDir}"cutadapt_report/"
mirgeDir=${MainDir}"2A_mirge3/"
rsemDir=${MainDir}"2B_rsem/"
QC_BB=${MainDir}"3_QC/BBMap/"
QC_fastQC=${MainDir}"3_QC/FastQC/"

FASTA=${GenomeDir}${Fasta}
GTF=${GenomeDir}${Gtf}


mkdir -p ${TrimDir}
mkdir -p ${QC_BB}
mkdir -p ${QC_fastQC}
mkdir -p ${rsemDir}
mkdir -p ${mirgeDir}

chmod 777 ${MainDir}
chmod 777 ${TrimDir}
chmod 777 ${QC_BB}
chmod 777 ${QC_fastQC}
chmod 777 ${rsemDir}
chmod 777 ${mirgeDir}


# source conda and activate environment
source ${CondaLocation}
conda activate 

### OPTIONAL - GENOME INDEXING
# Index genome for rsem 
if [ ${Indexing} == "n" ]; then
rsem-prepare-reference --gtf ${GTF} --star -p 8 ${FASTA} ${GenomeDir}${GenomeName}
Indexing="y"
fi



### 1 - Trimming: Cutadapt 

cd ${DataDir}

Samples=(*)

for S in ${!Samples[@]}; do
echo -e "Cutadapt: ${Samples[S]}" 
SampleName=( echo ${Samples[S]} | sed 's/${FileFormat}//' )
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

Rscript ${MergeMirge}"merge_mirge_files.R" ${MainDir}sample_list_mirge.txt ${mirgeDir}"miRNA_counts.txt"



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
rsem-generate-data-matrix ${FILELIST} > ${rsemDir}genes_data.tsv
sed -i 's/\.genes.results//g' ${rsemDir}genes_data.tsv



### 3 - QC: BBMap, FastQC, MultiQC

cd ${TrimDir}

Samples=(*fastq.gz)

for S in ${!Samples[@]}; do	
/share/tools/bbmap_38_94/bbmap/reformat.sh in1=${Samples[S]} \
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