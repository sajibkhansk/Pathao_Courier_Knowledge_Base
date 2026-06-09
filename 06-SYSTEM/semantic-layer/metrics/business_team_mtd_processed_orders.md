# Metric: Business Team MTD Processed Orders

## Definition

Count of eligible processed orders for the month-to-date Dashboard 31 period, excluding current day.

## Dashboard 31 Default Date Window

When `current_month = 'Yes'`:

```sql
DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)
AND DATE(sorted_at) < CURRENT_DATE()
```

Retail/Point/Booking Point cards are an exception in some SQL and use `DATE(created_at)`.

## Eligible Statuses Observed

Primary set used for processed count / target:

```sql
transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42,43,44)
```

Revenue cards often use the same set without `43,44`:

```sql
transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
```

## Segment Filters

- MTM: `merchant_id IN (SELECT merchant_id FROM public_ties_merchant WHERE ties_id = 67)`
- KAM: `merchant_id IN (SELECT merchant_id FROM public_ties_merchant WHERE ties_id = 68)`
- Retail / Point / Booking Point: `order_type_id IN (16,18)`
- Total: no segment filter except country and dashboard process merchant filters.

## Dashboard 31 Merchant Filter

Use `merchant_id <> 1` for this dashboard process.
