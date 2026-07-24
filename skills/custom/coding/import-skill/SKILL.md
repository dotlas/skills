---
name: import-skill
description: Import a third-party skill into this owned catalog (dotlas/skills) from a skills.sh URL, a GitHub repo/subdir, or a pasted `npx skills add` command. Use when the user wants to add, vendor, or import a skill, pastes a skills.sh link or an `npx skills add …` command, and the target is this repo's `skills/` catalog.
---
# Import a skill into this catalog

This repo is an **owned catalog**: skills are vendored as first-class directories under
`skills/<category>/<provenance>/<name>/`, grouped for the `skills` CLI by
`.claude-plugin/marketplace.json`, and there is deliberately **no `skills-lock.json`**.
The stock `npx skills add` violates both conventions — it writes a lock file and drops
skills flat under `skills/<name>/`. This skill replaces that default with the correct
local procedure.

Every import runs one **spine**: **resolve → clone-to-scratch → copy whole dir →
classify → place → register → assert-no-lock → verify → commit**. The three input forms
differ only in the first step; do not run `npx skills add` to perform the import even
when handed that command — parse it to a target and take the clone path like the others.

## 1. Resolve the source to `owner/repo` + skill path

Produce a concrete `(owner/repo, ref, skill-dir-in-repo, slug)`. The **slug** is the
frontmatter `name:` the skill will be identified by, not necessarily its folder name.

- **skills.sh URL** (`https://skills.sh/<owner>/<repo>/<slug>`) → the GitHub repo is
  `<owner>/<repo>`; the last segment is the target **slug**. Find the dir whose
  `SKILL.md` frontmatter `name:` equals that slug (folder name may differ).
- **GitHub repo or subdir** (`owner/repo`, or `.../tree/<branch>/<subdir>`) → clone and
  locate the `SKILL.md`. If a subdir is given it points at (or into) the skill dir.
- **Pasted `npx skills add …`** → parse the source arg and any `-s <skill>` out of the
  command to the same `(owner/repo, skill)` target.
  Do not execute the command.

## 2. Clone to scratch and copy the whole directory

Shallow-clone the source repo into a scratch directory (never into this repo).
Copy the **entire skill directory**, not just `SKILL.md` — skills commonly ship
`rules/`, `lib/`, `references/`, `scripts/`, `agents/`, and other supporting files.

```sh
git clone --depth 1 [--branch <ref>] https://github.com/<owner>/<repo> "$SCRATCH/src"
```

## 3. Classify: category + provenance + slug

- **category** ∈ `{generic, frontend}` — pick by function (frontend =
  web/UI/React/Next.js work; generic otherwise).
- **provenance** ∈ `{custom, community}` — an imported third-party skill is almost
  always `community`.

When either is not obvious from the source, use **AskUserQuestion** to confirm,
proposing a default.
Then confirm the final **slug**.

**Collision check at the frontmatter `name:` level, not just the folder name** — the CLI
identifies skills by `name:`. Grep existing `SKILL.md` frontmatter for the slug; a
colliding `name:` under a different folder still collides.
On collision, rename **both** the folder and the frontmatter `name:` to a distinct slug.

## 4. Place the directory

Copy to `skills/<category>/<provenance>/<slug>/`.

## 5. Register in `.claude-plugin/marketplace.json`

Add `"./skills/<category>/<provenance>/<slug>"` to the matching plugin’s `skills` array
(`custom-generic`, `community-generic`, `custom-frontend`, or `community-frontend`). The
arrays are **alphabetical** — insert in order.
Keep the JSON valid.

## 6. Assert no lock file

There must be **no `skills-lock.json`** anywhere in the repo.
Remove one if it exists — whether the stock CLI wrote it or it **rode in on the copy**
from the source dir — and note why in the commit.

```sh
find . -name skills-lock.json -not -path './.git/*' -delete
```

## 7. Verify from the local checkout

Confirm the new skill lists under the intended group **before committing** — the CLI
lists a local path without needing a push:

```sh
npx -y skills add . -l
```

The completion criterion: the new slug appears under the correct group header (Community
Frontend / Community Generic / Custom Frontend / Custom Generic) and no
`skills-lock.json` exists.
(`npx skills add dotlas/skills -l` clones the **remote** and only reflects the import
after it is pushed — use it as a post-push confirmation, not the pre-commit gate.)

## 8. Commit

Commit with the **[[commit]]** skill’s conventions.

* * *

**This skill itself** lives at `skills/generic/custom/import-skill/` and is registered
in `marketplace.json` under `custom-generic` — it is the worked example of the layout it
enforces.
