process QUAST {
    publishDir params.outdir, mode:'copy'

    conda "bioconda::quast=5.2.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/quast:5.2.0--py310pl5321h6cc9453_3' :
        'quay.io/biocontainers/quast:5.2.0--py310pl5321h6cc9453_3' }"

    input:
    tuple val(meta), path(contigs)

    output:
    path("${meta.id}-quast_results"), emit: quast_results

    script:
    """
    quast -t $task.cpus $contigs && mv quast_results ${meta.id}-quast_results
    """
}
