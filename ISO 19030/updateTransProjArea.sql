/* Update Transverse Projected Area based on Current loading condition */



DROP PROCEDURE IF EXISTS updateTransProjArea;

delimiter //

CREATE PROCEDURE updateTransProjArea(imo INT)
BEGIN

	SET @T := (SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO_Vessel_Number = imo);
	SET @D := (SELECT Draft_Design FROM Vessels WHERE IMO_Vessel_Number = imo);
	SET @B := (SELECT Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = imo);
	
	UPDATE tempRawISO
	SET Transverse_Projected_Area_Current =  @T + (( @D - (Static_Draught_Fore + Static_Draught_Aft)/2) * @B );
	
END;