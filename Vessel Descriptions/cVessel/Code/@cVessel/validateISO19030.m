function [obj] = validateISO19030(obj, measfile, spfile, windfile, varargin)
%validate Create files use in input of ISO19030 Test Software
%   Detailed explanation goes here

% Inputs
% validateattributes(measfile, {'char'}, {'vector'}, ...
%     'cVessel.validateISO19030', 'measfile', 2);
validateCellStr(measfile, 'cVessel.validateISO19030', 'measfile', 2);
validateCellStr(spfile, 'cVessel.validateISO19030', 'spfile', 3);
validateCellStr(windfile, 'cVessel.validateISO19030', 'windfile', 4);

createSpFile_l = isempty(spfile);

filterNan_l = false;
if nargin > 4 && ~isempty(varargin{1})
    
    filterNan_l = varargin{1};
    validateattributes(filterNan_l, {'logical'}, {'scalar'}, ...
        'cVessel.validateISO19030', 'filterNan_l', 5);
end

dir_l = false;
if nargin > 5 && ~isempty(varargin{2})
    
    dir_ch = varargin{2};
    validateattributes(dir_ch, {'char'}, {'vector'}, ...
        'cVessel.validateISO19030', 'dir_ch', 6);
    dir_l = true;
end

% numMeasNumVessels_l = isequal(length(measfile), size(obj, 2));
% num

scalarVessel_l = size(obj, 2) == 1;
if ~scalarVessel_l
    
    errid = 'cV:ScalarVesselMethod';
    errmsg = 'ISO19030 can only be verified for one vessel at a time.';
    error(errid, errmsg);
end

% Iterate over vessels
while ~obj.iterFinished
    
    [obj, ~, vesselI] = obj.iterVessel;
    currObj = obj(vesselI);
    
    currVessel = currObj(1);
    
    % Generate speed, power files for this vessel
    if createSpFile_l
       
        sp_v = currVessel.SpeedPower;
        disp_v = [sp_v.Displacement];
        trim_v = [sp_v.Trim];
        
        spfile = arrayfun(@(x, y) [strrep([num2str(x), ' ', num2str(y)], ...
            '.', ','), '.csv'], disp_v, trim_v, 'Uni', 0);
        
        % Prepent directory string to file names
        if dir_l
            spfile = fullfile(dir_ch, spfile);
        end
    end
    
    dataFields_c = {'DateTime_UTC',...
                    'Performance_Index',...
                    'Speed_Index'};
    for di = 1:numel(dataFields_c)
        currField = dataFields_c{di};
        currVessel.(currField) = [currObj.(currField)];
    end
    
    if ~isempty(measfile)
        
        % Create raw data file
        currVessel.DryDockInterval = [];
        isoCols_c = {'DateTime_UTC',...
                    'Speed_Through_Water',...
                    'ME_1_Load',... Delivered Power
                    'ME_1_Speed_RPM',... Shaft Revs
                    'Wind_Force_Kn',... Wind Speed knts
                    'Wind_Dir',... Wind dir sector 1 to 7
                    'Temperature_Ambient',... Air Temp
                    'Speed_GPS',... SOG
                    'Entry_Made_By_1',... Heading
                    'Entry_Made_By_1',... Rudder Angle
                    'Water_Depth',... Water depth
                    'Draft_Actual_Fore',... Draft
                    'Draft_Actual_Aft',... Draft
                    'Draft_Displacement_Actual',... Disp
                    'Temperature_Water'... Water temp
                    };
        [~, rawTbl] = currVessel.rawData;
        isoTbl = rawTbl(:, isoCols_c);
        isoTbl.DateTime_UTC = datestr(isoTbl.DateTime_UTC, ...
            'yyyy-mm-dd HH:MM:SS');
        
        if filterNan_l

            % Remove any all-NAN cols from filter first
            missing_l = ismissing(isoTbl,{NaN});
            missingCols_l = all(missing_l);

            % Remove remaining rows with NAN values
            missingRows_l = any(missing_l(:, ~missingCols_l), 2);
            isoTbl(missingRows_l, :) = [];
        end
        
        writetable(isoTbl, measfile, 'FileType', 'text', ...
            'WriteVariableNames', false);
    end
    
    % Create speed power file
    for si = 1:numel(spfile)
        
        currFile = spfile{si};
        currSp = currVessel.SpeedPower(si);
        spTbl = table(currSp.Speed(:), currSp.Power(:));
        writetable(spTbl, currFile, 'FileType', 'text', ...
            'WriteVariableNames', false);
    end
    
    if ~isempty(windfile)
        
        % Create wind file
        windCoeff = currVessel.WindCoefficient;
        windTbl = table(windCoeff.Direction(:), windCoeff.Coefficient(:));
        writetable(windTbl, windfile, 'FileType', 'text', ...
                'WriteVariableNames', false);
    end
    % Replace radix to match local
%     files = [spfile, windfile];
%     oldradix = {',', '.'};
%     newradix = {';', ','};
%     for fi = 1:numel(files)
%         
%         filename = files{fi};
%         fileRep( filename, oldradix, newradix );
%     end
end

obj = obj.iterReset;