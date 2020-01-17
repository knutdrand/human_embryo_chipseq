rule size_hist:
    input:
        "peaks/{name}_{class}.{type}Peak"
    output:
        "histograms/{name}_{class}_{type}.png"
    shell:
        "python3 peak_histograms.py {input} {output}"