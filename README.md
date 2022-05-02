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

### Step 1: Intersect with genesets

Here

python conifer.py analyze --output $ANALYZE_OUT"/CP_11F.analyze.hdf5" --write_svals CP_11F.sv.txt --plot_scree CP_11F.screeplot.png --write_sd CP_11F.sd_values.txt --svd 5

### Step: call


### Step 4: prepare file for Annovar

Optionally, remove ".rpkm" from each sampleID
`sed 's/.rpkm//g/' calls.txt > calls.names.txt`

The file needs to be reformatted for Annovar to accept it as input. These fields will not be used for our purposes, so they are filled with arbitrary values.

`cat calls.names.txt | awk -F'\t' 'OFS="\t"{print $1,$2,$3,$4}' > calls.names.index.txt
cat calls.names.index.txt | awk -F'\t' 'OFS="\t"{print $1,$2,$3,"0","-"}' | awk -F'\t' 'OFS="\t"{print $1,$2,$3,$4,"0","-"}' > calls.anno.in.bed
`

The results should look like this:

1       sampleID        chromosome      start   0       -
1       F309-003        chr1    196779161       0       -
1       F309-003        chr1    16757517        0       -
`

### Annovar annotates with refGene names
See 
`ANNOVAR=/storage1/fs1/jin810/Active/annovar_20191024/table_annovar.pl \
$ANNOVAR calls.anno.in.bed /storage1/fs1/jin810/Active/annovar_20191024/humandb/ --buildver hg38 -out ./anno.calls.bed -remove --protocol refGene --operation g -nastring .
`
### Remove extraneous fields from AnnovarR output

`cat anno.calls.bed.hg38_multianno.txt | awk -F'\t' 'OFS="\t"{print $1,$2,$3,$7}' > calls.annovar.txt '

### Recombine sample IDs with the other fields

`cat calls.names.txt | awk -F'\t' 'OFS="\t"{print $1}' > sampleID.txt
paste sampleID.txt calls_9F.txt calls.annovar.txt | awk -F'\t' 'OFS="\t"{print $0}' > calls.txt`

### 
