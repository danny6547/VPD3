/* Correct for Wind Resistance */

UPDATE tempRawISO 
SET Wind_Resistance_Relative = 
	0.5 * 
    Air_Density * 
    POWER(Relative_Wind_Speed, 2) * 
    ( SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO = 1234567) * 
    ( SELECT Wind_Resist_Coeff_Dir FROM Vessels WHERE IMO = 1234567);