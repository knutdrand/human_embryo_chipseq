rule size_hist:
    input:
        "peaks/{name}_{class}.{type}Peak"
    output:
        "histograms/{name}_{class}_{type}.png"
    shell:
        "python3 src/peak_histograms.py {input} {output}"

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
        "overlap_histogram/{reference}_{query}.txt",
        "overlap_histogram/{reference}_{query}.png",
    shell:
        """
	chiptools overlap_fraction {input} | awk "{{if (($3-$2)>5000) {{print $4}}}}" > {output[0]}
	python3 src/ratio_histogram.py {output}
	"""
