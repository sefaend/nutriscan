"""
Temizlik sonrasi teshis: kurallar cok mu sıkı, A katmani neden kuculdu, hangi alanlar bos?
Calistirma:  python diagnose.py
Cikti: ekrana ozet + review_samples.csv (elle bakman icin ornek satirlar)
"""
import sys
import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")

clean = pd.read_csv("products_clean.csv", dtype={"code": str})
review = pd.read_csv("products_review.csv", dtype={"code": str})

NUM = ["energy_kcal_100g", "fat_100g", "saturated_fat_100g", "carbohydrates_100g",
       "sugars_100g", "fiber_100g", "proteins_100g", "salt_100g"]
for d in (clean, review):
    for c in NUM:
        d[c] = pd.to_numeric(d[c], errors="coerce")

print("=== 1) Katman x alerjen durumu ===")
print(pd.crosstab(clean["tier"], clean["allergen_status"]), "\n")

print("=== 2) Temiz veride doluluk (%), katmana gore ===")
cols = ["nutriscore_grade", "nova_group", "ingredients_text", "image_url",
        "brand", "quantity", "saturated_fat_100g", "fiber_100g", "carbohydrates_100g"]
print(clean.groupby("tier")[cols].agg(lambda s: round(s.notna().mean() * 100, 1)).T, "\n")

print("=== 3) quality_flags sayilari (temiz veri) ===")
flags = clean["quality_flags"].fillna("").str.split(";").explode()
flags = flags[flags != ""].str.replace(r":.*", "", regex=True)
print(flags.value_counts().to_string(), "\n")

print("=== 4) A katmani alerjen ozeti ===")
a = clean[clean["tier"] == "A"]
n_all = a["allergens"].fillna("").map(lambda s: len([x for x in s.split(";") if x]))
print("Alerjeni hic olmayan urun orani: %.1f%%" % ((n_all == 0).mean() * 100))
print("Ortalama alerjen sayisi        : %.2f\n" % n_all.mean())

print("=== 5) REVIEW: energy_mismatch ne kadar sinirda? ===")
em = review[review["review_reason"].str.contains("energy_mismatch", na=False)].copy()
em["est_kcal"] = (9 * em["fat_100g"] + 4 * em["carbohydrates_100g"]
                  + 4 * em["proteins_100g"] + 2 * em["fiber_100g"].fillna(0))
em["fark_%"] = ((em["energy_kcal_100g"] - em["est_kcal"]).abs() / em["est_kcal"] * 100).round(0)
print("Toplam:", len(em))
for lo, hi in [(40, 50), (50, 75), (75, 100), (100, 10_000)]:
    print(f"   fark %{lo}-{hi}: {((em['fark_%'] >= lo) & (em['fark_%'] < hi)).sum()}")
print()

print("=== 6) REVIEW: sum>100 ne kadar sinirda? ===")
sm = review[review["review_reason"].str.contains("sum>100", na=False)].copy()
base = sm["carbohydrates_100g"].fillna(sm["sugars_100g"])
sm["toplam"] = sm[["fat_100g", "proteins_100g", "salt_100g"]].sum(axis=1) + base.fillna(0) \
    + np.where(sm["carbohydrates_100g"].notna(), sm["fiber_100g"].fillna(0), 0)
print("Toplam:", len(sm))
for lo, hi in [(105, 110), (110, 120), (120, 150), (150, 10_000)]:
    print(f"   toplam {lo}-{hi}: {((sm['toplam'] >= lo) & (sm['toplam'] < hi)).sum()}")
print()

print("=== 7) REVIEW: salt>10 ornek urunler ===")
print(review[review["review_reason"].str.contains("salt>10", na=False)][["name", "salt_100g"]]
      .head(10).to_string(index=False), "\n")

# elle bakmak icin ornekler
samples = []
for reason in ["energy_mismatch", "sum>100", "salt>10", "energy>900", "sat>fat", "sugar>carb"]:
    s = review[review["review_reason"].str.contains(reason, na=False)].head(8)
    samples.append(s)
pd.concat(samples).drop_duplicates("code").to_csv("review_samples.csv", index=False, encoding="utf-8-sig")
print("Ornekler -> review_samples.csv")