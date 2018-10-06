function obj = updateWindResistanceRelative(obj, vc)
% 

% Get Variables
tab = 'tempRawISO';
cols_c = {'Timestamp', 'Air_Density', ...
    'Transverse_Projected_Area_Current',...
    'Relative_Wind_Speed_Reference',...
    'Relative_Wind_Direction_Reference'};
[~, iso_tbl] = obj.SQL.select(tab, cols_c);

% Find nearest coefficient
% currIMO = iso_tbl.vessel_id(1);
windId = vc.Wind_Coefficient_Model_Id;
windCols_c = {'Direction', 'Coefficient'};
whereModel_sql = ['Wind_Coefficient_Model_Id = ', num2str(windId)];
windTab = 'WindCoefficientModelValue';
[~, wind_tbl] = vc.SQL.select(windTab, windCols_c, whereModel_sql);
if isempty(wind_tbl)
    
    errid = 'cVISO:NoWindCoeffsFound';
    errmsg = ['Cannot update wind resistance coefficients because wind resistance model with '...
        'id ', num2str(modelID), ' is empty'];
    error(errid, errmsg);
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
resCol = {'Timestamp', 'Wind_Resistance_Relative'};
% midnights_l = cellfun(@(x) length(x) == 10, iso_tbl.timestamp);
% sqldates_c = iso_tbl.timestamp;
% sqldates_c(midnights_l) = cellfun(@(x) [x, ' 00:00:00'], ...
%     iso_tbl.timestamp(midnights_l), 'Uni', 0);
% 
% sqldates_ch = datestr(datenum(sqldates_c, obj(1).SQL.DateFormStr),...'dd-mm-yyyy HH:MM:SS'),...
%     'yyyy-mm-dd HH:MM');
sqldates_dt = datetime(iso_tbl.timestamp);
sqldates_ch = datestr(sqldates_dt, 'yyyy-mm-dd HH:MM');
sqldates_c = cellstr(sqldates_ch);
resData_c = [sqldates_c, num2cell(res)];

[ resCol, resData_c ] = obj.catNonNullCols(resCol, resData_c, vc);

% Create temp file and load, if data too big
if size(resData_c, 1) > 5e4

   tempFile = fullfile(cd, 'tempWindRes.csv');
   try

       tempTab = cell2table(resData_c);
       nan_l = isnan(tempTab.resData_c3);
       tempTab.resData_c3 = num2cell(tempTab.resData_c3);
       tempTab.resData_c3(nan_l) = {'NULL'};
       tempTabName = 'tempTempRawISO';
       obj.SQL = obj.SQL.drop('TABLE', tempTabName, true);
       obj.SQL.createLike('tempTempRawISO', 'tempRawISO');
       writetable(tempTab, tempFile, 'WriteVariableNames', false);

   catch ee

       delete(tempFile);
       rethrow(ee);
   end

   obj.SQL.loadInFileDuplicate(tempFile, resCol, tempTabName, 'tempRawISO');
   delete(tempFile);

else

   obj.SQL.insertValuesDuplicate(tab, resCol, resData_c);
end
end
