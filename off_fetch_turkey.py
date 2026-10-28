"""
Open Food Facts toplu veri (dump) ile Türkiye ürünlerini çekme.

Kullanım:
    pip install pandas requests
    python off_fetch_turkey.py

Çıktı:
    off_turkey_raw.csv   -> ham (temizlenmemiş) Türkiye ürünleri
Not: Dump ~1 GB (sıkıştırılmış). Bir kez indirilir, tekrar çalıştırınca atlanır.
"""
import csv
import gzip
import shutil
from pathlib import Path

import pandas as pd
import requests

import sys
sys.stdout.reconfigure(encoding="utf-8")

# ----------------------------------------------------------------- AYARLAR
USER_AGENT = "NutriScanApp/0.1 (sudenazyonezer@gmail.com)"   # <-- kendi bilgini yaz
URL = "https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz"
DUMP = Path("off_dump.csv.gz")
OUT = Path("off_turkey_raw.csv")
CHUNK_SIZE = 200_000

COLS = [
    # kimlik
    "code", "product_name", "generic_name", "brands", "quantity",
    "product_quantity", "serving_size",
    # kategori / ülke
    "categories_tags", "countries_tags", "labels_tags",
    # içerik
    "ingredients_text", "ingredients_tags", "ingredients_analysis_tags",
    # alerjen
    "allergens", "allergens_tags", "traces", "traces_tags",
    # katkı
    "additives_n", "additives_tags",
    # skorlar
    "nutriscore_grade", "nutriscore_score", "nova_group", "ecoscore_grade",
    # besin değerleri (100 g)
    "energy-kcal_100g", "energy-kj_100g", "fat_100g", "saturated-fat_100g",
    "carbohydrates_100g", "sugars_100g", "fiber_100g", "proteins_100g",
    "salt_100g", "sodium_100g",
    # görsel / veri kalitesi
    "image_front_url", "completeness", "data_quality_tags",
    "states_tags", "last_modified_t",
]


# ----------------------------------------------------------------- 1) İNDİR
def download_dump():
    if DUMP.exists():
        print(f"[1/3] Dump zaten var: {DUMP} ({DUMP.stat().st_size / 1e6:.0f} MB)")
        return

    print("[1/3] Dump indiriliyor (bu birkaç dakika sürebilir)...")
    tmp = DUMP.with_suffix(".part")
    with requests.get(URL, headers={"User-Agent": USER_AGENT},
                      stream=True, timeout=60) as r:
        r.raise_for_status()
        total = int(r.headers.get("Content-Length", 0))
        done = 0
        with tmp.open("wb") as f:
            for block in r.iter_content(chunk_size=1024 * 1024):
                f.write(block)
                done += len(block)
                if total:
                    print(f"\r      {done / 1e6:7.0f} / {total / 1e6:.0f} MB",
                          end="", flush=True)
    print()

    # bozuk indirme kontrolü
    try:
        with gzip.open(tmp, "rb") as g:
            g.read(1024)
    except OSError:
        tmp.unlink(missing_ok=True)
        raise RuntimeError("İndirilen dosya geçerli bir gzip değil, tekrar dene.")
    shutil.move(tmp, DUMP)
    print("      İndirme tamam.")


# ----------------------------------------------------------------- 2) SÜZ
def extract_turkey():
    print("[2/3] Türkiye ürünleri süzülüyor...")
    parts = []
    total_rows = 0
    reader = pd.read_csv(
        DUMP,
        sep="\t",
        compression="gzip",
        usecols=lambda c: c in COLS,      # dump'ta olmayan sütun hata vermez
        dtype=str,                        # barkod başındaki sıfırlar korunur
        chunksize=CHUNK_SIZE,
        on_bad_lines="skip",
        quoting=csv.QUOTE_NONE,           # OFF dump'ında tırnak sorunlarını önler
        low_memory=False,
    )
    for i, chunk in enumerate(reader):
        total_rows += len(chunk)
        is_tr_country = chunk["countries_tags"].fillna("").str.contains("en:turkey")
        is_tr_barcode = chunk["code"].fillna("").str.startswith("869")
        tr = chunk[is_tr_country | is_tr_barcode]
        parts.append(tr)
        print(f"      chunk {i:3d} | okunan toplam: {total_rows:>9,} "
              f"| bu chunk'ta TR: {len(tr):>4}")

    df = pd.concat(parts, ignore_index=True)
    df = df.drop_duplicates(subset="code").reset_index(drop=True)
    return df


# ----------------------------------------------------------------- 3) KAYDET
def save_and_report(df):
    print("[3/3] Kaydediliyor...")
    missing = [c for c in COLS if c not in df.columns]
    if missing:
        print("      UYARI - dump'ta bulunamayan sütunlar:", missing)

    df.to_csv(OUT, index=False, encoding="utf-8-sig")
    print(f"\n{len(df):,} ürün kaydedildi -> {OUT}\n")

    print("Önemli alanların DOLULUK oranı (%):")
    key = ["product_name", "brands", "ingredients_text", "allergens_tags",
           "traces_tags", "nutriscore_grade", "nova_group",
           "energy-kcal_100g", "fat_100g", "saturated-fat_100g",
           "sugars_100g", "fiber_100g", "proteins_100g", "salt_100g",
           "image_front_url"]
    for c in key:
        if c in df.columns:
            pct = df[c].notna().mean() * 100
            print(f"   {c:<22} {pct:5.1f}")


if __name__ == "__main__":
    download_dump()
    turkey_df = extract_turkey()
    save_and_report(turkey_df)