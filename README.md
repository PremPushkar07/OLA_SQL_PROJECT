# Ola Ride Analytics — SQL Case Study Project

Welcome to the Ola Ride Analytics project —
a comprehensive SQL-based analysis of ride-sharing operations,
customer behavior, and business performance using PostgreSQL and pgAdmin. 
This project is designed to  showcase my SQL skills, and deliver real-world insights from a dataset.

---

 Objective
Analyze operational metrics,
customer behavior, ride patterns, revenue drivers, and cancellations
using structured SQL queries. 
Draw actionable insights to support business decisions for a ride-hailing platform.


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

--- Tools & Technologies
SQL: Data wrangling, cleaning and querying for insights.
TABLEAU: Dashboard creation and detailed reporting.
Python/Excel: Data preprocessing and randomization.



--- SQL Techniques Used
GROUP BY, ORDER BY, LIMIT
CASE statements for segmentation
DATE_PART, EXTRACT, AGE, and time windows
CTEs (WITH clause) for layered logic
Window functions: LEAD(), RANK(), PERCENTILE_CONT()
JOIN, FILTER, and subqueries
-----


 ---Key Insights
 Ride Performance
Identified top-performing vehicle types in terms of both volume and revenue.
Analyzed average ride distances and revealed that longer rides may have higher revenue potential.
Discovered peak ride hours, useful for fleet optimization and pricing.



----Cancellations & Incomplete Rides
Vehicle-wise and location-wise cancellation behavior assessed.
Identified top 10 pickup locations with highest driver cancellations.
Highlighted problem zones with high incomplete/failed rides.



--- Revenue & Customer Value
Top 5 highest revenue days uncovered.
High-value customers (90th percentile) extracted for loyalty strategies.
Cumulative daily revenue tracking enabled for current month.
Monthly customer-level booking value analyzed.



----Customer Behavior
Measured rebooking rate within 3 days — an indicator of short-term loyalty.
Identified churned customers with no activity in 60+ days.
Ranked customers by lifetime active span.



 Ratings & Turnaround Times
Compared average customer ratings by vehicle type.
Found low-rated vehicle segments via driver rating analysis.
Calculated Vehicle Turnaround Time (VTAT) and Customer Turnaround Time (CTAT) across time slots.


--- Location-Based Trends
Top 5 pickup-drop pairs extracted.
Ranked locations by ride frequency.
Detected locations with highest failed-to-successful ride ratios.







