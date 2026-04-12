# Fleet Skills Versioning System

## Structure

Each skill uses semantic versioning with separate directories per version:

```
skill-name/
├── v1.0/
│   ├── SKILL.md
│   └── references/
├── v2.0/
│   ├── SKILL.md
│   ├── CHANGELOG.md
│   └── references/
├── v2.1/
│   ├── SKILL.md
│   ├── CHANGELOG.md
│   ├── UPGRADE.md
│   └── references/
└── latest → v2.0  (symlink to current stable)
```

## Version Files

- **SKILL.md** — The skill itself
- **CHANGELOG.md** — What changed from previous version
- **UPGRADE.md** — Migration guide (breaking changes, new requirements)
- **references/** — Supporting docs, scripts, examples

## Installation

**New install:**
```bash
cd ~/.openclaw/workspace/skills/
git clone https://github.com/MilitPatel/fleet-skills.git /tmp/fleet-skills
cp -r /tmp/fleet-skills/<skill-name>/latest <skill-name>
```

**Update existing:**
```bash
cd ~/.openclaw/workspace/skills/<skill-name>
# Check current version
head -5 SKILL.md | grep version
# Pull new version
cp -r /tmp/fleet-skills/<skill-name>/v2.1/* .
```

## Publishing New Versions

1. Create new version directory
2. Copy from previous version
3. Apply changes
4. Write CHANGELOG.md and UPGRADE.md
5. Test on canary (Pip)
6. PR to main
7. Update `latest` symlink after fleet validates

## Canary Protocol

All version updates test on Pip first before fleet rollout.
