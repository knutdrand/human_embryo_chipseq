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
        "domains/{reference}_domains.bed",
        "domains/{query}_domains.bed",
    output:
        "overlap_histogram/{reference}_{query}.bed",
        "overlap_histogram/{reference}_{query}.png",
	
    shell:
        """
	chiptools overlap_fraction {input} > {output[0]}
	python3 src/ratio_hist.py {output}
	"""
