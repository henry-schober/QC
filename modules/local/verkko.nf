process VERKKO {
    tag "$meta.id"
    label 'process_high_memory', 'error_ignore'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/verkko:2.2--h45dadce_0' :
        'biocontainers/verkko:2.2--h45dadce_0' }"
        
    input:
    tuple val(meta), path(pb)
    tuple val(meta), path(ont)
    path(ref)

    output:
    path("verkko*/*${meta.id}.fasta")        , emit: fasta
    tuple val(meta), path("verkko*/*.gfa")                    , emit: gfa

    script:
    def VERSION = '4.1.0'
    def prefix = task.ext.prefix ?: "verkko_${meta.id}"
if(ont){
    if(ref){
    """
    verkko -d ${prefix} \\
    --hifi $pb \\
    --nano $ont \\
    --ref $ref

    cd ${prefix}
    mv assembly.fasta ${prefix}.fasta
    mv assembly.homopolymer-compressed.gfa ${prefix}_homopolymer-compressed.gfa
    
    """
    } else {
        """
    verkko -d ${prefix} \\
    --hifi $pb \\
    --nano $ont

    cd ${prefix}
    mv assembly.fasta ${prefix}.fasta
    mv assembly.homopolymer-compressed.gfa ${prefix}_homopolymer-compressed.gfa
    
    """
    }
} else {
    if(ref){
    """
    verkko -d ${prefix} \\
    --hifi $pb \\
    --ref $ref

    cd ${prefix}
    mv assembly.fasta ${prefix}.fasta
    mv assembly.homopolymer-compressed.gfa ${prefix}_homopolymer-compressed.gfa
    
    """ } else {
    """
    verkko -d ${prefix} \\
    --hifi $pb 

    cd ${prefix}
    mv assembly.fasta ${prefix}.fasta
    mv assembly.homopolymer-compressed.gfa ${prefix}_homopolymer-compressed.gfa
    """
    }
}

    
}
