# CRM Merchant Attribution

> **Source:** Dashboard 154 — CRM Managers Dashboard (10 cards)
> **Promoted:** 2026-06-19
> **Confidence:** High

## Rule

CRM leads are matched to merchants using a two-path fallback strategy:

1. **Primary: merchant_id match**
   `new_onboards.merchant_id = public_merchants.id` (when `merchant_id IS NOT NULL`)

2. **Fallback: phone match**
   `new_onboards.phone = public_merchants.phone` (when `merchant_id IS NULL`)

## Implementation Patterns

### Pattern A: UNION ALL (cards 2029, 2050, 2114, 2402)

```sql
merchants_by_merchant_id AS (
  SELECT m.*, DATE(nob.created_at) AS leads_created_at
  FROM public_merchants m
  JOIN new_onboards nob ON m.id = nob.merchant_id AND nob.merchant_id IS NOT NULL
  WHERE m.updated_at IS NOT NULL AND m.kam_id IS NULL
),
merchants_by_phone AS (
  SELECT m.*, DATE(nob.created_at) AS leads_created_at
  FROM public_merchants m
  JOIN new_onboards nob ON m.phone = nob.phone AND nob.merchant_id IS NULL
  WHERE m.updated_at IS NOT NULL AND m.kam_id IS NULL
),
merchants AS (
  SELECT * FROM merchants_by_merchant_id
  UNION ALL
  SELECT * FROM merchants_by_phone
)
```

### Pattern B: OR-join (cards 2031, 2260, 2262, 2060, 2400)

```sql
merchants AS (
  SELECT m.*, DATE(nob.created_at) AS leads_created_at
  FROM public_merchants m
  LEFT JOIN new_onboards nob
  ON (
    (nob.merchant_id IS NOT NULL AND m.id = nob.merchant_id)
    OR (nob.merchant_id IS NULL AND m.phone = nob.phone)
  )
  WHERE m.updated_at IS NOT NULL
    AND nob.created_at IS NOT NULL
    AND m.kam_id IS NULL
)
```

### Pattern C: Final output join (cards 2033)

```sql
LEFT JOIN final f
  ON (
    (n.merchant_id IS NOT NULL AND f.merchant_id = n.merchant_id)
    OR (n.merchant_id IS NULL AND f.phone = n.phone)
  )
```

## Rationale

Phone fallback catches CRM leads that were onboarded before a `merchant_id` was attached to the new_onboards record. This is a historical data gap — these leads would otherwise be invisible to merchant-level analytics.

## Exclusion Rules

| Rule | Filter | Applied By |
|---|---|---|
| KAM exclusion | `m.kam_id IS NULL` | All 10 attribution cards |
| Merchant freshness | `m.updated_at IS NOT NULL` | All 10 attribution cards |
| Country scope | `country_id = 1` (orders) | All order CTEs |

⚠️ A merchant matching on BOTH paths (has merchant_id AND phone matches another lead's phone) could appear twice in UNION ALL implementations. The join conditions are structured to partition leads (merchant_id-present vs merchant_id-NULL) to prevent this, but verify at query time.
