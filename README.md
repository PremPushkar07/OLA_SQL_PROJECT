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

# Setup Guide (PostgreSQL + pgAdmin)


--  STEP 1: Create Database
CREATE DATABASE ola_ride_analytics;

--  STEP 2: Create Table
CREATE TABLE ola_rides (
    ride_id SERIAL PRIMARY KEY,
    ride_date DATE,
    ride_time TIME,
    booking_id VARCHAR(20) UNIQUE,
    booking_status VARCHAR(50),
    customer_id INT,
    vehicle_type VARCHAR(50),
    pickup_location VARCHAR(100),
    drop_location VARCHAR(100),
    avg_vtat FLOAT,
    avg_ctat FLOAT,
    cancelled_rides_by_customer INT,
    cancelled_rides_by_driver INT,
    incomplete_rides INT,
    booking_value NUMERIC,
    payment_method VARCHAR(50),
    ride_distance FLOAT,
    driver_ratings FLOAT,
    customer_rating FLOAT
);

--  STEP 3: Import CSV into Table

-- Right-click on 'ola_rides' table → Import/Export → Choose 'ola_cleaned_all_rides.csv'
-- Match CSV columns to table columns:
-- Use the following column order: 
-- ride_date, ride_time, booking_id, booking_status, customer_id, vehicle_type, pickup_location, drop_location, avg_vtat, avg_ctat, cancelled_rides_by_customer, cancelled_rides_by_driver, incomplete_rides, booking_value, payment_method, ride_distance, driver_ratings, customer_rating

--  STEP 4: Basic Check

SELECT * FROM ola_rides LIMIT 5;


------------30 questions and their quires-------------



-- 1. Total number of rides per vehicle type


SELECT vehicle_type, COUNT(*) AS total_rides
FROM ola_rides
GROUP BY vehicle_type
ORDER BY total_rides DESC;

-- 2. Total and average booking revenue per vehicle type


SELECT vehicle_type, SUM(booking_value) AS total_revenue, AVG(booking_value) AS avg_revenue
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY vehicle_type;

-- 3. Top 5 pickup-drop location pairs by frequency


SELECT pickup_location, drop_location, COUNT(*) AS trip_count
FROM ola_rides
GROUP BY pickup_location, drop_location
ORDER BY trip_count DESC
LIMIT 5;

-- 4. Average ride distance per vehicle category


SELECT vehicle_type, AVG(ride_distance) AS avg_distance
FROM ola_rides
GROUP BY vehicle_type;

-- 5. Hour of day with highest number of completed rides


SELECT EXTRACT(HOUR FROM ride_time) AS ride_hour, COUNT(*) AS ride_count
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY ride_hour
ORDER BY ride_count DESC
LIMIT 1;

-- 6. Success vs cancellation rate for each vehicle type


SELECT vehicle_type,
       COUNT(*) FILTER (WHERE booking_status = 'Success') AS success_count,
       COUNT(*) FILTER (WHERE booking_status != 'Success') AS cancel_count
FROM ola_rides
GROUP BY vehicle_type;

-- 7. Locations with highest driver cancellations


SELECT pickup_location, SUM(cancelled_rides_by_driver) AS driver_cancels
FROM ola_rides
GROUP BY pickup_location
ORDER BY driver_cancels DESC
LIMIT 5;

-- 8. Booking value by ride distance buckets


SELECT
  CASE 
    WHEN ride_distance <= 5 THEN '0-5km'
    WHEN ride_distance <= 10 THEN '5-10km'
    WHEN ride_distance <= 20 THEN '10-20km'
    ELSE '20km+'
  END AS distance_bucket,
  AVG(booking_value) AS avg_booking_value
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY distance_bucket;

-- 9. Most common payment method for successful bookings


SELECT payment_method, COUNT(*) AS count
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY payment_method
ORDER BY count DESC
LIMIT 1;

-- 10. Day with highest revenue in the past month


SELECT ride_date, SUM(booking_value) AS total_revenue
FROM ola_rides
WHERE booking_status = 'Success'
  AND ride_date >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY ride_date
ORDER BY total_revenue DESC
LIMIT 1;


-- 11. Customers with most successful rides


SELECT customer_id, COUNT(*) AS success_count
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY customer_id
ORDER BY success_count DESC;

-- 12. Top 10 frequent riders


SELECT customer_id, COUNT(*) AS total_rides
FROM ola_rides
GROUP BY customer_id
ORDER BY total_rides DESC
LIMIT 10;

-- 13. Average customer rating by vehicle type


SELECT vehicle_type, AVG(customer_rating) AS avg_rating
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY vehicle_type;

-- 14. Distribution of driver ratings (count of ratings < 3.5)


SELECT COUNT(*) AS low_rated_rides
FROM ola_rides
WHERE driver_ratings < 3.5;

-- 15. Rebooking rate within 3 days


SELECT customer_id, COUNT(*) AS rebooked_within_3_days
FROM (
  SELECT customer_id, ride_date, LEAD(ride_date) OVER (PARTITION BY customer_id ORDER BY ride_date) AS next_ride
  FROM ola_rides
) t
WHERE next_ride IS NOT NULL AND next_ride - ride_date <= 3
GROUP BY customer_id
ORDER BY rebooked_within_3_days DESC;

-- 16. Customers who cancelled more than 3 rides in last 30 days


SELECT customer_id, COUNT(*) AS cancels
FROM ola_rides
WHERE booking_status = 'Cancelled by Customer' AND ride_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY customer_id
HAVING COUNT(*) > 3;

-- 17. Gap between customer's first and last ride


SELECT customer_id, MIN(ride_date) AS first_ride, MAX(ride_date) AS last_ride,
       MAX(ride_date) - MIN(ride_date) AS ride_gap_days
FROM ola_rides
GROUP BY customer_id;

-- 18. Customers with increasing ratings in last 3 rides


WITH ranked_rides AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ride_date DESC) AS rn
  FROM ola_rides
  WHERE customer_rating IS NOT NULL
),
recent_rides AS (
  SELECT * FROM ranked_rides WHERE rn <= 3
)
SELECT customer_id
FROM recent_rides
GROUP BY customer_id
HAVING COUNT(*) = 3 AND MIN(customer_rating) < MAX(customer_rating);

-- 19. Customers with only cancelled/incomplete rides


SELECT customer_id
FROM ola_rides
GROUP BY customer_id
HAVING SUM(CASE WHEN booking_status = 'Success' THEN 1 ELSE 0 END) = 0;

-- 20. Churned customers (no rides in last 60 days)


SELECT customer_id
FROM ola_rides
GROUP BY customer_id
HAVING MAX(ride_date) < CURRENT_DATE - INTERVAL '60 days';

-- 21. Average VTAT per vehicle type


SELECT vehicle_type, AVG(avg_vtat) AS avg_vehicle_turnaround
FROM ola_rides
GROUP BY vehicle_type;

-- 22. Average CTAT by time slot


SELECT 
  CASE 
    WHEN EXTRACT(HOUR FROM ride_time) BETWEEN 0 AND 6 THEN 'Late Night'
    WHEN EXTRACT(HOUR FROM ride_time) BETWEEN 7 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM ride_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening' 
  END AS time_slot,
  AVG(avg_ctat) AS avg_customer_turnaround
FROM ola_rides
GROUP BY time_slot;

-- 23. Percentage of incomplete rides overall and by location


SELECT 
  'Overall' AS location,
  ROUND(100.0 * SUM(incomplete_rides)::NUMERIC / COUNT(*), 2) AS incomplete_percentage
FROM ola_rides
UNION
SELECT 
  pickup_location,
  ROUND(100.0 * SUM(incomplete_rides)::NUMERIC / COUNT(*), 2) AS incomplete_percentage
FROM ola_rides
GROUP BY pickup_location
ORDER BY incomplete_percentage DESC;

-- 24. CTAT trend across week


SELECT TO_CHAR(ride_date, 'Day') AS day_of_week, AVG(avg_ctat) AS avg_ctat
FROM ola_rides
GROUP BY day_of_week
ORDER BY AVG(avg_ctat);

-- 25. Locations with highest failed:success ratio


SELECT pickup_location,
       SUM(CASE WHEN booking_status != 'Success' THEN 1 ELSE 0 END)::FLOAT /
       NULLIF(SUM(CASE WHEN booking_status = 'Success' THEN 1 ELSE 0 END), 0) AS failure_ratio
FROM ola_rides
GROUP BY pickup_location
ORDER BY failure_ratio DESC
LIMIT 5;

-- 26. Cumulative revenue day by day for current month


SELECT ride_date, SUM(booking_value) AS daily_revenue,
       SUM(SUM(booking_value)) OVER (ORDER BY ride_date) AS cumulative_revenue
FROM ola_rides
WHERE booking_status = 'Success'
  AND DATE_TRUNC('month', ride_date) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY ride_date
ORDER BY ride_date;

-- 27. Customers with revenue above 90th percentile


WITH revenue_by_customer AS (
  SELECT customer_id, SUM(booking_value) AS total_revenue
  FROM ola_rides
  WHERE booking_status = 'Success'
  GROUP BY customer_id
),
percentile_value AS (
  SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_revenue) AS p90
  FROM revenue_by_customer
)
SELECT r.customer_id, r.total_revenue
FROM revenue_by_customer r, percentile_value p
WHERE r.total_revenue > p.p90;

-- 28. Rank pickup locations by ride frequency (top 5)


SELECT pickup_location, COUNT(*) AS total_rides,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
FROM ola_rides
GROUP BY pickup_location
ORDER BY rank
LIMIT 5;

-- 29. Monthly average booking value per customer


SELECT customer_id, DATE_TRUNC('month', ride_date) AS month,
       AVG(booking_value) AS avg_booking_value
FROM ola_rides
WHERE booking_status = 'Success'
GROUP BY customer_id, month
ORDER BY customer_id, month;

-- 30. Customers with increasing booking value in last 3 rides


WITH ranked_rides AS (
  SELECT customer_id, ride_date, booking_value,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ride_date DESC) AS rn
  FROM ola_rides
  WHERE booking_status = 'Success'
),
last_3_rides AS (
  SELECT * FROM ranked_rides WHERE rn <= 3
)
SELECT customer_id
FROM last_3_rides
GROUP BY customer_id
HAVING COUNT(*) = 3 AND MIN(booking_value) < MAX(booking_value);



