/* Update LCV and Density at 15 degrees Celsius of bunker fuel from bunker 
notes */

USE hull_performance;


DROP PROCEDURE IF EXISTS updateFromBunkerNote;

delimiter //

CREATE PROCEDURE updateFromBunkerNote(imo INT(7))
BEGIN
	
    DECLARE BunkerReportAvailable BOOLEAN DEFAULT FALSE;
    DECLARE BunkerDataMissing BOOLEAN DEFAULT FALSE;
    DECLARE BunkerDataMissingError CONDITION FOR SQLSTATE '45000';
    
    SET BunkerReportAvailable := (SELECT COUNT(*) FROM tempRaw WHERE ME_Fuel_BDN IS NOT NULL) > 0;
    
    SET BunkerDataMissing := (SELECT COUNT(*) FROM tempRaw WHERE ME_Fuel_BDN NOT IN (SELECT BDN_Number FROM BunkerDeliveryNote) AND ME_Fuel_BDN IS NOT NULL) > 0;
    
    IF BunkerDataMissing THEN
		SIGNAL BunkerDataMissingError SET MESSAGE_TEXT = 'Bunker data for vessel not found in Bunker Delivery Note table.';
    END IF;
    
    IF BunkerReportAvailable
    THEN
		UPDATE tempRaw SET Lower_Caloirifc_Value_Fuel_Oil = (SELECT Lower_Heating_Value FROM BunkerDeliveryNote WHERE BDN_Number = tempRaw.ME_Fuel_BDN);
        UPDATE tempRaw SET Density_Fuel_Oil_15C = (SELECT Density_At_15dg FROM BunkerDeliveryNote WHERE BDN_Number = tempRaw.ME_Fuel_BDN);
    ELSE
		UPDATE tempRaw SET Lower_Caloirifc_Value_Fuel_Oil = (SELECT Lower_Heating_Value FROM BunkerDeliveryNote WHERE BDN_Number = 'Default_HFO');
        UPDATE tempRaw SET Density_Fuel_Oil_15C = (SELECT Density_At_15dg FROM BunkerDeliveryNote WHERE BDN_Number = 'Default_HFO');
    END IF;
    
    /*
	UPDATE tempRawISO SET Lower_Caloirifc_Value_Fuel_Oil = (SELECT Lower_Heating_Value FROM BunkerDeliveryNote WHERE BDN_Number = tempRawISO.ME_Fuel_BDN);
	UPDATE tempRawISO SET Density_Fuel_Oil_15C = (SELECT Density_At_15dg FROM BunkerDeliveryNote WHERE BDN_Number = tempRawISO.ME_Fuel_BDN);
	*/
END;