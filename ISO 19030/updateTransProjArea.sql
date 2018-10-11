/* Update Transverse Projected Area based on Current loading condition */

DROP PROCEDURE IF EXISTS updateTransProjArea;

delimiter //

CREATE PROCEDURE updateTransProjArea(vcid INT)
BEGIN

	SET @T := (SELECT Transverse_Projected_Area_Design FROM `static`.vesselconfiguration WHERE Vessel_Configuration_Id = vcid);
	SET @D := (SELECT Draft_Design FROM `static`.vesselconfiguration WHERE Vessel_Configuration_Id = vcid);
	SET @B := (SELECT Breadth_Moulded FROM `static`.vesselconfiguration WHERE Vessel_Configuration_Id = vcid);
	
	UPDATE tempRawISO SET Transverse_Projected_Area_Current =  @T + (( @D - (Static_Draught_Fore + Static_Draught_Aft)/2) * @B );
END;