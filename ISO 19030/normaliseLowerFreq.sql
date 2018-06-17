/* Repeat low-frequency data to a higher frequency */
/* Assumptions: */
/* 1.  */


DROP PROCEDURE IF EXISTS normaliseLowerFreq;

delimiter //

CREATE PROCEDURE normaliseLowerFreq()

BEGIN
	
    DECLARE timeStep DOUBLE(20, 3);
    
    /* Check for higher-frequency secondary parameters */
    
    /* Get primary parameter timestep */
    
    /* Average all secondary parameters to this value */
    UPDATE `inservice`.tempRawISO AS t1
		INNER JOIN
			(SELECT id, Timestamp, Vessel_Id, Vessel_Configuration_Id, Raw_Data_Id, Speed_Over_Ground, @lastb := IFNULL(Relative_Wind_Speed, @lastb) AS Relative_Wind_Speed, @lastc := IFNULL(Relative_Wind_Direction, @lastc) AS Relative_Wind_Direction, @laste := IFNULL(Ship_Heading, @laste) AS Ship_Heading, @lastf := IFNULL(Shaft_Revolutions, @lastf) AS Shaft_Revolutions, @lastg := IFNULL(Static_Draught_Fore, @lastg) AS Static_Draught_Fore, @lasth := IFNULL(Static_Draught_Aft, @lasth) AS Static_Draught_Aft, @lasti := IFNULL(Water_Depth, @lasti) AS Water_Depth, @lastj := IFNULL(Rudder_Angle, @lastj) AS Rudder_Angle, @lastk := IFNULL(Seawater_Temperature, @lastk) AS Seawater_Temperature, @lastl := IFNULL(Air_Temperature, @lastl) AS Air_Temperature, @lastm := IFNULL(Air_Pressure, @lastm) AS Air_Pressure, @lastn := IFNULL(Air_Density, @lastn) AS Air_Density, @lasto := IFNULL(Speed_Through_Water, @lasto) AS Speed_Through_Water, @lastq := IFNULL(Shaft_Power, @lastq) AS Shaft_Power, @lastr := IFNULL(Brake_Power, @lastr) AS Brake_Power, @lasts := IFNULL(Shaft_Torque, @lasts) AS Shaft_Torque, @lastt := IFNULL(Mass_Consumed_Fuel_Oil, @lastt) AS Mass_Consumed_Fuel_Oil, @lastu := IFNULL(Volume_Consumed_Fuel_Oil, @lastu) AS Volume_Consumed_Fuel_Oil, @lastdd := IFNULL(Displacement, @lastdd) AS Displacement
				FROM (SELECT id, Timestamp, Vessel_Id, Vessel_Configuration_Id, Raw_Data_Id, Speed_Over_Ground, Relative_Wind_Speed, Relative_Wind_Direction, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement FROM tempRawISO) AS q
					CROSS JOIN (SELECT @lastb := NULL) AS var_b  
					CROSS JOIN (SELECT @lastc := NULL) AS var_c  
					CROSS JOIN (SELECT @lastd := NULL) AS var_d  
					CROSS JOIN (SELECT @laste := NULL) AS var_e  
					CROSS JOIN (SELECT @lastf := NULL) AS var_f  
					CROSS JOIN (SELECT @lastg := NULL) AS var_g  
					CROSS JOIN (SELECT @lasth := NULL) AS var_h  
					CROSS JOIN (SELECT @lasti := NULL) AS var_i  
					CROSS JOIN (SELECT @lastj := NULL) AS var_j  
					CROSS JOIN (SELECT @lastk := NULL) AS var_k  
					CROSS JOIN (SELECT @lastl := NULL) AS var_l  
					CROSS JOIN (SELECT @lastm := NULL) AS var_m  
					CROSS JOIN (SELECT @lastn := NULL) AS var_n  
					CROSS JOIN (SELECT @lasto := NULL) AS var_o  
					CROSS JOIN (SELECT @lastq := NULL) AS var_q  
					CROSS JOIN (SELECT @lastr := NULL) AS var_r  
					CROSS JOIN (SELECT @lasts := NULL) AS var_s  
					CROSS JOIN (SELECT @lastt := NULL) AS var_t  
					CROSS JOIN (SELECT @lastu := NULL) AS var_u  
					CROSS JOIN (SELECT @lastv := NULL) AS var_v  
					CROSS JOIN (SELECT @lastw := NULL) AS var_w  
					CROSS JOIN (SELECT @lastx := NULL) AS var_x  
					CROSS JOIN (SELECT @lasty := NULL) AS var_y  
					CROSS JOIN (SELECT @lastz := NULL) AS var_z  
					CROSS JOIN (SELECT @lastaa := NULL) AS var_aa
					CROSS JOIN (SELECT @lastbb := NULL) AS var_bb
					CROSS JOIN (SELECT @lastcc := NULL) AS var_cc
					CROSS JOIN (SELECT @lastdd := NULL) AS var_dd
					CROSS JOIN (SELECT @lastee := NULL) AS var_ee
					CROSS JOIN (SELECT @lastff := NULL) AS var_ff
					CROSS JOIN (SELECT @lastgg := NULL) AS var_gg
					CROSS JOIN (SELECT @lasthh := NULL) AS var_hh
					CROSS JOIN (SELECT @lastii := NULL) AS var_ii
					CROSS JOIN (SELECT @lastjj := NULL) AS var_jj
					CROSS JOIN (SELECT @lastkk := NULL) AS var_kk
					CROSS JOIN (SELECT @lastll := NULL) AS var_ll
					CROSS JOIN (SELECT @lastmm := NULL) AS var_mm
					CROSS JOIN (SELECT @lastnn := NULL) AS var_nn
					CROSS JOIN (SELECT @lastoo := NULL) AS var_oo) AS t2
				ON t1.id = t2.id
					SET t1.Relative_Wind_Speed = t2.Relative_Wind_Speed,
						t1.Relative_Wind_Direction = t2.Relative_Wind_Direction,
						t1.Speed_Over_Ground = t2.Speed_Over_Ground,
						t1.Ship_Heading = t2.Ship_Heading,
						t1.Shaft_Revolutions = t2.Shaft_Revolutions,
						t1.Static_Draught_Fore = t2.Static_Draught_Fore,
						t1.Static_Draught_Aft = t2.Static_Draught_Aft,
						t1.Water_Depth = t2.Water_Depth,
						t1.Rudder_Angle = t2.Rudder_Angle,
						t1.Seawater_Temperature = t2.Seawater_Temperature,
						t1.Air_Temperature = t2.Air_Temperature,
						t1.Air_Pressure = t2.Air_Pressure,
						t1.Air_Density = t2.Air_Density,
						t1.Speed_Through_Water = t2.Speed_Through_Water,
						t1.Shaft_Power = t2.Shaft_Power,
						t1.Brake_Power = t2.Brake_Power,
						t1.Shaft_Torque = t2.Shaft_Torque,
						t1.Mass_Consumed_Fuel_Oil = t2.Mass_Consumed_Fuel_Oil,
						t1.Volume_Consumed_Fuel_Oil = t2.Volume_Consumed_Fuel_Oil,
						t1.Displacement = t2.Displacement
						;
    
    /* UPDATE tempRawISO AS t1
	SET 
		Relative_Wind_Speed = Relative_Wind_Speed
	FROM
		tempRawISO AS t1
        INNER JOIN 
			(SELECT IMO_Vessel_Number, Timestamp, Speed_Over_Ground, @lastb := IFNULL(Relative_Wind_Speed, @lastb) AS Relative_Wind_Speed, @lastc := IFNULL(Relative_Wind_Direction, @lastc) AS Relative_Wind_Direction, @laste := IFNULL(Ship_Heading, @laste) AS Ship_Heading, @lastf := IFNULL(Shaft_Revolutions, @lastf) AS Shaft_Revolutions, @lastg := IFNULL(Static_Draught_Fore, @lastg) AS Static_Draught_Fore, @lasth := IFNULL(Static_Draught_Aft, @lasth) AS Static_Draught_Aft, @lasti := IFNULL(Water_Depth, @lasti) AS Water_Depth, @lastj := IFNULL(Rudder_Angle, @lastj) AS Rudder_Angle, @lastk := IFNULL(Seawater_Temperature, @lastk) AS Seawater_Temperature, @lastl := IFNULL(Air_Temperature, @lastl) AS Air_Temperature, @lastm := IFNULL(Air_Pressure, @lastm) AS Air_Pressure, @lastn := IFNULL(Air_Density, @lastn) AS Air_Density, @lasto := IFNULL(Speed_Through_Water, @lasto) AS Speed_Through_Water, @lastp := IFNULL(Delivered_Power, @lastp) AS Delivered_Power, @lastq := IFNULL(Shaft_Power, @lastq) AS Shaft_Power, @lastr := IFNULL(Brake_Power, @lastr) AS Brake_Power, @lasts := IFNULL(Shaft_Torque, @lasts) AS Shaft_Torque, @lastt := IFNULL(Mass_Consumed_Fuel_Oil, @lastt) AS Mass_Consumed_Fuel_Oil, @lastu := IFNULL(Volume_Consumed_Fuel_Oil, @lastu) AS Volume_Consumed_Fuel_Oil, @lastv := IFNULL(Lower_Caloirifc_Value_Fuel_Oil, @lastv) AS Lower_Caloirifc_Value_Fuel_Oil, @lastw := IFNULL(Normalised_Energy_Consumption, @lastw) AS Normalised_Energy_Consumption, @lastx := IFNULL(Density_Fuel_Oil_15C, @lastx) AS Density_Fuel_Oil_15C, @lasty := IFNULL(Density_Change_Rate_Per_C, @lasty) AS Density_Change_Rate_Per_C, @lastz := IFNULL(Temp_Fuel_Oil_At_Flow_Meter, @lastz) AS Temp_Fuel_Oil_At_Flow_Meter, @lastaa := IFNULL(Wind_Resistance_Relative, @lastaa) AS Wind_Resistance_Relative, @lastbb := IFNULL(Air_Resistance_No_Wind, @lastbb) AS Air_Resistance_No_Wind, @lastcc := IFNULL(Expected_Speed_Through_Water, @lastcc) AS Expected_Speed_Through_Water, @lastdd := IFNULL(Displacement, @lastdd) AS Displacement, @lastee := IFNULL(Speed_Loss, @lastee) AS Speed_Loss, @lastff := IFNULL(Transverse_Projected_Area_Current, @lastff) AS Transverse_Projected_Area_Current, @lastgg := IFNULL(Wind_Resistance_Correction, @lastgg) AS Wind_Resistance_Correction, @lasthh := IFNULL(Corrected_Power, @lasthh) AS Corrected_Power, @lastii := IFNULL(Filter_SpeedPower_Disp_Trim, @lastii) AS Filter_SpeedPower_Disp_Trim, @lastjj := IFNULL(Filter_SpeedPower_Trim, @lastjj) AS Filter_SpeedPower_Trim, @lastkk := IFNULL(Filter_SpeedPower_Disp, @lastkk) AS Filter_SpeedPower_Disp, @lastll := IFNULL(Filter_SpeedPower_Below, @lastll) AS Filter_SpeedPower_Below, @lastmm := IFNULL(NearestDisplacement, @lastmm) AS NearestDisplacement, @lastnn := IFNULL(NearestTrim, @lastnn) AS NearestTrim, @lastoo := IFNULL(Trim, @lastoo) AS Trim
				FROM (SELECT IMO_Vessel_Number, Timestamp, Speed_Over_Ground, Relative_Wind_Speed, Relative_Wind_Direction, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Lower_Caloirifc_Value_Fuel_Oil, Normalised_Energy_Consumption, Density_Fuel_Oil_15C, Density_Change_Rate_Per_C, Temp_Fuel_Oil_At_Flow_Meter, Wind_Resistance_Relative, Air_Resistance_No_Wind, Expected_Speed_Through_Water, Displacement, Speed_Loss, Transverse_Projected_Area_Current, Wind_Resistance_Correction, Corrected_Power, Filter_SpeedPower_Disp_Trim, Filter_SpeedPower_Trim, Filter_SpeedPower_Disp, Filter_SpeedPower_Below, NearestDisplacement, NearestTrim, Trim FROM tempRawISO) AS q
					CROSS JOIN (SELECT @lastb := NULL) AS var_b  
					CROSS JOIN (SELECT @lastc := NULL) AS var_c  
					CROSS JOIN (SELECT @lastd := NULL) AS var_d  
					CROSS JOIN (SELECT @laste := NULL) AS var_e  
					CROSS JOIN (SELECT @lastf := NULL) AS var_f  
					CROSS JOIN (SELECT @lastg := NULL) AS var_g  
					CROSS JOIN (SELECT @lasth := NULL) AS var_h  
					CROSS JOIN (SELECT @lasti := NULL) AS var_i  
					CROSS JOIN (SELECT @lastj := NULL) AS var_j  
					CROSS JOIN (SELECT @lastk := NULL) AS var_k  
					CROSS JOIN (SELECT @lastl := NULL) AS var_l  
					CROSS JOIN (SELECT @lastm := NULL) AS var_m  
					CROSS JOIN (SELECT @lastn := NULL) AS var_n  
					CROSS JOIN (SELECT @lasto := NULL) AS var_o  
					CROSS JOIN (SELECT @lastp := NULL) AS var_p  
					CROSS JOIN (SELECT @lastq := NULL) AS var_q  
					CROSS JOIN (SELECT @lastr := NULL) AS var_r  
					CROSS JOIN (SELECT @lasts := NULL) AS var_s  
					CROSS JOIN (SELECT @lastt := NULL) AS var_t  
					CROSS JOIN (SELECT @lastu := NULL) AS var_u  
					CROSS JOIN (SELECT @lastv := NULL) AS var_v  
					CROSS JOIN (SELECT @lastw := NULL) AS var_w  
					CROSS JOIN (SELECT @lastx := NULL) AS var_x  
					CROSS JOIN (SELECT @lasty := NULL) AS var_y  
					CROSS JOIN (SELECT @lastz := NULL) AS var_z  
					CROSS JOIN (SELECT @lastaa := NULL) AS var_aa
					CROSS JOIN (SELECT @lastbb := NULL) AS var_bb
					CROSS JOIN (SELECT @lastcc := NULL) AS var_cc
					CROSS JOIN (SELECT @lastdd := NULL) AS var_dd
					CROSS JOIN (SELECT @lastee := NULL) AS var_ee
					CROSS JOIN (SELECT @lastff := NULL) AS var_ff
					CROSS JOIN (SELECT @lastgg := NULL) AS var_gg
					CROSS JOIN (SELECT @lasthh := NULL) AS var_hh
					CROSS JOIN (SELECT @lastii := NULL) AS var_ii
					CROSS JOIN (SELECT @lastjj := NULL) AS var_jj
					CROSS JOIN (SELECT @lastkk := NULL) AS var_kk
					CROSS JOIN (SELECT @lastll := NULL) AS var_ll
					CROSS JOIN (SELECT @lastmm := NULL) AS var_mm
					CROSS JOIN (SELECT @lastnn := NULL) AS var_nn
					CROSS JOIN (SELECT @lastoo := NULL) AS var_oo) AS t2
          ON t1.id = t2.id;
 */
END;