process MEGAHIT {
    publishDir params.outdir, mode:'copy', pattern: "*-contigs.fasta"

    conda "bioconda::megahit=1.2.9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/megahit:1.2.9--h43eeafb_4' :
        'quay.io/biocontainers/megahit:1.2.9--h43eeafb_4' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}-contigs.fasta"), emit: contigs

    script:
    """
    megahit -t $task.cpus -1 ${reads[0]} -2 ${reads[1]} -o megahit_out && cp megahit_out/final.contigs.fa ${meta.id}-contigs.fasta
    """
}
