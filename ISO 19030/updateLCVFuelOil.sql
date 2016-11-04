/* Update delivered power */

delimiter //

CREATE PROCEDURE updateLCVFuelOil()
BEGIN
	
	UPDATE tempRawISO SET Lower_Caloirifc_Value_Fuel_Oil = (SELECT Lower_Heating_Value FROM BunkerDeliveryNote WHERE BDN_Number = tempRawISO.ME_Fuel_BDN);
	
END;