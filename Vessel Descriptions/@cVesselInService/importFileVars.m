function vars = importFileVars()
%importFileVars Variable names in import files
%   Detailed explanation goes here

vars = {'Relative_Wind_Speed'
        'Relative_Wind_Direction'
        'Speed_Over_Ground'
        'Ship_Heading'
        'Shaft_Revolutions'
        'Static_Draught_Fore'
        'Static_Draught_Aft'
        'Water_Depth'
        'Rudder_Angle'
        'Seawater_Temperature'
        'Air_Temperature'
        'Air_Pressure'
        'Speed_Through_Water'
        'Delivered_Power'
        'Shaft_Power'
        'Brake_Power'
        'Shaft_Torque'
        'Mass_Consumed_Fuel_Oil'
        'Volume_Consumed_Fuel_Oil'
        'Temp_Fuel_Oil_At_Flow_Meter'
        'Displacement'};
vars = vars(:)';    
end