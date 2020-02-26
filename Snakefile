configfile: "config.json"
include: "mapping.sm"
include: "analysis.sm"
include: "commongenes.sm"
include: "gc.sm"
include: "trackhub.sm"


names = ["M", "GV", "IVF", "ICSI", "Day3G", "Day2G", "Zygote", "BlastG"]
pools = ["OocyteII", "Pre-ZGA", "Post-ZGA"]

rule human:
    input:
        expand("hg38/v3/domains/{name}.bed", name=pools),
        expand("hg38/v3/average_plots/{name}_{size}.png", name=pools, size=["sub5k", "5to20k", "super20k"]),
        expand("hg38/v3/tss_plots/{name}.png", name=pools)

rule structure_pools:
    input:
        "hg38/input_data/{name}_K4_pool.bed.gz",
        "hg38/input_data/{name}_In_pool.bed.gz"
    output:
        "hg38/pooled_K4/{name}.bed.gz",
        "hg38/pooled_inputs/{name}.bed.gz"
    shell:
        """
        mv {input[0]} {output[0]}
        mv {input[1]} {output[1]}
        """

#rule pool_stages:
#    input:
#        lambda wildcards: expand("hg38/pooled_K4/{name}.bed.gz", name=config["stage_pools"][wildcards.pool_name])
#    output:
#        "hg38/pooled_K4/{pool_name}.bed.gz"
#    shell:
#        "zcat {input} | gzip > {output}"

rule combine_tss_plot:
    input:
        expand("hg38/v3/tss_plots/{name}.npy", name=names),
    output:
        "hg38/v3/tss_plot.png",
    shell:
        "chiptools plot {input} {output}"

rule combine_average_plot:
    input:
        expand("{{species}}/{{version}}/average_plots/{name}_{{size}}.npy", name=names),
    output:
        "{species}/{version}/average_plot_{size}.png",
    shell:
        "chiptools plot {input} {output}"

rule peak_call_v3:
    input:
        "{species}/pooled_K4/{name}.bed.gz",
	"{species}/pooled_inputs/{name}.bed.gz" 
    output:
        "{species}/v3/macs_output/{name}_peaks.broadPeak",
        "{species}/v3/macs_output/{name}_treat_pileup.bdg",
	"{species}/v3/macs_output/{name}_control_lambda.bdg"
    shell:
        "macs2 callpeak -t {input[0]} -c {input[1]} --bdg -n {wildcards.name} --broad --outdir {wildcards.species}/v3/macs_output/"

rule get_qvalues:
    input:
        "{species}/{version}/macs_output/{name}_treat_pileup.bdg",
	"{species}/{version}/macs_output/{name}_control_lambda.bdg"
    output:
        "{species}/{version}/macs_output/{name}_qvalues.bdg"
    shell:
        "macs2 bdgcmp -t {input[0]} -c {input[1]} -m qpois -o {output}"

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
