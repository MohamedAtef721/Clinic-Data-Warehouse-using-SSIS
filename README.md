# 🏥 Clinic Data Warehouse (DWH) Project

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2025-red?logo=microsoft-sql-server)](https://www.microsoft.com/sql-server)
[![SSIS](https://img.shields.io/badge/SSIS-Integration%20Services-blue)](https://docs.microsoft.com/en-us/sql/integration-services)
[![Status](https://img.shields.io/badge/Status-Complete-brightgreen)]()

An end-to-end Clinic Data Warehouse and ETL solution built with SQL Server and SSIS to transform raw healthcare data into a structured, analytics-ready Data Warehouse. The project implements a Staging Layer, Star Schema, SCD Type 2, Stored Procedures, and Master SSIS orchestration to manage data extraction, transformation, and loading across patients, doctors, clinics, diagnoses, and visits, providing a reliable foundation for healthcare reporting and business intelligence.

---

## 📌 Project Overview

This project demonstrates how to build a full **Data Warehouse pipeline** starting from raw CSV data to analytical insights.

It covers:
- Data extraction from CSV files  
- Loading into staging tables  
- Transformations using ETL processes  
- Building a Star Schema Data Warehouse  

---

## 🧱 Architecture

![Architecture](architecture.png)

**Pipeline Flow:**

```
CSV Files → SSIS → Staging Layer → ETL → Data Warehouse → Power BI
```

---

## 📂 Project Structure

```
📁 Clinic Data Warehouse using SSIS
│
├── 📁 Data
│   └── CSV Files
│
├── 📁 SQL_query
│   ├── Staging Tables
│   ├── DWH Tables
│   └── Stored Procedures
│
├── 📦 SSIS Packages
│   ├── Load_Patients_to_Staging.dtsx
│   ├── Load_Doctors_to_Staging.dtsx
│   ├── Load_Clinics_to_Staging.dtsx
│   ├── Load_Diagnosis_to_Staging.dtsx
│   ├── Load_Visits_to_Staging.dtsx
│   ├── Execute_ETL_Procedures.dtsx
│   └── Master_ETL.dtsx
│
├── Clinic_DWH_SSIS.sln
├── Clinic_DWH_SSIS.dtproj
└── README.md
```

---;

## ⚙️ Technologies Used

- **SQL Server 2025**
- **SSIS (SQL Server Integration Services)**
- **T-SQL (Stored Procedures)**
- **CSV Files**

---

## 🔄 ETL Pipeline

### 1️⃣ Extract & Load (SSIS)

- Import CSV files into staging tables
- Each entity has its own SSIS package:

```
Patients
Doctors
Clinics
Diagnosis
Visits
```

---

### 2️⃣ Transform (SQL - Stored Procedures)

- Data cleaning & transformation  
- Implemented **SCD Type 2**:
  - Dim_Patient  
  - Dim_Doctor  

- Generated:
  - Surrogate Keys  
  - DateKey  

---

### 3️⃣ Load (Data Warehouse)

### ⭐ Star Schema Design

#### 🟦 Fact Table
- Fact_Visits

#### 🟩 Dimension Tables
- Dim_Patient  
- Dim_Doctor  
- Dim_Clinic  
- Dim_Diagnosis  
- Dim_Date  

---

## 🧠 Key Concepts

- Data Warehouse Architecture  
- Star Schema Modeling  
- ETL Pipeline Design  
- Slowly Changing Dimensions (SCD Type 2)  
- SSIS Control Flow & Data Flow  
- Data Transformation (Derived Column, Data Conversion)  
- Master ETL Orchestration  
- Error Handling  

---

## 🚀 Master ETL Process

Main Package:
```
Master_ETL.dtsx
```

### Workflow:

```
Load Staging Tables
        ↓
Execute ETL Procedures
        ↓
Success / Error Handling
```

Includes:
- Sequence Container  
- Execute Package Task  
- Script Task  

---

## 📊 Sample Analytics

- 🥇 Top Doctors by Number of Visits  
- 💰 Revenue by Clinic  
- 🦠 Most Common Diagnoses  
- 📅 Monthly Revenue Trends  

---


## 📈 Future Improvements

- Automate using SQL Server Agent  
- Implement Incremental Load  
- Enhance Logging System  
- Build Advanced Power BI Dashboards  

---

## 👨‍💻 Author

**Mohamed Atef**

- Data Analyst | BI Developer  
- AI & Data Science Graduate  

---

## ⭐ Support

If you found this project useful, please give it a ⭐ on GitHub!
