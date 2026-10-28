import json
rows = [json.loads(l) for l in open("off_enriched.jsonl", encoding="utf-8") if l.strip()]
nf = sum(1 for r in rows if r.get("_not_found"))
print("dosyadaki satır:", len(rows), "| bulunamayan:", nf, "| başarılı:", len(rows) - nf)