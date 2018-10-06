function obj = updateWindResistanceRelative(obj)
% 

% Get Variables
tab = 'tempRawISO';
cols_c = {'IMO_Vessel_Number', 'DateTime_UTC', 'Air_Density', ...
    'Transverse_Projected_Area_Current',...
    'Relative_Wind_Speed_Reference',...
    'Relative_Wind_Direction_Reference'};
[~, iso_tbl] = obj.select(tab, cols_c);

% Find nearest coefficient
currIMO = iso_tbl.imo_vessel_number(1);
windCols_c = {'Direction', 'Coefficient'};
whereModel_sql = ['ModelID = (SELECT Wind_Model_ID FROM Vessels '...
    'WHERE IMO_Vessel_Number = ', num2str(currIMO), ')'];
windTab = 'windcoefficientdirection';
[~, wind_tbl] = obj.select(windTab, windCols_c, whereModel_sql);
if isempty(wind_tbl)
    return
end
reldir = iso_tbl.relative_wind_direction_reference;
dir = wind_tbl.direction;
coeffs = wind_tbl.coefficient;
[~, coeffi] = FindNearestInVector(reldir, dir);
coeff = coeffs(coeffi);

% Find resistance
rho = iso_tbl.air_density;
At = iso_tbl.transverse_projected_area_current;
relspeed = iso_tbl.relative_wind_speed_reference;
res = 0.5 .* rho .* At .* coeff .* relspeed.^2;

% Insert update resistance
resCol = {'IMO_Vessel_Number', 'DateTime_UTC', ...
    'Wind_Resistance_Relative'};
midnights_l = cellfun(@(x) length(x) == 10, iso_tbl.timestamp);
sqldates_c = iso_tbl.timestamp;
sqldates_c(midnights_l) = cellfun(@(x) [x, ' 00:00:00'], ...
    iso_tbl.timestamp(midnights_l), 'Uni', 0);

sqldates_ch = datestr(datenum(sqldates_c, obj(1).DateFormStr),...'dd-mm-yyyy HH:MM:SS'),...
    'yyyy-mm-dd HH:MM');
sqldates_c = cellstr(sqldates_ch);
resData_c = [num2cell(iso_tbl.imo_vessel_number),...
    sqldates_c, num2cell(res)];

% Create temp file and load, if data too big
if size(resData_c, 1) > 5e4

   tempFile = fullfile(cd, 'tempWindRes.csv');
   try

       tempTab = cell2table(resData_c);
       nan_l = isnan(tempTab.resData_c3);
       tempTab.resData_c3 = num2cell(tempTab.resData_c3);
       tempTab.resData_c3(nan_l) = {'NULL'};
       tempTabName = 'tempTempRawISO';
       obj = obj.drop('TABLE', tempTabName, true);
       obj.createLike('tempTempRawISO', 'tempRawISO');
       writetable(tempTab, tempFile, 'WriteVariableNames', false);

   catch ee

       delete(tempFile);
       rethrow(ee);
   end

   obj.loadInFileDuplicate(tempFile, resCol, tempTabName, 'tempRawISO');
   delete(tempFile);

else

   obj.insertValuesDuplicate(tab, resCol, resData_c);
end
end
