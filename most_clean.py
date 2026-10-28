import pandas as pd
df = pd.read_csv("products_scored.csv", dtype={"code": str})
a = df[df["tier"] == "A"]
a.to_csv("products_final.csv", index=False, encoding="utf-8-sig")
print(len(a), "ürün kaydedildi")