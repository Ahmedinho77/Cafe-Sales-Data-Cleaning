# Data Cleaning Log — Cafe_Sales

**Dataset**: dirty_Cafe_Sales.csv  
**Cleaned Output**: Clean_Cafe_Sales.xlsx  
**Rows**: 10,000  
**Cleaned by**: Analyst Ahmed

## Issues Fixed

| # | Column | Issue Found | Raw Example | Action Taken | Status |
|---|--------|-------------|-------------|--------------|--------|
| 1 | Item | 333 blanks, 344 UNKNOWN, 292 ERROR | 969 rows | Blanks → 'Not Provided', UNKNOWN → 'Unknown', ERROR → 'Error' | FIXED |
| 2 | Quantity | 138 blanks, 171 UNKNOWN, 170 ERROR | 479 rows | Recovered via Qty = Total Spent ÷ Price Per Unit | FIXED |
| 3 | Price Per Unit | 179 blanks, 164 UNKNOWN, 190 ERROR | 533 rows | Recovered via Price = Total Spent ÷ Quantity | FIXED |
| 4 | Total Spent | 173 blanks, 165 UNKNOWN, 164 ERROR | 502 rows | Recovered via Total = Quantity × Price Per Unit | FIXED |
| 5 | Payment Method | 2,579 blanks, 293 UNKNOWN, 306 ERROR | 3,178 rows | Blanks → 'Not Provided', UNKNOWN → 'Unknown', ERROR → 'Error' | FIXED |
| 6 | Location | 3,265 blanks, 338 UNKNOWN, 358 ERROR | 3,961 rows | Blanks → 'Not Provided', UNKNOWN → 'Unknown', ERROR → 'Error' | FIXED |
| 7 | Transaction Date | 159 blanks, 159 UNKNOWN, 142 ERROR | 460 rows | Valid dates as date type; status column tracks issues | FIXED |

## Summary
- **Total issues addressed**: 7
- **Columns fixed**: 7
- **Columns dropped**: 0
- **Rows removed**: 0
- **New columns added**: 4 (status columns)