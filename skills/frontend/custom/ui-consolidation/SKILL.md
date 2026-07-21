---
name: ui-consolidation
description: Audit the component hierarchy for fragmented, duplicated, or overlapping UI components and consolidate them into canonical versions at the highest appropriate level — without changing user-visible behaviour. Use when refactoring for maintainability, reducing duplication, or preparing shared components.
---
# UI Consolidation Skill

## When to use

Invoke this skill when:

- You suspect multiple components serve the same or overlapping purpose
- A feature was built with local components that should be shared
- You’re preparing for a new feature and want to ensure existing components are reusable
- After a period of rapid development where duplication may have crept in
- You want a general audit of component fragmentation across the app

## Core principle

**The user should notice nothing.** Every change this skill produces is an internal
refactor. Pages render the same UI, with the same behaviour, at the same URLs.
The goal is fewer components, clearer ownership, and easier future changes.

## The component hierarchy

Components live at three levels.
Each level has a clear scope of reuse:

| Level | Location | Scope | What belongs here |
| --- | --- | --- | --- |
| **1. Design primitives** | `packages/design-system/components/` | Any app, any page, any context | Context-free building blocks: Button, Dialog, Card, Select, DataTable, Tooltip, etc. These know nothing about business logic. |
| **2. Feature components** | `apps/web/app/(dashboard)/_components/` | Shared across multiple pages within the web app | Business-aware assemblies: ListView, ItemDrawer, TaskList, CreateTaskDialog, AppShell, etc. Built from Level 1 primitives but understand domain concepts (records, entities, tasks). |
| **3. Page-local components** | Inside a specific route folder (e.g. `apps/web/app/(dashboard)/chat/`) | Only that one page | Components that only make sense in one context. If a second page needs the same thing, it must be promoted to Level 2. |

### Decision rule for placement

- Does the component know about business concepts (entities, records, tasks)?
  → **Level 2 or 3**, never Level 1.
- Is it used by more than one page?
  → **Level 2**.
- Is it purely visual and context-free?
  → **Level 1** (design system).
- Is it only used in one place and unlikely to be reused?
  → **Level 3** (page-local).

## Procedure

### Phase 1: Discovery — find fragmentation

Scan these directories in order, building an inventory of components:

1. `packages/design-system/components/` — the design primitives
2. `apps/web/app/(dashboard)/_components/` — shared feature components
3. `apps/web/app/(dashboard)/**/` — page-level route folders

For each component found, record:
- **Name and path**
- **What it renders** (brief description)
- **What props it accepts**
- **Where it’s imported** (use grep for import statements)
- **What Level it currently lives at** (1, 2, or 3)

Then identify **fragmentation groups** — sets of components that:
- Render visually similar or identical UI
- Accept similar props with minor variations
- Contain copy-pasted logic with small diffs
- Wrap the same design-system primitive with added business logic in multiple places
- Implement the same pattern (e.g. “list with filters and a drawer”) independently

### Phase 2: Analysis — choose the canonical version

For each fragmentation group:

1. **Pick the most complete implementation** as the canonical version — the one with the
   most features, best error handling, or cleanest code.
2. **Identify the differences** between variants.
   Categorize each difference as:
   - **Slot/render-prop candidate** — the variants show different content in the same
     structural position (e.g. different metadata sections in a drawer).
     Solve with render props or children slots.
   - **Prop/config candidate** — the variants differ by a flag or option (e.g. one shows
     a delete button, one doesn’t). Solve with a boolean or enum prop.
   - **Genuinely different component** — the overlap is superficial and merging would
     create a messy god-component.
     Leave them separate, but rename for clarity.
3. **Decide the target level** — promote to the highest level where it makes sense
   (page-local → feature-shared, or feature-shared → design-system).

### Phase 3: Consolidation — merge and redirect

For each fragmentation group to consolidate:

1. **Extend the canonical component** to handle the differences identified in Phase 2:
   - Add optional props, render-prop slots, or variant flags.
   - Use the existing prop patterns in this codebase.
     For example, `ItemDrawer` (`apps/web/app/(dashboard)/_components/item-preview.tsx`)
     already uses `renderMeta`, `renderProperties`, and `renderActions` slot props —
     follow that pattern.
   - Do NOT create new wrapper components around the canonical version.
     Merge into it directly.

2. **Update all import sites** to use the canonical component.
   Replace:
   ```ts
   // BEFORE: local duplicate
   import { EntityCard } from './_components/entity-card';
   ```
   with:
   ```ts
   // AFTER: shared canonical version
   import { EntityCard } from '@/app/(dashboard)/_components/entity-card';
   ```
   or for design-system promotions:
   ```ts
   import { EntityCard } from '@repo/design-system/components/entity-card';
   ```

3. **Delete the duplicate files.** Do not leave dead code behind.

4. **Verify no visual change.** After consolidation, the rendered output at every
   affected route must be identical.
   The only change is internal: fewer files, clearer ownership.

### Phase 4: Verify — confirm structural integrity

After all consolidations:

- Run `pnpm typecheck` to ensure no broken imports or type errors.
- Grep for any remaining imports of deleted files.
- Check that no orphan files remain (components that are no longer imported anywhere).
- Confirm the component hierarchy still follows the three-level rule — no component is
  at the wrong level.

## Key patterns in this codebase

These are existing architectural patterns to follow (not break) during consolidation:

| Pattern | Where | How it works |
| --- | --- | --- |
| **Slot props for drawer customization** | `item-preview.tsx` | `renderMeta`, `renderProperties`, `renderActions` — optional render functions that let different consumers show different sections without forking the component. |
| **`entityId` prop for scoping** | `list-view.tsx` | The same list component serves both the global list and per-entity views by accepting an optional `entityId` prop. |
| **Unified data source** | `useItems()` hook from `@/lib/items` | All record/task UI reads from one canonical hook. Components should not create their own data-fetching for records. |
| **Design system uses relative imports** | `packages/design-system/` | Components here use `../../lib/utils`, never `@/` aliases. |

## Anti-patterns to catch

- **God-component creep:** If merging would require more than ~5 new props or 3
  render-prop slots, the components are probably genuinely different.
  Don’t force a merge.
- **Prop drilling through wrappers:** If a “shared” component is just a thin wrapper
  that passes all props through to a design-system component, delete the wrapper and use
  the design-system component directly.
- **Local type re-definitions:** Components that define their own TypeScript types for
  data that already has a Zod schema in `packages/schemas/`. Replace with
  `z.infer<typeof existingSchema>`.
- **Copy-pasted hooks:** Two hooks that query the same tRPC endpoint with slightly
  different options. Consolidate into one hook with parameters.
- **Stale exports:** `index.ts` barrel files that re-export deleted or renamed
  components.

## Output format

Produce a structured report before making changes:

```
## UI Consolidation Report: [scope]

### Fragmentation Groups Found

#### Group 1: [description, e.g. "Entity card variants"]
- `apps/web/app/(dashboard)/accounts/_components/entity-card.tsx`
- `apps/web/app/(dashboard)/_components/entity-workspace.tsx` (partial overlap)
- **Differences:** [list]
- **Canonical version:** [path] — promoted to Level [2/1]
- **Strategy:** Add `variant` prop for [difference], `renderFooter` slot for [difference]

#### Group 2: ...

### No-merge decisions
- [Component A] and [Component B] — overlap is superficial, keeping separate. Renamed for clarity.

### Changes Made
| Action | File | Detail |
|---|---|---|
| Extended | `_components/entity-card.tsx` | Added `variant` prop, `renderFooter` slot |
| Deleted | `accounts/_components/entity-card.tsx` | Replaced by canonical version |
| Updated imports | `accounts/page.tsx`, `accounts/[entityId]/page.tsx` | Point to `_components/entity-card` |

### Verification
- `pnpm typecheck` ✅
- No orphan imports ✅
- No visual changes ✅
```
