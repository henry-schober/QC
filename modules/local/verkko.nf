process VERKKO {
    tag "$meta.id"
    label 'process_high_memory', 'error_ignore'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/verkko:2.2--h45dadce_0' :
        'biocontainers/verkko:2.2--h45dadce_0' }"
        
    input:
    tuple val(meta), path(ont), path(pb)

    output:
    path("verkko*/*${meta.id}.fasta")        , emit: fasta
    path("verkko*/*.gfa")                    , emit: gfa

    script:
    def VERSION = '4.1.0'
    def prefix = task.ext.prefix ?: "verkko_${meta.id}"
    """
    verkko -d ${prefix} \
    --hifi $pb \
    --nano $ont \
    --slurm

    cd ${prefix}
    mv assembly.fasta ${prefix}.fasta
    mv assembly.homopolymer-compressed.gfa ${prefix}_homopolymer-compressed.gfa
    
    """
}
