/* Update air density */

DROP PROCEDURE IF EXISTS updateAirDensity;

delimiter //

CREATE PROCEDURE updateAirDensity()
BEGIN

	UPDATE tempRawISO SET Air_Density = (Air_Pressure / ( (Air_Temperature + 273.15) * (SELECT Specific_Gas_Constant_Air FROM `static`.GlobalConstants) ) );
END