/* Update air density */

USE hull_performance;


delimiter //

CREATE PROCEDURE updateAirDensity()
BEGIN

	UPDATE tempRawISO SET Air_Density = (Air_Pressure / ( (Air_Temperature + 273.15) * (SELECT Specific_Gas_Constant_Air FROM GlobalConstants) ) );

END