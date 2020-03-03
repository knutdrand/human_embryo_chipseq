single_cells_samples = """MI_01_Single_Day2G  MI-03_Single_Day2G  MI-05_Single_Day3G  MI-07_Single_Day2B_slow  MI-09_Single_Day3B_slow  MI-11_Single_Day3B_arrest  MI-13_Day2B
MI-02_Single_Day2G  MI-04_Single_Day3G  MI-06_Single_Day3G  MI-08_Single_Day2B_slow  MI-10_Single_Day3B_slow  MI-12_Single_Day3B_arrest  MI-14_BlastB""".split()



rule single_cell_all:
    input:
        expand("hg38/sc_coverage/{sample}.bw", sample=single_cells_samples+["MI-15_BlastB_Input", "MI-16_Day2B_Input"])

rule single_cell_pools:
    input:
        expand("hg38/v3/domains/{name}.bb", name=["MI-14_BlastB", "MI-13_Day2B"]),
        expand("hg38/v3/macs_output/{name}_{t}", name=["MI-14_BlastB", "MI-13_Day2B"],t=["treat_pileup.bw", "control_lambda.bw", "qvalues.bw", "peaks.bb"])

rule single_cell_coverage:
    input:
        "hg38/sc_K4/{sample}.bed.gz",
        "hg38/data/chrom.sizes.txt"
    output:
        "hg38/sc_coverage/{sample}.bdg"
    shell:
        "bedtools genomecov -bg -i {input[0]} -g {input[1]} > {output}"

rule sinlge_cell_coverage_input:
    input:
        "hg38/sc_inputs/{sample}.bed.gz",
        "hg38/data/chrom.sizes.txt"
    output:
        "hg38/sc_coverage/{sample}.bdg"
    shell:
        "bedtools genomecov -bg -i {input[0]} -g {input[1]} > {output}"

rule copy_pools:
    input:
        "hg38/sc_K4/MI-13_Day2B.bed.gz",
        "hg38/sc_K4/MI-14_BlastB.bed.gz"
    output:
        "hg38/pooled_K4/MI-13_Day2B.bed.gz",
        "hg38/pooled_K4/MI-14_BlastB.bed.gz"
    shell:
        """
        mv {input[0]} {output[0]}
        mv {input[1]} {output[1]}
        """

rule copy_inputs:
    input:
        "hg38/sc_inputs/MI-15_BlastB_Input.bed.gz",
        "hg38/sc_inputs/MI-16_Day2B_Input.bed.gz"
    output:
        "hg38/pooled_inputs/MI-14_BlastB.bed.gz",
        "hg38/pooled_inputs/MI-13_Day2B.bed.gz"
    shell:
        """
        mv {input[0]} {output[0]}
        mv {input[1]} {output[1]}
        """
