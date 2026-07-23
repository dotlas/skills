# Internal

> This file is for Dotlas team members.
> Nothing here is secret.
> It’s just not relevant to external contributors.

## Global install

Install every skill in the catalog globally into Claude Code:

```bash
npx skills add dotlas/skills -s '*' -a claude-code -g -y
```

This makes all skills available in any project without a per-repo install.

## Selective install

```bash
# Install a specific category
npx skills add https://github.com/dotlas/skills/tree/main/skills/custom/coding -a claude-code -g -y

# Install a single skill globally
npx skills add dotlas/skills -s commit -a claude-code -g -y
```

## Overriding a skill per project

Drop a `SKILL.md` with the same `name` into your project’s `.claude/skills/` directory.
The local version takes precedence over the global catalog.

## Adding a skill to the catalog

See [CONTRIBUTING.md](./CONTRIBUTING.md).
The `custom/` provenance follows the same structure.
Use `custom/` instead of `community/` as the provenance prefix.
