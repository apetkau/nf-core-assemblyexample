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
