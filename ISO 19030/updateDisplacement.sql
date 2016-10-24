/* Set values of dispalcement in ISO analysis from current draft, trim values and diplacement table values */

UPDATE tempRawISO SET Displacement = (SELECT Displacement FROM Displacement WHERE IMO_Vessel_Number = imo AND
																	Draft_Actual_Fore = (SELECT Draft_Actual_Fore FROM tempRawISO) AND
																	Static_Draught_Aft = (SELECT Static_Draught_Aft FROM tempRawISO));
