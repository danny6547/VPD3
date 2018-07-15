function [ obj ] = selectInService(obj, varargin)
%selectInService Select InService data from database
%   Detailed explanation goes here

for oi = 1:numel(obj)

    % Input
    cols = {'Timestamp', obj(oi).Variable};
    if nargin > 1 && ~isempty(varargin{1})
        
        cols = varargin{1};
        cols = validateCellStr(cols);
        cols = obj(oi).SQL.validateColumnNames(cols);
    end
    
    % Data identified by Vessel Configuration
    vcid = [obj(oi).Configuration.Vessel_Configuration_Id];
    if isempty(vcid)
        
        continue
    end
    vcid_ch = num2str(vcid);
    
    % Select data and assign
    tab = 'CalculatedData c JOIN RawData r ON c.Raw_Data_Id = r.Raw_Data_Id';
    % cols = '*';
    where = ['c.Vessel_Configuration_Id = ', vcid_ch, ' ORDER BY Timestamp'];
    limit_ch = 20000;
    [~, tbl] = obj(oi).SQL.select(tab, cols, where, limit_ch);
    
    if ~isempty(tbl)
        obj(oi).InService = tbl;
        
    else
    
        % Check for data in raw table if none found in calcualted
        tab = 'RawData';
        cols = '*';
        vid = obj(oi).Vessel_Id;
        vid_ch = num2str(vid);
        where = ['Vessel_Id = ', vid_ch, ' ORDER BY Timestamp'];
        [~, tbl] = obj(oi).SQL.select(tab, cols, where, limit_ch);
        obj(oi).InService = tbl;
    end
end