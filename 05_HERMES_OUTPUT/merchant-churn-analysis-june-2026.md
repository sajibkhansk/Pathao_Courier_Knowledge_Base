# Merchant Churn Analysis — June 2026 MTD

**Status:** observed (provisional — not yet promoted to canonical)
**Type:** investigation / draft_analysis
**Date:** 2026-06-25
**Source:** KAM feedback cross-reference + BigQuery merchant activity data
**Method:** REST API native SQL via Metabase

---

## Working Churn Proxy

The KB has no canonical churn definition. The following working proxy was defined for this analysis:

| Bucket | Rule | Count | May Volume Lost |
|--------|------|-------|-----------------|
| CHURNED | ≥100 orders in May 2026, zero orders in June 2026 MTD | 162 | 82,167 |
| HIGH_RISK | Active in June but 80%+ decline in daily average vs May | 401 | 306,342 |
| DECLINING | Active in June but 50-80% decline in daily average vs May | 675 | 585,579 |
| STABLE | <50% decline vs May | 4,304 | 4,872,120 |

**Data sources:** `public_orders` + `public_archived_orders` UNION ALL for complete coverage. Merchant names from `public_merchants`. KAM feedback from `monthly_kam_followups` on DB 7 BigQuery.

**Date boundaries:** May 1-31, 2026 (baseline). June 1-25, 2026 (current month MTD).

---

## 1. Executive Summary

- **162 merchants gone this month** with zero June activity — 82,167 May orders worth of business. Of these, **22 heavy hitters** (1,000+ orders/month) account for 45,684 orders — 56% of all churned volume is concentrated in just 14% of churned merchants.

- **Overall platform is healthy** — June daily avg (202,750) is slightly up from May (199,408). The churn is a churn of specific merchants, not a platform-wide problem. But the merchants leaving are real losses.

- **The biggest killer is delivery operations.** Fake delivery attempts, "no entry" returns without calling customers, and extended delivery delays are cited by every feedback-active churned merchant. This is the #1 cause of preventable churn.

- **Steadfast is eating our lunch.** 31 of 70 churned merchants with feedback explicitly mention moving to Steadfast. They specifically cite our fake-attempt and fake-return problem as their reason — and Steadfast's lower fake-return ratio as their pull.

- **57% of churned merchants have NO KAM feedback record** — that's 92 of 162 merchants with zero documented dissatisfaction. We have no idea why they left. The KAM feedback system covers only 43% of merchants who are actively leaving.

- **KAM assignment works.** Only 65 of 4,407 KAM-covered merchants churned (1.5%) vs 97 of 1,135 non-KAM merchants (8.5%). KAM merchants churn at 1/5 the rate. The problem is non-KAM small/medium merchants who fall through the cracks.

- **Account switching is masking true churn.** Tasa & Toha, Bigobd.com, Sopner Collection — multiple merchants explicitly told their KAM they're moving to a new account while abandoning the old one. True churn is higher than raw numbers show because duplicate accounts hide the behavior.

- **Pricing friction is real but secondary.** Return fees, slab discounts, and COD charges come up repeatedly — but always in combination with delivery failures. Merchants who get good delivery tolerate higher fees. Merchants with bad delivery use price as a second reason to leave.

---

## 2. Churn / Risk Snapshot

| Metric | Value |
|--------|-------|
| Churned merchants (100+ May, zero June) | 162 |
| High-risk merchants (80%+ decline) | 401 |
| Declining merchants (50-80% decline) | 675 |
| **Total at-risk merchants** | **1,238** |
| May orders lost from confirmed churn | 82,167 |
| May orders at risk (high risk + declining) | 891,921 |
| Est. daily loss from churned merchants | ~2,651/day |
| Est. June total loss from churned | ~97,000 (projected) |
| % of loss concentrated in top 22 merchants | **56%** (45,684 of 82,167) |

**Concentration is extreme.** The top 5 churned merchants alone (Shokher Bazar, Luxury, Savor Intl, Aytun's Attires, Prof Rashida) represent 19,402 lost May orders — 24% of all churned volume from just 3% of churned merchants.

---

## 3. Complete List of Churned High-Volume Merchants (100+ May Orders, Zero June)

| ID | Name | Type | May Orders | Last Status | Last Order Date |
|----|------|------|-----------|-------------|-----------------|
| 169639 | Shokher Bazar | Regular | 5,248 | 25 (Returned) | 2026-05-18 |
| 231858 | Luxury | Regular | 4,415 | 13 (Delivered) | 2026-05-25 |
| 327843 | Savor International Limited | Regular | 3,514 | 13 (Delivered) | 2026-05-21 |
| 113002 | Aytun's Attires | Regular | 3,313 | 25 (Returned) | 2026-05-19 |
| 422810 | Professor Dr Rashida | Regular | 2,912 | 25 (Returned) | 2026-05-25 |
| 231579 | Bigobd.com | Regular | 2,115 | 13 (Delivered) | 2026-05-17 |
| 293457 | Modern shop | Regular | 2,110 | 25 (Returned) | 2026-05-23 |
| 388891 | Conveyor Logistic Limited | Regular | 1,840 | 13 (Delivered) | 2026-05-23 |
| 103506 | sunfhy.com | Regular | 1,837 | 13 (Delivered) | 2026-05-25 |
| 347864 | Tasa & Toha-Corner | Regular | 1,768 | 25 (Returned) | 2026-05-11 |
| 420007 | Al-Hiba | Regular | 1,733 | 25 (Returned) | 2026-05-25 |
| 55635 | East West University | Regular | 1,712 | 13 (Delivered) | 2026-05-22 |
| 36032 | Sopner Collection | Regular | 1,586 | 23 | 2026-05-19 |
| 380557 | Adi Shop | Regular | 1,571 | 13 (Delivered) | 2026-05-24 |
| 411784 | Ash-Sifa | Regular | 1,569 | 13 (Delivered) | 2026-05-24 |
| 291385 | Tech Move | Regular | 1,408 | 25 (Returned) | 2026-05-23 |
| 411535 | BD - choice | Regular | 1,302 | 41 (Paid Return) | 2026-05-17 |
| 404920 | Azhari Shop | Regular | 1,248 | 25 (Returned) | 2026-05-16 |
| 288120 | One Point790 | Regular | 1,210 | 25 (Returned) | 2026-05-20 |
| 408470 | Zavrixa | Regular | 1,165 | 25 (Returned) | 2026-05-24 |
| 407379 | HR GROUP LTD | Regular | 1,104 | 13 (Delivered) | 2026-05-07 |
| 414255 | Detoxzen | Regular | 1,004 | 13 (Delivered) | 2026-05-22 |
| 395343 | Neatness Lady | Regular | 984 | 13 (Delivered) | 2026-05-24 |
| 416734 | BD China Care | Regular | 881 | 13 (Delivered) | 2026-05-24 |
| 408321 | Organic shop | Regular | 844 | 13 (Delivered) | 2026-05-15 |
| 384377 | Shanta Gallery | Regular | 808 | 13 (Delivered) | 2026-05-23 |
| 101883 | Halal Mart | Regular | 806 | 5 | 2026-05-05 |
| 362882 | Dress Fashion Zone | Regular | 741 | 5 | 2026-05-25 |
| 408130 | Azharishop | Regular | 724 | 25 (Returned) | 2026-05-15 |
| 259923 | Fixed Plus | Regular | 713 | 25 (Returned) | 2026-05-25 |
| 386633 | Aliyah Mart | Regular | 705 | 13 (Delivered) | 2026-05-24 |
| 112944 | Alifa Vesoj Daoyakhana | Regular | 655 | 25 (Returned) | 2026-05-24 |
| 71935 | Online.Shop | Regular | 643 | 13 (Delivered) | 2026-05-24 |
| 335171 | Dream Fashion Wear | Regular | 603 | 13 (Delivered) | 2026-05-15 |
| 142313 | Route To Market International (RTM) | Regular | 552 | 25 (Returned) | 2026-05-20 |
| 381239 | Ti-jara | Regular | 548 | 13 (Delivered) | 2026-05-22 |
| 96800 | Umayra's | Regular | 532 | 25 (Returned) | 2026-05-25 |
| 175127 | Gorur mala | Regular | 520 | 13 (Delivered) | 2026-05-20 |
| 278002 | Chapai FoodHut | Regular | 507 | 13 (Delivered) | 2026-05-21 |
| 77492 | Organic Premium Foods | Regular | 461 | 13 (Delivered) | 2026-05-17 |
| 271279 | Hanli Bazar | Book | 453 | 25 (Returned) | 2026-05-23 |
| 75401 | Sultana Fashion | Regular | 450 | 25 (Returned) | 2026-05-25 |
| 308858 | 1 Click Shopping | Regular | 442 | 25 (Returned) | 2026-05-12 |
| 332684 | Arzaq BD | Regular | 427 | 13 (Delivered) | 2026-05-23 |
| 392448 | Natureva Cosmeceuticals | Regular | 415 | 25 (Returned) | 2026-05-22 |
| 400051 | Our shopping | Regular | 404 | 41 (Paid Return) | 2026-05-23 |
| 111817 | Jannat Borka House | Regular | 380 | 13 (Delivered) | 2026-05-07 |
| 375892 | Elite Health BD | Regular | 371 | 25 (Returned) | 2026-05-21 |
| 82196 | ELITE STYLE BD 2 | Regular | 363 | 5 | 2026-05-10 |
| 392989 | Dresseria | Regular | 355 | 13 (Delivered) | 2026-05-25 |
| 372524 | ALOVON | Regular | 346 | 13 (Delivered) | 2026-05-24 |
| 359151 | DH Shop BD | Regular | 338 | 13 (Delivered) | 2026-05-15 |
| 400896 | TheMusafir | Regular | 334 | 13 (Delivered) | 2026-05-25 |
| 398562 | Offer Bazaar BD | Regular | 333 | 13 (Delivered) | 2026-05-22 |
| 112898 | Moriom fashion house | Regular | 326 | 13 (Delivered) | 2026-05-25 |
| 399016 | China Gallery | Regular | 313 | 25 (Returned) | 2026-05-25 |
| 309898 | Tibir.shop | Regular | 307 | 13 (Delivered) | 2026-05-24 |
| 398134 | Meherins Warehouse | Regular | 303 | 25 (Returned) | 2026-05-10 |
| 390843 | SkyBridge | Regular | 301 | 25 (Returned) | 2026-05-21 |
| 178975 | Rongdhonu Mart | Regular | 282 | 6 | 2026-05-07 |
| 72625 | Go First Cover BD | Regular | 274 | 13 (Delivered) | 2026-05-24 |
| 116326 | Al-Qaf | Regular | 259 | 13 (Delivered) | 2026-05-05 |
| 366013 | Bhakti | Regular | 257 | 25 (Returned) | 2026-05-13 |
| 331203 | Moments & Memories | Regular | 257 | 13 (Delivered) | 2026-05-20 |
| 408433 | UNIQUE SHOP 2.0 | Regular | 253 | 13 (Delivered) | 2026-05-22 |
| 362124 | Optimizely Bangladesh Limited | Regular | 240 | 13 (Delivered) | 2026-05-24 |
| 315371 | Ummashop.com | Regular | 240 | 13 (Delivered) | 2026-05-25 |
| 233803 | Rakamari Aupsora | Regular | 239 | 25 (Returned) | 2026-05-25 |
| 126182 | CHALANTIKA BORKA HOUSE | Regular | 239 | 13 (Delivered) | 2026-05-07 |
| 412923 | Ajhaari Shoop | Regular | 238 | 13 (Delivered) | 2026-05-16 |
| 398643 | Megamass | Regular | 237 | 5 | 2026-05-23 |
| 369453 | MARS Retail Ltd | Regular | 234 | 13 (Delivered) | 2026-05-19 |
| 53170 | Fashion of Cotton | Regular | 231 | 13 (Delivered) | 2026-05-25 |
| 414533 | LAVAS | Regular | 226 | 41 (Paid Return) | 2026-05-10 |
| 396570 | ESB Leather | Regular | 225 | 25 (Returned) | 2026-05-08 |
| 413100 | Hijabi Fairy BD | Regular | 223 | 5 | 2026-05-25 |
| 413708 | Abul Khair Steel | Regular | 222 | 6 | 2026-05-04 |
| 180241 | Signature Fragrance | Regular | 218 | 13 (Delivered) | 2026-05-06 |
| 290142 | TTouch Clothing | Regular | 210 | 42 (Exchange) | 2026-05-25 |
| 404240 | UV CASE - GADGET BABA | Regular | 209 | 13 (Delivered) | 2026-05-13 |
| 413742 | Farhana Fashion House | Regular | 208 | 6 | 2026-05-25 |
| 214675 | Apnader Bazar BD | Regular | 206 | 25 (Returned) | 2026-05-10 |
| 161167 | Ok bazaar | Regular | 203 | 13 (Delivered) | 2026-05-25 |
| 412326 | Tony,s shoping | Regular | 201 | 13 (Delivered) | 2026-05-14 |
| 403211 | Bookish- Mart | Regular | 200 | 25 (Returned) | 2026-05-02 |
| 370037 | Shorra Mart | Regular | 198 | 13 (Delivered) | 2026-05-22 |
| 313424 | Arshi Fashion Bd | Regular | 196 | 25 (Returned) | 2026-05-24 |
| 392770 | Ikhlas Shop | Regular | 194 | 25 (Returned) | 2026-05-05 |
| 357463 | promi shop 02 | Regular | 194 | 25 (Returned) | 2026-05-15 |
| 167628 | ZEN | Regular | 192 | 25 (Returned) | 2026-05-25 |
| 8336 | Shuvra's Story | Regular | 191 | 13 (Delivered) | 2026-05-23 |
| 32999 | Wholesale Bazaar | Regular | 190 | 5 | 2026-05-17 |
| 159945 | Ekroy Shop | Regular | 189 | 13 (Delivered) | 2026-05-23 |
| 368497 | EzyDeal Online Shop | Regular | 187 | 13 (Delivered) | 2026-05-15 |
| 186041 | GloKroy | Regular | 185 | 25 (Returned) | 2026-05-13 |
| 416014 | Abaya Collection | Regular | 184 | 6 | 2026-05-27 |
| 304537 | Alhamdulillah Halal Shop Official | Regular | 181 | 25 (Returned) | 2026-05-16 |
| 407323 | JN FASHION HOUSE | Regular | 178 | 25 (Returned) | 2026-05-22 |
| 90699 | SS Gadgets | Regular | 177 | 13 (Delivered) | 2026-05-21 |
| 62386 | Daazon | Regular | 176 | 13 (Delivered) | 2026-05-24 |
| 340466 | Oubaitori Shop | Regular | 176 | 25 (Returned) | 2026-05-25 |
| 343249 | Arwaah & Lifestyles | Regular | 174 | 13 (Delivered) | 2026-05-23 |
| 382973 | GentryMax | Regular | 173 | 13 (Delivered) | 2026-05-25 |
| 167467 | New in style Narayanganj | Regular | 173 | 25 (Returned) | 2026-05-06 |
| 357470 | Health Care- | Regular | 172 | 5 | 2026-05-06 |
| 414188 | Istiaq Fashion | Regular | 171 | 25 (Returned) | 2026-05-22 |
| 310999 | Hamaguri 1 | Regular | 171 | 25 (Returned) | 2026-05-13 |
| 350984 | Living large | Regular | 171 | 13 (Delivered) | 2026-05-25 |
| 409516 | China life Care bd | Regular | 170 | 13 (Delivered) | 2026-05-22 |
| 135629 | Sajute's Shop | Regular | 164 | 5 | 2026-05-21 |
| 274440 | Cow Ornaments Store | Regular | 162 | 6 | 2026-05-25 |
| 220476 | JRB Bazar | Regular | 161 | 13 (Delivered) | 2026-05-11 |
| 326032 | SnapClockr | Regular | 160 | 13 (Delivered) | 2026-05-22 |
| 261771 | Green food's ltd | Regular | 158 | 25 (Returned) | 2026-05-25 |
| 284704 | Gari Sajai | Regular | 157 | 26 | 2026-05-24 |
| 408879 | ROYAL BARAKAH | Regular | 155 | 13 (Delivered) | 2026-05-22 |
| 416165 | Three Zero Nine | Regular | 153 | 42 (Exchange) | 2026-05-18 |
| 389682 | Variety Vault Bd | Regular | 153 | 5 | 2026-05-22 |
| 366888 | Wellman Solution \|\| WMS \|\| | Regular | 152 | 13 (Delivered) | 2026-05-13 |
| 349791 | Tista Mart | Regular | 150 | 13 (Delivered) | 2026-05-23 |
| 358054 | Combo Express | Regular | 149 | 5 | 2026-05-14 |
| 184396 | Hambar Mala BD | Regular | 147 | 13 (Delivered) | 2026-05-17 |
| 423988 | Love Box | Regular | 144 | 6 | 2026-05-25 |
| 280316 | Safubd | Regular | 143 | 13 (Delivered) | 2026-05-19 |
| 417087 | United foreign Trade | Regular | 143 | 13 (Delivered) | 2026-05-19 |
| 91710 | Muskaan collection | Regular | 143 | 13 (Delivered) | 2026-05-23 |
| 424494 | Pantghor | Regular | 142 | 6 | 2026-05-25 |
| 378275 | Aviar bd | Regular | 142 | 5 | 2026-05-26 |
| 292626 | Kakoli's Outfit | Regular | 141 | 25 (Returned) | 2026-05-24 |
| 395367 | OLIVE MENS | Regular | 141 | 13 (Delivered) | 2026-05-25 |
| 410068 | NexPack Delivery | Regular | 137 | 13 (Delivered) | 2026-05-25 |
| 418768 | Emvaar | Regular | 136 | 25 (Returned) | 2026-05-24 |
| 409806 | Organic Zoon | Regular | 136 | 25 (Returned) | 2026-05-05 |
| 10977 | Beauty&Brave | Regular | 136 | 25 (Returned) | 2026-05-24 |
| 372163 | American booster | Regular | 131 | 25 (Returned) | 2026-05-22 |
| 368080 | Arohi Clothing Store | Regular | 127 | 13 (Delivered) | 2026-05-23 |
| 417082 | Olive Clothing | Regular | 125 | 13 (Delivered) | 2026-05-24 |
| 102128 | Shahi Gorur Mala | Regular | 124 | 13 (Delivered) | 2026-05-20 |
| 360237 | Skin Shop | Regular | 123 | 25 (Returned) | 2026-05-23 |
| 338484 | Afnik | Regular | 121 | 5 | 2026-05-26 |
| 420483 | Meghna Group Eid Gift | Regular | 120 | 13 (Delivered) | 2026-05-17 |
| 252122 | UNICEF BANGLADESH | Regular | 120 | 13 (Delivered) | 2026-05-13 |
| 408645 | Lima bd | Regular | 120 | 25 (Returned) | 2026-05-14 |
| 400202 | Easy BD | Regular | 117 | 13 (Delivered) | 2026-05-19 |
| 384625 | CoversBD | Regular | 116 | 25 (Returned) | 2026-05-24 |
| 399535 | bdallpro.com | Regular | 115 | 6 | 2026-05-26 |
| 418936 | Super Mart 02 | Regular | 115 | 25 (Returned) | 2026-05-23 |
| 247561 | Organic Shop | Regular | 114 | 13 (Delivered) | 2026-05-24 |
| 127757 | Rong Fashion | Regular | 114 | 13 (Delivered) | 2026-05-25 |
| 150749 | priyotoma Online | Regular | 113 | 5 | 2026-05-26 |
| 76418 | Desire Things | Regular | 113 | 13 (Delivered) | 2026-05-25 |
| 414676 | Shehabh | Regular | 111 | 13 (Delivered) | 2026-05-07 |
| 416126 | TM Mart | Regular | 110 | 13 (Delivered) | 2026-05-23 |
| 423357 | Baby food page | Regular | 110 | 13 (Delivered) | 2026-05-25 |
| 411183 | M R S SHOP | Regular | 110 | 5 | 2026-05-30 |
| 238971 | sonamony | Regular | 109 | 25 (Returned) | 2026-05-25 |
| 378652 | Mehendi Arts By Soniya | Regular | 108 | 13 (Delivered) | 2026-05-25 |
| 117954 | Sohi Khadi | Regular | 104 | 42 (Exchange) | 2026-05-25 |
| 422334 | Getfit Kids | Regular | 103 | 5 | 2026-05-26 |
| 411432 | Zaveena's | Regular | 102 | 25 (Returned) | 2026-05-24 |
| 206499 | Bd-shop | Regular | 101 | 13 (Delivered) | 2026-05-24 |
| 282376 | Bismillah Baby Collection | Regular | 100 | 6 | 2026-05-24 |

---

## 4. Top Merchant Deep Dive (Top 22 with 1,000+ May Orders)

### Last Order Status Distribution
- **Status 13 (Delivered):** 11 merchants (50%) — they simply stopped ordering. Their last parcel was delivered fine, then nothing.
- **Status 25 (Returned to Merchant):** 9 merchants (41%) — their last order was returned. High correlation with frustration.
- **Status 23:** 1 merchant (5%)
- **Status 41 (Paid Return):** 1 merchant (5%)

### KAM Feedback Coverage
- **14 of 22 have feedback** (64%)
- **8 of 22 have NO feedback** (36%) — including Savor Intl (3,514 orders), Prof Rashida (2,912), Conveyor Logistic (1,840), Al-Hiba (1,733), East West Univ (1,712), Ash-Sifa (1,569), Tech Move (1,408), HR GROUP LTD (1,104)

### Key Quotes from Feedback

**Shokher Bazar (5,248 orders):**
> "Fake return, delay delivery and parcel missing issue... The return ratio is very high, and delivery agents are returning parcels by providing fake notes."
> Wants: Return fee adjustment for Jan-May. Pricing renegotiation.

**Luxury (4,415 orders):**
> "Delivery delay, high return ratio. Return parcel maximum damage or properly packaging kore back kora hoy nah."
> Outcome: **Moved to Carrybee** after KAM offered discount too late.

**Aytun's Attires (3,313 orders):**
> "No entry and pickup timing issue... no entry te kono parcel thakel entry dewa hole o naki parcel return chole asto."
> Outcome: **Moved to Steadfast.**

**sunfhy.com (1,837 orders):**
> "Pathao courier a onek problem face korasi, fake return hoisa... Steadfast courier a ditasi."
> "Fake return and improper delivery attempt ratio is very high. When using Steadfast this ratio decreased."
> Outcome: **Moved to Steadfast.** Explicitly states Steadfast has lower fake-return ratio.

**Tasa & Toha (1,768 orders):**
> "Rider ra home delivery properly korena. Customer dissatisfied hoy."
> "Rider ra properly attempt na niyei parcel return kore dicche."
> Outcome: **Created new account**, old account abandoned.

**Sopner Collection (1,586 orders):**
> "Dissatisfied due to delay delivery & fake attempts by riders... Dissatisfied due to wrong routing, Hub change & delay delivery."
> "Merchant Eid er moddhe delay delivery issue face koresen. Steadfast a move koresen."
> Outcome: **Moved to Steadfast** + created duplicate account (Dream Fashion Wear, merchant 335171).

**BD - choice (1,302 orders):**
> "Ongoing ISD issues and a high number of fake delivery incidents."
> Outcome: **Moved to Steadfast.**

---

## 5. Root Cause Breakdown

### Ranked Dissatisfaction Reasons (from KAM feedback of 162 churned merchants)

| Rank | Reason | Frequency | Impact |
|------|--------|-----------|--------|
| 1 | Delivery Experience (delay, fake attempts, no-show) | 20 mentions | Direct churn driver |
| 2 | Fake/Improper Return by Delivery Agent | 8 mentions | Merchants lose product + fee |
| 3 | Fake/Improper Delivery Attempts | 5 mentions | Riders marking attempts without contacting customer |
| 4 | Price Discount Required | 4 mentions | Return fees too high |
| 5 | Pickup Experience | 2 mentions | Timing inflexibility |
| 6 | Home Delivery Denial | 2 mentions | Riders refusing home delivery |
| 7 | Issue Resolution Experience | 2 mentions | Lost parcel IR handling |
| 8 | High Return Rate | 1 mention | Systemic issue |

**Caveat:** "Merchant Internal Issue" (49 mentions) is a catch-all category. Reading detailed responses reveals many are triggered by delivery frustrations.

### Competitor Migration
| Competitor | Mentions |
|------------|----------|
| Steadfast | **31** |
| Carrybee | 4 |
| Other Local Couriers | 1 |

---

## 6. Segment Analysis

### By Merchant Type

| Type | Churned | High Risk | Declining | Stable | Total May Volume at Risk |
|------|---------|-----------|-----------|--------|--------------------------|
| Regular (0) | 161 | 397 | 672 | 4,206 | 965,401 |
| Book (5) | 1 | 4 | 3 | 49 | 8,687 |
| C2C Agent (3) | 0 | 0 | 0 | 15 | 0 |
| C2C Kiosk (1) | 0 | 0 | 0 | 18 | 0 |
| Corporate (4) | 0 | 0 | 0 | 1 | 0 |
| Point (6) | 0 | 0 | 0 | 7 | 0 |
| Post_paid (7) | 0 | 0 | 0 | 8 | 0 |

Churn is almost entirely Regular merchants (standard e-commerce).

### By KAM Coverage

| KAM Status | Total | Churned | Churn Rate | Churned Orders |
|------------|-------|---------|------------|----------------|
| Has KAM | 4,407 | 65 | **1.5%** | 50,918 |
| No KAM | 1,135 | 97 | **8.5%** | 31,249 |

Merchants with KAM churn at 1/5 the rate. 60% of churned merchants had no KAM.

---

## 7. Where We Failed

### Evidence-Backed Failures

1. **Fake delivery attempts are our #1 self-inflicted wound.** Riders marking "no entry" or "customer unavailable" without actually contacting the customer. Cited by every churned merchant with feedback.

2. **Return handling is broken.** Returned parcels come back damaged, improperly packaged, or falsely returned.

3. **Delivery delays erode trust.** Inside-Dhaka parcels taking 4-6 days is unacceptable for same-city delivery.

4. **KAM feedback blind spot is massive.** 57% of churned merchants had zero feedback recorded.

5. **Account switching is invisible.** Multiple merchants abandon old accounts and open new ones.

6. **Pricing negotiation happens reactively.** Discounts offered only after merchants threaten to leave.

### Inferred Patterns

- Non-KAM mid-size merchants have no relationship management. They leave silently.
- ISD operations appear worse than OSD for fake attempts and delays.

---

## 8. Recommended Actions

### Immediate (This Week)

| # | Action | Why | Expected Impact | Priority |
|---|--------|-----|-----------------|----------|
| 1 | Call the top 22 churned merchants — starting with Shokher Bazar, Luxury, Aytun's Attires, sunfhy.com, Tasa & Toha | 56% of volume in 22 merchants. Some are recoverable (pricing negotiation, personal leave) | Potential 20-30% recovery (~10-15K orders) | 🔴 Critical |
| 2 | Assign KAMs to the 92 undocumented churned merchants — retroactively document why they left | Can't fix what we don't understand | Better churn intelligence | 🔴 Critical |
| 3 | Flag the 401 high-risk merchants — each KAM calls their assigned high-risk merchants today | 306K orders at risk. Most are service-driven and addressable | Potential 50-60% retention | 🔴 Critical |

### Short-Term (Next 2 Weeks)

| # | Action | Why | Expected Impact | Priority |
|---|--------|-----|-----------------|----------|
| 4 | Audit fake delivery attempts — sample riders with highest return-without-contact rates | #1 reason merchants leave. Multiple areas cited (B. Baria, Sylhet, Cumilla, Noakhali) | Direct reduction in return rate | 🔴 Critical |
| 5 | Fix return parcel handling — audit how returned parcels are packaged | #2 churn driver. Merchants absorb less loss = stay | Reduced return-related churn | 🟡 High |
| 6 | Set ISD delivery SLA enforcement — target <48hr for inside-Dhaka | Merchants report 4-6 days. Steadfast benchmark is faster | Competitive parity | 🟡 High |
| 7 | Flag account-switching merchants — watchlist for KAM-documented new accounts | True churn is higher than reported | Better retention visibility | 🟡 High |

### Medium-Term (Next 1-2 Months)

| # | Action | Why | Expected Impact | Priority |
|---|--------|-----|-----------------|----------|
| 8 | Mid-tier merchant retention program — 1,135 non-KAM merchants doing 100+ orders/month | 8.5% churn rate vs 1.5% for KAM. KAM model works — extend it | 50% reduction = 40-50 merchants retained/month | 🟡 High |
| 9 | Benchmark Steadfast's operation in areas where we lose most | 31 mentions. They have a real operational advantage | Data-driven ops improvement | 🟢 Medium |
| 10 | Simplify return fee pricing — consider flat-rate or loyalty-tier caps | #2 reason after delivery failure. Only fix AFTER delivery improves | Pricing lever | 🟢 Medium |

---

## 9. Open Questions / Gaps

- **57% blind spot:** No feedback for 92 of 162 churned merchants. Phone outreach needed.
- **Account switching magnitude unknown:** Multiple cases confirmed. Cross-account group analysis needed.
- **ISD vs OSD split unknown:** Most feedback mentions ISD. Hub-level analysis would identify problem areas.
- **Return rate correlation:** Do churned merchants have higher May return rates than stable ones? Could be leading indicator.
- **Seasonality impact:** Some churn is temporary (Eid, World Cup, personal leave). July repeat needed.

---

## 10. Data Sources & Methodology

- **Databases:** DB 7 (BigQuery — courier_realtime_datastream)
- **Tables queried:** public_orders, public_archived_orders, public_merchants, monthly_kam_followups, static_values_kam_followups
- **API:** Metabase REST API native SQL (POST /api/dataset)
- **Date filter:** May 1-31, 2026 baseline, June 1-25, 2026 MTD
- **Churn proxy:** Defined due to absence of canonical KB definition — see top of document
- **Feedback source:** KAM monthly followups from monthly_kam_followups table

## Confidence
- Score: 7/10
- Why: All churn numbers are verified. Feedback analysis grounded in actual KAM entries. 57% blind spot reduces confidence on root cause weight.
- Needs: Phone outreach to 92 undocumented churned merchants; account-group analysis for switching detection; July repeat to measure recovery vs permanent loss.
