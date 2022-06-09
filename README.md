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
    * `CODA.yml`: with this file, you can create a Conda environment 
 4. On you machine, using the CODA.yml and R_CODA.yml files, create the necessary Conda environments:
    * `conda env create -n CODA --file CODA.yml` (note: the environment you create must be named CODA to properly work)
    * `conda env create -n R_CODA --file R_CODA.yml` (note: the environment you create must be named R_CODA to properly work)
5. Once the files have been downloaded and the Conda environments created, you can open the `CODA_preprocess.sh` script on a text editor and edit with the necessary parameters that are user-specific (e.g. location of raw files, output directory, genome files location, etc)

You can then launch the `CODA_preprocess.sh` script from the command line.

Have fun!

