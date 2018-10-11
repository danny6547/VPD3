classdef cMarorkaWebAPI
    %CMARORKAWEBAPI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        URL = 'https://online.marorka.com/Odata/v1/ODataService.svc';
        UserName = '';
        Password = '';
        MaxRowsPerFile = 1e5;
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
           particulars = obj.call('ShipDescriptions');
           filename = obj.catDir('ShipDescriptions.csv');
           obj.saveFile(particulars.value, filename);
           sp = obj.call('SpeedPowerBaselines');
           filename = obj.catDir('SpeedPowerBaselines.csv');
           obj.saveFile(sp.value, filename);
           events = obj.call('ShipEvents');
           filename = obj.catDir('ShipEvents.csv');
           obj.saveFile(events.value, filename);
           events = obj.call('ShipEvents');
           filename = obj.catDir('ShipEvents.csv');
           obj.saveFile(events.value, filename);
           sfoc = obj.call('LoadSFOCBaselines');
           filename = obj.catDir('SFOCBaselines.csv');
           obj.saveFile(sfoc.value, filename);

           if isempty(obj.RemainingVessel)
               
               % Get all vessels
               vessels = obj.call('Ships');
               obj.RemainingVessel = vessels;
           end
           
           % Iterate vessels
           while ~isempty(obj.RemainingVessel.value)
           
               % High Freq data
               currIMO = obj.RemainingVessel.value(1).IMONo;
               
               vesselName = obj.RemainingVessel.value(1).ShipName;
               filename = fullfile(directory, ['Pivots_', vesselName, '.csv']);
               filterName = 'IMONo';
               filterValue = num2str(currIMO);
               if isempty(currIMO)
                   
                   filterName = 'ShipName';
                   filterValue = ['''', vesselName, ''''];
               end
               obj.inServiceData(filename, filterValue, filterName);
               
               % Noon data
               vesselName = strcat('Reports_', obj.RemainingVessel.value(1).ShipName, '.xlsx');
               currReportName = obj.catDir(vesselName);
			   obj.CurrentFileName = currReportName;
               obj.CurrentRowIdx = 1;
               obj.noonReports(currIMO);
               
               % Departure data
               vesselName = strcat('Departure_', obj.RemainingVessel.value(1).ShipName, '.xlsx');
               currReportName = obj.catDir(vesselName);
			   obj.CurrentFileName = currReportName;
               obj.CurrentRowIdx = 1;
               obj.departureReports(currIMO);
               
               % Arrival data
               vesselName = strcat('Arrival_', obj.RemainingVessel.value(1).ShipName, '.xlsx');
               currReportName = obj.catDir(vesselName);
			   obj.CurrentFileName = currReportName;
               obj.CurrentRowIdx = 1;
               obj.arrivalReports(currIMO);
               
               % Re-assign
               obj.RemainingVessel.value(1) = [];
               
               % Report Progress
               fprintf(1, [datestr(now), '. Completed IMO: ', num2str(currIMO), ', ',...
                   num2str(numel(obj.RemainingVessel.value)) ' remaining.\n']);
           end
       end
       
       function data = inServiceData(obj, filename, filterval, varargin)
       
           % Input
           validateattributes(filterval, {'char'}, {'vector'},...
               'cMarorkaWebAPI.inServiceData', 'filterValue', 3);
           
           filterName = 'IMONo';
           if nargin > 3
               filterName = varargin{1};
               validateattributes(filterName, {'char'}, {'vector'},...
                   'cMarorkaWebAPI.inServiceData', 'filterName', 4);
           end
           if strcmpi(filterName, 'IMONo')
               
               obj.validateimo(str2double(filterval));
           end
           
           % Command
           funcname = 'ShipPivots';
           funcInput = ['$filter=', filterName, ' eq ', filterval, ...
               ' &$orderby=DateTime desc'];
           tabFunc = @(x, y) tabulatePivots(obj, x, y);
           tabFuncIn = filename;
           data = iterLink(obj, funcname, funcInput, tabFunc, tabFuncIn);
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
       
       func_f = @(x, y) tabulateReportData(obj, x, y);
       funcIn_c = var;
       [tbl, missing] = obj.iterLink(funcname, funcInput, func_f, funcIn_c);
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
        tbl = pivotReportEmpty()
        
       function filename = nextFileInSeries(filepath)
           
           % Get files in directory with stub and wildcard
           [direct, file, ext] = fileparts(filepath);
           search_ch = fullfile(direct, [file, '*', ext]);
           dir_st = dir(search_ch);
           if isempty(dir_st)
               
               % This file will be the first in series
               [direct, file, ext] = fileparts(filepath);
               file = strcat(file, '_1');
               filename = fullfile(direct, [file, ext]);
               return
           end
           direct = fileparts(filepath);
           files_c = cellfun(@(x) fullfile(direct, x), {dir_st.name},...
               'Uni', 0);
           
           % Get index from last file
           files_c = sort(files_c);
           lastFile = files_c{end};
           [direct, file, ext] = fileparts(lastFile);
           idx_i = regexp(file, '\d+$');
           idx = str2double(file(idx_i:end));
           
           % Increment index and append to filename
           idx = idx + 1;
           filename = file;
           filename(idx_i:end) = [];
           filename = strcat(filename, num2str(idx));
           filename = fullfile(direct, [filename, ext]);
       end
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
       
       function [tbl, missing] = iterLink(obj, funcname, funcinput, tabFunc, varargin)
       % iterLink Iteratively call API while links are returned
           
           validateattributes(tabFunc, {'function_handle'}, ...
               {'scalar'}, 'cMarorkaWebAPI.iterLink', 'tabFunc', 4);

           out = obj.call(funcname, funcinput);
           sti = out.value;
           
           if isempty(sti)
               
               tbl = table();
               missing = struct();
               return
           end
           
           [tbl, missing] = tabFunc(sti, varargin{:});
           
           while isfield(out, 'odata_nextLink')
               
               funcinput = out.odata_nextLink;
               funcinput = strrep(funcinput, funcname, '');
               out = obj.call(funcname, funcinput);
               sti = out.value;
               
               [tbl, missingi] = tabFunc(sti, varargin{:});
               missing = [missing; missingi];
           end
       end
       
       function [tbl, missing] = tabulateReportData(obj, reports, var, varargin)
           
       % Input
       validateattributes(reports, {'struct'}, {'vector'}, ...
           'cMarorkaWebAPI.tabulateReportData', 'reports', 2);
       validateCellStr(var, 'cMarorkaWebAPI.tabulateReportData',...
           'var', 3);
       
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
	   
       function [tbl, missing] = tabulatePivots(obj, reports, filename)
           
           % Convert to table
           tbl = struct2table(reports);
           
           % Clean table up
           tbl.Id = [];
           
           % Write to next file
           filename = obj.nextFileInSeries(filename);
           writetable(tbl, filename);
           
           % Output
           missing = [];
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
       
       function path = catDir(obj, file)
           
           % Get all static vessel data
           directory = obj.Directory;
           path = fullfile(directory, file);
       end
       
%        function filename = writetableMulti(obj, tbl, filestub)
%        % writetableMulti Write table into multiple files, limiting rows
%            
%            nFile = numel(obj.MaxRowsPerFile:height(tbl));
%            filename = repmat({filestub}, 1, nFile);
%            
%            rowStarts = 1:incr:nFile;
%            rowEnds = [rowStarts(2:end)-1, nFile];
%            
%            for ti = 1:numel(rowStarts)
%                
%                % Curr file name
%                filename{ti} = strcat(filename{ti}, '_', num2str(ti), '.csv');
%                
%                % Index table
%                si = rowStarts(ti);
%                ei = rowEnds(ti);
%                writetable(tbl(si:ei, :), filename{ti});
%            end
%        end
       
    end
	
	methods
		
		function obj = set.CurrentFileName(obj, filename)
			
			validateattributes(filename, {'char'}, {'vector'});
			obj.CurrentRowIdx = 1;
			obj.CurrentFileName = filename;
		end
	end
end