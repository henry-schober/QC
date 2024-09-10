process VERKKO {
    tag "$meta.id"
    label 'process_high_memory', 'error_ignore'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/verkko:2.2--h45dadce_0' :
        'biocontainers/verkko:2.2--h45dadce_0' }"
        
    input:
    tuple val(meta), path(ont), path(pb)

    output:
    path("hybrid_masurca*")                , emit: fasta
    path ("versions.yml")                , emit: versions

    script:
    def VERSION = '4.1.0'
    def prefix = task.ext.prefix ?: "verkko_${meta.id}"
    """
    verkko -d ${prefix} \
    --hifi $pb \
    --nano $ont \
    --slurm

    mv assembly.fasta ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MaSuRCA: $VERSION
    END_VERSIONS
    """
}
