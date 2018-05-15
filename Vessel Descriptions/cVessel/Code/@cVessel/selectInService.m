function [ obj ] = selectInService(obj, varargin)
%selectInService Select InService data from database
%   Detailed explanation goes here

% Input


% Data identified by Vessel Configuration
vcid = [obj.Configuration.Vessel_Configuration_Id];
vcid_ch = num2str(vcid);

% Select data and assign
tab = 'CalculatedData c JOIN RawData r ON c.Raw_Data_Id = r.Raw_Data_Id';
cols = '*';
where = ['c.Vessel_Configuration_Id = ', vcid_ch];
[~, tbl] = obj.SQL.select(tab, cols, where);
obj.InService = tbl;

end