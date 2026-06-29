-- 1.4 

-- 1.4.1 Checking Constraints 

-- A. Primary Key Constraints:- 
INSERT INTO CUSTOMER (CustomerID, Name, Email) 
VALUES (1, 'Alice Smith', 'alice@example.com');

-- Attempt to insert another customer with the same ID
INSERT INTO CUSTOMER (CustomerID, Name, Email) 
VALUES (1, 'Bob Jones', 'bob@example.com'); -- Should fail due to duplicate PK

-- B. Testing Foreign Key Constraints
-- Attempt to insert a contact with a non-existent CustomerID
INSERT INTO CUSTOMER_CONTACT (CustomerID, Contact_Number) 
VALUES (999, '123-456-7890'); -- Should fail due to FK constraint

-- C. Testing NOT NULL Constraints 
INSERT INTO CAR (Vehicle_id, Make, Model, Year, Rental_price) 
VALUES (NULL, 'Toyota', 'Camry', 2020, 50.00); -- Should fail due to NOT NULL on Vehicle_id

-- D. Testing CHECK Constraints 
-- Attempt to insert a car with an invalid year
INSERT INTO CAR (Vehicle_id, Make, Model, Year, Rental_price) 
VALUES ('VIN1234', 'Honda', 'Civic', 1940, 40.00); -- Should fail (Year < 1950)

-- Testing ON DELETE CASCADE 
-- Insert a customer and related contact
INSERT INTO CUSTOMER (Name, Email) VALUES ('John Doe', 'john@example.com');
SET @cust_id = LAST_INSERT_ID();

INSERT INTO CUSTOMER_CONTACT (CustomerID, Contact_Number) 
VALUES (@cust_id, '555-1234');

-- Delete the customer
DELETE FROM CUSTOMER WHERE CustomerID = @cust_id;

-- Now check if the contact was deleted as well
SELECT * FROM CUSTOMER_CONTACT WHERE CustomerID = @cust_id; -- Should return 0 rows

-- E. Foreign Key Constraints 
-- Ensuring each contact belongs to a valid customer
ALTER TABLE CUSTOMER_CONTACT 
ADD CONSTRAINT fk_customer_contact FOREIGN KEY (CustomerID) 
REFERENCES CUSTOMER(CustomerID) 
ON DELETE CASCADE  -- If a customer is deleted, delete their contacts
ON UPDATE CASCADE; -- If CustomerID is updated, reflect changes in CUSTOMER_CONTACT

-- Ensuring each car is linked to a valid vehicle record
ALTER TABLE CAR 
ADD CONSTRAINT fk_car_vehicle FOREIGN KEY (Vehicle_id) 
REFERENCES VEHICLE(Vehicle_id) 
ON DELETE RESTRICT  -- Prevent deletion of a vehicle if it's referenced by a car
ON UPDATE CASCADE;  -- If Vehicle_id changes, update it in CAR table

-- Ensuring each transaction (rent/sell) is linked to a valid dealer
ALTER TABLE RENTSELLS 
ADD CONSTRAINT fk_rentsells_dealer FOREIGN KEY (D_id) 
REFERENCES DEALER(D_id) 
ON DELETE CASCADE  -- If a dealer is deleted, remove all their transactions
ON UPDATE CASCADE; -- If D_id changes, update it in RENTSELLS table

-- Ensuring rented or sold cars exist in the system
ALTER TABLE RENTSELLS 
ADD CONSTRAINT fk_rentsells_car FOREIGN KEY (Car_id) 
REFERENCES CAR(Car_id) 
ON DELETE CASCADE  -- If a car is deleted, remove all its rental/sell records
ON UPDATE CASCADE; -- If Car_id changes, update it in RENTSELLS table

-- Ensuring a reservation is linked to a valid customer
ALTER TABLE RESERVATION 
ADD CONSTRAINT fk_reservation_customer FOREIGN KEY (Customer_id) 
REFERENCES CUSTOMER(CustomerID) 
ON DELETE CASCADE  -- If a customer is deleted, remove their reservations
ON UPDATE CASCADE; -- If CustomerID changes, update it in RESERVATION table

-- Ensuring reserved cars exist in the system
ALTER TABLE RESERVATION 
ADD CONSTRAINT fk_reservation_car FOREIGN KEY (Car_id) 
REFERENCES CAR(Car_id) 
ON DELETE CASCADE  -- If a car is deleted, remove its reservations
ON UPDATE CASCADE; -- If Car_id changes, update it in RESERVATION table

-- F.Ensuring each customer has a unique email address
ALTER TABLE CUSTOMER 
ADD CONSTRAINT unique_email UNIQUE (Email);
-- 🔹 Prevents multiple customers from using the same email, ensuring uniqueness.

-- G.Setting the default availability of a car to 'Available'
ALTER TABLE CAR 
MODIFY Availability VARCHAR(20) DEFAULT 'Available';
-- 🔹 If no availability status is provided, the car is automatically set as 'Available' by default.

-- H.Ensuring that the rental price is always greater than 0
ALTER TABLE CAR 
ADD CONSTRAINT check_rental_price CHECK (Rental_price > 0);
-- 🔹 Prevents storing invalid rental prices that are zero or negative.

-- I.Ensuring that the start date of a reservation is before the end date
ALTER TABLE RESERVATION 
ADD CONSTRAINT check_no_overlap CHECK (Start_date < End_date);
-- 🔹 Ensures reservation periods are valid, preventing cases where a reservation starts after it ends.

-- J.That the contact number consists of exactly 10 digits
ALTER TABLE CUSTOMER_CONTACT 
ADD CONSTRAINT check_phone_format CHECK (Contact_Number REGEXP '^[0-9]{10}$');
-- 🔹 Ensures that phone numbers follow a strict numeric format of exactly 10 digits, preventing invalid entries.

-- K.Preventing a customer from reserving the same car multiple times
ALTER TABLE RESERVES 
ADD CONSTRAINT unique_customer_reservation UNIQUE (CustomerID, CarID);
-- 🔹 Ensures that a customer can only reserve a specific car once at a time, avoiding duplicate bookings.


-- 1.4.2 

-- 1.Customers Reserving More Than 3 Cars

INSERT INTO CUSTOMER (CustomerID, Name, Email, Street, City, Postal_Code)
VALUES (1, 'John Doe', 'john.doe@example.com', '123 Main St', 'Toronto', 'M5A1A1');

INSERT INTO CAR (Car_id, Vehicle_id, Make, Model, Year, Rental_price, Availability)
VALUES 
(11, 'V12311', 'Toyota', 'Corolla', 2022, 50.00, 'Available'),
(12, 'V12312', 'Honda', 'Civic', 2023, 55.00, 'Available'),
(13, 'V12313', 'Ford', 'Focus', 2021, 45.00, 'Available'),
(14, 'V12314', 'BMW', 'X5', 2024, 100.00, 'Available').

INSERT INTO RESERVES (CustomerID, CarID) 
VALUES (1, 11), (1, 12), (1, 13), (1, 14);

SELECT CustomerID, COUNT(*) AS Reservation_Count
FROM RESERVES
GROUP BY CustomerID
HAVING COUNT(*) > 3;
	 

-- 2.Overlapping Reservations for the Same Car 

INSERT INTO CUSTOMER (CustomerID, Name, Email, Street, City, Postal_Code)
VALUES 
(1, 'John Doe', 'john.doe@example.com', '123 Main St', 'Toronto', 'M5A1A1'),
(2, 'Alice Smith', 'alice.smith@example.com', '456 Elm St', 'Vancouver', 'V6B3K3');

INSERT INTO CAR (Car_id, Vehicle_id, Make, Model, Year, Rental_price, Availability)
VALUES 
(11, 'V12311', 'Toyota', 'Corolla', 2022, 50.00, 'Available'),
(12, 'V12312', 'Honda', 'Civic', 2023, 55.00, 'Available'),
(13, 'V12313', 'Ford', 'Focus', 2021, 45.00, 'Available'),
(14, 'V12314', 'BMW', 'X5', 2024, 100.00, 'Available');

INSERT INTO RESERVATION (Reservation_id, Start_date, End_date, Total_amount, Customer_id, Status)
VALUES 
(101, '2025-04-01', '2025-04-05', 200.00, 1, 'Confirmed'),
(102, '2025-04-02', '2025-04-06', 250.00, 2, 'Pending');

INSERT INTO RESERVES (CustomerID, CarID) VALUES
(1, 11),
(2, 11).

 

-- 3.Cars Marked as ‘Rented’ But Not in Any Active Reservation

INSERT INTO CUSTOMER (CustomerID, Name, Email, Street, City, Postal_Code)
VALUES 
(1, 'John Doe', 'john.doe@example.com', '123 Main St', 'Toronto', 'M5A1A1'),
(2, 'Alice Smith', 'alice.smith@example.com', '456 Elm St', 'Vancouver', 'V6B3K3');

INSERT INTO CAR (Car_id, Vehicle_id, Make, Model, Year, Rental_price, Availability)
VALUES 
(11, 'V12311', 'Toyota', 'Corolla', 2022, 50.00, 'Available'),
(12, 'V12312', 'Honda', 'Civic', 2023, 55.00, 'Available'),
(13, 'V12313', 'Ford', 'Focus', 2021, 45.00, 'Available'),
(14, 'V12314', 'BMW', 'X5', 2024, 100.00, 'Available');

INSERT INTO RESERVATION (Reservation_id, Start_date, End_date, Total_amount, Customer_id, Status)
VALUES 
(101, '2025-04-01', '2025-04-05', 200.00, 1, 'Confirmed'),
(102, '2025-04-02', '2025-04-06', 250.00, 2, 'Pending');

INSERT INTO RESERVES (CustomerID, CarID) 
VALUES 
(1, 11), (1, 12), (1, 13), (1, 14),  
(2, 11), (2, 12);  

SELECT C.Car_id, C.Make, C.Model
FROM CAR C
LEFT JOIN RESERVATION R ON C.Car_id = R.Car_id
WHERE C.Availability = 'Rented' 
AND (R.Reservation_id IS NULL OR R.Status NOT IN ('Confirmed', 'Pending'));

 

-- 4.Reservations Where End Date is Before Start Date

INSERT INTO CUSTOMER (CustomerID, Name, Email, Street, City, Postal_Code)
VALUES 
(1, 'John Doe', 'john.doe@example.com', '123 Main St', 'Toronto', 'M5A1A1'),
(2, 'Alice Smith', 'alice.smith@example.com', '456 Elm St', 'Vancouver', 'V6B3K3');

INSERT INTO CAR (Car_id, Vehicle_id, Make, Model, Year, Rental_price, Availability)
VALUES 
(11, 'V12311', 'Toyota', 'Corolla', 2022, 50.00, 'Available'),
(12, 'V12312', 'Honda', 'Civic', 2023, 55.00, 'Available'),
(13, 'V12313', 'Ford', 'Focus', 2021, 45.00, 'Available'),
(14, 'V12314', 'BMW', 'X5', 2024, 100.00, 'Available');

INSERT INTO RESERVATION (Reservation_id, Start_date, End_date, Total_amount, Customer_id, Status)
VALUES 
(101, '2025-04-01', '2025-04-05', 200.00, 1, 'Confirmed'),
(102, '2025-04-02', '2025-04-06', 250.00, 2, 'Pending');

SELECT * 
FROM RESERVATION 
WHERE End_date <= Start_date;

 




-- 5.Customers Making Inquiries for Cars They Have Already Reserved (Violation)

INSERT INTO CUSTOMER (CustomerID, Name, Email, Street, City, Postal_Code)
VALUES 
(1, 'John Doe', 'john.doe@example.com', '123 Main St', 'Toronto', 'M5A1A1'),
(2, 'Alice Smith', 'alice.smith@example.com', '456 Elm St', 'Vancouver', 'V6B3K3');

INSERT INTO CAR (Car_id, Vehicle_id, Make, Model, Year, Rental_price, Availability)
VALUES 
(11, 'V12311', 'Toyota', 'Corolla', 2022, 50.00, 'Available'),
(12, 'V12312', 'Honda', 'Civic', 2023, 55.00, 'Available'),
(13, 'V12313', 'Ford', 'Focus', 2021, 45.00, 'Available'),
(14, 'V12314', 'BMW', 'X5', 2024, 100.00, 'Available');

INSERT INTO INQUIRE (CustomerID, CarID) 
VALUES (1, 12), (2, 14);

INSERT INTO RESERVES (CustomerID, CarID) 
VALUES 
(1, 11), (1, 12), (1, 13), (1, 14),  
(2, 11), (2, 12);  

SELECT I.CustomerID, I.CarID
FROM INQUIRE I
JOIN RESERVES R ON I.CustomerID = R.CustomerID AND I.CarID = R.CarID;

 

-- 6.Duplicate Customer Contact 

INSERT INTO CUSTOMER (Name, Email) VALUES
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Williams', 'bob.williams@example.com');

INSERT INTO CUSTOMER_CONTACT (CustomerID, Contact_Number) VALUES
(1, '1234567890'),  -- Alice's contact number
(2, '0987654321'),  -- Bob's contact number
(1, '1234567890');  -- Alice's contact number again (duplicate)

SELECT Contact_Number, COUNT(*) 
FROM CUSTOMER_CONTACT
GROUP BY Contact_Number
HAVING COUNT(*) > 1;

 

-- 7.Multiple customers cannot share the same contact number.

INSERT INTO CUSTOMER_CONTACT (CustomerID, Contact_Number) VALUES
(1, '1234567890'),  -- Alice's contact number 1
(1, '0987654321');  -- Alice's contact number 2

INSERT INTO CUSTOMER_CONTACT (CustomerID, Contact_Number) VALUES
(1, '1234567899'),  -- Alice's contact number 1
(2, '1112233445');  -- Bob's contact number

SELECT Contact_Number, COUNT(DISTINCT CustomerID) AS Number_of_Customers
FROM CUSTOMER_CONTACT
GROUP BY Contact_Number
HAVING COUNT(DISTINCT CustomerID) > 1;


 

-- 8.Carn both in LUXURY_CAR and ECONOMY_CAR 

INSERT INTO CAR (Vehicle_id, Make, Model, Year, Rental_price, Availability) VALUES
('V12319', 'Audi', 'A6', 2022, 100.00, 'Available'),
('V12320', 'BMW', 'X5', 2021, 120.00, 'Available');

INSERT INTO LUXURY_CAR (Car_id) VALUES
(19);  -- Audi A6 is a luxury car

INSERT INTO ECONOMY_CAR (Car_id, Fuel_Efficiency) VALUES
(19, 15.5);  -- Audi A6 is also an economy car (for the sake of this example)

SELECT L.Car_id 
FROM LUXURY_CAR L
JOIN ECONOMY_CAR E ON L.Car_id = E.Car_id;

 

