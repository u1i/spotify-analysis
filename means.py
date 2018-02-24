import sys

file = sys.argv[1]

def mean(numbers):
    return float(sum(numbers)) / max(len(numbers), 1)

l=[]
with open(file) as tempo_file:
	tempo_data=tempo_file.read().splitlines()
	for t in tempo_data:
		l.append(float(t))

m = mean(l)

print m
