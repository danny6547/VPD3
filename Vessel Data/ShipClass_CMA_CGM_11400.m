% Create CMA CGM 11400 TEU Weight Class
obj_csc = cShipClass();

obj_csc.LBP = 348;
obj_csc.WeightTEU = 11400;
obj_csc.Engine = 'Man B&W 12K98ME-C Mk7';
obj_csc.Wind_Resist_Coeff_Dir = [];
obj_csc.Transverse_Projected_Area_Design = 2085;
obj_csc.Block_Coefficient = 0.6473;
obj_csc.Length_Overall = 363;
obj_csc.Breadth_Moulded = 45.6; % Denoted as only "breadth" in pdf
obj_csc.Draft_Design = 13;

% Create ships of the class
imo = [9410765, 9410791];
names = {'Cassiopeia', 'Gemini'};
obj_shp = cShip(imo, names);
obj_shp = obj_shp.assignClass(obj_csc);

% Insert static ship data into database
obj_shp.insertIntoVessels();

% Insert speed, power data
speed = 22.5:0.5:27.5;
power = [35792, 38335, 40976, 43665, 46499, 49624, 53165, 57311, 61838, ...
    66406, 71047];
disp = 133531;
trim = 13 - 13;
AT = 2085;
CB = 0.6473;
[obj_shp, ~, ~, s, p, d, t] = obj_shp.insertIntoSpeedPowerCoefficients(speed, power, disp, trim);
obj_shp = obj_shp.insertIntoSpeedPower(s, p, d, t);

speed = 24.5:0.5:29.5;
power = [39234, 42137, 45215, 48503, 52023, 55769, 59741, 63952, 68463, 73339, 78595];
disp = 64131.9;
trim = 9.6 - 4.5;
AT = 2356.82;
CB = 0.5732;
[obj_shp, ~, ~, s, p, d, t] = obj_shp.insertIntoSpeedPowerCoefficients(speed, power, disp, trim);
obj_shp = obj_shp.insertIntoSpeedPower(s, p, d, t);

speed = 22:0.5:27;
power = [36531, 39546, 42799, 46319, 50045, 53897, 57997, 62838, 68462, 74479, 80998];
disp = 159899.1;
trim = 15 - 15;
AT = 1993.80;
CB = 0.6718;
[obj_shp, ~, ~, s, p, d, t] = obj_shp.insertIntoSpeedPowerCoefficients(speed, power, disp, trim);
obj_shp = obj_shp.insertIntoSpeedPower(s, p, d, t);

% Insert wind direction coefficients

% 