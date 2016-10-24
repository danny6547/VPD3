/* Update air density  */

UPDATE tempRawISO SET Air_Density = Air_Pressure / ((Air_Temperatue + 273.15)* (SELECT Specific_Gas_Constant_Air FROM GlobalConstants));