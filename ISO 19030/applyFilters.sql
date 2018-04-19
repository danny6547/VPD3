/* Apply selected filters to performance data in table tempRawISO, returning table of DateTime_UTC, IMO_Vessel_Number and Speed_Index
*/

DROP PROCEDURE IF EXISTS applyFilters;

delimiter //

CREATE PROCEDURE applyFilters(SpeedPower_Below BOOLEAN, SpeedPower_Above BOOLEAN, SpeedPower_Trim BOOLEAN, SpeedPower_Disp BOOLEAN, Reference_Seawater_Temp BOOLEAN, Reference_Wind_Speed BOOLEAN, Reference_Water_Depth BOOLEAN, Reference_Rudder_Angle BOOLEAN, SFOC_Out_Range BOOLEAN, Chauvenet BOOLEAN, Valid BOOLEAN)

BEGIN

/* Reset filter column */
UPDATE tempRawISO SET Filter_All = FALSE;

UPDATE tempRawISO SET Filter_All = TRUE WHERE Speed_Through_Water > 18.0055556;
UPDATE tempRawISO SET Filter_All = TRUE WHERE Speed_Through_Water <= 0;

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

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Seawater_Temp OR Seawater_Temperature IS NULL;
END IF;

IF Reference_Wind_Speed THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Wind_Speed OR Relative_Wind_Speed IS NULL;
END IF;

IF Reference_Water_Depth THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Water_Depth IS NULL;
	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Water_Depth;
END IF;

IF Reference_Rudder_Angle THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Filter_Reference_Rudder_Angle OR Rudder_Angle IS NULL;
END IF;

IF Chauvenet THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE Chauvenet_Criteria;
END IF;

IF Valid THEN

	UPDATE tempRawISO SET Filter_All = TRUE WHERE NOT Validated;
END IF;

/* Query performance values */
SELECT DateTime_UTC, Speed_Loss FROM tempRawISO WHERE NOT Filter_All;

END;