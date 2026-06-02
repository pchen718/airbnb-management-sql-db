-- Query 1: Cleaner Assignment Status
-- Purpose: Identify which units still need assigned cleaners

SELECT
U.UNITID,
U.STREET,
U.CITY,
U.STATE,
U.CLEANERID,
CASE
WHEN U.CLEANERID IS NULL THEN 'NEEDS CLEANER'
ELSE 'ASSIGNED'
END AS CleanerStatus
FROM UNIT U
ORDER BY CleanerStatus DESC, U.UNITID;

-- Query 2: Repeat Renters
-- Purpose: Identify renters who have booked more than one unit

SELECT
unit.UNITID AS UnitIdentification,
rents.RENTERID AS RenterIdentification
FROM unit
JOIN rents
ON unit.UNITID = rents.UNITID
WHERE rents.RENTERID IN (
SELECT RENTERID
FROM rents
GROUP BY RENTERID
HAVING COUNT(DISTINCT UNITID) >= 2
);

-- Query 3: Contractor Payments
-- Purpose: Summarize contractor earnings from property maintenance work

SELECT
c.ContractorName,
SUM(f.PaymentAmount) AS TotalEarned
FROM FIXES f
JOIN CONTRACTOR c
ON f.ContractorID = c.ContractorID
GROUP BY c.ContractorID
ORDER BY TotalEarned DESC;

-- Query 4: Owned vs Managed Unit Performance
-- Purpose: Compare booking activity and occupancy across unit types

SELECT
u.UnitID,
u.Street,
CASE
WHEN m.UnitID IS NOT NULL THEN 'Managed'
ELSE 'Owned'
END AS UnitType,
COUNT(r.UnitID) AS TotalBookings,
COALESCE(SUM(DATEDIFF(r.ENDDATE, r.STARTDATE)), 0) AS TotalNights
FROM UNIT u
LEFT JOIN MANAGED m
ON u.UnitID = m.UnitID
LEFT JOIN RENTS r
ON u.UnitID = r.UnitID
GROUP BY
u.UnitID,
u.Street,
UnitType
ORDER BY
TotalBookings DESC,
u.UnitID;

-- Query 5: Cleaner Workload Summary
-- Purpose: Analyze cleaner workload by units, bookings, and guest volume

SELECT
c.CLEANERID,
COUNT(DISTINCT u.UNITID) AS Units_Assigned,
COUNT(r.STARTDATE) AS Num_Bookings,
COALESCE(SUM(r.NUMGUESTS), 0) AS Total_Guests
FROM CLEANER c
JOIN UNIT u
ON c.CLEANERID = u.CLEANERID
LEFT JOIN RENTS r
ON u.UNITID = r.UNITID
GROUP BY c.CLEANERID
ORDER BY Num_Bookings DESC, Total_Guests DESC;

-- Query 6: Booking Summary Report
-- Purpose: Generate a complete list of renter bookings and unit information

SELECT
R.FIRSTNAME,
R.LASTNAME,
U.STREET,
U.CITY,
T.STARTDATE,
T.ENDDATE,
T.NUMGUESTS
FROM RENTER R
INNER JOIN RENTS T
ON R.RENTERID = T.RENTERID
INNER JOIN UNIT U
ON T.UNITID = U.UNITID
ORDER BY T.STARTDATE DESC;
