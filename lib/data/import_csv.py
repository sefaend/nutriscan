import os
import re
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

KEY_FILE = os.path.join(BASE_DIR, "serviceAccountKey.json")
CSV_FILE = os.path.join(BASE_DIR, "products_A_layer.csv")   
COLLECTION_NAME = "products"
BATCH_SIZE = 400

cred = credentials.Certificate(KEY_FILE)
firebase_admin.initialize_app(cred)
db = firestore.client()

def s(v):
    return "" if pd.isna(v) else str(v).strip()

def f(v):
    try:
        return None if pd.isna(v) else float(v)
    except (ValueError, TypeError):
        return None

def i(v):
    try:
        return None if pd.isna(v) else int(float(v))
    except (ValueError, TypeError):
        return None

def b(v):
    return str(v).strip().lower() in ("true", "1", "yes")

def lst(v):
    raw = s(v)
    return [x.strip() for x in re.split(r"[,|;]", raw) if x.strip()] if raw else []


def build_doc(row):
    code = s(row["code"])
    if code.endswith(".0"):
        code = code[:-2]
    if not code:
        return None, None

    doc = {
        "code": code,
        "name": s(row["name"]),
        "brand": s(row["brand"]),
        "quantity": s(row["quantity"]),
        "tier": s(row["tier"]),
        "image_url": s(row["image_url"]),
        "ingredients_text": s(row["ingredients_text"]),

        "allergen_status": s(row["allergen_status"]),
        "allergens": lst(row["allergens"]),
        "traces": lst(row["traces"]),

        "nutriscore_final": s(row["nutriscore_final"]).upper(),
        "nova_final": i(row["nova_final"]),
        "additives_n": i(row["additives_n"]),
        "scorable": b(row["scorable"]),
        "has_api": b(row["has_api"]),
        "quality_flags": lst(row["quality_flags"]),

        "nutriments_100g": {
            "energy_kcal": f(row["energy_kcal_100g"]),
            "energy_kj": f(row["energy_kj_100g"]),
            "fat": f(row["fat_100g"]),
            "saturated_fat": f(row["saturated_fat_100g"]),
            "carbohydrates": f(row["carbohydrates_100g"]),
            "sugars": f(row["sugars_100g"]),
            "fiber": f(row["fiber_100g"]),
            "proteins": f(row["proteins_100g"]),
            "salt": f(row["salt_100g"]),
            "sodium": f(row["sodium_100g"]),
        },

        "nutriscore": {
            "grade": s(row["nutriscore_grade"]).upper(),
            "group": s(row["nutriscore_group"]),
            "calc": s(row["nutriscore_calc"]).upper(),
            "score_calc": f(row["nutriscore_score_calc"]),
            "confidence": s(row["nutriscore_confidence"]),
            "notes": s(row["nutriscore_notes"]),
            "off": s(row["nutriscore_off"]).upper(),
            "final": s(row["nutriscore_final"]).upper(),
            "source": s(row["nutriscore_source"]),
        },

        "nova": {
            "group": i(row["nova_group"]),
            "estimated": i(row["nova_estimated"]),
            "est_confidence": s(row["nova_est_confidence"]),
            "off": i(row["nova_off"]),
            "final": i(row["nova_final"]),
            "source": s(row["nova_source"]),
            "processing_markers": lst(row["processing_markers"]),
            "processing_marker_count": i(row["processing_marker_count"]),
        },

        "countries_tags": lst(row["countries_tags"]),
        "categories_tags": lst(row["categories_tags"]),
        "labels_tags": lst(row["labels_tags"]),
    }
    return code, doc

def import_data():
    df = pd.read_csv(CSV_FILE, dtype={"code": str})
    col = db.collection(COLLECTION_NAME)

    batch = db.batch()
    in_batch = total = 0

    for _, row in df.iterrows():
        code, doc = build_doc(row)
        if not code:
            continue
        batch.set(col.document(code), doc)
        in_batch += 1
        total += 1
        if in_batch >= BATCH_SIZE:
            batch.commit()
            batch = db.batch()
            in_batch = 0
            print(f"{total} ürün yazıldı...")

    if in_batch:
        batch.commit()

    print(f"Başarılı! Toplam {total} ürün Firestore'a aktarıldı.")
if __name__ == "__main__":
    import_data()