include: "mapping.sm"


rule peak_call_v3:
    input:
        "pooled_K4/{name}.bed.gz",
	"pooled_inputs/{name}.bed.gz" 
    output:
        "v3/macs_output/{name}_peaks.broadPeak",
        "v3/macs_output/{name}_treat_pileup.bdg",
	"v3/macs_output/{name}_control_lambda.bdg"
    shell:
        "macs2 callpeak -t {input[0]} -c {input[1]} --bdg -n {wildcards.name} --broad --outdir v3/macs_output"

rule create_pileup_track:
    input:
        "{version}/macs_output/{name}_treat_pileup.bdg"
    output:
        "{version}/macs_output/{name}_treat_pileup.bw"
    shell:
        "./bdg2bw {input} mm10.chrom.sizes"


rule create_peak_track:
    input:
        "{version}/macs_output/{name}_peaks.narrowPeak"
    output:
        "{version}/macs_output/{name_peaks.bb}"
    shell:
        "./narrowPeak2bb.sh {input} mm10.chrom.sizes"

rule merge_peaks:
    input:
        "{version}/macs_output/{name}_peaks.broadPeak"
    output:
        "{version}/domains/{name}.bed"
    shell:
        "bedtools merge -d 5000 -i {input} > {output}"

rule size_hist:
    input:
        "{version}/domains/{name}.bed"
    output:
        "{version}/size_histograms/{name}.png",
        "{version}/logsize_histograms/{name}.png"
    shell:
        """
	python3 src/peak_histograms.py hist {input} {output[0]}
	python3 src/peak_histograms.py loghist {input} {output[1]}
	"""

rule tss_plot:
    input:
        "data/human_genes.bed",
	"{version}/macs_output/{name}_treat_pileup.bdg"
    output:
        "{version}/tss_plots/{name}.npy",
        "{version}/tss_plots/{name}.png"
    shell:
        "cat {input[1]} | chiptools tssplot {input[0]} {output}"

rule average_plots:
    input:
        "{version}/domains/{name}.bed",
        "{version}/macs_output/{name}_treat_pileup.bdg"
    output:
        "{version}/average_plots/{name}.npy",
        "{version}/average_plots/{name}.png"
    shell:
        "cat {input[1]} | chiptools averageplot {input[0]} {output}"


rule overlap_hist:
    input:
        "{version}/domains/{reference}.bed",
        "{version}/domains/{query}.bed",
    output:
        "{version}/overlap_histogram/{reference}_{query}.bed",
        "{version}/overlap_histogram/{reference}_{query}.png",
    shell:
        """
	chiptools overlap_fraction {input} > {output[0]}
	awk '{{if (($3-$2)>5000) {{print $4}}}}' {output[0]} | python3 src/ratio_histogram.py {output[1]}
	"""
