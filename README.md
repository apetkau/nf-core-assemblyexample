# Example nf-core

This repository shows off some basic steps for creating a pipeline in Nextflow/nf-core. This is supplementary material for a presentation, which are listed below:

- Presentation [PetkauNextflow-2023-07-18.pdf](docs/PetkauNextflow-2023-07-18.pdf)
- Basic Nextflow pipeline: <https://github.com/apetkau/assembly-nf>
- Nf-core pipeline (this repository): <https://github.com/apetkau/nf-core-assemblyexample>

Additional information about creating a pipeline can also be found in the nf-core documentation: <https://nf-co.re/docs/contributing/adding_pipelines>.

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

You can ignore `--max_memory` and `--max_cpus` if you wish to use the defaults (defined in `nextflow.config`). However, you may need to adjust these values depending on which machine you run the pipeline on. These act to set a cap on the maximum resources used by each process (see <https://nf-co.re/docs/usage/configuration#max-resources>).

# Step 2. Adding processess

To add additional processess to the workflow, we will first start with the three processess (FASTP, MEGAHIT, QUAST) from <https://github.com/apetkau/assembly-nf/blob/main/main.nf>. These will be broken up into separate files and added to `modules/local/`. That is, we will add the following files:

- [modules/local/fastp.nf](https://github.com/apetkau/nf-core-assemblyexample/blob/step2/modules/local/fastp.nf)
- [modules/local/megahit.nf](https://github.com/apetkau/nf-core-assemblyexample/blob/step2/modules/local/megahit.nf)
- [modules/local/quast.nf](https://github.com/apetkau/nf-core-assemblyexample/blob/step2/modules/local/quast.nf)

We will have to modify these files to replace any `val(sample_id)` with `val(meta)` and `${sample_id}` with `${meta.id}` due to the way nf-core structures data within a channel (for nf-core, `meta.id` is the sample identifier associated with fastq files).

Next, we modify the file `workflows/assemblyexample.nf` to import the above modules and add the steps to the workflow.

You can now run the updated workflow with the same run command:

```bash
cd example-execution
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

To view a summary of all changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step1...step2> (you can ignore changes in `README.md`).

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

You can make adjustments to many of the parameters of the pipeline in [nextflow.config](nextflow.config). These can be overridden by command-line arguments (such as `--max_memory` as described above), but it may be useful to adjust the default values here. In particular, the `megahit` tool is set to use a very large amount of memory by default. You can decrease the default maximum memory by setting `max_memory = 8.GB` in this file (adjusting the value for your particular use case).

## 3.4. Remove existing modules

You can now remove the previously created `modules/local/{fastp,megahit,quast}.nf` files, as they are no longer needed.

## 3.5. Execute pipeline

You should now be able to execute the pipeline:

```bash
cd example-execution
nextflow run ../ --input samplesheet.csv --outdir results -profile singularity --genome hg38
```

To view a summary of all changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step2...step3> (you can ignore changes in `README.md`).

# Step 4. Adjusting parameters

Parameters can be adjusted in the [nextflow.config](nextflow.config) file. These can be set to defaults, or new parameters added/others removed.

To get rid of the need to use `--genome hg38`, an easy way is to set `genome = 'hg38'` as a default genome parameter.

However, to get rid of the parameter entirely, you can delete it from `nextflow.config` and comment-out the following lines <https://github.com/apetkau/nf-core-assemblyexample/blob/7a69b8c006610d3d07ad212c71bd807e63dde340/lib/WorkflowAssemblyexample.groovy#L18-L20>.

For this step, I have chosen to set "hg38" as the default, even if it's not used. To view a summary of changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step3...step4> (you can ignore changes in `README.md`).

# Step 5. Tests and linting

## 5.1. Linting

nf-core provides the capability to run a linter to check for any possible issues using the command `nf-core lint` (see the [nf-core linting documentation](https://nf-co.re/tools#linting-a-workflow) for more details). Running this now gives:

**Command**

```bash
nf-core lint
```

**Output**

```
...
│ pipeline_todos: TOD string in nextflow.config: Specify your pipeline's command line flags                                                                       │
│ pipeline_todos: TODO string in test_full.config: Specify the paths to your full test data ( on nf-core/test-datasets or directly in repositories, e.g. SRA)      │
│ pipeline_todos: TODO string in test_full.config: Give any required params for the test so that command line flags are not needed
...

╭───────────────────────╮
│ LINT RESULTS SUMMARY  │
├───────────────────────┤
│ [✔] 193 Tests Passed  │
│ [?]   0 Tests Ignored │
│ [!]  25 Test Warnings │
│ [✗]   0 Tests Failed  │
╰───────────────────────╯
```

That is, there are no issues with this pipeline, though there are a number of warnings, which all have to do with addressing **TODO** statements. We will focus on addressing the Testing **TODO**s.

## 5.2. Testing

nf-core also provides profiles that are intended to be used to run the pipeline with test data (see the [nf-core pipeline testing tutorial](https://nf-co.re/docs/contributing/tutorials/creating_with_nf_core#testing-the-new-pipeline) for details). To do this, we can run the below command:

**Command**

```bash
nextflow run . -profile docker,test --outdir results
```

**Output**

```
executor >  local (15)
[7f/08ba89] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:INPUT_CHECK:SAMPLESHEET_CHECK (samplesheet_test_illumina_amplicon.csv) [100%] 1 of 1 ✔
[3c/da189b] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:FASTQC (SAMPLE1_PE_T1)                                                 [100%] 4 of 4 ✔
[c2/3aea54] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:FASTP (SAMPLE1_PE_T1)                                                  [100%] 4 of 4 ✔
[0b/4a2548] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:MEGAHIT (SAMPLE1_PE_T1)                                                [100%] 4 of 4 ✔
[-        ] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:QUAST                                                                  -
[47/11da11] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:CUSTOM_DUMPSOFTWAREVERSIONS (1)                                        [100%] 1 of 1 ✔
[21/266316] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:MULTIQC                                                                [100%] 1 of 1 ✔
-[nf-core/assemblyexample] Pipeline completed successfully-
Completed at: 15-Aug-2023 15:54:16
Duration    : 1m 47s
CPU hours   : 0.1
Succeeded   : 15
```

This runs the pipeline with a minimal dataset and configured parameters as defined in <https://github.com/apetkau/nf-core-assemblyexample/blob/step5/conf/test.config>.

```
params {
    config_profile_name        = 'Test profile'
    config_profile_description = 'Minimal test dataset to check pipeline function'

    // Limit resources so that this can run on GitHub Actions
    max_cpus   = 2
    max_memory = '6.GB'
    max_time   = '6.h'

    // Input data
    // TODO nf-core: Specify the paths to your test data on nf-core/test-datasets
    // TODO nf-core: Give any required params for the test so that command line flags are not needed
    input  = 'https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/samplesheet/samplesheet_test_illumina_amplicon.csv'

    // Genome references
    genome = 'R64-1-1'
}
```

You may need to update this if the pipeline tests fail to run.

There are two types of testing profiles: (1) [test](https://github.com/apetkau/nf-core-assemblyexample/blob/step5/conf/test.config) (for small-scale testing) and (2) [test_full](https://github.com/apetkau/nf-core-assemblyexample/blob/step5/conf/test_full.config) (for full-sized dataset testing).

Let's try to run `test_full`.

**Command**

```bash
nextflow run . -profile docker,test_full --outdir results
```

**Output**

```
[11/56325e] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:INPUT_CHECK:SAMPLESHEET_CHECK (samplesheet_full_illumina_amplicon.csv) [100%] 1 of 1 ✔
[b5/a1ea7d] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:FASTQC (sample2_T1)                                                    [100%] 2 of 2 ✔
[3a/57842f] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:FASTP (sample2_T1)                                                     [100%] 2 of 2 ✔
[fd/af2df1] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:MEGAHIT (sample2_T1)                                                   [100%] 2 of 2 ✔
[-        ] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:QUAST                                                                  -
[9b/b078b7] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:CUSTOM_DUMPSOFTWAREVERSIONS (1)                                        [100%] 1 of 1 ✔
[be/20ded5] process > NFCORE_ASSEMBLYEXAMPLE:ASSEMBLYEXAMPLE:MULTIQC                                                                [100%] 1 of 1 ✔
-[nf-core/assemblyexample] Pipeline completed successfully-
Completed at: 15-Aug-2023 16:19:25
Duration    : 16m 46s
CPU hours   : 1.0
Succeeded   : 9
```

This succeeded as well, but was on larger files (compare running time of ~2 min for `test` to ~17 min for `test_full`.

Since both the `test` and `test_full` profiles succeded with the defaults provided by nf-core, the only changes needed are to remove the **TODO** statements in the respective files: [test](https://github.com/apetkau/nf-core-assemblyexample/blob/step4/conf/test.config#L23-L24) and [test_full](https://github.com/apetkau/nf-core-assemblyexample/blob/step4/conf/test_full.config#L18-L19).

To view a summary of changes, please see <https://github.com/apetkau/nf-core-assemblyexample/compare/step4...step5> (you can ignore changes in `README.md`).

# Step 6: CI with GitHub Actions

Continous Integration (CI) is the process of frequently commiting/merging code into a shared repository and automating the execution of tests to provide rapid feedback to catch any possible issues to new code (see <https://www.atlassian.com/continuous-delivery/continuous-integration>). [GitHub Actions](https://docs.github.com/en/actions) is one way to exectue continues integration suites that is provided by GitHub. nf-core has a comprehensive set of GitHub Actions workflows to run **linting** and **pipeline tests** on code (see [nf-core testing](https://nf-co.re/docs/contributing/contributing_to_pipelines#testing) for details).

In this step, we will make the necessary changes in order to get the nf-core CI workflows configured on GitHub.

## 6.1. Create branch and pull-request

The first step is to create a separate branch for these code changes and a pull-request. This can be done with:

```bash
git checkout -b step/ci-tests
# Make changes to some files here and commit
git push origin step/ci-tests
```

In GitHub, we will create a [step 6 pull request](https://github.com/apetkau/nf-core-assemblyexample/pull/3) with these changes. This will trigger the existing configured GitHub Actions by nf-core. This PR should be to the branch `dev`.

## 6.2. Fix existing tests

On GitHub Actions CI tests for the current code, there is one faillure for the [`nf-core linting / Prettier` check](https://github.com/apetkau/nf-core-assemblyexample/actions/runs/5879510871), mainly:

```
Run prettier --check ${GITHUB_WORKSPACE}
Checking formatting...
[warn] modules.json
[warn] README.md
[warn] Code style issues found in 2 files. Run Prettier to fix.
Error: Process completed with exit code 1.
```

The command [prettier](https://prettier.io/) is used to check for consistent formatting of code, and is described in the [nf-core code formatting](https://nf-co.re/docs/contributing/code_formatting) documentation.

The above error messages indicate some files are failing the `prettier` check. To run `prettier` manually to reproduce the CI test issues, we can use the following commands:

**Command**

```bash
conda install prettier
prettier --check .
```

**Output**

```
Checking formatting...
[warn] modules.json
[warn] README.md
[warn] Code style issues found in 2 files. Run Prettier to fix.
```

To make the necessary changes, the following can be run:

```bash
prettier -w .
```

Now, you can commit any of the changed files and re-push to try the CI tests again. All tests should pass.

![nf-core-ci-tests-pass.png][]

These tests are divided up into two categories (see [nf-core testing docs](https://nf-co.re/docs/contributing/contributing_to_pipelines#testing) for details).

- **Lint tests**: These tests verify that code confirms to nf-core specs and includes running `nf-core lint` as well as `prettier` (code formatting check) as well as **EditorConfig checker** and **Python Black** (other code formatting checks).
- **Pipeline tests**: These tests run the pipeline by running the command `nextflow run . -profile test,docker --outdir ./results` (i.e., running the pipeline using the `test` profile and data configured in [Step 5](#step-5-tests-and-linting)).

Configuration for the GitHub Actions workflows can be found in the [.github/workflows](https://github.com/apetkau/nf-core-assemblyexample/tree/step6/.github/workflows) directory.

## 6.3. Fix up CI-related TODOs/other small fixes

We will also fix up and CI-related TODOs. These can be reviewed by running `nf-core lint`, which should show:

```
│ pipeline_todos: TODO string in awsfulltest.yml: You can customise AWS full pipeline tests as required                                                            │
│ pipeline_todos: TODO string in ci.yml: You can customise CI pipeline run tests as required
```

### 6.3.1. AWS testing

The first **TODO** relates to [.github/workflows/awsfulltest.yml](https://github.com/apetkau/nf-core-assemblyexample/blob/step5/.github/workflows/awsfulltest.yml#L18), which runs a test on the full dataset (the `test_full` profile) when the pipeline is released. We are not going to use AWS right now, so this TODO can be ignored.

### 6.3.2. ci.yml customization

This **TODO** is related to [.github/workflows/ci.yml](https://github.com/apetkau/nf-core-assemblyexample/blob/step5/.github/workflows/ci.yml#L39), and describes how the test command can be modified here. We can remove this **TODO** statement as we do not need to modify the command.

### 6.3.3. Switch master to main

In some locations of GitHub Actions configuration files, the branch `master` is used, when it should be `main`, and thus preventing the Action from running. We can make this change.

- [.github/ci/branch.yml](https://github.com/apetkau/nf-core-assemblyexample/blob/step5/.github/workflows/branch.yml#L6): This action makes sure PRs are only submitted to `dev`. We can change `master` to `main` in this file so that it will be properly triggered.

All these changes can be viewed in the following commit: <https://github.com/apetkau/nf-core-assemblyexample/commit/eeb0186126e7337256a99445984098f1a4e22e41>.

## 6.4. Finish PR

Finally, the necessary changes have been made. You can push to the branch `step/ci-tests` and verify the tests pass.

The passing tests and code changes can all be reviewed in the [step 6 pull-request](https://github.com/apetkau/nf-core-assemblyexample/pull/3). You can also review the code changes needed at <https://github.com/apetkau/nf-core-assemblyexample/compare/step5...step6>.

[nf-core-ci-tests-pass.png]: docs/images/nf-core-ci-tests-pass.png
