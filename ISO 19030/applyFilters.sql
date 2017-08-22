/* Apply selected filters to performance data in table tempRawISO, returning table of DateTime_UTC, IMO_Vessel_Number and Speed_Index
*/

DROP PROCEDURE IF EXISTS applyFilters;

delimiter //

CREATE PROCEDURE applyFilters(SpeedPower_Below BOOLEAN, SpeedPower_Above BOOLEAN, SpeedPower_Trim BOOLEAN, SpeedPower_Disp BOOLEAN, Reference_Seawater_Temp BOOLEAN, Reference_Wind_Speed BOOLEAN, Reference_Water_Depth BOOLEAN, Reference_Rudder_Angle BOOLEAN, SFOC_Out_Range BOOLEAN)

BEGIN

/* Reset filter column */
UPDATE tempRawISO SET Filter_All = FALSE;

/* Apply selected filters */
IF SpeedPower_Below THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_SpeedPower_Below;
END IF;

IF SpeedPower_Above THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_SpeedPower_Above;
END IF;

IF SpeedPower_Trim THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_SpeedPower_Trim;
END IF;

IF SpeedPower_Disp THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_SpeedPower_Disp;
END IF;

IF Reference_Seawater_Temp THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Seawater_Temp;
END IF;

IF Reference_Wind_Speed THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Wind_Speed;
END IF;

IF Reference_Water_Depth THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Water_Depth;
END IF;

IF Reference_Rudder_Angle THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Rudder_Angle;
END IF;

IF SFOC_Out_Range THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_SFOC_Out_Range;
END IF;

/* Query performance values */
SELECT DateTime_UTC, Speed_Loss FROM tempRawISO WHERE NOT Filter_All;

END;