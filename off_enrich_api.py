"""
Adim 2: 'Tam verili' urunler icin OFF API'den alerjen + gorsel bilgisini cek.

Kullanim:
    python off_enrich_api.py
Girdi : off_turkey_raw.csv  (dump'tan cikan dosya)
Cikti : off_enriched.jsonl  (her satir bir urun, kaldigi yerden devam eder)

Ctrl+C ile istedigin zaman durdurabilirsin, tekrar calistirinca kaldigi yerden devam eder.
"""
import json
import sys
import time
from pathlib import Path

import pandas as pd
import requests

sys.stdout.reconfigure(encoding="utf-8")

# ------------------------------------------------------------------ AYARLAR
USER_AGENT = "SaglikliSepetApp/0.1 (mailin@ornek.com)"   # <-- kendi bilgini yaz
INPUT = Path("off_turkey_raw.csv")
OUT = Path("off_enriched.jsonl")
DELAY = 4.5          # saniye -> ~13 istek/dk (limitin altinda)
LIMIT = None         # deneme icin 50 yazabilirsin, hepsi icin None

BASE = "https://world.openfoodfacts.org/api/v2/product"
FIELDS = ",".join([
    "code", "product_name", "product_name_tr", "brands",
    "ingredients_text", "ingredients_text_tr",
    "allergens_tags", "allergens_from_ingredients", "traces_tags",
    "nutriscore_grade", "nova_group",
    "image_front_url", "image_url",
])
HEADERS = {"User-Agent": USER_AGENT}

NEED = ["product_name", "ingredients_text", "energy-kcal_100g",
        "fat_100g", "sugars_100g", "proteins_100g", "salt_100g"]


def pick_codes():
    df = pd.read_csv(INPUT, dtype=str)
    full = df[NEED].notna().all(axis=1)
    df = df[full].copy()
    # Turkiye etiketli olanlar once gelsin
    df["_tr"] = df["countries_tags"].fillna("").str.contains("en:turkey")
    df = df.sort_values("_tr", ascending=False)
    codes = df["code"].tolist()
    print(f"Tam verili urun: {len(codes)} (Turkiye etiketli: {int(df['_tr'].sum())})")
    return codes[:LIMIT] if LIMIT else codes


def already_done():
    if not OUT.exists():
        return set()
    done = set()
    with OUT.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                done.add(json.loads(line)["code"])
    return done


def fetch(code, retries=5):
    for i in range(retries):
        try:
            r = requests.get(f"{BASE}/{code}.json", params={"fields": FIELDS},
                             headers=HEADERS, timeout=30)
            if r.status_code == 200:
                data = r.json()
                if data.get("status") == 1:
                    return data["product"]
                return {"code": code, "_not_found": True}
            if r.status_code in (429, 503):
                wait = 15 * (i + 1)
                print(f"   limit/sunucu mesgul ({r.status_code}), {wait} sn bekleniyor...")
                time.sleep(wait)
                continue
            if r.status_code == 404:
                return {"code": code, "_not_found": True}
            time.sleep(5)
        except requests.RequestException:
            time.sleep(5 * (i + 1))
    return None   # basarisiz, dosyaya yazma (sonraki calistirmada tekrar denenir)


def main():
    codes = pick_codes()
    done = already_done()
    todo = [c for c in codes if c not in done]
    print(f"Zaten cekilen: {len(done)} | Kalan: {len(todo)} | "
          f"tahmini sure: {len(todo) * DELAY / 60:.0f} dk\n")

    with OUT.open("a", encoding="utf-8") as f:
        for n, code in enumerate(todo, 1):
            product = fetch(code)
            if product is not None:
                f.write(json.dumps(product, ensure_ascii=False) + "\n")
                f.flush()
            if n % 25 == 0:
                print(f"   {n}/{len(todo)} tamamlandi")
            time.sleep(DELAY)

    print("\nBitti ->", OUT)


if __name__ == "__main__":
    main()