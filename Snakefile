rule peak_call_v3:
    input:
        "sorted_alignments/{name}_K4.bed"
        "sorted_alignments/{name}_In.bed"
    output:
        "v3/macs_output/{name}_peaks.broadPeak",
        temp("v3/macs_output/{name}_treat_pileup.bdg"),
	temp("v3/macs_output/{name}_control_lambda.bdg")
    shell:
        "macs2 -t {input[0]} -c {input[1]} --bdg -B -n {wildcards.name} --broad -o v3/peaks/"

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
        "{version}/peaks/{name}.broadPeak"
    output:
        "{version}/domains/{name}.bed"
    shell:
        "bedtools merge -d 5000 -i {input} > {output}"

rule size_hist:
    input:
        "domains/{name}.bed"
    output:
        "size_histograms/{name}.png",
        "logsize_histograms/{name}.png"
    shell:
        """
	python3 src/peak_histograms.py hist {input} {output[0]}
	python3 src/peak_histograms.py loghist {input} {output[1]}
	"""

rule copy_domains:
    input:
        "../broad_domains/results/{name}_domains.broadPeak"
    output:
        "domains/{name}.bed"
    shell:
        "mv {input} {output}"

rule copy_peaks:
    input:
        "../broad_domains/results/{name}_peaks.broadPeak"
    output:
        "peaks/{name}.bed"
    shell:
        "mv {input} {output}"

rule overlap_hist:
    input:
        "domains/{reference}.bed",
        "domains/{query}.bed",
    output:
        "overlap_histogram/{reference}_{query}.bed",
        "overlap_histogram/{reference}_{query}.png",
    shell:
        """
	chiptools overlap_fraction {input} > {output[0]}
	awk '{{if (($3-$2)>5000) {{print $4}}}}' {output[0]} | python3 src/ratio_histogram.py {output[1]}
	"""
