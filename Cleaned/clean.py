import re
import numpy as np
import pandas as pd


def prepare_for_allergy_and_health_app(
    input_file: str,
    output_file: str = "openfoodfacts_mobil_app_temizlenmis.csv",
) -> pd.DataFrame:
  # 1. Dosyayı oku ve sütun adlarını düzenle
  df = pd.read_csv(input_file, encoding="utf-8-sig")
  df.columns = df.columns.str.strip().str.lower()

  # 2. ADI veya BARKODU olmayanları doğrudan sil
  df = df.dropna(subset=["barcode", "name"]).copy()
  df["barcode"] = df["barcode"].astype(str).str.strip()
  df["name"] = df["name"].astype(str).str.strip()

  # 3. ALERJİ FİLTRESİ: Hem 'allergens' hem 'ingredients' boşsa sil
  # Çünkü alerji taraması yapacak hiçbir metin yok demektir.
  has_allergy_info = df["allergens"].notna() | df["ingredients"].notna()
  df = df[has_allergy_info]

  # 4. SAĞLIK/ZARAR FİLTRESİ:
  # Nutri-Score, NOVA veya temel besin değerlerinden en az biri olmalı
  has_health_info = (
      df["nutriscore"].notna()
      | df["nova_group"].notna()
      | (df["energy_kcal_100g"].notna() & df["sugars_100g"].notna())
  )
  df = df[has_health_info]

  # 5. METİN TEMİZLİĞİ:
  # İçindekilerdeki Markdown (*, _) işaretlerini temizle (kullanıcı arayüzünde temiz görünsün)
  def clean_ingredients(val):
    if pd.isna(val):
      return "Belirtilmemiş"
    val = re.sub(r"[*_]", "", str(val))
    return re.sub(r"\s+", " ", val).strip()

  # Alerjen sütunundaki 'en:' ön eklerini kaldır
  def clean_allergens(val):
    if pd.isna(val):
      return "Belirtilmemiş"
    items = [re.sub(r"^en:", "", item.strip()) for item in str(val).split(",")]
    return ", ".join(filter(None, items))

  df["ingredients"] = df["ingredients"].apply(clean_ingredients)
  df["allergens"] = df["allergens"].apply(clean_allergens)

  # 6. EKSİK ALANLARI UYGULAMA İÇİN ANLAMLI DEĞERLERLE DOLDUR (Sıfır NaN):
  df["brand"] = df["brand"].fillna("Bilinmeyen Marka")
  df["nutriscore"] = (
      df["nutriscore"]
      .str.upper()
      .replace({"UNKNOWN": "Bilinmiyor", "NOT-APPLICABLE": "Uygulanamaz"})
      .fillna("Bilinmiyor")
  )
  df["nova_group"] = df["nova_group"].fillna(0).astype(int)

  # Besin değerlerinde boş kalanları 0.0 yap (su/maden suyu gibi doğal ürünlerin boşlukları için)
  nutri_cols = [
      "energy_kcal_100g",
      "fat_100g",
      "sugars_100g",
      "proteins_100g",
      "salt_100g",
  ]
  for col in nutri_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0.0)

  # 7. Kaydet
  df.to_csv(output_file, index=False, encoding="utf-8-sig")
  print(f"Hazır! Toplam {len(df)} ürün mobil uygulama için optimize edildi.")
  return df


# Çalıştır:
df_temiz = prepare_for_allergy_and_health_app("OPENFOODFACT_TRILK500.csv")