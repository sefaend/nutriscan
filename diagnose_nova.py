"""
NOVA tahminimiz neden OFF ile uyusmuyor? Verinin kendisinden ogren.
Calistirma:  python diagnose_nova.py   (once off_score.py calismis olmali)

Cikti:
  1) OFF=4 ama biz 3 dedik  -> bizim kacirdigimiz isaretler (en sik gecen icerikler)
  2) OFF=3 ama biz 4 dedik  -> bizim yanlis yakaladigimiz isaretler
  3) Her isaretin 'isabet orani' (bizim 4 dedigimiz urunlerde OFF'un da 4 deme orani)
"""
import re
import sys
from collections import Counter

import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
from off_score import MARKER_RX, TRACE_SPLIT, split_items, tr_lower

df = pd.read_csv("products_scored.csv", dtype={"code": str})
d = df[df["nova_off"].notna() & df["nova_estimated"].notna() & df["ingredients_text"].notna()].copy()


def items_of(text):
    t = tr_lower(TRACE_SPLIT.split(text, maxsplit=1)[0])
    out = []
    for it in split_items(t):
        it = re.sub(r"%\s?\d+([.,]\d+)?|\d+([.,]\d+)?\s?%", "", it)
        it = re.sub(r"[()\[\]]", " ", it)
        it = re.sub(r"\s+", " ", it).strip()
        if 2 <= len(it) <= 40:
            out.append(it)
    return out


def top_items(sub, n=30, exclude=None):
    c = Counter()
    for t in sub["ingredients_text"]:
        c.update(set(items_of(t)))
    if exclude is not None:
        for k in list(c):
            c[k] = c[k] - exclude.get(k, 0) * 0.5   # genel gecer icerikleri bastir
    return [(k, int(v)) for k, v in c.most_common(n) if v > 0]


miss = d[(d["nova_off"] == 4) & (d["nova_estimated"] == 3)]
agree3 = d[(d["nova_off"] == 3) & (d["nova_estimated"] == 3)]
base = Counter()
for t in agree3["ingredients_text"]:
    base.update(set(items_of(t)))

print(f"1) OFF=4, biz=3 ({len(miss)} urun) - bu urunlerde OFF'un 4 yapma nedeni olabilecek icerikler:")
print("   (sag taraf: OFF=3/biz=3 uyusan urunlerde kac kez geciyor; dusukse suclu bu)")
for k, v in top_items(miss, 40, exclude=base):
    print(f"   {k:<38} {v:>4}   | uyusanlarda: {base.get(k, 0)}")

fp = d[(d["nova_off"] == 3) & (d["nova_estimated"] == 4)]
print(f"\n2) OFF=3, biz=4 ({len(fp)} urun) - bizim tetikleyen isaretler:")
c = Counter()
for t in fp["ingredients_text"]:
    tt = tr_lower(TRACE_SPLIT.split(t, maxsplit=1)[0])
    c.update([k for k, rx in MARKER_RX.items() if rx.search(tt)])
for k, v in c.most_common():
    print(f"   {k:<32} {v:>4}")

print("\n3) Isaret bazinda isabet orani (isareti iceren urunlerde OFF'un 4 deme orani):")
rows = []
for k, rx in MARKER_RX.items():
    has = d["ingredients_text"].map(lambda t: bool(rx.search(tr_lower(TRACE_SPLIT.split(t, maxsplit=1)[0]))))
    sub = d[has]
    if len(sub):
        rows.append((k, len(sub), round((sub["nova_off"] == 4).mean() * 100, 1)))
for k, n, p in sorted(rows, key=lambda x: x[2]):
    print(f"   {k:<32} n={n:>5}   OFF=4 orani: %{p}")