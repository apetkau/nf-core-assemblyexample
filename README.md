# Example nf-core

This repository shows off some basic steps for creating a pipeline in Nextflow/nf-core. This is supplementary material for a presentation, which are listed below:

* Presentation [Petkau-Nextflow-2023-07-18.pdf](docs/Petkau-Nextflow-2023-07-18.pdf)
* Basic Nextflow pipeline: <https://github.com/apetkau/assembly-nf>
* Nf-core pipeline (this repository): <https://github.com/apetkau/nf-core-assemblyexample>

The files in this repository are part of the default nf-core template created initially using the command:

```bash
nf-core create --name assemblyexample --description "Example assembly pipeline" --plain --author "Aaron Petkau"
```

The following steps proceed through the process of adapting this template to execute the pipeline defined in <https://github.com/apetkau/assembly-nf/>.

The readme file created by `nf-core create` is [README.md.ORIG](README.md.ORIG).

# Setup

Prior to proceeding through this information, please make sure that `nextflow` and `nf-core` is installed. This can be installed with conda using:

```bash
conda create --name nextflow nextflow nf-core
conda activate nextflow
```

# Step 1. Running initial template pipeline

```bash
# Checkout necessary files
git checkout step1
cd example-execution

# Run pipeline
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38 --max_memory 8.GB --max_cpus 4
```

You can ignore `--max_memory` and `--max_cpus` if you wish to use the defaults (defined in `nextflow.config`). However, you may need to adjust these values depending on which machine you run the pipeline on.

# Step 2. Adding processess

To add additional processess to the workflow, we will first start with the three processess (FASTP, MEGAHIT, QUAST) from <https://github.com/apetkau/assembly-nf/blob/main/main.nf>. These will be broken up into separate files and added to `modules/local/`. That is, we will add the following files:

* [modules/local/fastp.nf](https://github.com/apetkau/nf-core-assemblyexample/blob/step2/modules/local/fastp.nf)
* [modules/local/megahit.nf](https://github.com/apetkau/nf-core-assemblyexample/blob/step2/modules/local/megahit.nf)
* [modules/local/quast.nf](https://github.com/apetkau/nf-core-assemblyexample/blob/step2/modules/local/quast.nf)

We will have to modify these files to replace any `val(sample_id)` with `val(meta)` and `${sample_id}` with `${meta.id}` due to the way nf-core structures data within a channel (for nf-core, `meta.id` is the sample identifier associated with fastq files).

Next, we modify the file `workflows/assemblyexample.nf` to import the above modules and add the steps to the workflow.

You can now run the updated workflow with the same run command:

```bash
cd example-execution
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

To view a summary of all changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step1...step2>.

# Step 3. Switching to nf-core modules

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

## 3.3. Make adjustments to max memory

You can make adjustments to many of the parameters of the pipeline in [nextflow.config](nextflow.config). In particular, we will have to reduce the default maximum memory by setting `max_memory = 32.GB` in this file. This is to prevent megahit from taking too much memory by default.

## 3.4. Remove existing modules

You can now remove the previously created `modules/local/{fastp,megahit,quast}.nf` files, as they are no longer needed.

## 3.5. Execute pipeline

You should now be able to execute the pipeline:

```bash
cd example-execution
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

To view a summary of all changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step2...step3>.

# Step 4. Adjusting parameters

Parameters can be adjusted in the [nextflow.config](nextflow.config) file. These can be set to defaults, or new parameters added/others removed.

To get rid of the need to use `--genome hg38`, an easy way is to set `genome = 'hg38'` as a default genome parameter.

However, to get rid of the parameter entirely, you can delete it from `nextflow.config` and comment-out the following lines <https://github.com/apetkau/nf-core-assemblyexample/blob/7a69b8c006610d3d07ad212c71bd807e63dde340/lib/WorkflowAssemblyexample.groovy#L18-L20>.

For this step, I have chosen to set "hg38" as the default, even if it's not used. To view a summary of changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step3...step4>.
