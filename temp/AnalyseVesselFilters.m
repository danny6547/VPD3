%% Input
imo = [];
rawFile = '';
calculatedFile = '';
outFile = '';
DDStart = '';
DDEnd = '';
lbp = [];
%%
% Check if schema built
obj = cMySQL();
[~, isTab] = obj.isTable('Vessels');

if ~isTab
    
    % Build DB
    obj_db = cDB();
    obj_db.LoadPerformance = false;
    obj_db.LoadRaw = false;
    obj_db.RunISO = false;
    obj_db.InsertStatic = false;
    
    obj_db.createHullPer;
end

% Create object
obj = cVessel();
obj.IMO_Vessel_Number = imo;
obj.Particulars.LBP = lbp;
obj.insertIntoVessels();

% Check if vessel in DB
[~, isTab] = obj.isTable('tempRawISO');
inTab = false;
if isTab
    
    [~, inTab_c] = obj.execute(['SELECT COUNT(*) > 0 FROM tempRawISO WHERE IMO_Vessel_Number = ' num2str(imo)]);
    inTab_ch = [inTab_c{:}];
    inTab = str2double(inTab_ch);
end

if ~inTab
    
    % Check if files have been combined
    outExists_l = exist(outFile, 'file') == 2;
    
    if ~outExists_l
        
        % Combine exported files into one
        combineCSVExportScript(rawFile, calculatedFile, outFile, imo);
    end
    
    % Check outfile has only columns needed
    checkCSVExportScript(outFile, imo);
    
    % Load exported file
    obj.loadCSVExportScript(outFile, imo);
end

%% Update selected filters, then apply to object data
obj = obj.updateFilters('SpeedPower_Lower', 7E3);
obj = obj.updateFilterDisp(0.95, 1.05);
obj = obj.updateFilterTrim(0.002, 0.002);
[obj, tbl] = obj.applyFilters('SFOC_Out_Range', false, ...
    'SpeedPower_Trim', false, 'SpeedPower_Disp', false, ...
    'SpeedPower_Below', false, 'SpeedPower_Above', false, ...
    'Reference_Seawater_Temp', false, 'Reference_Wind_Speed', false, ...
    'Reference_Water_Depth', false, 'Reference_Rudder_Angle', false);

%% Print number of data found, return if zero
nData = height(tbl);
if nData == 0
    
    msg = 'No data remains for this choice of filters.';
    disp(msg);
    return
else
    
    nData_ch = num2str(nData);
    msg = [nData_ch, ' data remain after filtering.'];
    disp(msg);
end

% % Assign new table to object
% ddStart = datenum(DDStart, 'dd-mm-yyyy');
% ddEnd = datenum(DDEnd, 'dd-mm-yyyy');
% beforeDD_l = tbl.datetime_utc < ddStart;
% afterDD_l = tbl.datetime_utc > ddEnd;
% 
% dd2 = any(beforeDD_l) && any(afterDD_l);
% if dd2
%     
%     obj(1, 1).DateTime_UTC = tbl.datetime_utc(beforeDD_l);
%     obj(1, 1).Speed_Index = tbl.speed_loss(beforeDD_l);
%     obj(2, 1).DateTime_UTC = tbl.datetime_utc(afterDD_l);
%     obj(2, 1).Speed_Index = tbl.speed_loss(afterDD_l);
% else
%     

ddd = cVesselDryDockDates();
ddd = ddd.assignDates(DDStart, DDEnd, 'dd-mm-yyyy');
obj.DryDockDates = ddd;
obj.InService = table2timetable(tbl);
%     obj.InService.Speed_Index = tbl.speed_loss;
% end

%% Recalculate report parameters
obj = obj.inServicePerformance();
[obj, reg_st] = obj.regressions(1);
[obj, avg_st] = obj.movingAverages(365.25, true, true);
[obj, f_h] = obj.plotPerformanceData();
set(f_h(end), 'WindowStyle', 'Docked');

% if dd2
%     
%     slop = reg_st(2).Coefficients(1) * 365.25 * 1e2
%     ddImprovement = (avg_st(2).Duration.Average - avg_st(1).Duration.Average) * 1e2
% end