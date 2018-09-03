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
    end
    
    methods
    
       function obj = cMarorkaWebAPI()
    
       end
    
       function obj = saveAllVessels(obj, directory, varargin)
           
           % Input
           validateattributes(directory, {'char'}, {'vector'}, ...
               'cMarorkaWebAPI.saveAllVessels', 'directory', 2);
           
           % Get all vessels
           vessels = obj.call('Ships');
           
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
           
           % Iterate vessels
           for vi = 1:numel(vessels)
           
%                % High Freq data
               currIMO = vessels.value(vi).IMONo;
%                pivot = obj.inServiceData(currIMO);
%                vesselName = strcat('Pivot_', vessels.value(vi).ShipName);
%                currPivotName = catDir_f(vesselName);
%                writetable(struct2table(pivot), currPivotName);
               
               % Noon data
               report = obj.noonReports(currIMO);
               vesselName = strcat('Reports_', vessels.value(vi).ShipName);
               currReportName = catDir_f(vesselName);
               writetable(report, currReportName);
               
               % Departure data
               report = obj.departureReports(currIMO);
               vesselName = strcat('Departure_', vessels.value(vi).ShipName);
               currReportName = catDir_f(vesselName);
               writetable(report, currReportName);
               
               % Arrival data
               report = obj.arrivalReports(currIMO);
               vesselName = strcat('Arrival_', vessels.value(vi).ShipName);
               currReportName = catDir_f(vesselName);
               writetable(report, currReportName);
               
               % Report Progress
               fprintf(1, ['Completed vessel ', num2str(vi), ', IMO: ',...
                   num2str(vessels.value(vi).IMONo) ,'.\n']);
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
       
       function [tbl, missingReports] = noonReports(obj, imo)
       % noonReports Table containing all noon reports for a vessel
       
       % Input
       obj.validateimo(imo);
       
       % Command
       funcname = 'Reports';
       funcInput = ['$filter=IMONo eq ', num2str(imo), ...
           ' and ReportType eq ''Daily Report'' '...
           '&$orderby=StartDateTimeGMT desc'];
       reports = obj.iterLink(funcname, funcInput);
       
       % Create output table and assign values
       var = obj.dailyReportVars;
       [tbl, missingReports] = obj.tabulateReportData(reports, var);
       end
       
       function [tbl, missing] = departureReports(obj, imo)
       
       % Input
       obj.validateimo(imo);
       
       % Get reportID for all departures
       funcname = 'Reports';
       funcInput = ['$filter=IMONo eq ', num2str(imo), ...
           ' and ReportType eq ''Departure Report'' '...
           '&$orderby=StartDateTimeGMT desc'];
       reports = obj.iterLink(funcname, funcInput);
       
       % Create table out of all departure reports
       var = obj.departureReportVars;
       [tbl, missing] = obj.tabulateReportData(reports, var);
       end
       
       function [tbl, missing] = arrivalReports(obj, imo)
       
       % Input
       obj.validateimo(imo);
       
       % Get reportID for all departures
       funcname = 'Reports';
       funcInput = ['$filter=IMONo eq ', num2str(imo), ...
           ' and ReportType eq ''Arrival Report'' '...
           '&$orderby=StartDateTimeGMT desc'];
       reports = obj.iterLink(funcname, funcInput);
       
       % Create table out of all departure reports
       var = obj.arrivalReportVars;
       [tbl, missing] = obj.tabulateReportData(reports, var);
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
       
       function st = iterLink(obj, funcname, funcinput)
       % iterLink Iteratively call API while links are returned
           
           out = obj.call(funcname, funcinput);
           st = out.value;
           
           while isfield(out, 'odata_nextLink')
               
               funcinput = out.odata_nextLink;
               funcinput = strrep(funcinput, funcname, '');
               out = obj.call(funcname, funcinput);
               sti = out.value;
               st = [st; sti];
           end
       end
       
       function [tbl, missing] = tabulateReportData(obj, reports, var, varargin)
           
       % Input
       validateattributes(reports, {'struct'}, {'vector'}, ...
           'cMarorkaWebAPI.tabulateReportData', 'reports', 2);
       validateCellStr(var, 'cMarorkaWebAPI.tabulateReportData',...
           'reports', 2);
       
       additionalFuncInput = '';
       if nargin > 3
           
           additionalFuncInput = varargin{1};
           validateattributes(additionalFuncInput, {'char'}, {'vector'}, ...
               'cMarorkaWebAPI.tabulateReportData', 'funcinput', 4);
       end
       
       % Pre-allocate outputs
       emptyReports_l = false(1, numel(reports));
       nVar = numel(var);
       emptyCell_c = repmat({{}}, numel(reports), nVar);
       tbl = cell2table(emptyCell_c, 'VariableNames', var);
       tick = tic;
       
       for ri = 1:numel(reports)
           
           % Call this reports data
           currReport = reports(ri);
           fprintf(1, ['\nTime: ', datestr(now), '. ', ...
                'Report number ', num2str(ri),...
                ' / ', num2str(numel(reports)),...
               '  ReportId: ', num2str(currReport.ReportId)]);
           seapassage_ch = '''Sea Passage''';
           reporti = obj.call('ReportData', ...
               ['$filter=ReportId eq ' num2str(currReport.ReportId),...
               additionalFuncInput]); % ' and StateName eq' seapassage_ch]);
           
           % Combine useful data into temporary cell, assign into output
           val = reporti.value;
           if isempty(val)
               
               emptyReports_l(ri) = true;
               continue
           end
           
           % Deal with case of multiple ValueDescriptions in same report
           % with different LapTimes
           allLapTime = unique([val.LapTime]);
           desiredLapTime = max(allLapTime);
           filter = [val.LapTime] ~= desiredLapTime;
           val(filter) = [];
           
           temp_c = {val.MeasuredValue};
           [~, coli] = ismember(genvarname({val.ValueDescription}), var);
           tbl(ri, coli) = temp_c;
           tbl.StartDateTimeGMT(ri) = { val(1).StartDateTimeGMT };
           tbl.EndDateTimeGMT(ri) = { val(1).EndDateTimeGMT };
           tbl.IMONo(ri) = {val(1).IMONo};
           tbl.ReportId(ri) = {val(1).ReportId};
       end
       toc(tick);
       
       % Remove empty rows
       emptyRows_l = all(cellfun(@isempty, tbl{:, :}), 2);
       tbl(emptyRows_l, :) = [];
       
       % Assign empty report
       missing = reports(emptyReports_l);
       end
       
    end
end