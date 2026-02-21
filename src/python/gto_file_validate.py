import os
from collections import defaultdict

FOLDER = "."          # change if needed
EXPECTED_COUNT = 1755 # optional sanity check


files = [f for f in os.listdir(FOLDER) if f.lower().endswith(".gto")]

print(f"Found {len(files)} .gto files\n")


# ------------------------------------------------
# 1) Exact filename duplicates (rare but safe check)
# ------------------------------------------------
exact_seen = set()
exact_dupes = []

for f in files:
    if f in exact_seen:
        exact_dupes.append(f)
    exact_seen.add(f)

if exact_dupes:
    print("❌ EXACT DUPLICATE FILENAMES:")
    for f in exact_dupes:
        print("   ", f)
else:
    print("✅ No exact filename duplicates\n")


# ------------------------------------------------
# 2) Logical duplicates (ignore numeric prefix)
#    e.g. 1.SRP_322_TT.gto -> SRP_322_TT.gto
# ------------------------------------------------
logical_map = defaultdict(list)

for f in files:
    parts = f.split(".", 1)
    logical = parts[1] if len(parts) > 1 else f
    logical_map[logical].append(f)

logical_dupes = {k: v for k, v in logical_map.items() if len(v) > 1}

if logical_dupes:
    print("❌ LOGICAL DUPLICATES (same board name):\n")
    for name, group in logical_dupes.items():
        print(name)
        for g in group:
            print("   ", g)
        print()
else:
    print("✅ No logical duplicates\n")


# ------------------------------------------------
# 3) Count check
# ------------------------------------------------
if EXPECTED_COUNT:
    if len(files) != EXPECTED_COUNT:
        print(f"⚠️  Expected {EXPECTED_COUNT} files but found {len(files)}")
    else:
        print("✅ File count matches expected total")


print("\nDone.")
