function tbl = writeImportFile(noonFile, noonType, highFile, highType, varargin)
%writeImportFile Write import file by joining high-freq and noon data
%   Detailed explanation goes here

% Input
noonFile = validateCellStr(noonFile);
highFile = validateCellStr(highFile);

% Concatenate noon reports
noon_tbl = cWanHai.loadNoon(noonFile{1}, noonType(1));
noon_tbl = cWanHai.processNoon(noon_tbl, noonType(1));
for ni = 2:numel(noonFile)
    
    currnoon_tbl = cWanHai.loadNoon(noonFile{ni}, noonType(ni));
    currnoon_tbl = cWanHai.processNoon(currnoon_tbl, noonType(ni));
    noon_tbl = [noon_tbl; currnoon_tbl];
end

% Concatenate high-freq data
high_tbl = cWanHai.loadHigh(highFile{1}, highType(1));
high_tbl = cWanHai.processHigh(high_tbl, highType(1), varargin{:});
for hi = 2:numel(highFile)
    
    currHigh_tbl = cWanHai.loadHigh(highFile{hi}, highType(hi));
    currHigh_tbl = cWanHai.processHigh(currHigh_tbl, highType(hi));
    high_tbl = [high_tbl; currHigh_tbl];
end

% Join
writeFile_l = false;
newtimebasis = 'union';
noonRep = [{'Static_Draught_Fore'}, {'Static_Draught_Aft'}];
tbl = cVesselNoonData.joinNoon2HighFreq(noon_tbl, high_tbl, noonRep, ...
    writeFile_l, newtimebasis);

% Hack code
if ~ismember('Speed_Through_Water', tbl.Properties.VariableNames)
    
    tbl.Speed_Through_Water = tbl.Speed_Over_Ground;
end