/* Create dry-docking index column */
/* SELECT * FROM `performance data` WHERE IMO = 9454448; */
SELECT IMO_Vessel_Number, StartDate, EndDate FROM DryDockDates ORDER BY IMO_Vessel_Number, StartDate;

/* 2011-09-17 */
/* 2014-08-10 */

SELECT Date, `Performance Index`, StartDate, EndDate FROM `performance data`, `drydockdates` WHERE IMO_Vessel_Number = 9280603 AND Date < StartDate AND Date < EndDate;