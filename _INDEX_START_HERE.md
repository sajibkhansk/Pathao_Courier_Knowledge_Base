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

Key notes: [[03_Business_Logic/cds_key_descriptions.md|cds_key_descriptions]] (enum mappings), [[03_Business_Logic/cds_task_management_logic.md|CDS task management]], [[03_Business_Logic/order_status_changes_human_oracle.md|OSC oracle]], [[03_Business_Logic/merchant_logic_human_oracle.md|merchant logic]], [[03_Business_Logic/hub_facility_logic_human_oracle.md|hub facility logic]], [[03_Business_Logic/ir_kobiraj_logic_human_oracle.md|IR/Kobiraj logic]], [[03_Business_Logic/open_orders_business_logic.md|open orders]], [[03_Business_Logic/price_change_logic.md|price change]], [[03_Business_Logic/return_revamp_logic.md|return revamp]], [[03_Business_Logic/run_routes_human_oracle.md|run routes]], [[03_Business_Logic/order_fields_human_oracle.md|order fields]], [[03_Business_Logic/phase2_open_enum_mappings.md|open enum mappings]].

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
- `crm_onboard_logic.md` — CRM onboarding window logic, KPI bonus formula (0/0.005/0.02), revenue formula, processed orders definition, forecast and target logic. Source: Dashboard 154.
- `crm_merchant_attribution.md` — CRM merchant-to-lead matching with merchant_id primary + phone fallback. Two implementation patterns (UNION ALL vs OR-join). Source: Dashboard 154.
- `open_orders_business_logic.md` — Open order status definition (use `on_process` from `courier_transfer_status` for open orders; use `is_processed` for successful/processed volume), default filters, section/responsible logic notes, return order aging rule, aging buckets, and known card patterns from Open Orders collection.
- `price_change_logic.md` — Price Change / COD Reduction logic from Phase 3: use OSC logs for collectable amount changes, merchant OTP meaning, tunable flagging thresholds, delivered vs exchange inclusion, and observed Price Change card catalog.
- `crm-kam-feedback-analysis.md` — KAM feedback analysis rules: `detailed_response` is primary analytical field, dashboard naming (Monthly KAM Feedback = Monthly Merchant Feedback id 191), data quality warning (63% dissatisfaction_reason_id = 40 unresolvable).
- `return-aging-logic.md` — Return aging calculation from Card #1360: start (created_at/sorted_at/lmh_at) → end (transfer_status_updated_at), DATE_DIFF in whole days, statuses 21/35 only, UNION ALL live+archive requirement.
- `cds_task_management_logic.md` — CDS task-management platform meaning, direct `public.requests` reporting source, dashboard-aligned open/closed/unassigned definitions, and CDS Summary rules.

### 04_SQL_Patterns
Use for reusable SQL snippets and implementation details: partition elimination, timezone handling, date windows, dedupe patterns, Metabase parameter conventions.

Key notes: [[04_SQL_Patterns/cds_cte_patterns.md|cds_cte_patterns]] (reusable CTEs), [[04_SQL_Patterns/phase2_initial_table_patterns.md|initial table patterns]], [[04_SQL_Patterns/run_routes_transfer_basket_patterns.md|run routes patterns]].

Current files:
- `README.md` — folder purpose.
- `phase2_initial_table_patterns.md` — initial datastream partition, order filter, return/reverse grain, and event timestamp patterns.
- `cds_cte_patterns.md` — reusable CDS CTE snippets for orders, merchants, hubs, invoices, payments, regions/zones/stores, merchant users, and wallet info.
- `run_routes_transfer_basket_patterns.md` — SQL patterns for transfer runs, direct/bulk assignments, basket-contained parcels, and `Run Closed` payload count extraction.

### 05-HERMES-OUTPUTS
Generated analysis outputs, draft investigations, and data artifacts. Notes here are NOT canonical — promote to `03_Business_Logic/` or `04_SQL_Patterns/` only after validation. All outputs go to `05-HERMES-OUTPUTS/analyses/`.

Current notes:
- `cpo-lmh-routing-investigation-2026-06-21.md` — CPO-to-LMH Routing Investigation (June 2026)

### 07-FEEDBACK-INBOX
Feedback and knowledge observations pending human review. Entries are append-only and never automatically promoted to canonical knowledge.

See: [[07-FEEDBACK-INBOX/_README.md|Feedback Inbox Guide]]

### 09_Projects
Structured project work — analyses, automations, investigations, and tools that produce multiple output files. One subfolder per project with its own code, data, and findings.

See: [[09_Projects/README.md|Projects Index]]

### 06-SYSTEM
System configuration, agent instructions, and the semantic layer (canonical metric/table definitions).

See: [[06-SYSTEM/semantic-layer/glossary.md|glossary]], [[06-SYSTEM/semantic-layer/relationships.md|table relationships]], [[06-SYSTEM/query-standards.md|SQL query standards]], [[06-SYSTEM/CLAUDE.md|CLAUDE.md (agent instructions)]], [[06-SYSTEM/MEMORY.md|MEMORY.md]], and [[06-SYSTEM/feedback-log.md|feedback-log]].

Key semantic notes:
- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]] — primary operational fact table
- [[06-SYSTEM/semantic-layer/tables/public_merchants.md|public_merchants]] — merchant registry
- [[06-SYSTEM/semantic-layer/tables/public_archived_orders.md|public_archived_orders]] — archived orders (historical completeness)
- [[06-SYSTEM/semantic-layer/tables/public_ties_merchant.md|public_ties_merchant]] — merchant-to-team assignment
- [[06-SYSTEM/semantic-layer/tables/new_onboards.md|new_onboards]] — CRM lead/onboarding table with CAST join chain to team names
- [[06-SYSTEM/semantic-layer/tables/crm_user_targets.md|crm_user_targets]] — per-acquisition-member monthly order/revenue targets
- [[06-SYSTEM/semantic-layer/tables/business_team_targets.md|business_team_targets]] — monthly targets
- [[06-SYSTEM/semantic-layer/metrics/delivery_rate.md|delivery_rate]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|business_team_mtd_revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|business_team_mtd_processed_orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|business_team_forecasting]]

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
