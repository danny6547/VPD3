/* Update Transverse Projected Area in Current loading condition */

delimiter //

CREATE PROCEDURE updateTransProjArea(imo INT)
BEGIN
	
	UPDATE tempRawISO
	SET Transverse_Projected_Area_Current = 
		(SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO_Vessel_Number = imo) + 
		(((SELECT Draft_Design FROM Vessels WHERE IMO_Vessel_Number = imo) - (Static_Draught_Fore + Static_Draught_Aft)/2) *
		 (SELECT Breadth_Moulded FROM Vessels WHERE IMO = imo) );
	
END;