"""
Adim 3: Ham dump + API zenginlestirme -> temiz veri.

Girdi : off_turkey_raw.csv, off_enriched.jsonl
Cikti : products_clean.csv     (A + B katmani, uygulamanin kullanacagi dosya)
        products_review.csv    (A olabilecek ama sasirtici degerli urunler; elle bak)
        products_rejected.csv  (elenenler + neden)

Calistirma:  python off_clean.py
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")

RAW = Path("off_turkey_raw.csv")
ENR = Path("off_enriched.jsonl")
OUT_CLEAN = Path("products_clean.csv")
OUT_REVIEW = Path("products_review.csv")
OUT_REJECT = Path("products_rejected.csv")

PLACEHOLDERS = {"", "unknown", "not-applicable", "belirtilmemiş", "bilinmiyor",
                "uygulanamaz", "bilinmeyen marka", "nan", "none", "null", "-"}

NUTR_RENAME = {
    "energy-kcal_100g": "energy_kcal_100g", "energy-kj_100g": "energy_kj_100g",
    "fat_100g": "fat_100g", "saturated-fat_100g": "saturated_fat_100g",
    "carbohydrates_100g": "carbohydrates_100g", "sugars_100g": "sugars_100g",
    "fiber_100g": "fiber_100g", "proteins_100g": "proteins_100g",
    "salt_100g": "salt_100g", "sodium_100g": "sodium_100g",
}
NUTR = list(NUTR_RENAME.values())
CORE = ["energy_kcal_100g", "fat_100g", "sugars_100g", "proteins_100g", "salt_100g"]

# ------------------------------------------------------------ ALERJENLER (AB 14)
STD = {"gluten", "milk", "eggs", "nuts", "peanuts", "soybeans", "fish",
       "crustaceans", "molluscs", "celery", "mustard", "sesame-seeds",
       "sulphur-dioxide-and-sulphites", "lupin"}
ALIAS = {"tree-nuts": "nuts", "wheat": "gluten", "soy": "soybeans",
         "sesame": "sesame-seeds", "sulphites": "sulphur-dioxide-and-sulphites",
         "sulfites": "sulphur-dioxide-and-sulphites", "egg": "eggs"}

PATTERNS = {
    "gluten": r"gluten|buğday|bugday|\barpa|yulaf|çavdar|bulgur|(?<!mısır )(?<!pirinç )\bun\b|wheat|barley|\brye\b|\boats?\b|blé|orge|seigle|avoine|weizen|gerste|roggen|hafer",
    "milk": r"süt|laktoz|peynir|yoğurt|tereyağ|kazein|whey|\bayran|kefir|\bmilk|\bwhey|\bcream|(?<!cocoa )(?<!shea )(?<!cacao )\bbutter|cheese|lactose|casein|yogh?urt|\blait\b|crème|(?<!de cacao )beurre|fromage|lactosérum|milch|molke|sahne",
    "eggs": r"yumurta|albümin|albumin|\begg|\bœuf|\boeuf|albumen",
    "nuts": r"fındık|findik|badem|(?<!hindistan )\bceviz(?!i)|antep fıstı|antep fisti|kaju|pikan|macadamia|sert kabuklu|hazelnut|almond|walnut|cashew|pistachio|pecan|noisette|amande|\bnoix|haselnuss|mandel|walnuss",
    "peanuts": r"yer fıstı|yerfıstı|yer fisti|yer-fıstı|peanut|groundnut|arachide|erdnuss|erdnüsse",
    "soybeans": r"\bsoya|\bsoy |\bsoy|\bsoja",
    "fish": r"balık|balik|ançüez|ançuez|orkinos|\bfish|poisson|anchov|\btuna|\bfisch",
    "crustaceans": r"karides|yengeç|ıstakoz|shrimp|prawn|\bcrab|lobster|crevette",
    "molluscs": r"midye|kalamar|ahtapot|istiridye|mussel|\bsquid|octopus|oyster|\bmoule",
    "celery": r"kereviz|celery|céleri|sellerie",
    "mustard": r"hardal|mustard|moutarde|\bsenf",
    "sesame-seeds": r"susam|tahin|sesame|sésame|\bsesam",
    "sulphur-dioxide-and-sulphites": r"sülfit|sulfit|metabisülfit|kükürt ?dioksit|\be22[0-8]\b|sulphite|sulfite|sulphur dioxide|sulfur dioxide|dioxyde de soufre|schwefel",
    "lupin": r"lupin|acı bakla",
}
COMPILED = {k: re.compile(v) for k, v in PATTERNS.items()}
TRACE_SPLIT = re.compile(r"eser miktar|iz miktar|içerebilir|may contain|traces of|peut contenir|kann spuren|kann enthalten")


def tr_lower(s):
    return str(s).replace("İ", "i").replace("I", "ı").lower()


def detect(text):
    t = tr_lower(text)
    return {k for k, rx in COMPILED.items() if rx.search(t)}


def split_ingredients(text):
    """(kesin icerik kismi, iz miktar kismi)"""
    t = tr_lower(text)
    parts = TRACE_SPLIT.split(t, maxsplit=1)
    return parts[0], (parts[1] if len(parts) > 1 else "")


def to_list(v):
    if v is None or (isinstance(v, float) and np.isnan(v)):
        return []
    if isinstance(v, (list, tuple, np.ndarray)):
        return [str(x) for x in v]
    s = str(v).strip()
    if not s or tr_lower(s) in PLACEHOLDERS:
        return []
    if s.startswith("["):
        try:
            return [str(x) for x in json.loads(s)]
        except Exception:
            pass
    return [p.strip() for p in s.split(",") if p.strip()]


def normalize_allergens(items):
    out = set()
    for t in items:
        t = tr_lower(t).strip()
        t = re.sub(r"^[a-z]{2,3}:", "", t)
        if t in STD:
            out.add(t)
        elif t in ALIAS:
            out.add(ALIAS[t])
        else:
            out |= detect(t)
    return out


# ------------------------------------------------------------ YARDIMCILAR
def clean_str(x):
    if x is None or (isinstance(x, float) and np.isnan(x)):
        return np.nan
    s = re.sub(r"\s+", " ", str(x)).strip()
    return np.nan if tr_lower(s) in PLACEHOLDERS else s


NON_FOOD = re.compile(r"film kaplı tablet|deksketoprofen|reçete ile|kullanma talimatı|\bkapsül\b")
GARBAGE = re.compile(r"işletme kayıt|üretici|tel no|www\.|\.com|tavsiye edilen|"
                     r"muhafaza|enerji ve besin|\bkj/|\bkcal\b|gıda işletmecisi|net miktar")
NON_LATIN = re.compile(r"[\u0400-\u04FF\u0600-\u06FF]")
OCR_ZERO = re.compile(r"(?<=[A-Za-zÇĞİÖŞÜçğıöşü])0|0(?=[A-Za-zÇĞİÖŞÜ]{2})")
ZERO_OK = re.compile(r"\bsu\b|maden|soda|mineral|water|şekersiz|zero|light|diet|sıfır|"
                     r"\bçay\b|kahve|coffee|\btea\b|\btuz\b")
SALT_PRODUCT = re.compile(r"\btuz\b")
SALT_OK = re.compile(r"tuz|harç|harc|baharat|çeşni|seasoning")
NON_SCORABLE = re.compile(r"\btuz\b|kabartma tozu|^maya$|\bmaya\b")


def ingredients_ok(text):
    if not isinstance(text, str):
        return False
    if not (8 <= len(text) <= 1200):
        return False
    t = tr_lower(text)
    if GARBAGE.search(t):
        return False
    if len(NON_LATIN.findall(text)) / max(len(text), 1) > 0.05:
        return False
    if len(OCR_ZERO.findall(text)) >= 3:
        return False
    return True


def ingredients_rich(text):
    """Alerjen yoklugunu dogrulamaya yetecek kadar ayrintili mi? ('Nuts Cacao' degil)"""
    if not isinstance(text, str):
        return False
    return bool(re.search(r"[,;%]", text)) or len(text) >= 25


CAT_EXPECT = {
    "gluten": re.compile(r"en:(pastas?|noodles|egg-noodles|biscuits|breads?|crackers|cakes|"
                         r"wafers|breakfast-cereals|cereals-and-their-products|flours|wheat)"),
    "milk": re.compile(r"en:(milks|yogurts|cheeses|milk-chocolates|fermented-milks|creams)"),
    "peanuts": re.compile(r"en:(peanut-butters|peanuts)"),
    "eggs": re.compile(r"en:(egg-noodles|mayonnaises)"),
}
NAME_EXPECT = {
    "gluten": re.compile(r"erişte|makarna|bisküvi|kraker|gofret|ekmek|şehriye|\bun\b"),
    "milk": re.compile(r"\bsüt\b|sütlü|yoğurt|peynir|kefir|ayran"),
    "eggs": re.compile(r"yumurtalı"),
}


def expected_missing(name, cats, labels, present):
    """Kategori/isim bir alerjeni isaret ediyor ama listede yoksa -> eksik liste"""
    missing = set()
    labels = tr_lower(labels or "")
    cats = tr_lower(cats or "")
    name = tr_lower(name or "")
    for a, rx in CAT_EXPECT.items():
        if rx.search(cats) and a not in present:
            if a == "gluten" and "gluten-free" in labels:
                continue
            missing.add(a)
    for a, rx in NAME_EXPECT.items():
        if rx.search(name) and a not in present:
            if a == "gluten" and "gluten-free" in labels:
                continue
            missing.add(a)
    return missing


def num(x):
    return pd.to_numeric(x, errors="coerce")


# ------------------------------------------------------------ YUKLE + BIRLESTIR
def load():
    raw = pd.read_csv(RAW, dtype=str)
    raw["code"] = raw["code"].str.strip()
    raw = raw.drop_duplicates("code").reset_index(drop=True)

    rows = []
    if ENR.exists():
        with ENR.open(encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    rows.append(json.loads(line))
    enr = pd.DataFrame(rows)
    if enr.empty or "code" not in enr.columns:
        enr = pd.DataFrame(columns=["code"])
    enr["code"] = enr["code"].astype(str)
    enr = enr.drop_duplicates("code")
    if "_not_found" in enr.columns:
        enr = enr[enr["_not_found"].isna()]
    keep = ["code", "allergens_tags", "allergens_from_ingredients", "traces_tags",
            "image_front_url", "ingredients_text_tr", "product_name_tr"]
    enr = enr[[c for c in keep if c in enr.columns]].copy()
    enr = enr.rename(columns={c: "api_" + c for c in enr.columns if c != "code"})
    enr["has_api"] = True

    df = raw.merge(enr, on="code", how="left")
    df["has_api"] = df["has_api"].fillna(False).astype(bool)
    print(f"Ham: {len(raw)} urun | API verisi olan: {int(df['has_api'].sum())}")
    return df


# ------------------------------------------------------------ SATIR ISLEME
def process(df):
    df = df.rename(columns=NUTR_RENAME)
    for c in NUTR:
        df[c] = num(df[c]) if c in df.columns else np.nan

    # marka: ilk marka, kirli degerleri at, yazimi tekillestir
    def first_brand(b):
        b = clean_str(b)
        if not isinstance(b, str):
            return np.nan
        b = b.split(",")[0].strip()
        if re.fullmatch(r"\d+\s*(g|gr|kg|ml|l|lt)", tr_lower(b)) or len(b) > 40:
            return np.nan
        return b or np.nan

    df["brand"] = df["brands"].map(first_brand)
    forms = {}
    for b in df["brand"].dropna():
        forms.setdefault(tr_lower(b), Counter())[b] += 1
    canon = {k: c.most_common(1)[0][0] for k, c in forms.items()}
    df["brand"] = df["brand"].map(lambda b: canon.get(tr_lower(b), b) if isinstance(b, str) else b)

    records = []
    for r in df.to_dict("records"):
        flags = []
        # --- isim
        name = clean_str(r.get("product_name"))
        if not isinstance(name, str):
            name = clean_str(r.get("api_product_name_tr"))
        if isinstance(name, str) and (len(name) < 3 or not re.search(r"[A-Za-zÇĞİÖŞÜçğıöşü]", name)):
            name = np.nan

        # --- icindekiler (API tr varsa onu tercih et)
        ing = clean_str(r.get("api_ingredients_text_tr"))
        if not (isinstance(ing, str) and ingredients_ok(ing)):
            ing = clean_str(r.get("ingredients_text"))
        ing_ok = ingredients_ok(ing)
        if isinstance(ing, str) and not ing_ok:
            flags.append("ingredients_garbage")

        # --- besin degerleri
        v = {c: r.get(c) for c in NUTR}
        v = {c: (np.nan if pd.isna(x) else float(x)) for c, x in v.items()}
        if np.isnan(v["energy_kcal_100g"]) and not np.isnan(v["energy_kj_100g"]):
            v["energy_kcal_100g"] = v["energy_kj_100g"] / 4.184
            flags.append("kcal_from_kj")

        kcal0, kj0 = v["energy_kcal_100g"], v["energy_kj_100g"]
        if (not np.isnan(kcal0)) and (not np.isnan(kj0)) and kcal0 > 0:
            ratio = kj0 / (kcal0 * 4.184)
            if not (0.85 <= ratio <= 1.15):
                v["energy_kj_100g"] = np.nan
                flags.append("kj_mismatch_nulled")

        text_for_name = tr_lower(name) if isinstance(name, str) else ""
        zero_ok = bool(ZERO_OK.search(text_for_name))

        core_vals = [v[c] for c in CORE]
        if all((not np.isnan(x)) and x == 0 for x in core_vals) and not zero_ok:
            for c in NUTR:
                v[c] = np.nan
            flags.append("all_zero_nulled")
        if v["energy_kcal_100g"] == 0 and any(
                (not np.isnan(v[c])) and v[c] > 1
                for c in ["fat_100g", "proteins_100g", "sugars_100g", "carbohydrates_100g"]):
            v["energy_kcal_100g"] = np.nan
            flags.append("zero_energy_nulled")
        if (not np.isnan(v["salt_100g"])) and 0 < v["salt_100g"] < 0.001:
            v["salt_100g"] = np.nan
            flags.append("salt_tiny_nulled")

        # kcal alanina yanlislikla kJ girilmis mi? (kcal ~ 4.184 x makrolardan hesaplanan)
        _f, _c, _p = v["fat_100g"], v["carbohydrates_100g"], v["proteins_100g"]
        _k = v["energy_kcal_100g"]
        if not any(np.isnan(x) for x in (_f, _c, _p, _k)):
            _est = 9 * _f + 4 * _c + 4 * _p + (0 if np.isnan(v["fiber_100g"]) else 2 * v["fiber_100g"])
            if _est >= 20 and _k > _est * 1.5 and 0.85 <= _k / (_est * 4.184) <= 1.15:
                v["energy_kj_100g"] = _k
                v["energy_kcal_100g"] = _k / 4.184
                flags.append("kcal_was_kj_fixed")

        hard = []
        kcal, fat, sat = v["energy_kcal_100g"], v["fat_100g"], v["saturated_fat_100g"]
        carb, sug, pro = v["carbohydrates_100g"], v["sugars_100g"], v["proteins_100g"]
        fib, salt = v["fiber_100g"], v["salt_100g"]
        nn = lambda x: not np.isnan(x)

        if nn(kcal) and kcal > 900:
            hard.append("energy>900")
        if any(nn(x) and (x > 100 or x < 0) for x in [fat, sat, carb, sug, pro, fib]):
            hard.append("value_out_of_range")
        if nn(salt) and salt > 10 and not SALT_OK.search(text_for_name):
            hard.append("salt>10")
        if nn(sat) and nn(fat) and sat > fat + 0.5:
            hard.append("sat>fat")
        if nn(sug) and nn(carb) and sug > carb + 0.5:
            hard.append("sugar>carb")
        base = carb if nn(carb) else sug
        parts = [x for x in [fat, base, pro, salt] if nn(x)]
        if nn(carb) and nn(fib):
            parts.append(fib)
        if sum(parts) > 110:
            hard.append("sum>100")
        if all(nn(x) for x in [kcal, fat, carb, pro]):
            est = 9 * fat + 4 * carb + 4 * pro + (2 * fib if nn(fib) else 0)
            if abs(kcal - est) > max(60, 0.4 * est):
                hard.append("energy_mismatch")

        # --- alerjenler
        certain = set()
        if r.get("has_api"):
            certain |= normalize_allergens(to_list(r.get("api_allergens_tags")))
            certain |= normalize_allergens(to_list(r.get("api_allergens_from_ingredients")))
        certain |= normalize_allergens(to_list(r.get("allergens")))
        text_certain, text_trace = (set(), set())
        if ing_ok:
            sure_part, trace_part = split_ingredients(ing)
            text_certain, text_trace = detect(sure_part), detect(trace_part)
        extra = text_certain - certain
        if extra and r.get("has_api"):
            flags.append("allergen_text_extra:" + "|".join(sorted(extra)))
        allergens = certain | text_certain

        traces = set()
        traces |= normalize_allergens(to_list(r.get("traces_tags")))
        traces |= normalize_allergens(to_list(r.get("api_traces_tags")))
        traces |= text_trace
        traces -= allergens

        rich = ing_ok and ingredients_rich(ing)
        miss = expected_missing(name, r.get("categories_tags"), r.get("labels_tags"),
                                allergens | traces)
        if miss:
            flags.append("expected_allergen_missing:" + "|".join(sorted(miss)))
        if not rich:
            flags.append("ingredients_too_short")
        if r.get("has_api") and rich and not miss:
            status = "api_verified"
        elif rich and not miss:
            status = "text_based"
        else:
            status = "unverified"
        internal = str(r["code"]).startswith("2") and len(str(r["code"])) == 13
        if internal:
            flags.append("internal_barcode")
        # --- skorlar
        ns = clean_str(r.get("nutriscore_grade"))
        ns = ns.upper() if isinstance(ns, str) and ns.lower() in list("abcde") else np.nan
        nova = num(r.get("nova_group"))
        nova = nova if (not pd.isna(nova) and 1 <= nova <= 4) else np.nan

        records.append({
            "code": r["code"], "name": name, "brand": r.get("brand"),
            "quantity": clean_str(r.get("quantity")),
            "ingredients_text": ing if ing_ok else np.nan,
            "allergens": ";".join(sorted(allergens)),
            "traces": ";".join(sorted(traces)),
            "allergen_status": status,
            "nutriscore_grade": ns, "nova_group": nova,
            "additives_n": num(r.get("additives_n")),
            **{c: (round(x, 1) if nn(x) else np.nan) for c, x in v.items()},
            "image_url": clean_str(r.get("api_image_front_url")),
            "countries_tags": r.get("countries_tags"),
            "has_api": bool(r.get("has_api")),
            "_ing_ok": ing_ok, "_internal": internal, "_status": status, "_hard": hard, "_flags": flags,
            "_non_food": bool(NON_FOOD.search(text_for_name + " " + tr_lower(r.get("ingredients_text") or ""))),
            "_non_scorable": bool(NON_SCORABLE.search(text_for_name)),
        })
    return pd.DataFrame(records)


# ------------------------------------------------------------ KATMANLAMA
def tier(df):
    n_core = df[CORE].notna().sum(axis=1)
    has_name = df["name"].notna()

    reason = pd.Series("", index=df.index)
    reason[~has_name] = "no_name"
    reason[has_name & df["_non_food"]] = "not_food"
    keepable = has_name & ~df["_non_food"] & (df["_ing_ok"] | (n_core >= 3))
    reason[has_name & ~df["_non_food"] & ~keepable] = "insufficient_data"

    a_cand = (keepable & df["_ing_ok"] & (n_core == 5) & df["has_api"]
              & (df["allergen_status"] == "api_verified") & ~df["_internal"])
    has_hard = df["_hard"].map(len) > 0

    df["tier"] = ""
    df.loc[keepable, "tier"] = "B"
    df.loc[a_cand & ~has_hard, "tier"] = "A"
    review_mask = keepable & has_hard & (n_core >= 4)
    # supheli degerli satirlarda besin degerlerini guvenme (B'de bos birak)
    for c in NUTR:
        df.loc[keepable & has_hard & ~review_mask, c] = np.nan

    df["quality_flags"] = df.apply(lambda r: ";".join(r["_hard"] + r["_flags"]), axis=1)
    df["scorable"] = ~df["_non_scorable"]

    rejected = df[~keepable].copy()
    rejected["reject_reason"] = reason[~keepable]
    review = df[review_mask].copy()
    review["review_reason"] = review["_hard"].map(";".join)
    clean = df[keepable & ~review_mask].copy()
    return clean, review, rejected


def main():
    df = process(load())
    clean, review, rejected = tier(df)

    drop = ["_ing_ok", "_hard", "_flags", "_non_food", "_non_scorable", "_internal", "_status"]
    cols_order = ["code", "name", "brand", "quantity", "tier", "allergen_status",
                  "allergens", "traces", "ingredients_text", "nutriscore_grade",
                  "nova_group", "additives_n"] + NUTR + \
                 ["scorable", "image_url", "quality_flags", "has_api", "countries_tags"]

    for d in (clean, review):
        d["nova_group"] = d["nova_group"].astype("Int64")
        d["additives_n"] = d["additives_n"].astype("Int64")

    clean[cols_order].to_csv(OUT_CLEAN, index=False, encoding="utf-8-sig")
    review.drop(columns=drop).to_csv(OUT_REVIEW, index=False, encoding="utf-8-sig")
    rejected[["code", "name", "brand", "reject_reason"]].to_csv(
        OUT_REJECT, index=False, encoding="utf-8-sig")

    print("\n===== OZET =====")
    print("Temiz (A+B):", len(clean), "->", dict(clean["tier"].value_counts()))
    print("Elle bakilacak (review):", len(review))
    print("Elenen:", len(rejected), "->", dict(rejected["reject_reason"].value_counts()))
    print("\nA katmani alerjen durumu:", dict(clean[clean.tier == "A"]["allergen_status"].value_counts()))
    print("\nReview nedenleri (ilk 10):")
    cnt = Counter(x for s in review["review_reason"] for x in s.split(";") if x)
    for k, n in cnt.most_common(10):
        print(f"   {k:<22} {n}")
    print(f"\nDosyalar: {OUT_CLEAN}, {OUT_REVIEW}, {OUT_REJECT}")


if __name__ == "__main__":
    main()