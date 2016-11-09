/* Update LCV and Density at 15 degrees of bunker from bunker notes */

delimiter //

CREATE PROCEDURE updateFromBunkerNote()
BEGIN
	
	UPDATE tempRawISO SET Lower_Caloirifc_Value_Fuel_Oil = (SELECT Lower_Heating_Value FROM BunkerDeliveryNote WHERE BDN_Number = tempRawISO.ME_Fuel_BDN);
	UPDATE tempRawISO SET Density_Fuel_Oil_15C = (SELECT Density_At_15dg FROM BunkerDeliveryNote WHERE BDN_Number = tempRawISO.ME_Fuel_BDN);
	
END;