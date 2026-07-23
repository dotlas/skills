<p align="center">
<img src="https://avatars.githubusercontent.com/u/88832003" height="64" /> </p>

# Dotlas Skills

A shared catalog of agent skills for Claude Code and compatible AI coding agents.

## Browse the catalog

**[Custom](skills/custom/)** skills are authored by Dotlas.
Start here if you’re looking for what we built.
**[Community](skills/community/)** skills are open source skills by other authors that
we vendor and use internally.

|  | Category | Description |
| --- | --- | --- |
| **Custom** | [common](skills/custom/common/) | Dotlas-authored general utilities |
|  | [coding](skills/custom/coding/) | Dotlas-authored coding workflows |
| **Community** | [common](skills/community/common/) | General-purpose agent utilities |
|  | [coding](skills/community/coding/) | Code quality, review, and deployment |
|  | [ui-ux](skills/community/ui-ux/) | Interface design and frontend polish |

## Install

```bash
# Add everything
npx skills add dotlas/skills

# Add a single skill by name
npx skills add dotlas/skills -s commit

# Add a whole category
npx skills add https://github.com/dotlas/skills/tree/main/skills/community/coding
```

## Overriding a skill

Any repo can define a skill with the same name locally to override the catalog version.
Create `<your-skill>/SKILL.md` in your project’s agent skills directory and it takes
precedence.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Colleagues at Dotlas

See [INTERNAL.md](./INTERNAL.md) for the full global install.
