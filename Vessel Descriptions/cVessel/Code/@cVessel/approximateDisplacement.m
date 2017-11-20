function [ obj, dates_v, disp_v ] = approximateDisplacement(obj, disp_tbl)
%approximateDisplacement Summary of this function goes here
%   Detailed explanation goes here

    % Get LPP
    lbp = obj.LBP;
    
    % Get time-series data
    evalTab_ch = 'tempRawISO';
    evalCols_c = {'DateTime_UTC', 'Static_Draught_Fore', ...
        'Static_Draught_Aft', 'Trim'};
    [~, eval_tbl] = obj.select(evalTab_ch, evalCols_c);
    
    % Filter mysterious rows of all nan values from table
    filter_l = cellfun(@(x) isnumeric(x) && isnan(x), eval_tbl.datetime_utc);
    eval_tbl(filter_l, :) = [];
    
    % Get time-series columns
    evalDraft_v = mean([eval_tbl.static_draught_fore, ...
        eval_tbl.static_draught_aft], 2);
    evalTrim_v = eval_tbl.trim;
    
    % Get displacement table columns
    refDraft_v = disp_tbl.draft_mean;
    lcf = disp_tbl.lcf;
    tpc = disp_tbl.tpc;
    displacement = disp_tbl.displacement;
    
    % Get nearest drafts in displacements to those in time-series table
    [~, nearDraftI_v, diffDraft_v] = FindNearestInVector(evalDraft_v, refDraft_v);
    
    % Output dates
    dates_v = datenum(eval_tbl.datetime_utc, obj(1).DateFormStr); % 'dd-mm-yyyy HH:MM:SS');
    disp_v = nan(height(eval_tbl), 1);
    
    for di = 1:height(eval_tbl)
        
        % Next-Lowest Draft
        if diffDraft_v(di) < 0 && nearDraftI_v(di) ~= 1
            
            nearDraftI_v(di) = nearDraftI_v(di) - 1;
        end
        currIdx = nearDraftI_v(di);
        
        % Trim correction
        currLcf = lcf(currIdx);
        currTpc = tpc(currIdx);
        currTrim = evalTrim_v(di);
        trimCorr = currLcf * currTrim / lbp;
        
        % Look up displacement, TPC at nearest measured draft
        currDisp = displacement(currIdx);
        
        % Calculate displacement at equivalent draft
        corrDisp = currDisp + (currTpc * trimCorr);
        
        % Assign out
        disp_v(di) = corrDisp;
    end
end