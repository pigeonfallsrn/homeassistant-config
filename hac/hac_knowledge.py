#!/usr/bin/env python3
# HAC Knowledge Engine v1.0
# Handles: duplicate detection, dead end management, context slicing
# Called by hac.sh — do not run directly except for testing
# Privacy: reads/writes local files only, no network calls

import sys
import os
import re
import yaml
from datetime import datetime

KNOWLEDGE_FILE = "/homeassistant/hac/knowledge.yaml"
CRITICAL_RULES = "/homeassistant/hac/CRITICAL_RULES.md"


def load_knowledge():
    if not os.path.exists(KNOWLEDGE_FILE):
        return {"meta": {}, "learnings": [], "dead_ends": [], "decisions": []}
    with open(KNOWLEDGE_FILE, "r") as f:
        return yaml.safe_load(f) or {}


def save_knowledge(data):
    with open(KNOWLEDGE_FILE, "w") as f:
        yaml.dump(data, f, default_flow_style=False, allow_unicode=True,
                  sort_keys=False, width=120)


def tokenize(text):
    words = re.findall(r"[a-zA-Z_]{4,}", text.lower())
    stopwords = {"this", "that", "with", "from", "have", "will", "when",
                 "then", "also", "always", "never", "must", "should",
                 "using", "used", "use", "make", "need", "does", "not",
                 "true", "false", "none", "yaml", "home", "assistant"}
    return set(w for w in words if w not in stopwords)


def overlap_score(text_a, text_b):
    tokens_a = tokenize(text_a)
    tokens_b = tokenize(text_b)
    if not tokens_a or not tokens_b:
        return 0.0
    intersection = tokens_a & tokens_b
    union = tokens_a | tokens_b
    return len(intersection) / len(union)


def check_duplicate(category, insight):
    """
    Check if insight is a duplicate of existing learnings.
    Returns list of (score, entry) tuples above threshold, sorted by score desc.
    Threshold: 0.35 (moderate — same category + concept overlap)
    """
    data = load_knowledge()
    category = category.upper()
    matches = []

    for entry in data.get("learnings", []):
        if entry.get("category", "").upper() != category:
            continue
        combined = entry.get("summary", "") + " " + entry.get("detail", "")
        score = overlap_score(insight, combined)
        if score >= 0.35:
            matches.append((score, entry))

    # Also check CRITICAL_RULES for matches regardless of category
    if os.path.exists(CRITICAL_RULES):
        with open(CRITICAL_RULES, "r") as f:
            rules_text = f.read()
        rules_score = overlap_score(insight, rules_text)
        if rules_score >= 0.4:
            matches.append((rules_score, {
                "id": "CRITICAL_RULES",
                "summary": "Already documented in CRITICAL_RULES.md",
                "times_hit": 99,
                "promoted": True
            }))

    matches.sort(key=lambda x: x[0], reverse=True)
    return matches[:3]


def add_learning(category, insight, detail=""):
    """Add new structured entry to knowledge.yaml"""
    data = load_knowledge()
    category = category.upper()
    today = datetime.now().strftime("%Y-%m-%d")

    # Generate ID from category + first meaningful words
    words = re.findall(r"[a-zA-Z]{4,}", insight.lower())[:4]
    entry_id = category.lower() + "_" + "_".join(words)

    # Check if ID already exists, append date if so
    existing_ids = [e.get("id", "") for e in data.get("learnings", [])]
    if entry_id in existing_ids:
        entry_id = entry_id + "_" + datetime.now().strftime("%m%d")

    new_entry = {
        "id": entry_id,
        "category": category,
        "times_hit": 1,
        "discovered": today,
        "promoted": False,
        "status": "active",
        "summary": insight,
        "detail": detail if detail else insight,
        "affects": [],
        "tags": words[:4]
    }

    if "learnings" not in data:
        data["learnings"] = []
    data["learnings"].append(new_entry)
    save_knowledge(data)
    return entry_id


def increment_times_hit(entry_id):
    """Increment times_hit counter on existing entry"""
    data = load_knowledge()
    for entry in data.get("learnings", []):
        if entry.get("id") == entry_id:
            entry["times_hit"] = entry.get("times_hit", 1) + 1
            save_knowledge(data)
            return entry["times_hit"]
    return None


def resolve_dead_end(dead_end_id, resolution):
    """Mark a dead end as resolved"""
    data = load_knowledge()
    today = datetime.now().strftime("%Y-%m-%d")
    for de in data.get("dead_ends", []):
        if de.get("id") == dead_end_id:
            de["status"] = "resolved"
            de["resolved"] = today
            de["resolution"] = resolution
            save_knowledge(data)
            return True
    return False


def add_dead_end(dead_end_id, summary, method, result, next_hypothesis=""):
    """Add new dead end or append attempt to existing"""
    data = load_knowledge()
    today = datetime.now().strftime("%Y-%m-%d")

    attempt = {"date": today, "method": method, "result": result}

    for de in data.get("dead_ends", []):
        if de.get("id") == dead_end_id:
            if "attempts" not in de:
                de["attempts"] = []
            de["attempts"].append(attempt)
            if next_hypothesis:
                de["next_hypothesis"] = next_hypothesis
            save_knowledge(data)
            return "appended"

    new_de = {
        "id": dead_end_id,
        "status": "active",
        "summary": summary,
        "attempts": [attempt]
    }
    if next_hypothesis:
        new_de["next_hypothesis"] = next_hypothesis

    if "dead_ends" not in data:
        data["dead_ends"] = []
    data["dead_ends"].append(new_de)
    save_knowledge(data)
    return "created"


def list_dead_ends(status_filter="active"):
    """List dead ends, optionally filtered by status"""
    data = load_knowledge()
    results = []
    for de in data.get("dead_ends", []):
        if status_filter == "all" or de.get("status") == status_filter:
            results.append(de)
    return results


def generate_slice(task_keyword):
    """
    Generate a minimal context slice for a given task keyword.
    Returns dict with relevant learnings, active dead ends, decisions.
    Privacy: returns structural/behavioral knowledge only — no states, IPs, names.
    """
    data = load_knowledge()
    keyword = task_keyword.lower()

    # Map keywords to categories + tags
    keyword_map = {
        "dashboard": ["DASHBOARD", "HACS", "YAML"],
        "motion": ["MOTION"],
        "inovelli": ["INOVELLI"],
        "lighting": ["INOVELLI", "AL", "MOTION"],
        "presence": ["PRESENCE", "ENTITY"],
        "kitchen": ["DASHBOARD", "MOTION", "AUDIO"],
        "notify": ["ENTITY"],
        "audio": ["AUDIO"],
        "music": ["AUDIO"],
        "matter": ["MATTER"],
        "yaml": ["YAML"],
        "terminal": ["TERMINAL"],
        "backup": ["DASHBOARD", "HAC"],
        "garage": ["MOTION", "ENTITY"],
    }

    relevant_categories = keyword_map.get(keyword, [])

    # If no map hit, fall back to tag/summary search
    relevant_learnings = []
    for entry in data.get("learnings", []):
        if entry.get("status") != "active":
            continue
        matched = False
        if entry.get("category") in relevant_categories:
            matched = True
        if not matched:
            tags = " ".join(entry.get("tags", []))
            summary = entry.get("summary", "")
            if keyword in tags.lower() or keyword in summary.lower():
                matched = True
        if matched:
            relevant_learnings.append({
                "id": entry["id"],
                "category": entry["category"],
                "summary": entry["summary"],
                "times_hit": entry.get("times_hit", 1),
                "promoted": entry.get("promoted", False)
            })

    # Active dead ends only — filter to relevant categories
    relevant_dead_ends = []
    for de in data.get("dead_ends", []):
        if de.get("status") != "active":
            continue
        summary = de.get("summary", "")
        if keyword in summary.lower() or not relevant_categories:
            relevant_dead_ends.append({
                "id": de["id"],
                "summary": de["summary"],
                "next_hypothesis": de.get("next_hypothesis", "")
            })

    # Promote-flagged learnings always included (high signal)
    promoted = [e for e in relevant_learnings if e.get("promoted")]
    unpromoted = [e for e in relevant_learnings if not e.get("promoted")]

    return {
        "task": task_keyword,
        "generated": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "promoted_learnings": promoted,
        "additional_learnings": unpromoted,
        "active_dead_ends": relevant_dead_ends,
        "total_entries": len(relevant_learnings),
        "note": "Slice contains structural/behavioral knowledge only — no live states or PII"
    }


def get_promote_candidates():
    """Return learnings with times_hit >= 3 and promoted=False"""
    data = load_knowledge()
    candidates = []
    for entry in data.get("learnings", []):
        if entry.get("times_hit", 0) >= 3 and not entry.get("promoted", False):
            candidates.append(entry)
    candidates.sort(key=lambda x: x.get("times_hit", 0), reverse=True)
    return candidates


def get_stats():
    """Summary stats for hac close report"""
    data = load_knowledge()
    learnings = data.get("learnings", [])
    dead_ends = data.get("dead_ends", [])
    active_de = [d for d in dead_ends if d.get("status") == "active"]
    resolved_de = [d for d in dead_ends if d.get("status") == "resolved"]
    promoted = [e for e in learnings if e.get("promoted")]
    candidates = get_promote_candidates()
    categories = {}
    for e in learnings:
        cat = e.get("category", "GENERAL")
        categories[cat] = categories.get(cat, 0) + 1
    return {
        "total_learnings": len(learnings),
        "promoted": len(promoted),
        "unpromoted": len(learnings) - len(promoted),
        "promote_candidates": len(candidates),
        "active_dead_ends": len(active_de),
        "resolved_dead_ends": len(resolved_de),
        "categories": categories
    }


# ── CLI interface (called from hac.sh) ───────────────────────────────────────

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "help"

    if cmd == "check_duplicate":
        category = sys.argv[2] if len(sys.argv) > 2 else "GENERAL"
        insight = sys.argv[3] if len(sys.argv) > 3 else ""
        matches = check_duplicate(category, insight)
        if matches:
            print("DUPLICATE_FOUND")
            for score, entry in matches:
                pct = int(score * 100)
                promoted_flag = " [in CRITICAL_RULES]" if entry.get("promoted") else ""
                times = entry.get("times_hit", 1)
                print(f"  {pct}% match — {entry.get('id')}{promoted_flag} (hit {times}x)")
                print(f"  → {entry.get('summary', '')[:80]}")
        else:
            print("NO_DUPLICATE")

    elif cmd == "add_learning":
        category = sys.argv[2] if len(sys.argv) > 2 else "GENERAL"
        insight = sys.argv[3] if len(sys.argv) > 3 else ""
        detail = sys.argv[4] if len(sys.argv) > 4 else ""
        entry_id = add_learning(category, insight, detail)
        print(f"ADDED:{entry_id}")

    elif cmd == "add_dead_end":
        # args: id summary method result [next_hypothesis]
        de_id = sys.argv[2] if len(sys.argv) > 2 else ""
        summary = sys.argv[3] if len(sys.argv) > 3 else ""
        method = sys.argv[4] if len(sys.argv) > 4 else ""
        result = sys.argv[5] if len(sys.argv) > 5 else ""
        hypothesis = sys.argv[6] if len(sys.argv) > 6 else ""
        action = add_dead_end(de_id, summary, method, result, hypothesis)
        print(f"DEAD_END_{action.upper()}:{de_id}")

    elif cmd == "resolve_dead_end":
        de_id = sys.argv[2] if len(sys.argv) > 2 else ""
        resolution = sys.argv[3] if len(sys.argv) > 3 else ""
        ok = resolve_dead_end(de_id, resolution)
        print("RESOLVED" if ok else "NOT_FOUND")

    elif cmd == "list_dead_ends":
        status = sys.argv[2] if len(sys.argv) > 2 else "active"
        items = list_dead_ends(status)
        if not items:
            print(f"No {status} dead ends.")
        else:
            for de in items:
                attempts = len(de.get("attempts", []))
                nh = de.get("next_hypothesis", "")
                print(f"  [{de.get('status','?').upper()}] {de['id']}")
                print(f"    {de.get('summary','')[:70]}")
                print(f"    Attempts: {attempts}" + (f" | Next: {nh[:50]}" if nh else ""))

    elif cmd == "slice":
        keyword = sys.argv[2] if len(sys.argv) > 2 else "general"
        result = generate_slice(keyword)
        print(f"# HAC Context Slice: {result['task']} ({result['generated']})")
        print(f"# {result['note']}")
        print(f"# Entries: {result['total_entries']} | Dead ends: {len(result['active_dead_ends'])}")
        print()
        if result["promoted_learnings"]:
            print("## Promoted (in CRITICAL_RULES)")
            for e in result["promoted_learnings"]:
                print(f"  [{e['category']}] {e['summary'][:70]} (hit {e['times_hit']}x)")
        if result["additional_learnings"]:
            print("## Additional")
            for e in result["additional_learnings"]:
                print(f"  [{e['category']}] {e['summary'][:70]}")
        if result["active_dead_ends"]:
            print("## Active dead ends")
            for de in result["active_dead_ends"]:
                print(f"  ✗ {de['id']}: {de['summary'][:60]}")
                if de.get("next_hypothesis"):
                    print(f"    → {de['next_hypothesis'][:60]}")

    elif cmd == "promote_candidates":
        candidates = get_promote_candidates()
        if not candidates:
            print("No candidates (all entries with 3+ hits are already promoted)")
        else:
            for c in candidates:
                print(f"  [{c['category']}] hit {c['times_hit']}x — {c['id']}")
                print(f"    {c['summary'][:70]}")

    elif cmd == "stats":
        stats = get_stats()
        print(f"  Learnings: {stats['total_learnings']} total "
              f"({stats['promoted']} promoted, {stats['unpromoted']} unpromoted)")
        print(f"  Promote candidates: {stats['promote_candidates']}")
        print(f"  Dead ends: {stats['active_dead_ends']} active, "
              f"{stats['resolved_dead_ends']} resolved")
        print(f"  Categories: " + ", ".join(f"{k}:{v}" for k, v in stats["categories"].items()))

    else:
        print("Usage: hac_knowledge.py <cmd> [args]")
        print("Commands: check_duplicate, add_learning, add_dead_end,")
        print("          resolve_dead_end, list_dead_ends, slice,")
        print("          promote_candidates, stats")
