import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# 1. Firebase Admin SDK başlat
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

CSV_FILE = "openfoodfacts_cleaned_data.csv"
COLLECTION_NAME = "products"

def import_nutriscan_data():
    df = pd.read_csv(CSV_FILE)
    
    # NaN değerleri boş string veya 0 ile doldur
    df["allergens"] = df["allergens"].fillna("")
    df["ingredients"] = df["ingredients"].fillna("")
    df["nutriscore"] = df["nutriscore"].fillna("-")
    df["brand"] = df["brand"].fillna("")
    df["image_url"] = df["image_url"].fillna("")
    
    batch = db.batch()
    total_count = 0

    for _, row in df.iterrows():
        # Barkodu string formatında al (doc_id olarak kullanılacak)
        barcode_str = str(int(row["barcode"])) if pd.notnull(row["barcode"]) else None
        if not barcode_str:
            continue

        # Alerjenleri listeye çevir (örn: "gluten, sesame-seeds" -> ["gluten", "sesame-seeds"])
        raw_allergens = str(row["allergens"]).strip()
        if raw_allergens and raw_allergens.lower() != "belirtilmemiş":
            allergens_list = [a.strip() for a in raw_allergens.split(",") if a.strip()]
        else:
            allergens_list = []

        # Firestore'a eklenecek temiz veri nesnesi
        product_doc = {
            "barcode": barcode_str,
            "name": str(row["name"]).strip(),
            "brand": str(row["brand"]).strip(),
            "nutriscore": str(row["nutriscore"]).strip().upper(),
            "nova_group": int(row["nova_group"]) if pd.notnull(row["nova_group"]) else 0,
            "allergens": allergens_list,
            "ingredients": str(row["ingredients"]).strip(),
            "image_url": str(row["image_url"]).strip(),
            "nutriments": {
                "energy_kcal_100g": float(row["energy_kcal_100g"]) if pd.notnull(row["energy_kcal_100g"]) else 0.0,
                "fat_100g": float(row["fat_100g"]) if pd.notnull(row["fat_100g"]) else 0.0,
                "sugars_100g": float(row["sugars_100g"]) if pd.notnull(row["sugars_100g"]) else 0.0,
                "proteins_100g": float(row["proteins_100g"]) if pd.notnull(row["proteins_100g"]) else 0.0,
                "salt_100g": float(row["salt_100g"]) if pd.notnull(row["salt_100g"]) else 0.0,
            }
        }

        # Belgeyi barkod adıyla koleksiyona ekle
        doc_ref = db.collection(COLLECTION_NAME).document(barcode_str)
        batch.set(doc_ref, product_doc)
        total_count += 1

    # Tüm 348 kaydı tek seferde gönder
    batch.commit()
    print(f"Başarılı! Toplam {total_count} ürün Firestore'a aktarıldı.")

if __name__ == "__main__":
    import_nutriscan_data()