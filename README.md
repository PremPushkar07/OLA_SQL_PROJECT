# Ola Ride Analytics — SQL Case Study Project

Welcome to the Ola Ride Analytics project —
a comprehensive SQL-based analysis of ride-sharing operations,
customer behavior, and business performance using PostgreSQL and pgAdmin. 
This project is designed to  showcase my SQL skills, and deliver real-world insights from a dataset.

---

# Project Objective

This project aims to:
- Analyze ride performance across vehicle types and locations
- Understand customer & driver behavior trends
- Monitor operational efficiency (VTAT, CTAT)
- Deliver business-impacting insights using 30 structured SQL queries

---

# Dataset Overview

Source:Simulated Ola-like ride data (CSV format)  
Table Name: `ola_rides`

| Column Name                   | Description                                 |
|------------------------------|---------------------------------------------|
| ride_id                      | Unique ride ID (Primary Key)                |
| ride_date                    | Date of the ride                            |
| ride_time                    | Time of the ride                            |
| booking_id                   | Unique booking reference                    |
| booking_status               | 'Success', 'Cancelled by driver', etc.      |
| customer_id                  | Customer identifier                         |
| vehicle_type                 | Type of vehicle (Mini, Sedan, etc.)         |
| pickup_location              | Ride start point                            |
| drop_location                | Ride destination                            |
| avg_vtat                     | Vehicle Turnaround Time (mins)              |
| avg_ctat                     | Customer Turnaround Time (mins)             |
| cancelled_rides_by_customer | Customer cancellations                      |
| cancelled_rides_by_driver   | Driver cancellations                        |
| incomplete_rides            | Incomplete ride attempts                    |
| booking_value               | Fare of the ride (₹)                        |
| payment_method              | UPI / Card / Wallet / Cash                  |
| ride_distance               | Distance in kilometers                      |
| driver_ratings              | Rating given to driver                      |
| customer_rating             | Rating given to customer                    |

---

 Tools & Technologies
SQL: Data wrangling, cleaning and querying for insights.
TABLEAU: Dashboard creation and detailed reporting.
Python/Excel: Data preprocessing and randomization.


-----



