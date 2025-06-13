--(CREATING TABLE ola_rides)
CREATE TABLE ola_rides (
    date              text,
    time              text,
    booking_id        text,
    booking_status    text,
    customer_id       text,
    vehicle_type      text,
    pickup_location   text,
    drop_location     text,
    avg_vtat          text,
    avg_ctat          text,
    cancelled_rides_by_customer text,
    cancelled_rides_by_driver   text,
    incomplete_rides           text,
    booking_value     text,
    payment_method    text,
    ride_distance     text,
    driver_ratings    text,
    customer_rating   text
);
--(verifying row count-- should be 50000)
SELECT COUNT(*) FROM ola_rides; 
DELETE FROM ola_rides
WHERE booking_id = 'booking_id';
SELECT COUNT(*) FROM ola_rides;


CREATE TABLE rides (
    booking_id        VARCHAR(40) PRIMARY KEY,
    ride_timestamp    TIMESTAMPTZ,          -- combined date + time
    booking_status    VARCHAR(40),
    customer_id       BIGINT,
    vehicle_type      VARCHAR(40),
    pickup_location   VARCHAR(60),
    drop_location     VARCHAR(60),
    avg_vtat          NUMERIC(6,2),
    avg_ctat          NUMERIC(6,2),
    cancelled_by_customer SMALLINT,
    cancelled_by_driver   SMALLINT,
    incomplete_rides      SMALLINT,
    booking_value     NUMERIC(10,2),
    payment_method    VARCHAR(40),
    ride_distance     NUMERIC(6,2),
    driver_rating     NUMERIC(3,2),
    customer_rating   NUMERIC(3,2)
);


INSERT INTO rides
SELECT
    booking_id,
    (date || ' ' || time)::timestamptz       AS ride_timestamp,
    booking_status,
    customer_id::bigint,
    vehicle_type,
    pickup_location,
    drop_location,
    avg_vtat::numeric(6,2),
    avg_ctat::numeric(6,2),
    cancelled_rides_by_customer::smallint,
    cancelled_rides_by_driver::smallint,
    incomplete_rides::smallint,
    booking_value::numeric(10,2),
    payment_method,
    ride_distance::numeric(6,2),
    driver_ratings::numeric(3,2),
    customer_rating::numeric(3,2)
FROM ola_rides;

INSERT INTO rides (
    booking_id,
    ride_timestamp,
    booking_status,
    customer_id,
    vehicle_type,
    pickup_location,
    drop_location,
    avg_vtat,
    avg_ctat,
    cancelled_by_customer,
    cancelled_by_driver,
    incomplete_rides,
    booking_value,
    payment_method,
    ride_distance,
    driver_rating,
    customer_rating
)
SELECT
    booking_id,
    (date || ' ' || time)::timestamptz,
    booking_status,
    customer_id::bigint,
    vehicle_type,
    pickup_location,
    drop_location,
    avg_vtat::numeric(6,2),
    avg_ctat::numeric(6,2),
    cancelled_rides_by_customer::smallint,
    cancelled_rides_by_driver::smallint,
    incomplete_rides::smallint,
    booking_value::numeric(10,2),
    payment_method,
    ride_distance::numeric(6,2),
    driver_ratings::numeric(3,2),
    customer_rating::numeric(3,2)
FROM ola_rides
WHERE booking_id != 'booking_id'
ON CONFLICT (booking_id) DO NOTHING;

CREATE INDEX idx_vehicle_type     ON rides (vehicle_type);
CREATE INDEX idx_pickup_location  ON rides (pickup_location);
CREATE INDEX idx_drop_location    ON rides (drop_location);
CREATE INDEX idx_ride_timestamp   ON rides (ride_timestamp);
CREATE INDEX idx_customer_id      ON rides (customer_id);

---1

SELECT vehicle_type, COUNT(*) AS total_rides
FROM rides
GROUP BY vehicle_type
ORDER BY total_rides DESC;

---2
SELECT vehicle_type,
       ROUND(AVG(booking_value),2) AS avg_revenue,
       ROUND(SUM(booking_value),2) AS total_revenue
FROM rides
WHERE booking_status = 'Success'
GROUP BY vehicle_type;

---3

SELECT pickup_location, drop_location, COUNT(*) AS rides
FROM rides
GROUP BY pickup_location, drop_location
ORDER BY rides DESC
LIMIT 5;
---4
SELECT vehicle_type, ROUND(AVG(ride_distance),2) AS avg_km
FROM rides
GROUP BY vehicle_type;

---5

SELECT DATE_PART('hour', ride_timestamp) AS hr, COUNT(*) AS rides
FROM rides
WHERE booking_status = 'Success'
GROUP BY hr
ORDER BY hr DESC
LIMIT 5;

---6
SELECT vehicle_type,
       SUM(CASE WHEN booking_status='Success' THEN 1 END)::float / COUNT(*) *100 AS success_pct,
       SUM(cancelled_by_customer)+SUM(cancelled_by_driver) AS cancellations
FROM rides
GROUP BY vehicle_type;

---7

SELECT pickup_location,
       SUM(cancelled_by_driver) AS driver_cancel
FROM rides
GROUP BY pickup_location
ORDER BY driver_cancel DESC
LIMIT 1O;

----8
WITH buckets AS (
  SELECT CASE
           WHEN ride_distance<5  THEN '0-5 km'
           WHEN ride_distance<10 THEN '5-10 km'
           ELSE '10+ km' END AS bucket,
         booking_value
  FROM rides
  WHERE booking_status='Success')
SELECT bucket,
       ROUND(AVG(booking_value),2) AS avg_value
FROM buckets
GROUP BY bucket;
----9

SELECT payment_method, COUNT(*) AS cnt
FROM rides
WHERE booking_status='Success'
GROUP BY payment_method
ORDER BY cnt DESC;

---10
SELECT CAST(ride_timestamp AS date) AS ride_day,
       ROUND(SUM(booking_value),2) AS day_revenue
FROM rides
WHERE booking_status = 'Success'
GROUP BY ride_day
ORDER BY day_revenue DESC
LIMIT 5;

---11
SELECT customer_id, COUNT(*) AS rides
FROM rides
WHERE booking_status='Success'
GROUP BY customer_id
ORDER BY rides DESC
LIMIT 10;

---12

SELECT customer_id, COUNT(*) AS rides
FROM rides
GROUP BY customer_id
ORDER BY rides DESC
LIMIT 10;


---13

SELECT vehicle_type,
       ROUND(AVG(customer_rating),2) AS avg_cust_rating
FROM rides
WHERE customer_rating>0
GROUP BY vehicle_type;

--14

SELECT vehicle_type, COUNT(*) AS low_rated
FROM rides
WHERE driver_rating < 3.5
  AND driver_rating>0
  GROUP BY vehicle_type;

  ---15

  WITH cte AS (
  SELECT customer_id, ride_timestamp,
         LEAD(ride_timestamp) OVER (PARTITION BY customer_id
                                    ORDER BY ride_timestamp) AS next_ride
									FROM rides
  WHERE booking_status='Success')
SELECT COUNT(*) FILTER (WHERE next_ride IS NOT NULL
                         AND next_ride-ride_timestamp<=INTERVAL '3 day')
       *100.0 / COUNT(*) AS rebook_pct
FROM cte;

--16

SELECT customer_id,
       SUM(cancelled_by_customer) AS cancels
FROM rides
WHERE ride_timestamp >= NOW() - INTERVAL '60 day'
GROUP BY customer_id
HAVING SUM(cancelled_by_customer) > 3;   

--17
SELECT customer_id,
       AGE(MAX(ride_timestamp), MIN(ride_timestamp)) AS active_span
FROM rides
GROUP BY customer_id
ORDER BY active_span DESC
LIMIT 10;

--18

WITH ranked AS (
  SELECT customer_id, customer_rating,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ride_timestamp DESC) AS rn
  FROM rides)
SELECT a.customer_id
FROM ranked a
JOIN ranked b ON a.customer_id=b.customer_id AND b.rn=2
JOIN ranked c ON a.customer_id=c.customer_id AND c.rn=3
WHERE a.rn=1 AND a.customer_rating>b.customer_rating
  AND b.customer_rating>c.customer_rating;

  --19

  SELECT customer_id
FROM rides
GROUP BY customer_id
HAVING SUM(CASE WHEN booking_status='Success' THEN 1 END)=0;

--20

SELECT customer_id
FROM rides
GROUP BY customer_id
HAVING MAX(ride_timestamp) < NOW() - INTERVAL '60 day';

--21

SELECT vehicle_type, ROUND(AVG(avg_vtat),2) AS avg_vtat
FROM rides
GROUP BY vehicle_type;

---22

SELECT CONCAT(FLOOR(EXTRACT(hour FROM ride_timestamp)/4)*4,':00') AS slot_start,
       ROUND(AVG(avg_ctat),2) AS avg_ctat
FROM rides
GROUP BY slot_start
ORDER BY slot_start;

--23
SELECT ROUND(SUM(incomplete_rides)::numeric / COUNT(*)*100,2) AS pct_incomplete
FROM rides;

SELECT pickup_location,
       ROUND(SUM(incomplete_rides)::numeric / COUNT(*)*100,2) AS pct_incomplete
FROM rides
GROUP BY pickup_location
ORDER BY pct_incomplete DESC
LIMIT 10;

--24--
SELECT pickup_location,
       SUM(CASE WHEN booking_status!='Success' THEN 1 END)::float /
       COUNT(*) *100 AS fail_pct
FROM rides
GROUP BY pickup_location
ORDER BY fail_pct DESC
LIMIT 10;  

--25

WITH tot AS (
  SELECT customer_id, SUM(booking_value) AS revenue
  FROM rides
  WHERE booking_status = 'Success'
  GROUP BY customer_id
),
percentile_90 AS (
  SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY revenue) AS p90
  FROM tot
)
SELECT t.*
FROM tot t
JOIN percentile_90 p ON t.revenue > p.p90;

--26

WITH daily AS (
  SELECT CAST(ride_timestamp AS date) AS day,
         SUM(booking_value) AS rev
  FROM rides
  WHERE booking_status = 'Success'
  GROUP BY day
)
SELECT day,
       rev,
       SUM(rev) OVER (ORDER BY day) AS cum_rev
FROM daily
ORDER BY day;

SELECT pickup_location,
       COUNT(*) AS rides,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM rides
GROUP BY pickup_location
ORDER BY rnk
LIMIT 5;

SELECT DATE_TRUNC('month',ride_timestamp) AS month,
       customer_id,
       ROUND(AVG(booking_value),2) AS avg_value
FROM rides
WHERE booking_status='Success'
GROUP BY month, customer_id
ORDER BY month, avg_value DESC;

SELECT  customer_id , COUNT('booking_ID') as total_rides FROM ola_rides 
GROUP BY customer_id 
ORDER BY total_rides DESC 
LIMIT 5;