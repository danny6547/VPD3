function [ obj ] = updateDisplacement(obj )
%updateDisplacement Summary of this function goes here
%   Detailed explanation goes here

    % Get table with displacements for this vessel
    imo = obj.IMO_Vessel_Number;
    dispCols_c = {'Draft_Mean', 'Trim', 'Displacement', 'lcf', 'tpc'};
    modelID = obj.Displacement.ModelID;
    dispWhere_ch = ['ModelID = ', num2str(modelID) ' ORDER BY Draft_Mean ASC'];
    [~, disp_tbl] = obj.select('Displacement', dispCols_c, dispWhere_ch);
    
    % If no displacement data in DB for this vessel, time to get creative
    invent_l = isempty(disp_tbl);
    if invent_l
        
        obj.call('updateDisplacement', num2str(imo));
    return
    end
    
    refTrim_v = disp_tbl.trim;
    lcf = disp_tbl.lcf;
    tpc = disp_tbl.tpc;
    
    % Decide which displacement method to take
    interp_l = ~all(isnan(refTrim_v));
    approx_l = ~all(isnan(lcf)) && ~all(isnan(tpc));
    
    if interp_l
        
        [~, dates_v, disp_v] = obj.interpolateDisplacement(disp_tbl);
        
    elseif approx_l
        
        [~, dates_v, disp_v] = obj.approximateDisplacement(disp_tbl);
    end
    
    % Convert displacement volume from displacement table to mass of
    % displaced fluid (to match values currently in speedpowercoefficients)
%     disp_v = disp_v*1.025*1e3;
    
    % Insert values duplicate
    imo_v = repmat(imo, length(dates_v), 1);
    dates_c = cellstr(datestr(dates_v, 'yyyy-mm-dd HH:MM:SS'));
    imo_c = num2cell(imo_v);
    disp_c = num2cell(disp_v);
    
    outCols_c = {'IMO_Vessel_Number', 'DateTime_UTC', 'Displacement'};
    outData_m = [imo_c(:), dates_c(:), disp_c(:)];
    evalTab_ch = 'tempRawISO';
    obj = obj.insertValuesDuplicate(evalTab_ch, outCols_c, outData_m);
end