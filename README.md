# Cerebral-Palsy-WES
Max Wrubel
Jin Group, Washington University School of Medicine

Whole exome sequencing and genetic variant analysis from cerebral palsy trios. 

##Setup
CNVs can be called from WES data on RIS running the docker container hosted at https://hub.docker.com/r/molecular/conifer. To use CoNIFER's plotting functions, you will need to use Python 2.7 with a matplotlib. You can do this by the CoNIFER container on top of an Anaconda container like so:

`bsub -G compute-jin810 -Is -q general-interactive -a 'docker(continuumio/anaconda)' /bin/bash` 
`bsub -G compute-jin810 -Is -q general-interactive -a 'docker(molecular/conifer)' /bin/bash`

Note: The CoNIFER docker container writes the script at `/home/bio/conifer_v0.2.2/conifer.py`

##Analysis

### Step 0: BAM to RPKM

CoNIFER calls CNVs based on the RPKM (reads per thousand bases per million reads sequenced) in each exome target region. If you do not already have RPKM files for each sample in your analysis, CoNIFER can generate them from BAM files.

**required input:**
  1. BAM file for each sample
  2. BED file containing the regions targeted by the exome capture kit used to sequence the WES. Make sure to use the right brand for the product, and that it is designed for the same reference genome your BAM file is aligned to. Many can be found at https://github.com/AstraZeneca-NGS/reference_data. As long as each BAM is processed with it's accompanying BED, samples can be ana....

`cd /home/bio/conifer_v0.2.2/ \
python conifer.py rpkm --probes $BED --input $BAM --output $RPKM_DIR/$SAMPLE_NAME".rpkm.txt" `



For the in order to run the `analyze` command on the RPKM files, they will all need to be stored in one directory, which cannot contain any other files.

### Step 1: analyze

python conifer.py analyze --output $ANALYZE_OUT"/CP_11F.analyze.hdf5" --write_svals CP_11F.sv.txt --plot_scree CP_11F.screeplot.png --write_sd CP_11F.sd_values.txt --svd 2
