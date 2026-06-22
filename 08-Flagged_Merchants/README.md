# Flagged Merchants Report
**Date:** 2026-06-22
**Source:** Slab-wise discount threshold analysis (item_type=2, delivery_type=48)

## Thresholds Applied
- ISD-ISD: < 45 BDT
- ISD-RSD / RSD-ISD / RSD-RSD: < 65 BDT
- ISD-OSD / RSD-OSD / OSD-ISD / OSD-RSD / OSD-OSD: < 85 BDT

## Summary
- **Total flagged:** 2000 merchants
- **Corporate excluded:** merchant_type=4 removed
- **Rule:** Any slab where `(base_cost - discount) >= threshold` → flagged

## Files
- [[08-Flagged_Merchants/flagged_merchants_clean.csv]]
'','', '','')

### Top Flagged Merchants (most violations)
| MID | Name | Slabs Flagged | Zones | Pickup Hub |
|-----|------|--------------|-------|------------|
| 673 | Femalo | 18 | 9 | Malibagh(ISD); Gazipur-Kapasia(RSD) |
| 659 | Modest Collection | 15 | 8 | Farmgate(ISD) |
| 627 | KINENAO | 14 | 8 | Mirpur-1(ISD); Shewrapara(ISD) |
| 625 | Pillow Platoon | 13 | 8 | Bashabo(ISD) |
| 62121 | Delivery Express Ltd | 18 | 9 | Narayanganj(RSD); Bandar(RSD) |
| 673 | Femalo | 18 | 9 | Malibagh(ISD); Gazipur-Kapasia(RSD) |

## Not Flagged (pass all thresholds)
- Alishop (MID=121354)
- Knowledge Publications (MID=258091)
- Taza Hair Oil (MID=305171)
- Daraz Bangladesh CP (MID=302566)
- Believer's Shop (MID=186030)
- Rabeya Fashion House (MID=327086)
- Falaq Food (MID=95357)
- Tabassum fashion (MID=329482)
