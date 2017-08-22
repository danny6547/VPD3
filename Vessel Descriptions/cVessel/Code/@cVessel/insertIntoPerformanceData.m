function obj = insertIntoPerformanceData(obj, comment, varargin )
%insertIntoPerformanceData Insert into performance data after filtering
%   Detailed explanation goes here
    
    % Input
    validateattributes(comment, {'char'}, {'vector'}, ...
        'cVessel.insertIntoPerformanceData', 'comment', 2);

    % Get struct of valid inputs
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
    
    % Create vector of inputs
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
%     inputs_st = orderfields(res, filtCols_c);
%     inputs_c = struct2cell(inputs_st);
%     inputs_ch = strjoin(cellfun(@num2str, inputs_c, 'Uni', 0), ', ');
    paramValues_sql = obj(1).procInputsFromStruct(res, filtCols_c);
    comment_sql = obj(1).encloseFilename(comment);
    in_sql = obj(1).colSepList({comment_sql, paramValues_sql});
    
    % Call with inputs
    obj(1) = obj(1).call('insertIntoPerformanceData', in_sql);
end