process COMPLEASM {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::quast=5.2.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/compleasm:0.2.6--pyh7cba7a3_0 ' :
        'quay.io/biocontainers/compleasm:0.2.6--pyh7cba7a3_0 ' }"

    input:
    tuple val(meta), path(assembly)
    val lineage

    output:
    tuple val(meta), path('*.txt')  , emit: txt

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta}"

    """
    compleasm download $lineage
    compleasm run -t $task.cpus -l $lineage -a $assembly -o ${prefix} 
    """
}
