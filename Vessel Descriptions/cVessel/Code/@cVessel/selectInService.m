function [ obj ] = selectInService(obj, varargin)
%selectInService Select InService data from database
%   Detailed explanation goes here

% Input
cols = '*';
if nargin > 1 && ~isempty(varargin{1})
    
    cols = varargin{1};
    cols = validateCellStr(cols);
    cols = obj.SQL.validateColumnNames(cols);
end

% Data identified by Vessel Configuration
vcid = [obj.Configuration.Vessel_Configuration_Id];
vcid_ch = num2str(vcid);

% Select data and assign
tab = 'CalculatedData c JOIN RawData r ON c.Raw_Data_Id = r.Raw_Data_Id';
% cols = '*';
where = ['c.Vessel_Configuration_Id = ', vcid_ch];
[~, tbl] = obj.SQL.select(tab, cols, where);
obj.InService = tbl;

end