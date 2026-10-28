import pandas as pd
df = pd.read_csv("off_turkey_raw.csv", dtype=str)

print("SÜTUNLAR:", list(df.columns), "\n")

# Kaç ürün gerçekten Türkiye etiketli, kaçı sadece 869 önekiyle geldi
is_country = df["countries_tags"].fillna("").str.contains("en:turkey")
print("en:turkey etiketli      :", is_country.sum())
print("sadece 869 önekli        :", (~is_country).sum(), "\n")

# Sahte dolulukları ortaya çıkar
print("nutriscore_grade değerleri:\n", df["nutriscore_grade"].value_counts(dropna=False).head(10), "\n")
print("nova_group değerleri:\n", df["nova_group"].value_counts(dropna=False), "\n")

# Alerjen ve görsel sütunları hangi adla var
for c in df.columns:
    if "allerg" in c or "image" in c or "trace" in c:
        print(f"{c:<22} dolu: {df[c].notna().mean()*100:5.1f}%")

# "Tam veri" tanımı: isim + içindekiler + enerji + yağ + şeker + protein + tuz dolu
need = ["product_name", "ingredients_text", "energy-kcal_100g",
        "fat_100g", "sugars_100g", "proteins_100g", "salt_100g"]
full = df[need].notna().all(axis=1)
print("\nTAM VERİLİ ürün sayısı   :", full.sum())
print("  bunlardan Türkiye etiketli:", (full & is_country).sum())