rule size_hist:
    input:
        "peaks/{name}.{type}Peak"
    output:
        "histograms/{name}_{type}.png"
    shell:
        "python3 peak_histograms {input} {output}"