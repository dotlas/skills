---
name: pipeline-conventions
description: Use this skill when creating or refactoring `.ipynb` or Databricks PySpark notebooks that read from Unity Catalog, run transformations, and write to Unity Catalog.
---
## General Conventions

- Each cell should do one thing well — separation of concerns at a glance.
- Keep cells under ~50 lines.
  Exceptions: large configs or long `select` field lists.
- If a notebook exceeds ~25–30 cells, consider splitting into multiple notebooks with
  intermediate table saves.
- Variable names should be meaningful, concise, and low-syllable — self-documenting
  without comments.
- Reserve comments for caveats and business-logic reasoning that isn’t directly
  inferrable from the code.

## Halting Conditions

- Notebooks must halt on failure and gracefully exit on success (e.g.
  `dbutils.notebook.exit()` when an incremental CDC finds no new data).
- Halt on failure when:
  - Input, intermediate, or output DataFrames are unexpectedly empty (bad
    filter/join/transform).
  - Critical data quality checks fail.
- Do **not** halt on minor warnings or non-critical issues.
  Pipeline repair requires human intervention, so make a best effort to complete when
  critical paths pass.
  The developer defines what’s critical based on source/target datasets and downstream
  usage (e.g. dashboards).

## Header Markdown Cell

First cell must be markdown containing the notebook title, an optional 1–2 line
description, and:

- **Compute**: Compatibility declaration.
  - `Serverless` = runs on Databricks Serverless or vanilla runtimes with no
    pre-installed internal packages; all dependencies defined within notebook scope.
  - `Internal` = requires clusters pre-installed with your organization’s proprietary
    libraries.
  - Note any other requirements (e.g. `photon`-compatible, `c7gd.**` instance type).
- **Maintainers**: Markdown-formatted email links.
- **Last Updated** *(optional)*: Date of last human review (maintainer changes, notebook
  tweaks). Does not substitute for git history.

## Package Installation

First code cell installs additional dependencies not in the standard Python distribution
or Databricks runtime.
All installs use `-q` (quiet) mode.

```python
!pip install loguru -q
```

## Logging Rules

- Use `loguru` exclusively — no `print` statements.
  Use appropriate levels: `.info`, `.debug`, `.warning`, `.error`, `.critical`.
- **Never** use the logger inside a `UDF` or `mapPartitions` — these run on executors
  where `loguru` may not be initialized.
- Use f-strings with `=` for variable logging and `:,` for numeric formatting.

| Scenario | Correct? | Why |
| --- | --- | --- |
| Logging each iteration of a very long loop | No | Creates an unusable stream of logs |
| Logging iterations of a small loop (<~20) showing current input | Yes | Shows per-iteration timing and current source; not useful for instant PySpark transforms |
| Logging integer/label values via f-strings | Yes | Clean, readable variable output |
| Logging DataFrames via f-strings | No | Inefficient; use `.display()` or `.head()` instead |
| Logging `df.count()` (e.g. `logger.info(f"{df.count()=:,}")`) | Yes | Materializes cache, validates row counts — first line of debugging in prod |
| Logging inputs, constants, globals | Yes | Quick verification of run hyperparameters |

## Import Convention

A single cell for all imports — no fragmented imports across the notebook.
Only import what the pipeline uses.
Order:

1. **Native** — standard library (`datetime`, `json`, etc.)
2. **Package** — pip-installable (`pandas`, `loguru`, etc.)
3. **Internal** — your organization’s internal packages
4. **Spark** — PySpark imports

```python
import warnings
warnings.filterwarnings("ignore")

# Native imports
from datetime import datetime
import json

# Package imports
import pandas as pd
from loguru import logger

# Internal imports
import your_internal_package

# Spark imports
from pyspark.sql.functions import col
from pyspark.sql import functions as F, types as T, Window, DataFrame
```

**Spark import convention**: `col` is imported directly (high usage).
`functions` and `types` are aliased as `F` and `T` (e.g. `F.min`, `T.StringType()`).
`Window` and `DataFrame` (for type hints) are imported from `pyspark.sql`.

## Databricks Notebook Parameters

Follows imports. First line: `dbutils.widgets.removeAll()` to clear and rebuild widget
state. Declaration and consumption in the same cell unless widget count is large (>15),
then split across two cells.
Widget values are parsed into typed Python variables and logged immediately.
Required params are asserted.

```python
dbutils.widgets.removeAll()
dbutils.widgets.text("COUNTRY", "")
dbutils.widgets.dropdown("MERGE_SCHEMA", "False", ["True", "False"])
dbutils.widgets.dropdown("ENABLE_CACHING", "True", ["True", "False"])
dbutils.widgets.dropdown("LOAD_TYPE", "incremental", ["incremental", "full"])
dbutils.widgets.dropdown("MODE", "dev", ["dev", "prod"])

COUNTRY: str = dbutils.widgets.get("COUNTRY")
MERGE_SCHEMA: bool = dbutils.widgets.get("MERGE_SCHEMA").lower() == "true"
ENABLE_CACHING: bool = dbutils.widgets.get("ENABLE_CACHING").lower() == "true"
LOAD_TYPE: str = dbutils.widgets.get("LOAD_TYPE")
MODE: str = dbutils.widgets.get("MODE")

logger.info(f"{COUNTRY=}")
logger.info(f"{MERGE_SCHEMA=}")
logger.info(f"{LOAD_TYPE=}")
logger.info(f"{ENABLE_CACHING=}")
logger.info(f"{MODE=}")

assert all(
    [COUNTRY, MERGE_SCHEMA is not None, LOAD_TYPE, ENABLE_CACHING is not None, MODE]
), "One or more required params is not present"
```

Not all widgets apply to every pipeline.
Common widgets:

| Widget | Description |
| --- | --- |
| `LOAD_TYPE` | `incremental` (new data only) or `full` (complete reload/playback). Implementation varies per notebook. |
| `MERGE_SCHEMA` | Enables schema evolution on the target table. Default blocked; opt-in with `true`. Always prefer this as a param for UC table writes. |
| `MODE` | `dev` = preview intermediate results, skip final save. `prod` = no previews, save final results only. |
| `ENABLE_CACHING` | Toggle `.cache()` — serverless computes self-optimize caching, so disable when running serverless. |

Data-value filters like `COUNTRY` or `TIME_FILTER` are allowed when applicable.

## Definitions

Define non-widget globals, including input/output table names (single source of truth
for editing).

```python
DT: str = "datetime_timestamp"
SIMILARITY_THRESHOLD: int = 0.9

INPUT_ENTITY_TABLE: str = "raw.sales.provider_entity"
INPUT_LINE_ITEM_TABLE: str = "raw.sales.provider_line_item"

OUTPUT_TABLE: str = "curated.sales.provider_entity"

logger.debug(f"{INPUT_ENTITY_TABLE=}")
logger.debug(f"{INPUT_LINE_ITEM_TABLE=}")

logger.warning(f"{OUTPUT_TABLE=}")
```

## Utility Functions

Define modularized functions in cells after definitions.
These cells define only — no invocations.
Functions must be type-hinted (args and return), well-formatted, and named as
`<verb>_<entity>` (e.g. `get_place_name`, `generate_credentials`).

## Read Input Tables

- Read all required tables in the next few cells.
  Filter and cache relevant subsets using `ENABLE_CACHING`.
- UC tables should not be read ad-hoc later — define them as filtered DataFrames early.
- Prefer PySpark DataFrame API (`spark.table`, `spark.read.format` with chained
  operations) over `spark.sql` or `F.expr`.
- When extracting scalar values from a DataFrame (e.g. latest timestamp), use
  `.toPandas()['<col>'].iloc[0]` — never `.collect()`. All small value extractions
  should prefer `.toPandas()`.

### Incremental Loading

When `LOAD_TYPE == "incremental"`, watermarking / delineation of new rows should occur
during the read phase, before caching.
This ensures the pipeline only processes data destined for the output table.
A common pattern: `left_anti` join on distinct keys against the existing output table.

```python
df: DataFrame = (
    spark.table(INPUT_TABLE)
    .filter(col("status_code") == 200)
    .select(
        "email",
        "org_id",
        "order_id",
        F.variant_get("raw_json", "$.status", "string").alias("order_status"),
        F.variant_get("raw_json", "$.amount.fractional", "int").alias("amount_fractional"),
        # … unwrap every field the curated table needs into a typed column.
        # Do NOT carry `raw_json`, `url`, or `status_code` into the curated tier —
        # the curated catalog holds parsed business data only.
        "datetime_timestamp",
    )
)

if TARGET_EMAIL:
    df = df.filter(col("email") == TARGET_EMAIL)

if LOAD_TYPE == "incremental" and spark.catalog.tableExists(OUTPUT_TABLE):
    existing_batches_df: DataFrame = (
        spark.table(OUTPUT_TABLE)
        .select("email", "org_id", "order_id")
        .distinct()
    )

    if not existing_batches_df.isEmpty():
        df = df.join(
            F.broadcast(existing_batches_df),
            on=["email", "org_id", "order_id"],
            how="left_anti",
        )

if ENABLE_CACHING:
    df = df.cache()

logger.info(f"{df.count()=:,}")
```

Key patterns: pre-select only essential fields before anti-join, broadcast the output
table keys when applicable, cache the final incremental result.

## Transformation Conventions

- Prefer PySpark functions (`F.coalesce()`, `F.explode()`, etc.)
  over `spark.sql()` or `F.expr`.
- No meaningless column names (single letters, bare underscores).
  Source-data underscores are acceptable; your own intermediate fields are not.
- DataFrame variables end with `_df` (not `df_` prefix).
  Aggregated variants can use `_agg_df`.
- DataFrame variable names must evolve after transformations/aggregations — enables
  downstream caching and debugging without re-running all cells.
- Before joins, rename fields to match and select only relevant columns from each side.
  This avoids aliased `select` cleanup afterward.

Prefer:
```python
one_df.select("country", "source_id", "country_name").join(
    two_df.select("country", col("native_id").alias("source_id"), "place_address"),
    on=["country", "source_id"],
)
```

Over:
```python
one_df.alias("one").join(
    two_df.alias("two"),
    on=[
        col("one.country") == col("two.country"),
        col("one.source_id") == col("two.native_id"),
    ],
).select(
    "one.country",
    "two.source_id",
    "one.country_name",
    "one.place_name",
    "two.place_address",
)
```

Aliases are acceptable when the above pattern genuinely doesn’t fit.

## Curated-Tier Output Schema (hard rules)

When the notebook writes to a curated catalog (anything downstream of the raw ingest
tier), the resulting Delta schema MUST contain only business data.
The following columns are **forbidden** on curated tables:

- **`raw_json`** (or any other `VARIANT` column holding a verbatim API payload).
  The extract notebook is responsible for unwrapping every field the downstream cares
  about into a typed column.
  If a payload field is not worth flattening, it is not worth keeping.
  Punting `variant_get` to downstream consumers defeats the point of the curated tier.
- **`url`**. Request URLs are request metadata; they belong to the raw audit log and the
  ingest notebook source code, not the curated row.
- **`status_code`**. Curated rows already imply `status_code == 200` (extracts filter
  non-200 rows out at read time).

Additional unwrapping rules:

- **Unwrap envelope-shaped values.** Many provider APIs wrap scalars in
  `{"value": <x>, "value_formatting": {"type": "…", "currency_code": "…"}}` envelopes.
  Persist only `<x>` as a typed column.
  Move the unit / currency to its own column when it varies per row, or to the column
  comment when intrinsic.
  Trend deltas (`trend_indicator.value`) get their own `_trend` column.
- **Explode arrays into per-row records.** When the API returns a list (top line items,
  daily breakdown, per-day activity windows, opt-in event log, …), the curated row
  granularity becomes one row per array element with a stable composite PK. Do not stash
  arrays in `VARIANT`.
- **Split mixed-grain payloads** into multiple curated tables when one response carries
  both a per-entity summary and a per-day timeseries.

The gold standard is a fully-flattened curated layout: every curated table is typed
end-to-end with zero `raw_json` / `url` / `status_code` leak-through.

- Use `assert` statements after transformations on cached DataFrames to catch unexpected
  empty results. Typically follows the `logger` statement that outputs the count.
