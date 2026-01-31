# 🏥 Primary Care Performance & Patient Activity Analytics

An end-to-end, automated healthcare analytics project that transforms raw appointment data into a structured data warehouse and executive-ready Power BI dashboards. This project demonstrates real-world data engineering, analytics, and business intelligence workflows using **Python, PostgreSQL, and Power BI**.

---

## 📌 Business Context
Primary care clinics and small healthcare networks rely on accurate, timely data to manage:
- Patient appointment volume
- No-shows and cancellations
- Staff workload and capacity
- Wait times and service efficiency
- Appointment outcomes and follow-up needs


## 🎯 Project Objectives

The solution enables:
- Monitoring appointment volume and trends over time
- Measuring no-show and cancellation rates
- Evaluating patient wait times and consultation efficiency
- Comparing workload across staff roles and clinic locations
- Analyzing appointment outcomes and service performance

---

## 🏗️ Architecture Overview

```
Raw CSV Data
     │
     ▼
Python ETL Pipeline
(Extract → Clean → Validate → Transform)
     │
     ▼
PostgreSQL
Staging + Star Schema Warehouse
     │
     ▼
Power BI Dashboard
(Operational & Executive Reporting)
```


## 📂 Repository Structure

```
primary-care-analytics/
├──data/
│  ├── raw/
│  │   ├── appointments_2023_2.csv
│  │   ├── appointments_2024_1.csv
│  │   ├── appointments_2024_2.csv
│  │   ├── appointments_2025_1.csv
│  │   └── appointments_2025_2.csv
├── notebooks/
├── src/
├── sql/
├── dashboards/
├── logs/
├── requirements.txt   
└── README.md
```

---
