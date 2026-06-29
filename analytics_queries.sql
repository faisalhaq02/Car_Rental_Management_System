-- 1. Cars Currently Rented Out (R10)
-- Objective: Track active rentals.

SELECT 
    CAR.Make, CAR.Model, R.Start_date, R.End_date, R.Status
FROM RESERVATION R
JOIN CAR ON R.Customer_id IN (
    SELECT CustomerID FROM RESERVES WHERE RESERVES.CarID = CAR.Car_id
)
WHERE R.Status = 'Confirmed';


-- 2. City-wise Customer Distribution (R9) 
-- Objective: Understand geographic reach.
SELECT 
    City, COUNT(*) AS Number_of_Customers
FROM CUSTOMER
GROUP BY City
ORDER BY Number_of_Customers DESC;


-- 3. Top Customers by Spending (R5)
-- Objective: Recognize loyal and high-value customer. 
SELECT 
    C.CustomerID, C.Name, SUM(R.Total_amount) AS Total_Spent
FROM CUSTOMER C
JOIN RESERVATION R ON C.CustomerID = R.Customer_id
WHERE R.Status = 'Completed'
GROUP BY C.CustomerID, C.Name
ORDER BY Total_Spent DESC
LIMIT 10;


-- 4. Reservation Status Distribution (R6)
-- Objective: Monitor reservation lifecycle.
SELECT 
    Status, COUNT(*) AS Count
FROM RESERVATION
GROUP BY Status;


-- 5. Maintenance Costs per Car (R7)
-- Objective: Track vehicle maintenance costs.
SELECT 
    CAR.Make, CAR.Model, SUM(M.Cost) AS Total_Maintenance_Cost
FROM MAINTENANCE M
JOIN CAR ON M.Car_id = CAR.Car_id
GROUP BY CAR.Make, CAR.Model
ORDER BY Total_Maintenance_Cost DESC;


-- 6. Revenue Contribution by City (R18)
-- Objective: See which cities generate the most revenue.
SELECT 
    C.City,
    SUM(R.Total_amount) AS Revenue
FROM CUSTOMER C
JOIN RESERVATION R ON C.CustomerID = R.Customer_id
WHERE R.Status = 'Completed'
GROUP BY C.City
ORDER BY Revenue DESC;

-- 7. Peak Booking Days (R19)
-- Objective: Understand on which weekdays most reservations start.
SELECT 
    DAYNAME(Start_date) AS Day_of_Week,
    COUNT(*) AS Number_of_Bookings
FROM RESERVATION
WHERE Status = 'Completed'
GROUP BY Day_of_Week
ORDER BY FIELD(Day_of_Week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


-- 8. Cars with Highest Maintenance Cost per Reservation (R20)
-- Objective: Identify cars that are expensive to maintain relative to how often they're rented (helps in fleet optimization).

SELECT 
    C.Make, C.Model,
    SUM(M.Cost) / COUNT(DISTINCT R.Reservation_id) AS Avg_Maintenance_Per_Reservation
FROM MAINTENANCE M
JOIN CAR C ON M.Car_id = C.Car_id
LEFT JOIN RESERVATION R ON R.Customer_id IN (
    SELECT CustomerID FROM RESERVES WHERE RESERVES.CarID = C.Car_id
) AND R.Status = 'Completed'
GROUP BY C.Make, C.Model
HAVING COUNT(DISTINCT R.Reservation_id) > 0
ORDER BY Avg_Maintenance_Per_Reservation DESC;


-- 9. Profitability per Car Model (R21)
-- Objective: Analyze which car models are the most profitable overall (Total Revenue – Maintenance Cost).
SELECT 
    C.Make, C.Model,
    IFNULL(SUM(R.Total_amount), 0) AS Total_Revenue,
    IFNULL(SUM(M.Cost), 0) AS Total_Maintenance_Cost,
    (IFNULL(SUM(R.Total_amount), 0) - IFNULL(SUM(M.Cost), 0)) AS Net_Profit
FROM CAR C
LEFT JOIN RESERVES RS ON C.Car_id = RS.CarID
LEFT JOIN RESERVATION R ON RS.CustomerID = R.Customer_id AND R.Status = 'Completed'
LEFT JOIN MAINTENANCE M ON C.Car_id = M.Car_id
GROUP BY C.Make, C.Model
ORDER BY Net_Profit DESC;


-- 10. Maintenance Frequency by Car Model (R22)
-- Objective: Measure how frequently each car requires maintenance (i.e., maintenance count vs rental count) to identify problematic models.
SELECT 
    C.Make, C.Model,
    COUNT(DISTINCT M.M_id) AS Maintenance_Count,
    COUNT(DISTINCT R.Reservation_id) AS Rental_Count,
    ROUND(
        COUNT(DISTINCT M.M_id) / 
        IF(COUNT(DISTINCT R.Reservation_id) = 0, 1, COUNT(DISTINCT R.Reservation_id)),
        2
    ) AS Maintenance_Per_Rental
FROM CAR C
LEFT JOIN MAINTENANCE M ON C.Car_id = M.Car_id
LEFT JOIN RESERVES RS ON C.Car_id = RS.CarID
LEFT JOIN RESERVATION R ON RS.CustomerID = R.Customer_id AND R.Status = 'Completed'
GROUP BY C.Make, C.Model
ORDER BY Maintenance_Per_Rental DESC;
