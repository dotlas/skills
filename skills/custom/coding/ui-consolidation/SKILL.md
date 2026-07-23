---
name: ui-consolidation
description: Audit the component hierarchy for fragmented, duplicated, or overlapping UI components and consolidate them into canonical versions at the highest appropriate level — without changing user-visible behaviour. Use when refactoring for maintainability, reducing duplication, or preparing shared components.
---
# UI Consolidation

Every change this skill produces is an internal refactor — pages render the same UI with
the same behaviour. The goal is fewer components, clearer ownership, and easier future
changes.

## Component hierarchy

Components live at three levels.
Adapt these locations to your repo’s actual package and route structure.

| Level | Location | Scope | What belongs here |
| --- | --- | --- | --- |
| **1. Design primitives** | `<design-system>/components/` | Any app, any page, any context | Context-free building blocks: Button, Dialog, Card, Select, DataTable, Tooltip. No business logic. |
| **2. Feature components** | `<app>/components/shared/` | Shared across multiple pages within the app | Business-aware assemblies built from Level 1 primitives. Understand domain concepts. |
| **3. Page-local components** | Inside a specific route folder (e.g. `<app>/routes/chat/`) | Only that one page | Components that only make sense in one context. If a second page needs the same thing, promote to Level 2. |

**Placement decision:**
- Knows about business concepts?
  → Level 2 or 3, never Level 1.
- Used by more than one page?
  → Level 2.
- Purely visual and context-free?
  → Level 1.
- Used in one place, unlikely to be reused?
  → Level 3.

## Discovery

Scan in order, building a component inventory:
1. `<design-system>/components/` — design primitives
2. `<app>/components/shared/` — shared feature components
3. `<app>/routes/**/` — page-level route folders

For each component, record: name and path, what it renders, props it accepts, where it’s
imported (grep import statements), current level.

Then identify **fragmentation groups** — sets of components that render visually similar
UI, accept similar props with minor variations, contain copy-pasted logic with small
diffs, wrap the same primitive with added business logic in multiple places, or
implement the same pattern independently across pages.

## Analysis

For each fragmentation group:

1. **Pick the most complete implementation** as the canonical version — the one with the
   most features, best error handling, or cleanest code.
2. **Categorise each difference:**
   - **Slot/render-prop candidate** — variants show different content in the same
     structural position.
     Solve with render props or children slots.
   - **Prop/config candidate** — variants differ by a flag or option.
     Solve with a boolean or enum prop.
   - **Genuinely different component** — overlap is superficial; merging would create a
     god-component. Leave separate, rename for clarity.
3. **Decide the target level** — promote to the highest level where it makes sense.

## Consolidation

For each fragmentation group to consolidate:

1. **Extend the canonical component** to handle the differences from Analysis:
   - Add optional props, render-prop slots, or variant flags.
   - Follow the existing prop patterns in this codebase (e.g. if the repo already uses
     render-prop slots like `renderMeta`/`renderActions`, continue that pattern).
   - Do NOT create new wrapper components around the canonical version.
     Merge into it directly.

2. **Update all import sites** to use the canonical component:
   ```ts
   // BEFORE: local duplicate
   import { EntityCard } from './_components/entity-card';

   // AFTER: shared canonical version
   import { EntityCard } from '<app>/components/shared/entity-card';
   // or for design-system promotions:
   import { EntityCard } from '<design-system>/components/entity-card';
   ```

3. **Delete the duplicate files.** Do not leave dead code behind.

## Verify

- Run the repo’s typecheck command — no broken imports or type errors.
- Grep for any remaining imports of deleted files.
- Check for orphan files — components no longer imported anywhere.
- Confirm every component is at the correct level per the three-level rule.

## Patterns to follow

Read your repo’s existing shared components before starting — follow the patterns you
find, don’t introduce new ones.
Common patterns worth looking for:

| Pattern | What to look for | How it works |
| --- | --- | --- |
| **Slot props for customisation** | A drawer or panel component | Optional render functions (e.g. `renderMeta`, `renderActions`) let consumers show different sections without forking. |
| **Scoping prop** | A list component | An optional ID prop lets the same component serve both global and scoped views. |
| **Unified data hook** | A shared hook for the main domain entity | All UI reads from one canonical hook; components don’t create their own data-fetching. |
| **Design system uses relative imports** | `<design-system>/` package | Components here use relative imports, never app-level aliases (`@/`). |

## Anti-patterns to catch

- **God-component creep** — if merging requires more than ~5 new props or 3 render-prop
  slots, the components are probably genuinely different.
  Don’t force a merge.
- **Wrapper components** — a “shared” component that just passes all props through to a
  design-system primitive.
  Delete the wrapper and use the primitive directly.
- **Local type re-definitions** — components that define their own TypeScript types for
  data that already has a canonical schema in `<schemas package>`. Replace with the
  inferred type.
- **Copy-pasted hooks** — two hooks querying the same endpoint with slightly different
  options. Consolidate into one hook with parameters.
- **Stale barrel exports** — `index.ts` files re-exporting deleted or renamed
  components.

## Output

Before making changes, report: fragmentation groups found (with canonical choice and
consolidation strategy), no-merge decisions with rationale, a changes table (Action /
File / Detail), and final typecheck/orphan-grep status.
