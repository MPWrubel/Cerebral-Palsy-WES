# Cerebral-Palsy-WES
Max Wrubel
Jin Group, Washington University School of Medicine

## Overview
This README documents the workflow for calling and visualizing CNVs from WES with CoNIFER [CoNIFER](https://github.com/nkrumm/CoNIFER) on the RIS cluster at WUSM. For further information on CoNIFER, see their [documentation](http://conifer.sourceforge.net/).
## Setup
The [scripts for running the CoNIFER algorithm](https://github.com/nkrumm/CoNIFER) require Python 2.7 with NumPy, matplotlib, PyTables, and pysam modules installed. when working interactively on the RIS cluster, the CoNIFER container can be run on top of an Anaconda for Python 2.7 like so:

`bsub -G compute-jin810 -Is -q general-interactive -a 'docker(continuumio/anaconda)' /bin/bash` 
`bsub -G compute-jin810 -Is -q general-interactive -a 'docker(molecular/conifer)' /bin/bash`

Note: The CoNIFER docker container writes the script at `/home/bio/conifer_v0.2.2/conifer.py).

## Analysis
### Step 0: BAM to RPKM

CoNIFER calls CNVs based on the RPKM, a measure of exome read depth adjusted for sequence length. If you do not already have RPKM files for each sample in your analysis, CoNIFER can generate them from BAM files. This is the most computationally demanding step in the analysis, so it is best to use the [included script] to produce bsub jobs for each sample.

**required input:**
  1. BAM file for each sample
  2. BED file containing the regions targeted by the exome capture kit used to sequence the WES. Make sure to use the right brand and product version, and that it is designed for the same reference genome your BAM file is aligned to. Many can be found at [AstraZeneca's reference data repository](https://github.com/AstraZeneca-NGS/reference_data). 


python conifer.py rpkm --probes $BED --input $BAM --output $RPKM_DIR/$SAMPLE_NAME".rpkm.txt" `

For the in order to run the `analyze` command on the RPKM files, they will all need to be stored in one directory, which cannot contain any other files.

### Step 1: Analyze RPKM values and call CNVs

`python conifer.py analyze --output analyze.hdf5 --write_svals sv.txt --plot_scree screeplot.png --write_sd sd_values.txt --svd 5`

The `analyze` tool may be run interactively because it runs quickly and usually need to be run multiple times so the user can adjust the SVD parameter. See the [tutorial](http://conifer.sourceforge.net/tutorial.html) in the documentation for details.

`python conifer.py call --input analyze.hdf5 --output calls.txt --threshold 1.5`

Examine calls.txt. If a few of the samples in your cohort have many times more CNV calls than the rest, the `--svd` option in `analyze` was probably not set high enough. The threshold of `call` may be adjusted from the default +/-1.5 SVD-ZRPKM to fine-tune the sensitivity, but this will not address biases. 

### Step 4: Annotate with refGene symbols using Annovar
The Annovar script table_annovar.pl requires a tab-delimited BED file with no column names and two additional fields. These are not used in this analysis, so the can be populated with arbitrary characters "0" and "-" respectively.

Optionally, remove ".rpkm" from each sampleID
`
sed -i 's/.rpkm//g/' calls.txt \
cat calls txt | sed '1d' | awk -F'\t' 'OFS="\t"{print $2,$3,$4,"0","-"}' | > calls.annovar.in.bed
`


`$ANNOVAR=/storage1/fs1/jin810/Active/annovar_20191024/table_annovar.pl calls.annovar.in.bed \
$DB=/storage1/fs1/jin810/Active/annovar_20191024/humandb/ \

$ANNOVAR calls.annovar.in.bed $DB --buildver hg38 -out ./calls -remove --protocol refGene --operation g -nastring .`
For this example, Annovar will output a file named calls.hg38_multianno.txt. Most fields in this file are based on the arbittrary "0" and "-" characters entered earlier and do not contain meaningful information. The only new and information is field 7 containing the refGene symbols.:

Make sure that all of the intervals were successfully annotated by checking that the `.invalid_input` file created while running Annovar is empty. As long as this is the case, the refGene field of the Annovar table can simply be pasted to the initial CoNIFER ouput file like so:

`cut -f 7 calls.hg38_multianno.txt > refGene.txt
paste calls.txt refGene.tt | awk -F'\t' 'OFS="\t"{print $0}' > calls.refGene.txt`

## Visualize CNV calls with CoNIFER

`
python conifer.py plotcalls \
  	--input analysis.hdf5 
  	--calls calls.txt 
  	--outputdir ./call_imgs/
`
