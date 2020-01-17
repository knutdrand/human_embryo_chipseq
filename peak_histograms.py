import matplotlib.pyplot as plt
import numpy as np
bin_size = 0.05
n_bins = 250

def get_hist(lines):
    bins = np.zeros(n_bins, dtype="int")
    parts = (l.split() for l in lines)
    log_sizes = (np.log(int(p[2])-int(p[1])) for p in parts)
    size_bins = (min(s//bin_size, n_bins-1) for s in log_sizes)
    for sb in size_bins:
        bins[int(sb)] += 1
    return np.exp(np.arange(bins.size)*bin_size), bins
    
if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        input_lines = open(sys.argv[1])
    else:
        input_lines = sys.stdin
    out_name = sys.argv[2]
    x, y = get_hist(input_lines)
    N = 110 #np.flatnonzero(y)[0]
    print(N)
    plt.plot(y[N:])
    ticks = np.arange(0, y.size-N, (y.size-N)//7)
    plt.xticks(ticks, np.array(np.exp((ticks+N)*bin_size), dtype="int"))
    plt.savefig(out_name)
