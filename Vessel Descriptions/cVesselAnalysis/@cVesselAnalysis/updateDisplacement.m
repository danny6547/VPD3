function [ obj ] = updateDisplacement(obj, vc )
%updateDisplacement Summary of this function goes here
%   Detailed explanation goes here

    % Get table with displacements for this vessel
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
    
    % Insert values duplicate
    dates_c = cellstr(datestr(dates_v, 'yyyy-mm-dd HH:MM:SS'));
    disp_c = num2cell(disp_v);
    
    outCols_c = {'Timestamp', 'Displacement'};
    outData_m = [dates_c(:), disp_c(:)];
    evalTab_ch = 'tempRawISO';
    
    [ outCols_c, outData_m ] = obj.catNonNullCols(outCols_c, outData_m, vc);
    obj.SQL = obj.SQL.insertValuesDuplicate(evalTab_ch, outCols_c, outData_m);
    
    % Temp code to deal with issue where Timestamp '0000-00-00 00:00:00' is
    % sometimes in table after insert duplicate
    obj.SQL.call('removeInvalidRecords');
end