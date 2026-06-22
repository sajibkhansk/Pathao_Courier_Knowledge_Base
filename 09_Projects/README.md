# Projects

**Purpose:** Structured project work — analyses, automations, investigations, and tools that produce multiple output files (code, data, findings, reports). Each project gets its own subfolder.

## Structure

```
09_Projects/
├── README.md                        ← This file — project index
├── project-name-1/                  ← One folder per project
│   ├── README.md                    ← Project scope, data sources, status
│   ├── scripts/                     ← Python, SQL, or shell code
│   ├── data/                        ← Generated outputs, CSVs, JSONs
│   └── findings.md                  ← Results, observations, decisions
└── project-name-2/
    ...
```

## Active Projects

*(Add projects here as they are created — include name, brief scope, status, and date)*

## Guidelines

- Each project folder is self-contained. Keep all scripts, data, and documentation inside.
- Raw observations that may become reusable business rules go to `07-FEEDBACK-INBOX/` for review.
- Reusable knowledge confirmed from a project gets promoted to `03_Business_Logic/` or `04_SQL_Patterns/`.
- Large data files (50MB+) should not be committed. Use a `.gitignore` per project if needed.
