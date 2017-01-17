/* Insert from temporary analysis table into final performance data table */

DROP PROCEDURE IF EXISTS insertIntoPerformanceData;

delimiter //

CREATE PROCEDURE insertIntoPerformanceData(allFilt BOOLEAN, speedPowerFilt BOOLEAN, SFOCFilt BOOLEAN)

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
INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, FrequencySufficient, SpeedPowerInRange, SFOCInRange)
VALUES (@imo, @startd, @endd, freqSufficient, speedPowerFilt, SFOCFilt) ON DUPLICATE KEY UPDATE 
FrequencySufficient = VALUES(FrequencySufficient), SpeedPowerInRange = VALUES(SpeedPowerInRange), SFOCInRange = VALUES(SFOCInRange);

/* Perform selected filtering */
IF allFilt THEN
	DELETE FROM tempRawISO WHERE AllFilt;
END IF;
IF speedPowerFilt THEN
	DELETE FROM tempRawISO WHERE Filter_SpeedPower_Below;
END IF;
IF SFOCFilt THEN
	DELETE FROM tempRawISO WHERE Filter_SFOC_Out_Range;
END IF;

/* Insert data from temporary table into performance data after filtering */
INSERT INTO PerformanceData
	(DateTime_UTC, IMO_Vessel_Number, Speed_Index)
		SELECT DateTime_UTC, IMO_Vessel_Number, Speed_Loss
			FROM tempRawISO AS aa WHERE NOT EXISTS(
				Select DateTime_UTC, IMO_Vessel_Number, Speed_Loss
					FROM PerformanceData AS bb WHERE
						aa.DateTime_UTC = bb.DateTime_UTC AND
						aa.IMO_Vessel_Number = bb.IMO_Vessel_Number);

END;