"""Builds assets/data/course.json from the content modules and checks it.

Run from the project root:  python tool/build_course.py
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import content_glossary as g  # noqa: E402
import content_lessons_a as a  # noqa: E402
import content_lessons_b as b  # noqa: E402
import content_library as lib  # noqa: E402

LABS = {"chits", "doubling", "circulation", "machines"}

course = {
    "modules": a.modules,
    "lessons": a.lessons + b.lessons,
    "glossaryTerms": g.terms,
    "glossaryCategories": g.categories,
    "sourceParts": lib.source_parts,
    "companionTexts": lib.companion_texts,
    "downloads": lib.downloads,
}

errors = []
ids = [l["id"] for l in course["lessons"]]
module_ids = {m["id"] for m in course["modules"]}
if len(ids) != len(set(ids)):
    errors.append("duplicate lesson ids")
for n, lesson in enumerate(course["lessons"], 1):
    where = lesson["id"]
    if lesson["number"] != n:
        errors.append(f"{where}: number {lesson['number']} != {n}")
    if lesson["moduleId"] not in module_ids:
        errors.append(f"{where}: unknown module")
    if lesson.get("lab") and lesson["lab"] not in LABS:
        errors.append(f"{where}: unknown lab")
    for q in lesson["quiz"]:
        if not 0 <= q["answer"] < len(q["options"]):
            errors.append(f"{where}: answer out of range")
    for key in ("source", "furtherReading"):
        if key in lesson and not lesson[key]["url"].startswith("https://"):
            errors.append(f"{where}: bad {key} url")
for t in course["glossaryTerms"]:
    if t["lessonId"] not in ids:
        errors.append(f"term {t['term']}: unknown lesson {t['lessonId']}")
    if t["category"] not in course["glossaryCategories"]:
        errors.append(f"term {t['term']}: unknown category")
seen = set()
for part in course["sourceParts"]:
    pages = [p["page"] for p in part["passages"]]
    if pages != sorted(pages):
        errors.append(f"part {part['id']}: pages out of order")
    for p in part["passages"]:
        key = (p["page"], p["title"])
        if key in seen:
            errors.append(f"duplicate passage {key}")
        seen.add(key)
if errors:
    sys.exit("\n".join(errors))

out = os.path.join(HERE, "..", "assets", "data", "course.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump(course, f, ensure_ascii=False, separators=(",", ":"))
answers = [q["answer"] for l in course["lessons"] for q in l["quiz"]]
print(len(ids), "lessons,", len(course["modules"]), "modules,", len(g.terms), "terms,",
      sum(len(p["passages"]) for p in course["sourceParts"]), "passages,",
      "answer spread", {i: answers.count(i) for i in range(4)})
