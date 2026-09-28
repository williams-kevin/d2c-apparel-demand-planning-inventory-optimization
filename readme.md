# 📦 Omnichannel Demand Planning & Inventory Optimization Control Tower

![Python](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python)
![SQLite](https://img.shields.io/badge/Database-SQLite3-003B57?logo=sqlite)
![Looker Studio](https://img.shields.io/badge/BI-Looker%20Studio-4285F4?logo=googlelooker)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 About the Project

In fashion retail and multi-channel sales (online + wholesale), connecting **customer demand** (online orders vs. large wholesale orders) with **raw material supply (fabrics/SKUs)** is key to keeping costs down and sales running smoothly.

This project builds a complete **Data & Analytics Control Tower** that helps to:
1. Track historical fabric usage and group inventory by stock health levels.
2. Predict **out-of-stock risks** early using usage rates and expected shipment arrival dates (ETA).
3. Map out ready-to-sell items (**Finished Goods**) in the warehouse by category, size, quality grade (1st vs. 2nd quality), and exact storage location (**Container Box ID**).

---

## 📂 Project Structure

```text
.
├── dashboard/                  # Dashboard screenshots and full PDF export from Looker Studio
│   ├── 01-Executive Overview & Historical Consumption.png
│   ├── 02-Demand Planning & Inventory Optimization.png
│   ├── 03-Finished Goods Inventory & Quality Overview.png
│   ├── 04-Warehouse & Location Mapping.png
│   └── Omnichannel_Demand_Planning_&_Inventory_Optimization_Control_Tower.pdf
├── data/                       # Project datasets (secured & anonymized)
│   ├── clean_data/             # Cleaned, anonymized files ready for SQLite loading
│   └── raw_data/               # [IGNORED BY GIT] Confidential raw company data
├── database/                   # [IGNORED BY GIT] Local SQLite database file (.sqlite / .db)
├── looker_export/              # CSV exports created from SQL views to power Looker Studio
├── notebooks/                  # Python scripts for data cleaning, anonymization, and ETL
│   └── cleaning_anonymization.ipynb
├── sql_scripts/                # SQL scripts to create views and optimize query performance
│   └── create_views_and_indexes.sql
├── .gitignore                  # Git configuration file to keep private data safe
└── README.md                   # Project documentation

---

## 🔄 Data Pipeline & Architecture

```mermaid
graph TD
    A[Raw Data / Private Files] -->|Python Notebook| B[Clean & Anonymized Data]
    B -->|SQL Ingestion| C[(SQLite Database)]
    C -->|SQL Scripts & Indexes| D[Business Analytics Views]
    D -->|CSV Export / Data Connector| E[Looker Studio Dashboard]
	
1. **Data Ingestion & Anonymization (`notebooks/`)**: Python script dedicated to processing raw company files (`raw_data`), removing sensitive information, and generating clean, anonymized datasets in `clean_data/`.
2. **Data Modeling & Query Optimization (`sql_scripts/`)**: Execution of SQL scripts using DB Browser for SQLite to create consolidated reporting views and index queries for faster performance.
3. **Visualization & Reporting (`dashboard/` & `looker_export/`)**: Multi-page BI dashboard built in Looker Studio, providing a 360-degree overview of the supply chain.

## 📊 Dashboard Pages & Business Insights

---

### 1. Executive Overview & Historical Consumption

![Executive Overview & Historical Consumption](dashboard/01-Executive%20Overview%20%26%20Historical%20Consumption.png)

#### 🔎 Key Takeaways
* **Main Metrics**: Total fabric consumed reached **18.33K meters**. Online orders accounted for most of the volume (**Web Orders: 13.05K m**), followed by wholesale orders (**Bulk Orders: 4,864.92 m**) and samples (**Samples: 338.17 m**). Scrap waste remained well-controlled (**Total Waste: 75.69 m**), while **4,680.43 meters** of fabric are currently in transit.
* **Top Consumed Fabrics**: Clear identification of high-demand fabrics (`ULA08`, `AL108`, `ROC08`, `KHE28`, `SOL14`) that require close reordering supervision.
* **Monthly Tracking**: Full visibility on month-by-month usage trends from January through September 2026.

🔗 **Direct Link**: [📌 Open Page 1 on Looker Studio](https://datastudio.google.com/reporting/db9a41b3-0c31-4fed-9208-b343cd8ea046/page/p_hsnyl9k5nd)

---

### 2. Demand Planning & Inventory Optimization

![Demand Planning & Inventory Optimization](dashboard/02-Demand%20Planning%20%26%20Inventory%20Optimization.png)

#### 🔎 Key Takeaways
* **Stock Health & Alerts**: Dynamic stock categorization into 4 safety priority levels (`ALERT: CRITICAL STOCKOUT`, `WARNING: Buffer Breach`, `Safe Buffer`, `Healthy (High Coverage)`).
* **Coverage Indicators**: Proactive management by tracking remaining *Days of Inventory*, predicting stockout dates (*Prospective Out of Stock Date*), and aligning with upcoming delivery schedules (*Next Delivery ETA*).
* **Absorption Ratio**: Measures fabric usage velocity relative to total available stock (Average rate: **56.18%**).

🔗 **Direct Link**: [📌 Open Page 2 on Looker Studio](https://datastudio.google.com/reporting/db9a41b3-0c31-4fed-9208-b343cd8ea046/page/p_ftt4xhl6nd)

---

### 3. Finished Goods Inventory & Quality Overview

![Finished Goods Inventory & Quality Overview](dashboard/03-Finished%20Goods%20Inventory%20%26%20Quality%20Overview.png)

#### 🔎 Key Takeaways
* **Finished Products Volume**: Total manufactured inventory currently available in the warehouse stands at **5,235 units**.
* **Quality Control**: Breakdown of product quality, separating perfect garments (**First Quality: 1,355 units / 25.9%**) from items meant for clearance (**Second Quality: 3,880 units / 74.1%**).
* **Product Mix & Models**: Performance analysis across key garment styles (`PLEE01`, `DMA101`, `DSAT01`, `YSEU01`) and product categories (Dresses, Pants, Skirts, Swimwear, Jumpsuits, etc.).

🔗 **Direct Link**: [📌 Open Page 3 on Looker Studio](https://datastudio.google.com/reporting/db9a41b3-0c31-4fed-9208-b343cd8ea046/page/p_90fptgl6nd)

---

### 4. Warehouse & Location Mapping

![Warehouse & Location Mapping](dashboard/04-Warehouse%20%26%20Location%20Mapping.png)

#### 🔎 Key Takeaways
* **Warehouse Mapping**: Physical tracking and layout management across **109 Container Boxes**.
* **Box Capacity**: Clear visibility on storage fill levels and item counts per box (`2ND-BOX-27`, `2ND-BOX-60`, etc.).
* **Item Lookup Matrix**: Practical cross-reference table to instantly locate any product by size (XS to 3XL), quality grade, and container box ID.

🔗 **Direct Link**: [📌 Open Page 4 on Looker Studio](https://datastudio.google.com/reporting/db9a41b3-0c31-4fed-9208-b343cd8ea046/page/p_yq2b32l6nd)

---

### 5. Operational View & Supplementary Analytics

🔗 **Direct Link**: [📌 Open Page 5 on Looker Studio](https://datastudio.google.com/reporting/db9a41b3-0c31-4fed-9208-b343cd8ea046/page/p_oio2dcm6nd)

---

## 📄 PDF Export & Full Report

- [📄 **Download Complete Control Tower PDF Export**](https://datastudio.google.com/reporting/db9a41b3-0c31-4fed-9208-b343cd8ea046/print)