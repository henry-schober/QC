process PILON {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pilon:1.24--hdfd78af_0':
        'biocontainers/pilon:1.24--hdfd78af_0' }"

    input:
    tuple val(meta), path(fasta), path(bam)

    output:
    tuple val(meta), path("*.fasta") , emit: improved_assembly
    tuple val(meta), path("*.vcf")   , emit: vcf               , optional : true
    tuple val(meta), path("*.change"), emit: change_record     , optional : true
    tuple val(meta), path("*.bed")   , emit: tracks_bed        , optional : true
    tuple val(meta), path("*.wig")   , emit: tracks_wig        , optional : true
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pilon \\
        --genome $fasta \\
        --output ${meta.id} \\
        --threads $task.cpus \\
        $args \\
        --bam $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pilon: \$(echo \$(pilon --version) | sed 's/^.*version //; s/ .*\$//' )
    """
}
