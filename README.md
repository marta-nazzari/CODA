# CODA setup and use

Dear user,<br/>CODA is a workflow developed for the preprocessing of Combo-Seq data.
<br/>
<br/>
### Important!
After the first use, every time you re-run the `CODA_preprocess.sh` script, you only need to perform **step 5**.
<br/>
<br/>
<br/>
Before you start using CODA, some initial setup is required:
1. Install conda on your machine (https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
2. Download the **GTF** and **FASTA** files of your reference genome of interest (you can skip this step if you already have the indexed files for RSEM)
3. Download the miRge3.0 library for the organism(s) of interest (https://mirge3.readthedocs.io/en/latest/quick_start.html#mirge3-0-libraries)
4. Download the files contained in this GitHub repository, which include: 
    * `CODA_preprocess.sh`: this is main script for processing the Combo-Seq data 
    * `merge_mirge_files.R`: this script is called by the `CODA_preprocess.sh` script and is necessary to group together all files output by miRge3.0 (note: skipping this step causes the `CODA_preprocess.sh` script to crash)
    * `CODA` and `R_CODA`: with these files, you can create a Conda environment (explained at step 4) 
 4. On you machine, you can create the necessary Conda environments by running the following commands in the terminal:<br/>
    *  `conda create -n CODA --file CODA`<br/>
    *  `conda create -n R_CODA --file R_CODA`<br/>
   (Note: the environments you create must be named CODA and R_CODA for the script to properly work)<br/>
   <br/>Alternatively, you can manually install the required tools on your machine (in which case, the calls to conda environments activation and deactivation need to be commented out). CODA uses: 
         * Cutadapt v3.7
         * FastQC v0.11.9
         * miRge3.0 v0.0.9
         * MultiQC v1.12
         * R v3.6.3
         * RSEM v1.3.3
         * STAR v2.7.10a
5. Once the files have been downloaded and the Conda environments created, you can open the `CODA_preprocess.sh` script on a text editor and edit with the necessary parameters that are user-specific (e.g. location of raw files, output directory, genome files location, etc)

You can then launch the `CODA_preprocess.sh` script from the command line.<br/>
<br/>
<br/>
Have fun!

