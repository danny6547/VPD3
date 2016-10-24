/* Calculate shaft power in temp ISO raw table */

UPDATE tempRawISO SET Shaft_Power = Shaft_Torque * Shaft_Revolutions;