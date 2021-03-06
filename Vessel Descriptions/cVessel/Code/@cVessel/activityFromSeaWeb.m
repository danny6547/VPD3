function [obj, activity] = activityFromSeaWeb(obj, filename)
% activityFromSeaWeb Parse activity data from SeaWeb download

% Output
activity = nan(size(obj));

% Input
filename = validateCellStr(filename, 'activityFromSeaWeb', 'filename', 2);
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
% fileVars_c = {'Ship', 'IMO_LR_IHS_No_',...
%     'Port_of_Call', 'PortOfCall_URL', 'Country_of_Call', 'Arrival_Date',...
%     'Sailed_Date', 'Hours_in_Port', 'Arrival_Date_1', 'Ship_Name',...
%     'Vessel_Type', 'Operator'};
fileVarsXLS_c = {'IMO_LR_IHS_No_', 'LRN01', 'Ship_Name', 'Port_of_Call', ...
    'Country_of_Call', 'Arrival_Date',...
    'Sailed_Date', 'Hours_in_Port', 'Arrival_Date_1', ...
    'Vessel_Type', 'Operator'};
empty_c = cell(1, numel(fileVarsXLS_c));
% ihs_tbl = table(empty_c{:}, 'VariableNames', fileVars_c);
ihs_tbl = table(empty_c{:}, 'VariableNames', fileVarsXLS_c);

for fi = 1:numel(filename)

    % Parse File
    currFile = filename{fi};
%     t = readtable(currFile, 'ReadVariableNames', false, 'HeaderLines', 1,...
%         'DatetimeType', 'text');
    t = readtable(currFile, 'ReadVariableNames', true, ...
        'DatetimeType', 'text');
    
    % Filter missing times from table
%     t.Properties.VariableNames = fileVars_c;
    t.Properties.VariableNames = fileVarsXLS_c;
    if iscell(t.Arrival_Date)
        
        t(cellfun(@isempty, t.Arrival_Date) | cellfun(@isempty, t.Sailed_Date), :)= [];
    else
        
        t(isnan(t.Arrival_Date) | isnan(t.Sailed_Date), :)= [];
    end
    
    % Append to existing table
    ihs_tbl = [ihs_tbl; t];
end

% Calculate Idle time as difference of arrival and departures
% ihs_tbl(1, :) = [];
if iscell(ihs_tbl.Arrival_Date)
    
    ihs_tbl.Arrival_Datenum = datenum(ihs_tbl.Arrival_Date, 'mm/dd/yyyy HH:MM:SS PM');
    ihs_tbl.Sailed_Datenum = datenum(ihs_tbl.Sailed_Date, 'mm/dd/yyyy HH:MM:SS PM');
else
    
    x2m = @(xld) xld + datenum('01-01-1900', 'dd-mm-yyyy') - 2;
    ihs_tbl.Arrival_Datenum = x2m(ihs_tbl.Arrival_Date);
    ihs_tbl.Sailed_Datenum = x2m(ihs_tbl.Sailed_Date);
end
ihs_tbl.Idle_Time = ihs_tbl.Sailed_Datenum - ihs_tbl.Arrival_Datenum;

if iscell(ihs_tbl.IMO_LR_IHS_No_)
    
    ihs_tbl.IMO_LR_IHS_No_ = cellfun(@str2double, ihs_tbl.IMO_LR_IHS_No_);
end

% Activity defined as ratio between total idle time and total time
% while ~obj.iterFinished
%     
%     % Iterate
%     [obj, ii] = obj.iter;
%     if obj(ii).isPerDataEmpty
%         continue
%     end
%     
% for ii = 1:numel(obj)

while obj.iterateDD
    
    % 
    [currTable, currVessel, ddi] = obj.currentDD;
    
    % Get extents of dry-docking interval
%     intStart = min(obj(ii).DateTime_UTC);
%     intEnd = max(obj(ii).DateTime_UTC);
    intStart = min(currTable.datetime_utc);
    intEnd = max(currTable.datetime_utc);
    
    % Find corresponding subset of table
    int_tbl = ihs_tbl(ihs_tbl.IMO_LR_IHS_No_ == currVessel.IMO_Vessel_Number & ...
        ((ihs_tbl.Arrival_Datenum > intStart & ihs_tbl.Arrival_Datenum < intEnd) | ...
        (ihs_tbl.Sailed_Datenum > intStart & ihs_tbl.Sailed_Datenum < intEnd)), :);
    
    % Skip if no activity data found for this dry-docking interval
    if isempty(int_tbl)
        
%         activity(ii) = nan;
%         obj(ii).Activity = activity(ii);
        currVessel.Report.Activity(ddi) = nan; % activity; %(ii);
    else
        
        % Calculate activity from subset
%         activity(ii) = 1 - (sum(int_tbl.Idle_Time) / ...
%             (max(int_tbl.Sailed_Datenum) - min(int_tbl.Arrival_Datenum)));
%         obj(ii).Activity = activity(ii);
        currVessel.Report.Activity(ddi) = 1 - (sum(int_tbl.Idle_Time) / ...
            (max(int_tbl.Sailed_Datenum) - min(int_tbl.Arrival_Datenum)));
    end
end
% obj = obj.iterReset;