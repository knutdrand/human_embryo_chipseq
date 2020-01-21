import numpy as np
import matplotlib.pyplot as plt
epsilon = 0.001

def logit(ratio):
    adjusted = ratio*(1-2*epsilon)+epsilon
    return np.log(adjusted/(1-adjusted))

if __name__ == "__main__":
    import sys
    input_file = sys.argv[1]
    numbers = np.array(
        [float(c.strip()) for c in open(input_file).read().split()])
    plt.hist(logit(numbers), bins=150)
    plt.savefig(sys.argv[-1])
    
