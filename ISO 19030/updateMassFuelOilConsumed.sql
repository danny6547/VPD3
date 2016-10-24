/* Calculate mass of fuel oil consumed based on volume of fuel oil consumed */

UPDATE tempRawISO SET Mass_Consumed_Fuel_Oil = Volume_Consumed_Fuel_Oil * (Density_Fuel_Oil_15C - Density_Change_Rate_Per_C*(Temp_Fuel_Oil_At_Flow_Meter - 15));