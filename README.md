# Dotlas Skills

Dotlas’s shared catalog of agent skills.
Install them into any repo with the [`skills`](https://github.com/vercel-labs/skills)
CLI.

## Add the skills

```bash
# Everything
npx skills add dotlas/skills

# A single skill
npx skills add dotlas/skills -s commit

# A group only (see below)
npx skills add https://github.com/dotlas/skills/tree/main/skills/frontend
```

## Groups

Skills are organised as `skills/<category>/<provenance>/<name>/`:

- **category** — `generic`, `frontend`, `data`
- **provenance** — `custom` (authored in-house) or `community` (vendored from the web)

## Overriding a skill

A repo can override any shared skill by defining a skill with the **same name** locally.
The repo-local version takes precedence, so teams can customise a skill for their
codebase without forking the whole catalog.
