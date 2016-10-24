use test2;

/* Select only performance data whose dates are before a start date found by "offsetting" from the first row */ 
/* SELECT * FROM `performance data` WHERE IMO = 9280603 HAVING Date < (SELECT StartDate FROM drydockdates WHERE IMO_Vessel_Number = 9280603 ORDER BY StartDate LIMIT 1 OFFSET 0); */

/* Define a value for the Dry Docking interval based on */
SELECT Date, `Performance Index`,
	CASE
		WHEN Date < (SELECT StartDate FROM DryDockDates WHERE IMO_VESSEL_NUMBER = 9280603 ORDER BY StartDate LIMIT 1 OFFSET 0) THEN 0
		WHEN Date > (SELECT EndDate FROM DryDockDates WHERE IMO_VESSEL_NUMBER = 9280603 ORDER BY StartDate LIMIT 1 OFFSET 0) AND Date < (SELECT StartDate FROM DryDockDates WHERE IMO_VESSEL_NUMBER = 9280603 ORDER BY StartDate LIMIT 1 OFFSET 1) THEN 1
        WHEN Date > (SELECT EndDate FROM DryDockDates WHERE IMO_VESSEL_NUMBER = 9280603 ORDER BY StartDate LIMIT 1 OFFSET 1) THEN 2
	END as 'Dry Dock Interval Index'
FROM `Performance Data`
WHERE IMO = 9280603