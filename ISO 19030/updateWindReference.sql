/* Calculate relative wind speed and direction at the reference height of the wind resistance coefficients */

DROP PROCEDURE IF EXISTS updateWindReference;

delimiter //

CREATE PROCEDURE updateWindReference()

BEGIN

	/* Get data for compliance table for this analysis */
    
    
    /* Get true wind */
    UPDATE tempRawISO SET True_Wind_Speed = SQRT(POWER(Relative_Wind_Speed, 2) + POWER(Speed_Over_Ground, 2) - 2*Relative_Wind_Speed*Speed_Over_Ground*COS(RADIANS(Relative_Wind_Direction)));
    
    UPDATE tempRawISO SET True_Wind_Direction = DEGREES(ATAN( (Relative_Wind_Speed*SIN(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*SIN(RADIANS(Ship_Heading))) /
		(Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading))) ))
		WHERE Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading)) >= 0;
    
    UPDATE tempRawISO SET True_Wind_Direction = DEGREES(ATAN( (Relative_Wind_Speed*SIN(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*SIN(RADIANS(Ship_Heading))) /
		(Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading))) )) + 180
		WHERE Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading)) < 0;
	
    /* Calculate reference height in current loading condition */
    SET @imo = (SELECT DISTINCT(IMO_Vessel_Number) FROM tempRawISO);
    SET @Tref = (SELECT Draft_Design FROM Vessels WHERE IMO_Vessel_Number = @imo);
    SET @Zrefref = ( SELECT Wind_Reference_Height_Design FROM Vessels WHERE IMO_Vessel_Number = @imo );
    SET @B = ( SELECT Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = @imo );
    SET @A = ( SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO_Vessel_Number = @imo );
    
    UPDATE tempRawISO SET Wind_Reference_Height = (@A*(@Zrefref + (@Tref - (Static_Draught_Fore + Static_Draught_Aft)/2 ))
		+ 0.5*@B*POWER(@Tref - ((Static_Draught_Fore + Static_Draught_Aft)/2), 2)) / Transverse_Projected_Area_Current;
    
	/* True wind at reference height */
    SET @Za = ( SELECT Anemometer_Height FROM Vessels WHERE IMO_Vessel_Number = @imo );
	UPDATE tempRawISO SET True_Wind_Speed_Reference = True_Wind_Speed * POWER((Wind_Reference_Height / @Za), 0.142857142857143);
    
	/* Relative wind at reference height */
    UPDATE tempRawISO SET Relative_Wind_Speed_Reference = SQRT(POWER(True_Wind_Speed_Reference, 2) + POWER(Speed_Over_Ground, 2) +
		2*True_Wind_Speed_Reference*Speed_Over_Ground*COS(RADIANS(True_Wind_Direction) + RADIANS(Ship_Heading)) );
	
    UPDATE tempRawISO SET Relative_Wind_Direction_Reference = DEGREES(ATAN( (True_Wind_Speed_Reference*SIN(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) / 
		(Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) ))
        WHERE (Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) >= 0;
    
    UPDATE tempRawISO SET Relative_Wind_Direction_Reference = DEGREES(ATAN( (True_Wind_Speed_Reference*SIN(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) / 
		(Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) )) + 180
        WHERE (Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) < 0;
END;