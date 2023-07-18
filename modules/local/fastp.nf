process FASTP {
    publishDir params.outdir, mode:'copy', pattern: "*-fastp.html"

    input:
    tuple val(meta), path(reads)

    conda "bioconda::fastp=0.23.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastp:0.23.4--hadf994f_1' :
        'quay.io/biocontainers/fastp:0.23.4--hadf994f_1' }"

    output:
    tuple val(meta), path("cleaned_{1,2}.fastq"), emit: reads
    path("*-fastp.html"), emit: report_html

    script:
    """
    fastp --detect_adapter_for_pe --in1 ${reads[0]} --in2 ${reads[1]} --html ${meta.id}-fastp.html --out1 cleaned_1.fastq --out2 cleaned_2.fastq
    """
}
