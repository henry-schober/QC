process NANOPLOT {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::nanoplot=1.41.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoplot:1.41.0--pyhdfd78af_0' :
        'biocontainers/nanoplot:1.41.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(ontfile)

    output:
    tuple val(meta), path("*.html")                , emit: html
    tuple val(meta), path("*.png") , optional: true, emit: png
    tuple val(meta), path("*.txt")                 , emit: txt
    tuple val(meta), path("*.log")                 , emit: log
    path  "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.read_type}_${meta.id}"
    def input_file = ("$ontfile".endsWith(".fastq")||"$ontfile".endsWith(".fastq.gz")||"$ontfile".endsWith(".fq.gz")||"$ontfile".endsWith(".fq")) ? "--fastq ${ontfile}" :
        ("$ontfile".endsWith(".txt")) ? "--summary ${ontfile}" : ''
    """
    NanoPlot \\
        $args \\
        -p $prefix \\
        -t $task.cpus \\
        --fastq ${ontfile}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoplot: \$(echo \$(NanoPlot --version 2>&1) | sed 's/^.*NanoPlot //; s/ .*\$//')
    END_VERSIONS

    """
}
