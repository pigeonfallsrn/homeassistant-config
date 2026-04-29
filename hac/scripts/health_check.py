#!/usr/bin/env python3
"""HA Health Check — S70 build. Terse summary to stdout, detail to /config/hac/health_check_detail.txt."""
import json, os, re, subprocess, sys, time, shutil
try:
    import yaml
except ImportError:
    yaml = None
from datetime import datetime, timezone
from urllib.request import Request, urlopen
from urllib.error import URLError

CFG = "/config"
HAC = "/config/hac"
DETAIL = f"{HAC}/health_check_detail.txt"
LAST_RUN = f"{HAC}/.last_health_check"
HANDOFF = f"{CFG}/HANDOFF.md"
DB = f"{CFG}/home-assistant_v2.db"
LOG = f"{CFG}/home-assistant.log"
AUTOS_YAML = f"{CFG}/automations.yaml"
REPAIRS = f"{CFG}/.storage/repairs.issue_registry"
EREG = f"{CFG}/.storage/core.entity_registry"
DREG = f"{CFG}/.storage/core.device_registry"

TOKEN = os.environ.get("SUPERVISOR_TOKEN", "")
SUP_URL = "http://supervisor/core/api"

DISK_WARN, DISK_CRIT = 85, 95
DB_WARN_GB, DB_CRIT_GB = 1.0, 3.0
PSI_WARN, PSI_CRIT = 10.0, 50.0
UNAVAIL_WARN, UNAVAIL_CRIT = 1, 10
ERRLOG_TAIL = 1000
EXCLUDE_DOMS = {"device_tracker", "person"}
EXCLUDE_RE = re.compile(r"_battery(_|$)")
HELPER_DOMS = {"input_boolean","input_number","input_select","input_text",
               "input_datetime","input_button","timer","counter"}

results, detail_lines = [], []

def add(n, label, status, summary, advisor="", detail=""):
    results.append({"n":n,"label":label,"status":status,"summary":summary,"advisor":advisor})
    if detail:
        detail_lines.append(f"--- [{n}] {label} ---\n{detail}\n")

def fetch(path):
    if not TOKEN:
        return None
    try:
        req = Request(f"{SUP_URL}{path}", headers={"Authorization": f"Bearer {TOKEN}"})
        with urlopen(req, timeout=15) as r:
            return r.read().decode()
    except (URLError, OSError):
        return None

def safe_load(p):
    try:
        with open(p) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return None

# [1] Unavailable entities
def chk_unavail():
    raw = fetch("/states")
    if not raw:
        add(1, "Unavailable entities", "ERR", "could not fetch /states", "verify SUPERVISOR_TOKEN")
        return
    states = json.loads(raw)
    bad = []
    for s in states:
        eid = s["entity_id"]
        if s["state"] not in ("unavailable", "unknown"):
            continue
        dom = eid.split(".",1)[0]
        if dom in EXCLUDE_DOMS or EXCLUDE_RE.search(eid):
            continue
        bad.append(eid)
    n = len(bad)
    if n >= UNAVAIL_CRIT:
        st, adv = "CRIT", "review detail file -> check device connectivity"
    elif n >= UNAVAIL_WARN:
        st, adv = "WARN", "review detail file -> confirm if expected"
    else:
        st, adv = "OK", ""
    add(1, "Unavailable entities", st, f"{n} unavailable", adv,
        "\n".join(sorted(bad)) if bad else "(none)")

# [2] PSI pressure
def read_psi(name):
    try:
        with open(f"/proc/pressure/{name}") as f:
            for line in f:
                if line.startswith("some "):
                    m = re.search(r"avg10=([\d.]+)", line)
                    if m:
                        return float(m.group(1))
    except (OSError, ValueError):
        pass
    return None

def chk_psi():
    parts, detail, worst = [], [], "OK"
    for name in ("cpu","memory","io"):
        v = read_psi(name)
        if v is None:
            parts.append(f"{name}=?")
            detail.append(f"{name}: PSI unreadable")
            continue
        parts.append(f"{name}={v:.1f}")
        detail.append(f"{name}: avg10={v:.2f}")
        if v >= PSI_CRIT:
            worst = "CRIT"
        elif v >= PSI_WARN and worst == "OK":
            worst = "WARN"
    adv = ""
    if worst == "CRIT":
        adv = "system thrashing -- investigate runaway processes"
    elif worst == "WARN":
        adv = "elevated pressure -- check load on EQ14"
    add(2, "CPU/mem/IO pressure", worst, " ".join(parts), adv, "\n".join(detail))

# [3] Disk
def chk_disk():
    try:
        st = shutil.disk_usage("/config")
        pct = (st.used/st.total)*100.0
        free_gb = st.free/1024**3
    except OSError as e:
        add(3, "Disk usage", "ERR", str(e))
        return
    if pct >= DISK_CRIT:
        s, adv = "CRIT", "free space critical -- purge logs/backups"
    elif pct >= DISK_WARN:
        s, adv = "WARN", "review backups + DB retention"
    else:
        s, adv = "OK", ""
    add(3, "Disk usage", s, f"{pct:.0f}% used, {free_gb:.0f}G free", adv,
        f"used={st.used} total={st.total} free={st.free}")

# [4] DB size
def chk_db():
    try:
        b = os.path.getsize(DB)
        gb = b/1024**3
    except OSError as e:
        add(4, "DB size", "ERR", str(e))
        return
    if gb >= DB_CRIT_GB:
        s, adv = "CRIT", "reduce recorder.purge_keep_days, exclude noisy entities"
    elif gb >= DB_WARN_GB:
        s, adv = "WARN", "consider tighter recorder retention"
    else:
        s, adv = "OK", ""
    add(4, "DB size", s, f"{gb:.2f} GB", adv, f"path={DB} bytes={b}")

# [5] Active repairs
def chk_repairs():
    d = safe_load(REPAIRS)
    if d is None:
        add(5, "Active repairs", "OK", "no issue registry yet")
        return
    issues = d.get("data", {}).get("issues", [])
    active = [i for i in issues if not i.get("dismissed_version")]
    n = len(active)
    if n >= 1:
        s, adv = "WARN", "review Settings > System > Repairs"
    else:
        s, adv = "OK", ""
    detail = "\n".join(f"  {i.get('domain','?')} :: {i.get('issue_id','?')} ({i.get('severity','?')})"
                       for i in active) if active else "(none)"
    add(5, "Active repairs", s, f"{n} active", adv, detail)

# [6] Integration setup errors
def chk_int_err():
    if not os.path.exists(LOG):
        add(6, "Integration errors", "OK", "no log file (clean restart)")
        return
    try:
        with open(LOG, errors="replace") as f:
            text = f.read()
    except OSError as e:
        add(6, "Integration errors", "ERR", str(e))
        return
    matches = re.findall(r"(?:Setup failed for|Error setting up entry|Error doing job).{0,200}", text)
    n = len(matches)
    if n >= 1:
        s, adv = "WARN", f"grep '{LOG}' for 'Setup failed'"
    else:
        s, adv = "OK", ""
    add(6, "Integration errors", s, f"{n} setup/job errors in log", adv,
        "\n".join(matches[:10]) if matches else "(none)")

# [7] Recent error_log
def chk_errlog():
    if not os.path.exists(LOG):
        add(7, "Recent error_log", "OK", "no log file")
        return
    try:
        with open(LOG, errors="replace") as f:
            lines = f.readlines()[-ERRLOG_TAIL:]
    except OSError as e:
        add(7, "Recent error_log", "ERR", str(e))
        return
    err = [l for l in lines if " ERROR " in l or " CRITICAL " in l]
    n = len(err)
    if n >= 1:
        s, adv = "WARN", f"tail -n200 {LOG}"
    else:
        s, adv = "OK", ""
    add(7, "Recent error_log", s, f"{n} ERROR/CRIT in last {ERRLOG_TAIL} log lines", adv,
        "".join(err[-10:]) if err else "(none)")

# [8] Double-fire risk (ZHA dupes -- TRIPLE-FIRE project rule)
def chk_double():
    if yaml is None:
        add(8, "Double-fire risk", "ERR", "PyYAML not available")
        return
    try:
        with open(AUTOS_YAML) as f:
            data = yaml.safe_load(f) or []
    except (OSError, yaml.YAMLError) as e:
        add(8, "Double-fire risk", "ERR", str(e))
        return
    if not isinstance(data, list):
        add(8, "Double-fire risk", "ERR", "automations.yaml not a list")
        return
    zha_evt, zha_dev = {}, {}
    for a in data:
        if not isinstance(a, dict): continue
        alias = a.get("alias", a.get("id", "?"))
        triggers = a.get("triggers") or a.get("trigger") or []
        if isinstance(triggers, dict): triggers = [triggers]
        for t in triggers:
            if not isinstance(t, dict): continue
            plat = t.get("platform") or t.get("trigger")
            if plat == "event" and t.get("event_type") == "zha_event":
                ieee = (t.get("event_data") or {}).get("device_ieee")
                if ieee:
                    zha_evt.setdefault(ieee, []).append(alias)
            elif plat == "device" and t.get("domain") == "zha" and t.get("device_id"):
                zha_dev.setdefault(t["device_id"], []).append(alias)
    edupe = {k:sorted(set(v)) for k,v in zha_evt.items() if len(set(v))>1}
    ddupe = {k:sorted(set(v)) for k,v in zha_dev.items() if len(set(v))>1}
    n = len(edupe) + len(ddupe)
    if n >= 1:
        s, adv = "WARN", "delete legacy duplicates -- don't just disable (project rule)"
    else:
        s, adv = "OK", ""
    parts = []
    if edupe:
        parts.append("=== zha_event device_ieee dupes ===")
        for k,v in sorted(edupe.items()):
            parts.append(k)
            parts.extend(f"  {x}" for x in v)
    if ddupe:
        parts.append("=== zha device_id dupes ===")
        for k,v in sorted(ddupe.items()):
            parts.append(k)
            parts.extend(f"  {x}" for x in v)
    add(8, "Double-fire risk", s, f"{n} shared ZHA triggers", adv, "\n".join(parts) or "(none)")

# [9] HANDOFF count drift
def count_autos():
    if yaml is None:
        return None
    try:
        with open(AUTOS_YAML) as f:
            data = yaml.safe_load(f) or []
        return len(data) if isinstance(data, list) else None
    except (OSError, yaml.YAMLError):
        return None

def count_helpers():
    d = safe_load(EREG)
    if not d:
        return None
    ents = d.get("data", {}).get("entities", [])
    return sum(1 for e in ents
               if e.get("entity_id","").split(".",1)[0] in HELPER_DOMS
               and not e.get("disabled_by"))

def chk_drift():
    if not os.path.exists(HANDOFF):
        add(9, "HANDOFF count drift", "OK", "no HANDOFF.md")
        return
    try:
        text = open(HANDOFF).read()
    except OSError as e:
        add(9, "HANDOFF count drift", "ERR", str(e))
        return
    am = re.search(r"(\d+)\s+automations?", text)
    hm = re.search(r"(\d+)\s+helpers?", text)
    la, lh = count_autos(), count_helpers()
    parts, warn = [], False
    if am and la is not None:
        doc = int(am.group(1))
        parts.append(f"auto:doc={doc}/live={la}")
        if doc != la: warn = True
    if hm and lh is not None:
        doc = int(hm.group(1))
        parts.append(f"help:doc={doc}/live={lh}")
        if doc != lh: warn = True
    s = "WARN" if warn else "OK"
    adv = "update HANDOFF.md to match live counts" if warn else ""
    add(9, "HANDOFF count drift", s, " | ".join(parts) or "no counts in HANDOFF", adv,
        "\n".join(parts))

# [10] Git working tree
def chk_git():
    try:
        r = subprocess.run(["git","-C",CFG,"status","--short"],
                           capture_output=True, text=True, timeout=10,
                           env={**os.environ,"GIT_TERMINAL_PROMPT":"0"})
    except (subprocess.SubprocessError, OSError) as e:
        add(10, "Git working tree", "ERR", str(e))
        return
    out = r.stdout.strip()
    n = len([l for l in out.splitlines() if l.strip()])
    s = "WARN" if n >= 1 else "OK"
    adv = "commit + git_push at session close" if n >= 1 else ""
    add(10, "Git working tree", s, f"{n} uncommitted", adv, out or "(clean)")

# [11] Last commit age
def chk_age():
    try:
        r = subprocess.run(["git","-C",CFG,"log","-1","--format=%cr|%h %s"],
                           capture_output=True, text=True, timeout=10,
                           env={**os.environ,"GIT_TERMINAL_PROMPT":"0"})
    except (subprocess.SubprocessError, OSError) as e:
        add(11, "Last commit age", "ERR", str(e))
        return
    out = r.stdout.strip()
    if "|" in out:
        rel, line = out.split("|",1)
        add(11, "Last commit age", "OK", rel, "", line)
    else:
        add(11, "Last commit age", "OK", out)

# Inventory
def inventory():
    ereg = safe_load(EREG)
    dreg = safe_load(DREG)
    if not ereg or not dreg:
        return None, None
    ents = ereg.get("data", {}).get("entities", [])
    devs = dreg.get("data", {}).get("devices", [])
    dev_areas = {d["id"]: d.get("area_id") for d in devs}
    domains, arealess = {}, []
    skip = {"automation","script","scene","person","zone","sun",
            "persistent_notification","conversation","tts","stt","update",
            "button","event","calendar","todo","image","backup",
            "assist_pipeline","weather","tag","device_tracker","number","select"}
    for e in ents:
        eid = e.get("entity_id","")
        dom = eid.split(".",1)[0]
        if e.get("disabled_by"):
            continue
        domains[dom] = domains.get(dom, 0) + 1
        if dom in skip:
            continue
        if not e.get("area_id") and not dev_areas.get(e.get("device_id")):
            arealess.append(eid)
    return domains, arealess

def main():
    t0 = time.time()
    for fn in (chk_unavail, chk_psi, chk_disk, chk_db, chk_repairs,
               chk_int_err, chk_errlog, chk_double, chk_drift, chk_git, chk_age):
        try:
            fn()
        except Exception as e:
            add(0, fn.__name__, "ERR", f"section crashed: {e}")
    domains, arealess = inventory()
    elapsed = time.time() - t0

    print(f"=== HA HEALTH CHECK -- {datetime.now(timezone.utc).isoformat(timespec='seconds')} ===")
    for r in results:
        line = f"[{r['n']:>2}] {r['label']:<24}: {r['status']:<4} {r['summary']}"
        if r["status"] in ("WARN","CRIT","ERR") and r["advisor"]:
            line += f"  -> {r['advisor']}"
        print(line)
    if domains:
        helpers = sum(domains.get(k,0) for k in HELPER_DOMS)
        print(f"[INV] auto:{domains.get('automation',0)} help:{helpers} "
              f"light:{domains.get('light',0)} switch:{domains.get('switch',0)} "
              f"sensor:{domains.get('sensor',0)} bin:{domains.get('binary_sensor',0)} "
              f"scene:{domains.get('scene',0)} script:{domains.get('script',0)}")
    if arealess is not None:
        by = {}
        for e in arealess:
            d = e.split(".",1)[0]
            by[d] = by.get(d,0)+1
        top = sorted(by.items(), key=lambda x:-x[1])[:5]
        top_s = " ".join(f"{d}:{n}" for d,n in top) or "(none)"
        print(f"[AREA] {len(arealess)} area-less (top: {top_s})")
    print(f"=== ran in {elapsed:.2f}s ===")

    try:
        with open(DETAIL,"w") as f:
            f.write(f"HA HEALTH CHECK DETAIL -- {datetime.now(timezone.utc).isoformat()}\n")
            f.write(f"Elapsed: {elapsed:.2f}s\n\n")
            for r in results:
                f.write(f"[{r['n']}] {r['label']}: {r['status']} -- {r['summary']}\n")
                if r["advisor"]:
                    f.write(f"   advisor: {r['advisor']}\n")
                f.write("\n")
            f.write("\n=== DETAIL ===\n\n")
            f.write("\n".join(detail_lines))
            if domains:
                f.write("\n\n=== DOMAIN COUNTS (active) ===\n")
                for k in sorted(domains, key=lambda x:-domains[x]):
                    f.write(f"  {k}: {domains[k]}\n")
            if arealess:
                f.write(f"\n=== AREA-LESS ENTITIES ({len(arealess)}) ===\n")
                for e in sorted(arealess):
                    f.write(f"  {e}\n")
    except OSError:
        pass
    try:
        with open(LAST_RUN,"w") as f:
            f.write(datetime.now().date().isoformat()+"\n")
    except OSError:
        pass

if __name__ == "__main__":
    main()
