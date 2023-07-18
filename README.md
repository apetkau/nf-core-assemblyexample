# Example nf-core template

This is an example nf-core template created initially using the command:

```bash
nf-core create --name assemblyexample --description "Example assembly pipeline" --plain --author "Aaron Petkau"
```

The following steps proceed through the process of adapting this template to execute the pipeline defined in <https://github.com/apetkau/assembly-nf/>.

The readme file created by `nf-core create` is [README.md.ORIG](README.md.ORIG).

# 0. Setup

Prior to proceeding through this information, please make sure that `nextflow` and `nf-core` is installed. This can be installed with conda using:

```bash
conda create --name nextflow nextflow nf-core
conda activate nextflow
```

# 1. Running initial template pipeline

```bash
# Checkout necessary files
git checkout step1
cd example-execution

# Run pipeline
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

# 2. Adding processess

To add additional processess to the workflow, we will first start with the three processess (FASTP, MEGAHIT, QUAST) from <https://github.com/apetkau/assembly-nf/blob/main/main.nf>. These will be broken up into separate files and added to `modules/local/`. That is, we will add the following files:

* [modules/local/fastp.nf][]
* [modules/local/megahit.nf][]
* [modules/local/quast.nf][]

We will have to modify these files to replace any `val(sample_id)` with `val(meta)` and `${sample_id}` with `${meta.id}` due to the way nf-core structures data within a channel (for nf-core, `meta.id` is the sample identifier associated with fastq files).

Next, we modify the file `workflows/assemblyexample.nf` to import the above modules and add the steps to the workflow.

You can now run the updated workflow with the same run command:

```bash
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```
