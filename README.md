Pizza Performance 2015 — BI Dashboard
End-to-end BI project analyzing a single-location pizza restaurant's 2015 sales: raw CSVs → SQL Server star schema → Tableau Public dashboard.
 
🔗 Live interactive dashboard on Tableau Public
________________________________________
The business question
Are we maximizing revenue from our menu and operating hours, and where are the biggest opportunities to grow without adding capacity?
The stakeholder is the GM/owner of a single-location pizza restaurant heading into 2026 planning. They already know revenue numbers — what they need is a clear view of where revenue is concentrated, where the operational gaps are, and which menu items deserve more attention or less shelf space.
Sub-questions the dashboard addresses:
•	Which days and hours generate the most revenue? Are there underused time slots?
•	Which pizza categories and sizes drive the business? Which underperform?
•	What's the spread between top and bottom performers — is the menu too long?
•	Is revenue stable across the year, or is there meaningful seasonality?
Key findings
•	Revenue concentration is steep. Top 5 pizzas generate ~$125K (15% of total revenue). Bottom 5 generate ~$7K (under 1%). That's an 18× revenue spread between the strongest and weakest items — a clear signal that the menu can be tightened without losing meaningful revenue.
•	Size matters more than category. Every pizza in the Top 10 by revenue is Large. Every pizza in the Bottom 10 is Small or XX-Large. This suggests the restaurant should reconsider how Small variants are positioned (or whether they should be offered at all for low-performing recipes).
•	5 pizzas had zero sales in 2015. All are size variants of otherwise-popular pizzas (Big Meat Medium/Large, Five Cheese Small/Medium, Four Cheese Small). This is documented as a size-mix optimization finding rather than a full menu removal candidate.
•	Time-of-day patterns are strong. Lunch (12–13) and dinner (17–20) are the clear revenue hot zones, with Friday and Saturday concentrating the most activity. Mornings (before 11am) and late evenings (after 22) are essentially dead — opportunities for either targeted promotion or staffing reduction.
•	Monthly seasonality is weak. Revenue is remarkably consistent across the year (mostly $2K–$3K/day with occasional spikes). The business doesn't have a "busy season" — it has a busy day-of-week rhythm.
•	Average ticket: $38.31. Computed as a true weighted average (SUM(Revenue) / SUM(Orders)) — not an average of daily averages, which would be misleading.
Architecture
The data flows through a five-schema warehouse design in SQL Server:
raw  →  stg  →  dim / fact  →  mart
 ↓        ↓          ↓             ↓
CSVs   Cleaned    Star schema   Aggregated views
       & typed                  (the BI layer)
Schema	Purpose
raw	Mirror of source CSVs — all columns as VARCHAR for safe ingestion
stg	Cleaned and properly typed staging tables
dim	Conformed dimensions: dim_pizza (96 rows), dim_date (365 rows), dim_time (24 rows with daypart classification)
fact	fact_order_line (48,620 rows), fact_order (21,350 rows)
mart	Pre-aggregated views feeding Tableau: daily revenue, hourly patterns, category performance, pizza performance with Top 5/Bottom 5 tiering
Mart views are exported to Excel and consumed by Tableau Public (which doesn't support live SQL Server connections on the free tier).
Data quality story
Three quality issues surfaced and were resolved during build:
1. CRLF line-ending artifacts. The source CSVs were saved on Windows, leaving trailing \r (carriage return) characters on the final column of every row. SQL Server's TRY_CAST silently returned NULL on the affected values — no error, no warning, just missing data. Discovered via comparing DATALENGTH (raw bytes) to LEN (visible characters), then confirmed with VARBINARY byte inspection. Fixed with defensive REPLACE(REPLACE(col, CHAR(13), ''), CHAR(10), '') applied across all staging queries. Lesson: trust but verify your source files.
2. Zero-sale pizzas. An INNER JOIN between dim_pizza and the fact table initially excluded 5 pizzas from the performance view because they had zero sales in 2015. Rather than mask this with a LEFT JOIN, the finding is documented separately — the absence of sales is itself the signal, and it warrants menu review rather than dashboard noise.
3. Average-of-averages risk. The KPI "Average Ticket" must be computed as SUM(Revenue) / SUM(Orders) to be a true weighted average. Using AVG(daily_average) would weight every day equally, distorting the result during low-volume days.
Project structure
pizza-bi-dashboard/
├── README.md
├── data/                         Source CSV files from Maven Analytics
│   ├── orders.csv
│   ├── order_details.csv
│   ├── pizzas.csv
│   ├── pizza_types.csv
│   └── data_dictionary.csv
├── sql/                          Numbered build scripts (run in order)
│   ├── 01_create_database.sql    Database and schema creation
│   ├── 02_load_raw.sql           Raw layer loading
│   ├── 03_staging.sql            CRLF-defensive staging
│   ├── 04_validation.sql         Referential integrity checks
│   ├── 05_dimensions.sql         dim_pizza, dim_date, dim_time
│   ├── 06_facts.sql              fact_order_line, fact_order
│   ├── 07_mart_views.sql         Aggregated views for BI
│   └── 08_vw_pizza_performance.sql   Top/Bottom tiering with window functions
└── tableau/
    ├── pizza_mart_data.xlsx      Excel extract feeding Tableau
    └── dashboard_screenshot.png  Static dashboard view
How to reproduce
Prerequisites: SQL Server (Developer Edition is free) and Tableau Public Desktop.
1.	Clone this repository.
2.	Place the CSV files in data/ (they're included).
3.	Run the SQL scripts in sql/ in numbered order against your SQL Server instance.
4.	Export the mart views (or use the included pizza_mart_data.xlsx).
5.	Open the Excel file in Tableau Public Desktop, or download the published workbook from the Tableau Public link above.
Tech stack & skills demonstrated
•	SQL Server / T-SQL — five-schema warehouse, CTEs, window functions (RANK, SUM OVER), recursive date dimension generation
•	Data modeling — star schema with surrogate keys, conformed dimensions, grain documentation
•	Data quality — defensive type casting, byte-level diagnostics, validation queries (orphan detection, totals reconciliation)
•	Tableau — calculated fields, weighted averages, filter actions, color encoding, dashboard layout
•	Documentation — analytical storytelling, decision rationale, reproducibility
About the author
I'm a career switcher building a four-project BI portfolio targeting entry-level analyst roles. This is project one of four; the next three will cover cohort/retention analysis, an operational dashboard with dbt transformations, and a creative Tableau Public viz.
LinkedIn: [add your URL here]
________________________________________
Data source: Maven Analytics — Pizza Place Sales 2015

