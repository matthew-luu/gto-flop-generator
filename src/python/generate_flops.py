import itertools

ranks = "AKQJT98765432"
suits = "shdc"

# Build full deck
deck = [r + s for r in ranks for s in suits]

flops = itertools.combinations(deck, 3)

with open("flops.txt", "w") as f:
    for flop in flops:
        f.write(" ".join(flop) + "\n")

print("flops.txt created")
