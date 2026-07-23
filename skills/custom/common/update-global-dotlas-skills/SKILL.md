---
name: update-global-dotlas-skills
description: Sync the globally-installed dotlas/skills catalog and prune stale remnants. Runs the documented global install command, then detects skills that were installed from dotlas/skills but no longer exist in the catalog and removes them (with confirmation). Use when the user wants to update, refresh, or clean up their global Dotlas skills, or invokes /update-global-dotlas-skills.
---
# Update the global Dotlas skills

Bring the machine’s **global** skill install back in line with the current
[`dotlas/skills`](https://github.com/dotlas/skills) catalog: install/refresh everything
in the catalog, then remove **remnants** — skills that were installed from
`dotlas/skills` but have since been renamed or dropped from the catalog.
`npx skills add` never prunes, so remnants accumulate silently.

Run one **spine**: **locate lock → sync → build catalog truth-set → diff for stale →
confirm → remove → report**.

Two hard rules, both from [INTERNAL.md](../../../../INTERNAL.md):

- **Agent scope is always `-a claude-code`.** Never `-a '*'` — not for install, not for
  removal.
- **Only ever touch skills whose lock `source` is `dotlas/skills`.** Skills installed
  from any other owner (`mattpocock/skills`, `LottieFiles/...`, etc.)
  are out of scope and must never be removed, even if they look unfamiliar.

## 1. Locate the global lock file

The global manifest is **`~/.agents/.skill-lock.json`** (note the leading dot; version 3
schema). This is *not* the per-project `skills-lock.json`. If it is missing, the machine
has no global skills installed — report that and stop; there is nothing to sync or
prune.

```sh
LOCK="$HOME/.agents/.skill-lock.json"
test -f "$LOCK" || echo "No global lock at $LOCK — nothing to do."
```

Each entry looks like:
`{"source": "dotlas/skills", "skillPath": "...", "updatedAt": "...", ...}` keyed by the
skill’s frontmatter `name:`.

## 2. Sync the catalog globally

Run the documented global install.
`-s '*'` installs every current catalog skill (picking up newly-added ones and
refreshing existing ones):

```sh
npx skills add dotlas/skills -s '*' -a claude-code -g -y
```

## 3. Build the catalog truth-set

The lock is the record of what is *installed*; it does not know what the catalog *now
contains*. Get the authoritative current list by shallow-cloning the catalog into
scratch and reading every skill’s frontmatter `name:` (this is the identity the lock
keys on — folder names can differ):

```sh
git clone --depth 1 https://github.com/dotlas/skills "$SCRATCH/catalog"
```

## 4. Diff the lock against the catalog for stale skills

**Stale** = a lock entry whose `source` is `dotlas/skills` **and** whose key is absent
from the catalog truth-set.
Use this snippet (edit `$SCRATCH` to the real path):

```sh
python3 - "$HOME/.agents/.skill-lock.json" "$SCRATCH/catalog" <<'PY'
import json, os, re, sys
lock_path, catalog_root = sys.argv[1], sys.argv[2]

# catalog truth-set = frontmatter name: of every SKILL.md in the fresh clone
catalog = set()
for root, _, files in os.walk(os.path.join(catalog_root, "skills")):
    if "SKILL.md" in files:
        with open(os.path.join(root, "SKILL.md")) as f:
            m = re.search(r"^name:\s*(.+)$", f.read(), re.M)
            if m:
                catalog.add(m.group(1).strip())

lock = json.load(open(lock_path))["skills"]
dotlas = {k for k, v in lock.items() if v.get("source") == "dotlas/skills"}
stale = sorted(dotlas - catalog)

print(f"catalog skills: {len(catalog)}")
print(f"dotlas-sourced global skills: {len(dotlas)}")
print("STALE (dotlas-sourced, no longer in catalog):")
for s in stale:
    print("  -", s)
PY
```

**Guard against false positives.** If the clone failed, the catalog set is tiny/empty,
or the stale list contains *most* of the dotlas-sourced skills, something went wrong
(bad clone, layout change) — **do not delete**. Report the anomaly and stop.

## 5. Confirm, then remove

Show the user the exact stale list.
**Wait for explicit confirmation before removing anything.** On approval, remove each
stale skill — one call per skill, scoped to `claude-code`:

```sh
npx skills remove -g -a claude-code <name> -y
```

If the list is empty, say so and skip this step.

## 6. Report

Summarise: catalog skills synced, and each stale skill removed (or “none — global
install already matched the catalog”). Leave non-`dotlas/skills` skills untouched and
unmentioned.
