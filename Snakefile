include: "mapping.sm"
include: "commongenes.sm"

names = ["M", "GV", "IVF", "ICSI", "Day3G", "Day2G", "Zygote", "BlastG"]
track_hub = "../../var/www/html/trackhub_knut/"
track_types = ["domains.bb", "peaks.bb", "treat_pileup.bw", "control_lambda.bw", "qvalues.bw"]

rule human:
    input:
        expand("hg38/v3/domains/{name}.bed", name=names),
        expand("hg38/v3/average_plots/{name}.png", name=names),
        expand("hg38/v3/tss_plots/{name}.png", name=names)

rule combine_tss_plot:
    input:
        expand("hg38/v3/tss_plots/{name}.npy", name=names),
    output:
        "hg38/v3/tss_plot.png",
    shell:
        "chiptools plot {input} {output}"

rule combine_average_plot:
    input:
        expand("hg38/v3/average_plots/{name}_{{size}}.npy", name=names),
    output:
        "hg38/v3/average_plot_{size}.png",
    shell:
        "chiptools plot {input} {output}"

rule trackhub:
    input:
        expand(track_hub+"hg38/v3_{name}_{track_type}", name=names, track_type=track_types)
    output:
        track_hub + "hg38/trackDb.txt"
    shell:
        "chiptools trackdb " + " ".join(names) + "> {output}"
        
rule copy_human_fragments:
    input:
        "../broad_domains/data/{name}_pool.bed.gz",
        "../broad_domains/data/{name}_In.bed.gz",        
    output:
        "hg38/pooled_K4/{name}.bed.gz",
        "hg38/pooled_inputs/{name}.bed.gz"
    shell:
        """
        mv {input[0]} {output[0]}
        mv {input[1]} {output[1]}
        """

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

rule create_bw_track:
    input:
        "{species}/{version}/macs_output/{name}.bdg",
        "data/{species}.chrom.sizes"
    output:
        "{species}/{version}/macs_output/{name}.bw"
    shell:
        "./bdg2bw {input}"

rule create_peak_track:
    input:
        "{species}/{version}/macs_output/{name}_peaks.broadPeak",
        "data/{species}.chrom.sizes"
    output:
        "{species}/{version}/macs_output/{name}_peaks.bb"
    shell:
        "./broadPeak2bb.sh {input}"

rule create_domain_track:
    input:
        "{species}/{version}/domains/{name}.bed",
        "data/{species}.chrom.sizes"
    output:
        "{species}/{version}/domains/{name}.bb"
    shell:
        "./domains2bb.sh {input}"

rule create_subhub:
    input:
        "{species}/{version}/domains/{name}.bb",
        "{species}/{version}/macs_output/{name}_peaks.bb",
        "{species}/{version}/macs_output/{name}_treat_pileup.bw",
        "{species}/{version}/macs_output/{name}_control_lambda.bw",
        "{species}/{version}/macs_output/{name}_qvalues.bw"
    output:
        track_hub + "{species}/{version}_{name}_domains.bb",
        track_hub + "{species}/{version}_{name}_peaks.bb",
        track_hub + "{species}/{version}_{name}_treat_pileup.bw",
        track_hub + "{species}/{version}_{name}_control_lambda.bw",
        track_hub + "{species}/{version}_{name}_qvalues.bw",
    shell:
        """
        mv {input[0]} {output[0]}
        mv {input[1]} {output[1]}
        mv {input[2]} {output[2]}
        mv {input[3]} {output[3]}
        mv {input[4]} {output[4]}
        """

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

rule tss_plots:
    input:
        "data/{species}_genes.bed",
	"{species}/{version}/macs_output/{name}_qvalues.bdg"
    output:
        "{species}/{version}/tss_plots/{name}.npy",
        report("{species}/{version}/tss_plots/{name}.png", caption="TSS enrichment-plot for {name}")
    shell:
        "cat {input[1]} | chiptools tssplot {input[0]} {output}"

rule gate_domains:
    input:
        "{species}/{version}/domains/{name}.bed"
    output:
        "{species}/{version}/gated_domains/{name}_sub5k.bed",
        "{species}/{version}/gated_domains/{name}_5to20k.bed",
        "{species}/{version}/gated_domains/{name}_super20k.bed",
    shell:
        """
        awk '{{if (($3-$2)<5000) print}}' {input} > {output[0]}
        awk '{{if (5000<=($3-$2) && ($3-$2)<20000) print}}' {input} > {output[1]}
        awk '{{20000<=($3-$2)) print}}' {input} > {output[2]}
        """

rule average_plots:
    input:
        "{species}/{version}/gated_domains/{name}_{size}.bed",
        "{species}/{version}/macs_output/{name}_qvalues.bdg"
    output:
        "{species}/{version}/average_plots/{name}_{size}.npy",
        "{species}/{version}/average_plots/{name}_{size}.png"
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
