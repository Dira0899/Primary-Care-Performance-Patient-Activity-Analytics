# 🏥 Primary Care Performance & Patient Activity Analytics

An **end-to-end healthcare analytics project** that transforms raw appointment data into a **clean data warehouse and executive-ready analytics model**.  
The project simulates a **primary care (GP) practice or small healthcare network**, demonstrating real-world **data engineering, analytics, and business intelligence workflows** using **Python, PostgreSQL, and Power BI**.

This repository is designed as a **portfolio project** showcasing how raw operational data can be converted into **decision-ready insights**.

---

##  Business Context

Primary care clinics and small healthcare networks rely on accurate, timely data to effectively manage daily operations and service quality.

Key operational challenges include:

- Managing patient appointment volume and demand  
- Monitoring no-shows and cancellations  
- Balancing staff workload and clinic capacity  
- Reducing patient wait times  
- Tracking appointment outcomes and follow-up needs  

This project addresses these challenges by building a **structured analytics pipeline** that supports **operational and executive decision-making**.

---

##  Project Objectives

The analytics solution enables:

- Monitoring appointment volume and trends over time  
- Measuring no-show and cancellation rates  
- Evaluating patient wait times and consultation efficiency  
- Comparing workload across staff roles and clinic locations  
- Analyzing appointment outcomes and service performance  

Each objective is directly supported by the data model and planned dashboard design.

---

##  Architecture Overview

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
This architecture mirrors a **real-world analytics workflow**, separating data ingestion, transformation, storage, and visualization.

---

##  Data Warehouse Design

### Staging Layer
- Stores cleaned, appointment-level records  
- Mirrors the source structure  
- No aggregations or business logic applied  

### Star Schema (Analytics Layer)

**Fact Table**
- `fact_appointments`  
  - One row per appointment  
  - Measures: wait time, consultation duration  
  - Foreign keys to all dimensions  

**Dimension Tables**
- `dim_date`  
- `dim_patient_age_group`  
- `dim_appointment_type`  
- `dim_appointment_status`  
- `dim_staff_role`  
- `dim_clinic_location`  
- `dim_outcome_category`  

This design ensures:
- Consistent KPI calculations  
- Fast BI performance  
- Flexible slicing across business dimensions  

---

## ⚙️ ETL Pipeline Overview (Python)

The ETL pipeline is **script-driven and repeatable**, allowing the same processing logic to be applied consistently across multiple data files.

**Extract**
- Loads multiple CSV files split by year/period  
- Validates column consistency  

**Transform**
- Standardizes dates and categorical values  
- Removes duplicates using a generated appointment UID  
- Derives calendar attributes (year, month, week, weekday)  

**Validate**
- No negative wait times  
- Reasonable consultation durations  
- Valid appointment statuses  
- Validation results logged for auditability  

**Load**
- Writes cleaned data to PostgreSQL staging  
- Populates dimension tables  
- Builds the fact table using surrogate keys  

---

##  Analytics & KPI Layer (Defined)

The following metrics have been defined and will be implemented in Power BI using DAX:

- Total Appointments  
- Attendance Rate  
- No-show Rate  
- Cancellation Rate  
- Average & Median Wait Time  
- Average Consultation Duration  
- Workload by Staff Role  
- Appointments by Clinic Location  
- Outcome Distribution & Follow-up Rate  
- Month-over-Month Appointment Trends  

This ensures dashboards focus on **business insights**, not just descriptive charts.

---

##  Power BI Dashboard (In Progress)

The final phase of the project focuses on **Power BI visualization and storytelling**, including:

- Importing the PostgreSQL star schema (Import mode)  
- Implementing validated DAX measures  
- Designing multi-page dashboards:
  - Executive Overview  
  - Appointment Status & Outcomes  
  - Wait Time & Service Efficiency  
  - Clinic & Staff Performance  

The dashboards are designed to support:
- Operational monitoring  
- Capacity planning  
- Service quality improvement  
- Executive-level reporting  

---

##  Repository Structure
```
primary-care-analytics/
├── data/
│ └── raw/
│ ├── appointments_2023_2.csv
│ ├── appointments_2024_1.csv
│ ├── appointments_2024_2.csv
│ ├── appointments_2025_1.csv
│ └── appointments_2025_2.csv
├── notebooks/ # Exploration & data quality checks
├── sql/ # Warehouse & star schema scripts
├── dashboards/ # Power BI files & screenshots (upcoming)
├── logs/ # ETL validation logs
├── requirements.txt
└── README.md
```
## 📌 Project Status

- ✅ Data ingestion & cleaning complete  
- ✅ PostgreSQL data warehouse implemented  
- ✅ Star schema analytics model finalized  
- ✅ Business KPIs defined  
- 🚧 Power BI dashboard development in progress  

---
