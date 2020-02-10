include: "mapping.sm"
include: "commongenes.sm"


rule peak_call_v3:
    input:
        "{species}/pooled_K4/{name}.bed.gz",
	"{species}/pooled_inputs/{name}.bed.gz" 
    output:
        "{species}/v3/macs_output/{name}_peaks.broadPeak",
        "{species}/v3/macs_output/{name}_treat_pileup.bdg",
	"{species}/v3/macs_output/{name}_control_lambda.bdg"
    shell:
        "macs2 callpeak -t {input[0]} -c {input[1]} --bdg -n {wildcards.name} --broad --outdir v3/macs_output"

rule create_pileup_track:
    input:
        "{species}/{version}/macs_output/{name}_treat_pileup.bdg",
        "{species}.chrom.sizes"
    output:
        "{species}/{version}/macs_output/{name}_treat_pileup.bw"
    shell:
        "./bdg2bw {input}"


rule create_peak_track:
    input:
        "{species}/{version}/macs_output/{name}_peaks.narrowPeak",
        "{species}.chrom.sizes"
    output:
        "{species}/{version}/macs_output/{name_peaks.bb}"
    shell:
        "./narrowPeak2bb.sh {input}"

rule merge_peaks:
    input:
        "{species}/{version}/macs_output/{name}_peaks.broadPeak"
    output:
        "{species}/{version}/domains/{name}.bed"
    shell:
        "bedtools merge -d 5000 -i {input} > {output}"

rule size_hist:
    input:
        "{species}/{version}/domains/{name}.bed"
    output:
        "{species}/{version}/size_histograms/{name}.png",
        "{species}/{version}/logsize_histograms/{name}.png"
    shell:
        """
	python3 src/peak_histograms.py hist {input} {output[0]}
	python3 src/peak_histograms.py loghist {input} {output[1]}
	"""

rule tss_plot:
    input:
        "data/{species}_genes.bed",
	"{species}/{version}/macs_output/{name}_treat_pileup.bdg"
    output:
        "{species}/{version}/tss_plots/{name}.npy",
        "{species}/{version}/tss_plots/{name}.png"
    shell:
        "cat {input[1]} | chiptools tssplot {input[0]} {output}"

rule average_plots:
    input:
        "{species}/{version}/domains/{name}.bed",
        "{species}/{version}/macs_output/{name}_treat_pileup.bdg"
    output:
        "{species}/{version}/average_plots/{name}.npy",
        "{species}/{version}/average_plots/{name}.png"
    shell:
        "cat {input[1]} | chiptools averageplot {input[0]} {output}"


rule overlap_hist:
    input:
        "{species}/{version}/domains/{reference}.bed",
        "{species}/{version}/domains/{query}.bed",
    output:
        "{species}/{version}/overlap_histogram/{reference}_{query}.bed",
        "{species}/{version}/overlap_histogram/{reference}_{query}.png",
    shell:
        """
	chiptools overlap_fraction {input} > {output[0]}
	awk '{{if (($3-$2)>5000) {{print $4}}}}' {output[0]} | python3 src/ratio_histogram.py {output[1]}
	"""
