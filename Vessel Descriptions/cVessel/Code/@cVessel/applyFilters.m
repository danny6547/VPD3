function [obj, tbl] = applyFilters(obj, varargin)
%applyFilters Return filtered performance data
%   [obj, tbl] = applyFilters(obj, filter, value, ...) will return in table
%   TBL data which has been filtered using the values of columns in the
%   analysis table indicated by input string FILTER when VALUE is TRUE, and
%   will return data not filtered by the corresponding filter when VALUE is
%   FALSE. Any number of FILTER, VALUE pairs may be input and FILTER must 
%   be selected from those given below. VALUE is a logical scalar. The
%   default VALUE for all FILTER is TRUE, i.e. data will be filtered by all
%   filters when only OBJ is input.
%   FILTER may be any of the following:
%     'SpeedPower_Below'
%     'SpeedPower_Above'
%     'SpeedPower_Trim'
%     'SpeedPower_Disp'
%     'Reference_Seawater_Temp'
%     'Reference_Wind_Speed'
%     'Reference_Water_Depth'
%     'Reference_Rudder_Angle'
%     'SFOC_Out_Range'
%     'Chauvenet_Criteria'
%     'Validated'

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
    p.addParameter('Chauvenet_Criteria', true, @islogical);
    p.addParameter('Validated', true, @islogical);
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
                 'SFOC_Out_Range',...
                 'Chauvenet_Criteria',...
                 'Validated'};
    in_sql = obj.procInputsFromStruct(res, filtCols_c);
    
    % Call procedure
    [obj, tbl] = obj.call('applyFilters', in_sql);
    
    % Convert table to numeric dates
    if ~isempty(tbl)
        try
            
            midnights = cellfun(@(x) length(x) == 10, tbl.datetime_utc);
            tbl.datetime_utc(midnights) = num2cell( datenum(tbl.datetime_utc(midnights), obj.DateFormStr(1:10)) );
            tbl.datetime_utc(~midnights) = num2cell( datenum(tbl.datetime_utc(~midnights), obj.DateFormStr) );
            tbl.datetime_utc = ([tbl.datetime_utc{:}])';
%         tbl.datetime_utc = datenum(tbl.datetime_utc, obj.DateFormStr);
        catch ee
            try tbl.datetime_utc = datenum(tbl.datetime_utc, 'dd-mm-yyyy');
                
            catch ee1
                
                rethrow(ee);
            end
        end
    end
end