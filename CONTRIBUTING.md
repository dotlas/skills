# Contributing

## What is a skill

A skill is a Markdown file (`SKILL.md`) that an agent loads as instructions.
It lives at `skills/<provenance>/<category>/<name>/SKILL.md`. Provenance is `community`
(vendored from the web) or `custom` (Dotlas-authored).

## Skill anatomy

The minimum viable skill:

```yaml
---
name: my-skill
description: One sentence describing what this does and when an agent should use it.
---

# My Skill

Instructions here.
```

Rules:

- `name` must be kebab-case and unique across the catalog
- `description` is what appears in manifest tables: one sentence, plain English
- The body can be any length but should be readable in a single scroll

## Adding a skill

1. Fork the repo and create a branch.
2. Create `skills/community/<category>/<your-skill>/SKILL.md` using the structure above.
3. Run `just fmt` to format Markdown.
4. Open a PR and describe what the skill does and when to use it.

## Formatting

This repo uses [flowmark](https://github.com/jlevy/flowmark) for Markdown formatting.
Run `just fmt` before pushing.
If you have lefthook installed (`just setup`), the pre-commit hook runs it
automatically.

## Code of Conduct

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
