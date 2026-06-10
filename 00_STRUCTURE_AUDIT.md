# KB Structure Audit

Status: audit created after user asked whether existing files are in the right place and whether anything seems misplaced.

Audit scope:
- `_INDEX_START_HERE.md`
- `00_WORKING_STATE.md`
- all current Markdown files under `01_Domain_Basics`, `02_Data_Dictionary`, `03_Business_Logic`, and `04_SQL_Patterns`

## Cleanup Actions Completed After User Approval

User said: "Carry out your recommendations."

Completed actions:
1. Added global Hermes OMS vs Hermes Agent note to:
   - `_INDEX_START_HERE.md`
   - `01_Domain_Basics/README.md`
2. Created dedicated SQL pattern file:
   - `04_SQL_Patterns/run_routes_transfer_basket_patterns.md`
3. Replaced the large SQL sample at the bottom of `03_Business_Logic/run_routes_human_oracle.md` with a pointer to the new SQL pattern file.
4. Created dedicated hub/facility logic file:
   - `03_Business_Logic/hub_facility_logic_human_oracle.md`
5. Kept `03_Business_Logic/phase2_open_enum_mappings.md` as the active tracker rather than renaming it.

## Overall Assessment

The KB is mostly coherent and usable. The main structure is correct:

- `01_Domain_Basics` stores business terminology and operating definitions.
- `02_Data_Dictionary` stores table/column profiles and raw CDS evidence.
- `03_Business_Logic` stores field meanings, enum mappings, and Human Oracle business rules.
- `04_SQL_Patterns` stores reusable query/CTE patterns.
- `_INDEX_START_HERE.md` and `00_WORKING_STATE.md` now provide the continuation anchors that were missing in earlier context-loss sessions.

## Issues Fixed During This Audit

### 1. Stale open questions in `01_Domain_Basics/README.md`

Problem:
- The file still said OSD/RSD hub_operation_type values needed confirmation.
- It also still asked whether reverse pickup maps to `order_type = 3`, even though later docs confirmed `order_type_id = 3`.

Action taken:
- Updated the bottom section to distinguish resolved vs remaining questions.
- Kept the remaining merchant-classification question open.

Updated file:
- `01_Domain_Basics/README.md`

## Items That Seem Slightly Out of Place / Need Your Decision

### A. Hub type / central sort details are duplicated across Domain Basics and Data Dictionary

Current locations:
- `01_Domain_Basics/README.md`
- `02_Data_Dictionary/core_tables_phase2_profile.md`
- `03_Business_Logic/phase2_open_enum_mappings.md`

Assessment:
- Not harmful. The Domain Basics file has the business-language explanation, while Data Dictionary has table-level field context.
- But central sort/sub-sort/sub-hub details are becoming large enough that a dedicated file may be easier for future retrieval.

Recommendation:
- Create `03_Business_Logic/hub_facility_logic_human_oracle.md` and move/copy canonical hub/facility rules there, while keeping a short summary in Domain Basics.

Decision needed:
- Should I create this dedicated hub/facility logic file?

### B. `run_routes_human_oracle.md` contains both business meanings and a large SQL pattern

Current location:
- `03_Business_Logic/run_routes_human_oracle.md`

Assessment:
- The business meanings belong in `03_Business_Logic`.
- The sample SQL for transfer runs / basket + direct parcel assignments would be easier to find under `04_SQL_Patterns`.

Recommendation:
- Keep business meanings in `03_Business_Logic/run_routes_human_oracle.md`.
- Move or duplicate the sample SQL pattern into `04_SQL_Patterns/run_routes_transfer_basket_patterns.md`.

Decision needed:
- Should I split this into a SQL-pattern file?

### C. Raw CDS JSON is in `02_Data_Dictionary`

Current location:
- `02_Data_Dictionary/cds_sql_snippets_raw.json`

Assessment:
- Acceptable as source evidence because it supports data dictionary and enum mappings.
- But as raw extracted source data, it could also live in a `00_Raw_Sources` or `99_Raw_Exports` folder.

Recommendation:
- Leave it where it is unless the KB grows significantly.

Decision needed:
- No immediate action recommended.

### D. Hermes OMS vs Hermes Agent note is buried in OSC file

Current location:
- `03_Business_Logic/order_status_changes_human_oracle.md`

Assessment:
- The note is correct but more global than OSC.
- Future sessions may miss it if they do not open the OSC file.

Recommendation:
- Add a short global note to `_INDEX_START_HERE.md` and/or `01_Domain_Basics/README.md`:
  - In Pathao Courier context, Hermes usually means the internal OMS/panel, not Hermes Agent.

Decision needed:
- Should I add this global note to the index/domain basics?

### E. `phase2_open_enum_mappings.md` mixes resolved mappings and open gaps

Current location:
- `03_Business_Logic/phase2_open_enum_mappings.md`

Assessment:
- This is okay as a phase tracker, but the name can be misleading because much of it is now resolved.

Recommendation:
- Either keep as a tracker, or rename/copy into `phase2_enum_mapping_tracker.md`.

Decision needed:
- Keep current filename, or rename to a clearer tracker name?

## Priority Recommendations

If we clean up now, I suggest this order:

1. Add global Hermes OMS vs Hermes Agent note to `_INDEX_START_HERE.md` and `01_Domain_Basics/README.md`.
2. Split run-route SQL patterns into `04_SQL_Patterns/run_routes_transfer_basket_patterns.md`.
3. Create `03_Business_Logic/hub_facility_logic_human_oracle.md` for canonical hub/facility terminology.
4. Keep raw CDS JSON where it is.
5. Keep `phase2_open_enum_mappings.md` as the active tracker unless you want a rename.

## Pending User Decision Questions

1. Should I add the global Hermes OMS vs Hermes Agent note to the index/domain basics?
2. Should I split the run-route transfer/basket SQL sample into a dedicated SQL pattern file?
3. Should I create a dedicated hub/facility logic file for central sort, sub-sort, sub-hub, LMH, and hub type/tier rules?
4. Should `phase2_open_enum_mappings.md` stay as-is, or should I rename/copy it to `phase2_enum_mapping_tracker.md`?
