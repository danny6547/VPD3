function [obj, tbl] = applyFilters(obj, varargin)
%applyFilters Return filtered performance data
%   Detailed explanation goes here

    % Create procudure input string from inputs
    p = inputParser();
    p.addParameter('SpeedPower_Below', true, @islogical);
    p.addParameter('SpeedPower_Above', true, @islogical);
    p.addParameter('SpeedPower_Trim', true, @islogical);
    p.addParameter('SpeedPower_Disp', true, @islogical);
    p.addParameter('Reference_Seawater_Temp', true, @islogical);
    p.addParameter('Reference_Wind_Speed', true, @islogical);
    p.addParameter('Reference_Water_Depth', true, @islogical);
    p.addParameter('Reference_Rudder_Angle', true, @islogical);
    p.addParameter('SFOC_Out_Range', true, @islogical);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;
    filtCols_c = {
                 'SpeedPower_Below',...
                 'SpeedPower_Above',...
                 'SpeedPower_Trim',...
                 'SpeedPower_Disp',...
                 'Reference_Seawater_Temp',...
                 'Reference_Wind_Speed',...
                 'Reference_Water_Depth',...
                 'Reference_Rudder_Angle',...
                 'SFOC_Out_Range'};
    in_sql = obj.procInputsFromStruct(res, filtCols_c);

    % Call procedure
    [obj, tbl] = obj.call('applyFilters', in_sql);
    
    % Convert table to numeric dates
    if ~isempty(tbl)
        try
            
        tbl.datetime_utc = datenum(tbl.datetime_utc, 'dd-mm-yyyy HH:MM:SS');
        catch ee
            try tbl.datetime_utc = datenum(tbl.datetime_utc, 'dd-mm-yyyy');
                
            catch ee1
                
                rethrow(ee);
            end
        end
    end
end