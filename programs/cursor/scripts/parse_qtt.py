#!/usr/bin/env python3
"""Parse Notion QTT query result: filter, sort, output top N tickets."""
import json
import sys

path = sys.argv[1] if len(sys.argv) > 1 else "/home/romain/.cursor/projects/home-romain-Stockly-Main/agent-tools/fe8a5638-c5b5-47a7-be52-f466588596b6.txt"
with open(path) as f:
    d = json.load(f)

pages = d.get("results", [])
SEVERITY_ORDER = {"SEV1": 0, "SEV2": 1, "SEV3": 2, "SEV4": 3, "SEV5": 4}

def get_title(props):
    for key, v in props.items():
        if isinstance(v, dict) and v.get("type") == "title" and "title" in v and isinstance(v["title"], list):
            if v["title"] and isinstance(v["title"][0], dict):
                return (v["title"][0].get("plain_text") or "").strip()
    for key in ("Name", "Title", "title"):
        if key in props:
            t = props[key]
            if isinstance(t, dict) and "title" in t and isinstance(t["title"], list):
                if t["title"] and isinstance(t["title"][0], dict):
                    return (t["title"][0].get("plain_text") or "").strip()
    return ""

def get_assignee(props):
    a = props.get("Assignee") or props.get("assignee") or {}
    if isinstance(a, dict) and "people" in a:
        return a["people"]
    return []

def get_teams_intl(props):
    t = props.get("Teams Intl") or props.get("teams_intl") or {}
    if isinstance(t, dict) and "multi_select" in t:
        return [o.get("name") or o.get("id") for o in (t["multi_select"] or [])]
    return []

def get_status_intl(props):
    s = props.get("Status Intl") or props.get("status_intl") or {}
    if isinstance(s, dict) and "select" in s and s["select"]:
        return (s["select"].get("name") or "").strip()
    return ""

def get_severity(props):
    s = props.get("Severity") or props.get("severity")
    if not isinstance(s, dict) or "select" not in s or not s["select"]:
        for v in props.values():
            if isinstance(v, dict) and v.get("type") == "select" and (v.get("select") or {}).get("name", "").upper().startswith("SEV"):
                return (v["select"].get("name") or "").strip()
        return ""
    return (s["select"].get("name") or "").strip()


def severity_rank(sev_value):
    """Lower number = higher priority. SEV1=0, SEV2=1, ..., SEV5=4. Handles 'SEV4', 'Sev4', '4'."""
    if not sev_value:
        return 5
    s = str(sev_value).upper().strip()
    if s in SEVERITY_ORDER:
        return SEVERITY_ORDER[s]
    if s.isdigit() and 1 <= int(s) <= 5:
        return int(s) - 1
    for k, v in SEVERITY_ORDER.items():
        if k in s or s in k:
            return v
    return 5

def get_updated(props):
    u = props.get("Updated At") or props.get("updated_at") or props.get("Last edited time") or {}
    if isinstance(u, dict) and "last_edited_time" in u:
        return u["last_edited_time"]
    if isinstance(u, dict) and "date" in u and u["date"] and "start" in u["date"]:
        return u["date"]["start"]
    return ""

# Filter: Status Intl = Pending workforce only; assignee empty; Teams Intl not "Partner Inputs_Front"
PENDING_WORKFORCE = "0 - Pending Workforce"

def is_pending_workforce(status_intl_value):
    if not status_intl_value:
        return False
    return "Pending" in status_intl_value and "Workforce" in status_intl_value

candidates = []
for p in pages:
    props = p.get("properties", {})
    if not is_pending_workforce(get_status_intl(props)):
        continue
    if get_assignee(props):
        continue
    teams = get_teams_intl(props)
    if "Partner Inputs_Front" in teams:
        continue
    title = get_title(props) or "(no title)"
    short_id = title[:5] if len(title) >= 5 else ""
    candidates.append({
        "id": p.get("id"),
        "url": p.get("url"),
        "title": title,
        "short_id": short_id,
        "severity": get_severity(props),
        "updated": get_updated(props),
        "props": props,
    })

# Sort: Severity (SEV1 first, SEV4 before SEV5), then Updated descending
from datetime import datetime

def sort_key(c):
    rank = severity_rank(c["severity"])
    ts = c["updated"] or ""
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        return (rank, -dt.timestamp())
    except Exception:
        return (rank, 0)

candidates.sort(key=sort_key)

# Top N (default 3) from parser argv
n = int(sys.argv[2]) if len(sys.argv) > 2 else 3
top = candidates[:n]
print(f"candidates_count={len(candidates)}", file=sys.stderr)
for i, t in enumerate(top):
    # Fallback title from URL slug (e.g. RR5BW-UPS-TI-status-...)
    title = t["title"] or t["url"].split("/")[-1].replace("-", " ")[:80]
    short_id = (t["title"] or "")[:5] if len(t["title"] or "") >= 5 else (t["url"].split("/")[-1][:5] if t["url"] else "")
    print(f"{i+1}|{t['id']}|{t['url']}|{title[:80]}|{short_id}")
