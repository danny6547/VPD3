function tbl = loadNoon(file, type)
%loadWanHaiNoon Return timetable of noon data from file name and spec type
%   Detailed explanation goes here

% Get variables to read
var = cWanHai.varFromSpec('noon', type);
noonOpts = detectImportOptions(file);
noonOpts = cVesselNoonData.rmVarsFromOpts(noonOpts, var);

% Read
tbl = readtable(file, noonOpts);

% Convert datetimes where necessary
switch type
    
    case 2
        
%         rt = obj.Noon2RowTime;
        [timeInputs, rt] = cWanHai.noon2TimeOpt;
        dt = datetime(tbl.(rt), timeInputs{1}{:});
        
        for ti = 2:numel(timeInputs)
            
            unconverted_l = isnat(dt);
            dt(unconverted_l) = datetime(tbl.(rt)(unconverted_l), timeInputs{ti}{:});
        end
        tbl.(rt) = dt;
end

% Convert to timetable
tbl = table2timetable(tbl);