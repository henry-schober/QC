process KMER_FREQ {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ragtag:2.1.0--pyhb7b1952_0' :
        'quay.io/biocontainers/ragtag:2.1.0--pyhb7b1952_0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.scaffold.fasta")              , emit: scaffolded_assembly
    tuple val(meta), path("*.stats")                 , emit: summary
    path  "versions.yml"                           , emit: versions

    script:
    def VERSION = '2.1.0'

    """
    ragtag.py scaffold {fasta} -f 1000 -o {outdir}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RagTag: $VERSION
    END_VERSIONS
    """
}