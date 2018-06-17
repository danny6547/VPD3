/* Calculate relative wind speed and direction at the reference height of the wind resistance coefficients */

DROP PROCEDURE IF EXISTS updateWindReference;

delimiter //

CREATE PROCEDURE updateWindReference(vcid INT)

BEGIN

	/* */
	/* Get data for compliance table for this analysis */
    
    /* Get true wind */
    UPDATE `inservice`.tempRawISO SET True_Wind_Speed = SQRT(POWER(Relative_Wind_Speed, 2) + POWER(Speed_Over_Ground, 2) - 2*Relative_Wind_Speed*Speed_Over_Ground*COS(RADIANS(Relative_Wind_Direction)));
    
    UPDATE `inservice`.tempRawISO SET True_Wind_Direction = DEGREES(ATAN( (Relative_Wind_Speed*SIN(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*SIN(RADIANS(Ship_Heading))) /
		(Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading))) ))
		WHERE Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading)) >= 0;
    
    UPDATE `inservice`.tempRawISO SET True_Wind_Direction = DEGREES(ATAN( (Relative_Wind_Speed*SIN(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*SIN(RADIANS(Ship_Heading))) /
		(Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading))) )) + 180
		WHERE Relative_Wind_Speed*COS(RADIANS(Relative_Wind_Direction) + RADIANS(Ship_Heading)) - Speed_Over_Ground*COS(RADIANS(Ship_Heading)) < 0;
	
    /* Set Direction in range 0 to 360 degrees */
    UPDATE `inservice`.tempRawISO SET True_Wind_Direction = CASE
		WHEN True_Wind_Direction >= 0 THEN MOD(True_Wind_Direction, 360)
		WHEN True_Wind_Direction < 0 THEN 360 + MOD(True_Wind_Direction, 360)
	END;
    
    /* Calculate reference height in current loading condition */
    SET @Tref = (SELECT Draft_Design FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
    SET @Zrefref = ( SELECT Wind_Reference_Height_Design FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
    SET @B = ( SELECT Breadth_Moulded FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
    SET @A = ( SELECT Transverse_Projected_Area_Design FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
    
    UPDATE `inservice`.tempRawISO SET Wind_Reference_Height = (@A*(@Zrefref + (@Tref - (Static_Draught_Fore + Static_Draught_Aft)/2 ))
		+ 0.5*@B*POWER(@Tref - ((Static_Draught_Fore + Static_Draught_Aft)/2), 2)) / Transverse_Projected_Area_Current;
    
	/* True wind at reference height */
    SET @Za = ( SELECT Anemometer_Height FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
	UPDATE `inservice`.tempRawISO SET True_Wind_Speed_Reference = True_Wind_Speed * POWER((Wind_Reference_Height / (@Za + @Tref - (Static_Draught_Fore + Static_Draught_Aft)/2)), 0.142857142857143);
    
	/* Relative wind at reference height */
	/*UPDATE `inservice`.tempRawISO SET WVX = True_Wind_Speed_Reference * COS((True_Wind_Direction - Ship_Heading) * PI()/180);
	UPDATE `inservice`.tempRawISO SET WVY = True_Wind_Speed_Reference * SIN((True_Wind_Direction - Ship_Heading) * PI()/180);*/
    /* 
    SET WVX = (SELECT True_Wind_Speed FROM tempRawISO) * COS(((SELECT True_Wind_Direction FROM tempRawISO) - (SELECT Ship_Heading FROM tempRawISO))*PI()/180);
    SET WVY = (SELECT True_Wind_Speed FROM tempRawISO) * SIN(((SELECT True_Wind_Direction FROM tempRawISO) - (SELECT Ship_Heading FROM tempRawISO))*PI()/180);
    */
    UPDATE `inservice`.tempRawISO SET Relative_Wind_Speed_Reference = SQRT(POWER(True_Wind_Speed_Reference * COS((True_Wind_Direction - Ship_Heading) * PI()/180) + Speed_Over_Ground, 2) + POWER(True_Wind_Speed_Reference * SIN((True_Wind_Direction - Ship_Heading) * PI()/180), 2));
    /*UPDATE `inservice`.tempRawISO SET Relative_Wind_Direction_Reference = 
    MOD(
		ATAN2(
				True_Wind_Speed_Reference * COS((True_Wind_Direction - Ship_Heading) * PI()/180), True_Wind_Speed_Reference * SIN((True_Wind_Direction - Ship_Heading) * PI()/180) + Speed_Over_Ground
			  )
		+ 2*PI(),
			2*PI()
				)*180/PI()
        ;
        */
    UPDATE `inservice`.tempRawISO SET Relative_Wind_Direction_Reference = 
        ATAN(
			(True_Wind_Speed_Reference*SIN((True_Wind_Direction - Ship_Heading) * PI()/180)) / (Speed_Over_Ground + True_Wind_Speed_Reference*COS((True_Wind_Direction - Ship_Heading) * PI()/180))
            ) * 180/PI();
    UPDATE `inservice`.tempRawISO SET Relative_Wind_Direction_Reference = Relative_Wind_Direction_Reference + 180 
		WHERE Speed_Over_Ground + True_Wind_Speed_Reference*COS((True_Wind_Direction - Ship_Heading) * PI()/180) < 0;
    
    
	/* Set Direction in range 0 to 360 degrees */
    /*UPDATE `inservice`.tempRawISO SET Relative_Wind_Direction_Reference = CASE
		WHEN Relative_Wind_Direction_Reference >= 0 THEN MOD(Relative_Wind_Direction_Reference, 360)
		WHEN Relative_Wind_Direction_Reference < 0 THEN 360 + MOD(Relative_Wind_Direction_Reference, 360)
	END;*/
        
	/* Relative wind at reference height */
    /* 
    UPDATE tempRawISO SET Relative_Wind_Speed_Reference = SQRT(POWER(True_Wind_Speed_Reference, 2) + POWER(Speed_Over_Ground, 2) +
		2*True_Wind_Speed_Reference*Speed_Over_Ground*COS(RADIANS(True_Wind_Direction) + RADIANS(Ship_Heading)) );
	
    UPDATE tempRawISO SET Relative_Wind_Direction_Reference = DEGREES(ATAN( (True_Wind_Speed_Reference*SIN(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) / 
		(Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) ))
        WHERE (Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) >= 0;
    
    UPDATE tempRawISO SET Relative_Wind_Direction_Reference = DEGREES(ATAN( (True_Wind_Speed_Reference*SIN(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) / 
		(Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) )) + 180
        WHERE (Speed_Over_Ground + True_Wind_Speed_Reference*COS(RADIANS(True_Wind_Direction) - RADIANS(Ship_Heading))) < 0;
        
	/* Set Direction in range 0 to 360 degrees */
    /* 
    UPDATE tempRawISO SET Relative_Wind_Direction_Reference = CASE
		WHEN Relative_Wind_Direction_Reference >= 0 THEN MOD(Relative_Wind_Direction_Reference, 360)
		WHEN Relative_Wind_Direction_Reference < 0 THEN 360 + MOD(Relative_Wind_Direction_Reference, 360)
	END;
    */
END;