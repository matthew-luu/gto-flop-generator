import itertools

ranks = "AKQJT98765432"
suits = "shdc"

# Full deck
deck = [r + s for r in ranks for s in suits]

rank_order = {r: i for i, r in enumerate(ranks)}  # A=0 ... 2=12


def normalize_cards(cards):
    """
    Sort cards deterministically:
      - primary: rank strength (A high)
      - secondary: suit label (so paired ranks get stable ordering)
    """
    return tuple(sorted(cards, key=lambda c: (rank_order[c[0]], c[1])))


def canonicalize_flop(flop):
    """
    Canonicalize up to suit isomorphism by trying all suit-label permutations
    for suits present on this flop and taking the minimum normalized tuple.
    """
    # Work with list of (rank, suit)
    cards = [(c[0], c[1]) for c in flop]
    suits_present = sorted({s for _, s in cards})

    # Map present suits -> canonical letters a,b,c (max 3 suits on a flop)
    canon_letters = ["a", "b", "c"]

    best = None
    for perm in itertools.permutations(canon_letters, len(suits_present)):
        suit_map = dict(zip(suits_present, perm))
        relabeled = [r + suit_map[s] for r, s in cards]
        norm = normalize_cards(relabeled)
        if best is None or norm < best:
            best = norm

    return best  # tuple like ("Ta","Tb","9a")


# Convert canonical suits → readable fixed suits
suit_restore = {
    "a": "h",
    "b": "d",
    "c": "c",
}

def restore_suits(flop):
    return " ".join(card[0] + suit_restore[card[1]] for card in flop)


unique = set()
for flop in itertools.combinations(deck, 3):
    unique.add(canonicalize_flop(flop))

with open("flops_1755.txt", "w") as f:
    for flop in sorted(unique):  # stable order
        f.write(restore_suits(flop) + "\n")

print(f"Created {len(unique)} canonical flops.")
