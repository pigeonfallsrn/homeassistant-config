#!/usr/bin/env python3
"""HAC Sanitizer v1.1 - Preserves entity IDs"""
import re
import sys
from typing import List, Tuple

# Patterns that look like HA entity IDs - DON'T sanitize these
ENTITY_ID_PATTERN = re.compile(r'\b[a-z]+_[a-z_]+(?:_home|_mode|_override|_bedroom|_status|_away)\b')

SANITIZE_PATTERNS: List[Tuple[re.Pattern, str, str]] = [
    (re.compile(r'40062\s+Hwy\s+53', re.I), '[ADDRESS]', 'addr1'),
    (re.compile(r'40154\s+US\s+Hwy\s+53', re.I), '[ADDRESS]', 'addr2'),
    (re.compile(r'\bStrum,?\s*WI\b', re.I), '[TOWN]', 'town_strum'),
    (re.compile(r'\bPigeon\s+Falls\b', re.I), '[TOWN]', 'town_pigeon'),
    (re.compile(r'[a-z0-9]{20,}@group\.calendar\.google\.com'), '[CALENDAR_ID]', 'cal'),
    # Person names - only match standalone or possessive, NOT in snake_case
    (re.compile(r"(?<![a-z_])\bTraci(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'traci'),
    (re.compile(r"(?<![a-z_])\bMichelle(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'michelle'),
    (re.compile(r"(?<![a-z_])\bAlaina(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'alaina'),
    (re.compile(r"(?<![a-z_])\bElla(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'ella'),
    (re.compile(r"(?<![a-z_])\bJarrett(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'jarrett'),
    (re.compile(r"(?<![a-z_])\bOwen(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'owen'),
    (re.compile(r"(?<![a-z_])\bJean(?='s|\b)(?![a-z_])", re.I), '[PERSON]', 'jean'),
    (re.compile(r'-?\d{1,3}\.\d{5,},-?\d{1,3}\.\d{5,}'), '[GPS]', 'gps'),
    (re.compile(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'), '[EMAIL]', 'email'),
    (re.compile(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), '[PHONE]', 'phone'),
    (re.compile(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'), '[IP]', 'ip'),
    (re.compile(r'\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b'), '[MAC]', 'mac'),
    (re.compile(r'[a-z0-9-]+\.cloudflare[a-z]*\.(?:com|dev)', re.I), '[TUNNEL]', 'cf'),
    (re.compile(r'\b[a-z0-9-]+\.local\b', re.I), '[LOCAL]', 'local'),
]

FORBIDDEN_PATTERNS: List[Tuple[re.Pattern, str]] = [
    (re.compile(r'ghp_[A-Za-z0-9_]{36}'), 'github_pat'),
    (re.compile(r'gho_[A-Za-z0-9_]{36}'), 'github_oauth'),
    (re.compile(r'github_pat_[A-Za-z0-9_]{22,}'), 'github_fine'),
    (re.compile(r'AKIA[A-Z0-9]{16}'), 'aws_key'),
    (re.compile(r'sk-[A-Za-z0-9]{48}'), 'openai'),
    (re.compile(r'xoxb-[0-9]+-[A-Za-z0-9]+'), 'slack_bot'),
]

SECRET_KEYWORDS = re.compile(r'\b(token|bearer|authorization|secret|api[_-]?key|password|credential)\b', re.I)
LONG_TOKEN = re.compile(r'\b[A-Za-z0-9_-]{32,64}\b')

def sanitize(content: str) -> str:
    for pattern, repl, _ in SANITIZE_PATTERNS:
        content = pattern.sub(repl, content)
    return content

def audit_line(line: str, ln: int, fn: str) -> List[str]:
    violations = []
    for pattern, name in FORBIDDEN_PATTERNS:
        if pattern.search(line):
            masked = pattern.sub(f'[REDACTED]', line)
            violations.append(f"{fn}:{ln} [{name}] {masked[:70]}...")
    if SECRET_KEYWORDS.search(line):
        for m in LONG_TOKEN.finditer(line):
            tok = m.group()
            if '_' in tok and tok.count('_') > 2: continue
            if tok.startswith(('input_','automation_','sensor_','binary_')): continue
            violations.append(f"{fn}:{ln} [potential_token] ...{tok[:20]}...")
    return violations

def audit_files(files: List[str]) -> Tuple[bool, List[str]]:
    all_v = []
    for fp in files:
        try:
            with open(fp, 'r', errors='replace') as f:
                for ln, line in enumerate(f, 1):
                    all_v.extend(audit_line(line.rstrip(), ln, fp))
        except Exception as e:
            all_v.append(f"{fp}:0 [error] {e}")
    return (len(all_v) == 0, all_v)

def run_tests() -> bool:
    print("═══ Sanitizer Self-Test ═══\n")
    p, f = 0, 0
    tests = [
        ("40154 US Hwy 53","[ADDRESS]","address"),
        ("Strum, WI","[TOWN]","town"),
        ("test@x.com","[EMAIL]","email"),
        ("192.168.1.1","[IP]","ip"),
        ("AA:BB:CC:DD:EE:FF","[MAC]","mac"),
        ("Traci's House","[PERSON]'s House","person possessive"),
        ("ella_bedroom_override: off","ella_bedroom_override","entity preserved"),
        ("michelle_home: on","michelle_home","entity preserved"),
        ("alaina_spencer: home","alaina_spencer","entity preserved"),
    ]
    for inp, exp, desc in tests:
        r = sanitize(inp)
        if exp in r: print(f"  ✓ {desc}"); p+=1
        else: print(f"  ✗ {desc}: '{inp}' → '{r}' (expected '{exp}')"); f+=1
    print(f"\nResults: {p} passed, {f} failed")
    return f == 0

if __name__ == '__main__':
    if len(sys.argv) < 2: print("Usage: sanitize|audit|test"); sys.exit(1)
    cmd = sys.argv[1]
    if cmd == 'sanitize': print(sanitize(sys.stdin.read()), end='')
    elif cmd == 'audit':
        ok, v = audit_files(sys.argv[2:])
        if ok: print("✓ Audit passed"); sys.exit(0)
        else: print("❌ AUDIT FAILED:"); [print(f"  {x}") for x in v]; sys.exit(1)
    elif cmd == 'test': sys.exit(0 if run_tests() else 1)
