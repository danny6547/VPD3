classdef cMarorkaWebAPI
    %CMARORKAWEBAPI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        URL = 'https://online.marorka.com/Odata/v1/ODataService.svc';
        UserName = '';
        Password = '';
    end
    
    properties(Hidden)
        
        Options = weboptions('UserName', 'damcl@hempel.com',...
                             'Password', '1lA02353L4L5U7dgl23leieeUO1fyjoD',...
                             'Timeout', 180);
		CurrentFileName;
        CurrentRowIdx;
        CurrentReport;
        RemainingVessel;
    end
    
    methods
    
       function obj = cMarorkaWebAPI()
    
       end
    
       function obj = saveAllVessels(obj, directory, varargin)
           
           % Input
           validateattributes(directory, {'char'}, {'vector'}, ...
               'cMarorkaWebAPI.saveAllVessels', 'directory', 2);
           
           
           % Get all static vessel data
           catDir_f = @(file) fullfile(directory, file);
           
%            particulars = obj.call('ShipDescriptions');
%            filename = catDir_f('ShipDescriptions.csv');
%            obj.saveFile(particulars.value, filename);
%            sp = obj.call('SpeedPowerBaselines');
%            filename = catDir_f('SpeedPowerBaselines.csv');
%            obj.saveFile(sp.value, filename);
%            events = obj.call('ShipEvents');
%            filename = catDir_f('ShipEvents.csv');
%            obj.saveFile(events.value, filename);
%            events = obj.call('ShipEvents');
%            filename = catDir_f('ShipEvents.csv');
%            obj.saveFile(events.value, filename);
%            sfoc = obj.call('LoadSFOCBaselines');
%            filename = catDir_f('SFOCBaselines.csv');
%            obj.saveFile(sfoc.value, filename);

           if isempty(obj.RemainingVessel)
               
               % Get all vessels
               vessels = obj.call('Ships');
               obj.RemainingVessel = vessels;
           end
           
           % Iterate vessels
           vi = 1;
           while ~isempty(obj.RemainingVessel)
           
% %                % High Freq data
               currIMO = obj.RemainingVessel.value(vi).IMONo;
%                pivot = obj.inServiceData(currIMO);
%                vesselName = strcat('Pivot_', vessels.value(vi).ShipName);
%                currPivotName = catDir_f(vesselName);
% 			   obj.CurrentFileName = currPivotName;
%                obj.CurrentRowIdx = 1;
%                writetable(struct2table(pivot), currPivotName);
%                
               % Noon data
               vesselName = strcat('Reports_', obj.RemainingVessel.value(vi).ShipName, '.xlsx');
               currReportName = catDir_f(vesselName);
			   obj.CurrentFileName = currReportName;
               obj.CurrentRowIdx = 1;
               obj.noonReports(currIMO);
               
               % Departure data
               vesselName = strcat('Departure_', obj.RemainingVessel.value(vi).ShipName, '.xlsx');
               currReportName = catDir_f(vesselName);
			   obj.CurrentFileName = currReportName;
               obj.CurrentRowIdx = 1;
               obj.departureReports(currIMO);
               
               % Arrival data
               vesselName = strcat('Arrival_', obj.RemainingVessel.value(vi).ShipName, '.xlsx');
               currReportName = catDir_f(vesselName);
			   obj.CurrentFileName = currReportName;
               obj.CurrentRowIdx = 1;
               obj.arrivalReports(currIMO);
               
               % Report Progress
               fprintf(1, ['Completed vessel ', num2str(vi), ', IMO: ',...
                   num2str(obj.RemainingVessel.value(vi).IMONo) ,'.\n']);
               
               % Re-assign
               obj.RemainingVessel.value(vi) = [];
%                vi = vi + 1;
           end
       end
       
       function data = inServiceData(obj, imo)
       
           % Input
           obj.validateimo(imo);
           
           % Command
           funcname = 'ShipPivots';
           funcInput = ['$filter=IMONo eq ', num2str(imo), ...
               ' &$orderby=DateTime desc'];
           data = iterLink(obj, funcname, funcInput);
           tbl = struct2table(data);
%            writetable(struct2table(pivot), currPivotName);
           
%            out = obj.call('ShipPivots', funcInput);
%            data = out.value;
%            
%            while isfield(out, 'odata_nextLink')
%                
%                funcInput = out.odata_nextLink;
%                funcInput = strrep(funcInput, 'ShipPivots?', '');
%                out = obj.call('ShipPivots', funcInput);
%                datai = out.value;
%                data = [data; datai];
%            end
       end
       
       function tbl = noonReports(obj, imo)
       % noonReports Table containing all noon reports for a vessel
       
       % Input
       obj.validateimo(imo);
       
       % Command
       funcname = 'Reports';
       funcInput = ['$filter=IMONo eq ', num2str(imo), ...
               ' and ReportType eq ''Daily Report'' '...
               '&$orderby=StartDateTimeGMT desc'];
       var = obj.dailyReportVars;
       tbl = obj.iterLink(funcname, funcInput, var);
       
       % Create output table and assign values
       % [tbl, missingReports] = obj.tabulateReportData(reports, var);
       end
       
       function [tbl, missing] = departureReports(obj, imo)
       
       % Input
       obj.validateimo(imo);
       
       % Get reportID for all departures
       funcname = 'Reports';
       funcInput = ['$filter=IMONo eq ', num2str(imo), ...
           ' and ReportType eq ''Departure Report'' '...
           '&$orderby=StartDateTimeGMT desc'];
       var = obj.departureReportVars;
       [tbl, missing] = obj.iterLink(funcname, funcInput, var);
       end
       
       function [tbl, missing] = arrivalReports(obj, imo)
       
       % Input
       obj.validateimo(imo);
       
       % Get reportID for all departures
       funcname = 'Reports';
       funcInput = ['$filter=IMONo eq ', num2str(imo), ...
           ' and ReportType eq ''Arrival Report'' '...
           '&$orderby=StartDateTimeGMT desc'];
       var = obj.arrivalReportVars;
       [tbl, missing] = obj.iterLink(funcname, funcInput, var, '', false);
       
       % Create table out of all departure reports
%        [tbl, missing] = obj.tabulateReportData(reports, var);
       end
    end
    
    methods(Hidden, Static)
       
       function validateimo(imo)
           
           validateattributes(imo, {'numeric'}, ...
               {'real', 'positive', 'scalar', 'integer'}, ...
               'cMarorkaWebAPI.inServiceData', 'imo', 2);
       end
       
       function saveFile(st, filename)
       % saveFile Write structure to file, column headers matching fields
       
           tbl = struct2table(st);
           writetable(tbl, filename);
       end
       
        [var] = dailyReportVars()
        [var] = arrivalReportVars()
        [var] = commonReportVars()
        [var] = departureReportVars()
    end
    
    methods(Hidden)
       
       function [out, url] = call(obj, funcname, varargin)
           
           % Input
           validateattributes(funcname, {'char'}, {'vector'},...
               'cMarorkaWebAPI.call', 'funcname', 2);
           
           funcinput = '';
           if nargin > 2
               
               funcinput = varargin{1};
               validateattributes(funcinput, {'char'}, {'vector'},...
                   'cMarorkaWebAPI.call', 'funcinput', 3);
           end
           
           % Combine function and input with api url
           url = strcat(obj.URL, '/', funcname, '?', funcinput);
           
           % Send URL to server
           opts = obj.Options;
           out = webread(url, opts);
       end
       
       function [tbl, missing] = iterLink(obj, funcname, funcinput, varargin)
       % iterLink Iteratively call API while links are returned
           
% 			if nargin > 4
% 			
% 				var = varargin{2};
% 				validateCellStr(var, 'cMarorkaWebAPI.iterLink', 'var', 5);
% 			end
		   
           out = obj.call(funcname, funcinput);
           sti = out.value;
           
           [tbl, missing] = obj.tabulateReportData(sti, varargin{:});
           
           while isfield(out, 'odata_nextLink')
               
               funcinput = out.odata_nextLink;
               funcinput = strrep(funcinput, funcname, '');
               out = obj.call(funcname, funcinput);
               sti = out.value;
               
               [tbl, missingi] = obj.tabulateReportData(sti, varargin{:});
               missing = [missing; missingi];
           end
       end
       
       function [tbl, missing] = tabulateReportData(obj, reports, var, varargin)
           
       % Input
       validateattributes(reports, {'struct'}, {'vector'}, ...
           'cMarorkaWebAPI.tabulateReportData', 'reports', 2);
       validateCellStr(var, 'cMarorkaWebAPI.tabulateReportData',...
           'reports', 2);
       
       additionalFuncInput = '';
       if nargin > 3 && ~isempty(additionalFuncInput)
           
           additionalFuncInput = varargin{1};
           validateattributes(additionalFuncInput, {'char'}, {'vector'}, ...
               'cMarorkaWebAPI.tabulateReportData', 'funcinput', 4);
       end
       
       filter_l = true;
       if nargin > 4
           
           filter_l = varargin{2};
           validateattributes(filter_l, {'logical'}, {'scalar'}, ...
               'cMarorkaWebAPI.tabulateReportData', 'filter', 5);
       end
       
       % Pre-allocate outputs
       emptyReports_l = false(1, numel(reports));
       nVar = numel(var);
       emptyCell_c = repmat({{}}, 1, nVar);
       tbl = cell2table(emptyCell_c, 'VariableNames', var);
       tick = tic;
       
       for ri = 1:numel(reports)
           
           % Call this reports data
           currReport = reports(ri);
           fprintf(1, ['Time: ', datestr(now), '. ', ...
                'Report number ', num2str(ri),...
                ' / ', num2str(numel(reports)),...
               '  ReportId: ', num2str(currReport.ReportId), '\n']);
           seapassage_ch = '''Sea Passage''';
           reporti = obj.call('ReportData', ...
               ['$filter=ReportId eq ' num2str(currReport.ReportId),...
               additionalFuncInput]); % ' and StateName eq' seapassage_ch]);
           
           val = reporti.value;
           if filter_l

               % Combine useful data into temporary cell, assign into output
               if isempty(val)

                   emptyReports_l(ri) = true;
                   continue
               end

               % Deal with case of multiple ValueDescriptions in same report
               % where some have empty MeasuredValue
               temp_c = {val.MeasuredValue};
               empty_l = cellfun(@isempty, temp_c);
               val(empty_l) = [];

               % Deal with case where values are given for both States of "Sea
               % Passage" and "Anchor/Waiting"
               anchor_l = strcmp('Anchor/Waiting', {val.StateName});
               val(anchor_l) = [];

               % Deal with case of multiple ValueDescriptions in same report
               % with different LapTimes
               allLapTime = unique([val.LapTime]);
               desiredLapTime = max(allLapTime);
               filter = [val.LapTime] ~= desiredLapTime;
               val(filter) = [];

               % Skip if report empty
               if isempty(val)

                   continue
               end
               
               % Deal with case of empty value description
               temp_c = {val.ValueDescription};
               empty_l = cellfun(@isempty, temp_c);
               val(empty_l) = [];

               % Iterate invalid
               [~, coli] = ismember(genvarname({val.ValueDescription}), var);
               invalidI = find(~coli);
               val2remove_l = false(1, length(val));
               for ii = 1:numel(invalidI)

                   matchingMeasurements_l = strcmp(...
                       val(invalidI(ii)).ValueDescription, {val.ValueDescription});
                   emptyMeasured = cellfun(@(x) isequal(x, '                     0.00'), {val.MeasuredValue});
                   emptyReported = cellfun(@(x) isequal(x, '                     0.00'), {val.ReportedValue});
                   val2remove = matchingMeasurements_l & emptyMeasured & emptyReported;
                   val2remove_l = val2remove_l | val2remove;
               end
               val(val2remove_l) = [];

               % Deal with case of multiple ValueDescription with either
               % non-empty MeasuredValue or ReportedValue at matching Times and
               % LapTimes
               [~, idx2keep] = unique({val.ValueDescription});
               val = val(idx2keep);
           end
           
           if ~isempty([val.ValueDescription])
               
               [~, coli] = ismember(genvarname({val.ValueDescription}), var);
               temp_c = {val.MeasuredValue};
               tbl(:, coli) = temp_c;
           end
           tbl.StartDateTimeGMT(1) = { val(1).StartDateTimeGMT };
           tbl.EndDateTimeGMT(1) = { val(1).EndDateTimeGMT };
           tbl.IMONo(1) = {val(1).IMONo};
           tbl.ReportId(1) = {val(1).ReportId};
           
           % Write into file
           obj = obj.appendTable(tbl);
       end
       toc(tick);
       
       % Write column names into fiel
       obj.writeTableColumns(tbl);
       
       % Assign empty report
       missing = reports(emptyReports_l);
       end
	   
	   function obj = appendTable(obj, tbl)
	   
			filename = obj.CurrentFileName;
			
			% Build range string
			rowIdx = obj.CurrentRowIdx + 1;
			range_ch = strcat('A', num2str(rowIdx));
			
			% Append
			writetable(tbl, filename, 'Range', range_ch, ...
                'WriteVariableNames', false);
			
			% Iterate
			obj.CurrentRowIdx = obj.CurrentRowIdx + 1;
       end
       
       function obj = writeTableColumns(obj, tbl)
           
		   filename = obj.CurrentFileName;
           writetable(tbl([], :), filename, 'Range', 'A1',...
               'WriteVariableNames', true);
       end
    end
	
	methods
		
		function obj = set.CurrentFileName(obj, filename)
			
			validateattributes(filename, {'char'}, {'vector'});
			obj.CurrentRowIdx = 1;
			obj.CurrentFileName = filename;
		end
	end
end