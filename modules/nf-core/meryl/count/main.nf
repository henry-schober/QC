process MERYL_COUNT {
    tag "$meta.id"
    label 'process_meryl'

    conda "bioconda::meryl=1.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/meryl:1.3--h87f3376_1':
        'biocontainers/meryl:1.3--h87f3376_1' }"

    input:
    tuple val(meta), path(reads)

    output:
    path("*filtered.meryl")           , emit: meryl_db
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def kmernum = '21'
    """
    for READ in $reads; do
        meryl count \\
            threads=$task.cpus \\
            k=$kmernum \\
            $args \\
            $reads \\
            output kmer_db.meryl

        meryl greater-than 1 \\
            threads=$task.cpus \\
            k=$kmernum \\
            output kmer_db.filtered.meryl kmer_db.meryl
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        meryl: \$( meryl --version |& sed 's/meryl //' )
    END_VERSIONS
    """
}
