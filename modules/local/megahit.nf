process MEGAHIT {
    publishDir params.outdir, mode:'copy', pattern: "*-contigs.fasta"

    conda "bioconda::megahit=1.2.9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/megahit:1.2.9--h43eeafb_4' :
        'quay.io/biocontainers/megahit:1.2.9--h43eeafb_4' }"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}-contigs.fasta"), emit: contigs

    script:
    """
    megahit -t $task.cpus -1 ${reads[0]} -2 ${reads[1]} -o megahit_out && cp megahit_out/final.contigs.fa ${sample_id}-contigs.fasta
    """
}
