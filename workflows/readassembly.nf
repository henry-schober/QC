/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowGenomeassembly.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.centrifuge_db ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) }

//if (params.summary_txt) {ch_sequencing_summary = file(params.sequencing_summary) } else { ch_sequencing_summary = []}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
//ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
//ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
//ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// MODULES
include { SAMTOOLS_INDEX } from '../../modules/nf-core/samtools/index/main' 
include { SAMTOOLS_SORT } from '../../modules/nf-core/samtools/sort'
include { MINIMAP2_INDEX } from '../../modules/nf-core/minimap2/index/main' 
include { MINIMAP2_ALIGN } from '../../modules/nf-core/minimap2/align/main' 
include { WINNOWMAP } from '../../modules/local/winnowmap'
include { BWAMEM2_INDEX } from '../../modules/nf-core/bwamem2/index/main' 
include { BWAMEM2_MEM } from '../../modules/nf-core/bwamem2/mem/main'

// SUBWORKFLOWS
include { INPUT_CHECK } from '../subworkflows/assembly_qc/01_input_check'
include { ASSEMBLY_QC } from '../subworkflows/assembly_qc/02_assembly_qc'

include { INPUT_CHECK } from '../subworkflows/long_qc/01_input_check'
include { LONG_QC } from '../subworkflows/long_qc/02_long_qc'

include { INPUT_CHECK } from '../subworkflows/short_qc/01_input_check'
include { SHORT_QC } from 'subworkflows/short_qc/02_short_qc'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow QUALITYCHECK {

    ch_versions = Channel.empty()

    ch_data = INPUT_CHECK ( ch_input )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    def (ch_ont, ch_pb, ch_ill) = INPUT_CHECK.out[0].branch {
        ont: it[0].read_type == 'ont'
        pb:  it[0].read_type == 'pb'
        ill: it[0].read_type == 'ill'
    }

    if (params.existing_assembly == true) {
        ch_data = INPUT_CHECK ( ch_assembly ) 
        ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
        ASSEMBLY_QC (ch_data)
        ch_versions = ch_versions.mix(ASSEMBLY_QC.out.versions)
        ch_busco = ASSEMBLY_QC.out.ch_busco
        ch_quast = ASSEMBLY_QC.out.ch_quast
        ch_merqury = ASSEMBLY_QC.out.ch_merqury
        ch_busco_full_table = ASSEMBLY_QC.out.ch_busco_full_table
    } else {
        ch_busco = Channel.empty()
        ch_quast = Channel.empty()
        ch_merqury = Channel.empty()
        ch_busco_full_table = Channel.empty()
    } }
    //
    // MODULE: MultiQC
    //
   //workflow_summary    = WorkflowGenomeassembly.paramsSummaryMultiqc(workflow, summary_params)
   //ch_workflow_summary = Channel.value(workflow_summary)

    //methods_description    = WorkflowGenomeassembly.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    //ch_methods_description = Channel.value(methods_description)

    //ch_multiqc_files = Channel.empty()
    //ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    //ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    //ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    //ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

    //MULTIQC (
    //    ch_multiqc_files.collect(),
    //    ch_multiqc_config.toList(),
    //    ch_multiqc_custom_config.toList(),
    //    ch_multiqc_logo.toList()
   //)
    //multiqc_report = MULTIQC.out.report.toList()


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
       NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
   }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
