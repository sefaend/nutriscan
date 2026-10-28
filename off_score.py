"""
Adim 4: Kendi Nutri-Score (2023 algoritmasi) ve islenmislik (NOVA benzeri) skorumuzu hesapla.

Girdi : products_clean.csv, off_turkey_raw.csv (categories_tags/labels_tags icin)
Cikti : products_scored.csv          (temiz veri + yeni skor sutunlari)
        nutriscore_mismatches.csv    (bizim hesap ile OFF notu 2+ harf farkli olanlar)

Calistirma:  python off_score.py

NOT: Resmi Nutri-Score 2023 tablolari (Sante publique France Q&A, 21 Aralik 2023) kullanildi.
 - Genel gidalar ve iceceklar hesaplanir.
 - Yag/yagli tohum/kuruyemis grubu (tereyagi, fistik ezmesi, tahin...) HESAPLANMAZ, OFF notu kullanilir.
 - Meyve/sebze/baklagil orani bilinmedigi icin 0 kabul edilir; guven seviyesine yansir.
"""
import re
import sys

import numpy as np
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")

CLEAN = "products_clean.csv"
RAW = "off_turkey_raw.csv"
OUT = "products_scored.csv"
OUT_MISMATCH = "nutriscore_mismatches.csv"

# ------------------------------------------------------------ NUTRI-SCORE TABLOLARI (2023)
E_GEN = [335 * i for i in range(1, 11)]
SUG_GEN = [3.4, 6.8, 10, 14, 17, 20, 24, 27, 31, 34, 37, 41, 44, 48, 51]
SAT = list(range(1, 11))
SALT = [round(0.2 * i, 1) for i in range(1, 21)]
PROT = [2.4, 4.8, 7.2, 9.6, 12, 14, 17]
FIB = [3.0, 4.1, 5.2, 6.3, 7.4]
E_BEV = [30, 90, 150, 210, 240, 270, 300, 330, 360, 390]
SUG_BEV = [0.5, 2, 3.5, 5, 6, 7, 8, 9, 10, 11]
PROT_BEV = [1.2, 1.5, 1.8, 2.1, 2.4, 2.7, 3.0]


def pts(value, thresholds):
    return int(sum(value > t for t in thresholds))


def grade_food(score):
    return "A" if score <= 0 else "B" if score <= 2 else "C" if score <= 10 else "D" if score <= 18 else "E"


def grade_beverage(score):
    return "B" if score <= 2 else "C" if score <= 6 else "D" if score <= 9 else "E"


# ------------------------------------------------------------ KATEGORI TESPITI
BEV_TAGS = {
    "en:beverages", "en:milks", "en:uht-milks", "en:whole-milks", "en:semi-skimmed-milks",
    "en:skimmed-milks", "en:dairy-drinks", "en:flavoured-milks", "en:chocolate-milks",
    "en:fermented-milk-drinks", "en:kefirs", "en:ayran", "en:buttermilks",
    "en:drinkable-yogurts", "en:yogurt-drinks", "en:plant-based-milk-alternatives",
    "en:plant-based-beverages", "en:juices-and-nectars", "en:fruit-juices", "en:nectars",
    "en:sodas", "en:carbonated-drinks", "en:iced-teas", "en:energy-drinks",
    "en:sweetened-beverages", "en:non-alcoholic-beverages", "en:flavoured-waters",
}
FAT_TAGS = {
    "en:fats", "en:oils", "en:vegetable-oils", "en:vegetable-fats", "en:margarines", "en:butters",
    "en:creams", "en:cooking-creams", "en:whipped-creams", "en:nuts", "en:peanuts",
    "en:peanut-butters", "en:nut-butters", "en:nuts-and-their-products", "en:seeds",
    "en:sunflower-seeds", "en:tahini", "en:sesame-seeds", "en:olive-oils",
}
WATER_TAGS = {"en:waters", "en:mineral-waters", "en:spring-waters", "en:natural-mineral-waters"}
RED_MEAT = re.compile(r"en:(red-meats|beef|pork|lamb|mutton|veal|sausages|salamis|horse)\b")
BEV_NAME = re.compile(r"\bayran\b|kefir|gazoz|limonata|\bkola\b|\bcola\b|\bsoda\b|içecek|meyve suyu|nektar|"
                      r"soğuk çay|\bsüt\b|pepsi|fanta|sprite")

SWEETENER = re.compile(r"asesülfam|aspartam|siklamat|sakkarin|sukraloz|steviol|stevia|steviya|"
                       r"neotam|advantam|taumatin|neohesperidin|\be95[0-2]\b|\be954\b|\be955\b|"
                       r"\be957\b|\be959\b|\be96[0-2]\b|\be969\b")
FVL_WORDS = re.compile(r"meyve|sebze|domates|havuç|elma|şeftali|kayısı|portakal|limon suyu|"
                       r"nohut|mercimek|fasulye|bezelye|biber|ıspanak|çilek|vişne|incir|hurma|üzüm|nar suyu|mango|muz")


def tr_lower(s):
    return str(s).replace("İ", "i").replace("I", "ı").lower()


def tag_set(v):
    if not isinstance(v, str):
        return set()
    return {t.strip() for t in v.split(",") if t.strip()}


def classify(name, cats_raw, sugars):
    tags = tag_set(cats_raw)
    n = tr_lower(name or "")
    if tags & WATER_TAGS and "en:flavoured-waters" not in tags:
        return "water"
    if not tags:
        if re.search(r"maden suyu|kaynak suyu|mineralli su|içme suyu|^su\b", n) and (sugars in (0, 0.0) or pd.isna(sugars)):
            return "water"
    if tags & FAT_TAGS:
        return "fats_nuts"
    if tags & BEV_TAGS:
        return "beverage"
    if not tags and BEV_NAME.search(n):
        return "beverage"
    return "general"


# ------------------------------------------------------------ NUTRI-SCORE HESABI
def compute_nutriscore(r, cats_raw):
    name = r.get("name")
    cats = cats_raw if isinstance(cats_raw, str) else ""
    group = classify(name, cats_raw, r.get("sugars_100g"))
    out = {"nutriscore_group": group, "nutriscore_calc": np.nan, "nutriscore_score_calc": np.nan,
           "nutriscore_confidence": "", "nutriscore_notes": ""}
    notes = []

    if group == "water":
        out.update(nutriscore_calc="A", nutriscore_score_calc=-1, nutriscore_confidence="high")
        return out
    if group == "fats_nuts":
        out["nutriscore_notes"] = "fats_nuts_not_computed"
        return out
    if r.get("scorable") is False:
        out["nutriscore_notes"] = "not_scorable"
        return out

    kcal, sat = r.get("energy_kcal_100g"), r.get("saturated_fat_100g")
    sug, pro = r.get("sugars_100g"), r.get("proteins_100g")
    salt, sodium = r.get("salt_100g"), r.get("sodium_100g")
    fib = r.get("fiber_100g")
    if pd.isna(salt) and not pd.isna(sodium):
        salt = sodium * 2.5
    if any(pd.isna(x) for x in (kcal, sat, sug, pro, salt)):
        out["nutriscore_notes"] = "missing_inputs"
        return out

    kj = kcal * 4.184
    if pd.isna(fib):
        fib = 0.0
        notes.append("fiber_assumed_0")
    text = r.get("ingredients_text")
    has_text = isinstance(text, str)
    fvl_possible = has_text and bool(FVL_WORDS.search(tr_lower(text)))
    if fvl_possible:
        notes.append("fvl_may_be_missing")

    if group == "beverage":
        n_pts = pts(kj, E_BEV) + pts(sug, SUG_BEV) + pts(sat, SAT) + pts(salt, SALT)
        if has_text and SWEETENER.search(tr_lower(text)):
            n_pts += 4
            notes.append("sweetener")
        elif not has_text and sug <= 0.5:
            notes.append("sweetener_unknown")
        p_pts = pts(pro, PROT_BEV) + pts(fib, FIB)
        score = n_pts - p_pts
        grade = grade_beverage(score)
    else:
        n_pts = pts(kj, E_GEN) + pts(sug, SUG_GEN) + pts(sat, SAT) + pts(salt, SALT)
        prot_pts = pts(pro, PROT)
        if RED_MEAT.search(cats):
            prot_pts = min(prot_pts, 2)
        fib_pts = pts(fib, FIB)
        is_cheese = "en:cheeses" in tag_set(cats_raw)
        if n_pts >= 11 and not is_cheese:
            score = n_pts - fib_pts
        else:
            score = n_pts - (prot_pts + fib_pts)
        grade = grade_food(score)

    # Dogrulama verisi: guven seviyeleri arasinda uyum farki yok (hepsi ~%94), bu yuzden
    # 'low' sadece gercekten belirsiz durumlara ayrildi.
    if "sweetener_unknown" in notes:
        conf = "low"
    elif "fiber_assumed_0" in notes or "fvl_may_be_missing" in notes or not has_text:
        conf = "medium"
    else:
        conf = "high"
    out.update(nutriscore_calc=grade, nutriscore_score_calc=score,
               nutriscore_confidence=conf, nutriscore_notes=";".join(notes))
    return out


# ------------------------------------------------------------ ISLENMISLIK (NOVA benzeri)
TRACE_SPLIT = re.compile(r"eser miktar|iz miktar|içerebilir|may contain|traces of|peut contenir|kann spuren|kann enthalten")
MARKERS = {
    "emülgatör": r"emülgatör|emulgatör|lesitin|\be47\d\b|emulsifier|émulsifiant|lecithin|lécithine",
    "aroma verici": r"aroma|vanilin|flavou?ring|flavou?rings|\barôme|\barome|vanillin|vanilline",
    "modifiye nişasta": r"modifiye|nişasta sodyum|modified (corn |potato |maize )?starch|amidon modifié",
    "glukoz/fruktoz şurubu": r"glukoz|glikoz|fruktoz|invert şeker|şurub|şurup|izoglukoz|glucose|sirop|fructose|invert sugar|dextrose|sucre inverti",
    "maltodekstrin/dekstroz": r"maltodekstrin|dekstroz|polidekstroz|maltodextrin",
    "hidrojenize yağ": r"hidrojenize|hydrogenated|hydrogéné",
    "tatlandırıcı": r"tatlandırıcı|asesülfam|aspartam|sukraloz|siklamat|sakkarin|steviol|sorbitol|maltitol|sweetener|édulcorant|aspartame|sucralose|acesulfame|saccharin|cyclamate|steviol",
    "renklendirici": r"renklendirici|\be1\d\d\b|colou?ring|colorant|caramel colou?r",
    "koruyucu": r"koruyucu|sorbat|benzoat|propiyonat|nitrit|\be2\d\d\b|preservative|conservateur|sorbate|benzoate|propionate|nitrite",
    "kıvam arttırıcı/stabilizör": r"kıvam art|stabilizör|ksantan|guar gam|karragenan|karboksi|selüloz|aljinat|thickener|épaississant|stabili[sz]er|xanthan|guar gum|carrageenan|carboxymethyl|alginate",
    "asitlik düzenleyici": r"asitlik düzenle|acidity regulator|acidifiant|régulateur d.acidité",
    "antioksidan": r"antioksidan|antioxidant|antioxydant",
    "nem verici": r"nem verici|gliserol|humectant|glycerol|glycérol",
    "aroma arttırıcı": r"aroma arttır|monosodyum|glutamat|\be62\d\b|flavou?r enhancer|monosodium|glutamate|exhausteur",
    "izole süt/protein bileşeni": r"peynir ?altı suyu|süt protein|protein (konsantre|izolat)|kazein|buğday protein|\bwhey|lactosérum|milk protein|protéine de lait|protein (concentrate|isolate)|casein|wheat protein",
}
MARKER_RX = {k: re.compile(v) for k, v in MARKERS.items()}
ADDED = re.compile(r"şeker|\btuz\b|\byağ\b|\byağı\b|\bsirke|\bbal\b|pekmez")
CULINARY_NAME = re.compile(r"\byağ\b|yağı|\btuz\b|şeker|sirke|\bun\b|\bbal\b")


def split_items(text):
    items, depth, cur = [], 0, ""
    for ch in text:
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth = max(depth - 1, 0)
        if ch in ",;." and depth == 0:
            if cur.strip():
                items.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        items.append(cur.strip())
    return items


def processing_estimate(r):
    text = r.get("ingredients_text")
    if not isinstance(text, str):
        return {"nova_estimated": np.nan, "nova_est_confidence": "", "processing_markers": "",
                "processing_marker_count": np.nan}
    t = tr_lower(TRACE_SPLIT.split(text, maxsplit=1)[0])
    found = [k for k, rx in MARKER_RX.items() if rx.search(t)]
    # E-kodu (E100-E1520) de katki isaretidir
    if re.search(r"\be\s?\d{3,4}[a-z]?\b", t) and "e-kodlu katkı" not in found:
        found.append("e-kodlu katkı")
    if found:
        return {"nova_estimated": 4, "nova_est_confidence": "high",
                "processing_markers": "; ".join(found), "processing_marker_count": len(found)}
    n = len(split_items(t))
    name = tr_lower(r.get("name") or "")
    if n <= 1 and not ADDED.search(t):
        level = 2 if CULINARY_NAME.search(name) else 1
    elif n <= 3 and not ADDED.search(t.replace("peynir mayası", "")):
        level = 1
    else:
        level = 3
    return {"nova_estimated": level, "nova_est_confidence": "low",
            "processing_markers": "", "processing_marker_count": 0}


# ------------------------------------------------------------ ANA AKIS
def main():
    df = pd.read_csv(CLEAN, dtype={"code": str})
    raw = pd.read_csv(RAW, dtype=str, usecols=lambda c: c in ("code", "categories_tags", "labels_tags"))
    raw["code"] = raw["code"].str.strip()
    df = df.merge(raw.drop_duplicates("code"), on="code", how="left")

    num_cols = ["energy_kcal_100g", "saturated_fat_100g", "sugars_100g", "proteins_100g",
                "salt_100g", "sodium_100g", "fiber_100g", "nova_group"]
    for c in num_cols:
        df[c] = pd.to_numeric(df[c], errors="coerce")
    df["scorable"] = df["scorable"].astype(str).str.lower().map({"true": True, "false": False}).fillna(True)

    ns = [compute_nutriscore(r, r.get("categories_tags")) for r in df.to_dict("records")]
    df = pd.concat([df, pd.DataFrame(ns, index=df.index)], axis=1)
    pe = pd.DataFrame([processing_estimate(r) for r in df.to_dict("records")], index=df.index)
    df = pd.concat([df, pe], axis=1)

    # --- nihai alanlar
    df["nutriscore_off"] = df["nutriscore_grade"]
    df["nutriscore_final"] = df["nutriscore_calc"].where(df["nutriscore_calc"].notna(), df["nutriscore_off"])
    df["nutriscore_source"] = np.where(df["nutriscore_calc"].notna(), "calculated",
                                       np.where(df["nutriscore_off"].notna(), "off", ""))
    df["nova_off"] = df["nova_group"]
    df["nova_final"] = df["nova_off"].where(df["nova_off"].notna(), df["nova_estimated"])
    df["nova_source"] = np.where(df["nova_off"].notna(), "off",
                                 np.where(df["nova_estimated"].notna(), "estimated", ""))

    df.to_csv(OUT, index=False, encoding="utf-8-sig")

    # ------------------------------------------------------------ RAPOR
    print("===== NUTRI-SCORE =====")
    print("Grup dagilimi:", dict(df["nutriscore_group"].value_counts()))
    print("Hesaplanabilen:", int(df["nutriscore_calc"].notna().sum()), "/", len(df))
    print("Guven:", dict(df.loc[df["nutriscore_calc"].notna(), "nutriscore_confidence"].value_counts()))
    print("\nNihai Nutri-Score doluluk (%), katmana gore:")
    print(df.groupby("tier")["nutriscore_final"].agg(lambda s: round(s.notna().mean() * 100, 1)).to_string())

    both = df[df["nutriscore_calc"].notna() & df["nutriscore_off"].isin(list("ABCDE"))
              & (df["nutriscore_group"].isin(["general", "beverage"]))].copy()
    print(f"\n===== DOGRULAMA (bizim hesap vs OFF, {len(both)} urun) =====")
    if len(both):
        order = {k: i for i, k in enumerate("ABCDE")}
        both["fark"] = (both["nutriscore_calc"].map(order) - both["nutriscore_off"].map(order)).abs()
        print("Birebir ayni      : %.1f%%" % ((both["fark"] == 0).mean() * 100))
        print("En fazla 1 harf   : %.1f%%" % ((both["fark"] <= 1).mean() * 100))
        for g, d in both.groupby("nutriscore_group"):
            print(f"   {g:<10} n={len(d):>5}  ayni=%{(d['fark'] == 0).mean() * 100:.1f}  <=1 harf=%{(d['fark'] <= 1).mean() * 100:.1f}")
        print("   --- guven seviyesine gore ---")
        for g, d in both.groupby("nutriscore_confidence"):
            print(f"   {g:<10} n={len(d):>5}  ayni=%{(d['fark'] == 0).mean() * 100:.1f}  <=1 harf=%{(d['fark'] <= 1).mean() * 100:.1f}")
        print("   --- not bazinda (bir urunde birden fazla not olabilir) ---")
        for note in ["fiber_assumed_0", "fvl_may_be_missing", "sweetener", "sweetener_unknown"]:
            d = both[both["nutriscore_notes"].fillna("").str.contains(note)]
            if len(d):
                print(f"   {note:<20} n={len(d):>5}  ayni=%{(d['fark'] == 0).mean() * 100:.1f}  <=1 harf=%{(d['fark'] <= 1).mean() * 100:.1f}")
        print("\nKarisiklik matrisi (satir: OFF, sutun: bizim):")
        print(pd.crosstab(both["nutriscore_off"], both["nutriscore_calc"]).to_string())
        mm = both[both["fark"] >= 2]
        mm[["code", "name", "nutriscore_off", "nutriscore_calc", "nutriscore_score_calc",
            "nutriscore_group", "nutriscore_notes", "energy_kcal_100g", "saturated_fat_100g",
            "sugars_100g", "salt_100g", "proteins_100g", "fiber_100g"]].to_csv(
            OUT_MISMATCH, index=False, encoding="utf-8-sig")
        print(f"\n2+ harf fark: {len(mm)} urun -> {OUT_MISMATCH}")

    print("\n===== ISLENMISLIK (NOVA) =====")
    print("Kaynak dagilimi:", dict(df["nova_source"].replace("", "yok").value_counts()))
    print("Nihai NOVA doluluk (%), katmana gore:")
    print(df.groupby("tier")["nova_final"].agg(lambda s: round(s.notna().mean() * 100, 1)).to_string())
    print("NOVA dagilimi:", dict(df["nova_final"].value_counts().sort_index()))

    est_vs_off = df[df["nova_off"].notna() & df["nova_estimated"].notna()]
    if len(est_vs_off):
        print(f"\nOFF NOVA ile bizim tahmin ({len(est_vs_off)} urun):")
        print("   Birebir ayni: %.1f%%" % ((est_vs_off["nova_off"] == est_vs_off["nova_estimated"]).mean() * 100))
        print(pd.crosstab(est_vs_off["nova_off"], est_vs_off["nova_estimated"]).to_string())

    print(f"\nDosya: {OUT}")


if __name__ == "__main__":
    main()