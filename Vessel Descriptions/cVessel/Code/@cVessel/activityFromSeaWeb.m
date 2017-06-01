function [obj, activity] = activityFromSeaWeb(obj, filename)
% activityFromSeaWeb Parse activity data from SeaWeb download

% Output
activity = nan(size(obj));

% Input
[validFile, errMsg] = cellfun(@(x) obj.validateFileExists(x), filename,...
    'Uni', 0);
validFile = [validFile{:}];
% [validFile, errMsg] = obj.validateFileExists(filename);
if any(~validFile)
   
   errid = 'ShipAnalysis:SeawebFileMissing';
   errMsg = errMsg{ find(~validFile, 1)};
   error(errid, errMsg);
end

% Iterate over files and append to table
empty_c = cell(1, 12);
ihs_tbl = table(empty_c{:}, 'VariableNames', {'Ship', 'IMO_LR_IHS_No_',...
    'Port_of_Call', 'PortOfCall_URL', 'Country_of_Call', 'Arrival_Date',...
    'Sailed_Date', 'Hours_in_Port', 'Arrival_Date_1', 'Ship_Name',...
    'Vessel_Type', 'Operator'});

for fi = 1:numel(filename)

    % Parse File
    currFile = filename{fi};
    t = readtable(currFile);

    % Filter missing times from table
    t(cellfun(@isempty, t.Arrival_Date) | cellfun(@isempty, t.Sailed_Date), :)= [];

    % Append to existing table
    ihs_tbl = [ihs_tbl; t];
end

% Calculate Idle time as difference of arrival and departures
ihs_tbl.Arrival_Datenum = datenum(ihs_tbl.Arrival_Date, 'mm/dd/yyyy HH:MM:SS PM');
ihs_tbl.Sailed_Datenum = datenum(ihs_tbl.Sailed_Date, 'mm/dd/yyyy HH:MM:SS PM');
ihs_tbl.Idle_Time = ihs_tbl.Sailed_Datenum - ihs_tbl.Arrival_Datenum;
    
% Activity defined as ratio between total idle time and total time
while ~obj.iterFinished
    
    % Iterate
    [obj, ii] = obj.iter;
    if obj(ii).isPerDataEmpty
        continue
    end
    
    % Get extents of dry-docking interval
    intStart = min(obj(ii).DateTime_UTC);
    intEnd = max(obj(ii).DateTime_UTC);
    
    % Find corresponding subset of table
    int_tbl = ihs_tbl(ihs_tbl.IMO_LR_IHS_No_ == obj(ii).IMO_Vessel_Number & ...
        ((ihs_tbl.Arrival_Datenum > intStart & ihs_tbl.Arrival_Datenum < intEnd) | ...
        (ihs_tbl.Sailed_Datenum > intStart & ihs_tbl.Sailed_Datenum < intEnd)), :);
    
    % Calculate activity from subset
    activity(ii) = 1 - (sum(int_tbl.Idle_Time) / (max(int_tbl.Sailed_Datenum) - min(int_tbl.Arrival_Datenum)));
    obj(ii).Activity = activity(ii);
    
end
obj = obj.iterReset;