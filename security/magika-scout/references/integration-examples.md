# magika-scout Integration Examples

*Added 2026-04-13 — Uvy, based on coordination in #zevo-uvy*

## Key Design Notes

### How scout.py works
- `scan([filepath])` returns a list of result dicts
- Key fields: `type`, `mime`, `confidence`, `safe`, `dangerous`
- Exit code 1 on dangerous/unknown/error; 0 otherwise
- `--json` flag for machine-readable output
- No `--expected` flag — detected type vs expectation is the **caller's** responsibility

### Consequence-Based Classification
Priority tier is NOT just content-type risk — it's blast radius:
- `registry.json` → 🔴 HIGH even though JSON is "safe" — feeds identity checks fleet-wide
- `cache.json` → 🟢 LOW — same format, isolated blast radius
- **Rule:** JSON/files feeding identity, auth, or downstream trust flows = 🔴 regardless of source trust

---

## Python Integration (import pattern)

```python
import sys
sys.path.insert(0, '/path/to/skills/magika-scout/scripts')
from scout import scan

def pre_download_check(filepath: str, expected_type: str | None = None) -> bool:
    """
    Returns True if file is safe to parse, False if it should be quarantined.
    expected_type: magika label string e.g. 'pdf', 'json', 'html' (optional)
    """
    results = scan([filepath])
    if not results:
        return False
    r = results[0]

    if r["dangerous"]:
        print(f"[magika-scout] 🚨 DANGEROUS type detected: {r['type']} ({r['mime']}) — quarantining {filepath}", file=sys.stderr)
        return False

    if r["type"] in ("error", "unknown"):
        print(f"[magika-scout] ⚠️  Unknown type — quarantining {filepath}", file=sys.stderr)
        return False

    if expected_type and r["type"] != expected_type:
        print(f"[magika-scout] ⚠️  Type mismatch: expected {expected_type}, got {r['type']} ({r['mime']}) — quarantining {filepath}", file=sys.stderr)
        return False

    return True


# Usage example — cron script
import tempfile, urllib.request

url = "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC123456/pdf/"
tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".pdf")
urllib.request.urlretrieve(url, tmp.name)

if not pre_download_check(tmp.name, expected_type="pdf"):
    # quarantine: log, skip parse, alert
    open("quarantine.log", "a").write(f"QUARANTINED: {url}\n")
else:
    # safe to parse
    parse_pdf(tmp.name)
```

---

## Node.js Integration (subprocess pattern)

For JS crons (e.g. `skin-intel-daily.js`) that can't import Python directly:

```js
const { execSync } = require('child_process');
const path = require('path');

const SCOUT_PATH = path.join(process.env.HOME, '.openclaw/workspace/skills/magika-scout/scripts/scout.py');

/**
 * Returns true if file is safe to parse, false if quarantined.
 * expectedType: magika label string e.g. 'pdf', 'json' (optional)
 */
function preDownloadCheck(filePath, expectedType = null) {
  try {
    const raw = execSync(`python3 ${SCOUT_PATH} --json ${filePath}`, { encoding: 'utf8' });
    const results = JSON.parse(raw);
    const r = results[0];

    if (r.dangerous) {
      console.error(`[magika-scout] 🚨 DANGEROUS: expected ${expectedType || 'any'}, got ${r.type} (${r.mime}) — quarantined ${filePath}`);
      return false;
    }
    if (r.type === 'unknown' || r.type === 'error') {
      console.error(`[magika-scout] ⚠️  Unknown type — quarantined ${filePath}`);
      return false;
    }
    if (expectedType && r.type !== expectedType) {
      console.error(`[magika-scout] ⚠️  Type mismatch: expected ${expectedType}, got ${r.type} (${r.mime}) — quarantined ${filePath}`);
      return false;
    }
    return true;
  } catch (e) {
    console.error(`[magika-scout] Scout error: ${e.message} — quarantining ${filePath}`);
    return false;
  }
}

// Usage example
const filePath = '/tmp/downloaded-paper.pdf';
if (!preDownloadCheck(filePath, 'pdf')) {
  fs.appendFileSync('quarantine.log', `QUARANTINED: ${filePath}\n`);
  return; // skip parse
}
parsePdf(filePath);
```

---

## Priority Tiers for Fleet Crons

| Cron | Agent | Downloads | Expected Type | Consequence | Priority |
|------|-------|-----------|---------------|-------------|----------|
| Research Scout | Uvy | PubMed papers/PDFs | pdf | Medium | 🔴 HIGH |
| Peptide Tool Monitor | Uvy | GitHub releases, weights | varies | Medium | 🔴 HIGH |
| Registry Daily Sync | Atlas | registry.json from Drive | json | 🔴 identity poisoning | 🔴 HIGH |
| Skin Intel Daily Digest | Atlas | PubMed abstracts (JSON) | json | Low (no disk write) | 🟡 Forward guard |
| EOD Debrief | Atlas | Drive notebook files | varies | Low | 🟡 Medium |

**Rule:** If the file feeds identity/auth/trust checks downstream, treat as 🔴 regardless of format.
