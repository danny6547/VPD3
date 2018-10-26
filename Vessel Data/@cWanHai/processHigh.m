function tbl = processHigh(tbl, type, varargin)
% processWanHaiHighFreqFile 

% Input
writeFile_l = false;
if nargin > 2
    
    outfile = varargin{1};
    writeFile_l = true;
end

% Calculate Position
tbl_long = rowfun(...
    @(sign, deg, min) ~isnan(strcmp(sign, 'E')/0)*(deg + min/60),...
    tbl, 'InputVariables', ...
    {'Longitude_Name', 'Longitude_Deg', 'Longitude_Min'},...
    'OutputFormat', 'table',...
    'OutputVariableNames', {'Longitude'});
tbl_lat = rowfun(...
    @(sign, deg, min) ~isnan(strcmp(sign, 'N')/0)*(deg + min/60),...
    tbl, 'InputVariables', ...
    {'Latitude_Name', 'Latitude_Deg', 'Latitude_Min'},...
    'OutputFormat', 'table',...
    'OutputVariableNames', {'Latitude'});
tbl = [tbl, tbl_long, tbl_lat];

% Convert true to relative wind speeds
knots2mps = 0.514444;
[relSpeed, relDir] = cVesselNoonData.relWindFromTrue(...
                            tbl.True_Wind_Speed, tbl.True_Wind_Direction,...
                            tbl.Speed_Over_Ground, tbl.Ship_Heading);
tbl.Relative_Wind_Speed = relSpeed*knots2mps;
tbl.Relative_Wind_Direction = relDir;

knots2mps = 0.514444;
tbl.Speed_Over_Ground = tbl.Speed_Over_Ground*knots2mps;

switch type
    
    case 1
        
        tbl.Speed_Through_Water = tbl.Speed_Over_Ground;
        
    case 2
        
        % Do something with Current speed and direction here later
        tbl.Speed_Through_Water = tbl.Speed_Over_Ground;
end

% Remove unnecessary variables
spec = cWanHai.specification('high', type);
tbl = cWanHai.removeNonStandard(tbl, spec);

% Append variables from other specifications
tbl = cWanHai.appendOtherSpecVars(tbl, 'high', type);

% Write table
if writeFile_l

    writetable(tbl, outfile);
end