# Hermes Knowledge Base — Index Start Here

Purpose: persistent Markdown knowledge base for Pathao Courier SQL generation, business rules, data dictionary, and reusable Metabase/BigQuery patterns.

Status: Phase 1 Domain Basics documented. Phase 2 database profiling is in progress. CDS SQL snippets have been extracted and documented as a source of truth for reusable key descriptions and CTE patterns.

## Global Terminology Note

- In Pathao Courier context, **Hermes** usually means Pathao's internal OMS / panel used by operations and panel users.
- Do not confuse **Hermes OMS / panel** with **Hermes Agent**, the autonomous AI runtime used by this assistant.

## State Control Files

- `00_WORKING_STATE.md` — mandatory external state anchor for HITL continuation. Read this file before every KB turn and update it before ending any turn after Human Oracle answers.
- `00_STRUCTURE_AUDIT.md` — latest structure/placement audit, including flagged items that may need reorganizing.

## Directory Map

### 01_Domain_Basics
Use for core business model concepts: courier terms, C2C vs B2B, hub categories, SLA vocabulary, reverse flows, operational lifecycle definitions.

Current files:
- `README.md` — Phase 1 Human Oracle answers: B2C/C2C, hub types, SLA matrix, reverse pickup vs return, consignment prefixes.

### 02_Data_Dictionary
Use for table/column-level documentation: primary keys, important columns, JSON payload meanings, enums, table grains, join keys.

Current files:
- `README.md` — folder purpose.
- `core_tables_phase2_profile.md` — initial profiles for `public_orders`, `public_order_status_changes`, `public_run_routes`, `public_run_routes_orders`, `public_hubs`, and supporting `public_merchants`.
- `cds_sql_snippets_raw.json` — raw export from CDS `/api/sql-snippets`; do not treat as polished docs, use it as source evidence.

### 03_Business_Logic
Use for reusable rules: status ID meanings, hub type mappings, exclusion rules, magic numbers, operational cutoffs, team/merchant identifiers.

Current files:
- `README.md` — folder purpose.
- `phase2_open_enum_mappings.md` — resolved/open enum/status/type mappings after Human Oracle and CDS extraction.
- `cds_key_descriptions.md` — extracted CDS key-description and case-function mappings: `order_type_id`, `merchant_type`, OSC type, run-route transfer type, invoice/payment statuses, item types, agent roles, distance IDs, and dispatch statuses.
- `order_fields_human_oracle.md` — Human Oracle meanings for `public_orders.next_status`, `is_incomplete`, `closebox_status`, and `payment_status_id`.
- `order_status_changes_human_oracle.md` — Human Oracle meanings for OSC status label/grouping sources, `visibility`, `is_public`, `caused_by`, `author_id`, and old/new payload extraction.
- `run_routes_human_oracle.md` — Human Oracle meanings for `public_run_routes.run_route_type`, `transfer_type`, basket/direct parcel assignment, `is_close`, `status_id`, and ignored fields.
- `hub_facility_logic_human_oracle.md` — canonical Human Oracle rules for hub operation types, central sort, sub-sort, sub-hub/booking point, LMH, hub `type`, `tier_type`, and deprecated hub JSON fields.
- `merchant_logic_human_oracle.md` — Human Oracle rules for merchant classification sourcing (`merchant_type` is reliable, `merchant_category`/`product_category`/`category` are not), `source` panel mapping, KAM assignment threshold, and CRM DB.
- `ir_kobiraj_logic_human_oracle.md` — IR/Kobiraj issue lifecycle, status meanings, tag_type mapping, team mappings, SLA logic, and known card patterns from Phase 3 Metabase deep dive.
- `return_revamp_logic.md` — Return lifecycle statuses (43/25/44/11), cycle detection pattern, and Return Revamp dashboard card catalog.
- `open_orders_business_logic.md` — Open order status definition (use `on_process` from `courier_transfer_status`), default filters, section/responsible logic notes, return order aging rule, aging buckets, and known card patterns from Open Orders collection.
- `price_change_logic.md` — Price Change / COD Reduction logic from Phase 3: use OSC logs for collectable amount changes, merchant OTP meaning, tunable flagging thresholds, delivered vs exchange inclusion, and observed Price Change card catalog.

### 04_SQL_Patterns
Use for reusable SQL snippets and implementation details: partition elimination, timezone handling, date windows, dedupe patterns, Metabase parameter conventions.

Current files:
- `README.md` — folder purpose.
- `phase2_initial_table_patterns.md` — initial datastream partition, order filter, return/reverse grain, and event timestamp patterns.
- `cds_cte_patterns.md` — reusable CDS CTE snippets for orders, merchants, hubs, invoices, payments, regions/zones/stores, merchant users, and wallet info.
- `run_routes_transfer_basket_patterns.md` — SQL patterns for transfer runs, direct/bulk assignments, basket-contained parcels, and `Run Closed` payload count extraction.

## Operating Rules

- **Never guess** ambiguous IDs, statuses, types, JSON keys, or business meanings.
- **Check CDS SQL snippets first** for reusable key descriptions, case functions, and base CTEs before asking the Human Oracle.
- **Ask maximum 3–4 related questions** per prompt.
- **Document every Human Oracle answer** before moving to the next phase.
- **Prefer courier_realtime_datastream** for stakeholder-facing courier analytics unless explicitly told otherwise.
- **Keep Markdown optimized for AI retrieval:** bullets, exact SQL snippets, labels, examples, and open-question sections.
- **Update this index** whenever a file is created, renamed, or a new folder/topic is added.

## Phase Roadmap

1. Phase 1 — Domain Basics: documented.
2. Phase 2 — Database Profiling & Table Logic: in progress.
3. Phase 3 — Metabase Deep Dive: pending.
4. Phase 4 — Dynamic Refinement: continuous.
