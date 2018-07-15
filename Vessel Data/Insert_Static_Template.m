% This is an "Insert data" script. It will create a cVessel object in
% variable VESS and insert the data into the database.

% Inputs
% vesselInput = exist('vess', 'var');
% if ~vesselInput
%     
%     vess = cVessel();
% end

% Create vessel, Assign IMO
vessel = cVessel('SavedConnection', 'static');
vessel.IMO = 9036442;

% Vessel Name
vessel.Info.Vessel_Name = 'Berge Kibo';
vessel.Info.Valid_From = '1993-01-01';

% Configuration
vessel.Configuration.Vessel_Configuration_Description = 'Berge Kibo Config';
vessel.Configuration.Transverse_Projected_Area_Design = 2000; % Big, wild guess
vessel.Configuration.Length_Overall = 327.5;
vessel.Configuration.Breadth_Moulded = 57.20;
vessel.Configuration.Draft_Design = 20.8;
vessel.Configuration.LBP = 315;
vessel.Configuration.Anemometer_Height = 40; % Big, wild guess
vessel.Configuration.Speed_Power_Source = 'Sea Trial Report';
vessel.Configuration.Fuel_Type = 'HFO';
vessel.Configuration.Valid_From = '1993-01-01';

% Owner
vessel.Owner.Vessel_Owner_Name = 'Berge Bulk';
vessel.Owner.Ownership_Start = '1993-01-01';

% Dry dock dates
vessel.DryDock(1).Start_Date = '2016-10-30';
vessel.DryDock(1).End_Date = '2016-11-06';
vessel.DryDock(1).Vertical_Bottom_Surface_Prep = 'Spot Blast';
vessel.DryDock(1).Vertical_Bottom_Coating = 'Hempaguard X5';
vessel.DryDock(1).Flat_Bottom_Surface_Prep = 'Spot Blast';
vessel.DryDock(1).Flat_Bottom_Coating = 'Hempaguard X5';
vessel.DryDock(1).Bot_Top_Surface_Prep = 'Spot Blast';
vessel.DryDock(1).Bot_Top_Coating = 'Hempaguard X5';

vessel.DryDock(2).Start_Date = '2013-09-18';
vessel.DryDock(2).End_Date = '2013-10-10';
vessel.DryDock(2).Vertical_Bottom_Surface_Prep = 'Full Blast';
vessel.DryDock(2).Vertical_Bottom_Coating = 'Hempaguard X5';
vessel.DryDock(2).Flat_Bottom_Surface_Prep = 'Full Blast';
vessel.DryDock(2).Flat_Bottom_Coating = 'Hempaguard X5';
vessel.DryDock(2).Bot_Top_Surface_Prep = 'Full Blast';
vessel.DryDock(2).Bot_Top_Coating = 'Hempaguard X5';

% Assign Speed, Power
knots2mps = 0.514444444;
bhp2Kw = 0.745699872 * 1e3;
design = [...
            12.544944	15.221138
            12.867977	16.32683
            13.134831	17.29431
            13.38764	18.28943
            13.58427	19.063416
            13.808989	20.003252
            13.935393	20.556097
            14.117977	21.274797
            14.244382	21.993496
            14.511236	22.988617
            14.707865	24.121952
            14.904494	25.006504
            15.101124	25.863415
            15.269663	26.720325
            15.424157	27.577236
            15.578651	28.406504
            15.733146	29.318699
            15.873595	30.0374
            16.042135	31.03252
            16.16854	31.64065
                                ];
vessel.SpeedPower(1).Speed = design(:, 1) * knots2mps; % m/s
vessel.SpeedPower(1).Power = design(:, 2) * bhp2Kw; % kW
vessel.SpeedPower(1).Trim = 0; % Positive by the bow, negative by the stern
vessel.SpeedPower(1).Displacement =  318899 ; % tonnes of seawater displaced at given seawater density
vessel.SpeedPower(1).FluidDensity = 1025; % tn / m^3, optional, default values is 1025
vessel.SpeedPower(1).Name = 'Berge Bulk Sea Trial Report';
vessel.SpeedPower(1).Description = 'Ballast and Design Speed, Power curves from Sea Trial Report, document titled `Hull No. 5069`.';

ballast = [...
            14.047184	15.271193
            14.353907	16.351734
            14.660945	17.281792
            14.898075	18.060894
            15.093018	18.864796
            15.357817	19.844732
            15.608518	20.849655
            15.831078	21.879473
            16.06805	22.733816
            16.276354	23.863863
            16.498913	24.893679
            16.693699	25.772823
            16.860079	26.802265
            17.054602	27.806812
            17.19347	28.560177
            17.290468	29.187855
            17.401512	29.815626
                                ];
vessel.SpeedPower(2).Speed = ballast(:, 1) * knots2mps;
vessel.SpeedPower(2).Power = ballast(:, 2) * bhp2Kw;
vessel.SpeedPower(2).Trim = 2.6;
vessel.SpeedPower(2).Displacement =  135939;
vessel.SpeedPower(2).FluidDensity = 1025;

% Assign Wind
vessel.WindCoefficient.selectByName('ISO15016 General Cargo Vessel 1');

% Assign Engine
vessel.Engine.Engine_Model = 'Man B&W 7S80MC';
mcr = 31920;
sfoc = [130, 126, 127.5, 131];
powerPCT = [50, 75, 90, 100];
vessel.Engine.fitData2Quadratic(mcr, sfoc, powerPCT);

% Displacement
vessel.Displacement.Draft_Mean = [21.82, 20.90, 19.92, 13.00, 11.01, 12.00, 14.00, 23.00, 22.00, 21.00, 20.00, 19.00, 18.00, 17.00, 16.00, 15.00, 14.00, 13.00];
vessel.Displacement.Trim = [];
vessel.Displacement.LCF = [-0.48, 0.21, 0.94, 14.59, 13.02, 12.01, 9.46, -0.89, -0.54, 0.06, 0.90, 1.98, 3.34, 4.88, 6.54, 7.99, 9.46, 10.82]; % Longitudinal centre of flotation
vessel.Displacement.TPC = [168.60, 167.75, 166.84, 157.27, 154.71, 155.93, 158.64, 169.53, 168.73, 167.88, 166.92, 165.75, 164.37, 162.92, 161.39, 160.01, 158.64, 157.27]; % Tonnes per centimeter immersion
vessel.Displacement.Displacement = [335602.8, 320129.5, 303732.1, 191554.3, 160519.1, 175895.0, 207349.8, 355551.4, 338638.6, 321807.9, 305067.0, 288432.5, 271924.8, 255560.0, 239344.4, 223280.8, 207349.8, 191554.3]; % tonnes
vessel.Displacement.FluidDensity = 1025; % tn / m^3, optional, default values is 1025

% Assign Bunker Delivery
...

% Insert data
vessel = vessel.insert;

% % Load time-series data
% % 2011
% sheets = {'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', ...
%     'SEP', 'OCT', 'NOV', 'DEC'};
% filename = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%     'performance\Vessels\Berge Bulk\Berge Kibo\Time series data\'...
%     'KBO 2011.xls'];
% dates = [734504, 734535, 734563, 734594, 734624, 734655, 734685, ...
%     734716, 734747, 734777, 734808, 734838];
% vessel = vessel.loadBergeNoon(filename, sheets, dates);
% 
% % 2012
% sheets = {'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', ...
%     'SEP', 'OCT', 'NOV', 'DEC'};
% filename = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%     'performance\Vessels\Berge Bulk\Berge Kibo\Time series data\'...
%     'KBO 2012.xls'];
% dates = [734869, 734900, 734929, 734960, 734990, 735021, 735051,...
%     735082, 735113, 735143, 735174, 735204];
% fileColI = [1, 10, 11, 12, 19, 26, 27, 14, 21, 22];
% vessel = vessel.loadBergeNoon(filename, sheets, dates);
% 
% % 2013 - 2016
% VesselDir_ch = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%     'performance\Vessels\Berge Bulk\Berge Kibo\Time series data'];
% file_c = {'KBO VPR 12 2013.xls', 'KBO VPR 12 2014.xlsx', ...
%     'KBO-VPR-10-2015.xlsx', 'KBO-VPR-1611.xlsx'};
% filename = cellfun(@(x) fullfile(VesselDir_ch, x), file_c, 'Uni', 0);
% vessel = vessel.loadBergeNoon(filename);
% 
% % 2016
% VesselDir_ch = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%     'performance\Vessels\Berge Bulk\Berge Kibo\Time series data'];
% file_c = {'VSL VPR MTH 2016_template-REVISED.xlsx'};
% filename = cellfun(@(x) fullfile(VesselDir_ch, x), file_c, 'Uni', 0);
% vessel = vessel.loadBergeNoon(filename);
% 
% % 2017
% VesselDir_ch = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%     'performance\Vessels\Berge Bulk\Berge Kibo\Time series data'];
% file_c = {'VSL VPR MTH 2017_template-REVISED b.xlsx'};
% filename = cellfun(@(x) fullfile(VesselDir_ch, x), file_c, 'Uni', 0);
% vessel = vessel.loadBergeNoon(filename);
% 
% % 2018
% sheetname = {'10.17', '11.17', '12.17', '01.18', '02.18'};
% filename = 'VSL VPR MTH 2018_template-REVISED.xlsx';
% basedate = datenum(sheetname, 'mm.yy');
% vessel = vessel.loadBergeNoon(filename, sheetname, basedate, ...
%     'LastRow', [37, 37, 37, 37, 37]);