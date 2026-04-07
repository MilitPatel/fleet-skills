# Fleet Skills Library

Custom OpenClaw skills built by the UViiVe/Ekker Lab AI fleet.

## What's Here

These skills extend OpenClaw agents with fleet-specific capabilities. They live in `~/.openclaw/workspace/skills/` on each fleet node and are auto-discovered by OpenClaw.

## Skills

### Memory & Learning System
| Skill | Description |
|-------|-------------|
| `moe-memory` | Install the full MoE summaries-first memory architecture |
| `pre-action-gate` | Structural memory check before high-risk actions (SSH, citations, external sends) |
| `discord-dm-recover` | Recover lost session context from Discord DM history after a crash |
| `fleet-mem-deploy` | Deploy MoE memory shards to fleet nodes |
| `memory-maintenance` | Keep Layer 0 bootstrap files lean to prevent compaction loops |
| `session-cleanup` | Prune stale sessions from the OpenClaw session store |
| `gateway-watchdog` | Check gateway health and restart safely (self-guard for mid-session) |

### Fleet Operations
| Skill | Description |
|-------|-------------|
| `fleet-sync` | Push files from Uvy to all fleet nodes via SSH |
| `openclaw-test-flight` | Post-update validation test flight for any fleet node |

### Literature & Science
| Skill | Description |
|-------|-------------|
| `arxiv-search` | Search arXiv for academic papers |
| `ncbi-api` | Search PubMed, fetch abstracts, download PMC papers |
| `semantic-scholar-api` | Search papers, citations, author profiles via Semantic Scholar |
| `latex-paper` | Build and compile LaTeX papers for academic publication |

### Communication & Tools
| Skill | Description |
|-------|-------------|
| `agentmail` | API-first email for agents (inboxes, send/receive) |
| `bird-x` | Read-only X (Twitter) access via bird CLI |
| `imsg` | iMessage/SMS CLI |
| `mcporter` | List, configure, and call MCP servers/tools |
| `github` | GitHub CLI operations (issues, PRs, CI runs) |

## Installing a Skill

Skills are auto-discovered when placed in `~/.openclaw/workspace/skills/`. To install from this repo:

```bash
# Clone or pull the repo
git clone https://github.com/ekkerlab/fleet-skills ~/.openclaw/workspace/skills-repo

# Copy the skill you want
cp -r ~/.openclaw/workspace/skills-repo/moe-memory ~/.openclaw/workspace/skills/

# Restart gateway to pick up new skills
openclaw gateway restart
```

Or pull from Google Drive (for agents without GitHub access):
```bash
gog drive download <folder-id> --account <your-account>
```
Drive folder: https://drive.google.com/drive/folders/1G2ggTGnxk7ClShVmLw9T8jUxvuoSLaGD

## Contributing

1. Build your skill in `~/.openclaw/workspace/skills/<name>/`
2. Test it on your node
3. Push to this repo via `gh` CLI or PR
4. Fleet-sync to other nodes

## Fleet Contacts
- **Maintainer:** Uvy 🦾 (uvy@uviive.com)
- **Fleet:** Uvy, Zevo, Atlas, Buster, SARAH, Pip, Jimmy, Mendel
- **Docs:** https://docs.openclaw.ai
