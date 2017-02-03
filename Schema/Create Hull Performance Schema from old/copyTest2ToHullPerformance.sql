CREATE SCHEMA hull_performance;

create table hull_performance.bunkerdeliverynote like test2.bunkerdeliverynote;            
create table hull_performance.chauvenettempfilter like test2.chauvenettempfilter;          
create table hull_performance.dnvglraw like test2.dnvglraw;                                
create table hull_performance.drydockdates like test2.drydockdates;                        
create table hull_performance.globalconstants like test2.globalconstants;                  
create table hull_performance.logt like test2.logt;                                        
create table hull_performance.performancedata like test2.performancedata;                  
create table hull_performance.performancedatadnvgl like test2.performancedatadnvgl;        
create table hull_performance.rawdata like test2.rawdata;                                  
create table hull_performance.sfoccoefficients like test2.sfoccoefficients;                
create table hull_performance.ships like test2.ships;                                      
create table hull_performance.speedpower like test2.speedpower;                            
create table hull_performance.speedpowercoefficients like test2.speedpowercoefficients;    
create table hull_performance.standardcompliance like test2.standardcompliance;            
create table hull_performance.tempbunkerdeliverynote like test2.tempbunkerdeliverynote;    
create table hull_performance.vesselcoating like test2.vesselcoating;                      
create table hull_performance.vessels like test2.vessels;                                  
create table hull_performance.windcoefficientdirection like test2.windcoefficientdirection;

INSERT INTO hull_performance.bunkerdeliverynote SELECT * FROM test2.bunkerdeliverynote;            
INSERT INTO hull_performance.chauvenettempfilter SELECT * FROM test2.chauvenettempfilter;          
INSERT INTO hull_performance.dnvglraw SELECT * FROM test2.dnvglraw;                                
INSERT INTO hull_performance.drydockdates SELECT * FROM test2.drydockdates;                        
INSERT INTO hull_performance.globalconstants SELECT * FROM test2.globalconstants;                  
INSERT INTO hull_performance.logt SELECT * FROM test2.logt;                                        
INSERT INTO hull_performance.performancedata SELECT * FROM test2.performancedata;                  
INSERT INTO hull_performance.performancedatadnvgl SELECT * FROM test2.performancedatadnvgl;        
INSERT INTO hull_performance.rawdata SELECT * FROM test2.rawdata;                                  
INSERT INTO hull_performance.sfoccoefficients SELECT * FROM test2.sfoccoefficients;                
INSERT INTO hull_performance.ships SELECT * FROM test2.ships;                                      
INSERT INTO hull_performance.speedpower SELECT * FROM test2.speedpower;                            
INSERT INTO hull_performance.speedpowercoefficients SELECT * FROM test2.speedpowercoefficients;    
INSERT INTO hull_performance.standardcompliance SELECT * FROM test2.standardcompliance;            
INSERT INTO hull_performance.tempbunkerdeliverynote SELECT * FROM test2.tempbunkerdeliverynote;    
INSERT INTO hull_performance.vesselcoating SELECT * FROM test2.vesselcoating;                      
INSERT INTO hull_performance.vessels SELECT * FROM test2.vessels;                                  
INSERT INTO hull_performance.windcoefficientdirection SELECT * FROM test2.windcoefficientdirection;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`convertDNVGLRawToRawData`()
BEGIN
	
    /* Input */
    DECLARE knots2SI DOUBLE(10, 10);
    DECLARE Fluid_Density INT(4);
    
    SET knots2SI := 0.5144444444;
    SET Fluid_Density := 1025;
    
    /* Add columns matching those in rawdata table, update values appropriately */
    UPDATE tempRaw SET Relative_Wind_Speed = Wind_Force_Kn * knots2SI;           /* Assume wind recorded is relative to ship's frame of reference */
    
    UPDATE tempRaw SET Relative_Wind_Direction = Wind_Dir;           /* Assume ship forward direction is 0, clockwise positive*/
	
    UPDATE tempRaw SET Speed_Over_Ground = Speed_GPS;           /* Assume wind recorded is relative to ship's frame of reference */
    
    /* Ship heading not found in DNVGL raw files. Data required by ISO only for calculation of true wind speed and direction, not used in performance analysis.
	ALTER TABLE tempRaw ADD Ship_Heading DOUBLE (10, 5);
    UPDATE tempRaw SET Ship_Heading = NULL;           /* Assume wind recorded is relative to ship's frame of reference */
	
    UPDATE tempRaw SET Shaft_Revolutions = ME_1_Speed_RPM;           /* Assume one main engine */
    
    UPDATE tempRaw SET Static_Draught_Fore = Draft_Actual_Fore;
    
    UPDATE tempRaw SET Static_Draught_Aft = Draft_Actual_Aft;
    
    /* Skip water depth, name and meaning equivalent
	ALTER TABLE tempRaw ADD Water_Depth DOUBLE(10, 5);
    UPDATE tempRaw SET Water_Depth = Water_Depth;            */
    
    /* Rudder Angle not found in DNVGL raw files. Data required by ISO only for calculation of true wind speed and direction, not used in performance analysis.
	ALTER TABLE tempRaw ADD Rudder_Angle DOUBLE (10, 5);
    UPDATE tempRaw SET Rudder_Angle = NULL;           /* Assume wind recorded is relative to ship's frame of reference */
    
    UPDATE tempRaw SET Seawater_Temperature = Temperature_Water;
    
    UPDATE tempRaw SET Air_Temperature = Temperature_Ambient;
    
    UPDATE tempRaw SET Air_Pressure = ME_Barometric_Pressure;           /* Assumes that ship has only one engine, and that air intake pressure is a sufficient approximation for atmospheric pressure.*/
    
    /* Air density is a derived value */
    
    /* Speed through water
    ALTER TABLE tempRaw ADD Speed_Through_Water DOUBLE(10, 5);
    UPDATE tempRaw SET Speed_Through_Water = Speed_Through_Water;         */
    
    /* Delivered Power is a derived value. It could be read from input after further code development. */
    
    /* Shaft Power is a derived value. It could be optionally read from input after further code development. */
    
    /* Brake Power is a derived value. */
    
    /* Shaft Torque not found in DNVGL raw files. Procedure `updateShaftPower` not compatible with this input file type. */
    
    UPDATE tempRaw SET Mass_Consumed_Fuel_Oil = ME_Consumption * 1e3;           /* Assume only one engine. */
    
    /* Volume of consumed fuel oil not found in DNVGL raw files. Procedure `updateMassFuelOilConsumed` not compatible with this input file type. */
    
    /* LCV is a bunker report variable. It can be read from bunker delivery note table. */
    /* CALL updateFromBunkerNote; */
    
    /* Normalied Energy Consumed is a derived variable */
    
    /* Density_Fuel_Oil_15C is a bunker report variable and will have been updated with previous call to updateFromBunkerNote */
    
    /* Density_Change_Rate_Per_C not found in DNVGL raw files. This may be obtained from another source. */
    
    /* Temp_Fuel_Oil_At_Flow_Meter not found in DNVGL raw files. Procedure `updateMassFuelOilConsumed' not compatible with this input file type. */
    
    /* Wind_Resistance_Relative not found in DNVGL raw files. This may be obtained from another source. */
    
    /* Air_Resistance_No_Wind not found in DNVGL raw files. This may be obtained from another source. */
    
    /* Expected_Speed_Through_Water is a derived variable. */
    
    /* Displacement is a derived variable. It could be optionally read from input after further code development.
	ALTER TABLE tempRaw ADD Displacement DOUBLE(20, 10);
    UPDATE tempRaw SET Displacement = Draft_Displacement_Actual / Fluid_Density;           /* Assume units of displacement in analysis are tonnes. */
    
    /* Speed_Loss is a derived variable. */
    
    /* Transverse_Projected_Area_Current not found in DNVGL raw files. This may be obtained from another source.  */
    
    /* Wind_Resistance_Correction is a derived variable. */
    
    /* Corrected_Power is a derived variable. */
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`createBunkerDeliveryNote`()
BEGIN

CREATE TABLE BunkerDeliveryNote (id INT PRIMARY KEY AUTO_INCREMENT,
								IMO_Vessel_Number INT,
								BDN_Number VARCHAR(100),
								Bunker_Delivery_Date DATE,
								Fuel_Type VARCHAR(100),
								Mass DOUBLE(10, 3),
								Sulphur_Content DOUBLE(2, 1),
								Density_At_15dg DOUBLE(5, 4),
								Lower_Heating_Value DOUBLE(5, 3));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`createDNVGLRawTempTable`()
BEGIN

CREATE TABLE tempDNVGLRaw (
id INTEGER AUTO_INCREMENT PRIMARY KEY,
AE_1_Running_Hours	DOUBLE(20, 5),
AE_2_Running_Hours	DOUBLE(20, 5), 
Date_Local	DOUBLE(20, 5), 
AE_3_Running_Hours	DOUBLE(20, 5), 
Time_Local	DOUBLE(20, 5), 
Voyage_From	DOUBLE(20, 5), 
Voyage_To	DOUBLE(20, 5), 
Voyage_Number	DOUBLE(20, 5), 
AE_Consumption	DOUBLE(20, 5), 
Boiler_Consumption	DOUBLE(20, 5), 
Latitude_North_South	CHAR(1), 
Cargo_Mt	DOUBLE(20, 5), 
Current_Dir	INT, 
Longitude_East_West	CHAR(1), 
Current_Speed	DOUBLE(20, 5), 
Date_UTC	DATE, 
Distance	DOUBLE(20, 5), 
Sea_state_Dir	DOUBLE(20, 5), 
Sea_state_Force_Douglas	DOUBLE(20, 5), 
Draft_Actual_Aft	DOUBLE(20, 5), 
Draft_Actual_Fore	DOUBLE(20, 5), 
Draft_Displacement_Actual	DOUBLE(20, 5), 
IMO_Vessel_Number	INT, 
Temperature_Ambient	DOUBLE(20, 5), 
Latitude_Degree	INT, 
Latitude_Minutes	INT, 
Longitude_Degree	INT, 
Draft_Recommended_Fore	DOUBLE(20, 5), 
Draft_Recommended_Aft	DOUBLE(20, 5), 
Draft_Ballast_Actual	DOUBLE(20, 5), 
Draft_Ballast_Optimum	DOUBLE(20, 5), 
Longitude_Minutes	INT, 
ME_Fuel_BDN	VARCHAR(100), 
AE_Fuel_BDN	VARCHAR(100), 
Event	VARCHAR(4), 
ME_1_Load	DOUBLE(20, 5), 
ME_1_Running_Hours	DOUBLE(20, 5), 
Time_Elapsed_Maneuvering	DOUBLE(20, 5), 
Time_Elapsed_Waiting	DOUBLE(20, 5), 
ME_1_Scav_Air_Pressure	DOUBLE(20, 5), 
ME_1_Speed_RPM	DOUBLE(20, 5), 
ME_Consumption	DOUBLE(20, 5), 
Apparent_Slip	DOUBLE(20, 5), 
Nominal_Slip	DOUBLE(20, 5), 
Cargo_Total_TEU	DOUBLE(20, 5), 
Cargo_Total_Full_TEU	DOUBLE(20, 5), 
Cargo_Reefer_TEU	DOUBLE(20, 5), 
Cargo_CEU	DOUBLE(20, 5), 
Crew	DOUBLE(20, 5), 
Passengers	DOUBLE(20, 5), 
People	DOUBLE(20, 5), 
ME_Projected_Consumption	DOUBLE(20, 5), 
Speed_GPS	DOUBLE(20, 5), 
ME_Cylinder_Oil_Consumption	DOUBLE(20, 5), 
ME_System_Oil_Consumption	DOUBLE(20, 5), 
Speed_Through_Water	DOUBLE(20, 5), 
ME_1_Consumption	DOUBLE(20, 5), 
ME_1_Cylinder_Oil_Consumption	DOUBLE(20, 5), 
ME_1_System_Oil_Consumption	DOUBLE(20, 5), 
ME_1_Work	DOUBLE(20, 5), 
ME_1_Shaft_Power	DOUBLE(20, 5), 
ME_1_Shaft_Gen_Running_Hours	DOUBLE(20, 5), 
ME_2_Running_Hours	DOUBLE(20, 5), 
ME_2_Consumption	DOUBLE(20, 5), 
ME_2_Cylinder_Oil_Consumption	DOUBLE(20, 5), 
ME_2_System_Oil_Consumption	DOUBLE(20, 5), 
ME_2_Work	DOUBLE(20, 5), 
ME_2_Shaft_Power	DOUBLE(20, 5), 
ME_2_Shaft_Gen_Running_Hours	DOUBLE(20, 5), 
AE_Projected_Consumption	DOUBLE(20, 5), 
Swell_Dir	DOUBLE(20, 5), 
Swell_Force	DOUBLE(20, 5), 
AE_1_Consumption	DOUBLE(20, 5), 
AE_1_Work	DOUBLE(20, 5), 
Temperature_Water	DOUBLE(20, 5), 
AE_2_Consumption	DOUBLE(20, 5), 
AE_2_Work	DOUBLE(20, 5), 
Time_Elapsed_Loading_Unloading	DOUBLE(20, 5), 
AE_3_Consumption	DOUBLE(20, 5), 
AE_3_Work	DOUBLE(20, 5), 
AE_4_Running_Hours	DOUBLE(20, 5), 
AE_4_Consumption	DOUBLE(20, 5), 
AE_4_Work	DOUBLE(20, 5), 
AE_5_Running_Hours	DOUBLE(20, 5), 
AE_5_Consumption	DOUBLE(20, 5), 
AE_5_Work	DOUBLE(20, 5), 
AE_6_Running_Hours	DOUBLE(20, 5), 
AE_6_Consumption	DOUBLE(20, 5), 
AE_6_Work	DOUBLE(20, 5), 
Time_Elapsed_Sailing	DOUBLE(20, 5), 
Boiler_1_Running_Hours	DOUBLE(20, 5), 
Boiler_1_Consumption	DOUBLE(20, 5), 
Boiler_2_Running_Hours	DOUBLE(20, 5), 
Boiler_2_Consumption	DOUBLE(20, 5), 
Air_Compr_1_Running_Time	DOUBLE(20, 5), 
Air_Compr_2_Running_Time	DOUBLE(20, 5), 
Thruster_1_Running_Time	DOUBLE(20, 5), 
Thruster_2_Running_Time	DOUBLE(20, 5), 
Thruster_3_Running_Time	DOUBLE(20, 5), 
Lube_Oil_System_Type_Of_Pump_In_Service	DOUBLE(20, 5), 
Cleaning_Event	DOUBLE(20, 5), 
Mode	DOUBLE(20, 5), 
Time_Since_Previous_Report	DOUBLE(20, 5), 
Time_UTC	TIME, 
Speed_Projected_From_Charter_Party	DOUBLE(20, 5), 
Water_Depth	DOUBLE(20, 5), 
ME_Barometric_Pressure	DOUBLE(20, 5), 
ME_Charge_Air_Coolant_Inlet_Temp	DOUBLE(20, 5), 
ME_Air_Intake_Temp	DOUBLE(20, 5), 
Wind_Dir	INT, 
Wind_Force_Bft	INT, 
Prop_1_Pitch	DOUBLE(20, 5), 
ME_1_Aux_Blower	DOUBLE(20, 5), 
ME_1_Shaft_Gen_Power	DOUBLE(20, 5), 
ME_1_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
Wind_Force_Kn	DOUBLE(20, 5), 
ME_1_Pressure_Drop_Over_Scav_Air_Cooler	DOUBLE(20, 5), 
ME_1_TC_Speed	DOUBLE(20, 5), 
ME_1_Exh_Temp_Before_TC	DOUBLE(20, 5), 
ME_1_Exh_Temp_After_TC	DOUBLE(20, 5), 
ME_1_Current_Consumption	DOUBLE(20, 5), 
ME_1_SFOC_ISO_Corrected	DOUBLE(20, 5), 
ME_1_SFOC	DOUBLE(20, 5), 
ME_1_Pmax	DOUBLE(20, 5), 
ME_1_Pcomp	DOUBLE(20, 5), 
ME_2_Load	DOUBLE(20, 5), 
ME_2_Speed_RPM	DOUBLE(20, 5), 
Prop_2_Pitch	DOUBLE(20, 5), 
ME_2_Aux_Blower	DOUBLE(20, 5), 
ME_2_Shaft_Gen_Power	DOUBLE(20, 5), 
ME_2_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
ME_2_Scav_Air_Pressure	DOUBLE(20, 5), 
ME_2_Pressure_Drop_Over_Scav_Air_Cooler	DOUBLE(20, 5), 
ME_2_TC_Speed	DOUBLE(20, 5), 
ME_2_Exh_Temp_Before_TC	DOUBLE(20, 5), 
ME_2_Exh_Temp_After_TC	DOUBLE(20, 5), 
ME_2_Current_Consumption	DOUBLE(20, 5), 
ME_2_SFOC_ISO_Corrected	DOUBLE(20, 5), 
ME_2_SFOC	DOUBLE(20, 5), 
ME_2_Pmax	DOUBLE(20, 5), 
ME_2_Pcomp	DOUBLE(20, 5), 
AE_Barometric_Pressure	DOUBLE(20, 5), 
AE_Charge_Air_Coolant_Inlet_Temp	DOUBLE(20, 5), 
AE_Air_Intake_Temp	DOUBLE(20, 5), 
AE_1_Load	DOUBLE(20, 5), 
AE_1_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_1_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_1_TC_Speed	DOUBLE(20, 5), 
AE_1_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_1_Current_Consumption	DOUBLE(20, 5), 
AE_1_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_1_SFOC	DOUBLE(20, 5), 
AE_1_Pmax	DOUBLE(20, 5), 
AE_1_Pcomp	DOUBLE(20, 5), 
AE_2_Load	DOUBLE(20, 5), 
AE_2_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_2_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_2_TC_Speed	DOUBLE(20, 5), 
AE_2_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_2_Current_Consumption	DOUBLE(20, 5), 
AE_2_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_2_SFOC	DOUBLE(20, 5), 
AE_2_Pmax	DOUBLE(20, 5), 
AE_2_Pcomp	DOUBLE(20, 5), 
AE_3_Load	DOUBLE(20, 5), 
AE_3_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_3_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_3_TC_Speed	DOUBLE(20, 5), 
AE_3_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_3_Current_Consumption	DOUBLE(20, 5), 
AE_3_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_3_SFOC	DOUBLE(20, 5), 
AE_3_Pmax	DOUBLE(20, 5), 
AE_3_Pcomp	DOUBLE(20, 5), 
AE_4_Load	DOUBLE(20, 5), 
AE_4_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_4_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_4_TC_Speed	DOUBLE(20, 5), 
AE_4_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_4_Current_Consumption	DOUBLE(20, 5), 
AE_4_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_4_SFOC	DOUBLE(20, 5), 
AE_4_Pmax	DOUBLE(20, 5), 
AE_4_Pcomp	DOUBLE(20, 5), 
AE_5_Load	DOUBLE(20, 5), 
AE_5_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_5_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_5_TC_Speed	DOUBLE(20, 5), 
AE_5_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_5_Current_Consumption	DOUBLE(20, 5), 
AE_5_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_5_SFOC	DOUBLE(20, 5), 
AE_5_Pmax	DOUBLE(20, 5), 
AE_5_Pcomp	DOUBLE(20, 5), 
AE_6_Load	DOUBLE(20, 5), 
AE_6_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_6_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_6_TC_Speed	DOUBLE(20, 5), 
AE_6_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_6_Current_Consumption	DOUBLE(20, 5), 
AE_6_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_6_SFOC	DOUBLE(20, 5), 
AE_6_Pmax	DOUBLE(20, 5), 
AE_6_Pcomp	DOUBLE(20, 5), 
Boiler_1_Operation_Mode	DOUBLE(20, 5), 
Boiler_1_Feed_Water_Flow	DOUBLE(20, 5), 
Boiler_1_Steam_Pressure	DOUBLE(20, 5), 
Boiler_2_Operation_Mode	DOUBLE(20, 5), 
Boiler_2_Feed_Water_Flow	DOUBLE(20, 5), 
Boiler_2_Steam_Pressure	DOUBLE(20, 5), 
Cooling_Water_System_SW_Pumps_In_Service	DOUBLE(20, 5), 
Cooling_Water_System_SW_Inlet_Temp	DOUBLE(20, 5), 
Cooling_Water_System_SW_Outlet_Temp	DOUBLE(20, 5), 
Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger	DOUBLE(20, 5), 
Cooling_Water_System_Pump_Pressure	DOUBLE(20, 5), 
ER_Ventilation_Fans_In_Service	DOUBLE(20, 5), 
ER_Ventilation_Waste_Air_Temp	DOUBLE(20, 5), 
Remarks	DOUBLE(20, 5), 
Entry_Made_By_1	DOUBLE(20, 5), 
Entry_Made_By_2	DOUBLE(20, 5)
);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`createTempBunkerDeliveryNote`()
BEGIN

DROP TABLE IF EXISTS TempBunkerDeliveryNote;
	
CREATE TABLE TempBunkerDeliveryNote (id INT PRIMARY KEY AUTO_INCREMENT,
								IMO_Vessel_Number INT,
								BDN_Number VARCHAR(100),
								Bunker_Delivery_Date DATE,
								Fuel_Type VARCHAR(100),
								Mass DOUBLE(10, 3),
								Sulphur_Content DOUBLE(2, 1),
								Density_At_15dg DOUBLE(5, 4),
								Lower_Heating_Value DOUBLE(5, 3));
                                
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`createTempChauvenetFilter`()
BEGIN

DROP TABLE IF EXISTS ChauvenetTempFilter;

CREATE TABLE ChauvenetTempFilter (id INT PRIMARY KEY AUTO_INCREMENT, 
								Speed_Through_Water BOOLEAN, 
								Delivered_Power BOOLEAN, 
								Shaft_Revolutions BOOLEAN, 
								Relative_Wind_Speed BOOLEAN, 
								Relative_Wind_Direction BOOLEAN, 
								Speed_Over_Ground BOOLEAN, 
								Ship_Heading BOOLEAN, 
								Rudder_Angle BOOLEAN, 
								Water_Depth BOOLEAN, 
								Seawater_Temperature BOOLEAN);
                                
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`createTempRaw`(imo INT)
BEGIN

DROP TABLE IF EXISTS tempRaw;
/* CREATE TABLE tempRaw LIKE dnvglraw; */

CREATE TABLE tempRaw (
id INTEGER AUTO_INCREMENT PRIMARY KEY,
IMO_Vessel_Number	INT,
DateTime_UTC 		DATETIME,
CONSTRAINT UniqueIMODates UNIQUE(IMO_Vessel_Number, DateTime_UTC),
AE_1_Running_Hours	DOUBLE(20, 5),
AE_2_Running_Hours	DOUBLE(20, 5), 
Date_Local	DOUBLE(20, 5), 
AE_3_Running_Hours	DOUBLE(20, 5), 
Time_Local	DOUBLE(20, 5), 
Voyage_From	DOUBLE(20, 5), 
Voyage_To	DOUBLE(20, 5), 
Voyage_Number	DOUBLE(20, 5), 
AE_Consumption	DOUBLE(20, 5), 
Boiler_Consumption	DOUBLE(20, 5), 
Latitude_North_South	CHAR(1), 
Cargo_Mt	DOUBLE(20, 5), 
Current_Dir	INT, 
Longitude_East_West	CHAR(1), 
Current_Speed	DOUBLE(20, 5), 
Date_UTC	DATE, 
Distance	DOUBLE(20, 5), 
Sea_state_Dir	DOUBLE(20, 5), 
Sea_state_Force_Douglas	DOUBLE(20, 5), 
Draft_Actual_Aft	DOUBLE(20, 5), 
Draft_Actual_Fore	DOUBLE(20, 5), 
Draft_Displacement_Actual	DOUBLE(20, 5), 
Temperature_Ambient	DOUBLE(20, 5), 
Latitude_Degree	INT, 
Latitude_Minutes	INT, 
Longitude_Degree	INT, 
Draft_Recommended_Fore	DOUBLE(20, 5), 
Draft_Recommended_Aft	DOUBLE(20, 5), 
Draft_Ballast_Actual	DOUBLE(20, 5), 
Draft_Ballast_Optimum	DOUBLE(20, 5), 
Longitude_Minutes	INT, 
ME_Fuel_BDN	VARCHAR(100), 
AE_Fuel_BDN	VARCHAR(100), 
Event	VARCHAR(4), 
ME_1_Load	DOUBLE(20, 5), 
ME_1_Running_Hours	DOUBLE(20, 5), 
Time_Elapsed_Maneuvering	DOUBLE(20, 5), 
Time_Elapsed_Waiting	DOUBLE(20, 5), 
ME_1_Scav_Air_Pressure	DOUBLE(20, 5), 
ME_1_Speed_RPM	DOUBLE(20, 5), 
ME_Consumption	DOUBLE(20, 5), 
Apparent_Slip	DOUBLE(20, 5), 
Nominal_Slip	DOUBLE(20, 5), 
Cargo_Total_TEU	DOUBLE(20, 5), 
Cargo_Total_Full_TEU	DOUBLE(20, 5), 
Cargo_Reefer_TEU	DOUBLE(20, 5), 
Cargo_CEU	DOUBLE(20, 5), 
Crew	DOUBLE(20, 5), 
Passengers	DOUBLE(20, 5), 
People	DOUBLE(20, 5), 
ME_Projected_Consumption	DOUBLE(20, 5), 
Speed_GPS	DOUBLE(20, 5), 
ME_Cylinder_Oil_Consumption	DOUBLE(20, 5), 
ME_System_Oil_Consumption	DOUBLE(20, 5), 
Speed_Through_Water	DOUBLE(20, 5), 
ME_1_Consumption	DOUBLE(20, 5), 
ME_1_Cylinder_Oil_Consumption	DOUBLE(20, 5), 
ME_1_System_Oil_Consumption	DOUBLE(20, 5), 
ME_1_Work	DOUBLE(20, 5), 
ME_1_Shaft_Power	DOUBLE(20, 5), 
ME_1_Shaft_Gen_Running_Hours	DOUBLE(20, 5), 
ME_2_Running_Hours	DOUBLE(20, 5), 
ME_2_Consumption	DOUBLE(20, 5), 
ME_2_Cylinder_Oil_Consumption	DOUBLE(20, 5), 
ME_2_System_Oil_Consumption	DOUBLE(20, 5), 
ME_2_Work	DOUBLE(20, 5), 
ME_2_Shaft_Power	DOUBLE(20, 5), 
ME_2_Shaft_Gen_Running_Hours	DOUBLE(20, 5), 
AE_Projected_Consumption	DOUBLE(20, 5), 
Swell_Dir	DOUBLE(20, 5), 
Swell_Force	DOUBLE(20, 5), 
AE_1_Consumption	DOUBLE(20, 5), 
AE_1_Work	DOUBLE(20, 5), 
Temperature_Water	DOUBLE(20, 5), 
AE_2_Consumption	DOUBLE(20, 5), 
AE_2_Work	DOUBLE(20, 5), 
Time_Elapsed_Loading_Unloading	DOUBLE(20, 5), 
AE_3_Consumption	DOUBLE(20, 5), 
AE_3_Work	DOUBLE(20, 5), 
AE_4_Running_Hours	DOUBLE(20, 5), 
AE_4_Consumption	DOUBLE(20, 5), 
AE_4_Work	DOUBLE(20, 5), 
AE_5_Running_Hours	DOUBLE(20, 5), 
AE_5_Consumption	DOUBLE(20, 5), 
AE_5_Work	DOUBLE(20, 5), 
AE_6_Running_Hours	DOUBLE(20, 5), 
AE_6_Consumption	DOUBLE(20, 5), 
AE_6_Work	DOUBLE(20, 5), 
Time_Elapsed_Sailing	DOUBLE(20, 5), 
Boiler_1_Running_Hours	DOUBLE(20, 5), 
Boiler_1_Consumption	DOUBLE(20, 5), 
Boiler_2_Running_Hours	DOUBLE(20, 5), 
Boiler_2_Consumption	DOUBLE(20, 5), 
Air_Compr_1_Running_Time	DOUBLE(20, 5), 
Air_Compr_2_Running_Time	DOUBLE(20, 5), 
Thruster_1_Running_Time	DOUBLE(20, 5), 
Thruster_2_Running_Time	DOUBLE(20, 5), 
Thruster_3_Running_Time	DOUBLE(20, 5), 
Lube_Oil_System_Type_Of_Pump_In_Service	DOUBLE(20, 5), 
Cleaning_Event	DOUBLE(20, 5), 
Mode	DOUBLE(20, 5), 
Time_Since_Previous_Report	DOUBLE(20, 5), 
Time_UTC	TIME, 
Speed_Projected_From_Charter_Party	DOUBLE(20, 5), 
Water_Depth	DOUBLE(20, 5), 
ME_Barometric_Pressure	DOUBLE(20, 5), 
ME_Charge_Air_Coolant_Inlet_Temp	DOUBLE(20, 5), 
ME_Air_Intake_Temp	DOUBLE(20, 5), 
Wind_Dir	INT, 
Wind_Force_Bft	INT, 
Prop_1_Pitch	DOUBLE(20, 5), 
ME_1_Aux_Blower	DOUBLE(20, 5), 
ME_1_Shaft_Gen_Power	DOUBLE(20, 5), 
ME_1_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
Wind_Force_Kn	DOUBLE(20, 5), 
ME_1_Pressure_Drop_Over_Scav_Air_Cooler	DOUBLE(20, 5), 
ME_1_TC_Speed	DOUBLE(20, 5), 
ME_1_Exh_Temp_Before_TC	DOUBLE(20, 5), 
ME_1_Exh_Temp_After_TC	DOUBLE(20, 5), 
ME_1_Current_Consumption	DOUBLE(20, 5), 
ME_1_SFOC_ISO_Corrected	DOUBLE(20, 5), 
ME_1_SFOC	DOUBLE(20, 5), 
ME_1_Pmax	DOUBLE(20, 5), 
ME_1_Pcomp	DOUBLE(20, 5), 
ME_2_Load	DOUBLE(20, 5), 
ME_2_Speed_RPM	DOUBLE(20, 5), 
Prop_2_Pitch	DOUBLE(20, 5), 
ME_2_Aux_Blower	DOUBLE(20, 5), 
ME_2_Shaft_Gen_Power	DOUBLE(20, 5), 
ME_2_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
ME_2_Scav_Air_Pressure	DOUBLE(20, 5), 
ME_2_Pressure_Drop_Over_Scav_Air_Cooler	DOUBLE(20, 5), 
ME_2_TC_Speed	DOUBLE(20, 5), 
ME_2_Exh_Temp_Before_TC	DOUBLE(20, 5), 
ME_2_Exh_Temp_After_TC	DOUBLE(20, 5), 
ME_2_Current_Consumption	DOUBLE(20, 5), 
ME_2_SFOC_ISO_Corrected	DOUBLE(20, 5), 
ME_2_SFOC	DOUBLE(20, 5), 
ME_2_Pmax	DOUBLE(20, 5), 
ME_2_Pcomp	DOUBLE(20, 5), 
AE_Barometric_Pressure	DOUBLE(20, 5), 
AE_Charge_Air_Coolant_Inlet_Temp	DOUBLE(20, 5), 
AE_Air_Intake_Temp	DOUBLE(20, 5), 
AE_1_Load	DOUBLE(20, 5), 
AE_1_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_1_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_1_TC_Speed	DOUBLE(20, 5), 
AE_1_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_1_Current_Consumption	DOUBLE(20, 5), 
AE_1_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_1_SFOC	DOUBLE(20, 5), 
AE_1_Pmax	DOUBLE(20, 5), 
AE_1_Pcomp	DOUBLE(20, 5), 
AE_2_Load	DOUBLE(20, 5), 
AE_2_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_2_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_2_TC_Speed	DOUBLE(20, 5), 
AE_2_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_2_Current_Consumption	DOUBLE(20, 5), 
AE_2_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_2_SFOC	DOUBLE(20, 5), 
AE_2_Pmax	DOUBLE(20, 5), 
AE_2_Pcomp	DOUBLE(20, 5), 
AE_3_Load	DOUBLE(20, 5), 
AE_3_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_3_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_3_TC_Speed	DOUBLE(20, 5), 
AE_3_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_3_Current_Consumption	DOUBLE(20, 5), 
AE_3_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_3_SFOC	DOUBLE(20, 5), 
AE_3_Pmax	DOUBLE(20, 5), 
AE_3_Pcomp	DOUBLE(20, 5), 
AE_4_Load	DOUBLE(20, 5), 
AE_4_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_4_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_4_TC_Speed	DOUBLE(20, 5), 
AE_4_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_4_Current_Consumption	DOUBLE(20, 5), 
AE_4_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_4_SFOC	DOUBLE(20, 5), 
AE_4_Pmax	DOUBLE(20, 5), 
AE_4_Pcomp	DOUBLE(20, 5), 
AE_5_Load	DOUBLE(20, 5), 
AE_5_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_5_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_5_TC_Speed	DOUBLE(20, 5), 
AE_5_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_5_Current_Consumption	DOUBLE(20, 5), 
AE_5_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_5_SFOC	DOUBLE(20, 5), 
AE_5_Pmax	DOUBLE(20, 5), 
AE_5_Pcomp	DOUBLE(20, 5), 
AE_6_Load	DOUBLE(20, 5), 
AE_6_Charge_Air_Inlet_Temp	DOUBLE(20, 5), 
AE_6_Charge_Air_Pressure	DOUBLE(20, 5), 
AE_6_TC_Speed	DOUBLE(20, 5), 
AE_6_Exh_Gas_Temperature	DOUBLE(20, 5), 
AE_6_Current_Consumption	DOUBLE(20, 5), 
AE_6_SFOC_ISO_Corrected	DOUBLE(20, 5), 
AE_6_SFOC	DOUBLE(20, 5), 
AE_6_Pmax	DOUBLE(20, 5), 
AE_6_Pcomp	DOUBLE(20, 5), 
Boiler_1_Operation_Mode	DOUBLE(20, 5), 
Boiler_1_Feed_Water_Flow	DOUBLE(20, 5), 
Boiler_1_Steam_Pressure	DOUBLE(20, 5), 
Boiler_2_Operation_Mode	DOUBLE(20, 5), 
Boiler_2_Feed_Water_Flow	DOUBLE(20, 5), 
Boiler_2_Steam_Pressure	DOUBLE(20, 5), 
Cooling_Water_System_SW_Pumps_In_Service	DOUBLE(20, 5), 
Cooling_Water_System_SW_Inlet_Temp	DOUBLE(20, 5), 
Cooling_Water_System_SW_Outlet_Temp	DOUBLE(20, 5), 
Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger	DOUBLE(20, 5), 
Cooling_Water_System_Pump_Pressure	DOUBLE(20, 5), 
ER_Ventilation_Fans_In_Service	DOUBLE(20, 5), 
ER_Ventilation_Waste_Air_Temp	DOUBLE(20, 5), 
Remarks	DOUBLE(20, 5), 
Entry_Made_By_1	DOUBLE(20, 5), 
Entry_Made_By_2	DOUBLE(20, 5),
Relative_Wind_Speed DOUBLE (10, 5),
Relative_Wind_Direction DOUBLE (10, 5),
Speed_Over_Ground DOUBLE (10, 5),
Shaft_Revolutions DOUBLE (10, 5),
Static_Draught_Fore DOUBLE(10, 5),
Static_Draught_Aft DOUBLE(10, 5),
Seawater_Temperature DOUBLE (10, 5),
Air_Temperature DOUBLE(10, 8),
Air_Pressure DOUBLE(10, 6),
Mass_Consumed_Fuel_Oil DOUBLE(10, 3),
Lower_Caloirifc_Value_Fuel_Oil DOUBLE(10, 5),
Density_Fuel_Oil_15C DOUBLE(10, 5)
);

INSERT INTO tempRaw (IMO_Vessel_Number, DateTime_UTC, AE_1_Running_Hours, AE_2_Running_Hours, Date_Local, AE_3_Running_Hours, Time_Local, Voyage_From, Voyage_To, Voyage_Number, AE_Consumption, Boiler_Consumption, Latitude_North_South, Cargo_Mt, Current_Dir, Longitude_East_West, Current_Speed, Date_UTC, Distance, Sea_state_Dir, Sea_state_Force_Douglas, Draft_Actual_Aft, Draft_Actual_Fore, Draft_Displacement_Actual, Temperature_Ambient, Latitude_Degree, Latitude_Minutes, Longitude_Degree, Draft_Recommended_Fore, Draft_Recommended_Aft, Draft_Ballast_Actual, Draft_Ballast_Optimum, Longitude_Minutes, ME_Fuel_BDN, AE_Fuel_BDN, Event, ME_1_Load, ME_1_Running_Hours, Time_Elapsed_Maneuvering, Time_Elapsed_Waiting, ME_1_Scav_Air_Pressure, ME_1_Speed_RPM, ME_Consumption, Apparent_Slip, Nominal_Slip, Cargo_Total_TEU, Cargo_Total_Full_TEU, Cargo_Reefer_TEU, Cargo_CEU, Crew, Passengers, People, ME_Projected_Consumption, Speed_GPS, ME_Cylinder_Oil_Consumption, ME_System_Oil_Consumption, Speed_Through_Water, ME_1_Consumption, ME_1_Cylinder_Oil_Consumption, ME_1_System_Oil_Consumption, ME_1_Work, ME_1_Shaft_Power, ME_1_Shaft_Gen_Running_Hours, ME_2_Running_Hours, ME_2_Consumption, ME_2_Cylinder_Oil_Consumption, ME_2_System_Oil_Consumption, ME_2_Work, ME_2_Shaft_Power, ME_2_Shaft_Gen_Running_Hours, AE_Projected_Consumption, Swell_Dir, Swell_Force, AE_1_Consumption, AE_1_Work, Temperature_Water, AE_2_Consumption, AE_2_Work, Time_Elapsed_Loading_Unloading, AE_3_Consumption, AE_3_Work, AE_4_Running_Hours, AE_4_Consumption, AE_4_Work, AE_5_Running_Hours, AE_5_Consumption, AE_5_Work, AE_6_Running_Hours, AE_6_Consumption, AE_6_Work, Time_Elapsed_Sailing, Boiler_1_Running_Hours, Boiler_1_Consumption, Boiler_2_Running_Hours, Boiler_2_Consumption, Air_Compr_1_Running_Time, Air_Compr_2_Running_Time, Thruster_1_Running_Time, Thruster_2_Running_Time, Thruster_3_Running_Time, Lube_Oil_System_Type_Of_Pump_In_Service, Cleaning_Event, Mode, Time_Since_Previous_Report, Time_UTC, Speed_Projected_From_Charter_Party, Water_Depth, ME_Barometric_Pressure, ME_Charge_Air_Coolant_Inlet_Temp, ME_Air_Intake_Temp, Wind_Dir, Wind_Force_Bft, Prop_1_Pitch, ME_1_Aux_Blower, ME_1_Shaft_Gen_Power, ME_1_Charge_Air_Inlet_Temp, Wind_Force_Kn, ME_1_Pressure_Drop_Over_Scav_Air_Cooler, ME_1_TC_Speed, ME_1_Exh_Temp_Before_TC, ME_1_Exh_Temp_After_TC, ME_1_Current_Consumption, ME_1_SFOC_ISO_Corrected, ME_1_SFOC, ME_1_Pmax, ME_1_Pcomp, ME_2_Load, ME_2_Speed_RPM, Prop_2_Pitch, ME_2_Aux_Blower, ME_2_Shaft_Gen_Power, ME_2_Charge_Air_Inlet_Temp, ME_2_Scav_Air_Pressure, ME_2_Pressure_Drop_Over_Scav_Air_Cooler, ME_2_TC_Speed, ME_2_Exh_Temp_Before_TC, ME_2_Exh_Temp_After_TC, ME_2_Current_Consumption, ME_2_SFOC_ISO_Corrected, ME_2_SFOC, ME_2_Pmax, ME_2_Pcomp, AE_Barometric_Pressure, AE_Charge_Air_Coolant_Inlet_Temp, AE_Air_Intake_Temp, AE_1_Load, AE_1_Charge_Air_Inlet_Temp, AE_1_Charge_Air_Pressure, AE_1_TC_Speed, AE_1_Exh_Gas_Temperature, AE_1_Current_Consumption, AE_1_SFOC_ISO_Corrected, AE_1_SFOC, AE_1_Pmax, AE_1_Pcomp, AE_2_Load, AE_2_Charge_Air_Inlet_Temp, AE_2_Charge_Air_Pressure, AE_2_TC_Speed, AE_2_Exh_Gas_Temperature, AE_2_Current_Consumption, AE_2_SFOC_ISO_Corrected, AE_2_SFOC, AE_2_Pmax, AE_2_Pcomp, AE_3_Load, AE_3_Charge_Air_Inlet_Temp, AE_3_Charge_Air_Pressure, AE_3_TC_Speed, AE_3_Exh_Gas_Temperature, AE_3_Current_Consumption, AE_3_SFOC_ISO_Corrected, AE_3_SFOC, AE_3_Pmax, AE_3_Pcomp, AE_4_Load, AE_4_Charge_Air_Inlet_Temp, AE_4_Charge_Air_Pressure, AE_4_TC_Speed, AE_4_Exh_Gas_Temperature, AE_4_Current_Consumption, AE_4_SFOC_ISO_Corrected, AE_4_SFOC, AE_4_Pmax, AE_4_Pcomp, AE_5_Load, AE_5_Charge_Air_Inlet_Temp, AE_5_Charge_Air_Pressure, AE_5_TC_Speed, AE_5_Exh_Gas_Temperature, AE_5_Current_Consumption, AE_5_SFOC_ISO_Corrected, AE_5_SFOC, AE_5_Pmax, AE_5_Pcomp, AE_6_Load, AE_6_Charge_Air_Inlet_Temp, AE_6_Charge_Air_Pressure, AE_6_TC_Speed, AE_6_Exh_Gas_Temperature, AE_6_Current_Consumption, AE_6_SFOC_ISO_Corrected, AE_6_SFOC, AE_6_Pmax, AE_6_Pcomp, Boiler_1_Operation_Mode, Boiler_1_Feed_Water_Flow, Boiler_1_Steam_Pressure, Boiler_2_Operation_Mode, Boiler_2_Feed_Water_Flow, Boiler_2_Steam_Pressure, Cooling_Water_System_SW_Pumps_In_Service, Cooling_Water_System_SW_Inlet_Temp, Cooling_Water_System_SW_Outlet_Temp, Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger, Cooling_Water_System_Pump_Pressure, ER_Ventilation_Fans_In_Service, ER_Ventilation_Waste_Air_Temp, Remarks, Entry_Made_By_1, Entry_Made_By_2)
	(SELECT IMO_Vessel_Number, DateTime_UTC, AE_1_Running_Hours, AE_2_Running_Hours, Date_Local, AE_3_Running_Hours, Time_Local, Voyage_From, Voyage_To, Voyage_Number, AE_Consumption, Boiler_Consumption, Latitude_North_South, Cargo_Mt, Current_Dir, Longitude_East_West, Current_Speed, Date_UTC, Distance, Sea_state_Dir, Sea_state_Force_Douglas, Draft_Actual_Aft, Draft_Actual_Fore, Draft_Displacement_Actual, Temperature_Ambient, Latitude_Degree, Latitude_Minutes, Longitude_Degree, Draft_Recommended_Fore, Draft_Recommended_Aft, Draft_Ballast_Actual, Draft_Ballast_Optimum, Longitude_Minutes, ME_Fuel_BDN, AE_Fuel_BDN, Event, ME_1_Load, ME_1_Running_Hours, Time_Elapsed_Maneuvering, Time_Elapsed_Waiting, ME_1_Scav_Air_Pressure, ME_1_Speed_RPM, ME_Consumption, Apparent_Slip, Nominal_Slip, Cargo_Total_TEU, Cargo_Total_Full_TEU, Cargo_Reefer_TEU, Cargo_CEU, Crew, Passengers, People, ME_Projected_Consumption, Speed_GPS, ME_Cylinder_Oil_Consumption, ME_System_Oil_Consumption, Speed_Through_Water, ME_1_Consumption, ME_1_Cylinder_Oil_Consumption, ME_1_System_Oil_Consumption, ME_1_Work, ME_1_Shaft_Power, ME_1_Shaft_Gen_Running_Hours, ME_2_Running_Hours, ME_2_Consumption, ME_2_Cylinder_Oil_Consumption, ME_2_System_Oil_Consumption, ME_2_Work, ME_2_Shaft_Power, ME_2_Shaft_Gen_Running_Hours, AE_Projected_Consumption, Swell_Dir, Swell_Force, AE_1_Consumption, AE_1_Work, Temperature_Water, AE_2_Consumption, AE_2_Work, Time_Elapsed_Loading_Unloading, AE_3_Consumption, AE_3_Work, AE_4_Running_Hours, AE_4_Consumption, AE_4_Work, AE_5_Running_Hours, AE_5_Consumption, AE_5_Work, AE_6_Running_Hours, AE_6_Consumption, AE_6_Work, Time_Elapsed_Sailing, Boiler_1_Running_Hours, Boiler_1_Consumption, Boiler_2_Running_Hours, Boiler_2_Consumption, Air_Compr_1_Running_Time, Air_Compr_2_Running_Time, Thruster_1_Running_Time, Thruster_2_Running_Time, Thruster_3_Running_Time, Lube_Oil_System_Type_Of_Pump_In_Service, Cleaning_Event, Mode, Time_Since_Previous_Report, Time_UTC, Speed_Projected_From_Charter_Party, Water_Depth, ME_Barometric_Pressure, ME_Charge_Air_Coolant_Inlet_Temp, ME_Air_Intake_Temp, Wind_Dir, Wind_Force_Bft, Prop_1_Pitch, ME_1_Aux_Blower, ME_1_Shaft_Gen_Power, ME_1_Charge_Air_Inlet_Temp, Wind_Force_Kn, ME_1_Pressure_Drop_Over_Scav_Air_Cooler, ME_1_TC_Speed, ME_1_Exh_Temp_Before_TC, ME_1_Exh_Temp_After_TC, ME_1_Current_Consumption, ME_1_SFOC_ISO_Corrected, ME_1_SFOC, ME_1_Pmax, ME_1_Pcomp, ME_2_Load, ME_2_Speed_RPM, Prop_2_Pitch, ME_2_Aux_Blower, ME_2_Shaft_Gen_Power, ME_2_Charge_Air_Inlet_Temp, ME_2_Scav_Air_Pressure, ME_2_Pressure_Drop_Over_Scav_Air_Cooler, ME_2_TC_Speed, ME_2_Exh_Temp_Before_TC, ME_2_Exh_Temp_After_TC, ME_2_Current_Consumption, ME_2_SFOC_ISO_Corrected, ME_2_SFOC, ME_2_Pmax, ME_2_Pcomp, AE_Barometric_Pressure, AE_Charge_Air_Coolant_Inlet_Temp, AE_Air_Intake_Temp, AE_1_Load, AE_1_Charge_Air_Inlet_Temp, AE_1_Charge_Air_Pressure, AE_1_TC_Speed, AE_1_Exh_Gas_Temperature, AE_1_Current_Consumption, AE_1_SFOC_ISO_Corrected, AE_1_SFOC, AE_1_Pmax, AE_1_Pcomp, AE_2_Load, AE_2_Charge_Air_Inlet_Temp, AE_2_Charge_Air_Pressure, AE_2_TC_Speed, AE_2_Exh_Gas_Temperature, AE_2_Current_Consumption, AE_2_SFOC_ISO_Corrected, AE_2_SFOC, AE_2_Pmax, AE_2_Pcomp, AE_3_Load, AE_3_Charge_Air_Inlet_Temp, AE_3_Charge_Air_Pressure, AE_3_TC_Speed, AE_3_Exh_Gas_Temperature, AE_3_Current_Consumption, AE_3_SFOC_ISO_Corrected, AE_3_SFOC, AE_3_Pmax, AE_3_Pcomp, AE_4_Load, AE_4_Charge_Air_Inlet_Temp, AE_4_Charge_Air_Pressure, AE_4_TC_Speed, AE_4_Exh_Gas_Temperature, AE_4_Current_Consumption, AE_4_SFOC_ISO_Corrected, AE_4_SFOC, AE_4_Pmax, AE_4_Pcomp, AE_5_Load, AE_5_Charge_Air_Inlet_Temp, AE_5_Charge_Air_Pressure, AE_5_TC_Speed, AE_5_Exh_Gas_Temperature, AE_5_Current_Consumption, AE_5_SFOC_ISO_Corrected, AE_5_SFOC, AE_5_Pmax, AE_5_Pcomp, AE_6_Load, AE_6_Charge_Air_Inlet_Temp, AE_6_Charge_Air_Pressure, AE_6_TC_Speed, AE_6_Exh_Gas_Temperature, AE_6_Current_Consumption, AE_6_SFOC_ISO_Corrected, AE_6_SFOC, AE_6_Pmax, AE_6_Pcomp, Boiler_1_Operation_Mode, Boiler_1_Feed_Water_Flow, Boiler_1_Steam_Pressure, Boiler_2_Operation_Mode, Boiler_2_Feed_Water_Flow, Boiler_2_Steam_Pressure, Cooling_Water_System_SW_Pumps_In_Service, Cooling_Water_System_SW_Inlet_Temp, Cooling_Water_System_SW_Outlet_Temp, Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger, Cooling_Water_System_Pump_Pressure, ER_Ventilation_Fans_In_Service, ER_Ventilation_Waste_Air_Temp, Remarks, Entry_Made_By_1, Entry_Made_By_2
		FROM dnvglraw WHERE IMO_Vessel_Number = imo);
        
CALL convertDNVGLRawToRawData;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`createTempRawISO`(imo INT)
BEGIN
	
	DROP TABLE IF EXISTS tempRawISO;
    
	/* CREATE TABLE tempRawISO LIKE rawdata; */
    /* Creating table with all columns much faster than adding later */
	CREATE TABLE tempRawISO (id INT PRIMARY KEY AUTO_INCREMENT,
							 DateTime_UTC DATETIME(3),
							 IMO_Vessel_Number INT(7),
							 Relative_Wind_Speed DOUBLE(10, 5),
							 Relative_Wind_Direction DOUBLE(10, 5),
							 Speed_Over_Ground DOUBLE(10, 5),
							 Ship_Heading DOUBLE(10, 5),
							 Shaft_Revolutions DOUBLE(10, 5),
							 Static_Draught_Fore DOUBLE(10, 5),
							 Static_Draught_Aft DOUBLE(10, 5),
							 Water_Depth DOUBLE(10, 5),
							 Rudder_Angle DOUBLE(10, 5),
							 Seawater_Temperature DOUBLE(10, 5),
							 Air_Temperature DOUBLE(10, 8),
							 Air_Pressure DOUBLE(10, 6),
							 Air_Density DOUBLE(10, 9),
							 Speed_Through_Water DOUBLE(10, 5),
							 Delivered_Power DOUBLE(20, 3),
							 Shaft_Power DOUBLE(10, 5),
							 Brake_Power DOUBLE(20, 3),
							 Shaft_Torque DOUBLE(10, 5),
							 Mass_Consumed_Fuel_Oil DOUBLE(20, 10),
							 Volume_Consumed_Fuel_Oil DOUBLE(10, 5),
							 Lower_Caloirifc_Value_Fuel_Oil DOUBLE(10, 5),
							 Normalised_Energy_Consumption DOUBLE(10, 5),
							 Density_Fuel_Oil_15C DOUBLE(10, 5),
							 Density_Change_Rate_Per_C DOUBLE(10, 5),
							 Temp_Fuel_Oil_At_Flow_Meter DOUBLE(10, 5),
							 Wind_Resistance_Relative DOUBLE(10, 5),
							 Air_Resistance_No_Wind DOUBLE(10, 5),
							 Expected_Speed_Through_Water DOUBLE(10, 5),
							 Displacement DOUBLE(20, 10),
							 Speed_Loss DOUBLE(10, 5),
							 Transverse_Projected_Area_Current DOUBLE(10, 5),
							 Wind_Resistance_Correction DOUBLE(10, 5),
							 Corrected_Power DOUBLE(20, 3),
							 Filter_SpeedPower_Disp_Trim BOOLEAN,
							 Filter_SpeedPower_Trim BOOLEAN,
							 Filter_SpeedPower_Disp BOOLEAN,
							 Filter_SpeedPower_Below BOOLEAN,
							 NearestDisplacement DOUBLE(20, 10),
							 NearestTrim DOUBLE(10, 5),
							 Trim DOUBLE(10, 5),
							 Chauvenet_Criteria BOOLEAN,
							 Validated BOOLEAN,
							 Displacement_Correction_Needed BOOLEAN,
							 Filter_All BOOLEAN DEFAULT FALSE,
							 Filter_SFOC_Out_Range BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Seawater_Temp BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Wind_Speed BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Water_Depth BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Rudder_Angle BOOLEAN DEFAULT FALSE
							 ) ENGINE = MYISAM;
	
	INSERT INTO tempRawISO (DateTime_UTC, IMO_Vessel_Number, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement)
		SELECT DateTime_UTC, IMO_Vessel_Number, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement
			FROM rawdata WHERE IMO_Vessel_Number = imo;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`filterPowerBelowMinimum`(imo INT)
BEGIN
	
    /* Get nearest displacements and trim Filter_SpeedPower_Disp_Trim*/
	/* UPDATE tempRawISO t
		JOIN SpeedPower p
		ON t.IMO_Vessel_Number = p.IMO_Vessel_Number AND
			t.NearestTrim = p.Trim AND
            t.NearestDisplacement = p.Displacement
		SET t.Filter_SpeedPower_Below = t.Delivered_Power < MIN(p.Power)
        ; */
    
	/* Get the minimum power of the power curve corresponding to delivered power, then whether DeliveredPower is less than this value. */
	UPDATE tempRawISO y JOIN
		(SELECT q.id, q.BelowMin, q.Delivered_Power FROM
			(SELECT r.id, r.Delivered_Power, p.Power, r.Delivered_Power < p.Power AS 'BelowMin' FROM tempRawISO r
				JOIN SpeedPower p
					ON
					r.IMO_Vessel_Number = p.IMO_Vessel_Number AND
					r.NearestTrim = p.Trim AND
					r.NearestDisplacement = p.Displacement) AS q
		INNER JOIN
			(SELECT id, Delivered_Power, Power, MIN(Power) AS MinPower
			FROM
				(SELECT t.id, t.Delivered_Power, p.Power, t.Delivered_Power < p.Power AS 'BelowMin' FROM tempRawISO t
					JOIN SpeedPower p
						ON
						t.IMO_Vessel_Number = p.IMO_Vessel_Number AND
						t.NearestTrim = p.Trim AND
						t.NearestDisplacement = p.Displacement) AS w
			GROUP BY id) AS e
		ON
			q.id = e.id AND
			q.Power = e.Power
			GROUP BY q.id) u
	ON y.id = u.id
	SET y.Filter_SpeedPower_Below = u.BelowMin
		;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`filterReferenceConditions`(imo INT)
BEGIN
	
    DECLARE DepthFormula5 DOUBLE(10, 5);
    DECLARE DepthFormula6 DOUBLE(10, 5);
    DECLARE ShipBreadth DOUBLE(10, 5);
    DECLARE g1 DOUBLE(10, 5);
    
    DROP TABLE IF EXISTS DepthFormula;
    CREATE TABLE DepthFormula (id INT PRIMARY KEY AUTO_INCREMENT, 
								DateTime_UTC DATETIME, 
								Water_Depth DOUBLE(10, 5), 
								DepthFormula5 DOUBLE(10, 5), 
								DepthFormula6 DOUBLE(10, 5));
    
    INSERT INTO DepthFormula (DateTime_UTC) SELECT DateTime_UTC FROM tempRawISO;
    UPDATE DepthFormula, tempRawISO SET DepthFormula.Water_Depth = tempRawISO.Water_Depth;
    
    SET ShipBreadth := (SELECT Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = imo);
    SET g1 := (SELECT g FROM globalConstants);
    
	UPDATE DepthFormula d 
		INNER JOIN tempRawISO t
			ON d.DateTime_UTC = t.DateTime_UTC
				SET 
                d.DepthFormula5 = 3 * SQRT( ShipBreadth * (t.Static_Draught_Aft + t.Static_Draught_Fore) / 2 ),
                d.DepthFormula6 = 2.75 * POWER(t.Speed_Through_Water, 2) / g1, 
                d.Water_Depth = t.Water_Depth;
    
    UPDATE tempRawISO SET Filter_Reference_Seawater_Temp = TRUE WHERE Seawater_Temperature <= 2;
    UPDATE tempRawISO SET Filter_Reference_Wind_Speed = TRUE WHERE Relative_Wind_Speed > 7.9;
    UPDATE tempRawISO SET Filter_Reference_Water_Depth = TRUE WHERE Water_Depth < 3 * SQRT( ShipBreadth * (Static_Draught_Aft + Static_Draught_Fore) / 2 ) 
		OR Water_Depth < 2.75 * POWER(Speed_Through_Water, 2) / g1;
    UPDATE tempRawISO SET Filter_Reference_Rudder_Angle = TRUE WHERE Rudder_Angle > 5;
    
	/* DELETE FROM tempRawISO WHERE Seawater_Temperature <= 2; */
    /* 
	DELETE FROM tempRawISO WHERE Relative_Wind_Speed < 0 OR Relative_Wind_Speed > 7.9;
	DELETE FROM tempRawISO WHERE Rudder_Angle > 5;
    DELETE d
		FROM tempRawISO d
        JOIN DepthFormula dd ON d.DateTime_UTC = dd.DateTime_UTC
        WHERE d.Water_Depth < dd.DepthFormula5 OR
			  d.Water_Depth < dd.DepthFormula6;
    /* DROP TABLE DepthFormula; */
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`filterSFOCOutOfRange`(imo INT)
BEGIN
    
    UPDATE tempRawISO SET Filter_SFOC_Out_Range = CASE
		WHEN Brake_Power < (SELECT Lowest_Given_Brake_Power FROM sfoccoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = imo)) OR 
			Brake_Power > (SELECT Highest_Given_Brake_Power FROM sfoccoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = imo)) THEN TRUE
        ELSE FALSE
    END;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`filterSpeedPowerLookup`(imo INT)
BEGIN
	
    /* 
    /* Declarations */
    /* DECLARE numRows INT;
    SET numRows := (SELECT COUNT(*) FROM tempRawISO);
    
    /* Create temporary table for speed-power data look-up */
	/* DROP TABLE IF EXISTS tempSpeedPowerConditions;
	CREATE TABLE tempSpeedPowerConditions (id INT PRIMARY KEY AUTO_INCREMENT,
									Displacement DOUBLE(20, 10),
									Displacement_Difference_With_Nearest DOUBLE(20, 3),
									Displacement_Nearest DOUBLE(20, 3),
									Displacement_Diff_PC DOUBLE(10, 5),
									Displacement_Condition BOOLEAN,
                                    Trim DOUBLE(10, 8),
                                    Trim_Nearest DOUBLE(10, 8),
									Trim_Condition BOOLEAN,
									Nearest_Neighbour_Condition BOOLEAN);
    
    /* Update trim */
    /* UPDATE tempRawISO SET Trim = Static_Draught_Fore - Static_Draught_Aft;
    
	/* Find nearest displacement value */
    /* INSERT INTO tempSpeedPowerConditions (Displacement, Trim) SELECT Displacement, Trim FROM tempRawISO WHERE Displacement IS NOT NULL;
    CALL log_msg('Max Displacement = ', (SELECT MAX(Displacement) FROM tempSpeedPowerConditions));
    
	DROP TABLE IF EXISTS tempTable1;
	CREATE TABLE tempTable1 (id INT PRIMARY KEY AUTO_INCREMENT, disps DOUBLE(20, 10), lookupDisps DOUBLE(20, 10), `Abs Difference` DOUBLE(20, 10));
	INSERT INTO tempTable1 (disps, lookupDisps, `Abs Difference`)
		(SELECT a.Displacement, b.Displacement, ABS(a.Displacement - b.Displacement) AS 'Abs Difference'
			FROM tempSpeedPowerConditions a
				JOIN speedPowerCoefficients b
					ORDER BY b.Displacement);
    
    CALL log_msg('disps 1 = ', (SELECT disps FROM tempTable1 LIMIT 1));
    CALL log_msg('lookupDisps 1 = ', (SELECT lookupDisps FROM tempTable1 LIMIT 1));
    CALL log_msg('`Abs Difference` 1 = ', (SELECT `Abs Difference` FROM tempTable1 LIMIT 1));
    
    /* UPDATE tempSpeedPowerConditions a
		INNER JOIN tempTable1 b
			ON a.Displacement = b.disps
				SET
                a.Displacement_Nearest = b.disps ORDER BY `Abs Difference` LIMIT numRows;
    /* UPDATE tempSpeedPowerConditions a,  tempTable1 b SET a.Displacement_Nearest = (SELECT b.disps FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows); */
	/*INSERT INTO tempSpeedPowerConditions (Displacement_Nearest) (SELECT disps FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows); */
    
    /* DROP TABLE IF EXISTS NearestDisplacement;
	CREATE TABLE NearestDisplacement (id INT PRIMARY KEY AUTO_INCREMENT, Displacement DOUBLE(20, 10), Displacement_Difference_With_Nearest DOUBLE(20, 3), Displacement_Nearest DOUBLE(20, 3));
    INSERT INTO NearestDisplacement (Displacement, Displacement_Nearest, Displacement_Difference_With_Nearest) (SELECT disps, lookupDisps, `Abs Difference` FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows);
    UPDATE tempSpeedPowerConditions a
		INNER JOIN NearestDisplacement b
			ON a.Displacement = b.Displacement
				SET
                a.Displacement_Nearest = b.Displacement_Nearest,
                a.Displacement_Difference_With_Nearest = b.Displacement_Difference_With_Nearest;
	
    CALL log_msg('Displacement_Nearest 1 = ', (SELECT Displacement_Nearest FROM tempSpeedPowerConditions LIMIT 1));
    
    /* UPDATE tempSpeedPowerConditions SET Displacement_Difference_With_Nearest = (SELECT MIN(ABS(Difference)) AS 'Difference_With_Speed_Power' FROM 
		(SELECT (tempRawISO.Displacement - speedPower.Displacement) AS 'Difference' FROM tempRawISO
			JOIN speedPower WHERE tempRawISO.IMO_Vessel_Number = imo) AS tempTable1 GROUP BY Displacement);
    CALL log_msg('Max DWN = ', (SELECT MAX(Displacement_Difference_With_Nearest) FROM tempSpeedPowerConditions));
    
    UPDATE tempSpeedPowerConditions SET Displacement_Nearest = Displacement + Displacement_Difference_With_Nearest;
    CALL log_msg('Max NISP = ', (SELECT MAX(Displacement_Nearest) FROM tempSpeedPowerConditions)); */
    
    /* Update Displacement Condition */
    /* UPDATE tempSpeedPowerConditions SET Displacement_Diff_PC = ( Displacement_Difference_With_Nearest / Displacement_Nearest )*100;
    UPDATE tempSpeedPowerConditions SET Displacement_Condition = Displacement_Diff_PC > 5;
    CALL log_msg('Max DispCond = ', (SELECT MAX(Displacement_Condition) FROM tempSpeedPowerConditions));
    
    /* Update Trim Condition SELECT Trim FROM tempRawISO */
	/* DROP TABLE IF EXISTS tempTable3;
	CREATE TABLE tempTable3 (id INT PRIMARY KEY AUTO_INCREMENT, rawTrim DOUBLE(20, 10), lookupTrim DOUBLE(20, 10), `Abs Difference` DOUBLE(20, 10));
	INSERT INTO tempTable3 (rawTrim, lookupTrim, `Abs Difference`)
		(SELECT a.Trim, b.Trim, ABS(a.Trim - b.Trim) AS 'Abs Difference'
			FROM tempSpeedPowerConditions a
				JOIN speedPowerCoefficients b
					ORDER BY b.Trim);
                    
    UPDATE tempSpeedPowerConditions a 
	INNER JOIN (SELECT rawTrim, lookupTrim, `Abs Difference` FROM tempTable3 ORDER BY `Abs Difference` LIMIT 2) b
		ON a.Trim = b.rawTrim
			SET a.Trim_Nearest = b.lookupTrim,
				a.Trim_Condition = (ABS(a.Trim) - ABS(a.Trim_Nearest)) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = 9450648));
    
    /* UPDATE tempSpeedPowerConditions a
		INNER JOIN tempRawISO b
			ON a.Displacement = b.Displacement
				SET
                a.Trim_Condition = ABS(b.Trim) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)); */
    
    /* UPDATE tempSpeedPowerConditions, tempRawISO SET Trim_Condition = CASE
		WHEN ABS(tempRawISO.Trim) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo))
        THEN TRUE
        ELSE FALSE
	END; */
    /* CALL log_msg('Max TrimCond = ', (SELECT MAX(Trim_Condition) FROM tempSpeedPowerConditions));
    
    /* Update raw data table with conditions */
    /* UPDATE tempRawISO t
		INNER JOIN tempSpeedPowerConditions d
			ON t.Displacement = d.Displacement
				SET
                t.Filter_SpeedPower_Disp = Displacement_Condition,
                t.Filter_SpeedPower_Trim = Trim_Condition;
    CALL log_msg('Max tempRaw Dist Cond = ', (SELECT MAX(Filter_SpeedPower_Disp) FROM tempRawISO));
    
    /* Update Nearest Neighbour Condition */
	/* UPDATE tempSpeedPowerConditions
		SET Nearest_Neighbour_Condition = CASE
			WHEN Displacement_Condition = TRUE AND Trim_Condition = TRUE THEN TRUE
			ELSE FALSE
		END; */
    
    /* Delete unwanted tables */
    
    /* Get upper and lower limits */
    
    /* Is value between limits? */
    
   /* Get boolean column indicating which values of trim and displacement are outside the ranges for nearest-neighbour interpolation */
   /* UPDATE tempRawISO SET Filter_SpeedPower_Disp_Trim = id NOT IN (SELECT Cid FROM
	(SELECT c.id AS Cid, d.id AS Did, `Actual Displacement`, `Actual Trim`, SPTrim, SPDisplacement FROM 
			(SELECT 
				 b.id, 
				 a.Trim AS 'SPTrim',
				 b.Trim AS 'Actual Trim',
				 `Lower Trim`,
				 `Upper Trim`,
				 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim
				 FROM speedpowercoefficients a
				 JOIN
					(SELECT
							id,
						   Trim,
						  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
						  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
					FROM tempRawISO) AS b) AS c
		JOIN
			(SELECT
				 b.id, 
				 a.Displacement AS 'SPDisplacement',
				 b.Displacement AS 'Actual Displacement',
				 `Lower Displacement`,
				 `Upper Displacement`,
				 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement
				 FROM speedpowercoefficients a
				 JOIN
					(SELECT 
							id,
						   Displacement,
						  (Displacement*0.95) AS 'Lower Displacement',
						  (Displacement*1.05) AS 'Upper Displacement'
					FROM tempRawISO) AS b) AS d
		WHERE c.ValidTrim = 1 AND
			  d.ValidDisplacement = 1
			) e
		WHERE Cid = DiD
		GROUP BY Cid)
        ; */
	
    /* Update column giving the nearest value of Displacement and Trim for which the Displacement and Trim conditions are both satisfied */
	/* UPDATE tempRawISO f
	JOIN (SELECT * FROM (SELECT c.id AS Cid, d.id AS Did, `Actual Displacement`, `Actual Trim`, SPTrim, SPDisplacement FROM
				(SELECT
					 b.id,
					 a.Trim AS 'SPTrim',
					 b.Trim AS 'Actual Trim',
					 `Lower Trim`,
					 `Upper Trim`,
					 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim
					 FROM speedpowercoefficients a
					 JOIN
						(SELECT
								id,
							   Trim,
							  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
							  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
						FROM tempRawISO) AS b) AS c
			JOIN
				(SELECT
					 b.id,
					 a.Displacement AS 'SPDisplacement',
					 b.Displacement AS 'Actual Displacement',
					 `Lower Displacement`,
					 `Upper Displacement`,
					 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement
					 FROM speedpowercoefficients a
					 JOIN
						(SELECT
								id,
							   Displacement,
							  (Displacement*0.95) AS 'Lower Displacement',
							  (Displacement*1.05) AS 'Upper Displacement'
						FROM tempRawISO) AS b) AS d
			WHERE c.ValidTrim = 1 AND
				  d.ValidDisplacement = 1
				) e
			WHERE Cid = DiD
			GROUP BY Cid) g
	ON f.id = g.Cid
    SET f.NearestDisplacement = g.SPDisplacement,
		f.NearestTrim = g.SPTrim
        ;*/
	
    /* Get valid trim and nearest trim */
    UPDATE tempRawISO t
		JOIN (
			SELECT c.id, c.SPTrim, c.ValidTrim
				FROM (SELECT 
					 b.id, 
					 a.Trim AS 'SPTrim',
					 b.Trim AS 'Actual Trim',
					 `Lower Trim`,
					 `Upper Trim`,
					 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim,
					 ABS((ABS(a.Trim) - ABS(b.Trim))) AS DiffTrim
					 FROM speedpowercoefficients a
					 JOIN
						(SELECT
								id,
							   Trim,
							  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
							  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
						FROM tempRawISO) AS b) AS c
					 INNER JOIN
						(
						SELECT f.id, 'SPTrim', 'Actual Trim', `Lower Trim`, `Upper Trim`, ValidTrim, MIN(DiffTrim) AS MinDiff
						FROM (SELECT 
								 d.id, 
								 a.Trim AS 'SPTrim',
								 d.Trim AS 'Actual Trim',
								 `Lower Trim`,
								 `Upper Trim`,
								 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim,
								 ABS((ABS(a.Trim) - ABS(d.Trim))) AS DiffTrim
								 FROM speedpowercoefficients a
								 JOIN
									(SELECT
											id,
										   Trim,
										  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
										  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
									FROM tempRawISO) AS d) AS f
							GROUP BY id) AS e /* 'SPTrim', 'Actual Trim', `Lower Trim`, `Upper Trim`,  */ 
					  ON
						c.id= e.id AND
						c.DiffTrim = e.MinDiff
					  GROUP BY c.id) w
                    ON t.id = w.id
		SET t.Filter_SpeedPower_Trim = NOT(w.ValidTrim),
			t.NearestTrim = w.SPTrim
				;
	
    /* Get valid displacement and nearest displacement */
    UPDATE tempRawISO t
		JOIN (
			SELECT z.id, z.ValidDisplacement, z.SPDisplacement AS 'NearestDisplacement'
				FROM
					(SELECT
						 b.id,
                         a.IMO_Vessel_Number,
						 a.Displacement AS 'SPDisplacement',
						 b.Displacement AS 'Actual Displacement',
						 `Lower Displacement`,
						 `Upper Displacement`,
						 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement,
						 ABS((ABS(a.Displacement) - ABS(b.Displacement))) AS DiffDisp
						 FROM speedpowercoefficients a
						 JOIN
							(SELECT
									id,
                                    IMO_Vessel_Number,
								   Displacement,
								  (Displacement*0.95) AS 'Lower Displacement',
								  (Displacement*1.05) AS 'Upper Displacement'
							FROM tempRawISO) AS b
						ON a.IMO_Vessel_Number = b.IMO_Vessel_Number) AS z
				INNER JOIN
					(
					SELECT d.id, SPDisplacement, `Actual Displacement`, `Lower Displacement`, `Upper Displacement`, ValidDisplacement, MIN(DiffDisp) AS MinDiff
					FROM (SELECT
						 b.id,
                         a.IMO_Vessel_Number,
						 a.Displacement AS 'SPDisplacement',
						 b.Displacement AS 'Actual Displacement',
						 `Lower Displacement`,
						 `Upper Displacement`,
						 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement,
						 ABS((ABS(a.Displacement) - ABS(b.Displacement))) AS DiffDisp
						 FROM speedpowercoefficients a
						 JOIN
							(SELECT
									id,
                                    IMO_Vessel_Number,
								   Displacement,
								  (Displacement*0.95) AS 'Lower Displacement',
								  (Displacement*1.05) AS 'Upper Displacement'
							FROM tempRawISO) AS b
						ON a.IMO_Vessel_Number = b.IMO_Vessel_Number) AS d
					 GROUP BY id) AS x /* 'SPTrim', 'Actual Trim', `Lower Trim`, `Upper Trim`,  */ 
				  ON
					z.id= x.id AND
					z.DiffDisp = x.MinDiff
					GROUP BY z.id) w
                    ON t.id = w.id
			 SET t.NearestDisplacement = w.NearestDisplacement,
				 t.Filter_SpeedPower_Disp = NOT(w.ValidDisplacement);
    
	/* Get boolean column indicating which values of trim and displacement are outside the ranges for nearest-neighbour interpolation */
	UPDATE tempRawISO SET Filter_SpeedPower_Disp_Trim = (Filter_SpeedPower_Disp OR Filter_SpeedPower_Trim);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`IMOStartEnd`(OUT imo INT(7), OUT startd DATETIME, OUT endd DATETIME)
BEGIN

SET imo := (SELECT DISTINCT(IMO_Vessel_Number) FROM tempRawISO);
SET startd := (SELECT MIN(DateTime_UTC) FROM tempRawISO);
SET endd := (SELECT MAX(DateTime_UTC) FROM tempRawISO);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`insertFromDNVGLRawIntoRaw`(imo INT)
BEGIN

CALL createTempRaw(imo);
CALL updateFromBunkerNote(imo);

INSERT INTO rawdata (IMO_Vessel_Number,
							Water_Depth, 
							DateTime_UTC,
							Relative_Wind_Speed,
							 Relative_Wind_Direction,
							 Speed_Over_Ground,
                             Speed_Through_Water,
							 Shaft_Revolutions,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							 Seawater_Temperature,
							 Air_Temperature,
							 Air_Pressure,
							 Mass_Consumed_Fuel_Oil,
                             Shaft_Power,
                             Displacement
                             )
SELECT IMO_Vessel_Number, 
							 Water_Depth, 
							 DateTime_UTC, 
							 Relative_Wind_Speed,
							 Relative_Wind_Direction,
							 Speed_Over_Ground,
                             Speed_Through_Water,
							 Shaft_Revolutions,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							 Seawater_Temperature,
							 Air_Temperature,
							 Air_Pressure,
							 Mass_Consumed_Fuel_Oil,
                             ME_1_Load,
                             Draft_Displacement_Actual
							 FROM tempRaw
								ON DUPLICATE KEY UPDATE 
									IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
                                    Water_Depth = VALUES(Water_Depth),
                                    DateTime_UTC = VALUES(DateTime_UTC),
                                    Relative_Wind_Speed = VALUES(Relative_Wind_Speed),
                                    Relative_Wind_Direction = VALUES(Relative_Wind_Direction),
                                    Speed_Over_Ground = VALUES(Speed_Over_Ground),
                                    Speed_Through_Water = VALUES(Speed_Through_Water),
                                    Shaft_Revolutions = VALUES(Shaft_Revolutions),
                                    Static_Draught_Fore = VALUES(Static_Draught_Fore),
                                    Static_Draught_Aft = VALUES(Static_Draught_Aft),
                                    Seawater_Temperature = VALUES(Seawater_Temperature),
                                    Air_Temperature = VALUES(Air_Temperature),
                                    Air_Pressure = VALUES(Air_Pressure),
                                    Mass_Consumed_Fuel_Oil = VALUES(Mass_Consumed_Fuel_Oil),
                                    Shaft_Power = VALUES(Shaft_Power),
                                    Displacement = VALUES(Displacement)
									;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`insertIntoPerformanceData`(allFilt BOOLEAN, speedPowerFilt BOOLEAN, SFOCFilt BOOLEAN)
BEGIN

/* Get data for compliance table for this analysis */
DECLARE imo INT(7);
DECLARE starttime DATETIME;
DECLARE endtime DATETIME;
DECLARE compliant BOOLEAN;
DECLARE freqSufficient BOOLEAN;

/* Determine whether instrument frequencies are sufficient for standard compliance, from data */
CALL validateFrequencies(@valSTWt,
					 @valDelt,
					 @valShRt,
					 @valRWSt,
					 @valRWDt,
					 @valSOGt,
					 @valHeat,
					 @valRudt,
					 @valWDpt,
					 @valTmpt);
SET freqSufficient = @valSTWt AND @valDelt AND @valShRt AND @valRWSt AND @valRWDt AND @valSOGt AND @valHeat AND @valRudt AND @valWDpt AND @valTmpt;

/* Declare whether standard has been complied with */
CALL IMOStartEnd(@imo, @startd, @endd);
INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, FrequencySufficient, SpeedPowerInRange, SFOCInRange)
VALUES (@imo, @startd, @endd, freqSufficient, speedPowerFilt, SFOCFilt) ON DUPLICATE KEY UPDATE 
FrequencySufficient = VALUES(FrequencySufficient), SpeedPowerInRange = VALUES(SpeedPowerInRange), SFOCInRange = VALUES(SFOCInRange);

/* Perform selected filtering */
IF allFilt THEN
	DELETE FROM tempRawISO WHERE AllFilt;
END IF;
IF speedPowerFilt THEN
	DELETE FROM tempRawISO WHERE Filter_SpeedPower_Below;
END IF;
IF SFOCFilt THEN
	DELETE FROM tempRawISO WHERE Filter_SFOC_Out_Range;
END IF;

/* Insert data from temporary table into performance data after filtering */
/* INSERT INTO PerformanceData
	(DateTime_UTC, IMO_Vessel_Number, Speed_Index)
		SELECT DateTime_UTC, IMO_Vessel_Number, Speed_Loss
			FROM tempRawISO AS aa WHERE NOT EXISTS(
				Select DateTime_UTC, IMO_Vessel_Number, Speed_Loss
					FROM PerformanceData AS bb WHERE
						aa.DateTime_UTC = bb.DateTime_UTC AND
						aa.IMO_Vessel_Number = bb.IMO_Vessel_Number); */

INSERT INTO PerformanceData
	(DateTime_UTC, IMO_Vessel_Number, Speed_Index)
		SELECT DateTime_UTC, IMO_Vessel_Number, Speed_Loss
			FROM tempRawISO
				ON DUPLICATE KEY UPDATE	
					DateTime_UTC = VALUES(DateTime_UTC),
					IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
					Speed_Index = VALUES(Speed_Index);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`isBrakePowerAvailable`(imo INT, OUT isAvailable BOOLEAN, OUT isVoumeNeeded BOOLEAN)
BEGIN
	
    DECLARE MfocAvail BOOLEAN;
    DECLARE LCVAvail BOOLEAN;
    
    SET MfocAvail := FALSE;
    SET LCVAvail := FALSE;
    
    SET isAvailable = FALSE;
    SET isVoumeNeeded = FALSE;
    
    /* Check if Mass of fuel oil consumed is not all NULL */
    IF (SELECT COUNT(*) FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil IS NOT NULL) = 0 THEN
		
        /* Check if Mass of fuel oil consumed can be calculated */
        IF (SELECT COUNT(*) FROM tempRawISO WHERE Volume_Consumed_Fuel_Oil IS NOT NULL AND
												  Density_Fuel_Oil_15C  IS NOT NULL AND
                                                  Density_Change_Rate_Per_C  IS NOT NULL AND
                                                  Temp_Fuel_Oil_At_Flow_Meter IS NOT NULL
																				) > 0 THEN
			SET MfocAvail := TRUE;
            SET isVoumeNeeded := TRUE;
        END IF;
        
	ELSE
        SET MfocAvail := TRUE;
    END IF;
    
    /* Check if LCV is available */
    IF (SELECT COUNT(*) FROM tempRawISO WHERE Lower_Caloirifc_Value_Fuel_Oil IS NOT NULL) > 0 THEN
		SET LCVAvail := TRUE;
    END IF;
    
    /* Brake Power available when both are available */
	SET isAvailable = LCVAvail AND MfocAvail;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`ISO19030`(imo int)
BEGIN

	/* Get retreived data set 5.3.3 */
    CALL createTempRawISO(imo);
    CALL removeInvalidRecords();
    CALL sortOnDateTime();
    
    /* Normalise frequency rates 5.3.3.1 */
    CALL normaliseHigherFreq();
    CALL normaliseLowerFreq();
    
    /* Get validated data set 5.3.4 */
    CALL updateChauvenetCriteria();
    CALL updateValidated();
    
    /* Correct for environmental factors 5.3.5 */
    CALL updateDeliveredPower(imo);
    
    CALL updateAirDensity();
    CALL updateTransProjArea(imo);
    CALL updateWindResistanceRelative(imo);
	CALL updateAirResistanceNoWind(imo);
	CALL updateWindResistanceCorrection(imo);
    
    CALL updateDisplacement(imo);
    CALL updateTrim();
    CALL filterSpeedPowerLookup(imo);
    
    CALL updateCorrectedPower();
    
    /* Calculate Performance Values 5.3.6.2 */
    CALL updateExpectedSpeed(imo);
    
    /* Calculate Performance Values 5.3.6.1 */
    CALL updateSpeedLoss();
    
    /* Calculate filter */
    CALL filterSFOCOutOfRange(imo);
    CALL filterPowerBelowMinimum(imo);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`isShaftPowerAvailable`(imo INT, OUT isAvailable BOOLEAN)
BEGIN
	
    SET isAvailable = FALSE;
    
    /* Check if torque and rpm are both not all NULL */
    IF (SELECT COUNT(*) FROM tempRawISO WHERE Shaft_Torque IS NOT NULL AND Shaft_Revolutions IS NOT NULL) > 0 THEN
    
		SET isAvailable = TRUE;
        
    END IF;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`log_msg`(msg1 VARCHAR(255), msg2 VARCHAR(255))
BEGIN
    insert into logt select 0, msg1, msg2;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`normaliseHigherFreq`()
BEGIN

    DECLARE timeStep DOUBLE(20, 3);
    DECLARE minTime INT8(12);
    
    /* Check for higher-frequency secondary parameters */
    
    /* Get primary parameter timestep */
    SET timeStep := (SELECT (SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
		(SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
	SET minTime = (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);
    
    /* Average all secondary parameters to this value */
    DROP TABLE IF EXISTS tempRawISO1;
    CREATE TABLE tempRawISO1 LIKE tempRawISO;
    
    INSERT INTO tempRawISO1 (DateTime_UTC, IMO_Vessel_Number, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement) 
    SELECT (DateTime_UTC), IMO_Vessel_Number, AVG(Relative_Wind_Speed), AVG(Relative_Wind_Direction), AVG(Speed_Over_Ground), AVG(Ship_Heading), AVG(Shaft_Revolutions), AVG(Static_Draught_Fore), AVG(Static_Draught_Aft), AVG(Water_Depth), AVG(Rudder_Angle), AVG(Seawater_Temperature), AVG(Air_Temperature), AVG(Air_Pressure), AVG(Air_Density), AVG(Speed_Through_Water), AVG(Delivered_Power), AVG(Shaft_Power), AVG(Brake_Power), AVG(Shaft_Torque), AVG(Mass_Consumed_Fuel_Oil), AVG(Volume_Consumed_Fuel_Oil), AVG(Displacement)
		FROM tempRawISO
			GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - minTime) / timeStep);
    
    DROP TABLE tempRawISO;
    RENAME TABLE tempRawISO1 TO tempRawISO;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`normaliseLowerFreq`()
BEGIN
	
    DECLARE timeStep DOUBLE(20, 3);
    
    /* Check for higher-frequency secondary parameters */
    
    /* Get primary parameter timestep */
    
    /* Average all secondary parameters to this value */
    UPDATE tempRawISO AS t1
		INNER JOIN
			(SELECT id, IMO_Vessel_Number, DateTime_UTC, Speed_Over_Ground, @lastb := IFNULL(Relative_Wind_Speed, @lastb) AS Relative_Wind_Speed, @lastc := IFNULL(Relative_Wind_Direction, @lastc) AS Relative_Wind_Direction, @laste := IFNULL(Ship_Heading, @laste) AS Ship_Heading, @lastf := IFNULL(Shaft_Revolutions, @lastf) AS Shaft_Revolutions, @lastg := IFNULL(Static_Draught_Fore, @lastg) AS Static_Draught_Fore, @lasth := IFNULL(Static_Draught_Aft, @lasth) AS Static_Draught_Aft, @lasti := IFNULL(Water_Depth, @lasti) AS Water_Depth, @lastj := IFNULL(Rudder_Angle, @lastj) AS Rudder_Angle, @lastk := IFNULL(Seawater_Temperature, @lastk) AS Seawater_Temperature, @lastl := IFNULL(Air_Temperature, @lastl) AS Air_Temperature, @lastm := IFNULL(Air_Pressure, @lastm) AS Air_Pressure, @lastn := IFNULL(Air_Density, @lastn) AS Air_Density, @lasto := IFNULL(Speed_Through_Water, @lasto) AS Speed_Through_Water, @lastq := IFNULL(Shaft_Power, @lastq) AS Shaft_Power, @lastr := IFNULL(Brake_Power, @lastr) AS Brake_Power, @lasts := IFNULL(Shaft_Torque, @lasts) AS Shaft_Torque, @lastt := IFNULL(Mass_Consumed_Fuel_Oil, @lastt) AS Mass_Consumed_Fuel_Oil, @lastu := IFNULL(Volume_Consumed_Fuel_Oil, @lastu) AS Volume_Consumed_Fuel_Oil, @lastdd := IFNULL(Displacement, @lastdd) AS Displacement
				FROM (SELECT id, IMO_Vessel_Number, DateTime_UTC, Speed_Over_Ground, Relative_Wind_Speed, Relative_Wind_Direction, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement FROM tempRawISO) AS q
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
			(SELECT IMO_Vessel_Number, DateTime_UTC, Speed_Over_Ground, @lastb := IFNULL(Relative_Wind_Speed, @lastb) AS Relative_Wind_Speed, @lastc := IFNULL(Relative_Wind_Direction, @lastc) AS Relative_Wind_Direction, @laste := IFNULL(Ship_Heading, @laste) AS Ship_Heading, @lastf := IFNULL(Shaft_Revolutions, @lastf) AS Shaft_Revolutions, @lastg := IFNULL(Static_Draught_Fore, @lastg) AS Static_Draught_Fore, @lasth := IFNULL(Static_Draught_Aft, @lasth) AS Static_Draught_Aft, @lasti := IFNULL(Water_Depth, @lasti) AS Water_Depth, @lastj := IFNULL(Rudder_Angle, @lastj) AS Rudder_Angle, @lastk := IFNULL(Seawater_Temperature, @lastk) AS Seawater_Temperature, @lastl := IFNULL(Air_Temperature, @lastl) AS Air_Temperature, @lastm := IFNULL(Air_Pressure, @lastm) AS Air_Pressure, @lastn := IFNULL(Air_Density, @lastn) AS Air_Density, @lasto := IFNULL(Speed_Through_Water, @lasto) AS Speed_Through_Water, @lastp := IFNULL(Delivered_Power, @lastp) AS Delivered_Power, @lastq := IFNULL(Shaft_Power, @lastq) AS Shaft_Power, @lastr := IFNULL(Brake_Power, @lastr) AS Brake_Power, @lasts := IFNULL(Shaft_Torque, @lasts) AS Shaft_Torque, @lastt := IFNULL(Mass_Consumed_Fuel_Oil, @lastt) AS Mass_Consumed_Fuel_Oil, @lastu := IFNULL(Volume_Consumed_Fuel_Oil, @lastu) AS Volume_Consumed_Fuel_Oil, @lastv := IFNULL(Lower_Caloirifc_Value_Fuel_Oil, @lastv) AS Lower_Caloirifc_Value_Fuel_Oil, @lastw := IFNULL(Normalised_Energy_Consumption, @lastw) AS Normalised_Energy_Consumption, @lastx := IFNULL(Density_Fuel_Oil_15C, @lastx) AS Density_Fuel_Oil_15C, @lasty := IFNULL(Density_Change_Rate_Per_C, @lasty) AS Density_Change_Rate_Per_C, @lastz := IFNULL(Temp_Fuel_Oil_At_Flow_Meter, @lastz) AS Temp_Fuel_Oil_At_Flow_Meter, @lastaa := IFNULL(Wind_Resistance_Relative, @lastaa) AS Wind_Resistance_Relative, @lastbb := IFNULL(Air_Resistance_No_Wind, @lastbb) AS Air_Resistance_No_Wind, @lastcc := IFNULL(Expected_Speed_Through_Water, @lastcc) AS Expected_Speed_Through_Water, @lastdd := IFNULL(Displacement, @lastdd) AS Displacement, @lastee := IFNULL(Speed_Loss, @lastee) AS Speed_Loss, @lastff := IFNULL(Transverse_Projected_Area_Current, @lastff) AS Transverse_Projected_Area_Current, @lastgg := IFNULL(Wind_Resistance_Correction, @lastgg) AS Wind_Resistance_Correction, @lasthh := IFNULL(Corrected_Power, @lasthh) AS Corrected_Power, @lastii := IFNULL(Filter_SpeedPower_Disp_Trim, @lastii) AS Filter_SpeedPower_Disp_Trim, @lastjj := IFNULL(Filter_SpeedPower_Trim, @lastjj) AS Filter_SpeedPower_Trim, @lastkk := IFNULL(Filter_SpeedPower_Disp, @lastkk) AS Filter_SpeedPower_Disp, @lastll := IFNULL(Filter_SpeedPower_Below, @lastll) AS Filter_SpeedPower_Below, @lastmm := IFNULL(NearestDisplacement, @lastmm) AS NearestDisplacement, @lastnn := IFNULL(NearestTrim, @lastnn) AS NearestTrim, @lastoo := IFNULL(Trim, @lastoo) AS Trim
				FROM (SELECT IMO_Vessel_Number, DateTime_UTC, Speed_Over_Ground, Relative_Wind_Speed, Relative_Wind_Direction, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Lower_Caloirifc_Value_Fuel_Oil, Normalised_Energy_Consumption, Density_Fuel_Oil_15C, Density_Change_Rate_Per_C, Temp_Fuel_Oil_At_Flow_Meter, Wind_Resistance_Relative, Air_Resistance_No_Wind, Expected_Speed_Through_Water, Displacement, Speed_Loss, Transverse_Projected_Area_Current, Wind_Resistance_Correction, Corrected_Power, Filter_SpeedPower_Disp_Trim, Filter_SpeedPower_Trim, Filter_SpeedPower_Disp, Filter_SpeedPower_Below, NearestDisplacement, NearestTrim, Trim FROM tempRawISO) AS q
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`removeFOCBelowMinimum`(imo INT)
BEGIN
    
    DECLARE FOCmin DOUBLE(10, 3);
    DECLARE HoursPerTimeStep DOUBLE(10, 3) DEFAULT 24;
    
    CALL log_msg('removeFOCBelowMinimum', 'starting');
    
    SET FOCmin = (SELECT Minimum_FOC_ph FROM SFOCCoefficients WHERE Engine_Model = (SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO)) * HoursPerTimeStep;
    /* DELETE FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil < FOCmin; */
    UPDATE tempRawISO SET Filter_SFOC_Out_Range = TRUE WHERE Mass_Consumed_Fuel_Oil < FOCmin;
	
    CALL log_msg('removeFOCBelowMinimum', 'ending');
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`removeInvalidRecords`()
BEGIN

	DELETE FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil <= 0;
    
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`removeNullRows`()
BEGIN

	DELETE FROM tempraw WHERE Date_UTC IS NULL OR Time_UTC IS NULL;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`sortOnDateTime`()
BEGIN

	ALTER TABLE tempRawISO ORDER BY DateTime_UTC ASC;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateAirDensity`()
BEGIN

	UPDATE tempRawISO SET Air_Density = (Air_Pressure / ( (Air_Temperature + 273.15) * (SELECT Specific_Gas_Constant_Air FROM GlobalConstants) ) );

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateAirResistanceNoWind`(imo INT)
BEGIN

	UPDATE tempRawISO
	SET Air_Resistance_No_Wind = 
		0.5 * 
		Air_Density * 
		POWER(Speed_Over_Ground, 2) *
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO_Vessel_Number = imo AND 0 BETWEEN Start_Direction AND End_Direction);
        
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateBrakePower`(IMO INT)
BEGIN
	
    /* Declare variables */
    DECLARE X0 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X1 DOUBLE(20, 10) DEFAULT 0;
    DECLARE X2 DOUBLE(20, 10) DEFAULT 0;
    
    /* Get coefficients of SFOC reference curve for engine of this vessel */
    SELECT SFOCCoefficients.X0 INTO X0 FROM SFOCCoefficients
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO);
    SELECT SFOCCoefficients.X1 INTO X1 FROM SFOCCoefficients
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO);
    SELECT SFOCCoefficients.X2 INTO X2 FROM SFOCCoefficients
			WHERE Engine_Model = 
				(SELECT Engine_Model FROM Vessels WHERE IMO_Vessel_Number = IMO);
    
    /* Perform calculation of Brake Power */
    UPDATE tempRawISO SET Brake_Power = 
										X0
									  + X1 * ( (Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil) / (42.7 * 24) )
									  + X2 * POWER(Mass_Consumed_Fuel_Oil*Lower_Caloirifc_Value_Fuel_Oil / (42.7 * 24), 2)
    ;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateChauvenetCriteria`()
BEGIN
	
    /* Declare constants */
    DECLARE a1 DOUBLE (10, 9);
    DECLARE a2 DOUBLE (10, 9);
    DECLARE a3 DOUBLE (10, 9);
    DECLARE a4 DOUBLE (10, 9);
    DECLARE a5 DOUBLE (10, 9);
    DECLARE p DOUBLE (10, 9);
    DECLARE startTime INT(12);
    
    set @a1 := 0.254829592;
	set @a2 := -0.284496736;
	set @a3 := 1.421413741;
	set @a4 := -1.453152027;
	set @a5 := 1.061405429;
	set @p  := 0.3275911;
    
    SET @startTime := (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);
    
    /* Update Chauvenet_Criteria field */
	CALL createTempChauvenetFilter();
    INSERT INTO ChauvenetTempFilter (id) (SELECT id FROM tempRawISO);
    UPDATE ChauvenetTempFilter AS t7
		INNER JOIN
			(SELECT t6.id, /* (IFNULL(ChauvFilt_Speed_Through_Water, FALSE) OR IFNULL(ChauvFilt_Delivered_Power, FALSE) OR IFNULL(ChauvFilt_Shaft_Revolutions, FALSE) OR IFNULL(ChauvFilt_Relative_Wind_Speed, FALSE) OR IFNULL(ChauvFilt_Relative_Wind_Direction, FALSE) OR IFNULL(ChauvFilt_Speed_Over_Ground, FALSE) OR IFNULL(ChauvFilt_Ship_Heading, FALSE) OR IFNULL(ChauvFilt_Rudder_Angle, FALSE) OR IFNULL(ChauvFilt_Water_Depth, FALSE) OR IFNULL(ChauvFilt_Seawater_Temperature, FALSE)) */ 
					ChauvFilt_Speed_Through_Water , ChauvFilt_Delivered_Power , ChauvFilt_Shaft_Revolutions , ChauvFilt_Relative_Wind_Speed , ChauvFilt_Relative_Wind_Direction , ChauvFilt_Speed_Over_Ground , ChauvFilt_Ship_Heading , ChauvFilt_Rudder_Angle , ChauvFilt_Water_Depth , ChauvFilt_Seawater_Temperature /* AS Chauvenet_Criteria */
				FROM (SELECT t5.id,
							CASE x_Speed_Through_Water >= 0
								WHEN TRUE THEN (@a1*t_Speed_Through_Water + @a2*POWER(t_Speed_Through_Water, 2) + @a3*POWER(t_Speed_Through_Water, 3) + @a4*POWER(t_Speed_Through_Water, 4) + @a5*POWER(t_Speed_Through_Water, 5))*exp(-POWER(x_Speed_Through_Water, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Speed_Through_Water + @a2*POWER(t_Speed_Through_Water, -2) + @a3*POWER(t_Speed_Through_Water, -3) + @a4*POWER(t_Speed_Through_Water, -4) + @a5*POWER(t_Speed_Through_Water, -5))*exp(-POWER(x_Speed_Through_Water, 2))) * N  < 0.5                        
							END AS ChauvFilt_Speed_Through_Water,
                            CASE x_Delivered_Power >= 0
								WHEN TRUE THEN (@a1*t_Delivered_Power + @a2*POWER(t_Delivered_Power, 2) + @a3*POWER(t_Delivered_Power, 3) + @a4*POWER(t_Delivered_Power, 4) + @a5*POWER(t_Delivered_Power, 5))*exp(-POWER(x_Delivered_Power, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Delivered_Power + @a2*POWER(t_Delivered_Power, -2) + @a3*POWER(t_Delivered_Power, -3) + @a4*POWER(t_Delivered_Power, -4) + @a5*POWER(t_Delivered_Power, -5))*exp(-POWER(x_Delivered_Power, 2))) * N  < 0.5
							END AS ChauvFilt_Delivered_Power,
                            CASE x_Shaft_Revolutions >= 0
								WHEN TRUE THEN (@a1*t_Shaft_Revolutions + @a2*POWER(t_Shaft_Revolutions, 2) + @a3*POWER(t_Shaft_Revolutions, 3) + @a4*POWER(t_Shaft_Revolutions, 4) + @a5*POWER(t_Shaft_Revolutions, 5))*exp(-POWER(x_Shaft_Revolutions, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Shaft_Revolutions + @a2*POWER(t_Shaft_Revolutions, -2) + @a3*POWER(t_Shaft_Revolutions, -3) + @a4*POWER(t_Shaft_Revolutions, -4) + @a5*POWER(t_Shaft_Revolutions, -5))*exp(-POWER(x_Shaft_Revolutions, 2))) * N  < 0.5
							END AS ChauvFilt_Shaft_Revolutions,
                            CASE x_Relative_Wind_Speed >= 0
								WHEN TRUE THEN (@a1*t_Relative_Wind_Speed + @a2*POWER(t_Relative_Wind_Speed, 2) + @a3*POWER(t_Relative_Wind_Speed, 3) + @a4*POWER(t_Relative_Wind_Speed, 4) + @a5*POWER(t_Relative_Wind_Speed, 5))*exp(-POWER(x_Relative_Wind_Speed, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Relative_Wind_Speed + @a2*POWER(t_Relative_Wind_Speed, -2) + @a3*POWER(t_Relative_Wind_Speed, -3) + @a4*POWER(t_Relative_Wind_Speed, -4) + @a5*POWER(t_Relative_Wind_Speed, -5))*exp(-POWER(x_Relative_Wind_Speed, 2))) * N  < 0.5
							END AS ChauvFilt_Relative_Wind_Speed,
                            CASE x_Relative_Wind_Direction >= 0
								WHEN TRUE THEN (@a1*t_Relative_Wind_Direction + @a2*POWER(t_Relative_Wind_Direction, 2) + @a3*POWER(t_Relative_Wind_Direction, 3) + @a4*POWER(t_Relative_Wind_Direction, 4) + @a5*POWER(t_Relative_Wind_Direction, 5))*exp(-POWER(x_Relative_Wind_Direction, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Relative_Wind_Direction + @a2*POWER(t_Relative_Wind_Direction, -2) + @a3*POWER(t_Relative_Wind_Direction, -3) + @a4*POWER(t_Relative_Wind_Direction, -4) + @a5*POWER(t_Relative_Wind_Direction, -5))*exp(-POWER(x_Relative_Wind_Direction, 2))) * N  < 0.5
							END AS ChauvFilt_Relative_Wind_Direction,
                            CASE x_Speed_Over_Ground >= 0
								WHEN TRUE THEN (@a1*t_Speed_Over_Ground + @a2*POWER(t_Speed_Over_Ground, 2) + @a3*POWER(t_Speed_Over_Ground, 3) + @a4*POWER(t_Speed_Over_Ground, 4) + @a5*POWER(t_Speed_Over_Ground, 5))*exp(-POWER(x_Speed_Over_Ground, 2)) * N < 0.5
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Speed_Over_Ground + @a2*POWER(t_Speed_Over_Ground, -2) + @a3*POWER(t_Speed_Over_Ground, -3) + @a4*POWER(t_Speed_Over_Ground, -4) + @a5*POWER(t_Speed_Over_Ground, -5))*exp(-POWER(x_Speed_Over_Ground, 2))) * N  < 0.5
							END AS ChauvFilt_Speed_Over_Ground,
                            CASE x_Ship_Heading >= 0
								WHEN TRUE THEN (@a1*t_Ship_Heading + @a2*POWER(t_Ship_Heading, 2) + @a3*POWER(t_Ship_Heading, 3) + @a4*POWER(t_Ship_Heading, 4) + @a5*POWER(t_Ship_Heading, 5))*exp(-POWER(x_Ship_Heading, 2)) * N < 0.5                                                                              
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Ship_Heading + @a2*POWER(t_Ship_Heading, -2) + @a3*POWER(t_Ship_Heading, -3) + @a4*POWER(t_Ship_Heading, -4) + @a5*POWER(t_Ship_Heading, -5))*exp(-POWER(x_Ship_Heading, 2))) * N  < 0.5
							END AS ChauvFilt_Ship_Heading,
                            CASE x_Rudder_Angle >= 0
								WHEN TRUE THEN (@a1*t_Rudder_Angle + @a2*POWER(t_Rudder_Angle, 2) + @a3*POWER(t_Rudder_Angle, 3) + @a4*POWER(t_Rudder_Angle, 4) + @a5*POWER(t_Rudder_Angle, 5))*exp(-POWER(x_Rudder_Angle, 2)) * N < 0.5                                                                              
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Rudder_Angle + @a2*POWER(t_Rudder_Angle, -2) + @a3*POWER(t_Rudder_Angle, -3) + @a4*POWER(t_Rudder_Angle, -4) + @a5*POWER(t_Rudder_Angle, -5))*exp(-POWER(x_Rudder_Angle, 2))) * N  < 0.5
							END AS ChauvFilt_Rudder_Angle,
                            CASE x_Water_Depth >= 0
								WHEN TRUE THEN (@a1*t_Water_Depth + @a2*POWER(t_Water_Depth, 2) + @a3*POWER(t_Water_Depth, 3) + @a4*POWER(t_Water_Depth, 4) + @a5*POWER(t_Water_Depth, 5))*exp(-POWER(x_Water_Depth, 2)) * N < 0.5                                                                                                                                                                  
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Water_Depth + @a2*POWER(t_Water_Depth, -2) + @a3*POWER(t_Water_Depth, -3) + @a4*POWER(t_Water_Depth, -4) + @a5*POWER(t_Water_Depth, -5))*exp(-POWER(x_Water_Depth, 2))) * N  < 0.5
							END AS ChauvFilt_Water_Depth,
                            CASE x_Seawater_Temperature >= 0
								WHEN TRUE THEN (@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, 2) + @a3*POWER(t_Seawater_Temperature, 3) + @a4*POWER(t_Seawater_Temperature, 4) + @a5*POWER(t_Seawater_Temperature, 5))*exp(-POWER(x_Seawater_Temperature, 2)) * N < 0.5                                                                                                                                                                   
                                WHEN FALSE THEN ( 2 - ABS(@a1*t_Seawater_Temperature + @a2*POWER(t_Seawater_Temperature, -2) + @a3*POWER(t_Seawater_Temperature, -3) + @a4*POWER(t_Seawater_Temperature, -4) + @a5*POWER(t_Seawater_Temperature, -5))*exp(-POWER(x_Seawater_Temperature, 2))) * N  < 0.5
							END AS ChauvFilt_Seawater_Temperature
					FROM
						(SELECT t4.id,
							N,
							ABS(Speed_Through_Water - Avg_Speed_Through_Water) / (Std_Speed_Through_Water - SQRT(2)) AS x_Speed_Through_Water,
							ABS(Delivered_Power - Avg_Delivered_Power) / (Std_Delivered_Power - SQRT(2)) AS x_Delivered_Power,
							ABS(Shaft_Revolutions - Avg_Shaft_Revolutions) / (Std_Shaft_Revolutions - SQRT(2)) AS x_Shaft_Revolutions,
							ABS(Relative_Wind_Speed - Avg_Relative_Wind_Speed) / (Std_Relative_Wind_Speed - SQRT(2)) AS x_Relative_Wind_Speed,
							ABS(Relative_Wind_Direction - Avg_Relative_Wind_Direction) / (Std_Relative_Wind_Direction - SQRT(2)) AS x_Relative_Wind_Direction,
							ABS(Speed_Over_Ground - Avg_Speed_Over_Ground) / (Std_Speed_Over_Ground - SQRT(2)) AS x_Speed_Over_Ground,
							ABS(Ship_Heading - Avg_Ship_Heading) / (Std_Ship_Heading - SQRT(2)) AS x_Ship_Heading,
							ABS(Rudder_Angle - Avg_Rudder_Angle) / (Std_Rudder_Angle - SQRT(2)) AS x_Rudder_Angle,
							ABS(Water_Depth - Avg_Water_Depth) / (Std_Water_Depth - SQRT(2)) AS x_Water_Depth,
							ABS(Seawater_Temperature - Avg_Seawater_Temperature) / (Std_Seawater_Temperature - SQRT(2)) AS x_Seawater_Temperature,
							1 / (1 + @p* (ABS(Speed_Through_Water - Avg_Speed_Through_Water)) / (Std_Speed_Through_Water - SQRT(2)) ) AS t_Speed_Through_Water,
							1 / (1 + @p* (ABS(Delivered_Power - Avg_Delivered_Power)) / (Std_Delivered_Power - SQRT(2)) ) AS t_Delivered_Power,
							1 / (1 + @p* (ABS(Shaft_Revolutions - Avg_Shaft_Revolutions)) / (Std_Shaft_Revolutions - SQRT(2)) ) AS t_Shaft_Revolutions,
							1 / (1 + @p* (ABS(Relative_Wind_Speed - Avg_Relative_Wind_Speed)) / (Std_Relative_Wind_Speed - SQRT(2)) ) AS t_Relative_Wind_Speed,
							1 / (1 + @p* (ABS(Relative_Wind_Direction - Avg_Relative_Wind_Direction)) / (Std_Relative_Wind_Direction - SQRT(2)) ) AS t_Relative_Wind_Direction,
							1 / (1 + @p* (ABS(Speed_Over_Ground - Avg_Speed_Over_Ground)) / (Std_Speed_Over_Ground - SQRT(2)) ) AS t_Speed_Over_Ground,
							1 / (1 + @p* (ABS(Ship_Heading - Avg_Ship_Heading)) / (Std_Ship_Heading - SQRT(2)) ) AS t_Ship_Heading,
							1 / (1 + @p* (ABS(Rudder_Angle - Avg_Rudder_Angle)) / (Std_Rudder_Angle - SQRT(2)) ) AS t_Rudder_Angle,
							1 / (1 + @p* (ABS(Water_Depth - Avg_Water_Depth)) / (Std_Water_Depth - SQRT(2)) ) AS t_Water_Depth,
							1 / (1 + @p* (ABS(Seawater_Temperature - Avg_Seawater_Temperature)) / (Std_Seawater_Temperature - SQRT(2)) ) AS t_Seawater_Temperature
						FROM
							(SELECT t3.id,
									Speed_Through_Water,
									Delivered_Power,
									Shaft_Revolutions,
									Relative_Wind_Speed,
									Relative_Wind_Direction,
									Speed_Over_Ground,
									Ship_Heading,
									Rudder_Angle,
									Water_Depth,
									Seawater_Temperature,
									@lasta := IFNULL(Avg_Speed_Through_Water, @lasta) AS Avg_Speed_Through_Water,        
									@lastb := IFNULL(Avg_Delivered_Power, @lastb) AS Avg_Delivered_Power,                
									@lastc := IFNULL(Avg_Shaft_Revolutions, @lastc) AS Avg_Shaft_Revolutions,            
									@lastd := IFNULL(Avg_Relative_Wind_Speed, @lastd) AS Avg_Relative_Wind_Speed,        
									@laste := IFNULL(Avg_Relative_Wind_Direction, @laste) AS Avg_Relative_Wind_Direction,
									@lastf := IFNULL(Avg_Speed_Over_Ground, @lastf) AS Avg_Speed_Over_Ground,            
									@lastg := IFNULL(Avg_Ship_Heading, @lastg) AS Avg_Ship_Heading,                       
									@lasth := IFNULL(Avg_Rudder_Angle, @lasth) AS Avg_Rudder_Angle,                      
									@lasti := IFNULL(Avg_Water_Depth, @lasti) AS Avg_Water_Depth,                        
									@lastj := IFNULL(Avg_Seawater_Temperature, @lastj) AS Avg_Seawater_Temperature,      
									@lastk := IFNULL(Std_Speed_Through_Water, @lastk) AS Std_Speed_Through_Water,        
									@lastl := IFNULL(Std_Delivered_Power, @lastl) AS Std_Delivered_Power,                
									@lastm := IFNULL(Std_Shaft_Revolutions, @lastm) AS Std_Shaft_Revolutions,            
									@lastn := IFNULL(Std_Relative_Wind_Speed, @lastn) AS Std_Relative_Wind_Speed,        
									@lasto := IFNULL(Std_Relative_Wind_Direction, @lasto) AS Std_Relative_Wind_Direction,
									@lastp := IFNULL(Std_Speed_Over_Ground, @lastp) AS Std_Speed_Over_Ground,            
									@lastq := IFNULL(Std_Ship_Heading, @lastq) AS Std_Ship_Heading,                      
									@lastr := IFNULL(Std_Rudder_Angle, @lastr) AS Std_Rudder_Angle,                      
									@lasts := IFNULL(Std_Water_Depth, @lasts) AS Std_Water_Depth,                        
									@lastt := IFNULL(Std_Seawater_Temperature, @lastt) AS Std_Seawater_Temperature,     
                                    @lastv := IFNULL(N, @lastv) AS N
							FROM
								(SELECT
									t1.id,
									N,
									Speed_Through_Water,
									Delivered_Power,
									Shaft_Revolutions,
									Relative_Wind_Speed,
									Relative_Wind_Direction,
									Speed_Over_Ground,
									Ship_Heading,
									Rudder_Angle,
									Water_Depth,
									Seawater_Temperature,
									Avg_Speed_Through_Water,
									Avg_Delivered_Power,
									Avg_Shaft_Revolutions,
									Avg_Relative_Wind_Speed,
									Avg_Relative_Wind_Direction,
									Avg_Speed_Over_Ground,
									Avg_Ship_Heading,
									Avg_Water_Depth,
									Avg_Seawater_Temperature,
                                    Avg_Rudder_Angle,
									Std_Speed_Through_Water,
									Std_Delivered_Power,
									Std_Shaft_Revolutions,
									Std_Relative_Wind_Speed,
									Std_Relative_Wind_Direction,
									Std_Speed_Over_Ground,
									Std_Ship_Heading,
									Std_Water_Depth,
									Std_Seawater_Temperature,
                                    Std_Rudder_Angle
										FROM tempRawISO t1
											LEFT JOIN (SELECT id, DateTime_UTC, t33.IMO_Vessel_Number, COUNT(*) AS N,
												AVG(Speed_Through_Water) AS  Avg_Speed_Through_Water,        
												AVG(Delivered_Power) AS  Avg_Delivered_Power,                
												AVG(Shaft_Revolutions) AS  Avg_Shaft_Revolutions,            
												AVG(Relative_Wind_Speed) AS  Avg_Relative_Wind_Speed,        
												AVG(Relative_Wind_Direction) AS  Avg_Relative_Wind_Direction,
												AVG(Speed_Over_Ground) AS  Avg_Speed_Over_Ground,            
												AVG(Ship_Heading) AS  Avg_Ship_Heading,                      
												AVG(Water_Depth) AS  Avg_Water_Depth,                        
												AVG(Seawater_Temperature) AS  Avg_Seawater_Temperature,
                                                mu_Rudder_Angle AS Avg_Rudder_Angle,
                                                mu_Relative_Wind_Direction AS mu_Relative_Wind_Direction,
												STD(Speed_Through_Water) AS  Std_Speed_Through_Water,        
												STD(Delivered_Power) AS  Std_Delivered_Power,                
												STD(Shaft_Revolutions) AS  Std_Shaft_Revolutions,            
												STD(Relative_Wind_Speed) AS  Std_Relative_Wind_Speed,        
												STD(Speed_Over_Ground) AS  Std_Speed_Over_Ground,            
												STD(Ship_Heading) AS  Std_Ship_Heading,                        
												STD(Water_Depth) AS  Std_Water_Depth,                        
												STD(Seawater_Temperature) AS  Std_Seawater_Temperature,
												SQRT(AVG(POWER(Delta_Rudder_Angle, 2))) AS Std_Rudder_Angle,
												SQRT(AVG(POWER(Delta_Relative_Wind_Direction, 2))) AS Std_Relative_Wind_Direction
													FROM (SELECT
																t32.id,
                                                                t32.IMO_Vessel_Number,
																t32.DateTime_UTC,
																Speed_Through_Water,
																Delivered_Power,
																Shaft_Revolutions,
																Relative_Wind_Speed,
																Relative_Wind_Direction,
																Speed_Over_Ground,
																Ship_Heading,
																Water_Depth,
																Seawater_Temperature,
                                                                mu_Rudder_Angle,
                                                                mu_Relative_Wind_Direction,
																CASE mod(ABS(t32.Rudder_Angle - mu_Rudder_Angle), 360) > 180
																	WHEN TRUE THEN 360 - mod(ABS(t32.Rudder_Angle - mu_Rudder_Angle), 360)
																	WHEN FALSE THEN mod(ABS(t32.Rudder_Angle - mu_Rudder_Angle), 360)
																END AS Delta_Rudder_Angle,
																CASE mod(ABS(t32.Relative_Wind_Direction - mu_Relative_Wind_Direction), 360) > 180
																	WHEN TRUE THEN 360 - mod(ABS(t32.Relative_Wind_Direction - mu_Relative_Wind_Direction), 360)
																	WHEN FALSE THEN mod(ABS(t32.Relative_Wind_Direction - mu_Relative_Wind_Direction), 360)
																END AS Delta_Relative_Wind_Direction
															FROM
																(SELECT t31.id,
																	t31.IMO_Vessel_Number,
                                                                    t31.DateTime_UTC,
																	t31.Rudder_Angle,
																	Speed_Through_Water,
																	Delivered_Power,
																	Shaft_Revolutions,
																	Relative_Wind_Speed,
																	Relative_Wind_Direction,
																	Speed_Over_Ground,
																	Ship_Heading,
																	Water_Depth,
																	Seawater_Temperature,
																	@lastw := IFNULL(mu_Rudder_Angle, @lastw) AS mu_Rudder_Angle,
																	@lastx := IFNULL(mu_Relative_Wind_Direction, @lastx) AS mu_Relative_Wind_Direction
																	FROM
																		(SELECT id,
																			IMO_Vessel_Number,
																			DateTime_UTC,
																			 ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS mu_Rudder_Angle,
																			 ATAN2(AVG(SIN(Relative_Wind_Direction)), AVG(COS(Relative_Wind_Direction))) AS mu_Relative_Wind_Direction
																		FROM tempRawISO
																			GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t30
																		RIGHT JOIN tempRawISO t31
																			ON t30.id = t31.id
																				CROSS JOIN (SELECT @lastw := 0) AS var_w) t32) t33
														GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t2
											ON t1.id = t2.id) t3
											CROSS JOIN (SELECT @lasta := 0) AS var_a
											CROSS JOIN (SELECT @lastb := 0) AS var_b
											CROSS JOIN (SELECT @lastd := 0) AS var_d
											CROSS JOIN (SELECT @lastf := 0) AS var_f
											CROSS JOIN (SELECT @lasth := 0) AS var_h
											CROSS JOIN (SELECT @lastj := 0) AS var_j
											CROSS JOIN (SELECT @lastl := 0) AS var_l
											CROSS JOIN (SELECT @lastn := 0) AS var_n
											CROSS JOIN (SELECT @lastp := 0) AS var_p
											CROSS JOIN (SELECT @lastr := 0) AS var_r
											CROSS JOIN (SELECT @lastt := 0) AS var_t
											CROSS JOIN (SELECT @lastc := 0) AS var_c
											CROSS JOIN (SELECT @laste := 0) AS var_e
											CROSS JOIN (SELECT @lastg := 0) AS var_g
											CROSS JOIN (SELECT @lasti := 0) AS var_i
											CROSS JOIN (SELECT @lastk := 0) AS var_k
											CROSS JOIN (SELECT @lastm := 0) AS var_m
											CROSS JOIN (SELECT @lasto := 0) AS var_o
											CROSS JOIN (SELECT @lastq := 0) AS var_q
											CROSS JOIN (SELECT @lasts := 0) AS var_s
											CROSS JOIN (SELECT @lastu := 0) AS var_u
											CROSS JOIN (SELECT @lastv := 0) AS var_v) t4) t5) t6) AS t8
												ON t7.id = t8.id
													SET t7.Speed_Through_Water = t8.ChauvFilt_Speed_Through_Water,
													    t7.Delivered_Power = t8.ChauvFilt_Delivered_Power,
													    t7.Shaft_Revolutions = t8.ChauvFilt_Shaft_Revolutions,
													    t7.Relative_Wind_Speed = t8.ChauvFilt_Relative_Wind_Speed,
													    t7.Relative_Wind_Direction = t8.ChauvFilt_Relative_Wind_Direction,
													    t7.Speed_Over_Ground = t8.ChauvFilt_Speed_Over_Ground,
													    t7.Shaft_Revolutions = t8.ChauvFilt_Shaft_Revolutions,
													    t7.Ship_Heading = t8.ChauvFilt_Ship_Heading,
													    t7.Rudder_Angle = t8.ChauvFilt_Rudder_Angle,
													    t7.Water_Depth = t8.ChauvFilt_Water_Depth,
													    t7.Seawater_Temperature = t8.ChauvFilt_Seawater_Temperature
                                                        ;
    
	UPDATE temprawiso t
		JOIN ChauvenetTempFilter c
			ON t.id = c.id
				SET t.Chauvenet_Criteria = 
                (IFNULL(c.Speed_Through_Water, FALSE) OR IFNULL(c.Delivered_Power, FALSE) OR IFNULL(c.Shaft_Revolutions, FALSE) OR IFNULL(c.Relative_Wind_Speed, FALSE) OR
                IFNULL(c.Relative_Wind_Direction, FALSE) OR IFNULL(c.Speed_Over_Ground, FALSE) OR IFNULL(c.Ship_Heading, FALSE) OR IFNULL(c.Rudder_Angle, FALSE) OR
                IFNULL(c.Water_Depth, FALSE) OR IFNULL(c.Seawater_Temperature, FALSE));
                
    /* Mark analysis as Chauvenet Filtered */
    SET @timeStep := (SELECT (SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
		(SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
	IF @timeStep < 600 THEN
		SET @ChauvenetFiltered := TRUE;
	ELSE
		SET @ChauvenetFiltered := FALSE;
	END IF;
    
    CALL IMOStartEnd(@imo, @startd, @endd);
    IF @imo IS NOT NULL AND @startd IS NOT NULL AND @endd IS NOT NULL THEN
		INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, ChauvenetFiltered)
		VALUES (@imo, @startd, @endd, @ChauvenetFiltered) ON DUPLICATE KEY UPDATE ChauvenetFiltered = VALUES(ChauvenetFiltered);
    END IF;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateCorrectedPower`()
BEGIN
    
    DECLARE WindResValid BOOLEAN;
    SET WindResValid := (SELECT COUNT(Wind_Resistance_Correction) FROM tempRawISO) != 0;
    
    IF WindResValid THEN
		UPDATE tempRawISO SET Corrected_Power = Delivered_Power - Wind_Resistance_Correction;
    ELSE
		UPDATE tempRawISO SET Corrected_Power = Delivered_Power;
	END IF;
    
    IF @imo IS NOT NULL AND @startd IS NOT NULL AND @endd IS NOT NULL THEN
		CALL IMOStartEnd(@imo, @startd, @endd);
		INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, WindResistanceApplied) 
		VALUES (@imo, @startd, @endd, WindResValid) ON duplicate key update WindResistanceApplied = values(WindResistanceApplied);
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateDeliveredPower`(imo INT)
BEGIN
	
    /* DECLARATIONS */
    /* DECLARE isAvail BOOLEAN; */
    
    /* Check if torsio-metre data available 
    CALL log_msg(concat('isShaftAvail = ', @isShaftAvail));
		CALL log_msg(concat('UPDATE shaft power called')); */
	DECLARE powerIncalculable CONDITION FOR SQLSTATE '45000';
    
    DECLARE isShaftRequired BOOLEAN Default TRUE;
    SET isShaftRequired := (SELECT COUNT(*) FROM tempRawISO WHERE Shaft_Power IS NOT NULL) = 0;
	
    CALL isShaftPowerAvailable(imo, @isShaftAvail);
    CALL isBrakePowerAvailable(imo, @isBrakeAvail, @isMassNeeded);
    
    IF NOT isShaftRequired THEN
    
		UPDATE tempRawISO SET Delivered_Power = Shaft_Power;
    
    ELSEIF @isShaftAvail THEN
		
        CALL updateShaftPower(imo);
        UPDATE tempRawISO SET Delivered_Power = Shaft_Power;
		
    /* Check if engine data available */
    ELSEIF @isBrakeAvail THEN
		
		IF @isMassNeeded THEN
			CALL updateMassFuelOilConsumed(imo);
        END IF;
		
		CALL updateBrakePower(imo);
        UPDATE tempRawISO SET Delivered_Power = Brake_Power;
		
    /* Error if value cannot be calculated */
    ELSE
		
		SIGNAL powerIncalculable
		  SET MESSAGE_TEXT = 'Delivered Power cannot be calculated without either sufficient inputs for shaft power or brake power';
		
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateDisplacement`(IMO INT)
BEGIN
	
    DECLARE AdjustedTopArea DOUBLE(10, 5);
        
	IF (SELECT Block_Coefficient FROM Vessels WHERE IMO_Vessel_Number = IMO) IS NULL THEN
	
		/* Calculate Displacement based on Hydrostatic Table */
		UPDATE tempRawISO SET Displacement = (SELECT Displacement FROM Displacement WHERE IMO_Vessel_Number = imo AND
																			Draft_Actual_Fore = (SELECT Draft_Actual_Fore FROM tempRawISO) AND
																			Static_Draught_Aft = (SELECT Static_Draught_Aft FROM tempRawISO));
    
    ELSE
    
		/* Calculate Displacement based on Block Coefficient Approximation */
        SET AdjustedTopArea := (SELECT Block_Coefficient*Length_Overall*Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = IMO);
        UPDATE tempRawISO SET Displacement = AdjustedTopArea*( (Static_Draught_Fore + Static_Draught_Aft) / 2);
	
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateExpectedSpeed`(imo INT)
BEGIN
	
    /* Calculate expected speed from fitted speed-power curve
	UPDATE tempRawISO SET Expected_Speed_Through_Water = ((SELECT Exponent_A FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo AND Displacement = 137090) * LOG(Delivered_Power))
														+ (SELECT Exponent_B FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo AND Displacement = 137090); */
    
	/* Calculate expected speed from fitted speed-power curve */ 
    /* UPDATE tempRawISO c
	INNER JOIN (
				SELECT b.Displacement, a.Exponent_A, a.Exponent_B, b.Nearest_In_Speed_Power
					FROM speedpowercoefficients a
						JOIN NearestDisplacement b
							ON a.Displacement = b.Nearest_In_Speed_Power
								WHERE a.IMO_Vessel_Number = imo
				) d
	ON c.Displacement = d.Displacement
	SET c.Expected_Speed_Through_Water = d.Exponent_A*LOG(ABS(c.Delivered_Power)) + d.Exponent_B; */ 
    
    /* Check whether Admiralty formula should be used to correct for displacement */
    UPDATE tempRawISO SET Displacement_Correction_Needed = FALSE;
    UPDATE tempRawISO SET Displacement_Correction_Needed = TRUE WHERE NearestDisplacement > Displacement*1.05 OR NearestDisplacement < Displacement*0.95;
    
    /* Get coefficients of speed, power curve for nearest diplacement, trim */ 
    UPDATE IGNORE tempRawISO ii JOIN
	(SELECT i.id, i.IMO_Vessel_Number, NearestDisplacement, NearestTrim, i.Displacement, i.Trim, s.Exponent_A, s.Exponent_B FROM tempRawISO i
		JOIN speedpowercoefficients s
			ON i.IMO_Vessel_Number = s.IMO_Vessel_Number AND
			   i.NearestDisplacement = s.Displacement AND
			   i.NearestTrim = s.Trim) si
	ON ii.id = si.id
	SET Expected_Speed_Through_Water = Exponent_A*LOG(ABS(Delivered_Power)) + Exponent_B
    WHERE Displacement_Correction_Needed IS FALSE;
    
    /* Get coefficients of speed, power curve for nearest diplacement, trim */ 
    UPDATE IGNORE tempRawISO ii JOIN
	(SELECT i.id, i.IMO_Vessel_Number, NearestDisplacement, NearestTrim, i.Displacement, i.Trim, s.Exponent_A, s.Exponent_B FROM tempRawISO i
		JOIN speedpowercoefficients s
			ON i.IMO_Vessel_Number = s.IMO_Vessel_Number AND
			   i.NearestDisplacement = s.Displacement AND
			   i.NearestTrim = s.Trim) si
	ON ii.id = si.id
	SET Expected_Speed_Through_Water = (Exponent_A*LOG(ABS(Delivered_Power)) + Exponent_B) * POWER( POWER(ii.Displacement, (2/3)) / POWER(ii.NearestDisplacement, (2/3)), (1/3))
    WHERE Displacement_Correction_Needed IS TRUE;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateFromBunkerNote`(imo INT(7))
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateMassFuelOilConsumed`(IMO INT)
BEGIN
	
	UPDATE tempRawISO SET Mass_Consumed_Fuel_Oil = Volume_Consumed_Fuel_Oil * (Density_Fuel_Oil_15C - Density_Change_Rate_Per_C*(Temp_Fuel_Oil_At_Flow_Meter - 15));
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateShaftPower`(IMO INT)
BEGIN
	
	UPDATE tempRawISO SET Shaft_Power = Shaft_Torque * Shaft_Revolutions * (2 * PI() / 60);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateSpeedLoss`()
BEGIN

	UPDATE tempRawISO SET Speed_Loss = (100 * (Speed_Through_Water - Expected_Speed_Through_Water) / Expected_Speed_Through_Water);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateTransProjArea`(imo INT)
BEGIN

	SET @T := (SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO_Vessel_Number = imo);
	SET @D := (SELECT Draft_Design FROM Vessels WHERE IMO_Vessel_Number = imo);
	SET @B := (SELECT Breadth_Moulded FROM Vessels WHERE IMO_Vessel_Number = imo);
	
	UPDATE tempRawISO
	SET Transverse_Projected_Area_Current =  @T + (( @D - (Static_Draught_Fore + Static_Draught_Aft)/2) * @B );
	
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateTrim`()
BEGIN

	UPDATE tempRawISO SET Trim = Static_Draught_Fore - Static_Draught_Aft;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateValidated`()
BEGIN
	
SET @startTime := (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);

UPDATE tempRawISO t7
JOIN
(SELECT t6.id, t6.DateTime_UTC,
			Std_Shaft_Revolutions,
			Std_Speed_Through_Water,
			Std_Speed_Over_Ground,
            @lasth := IFNULL(InvalidR, @lasth) AS InvalidR,
			@lasti := IFNULL(Std_Shaft_Revolutions > 3, @lasti) AS InvalidRPM,
			@lastj := IFNULL(Std_Speed_Through_Water > 0.5, @lastj) AS InvalidSTW,
			@lastk := IFNULL(Std_Speed_Over_Ground > 0.5, @lastk) AS InvalidSOG
	FROM tempRawISO t6
	LEFT JOIN
	(SELECT id, DateTime_UTC, 
			SQRT(AVG(POWER(Delta_Rudder_Angle, 2))) AS Std_Rudder_Angle,
            Delta_Rudder_Angle,
			Std_Shaft_Revolutions,
			Std_Speed_Through_Water,
			Std_Speed_Over_Ground,
            @lasth := IFNULL(SQRT(AVG(POWER(Delta_Rudder_Angle, 2))) > 1, @lasth) AS InvalidR,
			@lasti := IFNULL(Std_Shaft_Revolutions > 3, @lasti) AS InvalidRPM,
			@lastj := IFNULL(Std_Speed_Through_Water > 0.5, @lastj) AS InvalidSTW,
			@lastk := IFNULL(Std_Speed_Over_Ground > 0.5, @lastk) AS InvalidSOG
            FROM
		(SELECT
			t2.id, t2.DateTime_UTC,
			CASE mod(ABS(t2.Rudder_Angle - atan2r), 360) > 180
				WHEN TRUE THEN 360 - mod(ABS(t2.Rudder_Angle - atan2r), 360)
				WHEN FALSE THEN mod(ABS(t2.Rudder_Angle - atan2r), 360)
			END AS Delta_Rudder_Angle,
			Std_Shaft_Revolutions,
			Std_Speed_Through_Water,
			Std_Speed_Over_Ground
		FROM
		(SELECT t1.id, t1.DateTime_UTC,
					@lasta := IFNULL(Sinr, @lasta) AS Sinr,
					@lastb := IFNULL(Cosr, @lastb) AS Cosr,
					@lastc := IFNULL(atan2r, @lastc) AS atan2r,
					@lastd := IFNULL(modCon, @lastd) AS modCon,
					@laste := IFNULL(Std_Shaft_Revolutions, @laste)   AS Std_Shaft_Revolutions,
					@lastf := IFNULL(Std_Speed_Through_Water, @lastf) AS Std_Speed_Through_Water,
					@lastg := IFNULL(Std_Speed_Over_Ground, @lastg)   AS Std_Speed_Over_Ground,
					t1.Rudder_Angle, ri
				FROM
					(SELECT id, DateTime_UTC,
						 AVG(SIN(Rudder_Angle)) AS Sinr,
						 AVG(COS(Rudder_Angle)) AS Cosr,
						 ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS atan2r,
						 Rudder_Angle,
						 ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))) AS absdiff,
						 mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360) AS ri,
						 mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360) > 180 AS modCon,
						 STD(Shaft_Revolutions)   AS Std_Shaft_Revolutions,
						 STD(Speed_Through_Water) AS Std_Speed_Through_Water,
						 STD(Speed_Over_Ground)   AS Std_Speed_Over_Ground
					FROM tempRawISO
						GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t0
					RIGHT JOIN tempRawISO t1
						ON t0.id = t1.id
							CROSS JOIN (SELECT @lasta := 0) AS var_a
							CROSS JOIN (SELECT @lastb := 0) AS var_b
							CROSS JOIN (SELECT @lastc := 0) AS var_c
							CROSS JOIN (SELECT @lastd := 0) AS var_d
							CROSS JOIN (SELECT @laste := 0) AS var_e
							CROSS JOIN (SELECT @lastf := 0) AS var_f
							CROSS JOIN (SELECT @lastg := 0) AS var_g) t2) t3
							GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t5
								ON t5.id = t6.id
								CROSS JOIN (SELECT @lasth := 0) AS var_h
								CROSS JOIN (SELECT @lasti := 0) AS var_i
								CROSS JOIN (SELECT @lastj := 0) AS var_j
								CROSS JOIN (SELECT @lastk := 0) AS var_k) t8
                                ON t7.id = t8.id
									SET t7.Validated = NOT InvalidRPM AND
														NOT InvalidSTW AND
														NOT InvalidSOG AND
														NOT InvalidR
																	;

/* Mark analysis as Validated */
SET @timeStep := (SELECT (SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
	(SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
IF @timeStep < 600 THEN
	SET @Validated := TRUE;
ELSE
	SET @Validated := FALSE;
    UPDATE tempRawISO SET Validated = FALSE;
END IF;

CALL IMOStartEnd(@imo, @startd, @endd);
IF @imo IS NOT NULL AND @startd IS NOT NULL AND @endd IS NOT NULL THEN
	INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, Validated)
	VALUES (@imo, @startd, @endd, @Validated) ON DUPLICATE KEY UPDATE Validated = VALUES(Validated);
END IF;


/* UPDATE tempRawISO t3
    INNER JOIN
		(SELECT t2.id, 
			@lasta := IFNULL(Std_Shaft_Revolutions, @lasta) AS Std_Shaft_Revolutions,
			@lastb := IFNULL(Std_Speed_Through_Water, @lastb) AS Std_Speed_Through_Water,
			@lastd := IFNULL(Std_Speed_Over_Ground, @lastd) AS Std_Speed_Over_Ground,
			@lastf := IFNULL(SQRT(AVG(POWER(Delta_Rudder_Angle, 2))), @lastf) AS Std_Rudder_Angle
			FROM
				(SELECT t1.id, DateTime_UTC, Std_Shaft_Revolutions, Std_Speed_Through_Water, Std_Speed_Over_Ground, Avg_Rudder_Angle, Std_Rudder_Angle, Delta_Rudder_Angle
				FROM
					(SELECT id, DateTime_UTC,
						STD(Shaft_Revolutions) AS    Std_Shaft_Revolutions,
						STD(Speed_Through_Water) AS  Std_Speed_Through_Water,
						STD(Speed_Over_Ground) AS    Std_Speed_Over_Ground,
						ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS Avg_Rudder_Angle,
						STD(Rudder_Angle) AS         Std_Rudder_Angle
							FROM tempRawISO
								GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t1
					JOIN
						(SELECT id,
							CASE mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360) > 180
								WHEN TRUE THEN 360 - mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360)
								WHEN FALSE THEN mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360)
							END AS Delta_Rudder_Angle
							FROM tempRawISO
								GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t0
					ON t1.id = t0.id)
						RIGHT JOIN tempRawISO t2
						ON t1.id = t2.id
						CROSS JOIN (SELECT @lasta := 0) AS var_a
						CROSS JOIN (SELECT @lastb := 0) AS var_b
						CROSS JOIN (SELECT @lastd := 0) AS var_d
						CROSS JOIN (SELECT @lastf := 0) AS var_f) t4
						ON t3.id = t4.id
							SET t3.Validated = Std_Shaft_Revolutions <= 3 AND
											Std_Speed_Through_Water <= 0.5 AND
											Std_Speed_Over_Ground <= 0.5 AND
											Std_Rudder_Angle <= 1
																; */
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateWindResistanceCorrection`(imo INT)
BEGIN

	/* UPDATE tempRawISO
	SET Wind_Resistance_Correction = 
		((Wind_Resistance_Relative - Air_Resistance_No_Wind) * Speed_Over_Ground / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)) + 
		Delivered_Power * (1 - (0.7 / (SELECT Propulsive_Efficiency FROM SpeedPower WHERE IMO_Vessel_Number = imo)));
	*/
    
	UPDATE tempRawISO e 
		JOIN
			(SELECT q.id, w.Propulsive_Efficiency, w.Speed, w.Power, q.Delivered_Power FROM tempRawISO q
				JOIN SpeedPower w
					ON q.IMO_Vessel_Number = w.IMO_Vessel_Number AND
						q.NearestDisplacement = w.Displacement AND
						q.NearestTrim = w.Trim
				GROUP BY id) r
		ON e.id = r.id
		SET e.Wind_Resistance_Correction = (
			(e.Wind_Resistance_Relative - e.Air_Resistance_No_Wind) * e.Speed_Over_Ground / r.Propulsive_Efficiency) + 
			e.Delivered_Power * (1 - (0.7 / r.Propulsive_Efficiency)
			)
			;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`updateWindResistanceRelative`(imo INT)
BEGIN
    
	UPDATE tempRawISO
	SET Wind_Resistance_Relative =
		0.5 *
		Air_Density *
		POWER(Relative_Wind_Speed, 2) *
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO_Vessel_Number = imo AND Relative_Wind_Direction >= Start_Direction AND Relative_Wind_Direction < End_Direction);
	
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`validateFrequencies`(OUT valSTWt BOOLEAN,
									 OUT valDelt BOOLEAN,
									 OUT valShRt BOOLEAN,
									 OUT valRWSt BOOLEAN,
									 OUT valRWDt BOOLEAN,
									 OUT valSOGt BOOLEAN,
									 OUT valHeat BOOLEAN,
									 OUT valRudt BOOLEAN,
									 OUT valWDpt BOOLEAN,
									 OUT valTmpt BOOLEAN)
BEGIN

/* DECLARATIONS */
DECLARE minSTWt INT;
DECLARE minDelt INT;
DECLARE minShRt INT;
DECLARE minRWSt INT;
DECLARE minRWDt INT;
DECLARE minSOGt INT;
DECLARE minHeat INT;
DECLARE minRudt INT;
DECLARE minWDpt INT;
DECLARE minTmpt INT;

/* 
DECLARE valSTWt BOOLEAN;
DECLARE valDelt BOOLEAN;
DECLARE valShRt BOOLEAN;
DECLARE valRWSt BOOLEAN;
DECLARE valRWDt BOOLEAN;
DECLARE valSOGt BOOLEAN;
DECLARE valHeat BOOLEAN;
DECLARE valRudt BOOLEAN;
DECLARE valWDpt BOOLEAN;
DECLARE valTmpt BOOLEAN;
*/

/* Check for speed through water */
SET minSTWt := 
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Speed_Through_Water FROM tempRawISO WHERE Speed_Through_Water IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Speed_Through_Water FROM tempRawISO WHERE Speed_Through_Water IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Delivered Power */
SET minDelt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Delivered_Power FROM tempRawISO WHERE Delivered_Power IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Delivered_Power FROM tempRawISO WHERE Delivered_Power IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Shaft Revolutions */
SET minShRt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Shaft_Revolutions FROM tempRawISO WHERE Shaft_Revolutions IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Shaft_Revolutions FROM tempRawISO WHERE Shaft_Revolutions IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Relative Wind Speed */
SET minRWSt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Relative_Wind_Speed FROM tempRawISO WHERE Relative_Wind_Speed IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Relative_Wind_Speed FROM tempRawISO WHERE Relative_Wind_Speed IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Relative Wind Direction */
SET minRWDt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Relative_Wind_Direction FROM tempRawISO WHERE Relative_Wind_Direction IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Relative_Wind_Direction FROM tempRawISO WHERE Relative_Wind_Direction IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Speed Over Ground */
SET minSOGt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Speed_Over_Ground FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Speed_Over_Ground FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Ship Heading */
SET minHeat :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Ship_Heading FROM tempRawISO WHERE Ship_Heading IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Ship_Heading FROM tempRawISO WHERE Ship_Heading IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Rudder Angle */
SET minRudt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Rudder_Angle FROM tempRawISO WHERE Rudder_Angle IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Rudder_Angle FROM tempRawISO WHERE Rudder_Angle IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Water Depth */
SET minWDpt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Water_Depth FROM tempRawISO WHERE Water_Depth IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Water_Depth FROM tempRawISO WHERE Water_Depth IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Water Temperature */
SET minTmpt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Seawater_Temperature FROM tempRawISO WHERE Seawater_Temperature IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Seawater_Temperature FROM tempRawISO WHERE Seawater_Temperature IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Compare timesteps to those in standard */
SET valSTWt :=  minSTWt < 15;
SET valDelt :=  minDelt < 15 AND minDelt = minSTWt;
SET valShRt :=  minShRt < 15;
SET valRWSt :=  minRWSt < 15;
SET valRWDt :=  minRWDt < 15;
SET valSOGt :=  minSOGt < 15;
SET valHeat :=  minHeat < 15;
SET valRudt :=  minRudt < 15;
SET valWDpt :=  minWDpt < 15;
SET valTmpt :=  minTmpt < 15;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `hull_performance`.`vesselCoatingAtDate`(OUT coating VARCHAR(255), INOUT datet DATETIME, imo INT(7))
BEGIN

	SELECT (SELECT CoatingName FROM vesselcoating
				WHERE DryDockId =
					(SELECT id FROM DryDockDates
						WHERE IMO_Vessel_Number = imo AND
							EndDate <= datet LIMIT 1))
	INTO coating;

END$$
DELIMITER ;
