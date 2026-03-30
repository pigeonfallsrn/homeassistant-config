#!/usr/bin/env python3
import json, sys
from datetime import datetime, timezone, timedelta

try:
    with open(sys.argv[1]) as f:
        states = json.load(f)
    automations = [s for s in states if s["entity_id"].startswith("automation.")]
    never, stale_30, stale_7 = [], [], []
    now = datetime.now(timezone.utc)
    cutoff_30 = now - timedelta(days=30)
    cutoff_7 = now - timedelta(days=7)
    for a in automations:
        lt = a["attributes"].get("last_triggered")
        name = a["attributes"].get("friendly_name", a["entity_id"])
        if not lt:
            never.append(name)
        else:
            try:
                ts = datetime.fromisoformat(lt.replace("Z","+00:00"))
                if ts < cutoff_30: stale_30.append((name, ts.strftime("%Y-%m-%d")))
                elif ts < cutoff_7: stale_7.append((name, ts.strftime("%Y-%m-%d")))
            except: never.append(name)
    print(f"  Never triggered: {len(never)}")
    for n in sorted(never)[:10]: print(f"    ⚠ {n}")
    if len(never) > 10: print(f"    ... and {len(never)-10} more")
    print(f"  Not triggered >30d: {len(stale_30)}")
    for n,d in sorted(stale_30)[:5]: print(f"    ○ {n} (last: {d})")
    if len(stale_30) > 5: print(f"    ... and {len(stale_30)-5} more")
    print(f"  Not triggered 7-30d: {len(stale_7)}")
except Exception as e:
    print(f"  Error: {e}")
