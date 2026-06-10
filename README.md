# Cafe Sales Data Cleaning Project

## Overview
This project involved cleaning a dirty cafe sales dataset with 10,000+ records containing various data quality issues.

## Raw Data Issues Identified
| Column | Issue | Count |
|--------|-------|-------|
| Item | Blanks/UNKNOWN/ERROR | 969 rows |
| Quantity | Missing/Invalid | 479 rows |
| Price Per Unit | Missing/Invalid | 533 rows |
| Total Spent | Missing/Invalid | 502 rows |
| Payment Method | Missing/Invalid | 3,178 rows |
| Location | Missing/Invalid | 3,961 rows |
| Transaction Date | Missing/Invalid | 460 rows |

## Cleaning Approach

### Categorical Columns (Item, Payment Method, Location)
- Blanks → 'Not Provided'
- 'UNKNOWN' → 'Unknown'  
- 'ERROR' → 'Error'

### Numeric Columns (Quantity, Price Per Unit, Total Spent)
- Cross-column recovery using: `Total = Quantity × Price Per Unit`
- Added status columns to track original vs. derived values

### Date Column
- Valid dates preserved as date type
- Added status column to document affected rows

## Results
- **Rows removed**: 0 (all data preserved)
- **New columns added**: 4 status columns
- **All issues resolved**: 7 columns fixed

## Files
- `dirty_cafe_sales.csv` - Original raw data
- `Clean_cafe_sales.xlsx` - Cleaned output with status columns
- `cleaning_log.md` - Detailed cleaning documentation

## Key Learnings
1. Always preserve data when possible (no row deletion)
2. Cross-column validation helps recover numeric values
3. Status columns provide transparency for derived values