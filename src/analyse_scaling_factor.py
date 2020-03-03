import sys
import matplotlib.pyplot as plt
import numpy as np

f = open(sys.argv[1])
header = next(f).split(",")
# for line in f:
#     if all(line.strip().split(",")):
#         print(line.strip().split(","))
rows = np.array([[float(c.strip()) for c in line.strip().split(",")] for line in f if all(line.strip().split(","))])
rows = rows[50:]
print(rows.shape)
lines = [plt.plot(col/rows.T[0])[0] for col in rows.T]
plt.legend(lines, header)
plt.title("Inverse_scaling_factor")
plt.xlabel("n")
plt.ylabel("tss[n]_sample/tss[n]_blastG")          
plt.savefig(sys.argv[2])

        

