# Feedback Log

A log of queries, metrics, or business logic corrected by the user.

- **Format**: [Date] - [Issue] - [Correction]
- **2026-06-08** - Metabase question #3479 query runner - Metabase question/card #3479 is a scratch app DB SQL runner named "boss man app db query run"; update it via courierbi.pathaointernal.com API when the user asks to paste/run SQL there and return CSV.
- **2026-06-09** - KAM processed yesterday mismatch - User's Metabase showed `180,534` while initial query returned `181,273`; the difference was exactly `739` orders with `transfer_status_id IN (43,44)` (`43=667`, `44=72`). For matching that Metabase view, exclude statuses `43,44` from the processed status set.
