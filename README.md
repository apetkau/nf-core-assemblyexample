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
cd example-execution
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

# 3. Switching to nf-core modules

Nf-core provides a large collection of modules that define processess for bioinformatics tools (fastp, megahit, quast). To switch to these community-maintained modules, you can do the following.

## 3.1. Install nf-core modules

To install the nf-core modules, make sure you are in the root of the nextflow pipeline directory (this directory <https://github.com/apetkau/nf-core-assemblyexample>) and run the following:

```bash
nf-core modules install fastp
nf-core modules install megahit
nf-core modules install quast
```

This will install the modules in `modules/nf-core` and create a file `modules.json` to track versions. You can commit these files to git.

## 3.2. Add modules to workflow

To add modules to the workflow (`workflows/assemblyexample.nf`), for each module add the following line to import the module:

```
include { FASTP                       } from '../modules/nf-core/fastp/main'
```

Next, modify the execution of each imported process if there were different parameters or input/output files.

## 3.3. Make adjustments to configuration

You can make adjustments to the configuration of individual processess in the `conf/modules.config` file. For example, I had to add the following section to reduce the default memory usage of MEGAHIT:

*In [conf/modules.config][conf/modules.config]*

```
// Reducing memory assigned to megahit
withName:MEGAHIT {
    memory = { 32.GB * task.attempt }
}
```

## 3.4. Remove existing modules

You can now remove the previously created `modules/local/{fastp,megahit,quast}.nf` files, as they are no longer needed.

## 3.5. Execute pipeline

You should now be able to execute the pipeline:

```bash
cd example-execution
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

