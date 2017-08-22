/* Insert from temporary analysis table into final performance data table.
Procedure will apply the input filters to the performance values prior to 
inserting the data into table PerformanceData, i.e. data will not be 
inserted for any row where any of the corresponding filter columns have the
value TRUE.
*/

DROP PROCEDURE IF EXISTS insertIntoPerformanceData;

delimiter //

CREATE PROCEDURE insertIntoPerformanceData(Comment TEXT, SpeedPower_Below BOOLEAN, SpeedPower_Above BOOLEAN, SpeedPower_Trim BOOLEAN, SpeedPower_Disp BOOLEAN, Reference_Seawater_Temp BOOLEAN, Reference_Wind_Speed BOOLEAN, Reference_Water_Depth BOOLEAN, Reference_Rudder_Angle BOOLEAN, SFOC_Out_Range BOOLEAN)

BEGIN

/* Get data for compliance table for this analysis */
DECLARE imo INT(7);
DECLARE starttime DATETIME;
DECLARE endtime DATETIME;
DECLARE compliant BOOLEAN;
DECLARE freqSufficient BOOLEAN;

/* Determine whether instrument frequencies are sufficient for standard compliance, from data */
CALL validateFrequencies(@valSTWt,
					 @valDelt,
					 @valShRt,
					 @valRWSt,
					 @valRWDt,
					 @valSOGt,
					 @valHeat,
					 @valRudt,
					 @valWDpt,
					 @valTmpt);
SET freqSufficient = @valSTWt AND @valDelt AND @valShRt AND @valRWSt AND @valRWDt AND @valSOGt AND @valHeat AND @valRudt AND @valWDpt AND @valTmpt;

/* Declare whether standard has been complied with */
CALL IMOStartEnd(@imo, @startd, @endd);
INSERT INTO Analysis (IMO_Vessel_Number, StartDate, EndDate, FrequencySufficient, SpeedPowerInRange, SFOCInRange, Comment)
VALUES (@imo, @startd, @endd, freqSufficient, SpeedPower_Above, SFOC_Out_Range, Comment) ON DUPLICATE KEY UPDATE 
 /*Filter_SpeedPower_Below = VALUES(Filter_SpeedPower_Below),
 Filter_SpeedPower_Above = VALUES(Filter_SpeedPower_Above),
 Filter_SpeedPower_Trim = VALUES(Filter_SpeedPower_Trim),*/
 IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
 StartDate = VALUES(StartDate),
 EndDate = VALUES(EndDate),
 FrequencySufficient = VALUES(FrequencySufficient),
 SpeedPowerInRange = VALUES(SpeedPowerInRange),
 SFOCInRange = VALUES(SFOCInRange),
 Comment = VALUES(Comment);

/* Apply filters */
CALL applyFilters(SpeedPower_Below, SpeedPower_Above, SpeedPower_Trim, SpeedPower_Disp, Reference_Seawater_Temp,
					Reference_Wind_Speed, Reference_Water_Depth, Reference_Rudder_Angle, SFOC_Out_Range);

/* Remove data from performance table correspoding to this analysis */
DELETE FROM PerformanceData WHERE 
	IMO_Vessel_Number = @imo AND 
    DateTime_UTC BETWEEN @startd AND @endd;

/* Insert data into performance table after filtering */
INSERT INTO PerformanceData
	(DateTime_UTC, IMO_Vessel_Number, Speed_Index)
		SELECT DateTime_UTC, IMO_Vessel_Number, Speed_Loss
			FROM tempRawISO
				WHERE NOT Filter_All
					ON DUPLICATE KEY UPDATE	
						DateTime_UTC = VALUES(DateTime_UTC),
						IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
						Speed_Index = VALUES(Speed_Index);

END;