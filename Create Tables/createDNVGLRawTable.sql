/* Creates RawData table, a table containing the "raw" ship data obtained from DNVGL EcoInsight "Manage Data" facility. */ 



DROP PROCEDURE IF EXISTS createDNVGLRaw;

delimiter //

CREATE PROCEDURE createDNVGLRaw()

BEGIN

CREATE TABLE DNVGLRaw (
id INTEGER AUTO_INCREMENT PRIMARY KEY,
IMO_Vessel_Number	INT(7) NOT NULL,
DateTime_UTC 		DATETIME NOT NULL,
CONSTRAINT UniqueIMODates UNIQUE(IMO_Vessel_Number, DateTime_UTC), 
Date_UTC	DATE,                                              
Time_UTC	TIME,                                          
    Date_Local DATE,                                            
    Time_Local TIME,                                            
    Reporting_Time DOUBLE(20, 5),                                        
    Voyage_From DOUBLE(20, 5),                                           
    Voyage_To DOUBLE(20, 5),                                             
    ETA DOUBLE(20, 5),                                                   
    RTA DOUBLE(20, 5),                                                   
    Reason_For_Schedule_Deviation DOUBLE(20, 5),                         
    No_Of_Tugs DOUBLE(20, 5),                                            
    Voyage_Number DOUBLE(20, 5),                                         
    Voyage_Type DOUBLE(20, 5),                                           
    Service DOUBLE(20, 5),                                               
    System_Condition DOUBLE(20, 5),                                      
    Travel_Condition DOUBLE(20, 5),                                      
    Voyage_Stage DOUBLE(20, 5),                                          
    Voyage_Leg DOUBLE(20, 5),                                            
    Voyage_Leg_Type DOUBLE(20, 5),                                       
    Port_To_Port_Id DOUBLE(20, 5),                                       
    Area_From DOUBLE(20, 5),                                             
    Area_To DOUBLE(20, 5),                                               
    Position DOUBLE(20, 5),                                              
    Latitude_Degree INT,                                       
    Latitude_Minutes INT,                                      
    Latitude_North_South CHAR(1),                                  
    Longitude_Degree INT,                                      
    Longitude_Minutes INT,                                     
    Longitude_East_West CHAR(1),                                   
    Wind_Dir INT,                                              
    Wind_Dir_Degree INT,                                       
    Wind_Force_Kn DOUBLE(20, 5),                                         
    Wind_Force_Bft INT,                                        
    Sea_state_Dir INT,                                         
    Sea_state_Dir_Degree INT,                                  
    Sea_state_Force_Douglas INT,                               
    Period_Of_Wind_Waves INT,                                  
    Swell_Dir INT,                                             
    Swell_Dir_Degree INT,                                      
    Swell_Force INT,                                           
    Period_Of_Primary_Swell_Waves INT,                         
    Current_Dir INT,                                           
    Current_Dir_Degree INT,                                    
    Current_Speed INT,                                         
    Temperature_Ambient DOUBLE(20, 5),                                   
    Temperature_Water DOUBLE(20, 5),                                     
    Water_Depth DOUBLE(20, 5),                                           
    Draft_Actual_Fore DOUBLE(20, 5),                                     
    Draft_Actual_Aft DOUBLE(20, 5),                                      
    Draft_Recommended_Fore DOUBLE(20, 5),                                
    Draft_Recommended_Aft DOUBLE(20, 5),                                 
    Draft_Ballast_Actual DOUBLE(20, 5),                                  
    Draft_Ballast_Optimum DOUBLE(20, 5),                                 
    Draft_Displacement_Actual DOUBLE(20, 5),                             
    Event VARCHAR(4),                                                 
    Time_Since_Previous_Report DOUBLE(20, 5),                            
    Time_Elapsed_Sailing DOUBLE(20, 5),                                  
    Time_Elapsed_Maneuvering DOUBLE(20, 5),                              
    Time_Elapsed_Waiting DOUBLE(20, 5),                                  
    Time_Elapsed_Loading_Unloading DOUBLE(20, 5),                        
    Distance DOUBLE(20, 5),                                              
    Distance_To_Go DOUBLE(20, 5),                                        
    Average_Speed_GPS DOUBLE(20, 5),                                     
    Average_Speed_Through_Water DOUBLE(20, 5),                           
    Average_Propeller_Speed DOUBLE(20, 5),                               
    Intended_Speed_Next_24Hrs DOUBLE(20, 5),                             
    Nominal_Slip DOUBLE(20, 5),                                          
    Apparent_Slip DOUBLE(20, 5),                                         
    Cargo_Mt DOUBLE(20, 5),                                              
    Cargo_Total_TEU DOUBLE(20, 5),                                       
    Cargo_Total_Full_TEU DOUBLE(20, 5),                                  
    Cargo_Reefer_TEU DOUBLE(20, 5),                                      
    Reefer_20_Chilled DOUBLE(20, 5),                                     
    Reefer_40_Chilled DOUBLE(20, 5),                                     
    Reefer_20_Frozen DOUBLE(20, 5),                                      
    Reefer_40_Frozen DOUBLE(20, 5),                                      
    Cargo_CEU DOUBLE(20, 5),                                             
    Crew DOUBLE(20, 5),                                                  
    Passengers DOUBLE(20, 5),                                            
    ME_Fuel_BDN VARCHAR(100),                                       
    ME_Fuel_BDN_2 DOUBLE(20, 5),                                         
    ME_Fuel_BDN_3 DOUBLE(20, 5),                                         
    ME_Fuel_BDN_4 DOUBLE(20, 5),                                         
    ME_Consumption DOUBLE(20, 5),                                        
    ME_Consumption_BDN_2 DOUBLE(20, 5),                                  
    ME_Consumption_BDN_3 DOUBLE(20, 5),                                  
    ME_Consumption_BDN_4 DOUBLE(20, 5),                                  
    ME_Projected_Consumption DOUBLE(20, 5),                              
    ME_Cylinder_Oil_Consumption DOUBLE(20, 5),                           
    ME_System_Oil_Consumption DOUBLE(20, 5),                             
    ME_1_Running_Hours DOUBLE(20, 5),                                    
    ME_1_Consumption DOUBLE(20, 5),                                      
    ME_1_Cylinder_Oil_Consumption DOUBLE(20, 5),                         
    ME_1_System_Oil_Consumption DOUBLE(20, 5),                           
    ME_1_Work DOUBLE(20, 5),                                             
    ME_1_Shaft_Gen_Work DOUBLE(20, 5),                                   
    ME_1_Shaft_Gen_Running_Hours DOUBLE(20, 5),                          
    ME_2_Running_Hours DOUBLE(20, 5),                                    
    ME_2_Consumption DOUBLE(20, 5),                                      
    ME_2_Cylinder_Oil_Consumption DOUBLE(20, 5),                         
    ME_2_System_Oil_Consumption DOUBLE(20, 5),                           
    ME_2_Work DOUBLE(20, 5),                                             
    ME_2_Shaft_Gen_Work DOUBLE(20, 5),                                   
    ME_2_Shaft_Gen_Running_Hours DOUBLE(20, 5),                          
    ME_3_Running_Hours DOUBLE(20, 5),                                    
    ME_3_Consumption DOUBLE(20, 5),                                      
    ME_3_Cylinder_Oil_Consumption DOUBLE(20, 5),                         
    ME_3_System_Oil_Consumption DOUBLE(20, 5),                           
    ME_3_Work DOUBLE(20, 5),                                             
    ME_3_Shaft_Gen_Work DOUBLE(20, 5),                                   
    ME_3_Shaft_Gen_Running_Hours DOUBLE(20, 5),                          
    ME_4_Running_Hours DOUBLE(20, 5),                                    
    ME_4_Consumption DOUBLE(20, 5),                                      
    ME_4_Cylinder_Oil_Consumption DOUBLE(20, 5),                         
    ME_4_System_Oil_Consumption DOUBLE(20, 5),                           
    ME_4_Work DOUBLE(20, 5),                                             
    ME_4_Shaft_Gen_Work DOUBLE(20, 5),                                   
    ME_4_Shaft_Gen_Running_Hours DOUBLE(20, 5),                          
    AE_Fuel_BDN DOUBLE(20, 5),                                           
    AE_Fuel_BDN_2 DOUBLE(20, 5),                                         
    AE_Fuel_BDN_3 DOUBLE(20, 5),                                         
    AE_Fuel_BDN_4 DOUBLE(20, 5),                                         
    AE_Consumption DOUBLE(20, 5),                                        
    AE_Consumption_BDN_2 DOUBLE(20, 5),                                  
    AE_Consumption_BDN_3 DOUBLE(20, 5),                                  
    AE_Consumption_BDN_4 DOUBLE(20, 5),                                  
    AE_Projected_Consumption DOUBLE(20, 5),                              
    AE_System_Oil_Consumption DOUBLE(20, 5),                             
    AE_1_Running_Hours DOUBLE(20, 5),                                    
    AE_1_Consumption DOUBLE(20, 5),                                      
    AE_1_System_Oil_Consumption DOUBLE(20, 5),                           
    AE_1_Work DOUBLE(20, 5),                                             
    AE_2_Running_Hours DOUBLE(20, 5),                                    
    AE_2_Consumption DOUBLE(20, 5),                                      
    AE_2_System_Oil_Consumption DOUBLE(20, 5),                           
    AE_2_Work DOUBLE(20, 5),                                             
    AE_3_Running_Hours DOUBLE(20, 5),                                    
    AE_3_Consumption DOUBLE(20, 5),                                      
    AE_3_System_Oil_Consumption DOUBLE(20, 5),                           
    AE_3_Work DOUBLE(20, 5),                                             
    AE_4_Running_Hours DOUBLE(20, 5),                                    
    AE_4_Consumption DOUBLE(20, 5),                                      
    AE_4_System_Oil_Consumption DOUBLE(20, 5),                           
    AE_4_Work DOUBLE(20, 5),                                             
    AE_5_Running_Hours DOUBLE(20, 5),                                    
    AE_5_Consumption DOUBLE(20, 5),                                      
    AE_5_System_Oil_Consumption DOUBLE(20, 5),                           
    AE_5_Work DOUBLE(20, 5),                                             
    AE_6_Running_Hours DOUBLE(20, 5),                                    
    AE_6_Consumption DOUBLE(20, 5),                                      
    AE_6_System_Oil_Consumption DOUBLE(20, 5),                           
    AE_6_Work DOUBLE(20, 5),                                             
    Boiler_Consumption DOUBLE(20, 5),                                    
    Boiler_Consumption_BDN_2 DOUBLE(20, 5),                              
    Boiler_Consumption_BDN_3 DOUBLE(20, 5),                              
    Boiler_Consumption_BDN_4 DOUBLE(20, 5),                              
    Boiler_1_Running_Hours DOUBLE(20, 5),                                
    Boiler_1_Consumption DOUBLE(20, 5),                                  
    Boiler_2_Running_Hours DOUBLE(20, 5),                                
    Boiler_2_Consumption DOUBLE(20, 5),                                  
    Air_Compr_1_Running_Time DOUBLE(20, 5),                              
    Air_Compr_2_Running_Time DOUBLE(20, 5),                              
    Thruster_1_Running_Time DOUBLE(20, 5),                               
    Thruster_2_Running_Time DOUBLE(20, 5),                               
    Thruster_3_Running_Time DOUBLE(20, 5),                               
    Fresh_Water_Bunkered DOUBLE(20, 5),                                  
    Fresh_Water_Consumption_Drinking DOUBLE(20, 5),                      
    Fresh_Water_Consumption_Technical DOUBLE(20, 5),                     
    Fresh_Water_Consumption_Washing DOUBLE(20, 5),                       
    Fresh_Water_Produced DOUBLE(20, 5),                                  
    Fresh_Water_ROB DOUBLE(20, 5),                                       
    Duration_Fresh_Water DOUBLE(20, 5),                                  
    Sludge_ROB DOUBLE(20, 5),                                            
    HFO_HS_ROB DOUBLE(20, 5),                                            
    HFO_LS_ROB DOUBLE(20, 5),                                            
    MDO_MGO_HS_ROB DOUBLE(20, 5),                                        
    MDO_MGO_LS_ROB DOUBLE(20, 5),                                        
    ME_Cylinder_Oil_ROB DOUBLE(20, 5),                                   
    ME_System_Oil_ROB DOUBLE(20, 5),                                     
    AE_System_Oil_ROB DOUBLE(20, 5),                                     
    Cleaning_Event DOUBLE(20, 5),                                        
    Mode DOUBLE(20, 5),                                                  
    Speed_GPS DOUBLE(20, 5),                                             
    Speed_Through_Water DOUBLE(20, 5),                                   
    Speed_Projected_From_Charter_Party DOUBLE(20, 5),                    
    Course DOUBLE(20, 5),                                                
    True_Heading DOUBLE(20, 5),                                          
    ME_Barometric_Pressure DOUBLE(20, 5),                                
    ME_Charge_Air_Coolant_Inlet_Temp DOUBLE(20, 5),                      
    ME_Air_Intake_Temp DOUBLE(20, 5),                                    
    ME_1_Load DOUBLE(20, 5),                                             
    ME_1_Speed_RPM DOUBLE(20, 5),                                        
    Prop_1_Pitch DOUBLE(20, 5),                                          
    ME_1_Aux_Blower DOUBLE(20, 5),                                       
    ME_1_Shaft_Gen_Power DOUBLE(20, 5),                                  
    ME_1_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    ME_1_Charge_Air_Pressure DOUBLE(20, 5),                              
    ME_1_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    ME_1_TC_Speed DOUBLE(20, 5),                                         
    ME_1_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    ME_1_Exh_Temp_After_TC DOUBLE(20, 5),                                
    ME_1_Current_Consumption DOUBLE(20, 5),                              
    ME_1_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    ME_1_SFOC DOUBLE(20, 5),                                             
    ME_1_Pmax DOUBLE(20, 5),                                             
    ME_1_Pcomp DOUBLE(20, 5),                                            
    ME_2_Load DOUBLE(20, 5),                                             
    ME_2_Speed_RPM DOUBLE(20, 5),                                        
    Prop_2_Pitch DOUBLE(20, 5),                                          
    ME_2_Aux_Blower DOUBLE(20, 5),                                       
    ME_2_Shaft_Gen_Power DOUBLE(20, 5),                                  
    ME_2_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    ME_2_Charge_Air_Pressure DOUBLE(20, 5),                              
    ME_2_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    ME_2_TC_Speed DOUBLE(20, 5),                                         
    ME_2_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    ME_2_Exh_Temp_After_TC DOUBLE(20, 5),                                
    ME_2_Current_Consumption DOUBLE(20, 5),                              
    ME_2_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    ME_2_SFOC DOUBLE(20, 5),                                             
    ME_2_Pmax DOUBLE(20, 5),                                             
    ME_2_Pcomp DOUBLE(20, 5),                                            
    ME_3_Load DOUBLE(20, 5),                                             
    ME_3_Speed_RPM DOUBLE(20, 5),                                        
    Prop_3_Pitch DOUBLE(20, 5),                                          
    ME_3_Aux_Blower DOUBLE(20, 5),                                       
    ME_3_Shaft_Gen_Power DOUBLE(20, 5),                                  
    ME_3_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    ME_3_Charge_Air_Pressure DOUBLE(20, 5),                              
    ME_3_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    ME_3_TC_Speed DOUBLE(20, 5),                                         
    ME_3_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    ME_3_Exh_Temp_After_TC DOUBLE(20, 5),                                
    ME_3_Current_Consumption DOUBLE(20, 5),                              
    ME_3_SFOC DOUBLE(20, 5),                                             
    ME_3_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    ME_3_Pmax DOUBLE(20, 5),                                             
    ME_3_Pcomp DOUBLE(20, 5),                                            
    ME_4_Load DOUBLE(20, 5),                                             
    ME_4_Speed_RPM DOUBLE(20, 5),                                        
    Prop_4_Pitch DOUBLE(20, 5),                                          
    ME_4_Aux_Blower DOUBLE(20, 5),                                       
    ME_4_Shaft_Gen_Power DOUBLE(20, 5),                                  
    ME_4_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    ME_4_Charge_Air_Pressure DOUBLE(20, 5),                              
    ME_4_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    ME_4_TC_Speed DOUBLE(20, 5),                                         
    ME_4_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    ME_4_Exh_Temp_After_TC DOUBLE(20, 5),                                
    ME_4_Current_Consumption DOUBLE(20, 5),                              
    ME_4_SFOC DOUBLE(20, 5),                                             
    ME_4_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    ME_4_Pmax DOUBLE(20, 5),                                             
    ME_4_Pcomp DOUBLE(20, 5),                                            
    AE_Barometric_Pressure DOUBLE(20, 5),                                
    AE_Charge_Air_Coolant_Inlet_Temp DOUBLE(20, 5),                      
    AE_Air_Intake_Temp DOUBLE(20, 5),                                    
    AE_1_Load DOUBLE(20, 5),                                             
    AE_1_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    AE_1_Charge_Air_Pressure DOUBLE(20, 5),                              
    AE_1_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    AE_1_TC_Speed DOUBLE(20, 5),                                         
    AE_1_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    AE_1_Exh_Temp_After_TC DOUBLE(20, 5),                                
    AE_1_Current_Consumption DOUBLE(20, 5),                              
    AE_1_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    AE_1_SFOC DOUBLE(20, 5),                                             
    AE_1_Pmax DOUBLE(20, 5),                                             
    AE_1_Pcomp DOUBLE(20, 5),                                            
    AE_2_Load DOUBLE(20, 5),                                             
    AE_2_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    AE_2_Charge_Air_Pressure DOUBLE(20, 5),                              
    AE_2_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    AE_2_TC_Speed DOUBLE(20, 5),                                         
    AE_2_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    AE_2_Exh_Temp_After_TC DOUBLE(20, 5),                                
    AE_2_Current_Consumption DOUBLE(20, 5),                              
    AE_2_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    AE_2_SFOC DOUBLE(20, 5),                                             
    AE_2_Pmax DOUBLE(20, 5),                                             
    AE_2_Pcomp DOUBLE(20, 5),                                            
    AE_3_Load DOUBLE(20, 5),                                             
    AE_3_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    AE_3_Charge_Air_Pressure DOUBLE(20, 5),                              
    AE_3_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    AE_3_TC_Speed DOUBLE(20, 5),                                         
    AE_3_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    AE_3_Exh_Temp_After_TC DOUBLE(20, 5),                                
    AE_3_Current_Consumption DOUBLE(20, 5),                              
    AE_3_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    AE_3_SFOC DOUBLE(20, 5),                                             
    AE_3_Pmax DOUBLE(20, 5),                                             
    AE_3_Pcomp DOUBLE(20, 5),                                            
    AE_4_Load DOUBLE(20, 5),                                             
    AE_4_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    AE_4_Charge_Air_Pressure DOUBLE(20, 5),                              
    AE_4_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    AE_4_TC_Speed DOUBLE(20, 5),                                         
    AE_4_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    AE_4_Exh_Temp_After_TC DOUBLE(20, 5),                                
    AE_4_Current_Consumption DOUBLE(20, 5),                              
    AE_4_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    AE_4_SFOC DOUBLE(20, 5),                                             
    AE_4_Pmax DOUBLE(20, 5),                                             
    AE_4_Pcomp DOUBLE(20, 5),                                            
    AE_5_Load DOUBLE(20, 5),                                             
    AE_5_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    AE_5_Charge_Air_Pressure DOUBLE(20, 5),                              
    AE_5_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    AE_5_TC_Speed DOUBLE(20, 5),                                         
    AE_5_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    AE_5_Exh_Temp_After_TC DOUBLE(20, 5),                                
    AE_5_Current_Consumption DOUBLE(20, 5),                              
    AE_5_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    AE_5_SFOC DOUBLE(20, 5),                                             
    AE_5_Pmax DOUBLE(20, 5),                                             
    AE_5_Pcomp DOUBLE(20, 5),                                            
    AE_6_Load DOUBLE(20, 5),                                             
    AE_6_Charge_Air_Inlet_Temp DOUBLE(20, 5),                            
    AE_6_Charge_Air_Pressure DOUBLE(20, 5),                              
    AE_6_Pressure_Drop_Over_Charge_Air_Cooler DOUBLE(20, 5),             
    AE_6_TC_Speed DOUBLE(20, 5),                                         
    AE_6_Exh_Temp_Before_TC DOUBLE(20, 5),                               
    AE_6_Exh_Temp_After_TC DOUBLE(20, 5),                                
    AE_6_Current_Consumption DOUBLE(20, 5),                              
    AE_6_SFOC_ISO_Corrected DOUBLE(20, 5),                               
    AE_6_SFOC DOUBLE(20, 5),                                             
    AE_6_Pmax DOUBLE(20, 5),                                             
    AE_6_Pcomp DOUBLE(20, 5),                                            
    Boiler_1_Operation_Mode DOUBLE(20, 5),                               
    Boiler_1_Feed_Water_Flow DOUBLE(20, 5),                              
    Boiler_1_Steam_Pressure DOUBLE(20, 5),                               
    Boiler_2_Operation_Mode DOUBLE(20, 5),                               
    Boiler_2_Feed_Water_Flow DOUBLE(20, 5),                              
    Boiler_2_Steam_Pressure DOUBLE(20, 5),                               
    Cooling_Water_System_SW_Pumps_In_Service DOUBLE(20, 5),              
    Cooling_Water_System_SW_Inlet_Temp DOUBLE(20, 5),                    
    Cooling_Water_System_SW_Outlet_Temp DOUBLE(20, 5),                   
    Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger DOUBLE(20, 5),
    Cooling_Water_System_Pump_Pressure DOUBLE(20, 5),                    
    ER_Ventilation_Fans_In_Service DOUBLE(20, 5),                        
    ER_Ventilation_Waste_Air_Temp DOUBLE(20, 5),                         
    Remarks DOUBLE(20, 5),                                               
    Entry_Made_By_1 DOUBLE(20, 5),                                       
    Entry_Made_By_2 DOUBLE(20, 5)                                       
);

END;