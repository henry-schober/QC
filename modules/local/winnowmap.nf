
process MINIMAP2_ALIGN {
    tag "$meta"
    label 'process_medium'
    time '36h'
    // Note: the versions here need to match the versions used in the mulled container below and minimap2/index
    conda "bioconda::minimap2=2.24 bioconda::samtools=1.14"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/winnowmap:2.03--h5b5514e_1' :
        'quay.io/biocontainers/winnowmap:2.03--h5b5514e_1' }"

    input:
    tuple val(meta), path(reference), path(reads)
    tuple val(meta), path(repetitive_txt)

    output:
    tuple val(meta), path("*.bam"), emit: bam

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    winnowmap \\
      -W $repetitive_txt -ax $read_type $reference $reads > ${prefix}.sam
        $args \\
        -t $task.cpus \\
        "${reference ?: reads}" \\
        "$reads" \\

    samtools view -bS ${prefix}.sam > ${prefix}.bam
    """
}
