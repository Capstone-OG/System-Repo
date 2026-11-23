
#!/usr/bin/env python3
"""
V-Eval Automated Question Bank Seeder (All 9 Subjects, Grades 10-12, All Patterns)
- Reads GEMINI_API_KEY from .env
- Fetches all skills (patterns) from V-Eval Content Service (http://localhost:5249)
- For each skill with < TARGET questions (default 10), calls Gemini API (gemini-2.5-flash)
  to generate the missing unique, curriculum-aligned multiple-choice questions (Bloom L1-L4)
- Persists directly via POST /api/content/questions (zero direct SQL hacks)
- Fully resumable: automatically skips any skill that already has >= TARGET questions.

Usage:
  python Scripts/seed_questions_batch.py --target 10 --concurrency 4
  python Scripts/seed_questions_batch.py --subject "Ngữ văn" --target 10
  python Scripts/seed_questions_batch.py --limit 5 --target 10   # quick test on 5 skills
"""

import argparse
import concurrent.futures
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
DEFAULT_BASE_URL = "http://localhost:5249"
GEMINI_MODELS = ["gemini-3.6-flash", "gemini-3.8-flash", "gemini-2.5-flash-lite"]


def load_gemini_api_key() -> str:
    env_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if env_key:
        return env_key.strip().strip('"').strip("'")

    candidates = [
        ROOT_DIR / "All Services" / "V-Eval-Ai_Engine" / "rag-service" / ".env",
        ROOT_DIR / ".env",
    ]
    for path in candidates:
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            if k.strip() in ("GOOGLE_API_KEY", "GEMINI_API_KEY"):
                val = v.strip().strip('"').strip("'")
                if val and not val.lower().startswith("your_") and "placeholder" not in val.lower():
                    return val
    raise RuntimeError("Khong tim thay GEMINI_API_KEY trong bien moi truong hoac file .env!")


def http_json(method: str, url: str, payload=None, timeout: int = 45):
    data = json.dumps(payload, ensure_ascii=False).encode("utf-8") if payload is not None else None
    headers = {"Accept": "application/json"}
    if data is not None:
        headers["Content-Type"] = "application/json; charset=utf-8"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        raw = resp.read().decode("utf-8", errors="replace")
        return json.loads(raw) if raw.strip() else {}


def fetch_all_skills(base_url: str) -> list[dict]:
    data = http_json("GET", f"{base_url}/api/content/curriculum", timeout=30)
    domains = data if isinstance(data, list) else (data.get("domains") or data.get("data") or [])
    skills = []
    seen = set()
    for dom in domains:
        dom_name = dom.get("title") or dom.get("name") or ""
        for ch in dom.get("chapters") or []:
            ch_name = ch.get("name") or ""
            for les in ch.get("lessons") or []:
                les_name = les.get("name") or ""
                for pat in les.get("patterns") or []:
                    sid = str(pat.get("patternId") or pat.get("skillId") or pat.get("id") or "").strip()
                    if not sid or sid in seen:
                        continue
                    seen.add(sid)
                    skills.append({
                        "skillId": sid,
                        "skillName": pat.get("name") or "Kỹ năng chuyên đề",
                        "lessonName": les_name,
                        "chapterName": ch_name,
                        "domainName": dom_name,
                    })
    return skills


def fetch_existing_questions(base_url: str, skill_id: str) -> list[dict]:
    try:
        data = http_json("GET", f"{base_url}/api/content/questions/by-skill/{skill_id}", timeout=20)
        if isinstance(data, list):
            return data
        return data.get("questions") or data.get("items") or []
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return []
        raise


def normalize_text(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "").strip()).lower()


def generate_questions_with_gemini(api_key: str, skill: dict, count: int, existing_stems: list[str]) -> list[dict]:
    is_english = "tiếng anh" in f"{skill['chapterName']} {skill['domainName']} {skill['skillName']}".lower()
    lang_rule = (
        "Viết câu hỏi và 4 phương án A/B/C/D bằng Tiếng Anh chuẩn thi ĐGNL V-ACT, lời giải (explanation) bằng Tiếng Việt ngắn gọn."
        if is_english
        else "Viết 100% bằng Tiếng Việt chuẩn SGK GDPT 2018 và đề ĐGNL ĐHQG TP.HCM (V-ACT)."
    )
    existing_sample = "\n".join(f"- {s[:120]}" for s in existing_stems[:6])
    avoid_block = f"\nTuyệt đối KHÔNG lặp lại ý với các câu đã có sau:\n{existing_sample}\n" if existing_sample else ""

    prompt = f"""Bạn là chuyên gia ra đề thi Đánh giá Năng lực ĐHQG TP.HCM (V-ACT) chuẩn chương trình GDPT 2018.
Hãy tạo đúng {count} câu hỏi trắc nghiệm ĐỘC LẬP (tự đủ ngữ cảnh trong thân câu hỏi, KHÔNG nhắc "đoạn văn trên" hay "bài đọc trên") cho dạng bài sau:
- Lĩnh vực: {skill['domainName']}
- Chương: {skill['chapterName']}
- Bài học: {skill['lessonName']}
- Dạng bài (Skill): {skill['skillName']}

Yêu cầu bắt buộc:
1. {lang_rule}
2. Phân bổ độ khó Bloom (`difficultyLevel` từ 1 đến 4: 1=Nhận biết, 2=Thông hiểu, 3=Vận dụng, 4=Vận dụng cao).
3. Nếu có công thức Toán/Lý/Hóa thì bọc bằng `$...$` chuẩn LaTeX, không có dấu `$` lẻ.
4. Mỗi câu có đúng 4 phương án `optionA`, `optionB`, `optionC`, `optionD` khác nhau hoàn toàn, chỉ 1 đáp án đúng duy nhất (`correctOption` là "A", "B", "C" hoặc "D") và `explanation` giải thích ngắn gọn, chính xác.
5. Các câu hỏi phải đa dạng góc hỏi, không trùng lặp nhau.{avoid_block}
Trả về JSON array hợp lệ theo đúng cấu trúc:
[
  {{
    "difficultyLevel": 2,
    "contentLatex": "...",
    "optionA": "...",
    "optionB": "...",
    "optionC": "...",
    "optionD": "...",
    "correctOption": "A",
    "explanation": "..."
  }}
]"""

    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.75,
            "responseMimeType": "application/json",
        },
    }

    last_err = None
    for model_name in GEMINI_MODELS:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={urllib.parse.quote(api_key)}"
        for attempt in range(2):
            try:
                res = http_json("POST", url, payload=payload, timeout=60)
                text = res["candidates"][0]["content"]["parts"][0]["text"]
                parsed = json.loads(text)
                if isinstance(parsed, dict):
                    parsed = parsed.get("questions") or parsed.get("items") or []
                if isinstance(parsed, list):
                    return parsed
            except urllib.error.HTTPError as e:
                err_body = ""
                try:
                    err_body = e.read().decode("utf-8", errors="ignore")[:240]
                except Exception:
                    pass
                last_err = f"{model_name} HTTP {e.code}: {err_body}"
                if e.code == 404:
                    break  # try next model immediately
                if e.code in (429, 500, 503):
                    time.sleep(2.0 * (attempt + 1))
                    continue
                raise RuntimeError(last_err)
            except Exception as e:
                last_err = f"{model_name}: {e}"
                time.sleep(1.5)
    raise RuntimeError(f"Gemini failed across models: {last_err}")


def process_skill(api_key: str, base_url: str, skill: dict, target: int, delay: float) -> tuple[str, int, int, str]:
    sid = skill["skillId"]
    existing = fetch_existing_questions(base_url, sid)
    existing_count = len(existing)
    if existing_count >= target:
        return (sid, existing_count, 0, "SKIP")

    needed = target - existing_count
    seen_stems = {normalize_text(q.get("contentLatex") or q.get("content") or "") for q in existing}
    existing_stems = [q.get("contentLatex") or q.get("content") or "" for q in existing]

    generated = generate_questions_with_gemini(api_key, skill, needed, existing_stems)
    inserted = 0
    for q in generated:
        stem = (q.get("contentLatex") or "").strip()
        norm = normalize_text(stem)
        opt_a = (q.get("optionA") or "").strip()
        opt_b = (q.get("optionB") or "").strip()
        opt_c = (q.get("optionC") or "").strip()
        opt_d = (q.get("optionD") or "").strip()
        correct = (q.get("correctOption") or "").strip().upper()
        if not stem or norm in seen_stems or not all([opt_a, opt_b, opt_c, opt_d]) or correct not in ("A", "B", "C", "D"):
            continue
        diff = int(q.get("difficultyLevel") or 2)
        diff = max(1, min(6, diff))
        body = {
            "skillId": sid,
            "passageId": None,
            "difficultyLevel": diff,
            "contentLatex": stem,
            "optionA": opt_a,
            "optionB": opt_b,
            "optionC": opt_c,
            "optionD": opt_d,
            "correctOption": correct,
            "explanation": (q.get("explanation") or "").strip() or "Áp dụng kiến thức trọng tâm của dạng bài.",
        }
        try:
            http_json("POST", f"{base_url}/api/content/questions", payload=body, timeout=20)
            seen_stems.add(norm)
            inserted += 1
        except Exception:
            continue

    if delay > 0:
        time.sleep(delay)
    return (sid, existing_count, inserted, "OK")


def main():
    parser = argparse.ArgumentParser(description="Batch AI Question Bank Seeder for V-Eval")
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL, help="Content Service base URL (default: http://localhost:5249)")
    parser.add_argument("--target", type=int, default=10, help="Target minimum questions per skill (default: 10)")
    parser.add_argument("--concurrency", type=int, default=4, help="Parallel workers (default: 4)")
    parser.add_argument("--subject", default="", help="Optional substring filter by subject/chapter/domain (e.g. 'Ngữ văn')")
    parser.add_argument("--limit", type=int, default=0, help="Optional limit number of skills to process (0 = all)")
    parser.add_argument("--delay", type=float, default=0.4, help="Delay between requests per worker (seconds)")
    args = parser.parse_args()

    api_key = load_gemini_api_key()
    print(f"[INFO] Loading curriculum from {args.base_url} ...")
    skills = fetch_all_skills(args.base_url)

    if args.subject:
        needle = args.subject.strip().lower()
        skills = [
            s for s in skills
            if needle in f"{s['domainName']} {s['chapterName']} {s['lessonName']} {s['skillName']}".lower()
        ]

    if args.limit > 0:
        skills = skills[: args.limit]

    total = len(skills)
    print(f"[INFO] Found {total} skills to check/seed (target >= {args.target} questions/skill, workers={args.concurrency}).")
    if total == 0:
        return

    done = 0
    total_inserted = 0
    skipped = 0
    failed = 0
    t0 = time.time()

    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.concurrency)) as pool:
        future_map = {
            pool.submit(process_skill, api_key, args.base_url, sk, args.target, args.delay): sk
            for sk in skills
        }
        for fut in concurrent.futures.as_completed(future_map):
            sk = future_map[fut]
            done += 1
            try:
                _, prev_cnt, ins, status = fut.result()
                total_inserted += ins
                if status == "SKIP":
                    skipped += 1
                else:
                    print(f"[{done}/{total}] +{ins} (had {prev_cnt}) | {sk['chapterName'][:32]} | {sk['skillName'][:48]}", flush=True)
            except Exception as e:
                failed += 1
                print(f"[{done}/{total}] [ERR] {sk['skillName'][:45]} -> {e}", flush=True)

            if done % 25 == 0 or done == total:
                elapsed = time.time() - t0
                print(
                    f"--- PROGRESS {done}/{total} | inserted={total_inserted} | skipped={skipped} | failed={failed} | {elapsed:.1f}s ---",
                    flush=True,
                )

    print(f"[DONE] Completed {total} skills: +{total_inserted} new questions inserted, {skipped} already >= {args.target}, {failed} errors.")


if __name__ == "__main__":
    main()
