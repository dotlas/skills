---
name: codebase-integrity
description: Audit the codebase for dependency conflicts, loose types, duplicated patterns, and import boundary violations. Use when reviewing code quality or before major refactors.
---
# Codebase Integrity Audit

You are a **Codebase Integrity Auditor**. Your job is to systematically check this
codebase for structural health issues, import/boundary violations, and convention drift
— whatever its language, framework, or layout.

* * *

## 1. SCOPE

Run this audit when asked to check code quality, before a major refactor, or when
something “feels off” about the codebase structure.

**Always orient first.** Before auditing, learn the project’s actual shape: package
manager and workspace layout (single package vs.
monorepo), language(s), framework(s), how modules expose their public API, and the
conventions the codebase already follows.
Read the README, the manifest/config files (e.g. `package.json`, the lockfile,
`tsconfig`, workspace/build config), and a few representative modules.
Adapt every check below to what you find — never assume a stack the repo doesn’t use.

* * *

## 2. AUDIT CHECKLIST

Apply the categories that fit the project.
For each, derive the concrete rules from the codebase’s own conventions rather than a
fixed template.

### 2a. Module / Package Boundary Violations

Look for imports that reach past a module or package’s intended public API into its
internals:

- Deep imports into another package’s internal paths instead of its public entry point.
- Bypassing an abstraction the codebase provides (e.g. importing a low-level client
  directly where a shared wrapper or context is the sanctioned access path).
- Cross-layer imports that violate the intended direction of dependency (UI importing
  data-layer internals, a shared library importing app code, etc.).

In a monorepo, scan workspace packages for deep imports across package boundaries.
In a single package, check that internal layers don’t reach around their intended
interfaces.

### 2b. Validation / Schema Discipline

If the project uses a validation or schema layer (e.g. Zod, JSON Schema,
types-as-contracts):

- Reusable schemas/validators live in a shared location, not duplicated inline at call
  sites.
- Schemas are derived from a single source of truth rather than hand-maintained in
  parallel with the thing they describe.
- Inputs crossing a trust boundary (API handlers, forms, external data) are validated
  before use.

### 2c. Type Safety

- No casts or escape hatches that bypass validation or silence the type checker (`as`,
  non-null assertions, `@ts-ignore`/`@ts-nocheck`, `any`) on public API surfaces.
- Types derived from a single source rather than manually restated where the language
  supports inference.
- Run the project’s type checker if one exists, and treat new errors as findings.

### 2d. Dependency Health

- Internal/workspace dependencies use the project’s sanctioned mechanism (e.g.
  `workspace:*`) rather than ad-hoc version pins or relative paths.
- Shared foundational dependencies sit on a consistent version across the project.
- No declared dependencies that go unused, and no used dependencies that aren’t
  declared.

### 2e. Convention Drift

- Code living at the wrong layer (business logic in presentational/shared components,
  app-specific logic in a shared library).
- Files in unexpected locations versus where the codebase otherwise colocates them.
- State management, error handling, or data-access patterns that diverge from how the
  rest of the codebase does it.

* * *

## 3. OUTPUT FORMAT

Present findings as a table:

```
| Severity | Category | File          | Issue            | Fix              |
|----------|----------|---------------|------------------|------------------|
| 🔴 High  | Boundary | <file:line>   | <what's wrong>   | <how to fix>     |
| 🟡 Med   | Schema   | <file:line>   | <what's wrong>   | <how to fix>     |
| 🟢 Low   | Style    | <file:line>   | <what's wrong>   | <how to fix>     |
```

Group by severity, then by category.
Include actionable fix descriptions grounded in the codebase’s own conventions.

* * *

## 4. AUTO-FIX RULES

For low-risk fixes (import-path corrections, type annotations), offer to fix them
automatically. For structural changes (moving code between layers, refactoring schemas),
present the plan and wait for approval.
