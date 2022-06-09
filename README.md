# CODA use and setup

Dear user,<br/>CODA is a workflow developed for the preprocessing of Combo-Seq data.
<br/>
<br/>
### Important!
After the first use, every time you re-run the `CODA_preprocess.sh` script, you only need to perform **step 5**.
<br/>
<br/>
<br/>
Before you start using CODA, some initial setup is required:
1. You need to download the **GTF** and **FASTA** files of your reference genome of interest (you can skip this step if you already have the indexed files for RSEM)
2. You need to download the **BBMap suite** (https://sourceforge.net/projects/bbmap/files/)
3. Download the files in this GitHub repository, which include: 
    * `CODA_preprocess.sh`: this is main script for processing the Combo-Seq data 
    * `merge_mirge_files.R`: this script is called by the `CODA_preprocess.sh` script and is necessary to group together all files output by miRge3.0 (note: skiping this step causes the main step
    * `CODA` and `R_CODA`: with these files, you can create a Conda environment (explained at step 4) 
 4. On you machine, you can create the necessary Conda environments by runing the following commands in the terminal:<br/>
    *  `conda create -n CODA --file CODA`<br/>
    *  `conda create -n R_CODA --file R_CODA`<br/>
   (Note: the environments you create must be named CODA and R_CODA for the script to properly work)
5. Once the files have been downloaded and the Conda environments created, you can open the `CODA_preprocess.sh` script on a text editor and edit with the necessary parameters that are user-specific (e.g. location of raw files, output directory, genome files location, etc)

You can then launch the `CODA_preprocess.sh` script from the command line.<br/>
<br/>
<br/>
Have fun!

