function [ obj ] = updateDisplacement(obj, vc )
%updateDisplacement Summary of this function goes here
%   Detailed explanation goes here

    % Get table with displacements for this vessel
%     imo = obj.IMO_Vessel_Number;
    dispCols_c = {'Draft_Mean', 'Trim', 'Displacement', 'lcf', 'tpc'};
    modelID = vc.Displacement_Model_Id;
    dispWhere_ch = ['Displacement_Model_Id = ', num2str(modelID) ' ORDER BY Draft_Mean ASC'];
    [~, disp_tbl] = vc.SQL.select('DisplacementModelValue', dispCols_c, dispWhere_ch);
    
    % If no displacement data in DB for this vessel, time to get creative
    invent_l = isempty(disp_tbl);
    if invent_l
        
        errid = 'cVISO:NoDisplacementsFound';
        errmsg = ['Cannot update displacements because displacement with '...
            'model id ', num2str(modelID), ' is empty'];
        error(errid, errmsg);
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
        
        [~, dates_v, disp_v] = obj.approximateDisplacement(vc, disp_tbl);
        
    else
        
        % Do nothing.... to make testExternal work without displacement
        % table inputs
        
    end
    
    % Convert displacement volume from displacement table to mass of
    % displaced fluid (to match values currently in speedpowercoefficients)
%     disp_v = disp_v*1.025*1e3;
    
    % Insert values duplicate
%     imo_v = repmat(imo, length(dates_v), 1);
    dates_c = cellstr(datestr(dates_v, 'yyyy-mm-dd HH:MM:SS'));
%     imo_c = num2cell(imo_v);
    vid = vc.Vessel_Id;
    vid_c = repmat({vid}, numel(dates_c), 1);
    vcid = vc.Model_ID;
    vcid_c = repmat({vcid}, numel(dates_c), 1);
    disp_c = num2cell(disp_v);
%     raw_c = num2cell(raw_v);
    
    outCols_c = {'Timestamp', 'Vessel_Id', 'Vessel_Configuration_Id', 'Displacement'};
    outData_m = [dates_c(:), vid_c(:), vcid_c(:), disp_c(:)];
    evalTab_ch = 'tempRawISO';
    obj = obj.SQL.insertValuesDuplicate(evalTab_ch, outCols_c, outData_m);
end