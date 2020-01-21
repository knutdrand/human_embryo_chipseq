import numpy as np
import matplotlib.pyplot as plt
epsilon = 0.001

def logit(ratio):
    adjusted = ratio*(1-2*epsilon)+epsilon
    return np.log(adjusted/(1-adjusted))

if __name__ == "__main__":
    import sys
    import os
    if len(sys.argv>2):
        lines = open(sys.argv[1])
    else:
        lines = os.stdin
    numbers = np.array(
        [float(c.strip()) for c in lines])
    plt.hist(logit(numbers), bins=150)
    plt.savefig(sys.argv[-1])
    
