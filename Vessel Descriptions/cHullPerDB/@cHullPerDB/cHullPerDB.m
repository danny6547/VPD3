classdef cHullPerDB < cMySQL
    %CVESSELDB Manage vessel databases
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
    
       function obj = cHullPerDB()
    
       end
       
        function obj = loadDNVGLPerformance(obj, filename, imo, varargin)
        % loadDNVGLPerformance Load performance data sourced from DNVGL.
        
        % Input
        filename = validateCellStr(filename);
        validateattributes(imo, {'numeric'}, {'vector', 'integer', ...
            'positive'}, 'loadDNVGLPerformance', 'imo', 3);
        
        deleteTab_l = true;
        if nargin > 3
            
            deleteTab_l = varargin{1};
            validateattributes(deleteTab_l, {'logical'}, {'scalar'},...
                'loadDNVGLPerformance', 'deleteTab_l', 2);
        end
        
        % Convert xls files to tab, if necessary
        if ~isscalar(filename)
            
            [~, file, ext] = cellfun(@fileparts, filename, 'Uni', 0);
            ext = unique(ext);
            
            if numel(ext) > 1
               
                errid = 'VesselDB:MultiFileTypes';
                errmsg = ['If FILENAME is a non-scalar, file extensions '...
                    'must all be either ''tab'' or ''xlsx''.'];
                error(errid, errmsg);
            end
            
            file = file{1};
            ext = [ext{:}];
            
            if strcmpi(ext, '.tab')
                
                tabfile = filename;
            elseif strcmpi(ext, '.xlsx')
            
                outfilename = filename{1};
                tabfile = strrep(outfilename, file, ['temp', file]);
                tabfile = strrep(tabfile, ext, '.tab');
                if exist(tabfile, 'file') == 2
                    delete(tabfile);
                end
                [~, ~, ~, tabfile] = convertEcoInsightXLS2tab( filename, ...
                    tabfile, true, imo);
            else
                errid = 'VesselDB:FileTypeUnrecognised';
                errmsg = ['Extension of file given by input FILENAME must be '...
                    'either ''xlsx'' or ''tab''.'];
                error(errid, errmsg);
            end
            
        else
            
            filename = [filename{:}];
            [~, file, ext] = fileparts(filename);
            if strcmpi(ext, '.tab')

                tabfile = filename;
            elseif strcmpi(ext, '.xlsx') 

                tabfile = strrep(filename, file, ['temp', file]);
                tabfile = strrep(tabfile, ext, '.tab');
                if exist(tabfile, 'file') == 2
                    delete(tabfile);
                end
                [~, ~, ~, tabfile] = convertEcoInsightXLS2tab( filename, ...
                    tabfile, true, imo);
            else

                errid = 'VesselDB:FileTypeUnrecognised';
                errmsg = ['Extension of file given by input FILENAME must be '...
                    'either ''xlsx'' or ''tab''.'];
                error(errid, errmsg);
            end
        end
        
%         tabfile = validateCellStr(tabfile);
        % Load performance, speed files
        tempTab = 'tempDNVPer';
        permTab = 'PerformanceDataDNVGL';
        ignore_i = 1;
        
%         if ~isempty(pTab)
%             pCols = {'Performance_Index', 'DateTime_UTC', 'IMO_Vessel_Number'};
%             obj = obj.loadInFileDuplicate(pTab, pCols, tempTab,...
%                 permTab, ignore_i);
%         end
%         if ~isempty(sTab)
%             sCols = {'Speed_Index', 'DateTime_UTC', 'IMO_Vessel_Number'};
%             obj = obj.loadInFileDuplicate(sTab, sCols, tempTab,...
%                 permTab, ignore_i);
%         end
        
        % Load in tab file
        tabfile = validateCellStr(tabfile);
        for ti = 1:numel(tabfile)
            
%             cols = {'Performance_Index', 'Speed_Index', ...
%                 'DateTime_UTC', 'IMO_Vessel_Number'};
            currTab = tabfile{ti};
            currTabid = fopen(currTab);
            currCols_cc = textscan(currTabid, '%s', 3);
            currCols_c = [currCols_cc{:}];
            obj = obj.loadInFileDuplicate(currTab, currCols_c, tempTab,...
                permTab, ignore_i);
        end
        
        % Delete tab file, unless requested
        if deleteTab_l
            
           cellfun(@delete, tabfile);
%            delete(pTab); 
%            delete(sTab); 
        end
        end
        
        function obj = loadDNVGLRaw(obj, filename)
        % loadDNVGLRaw Load raw data sourced from DNVGL
        
        % Drop if exists
        tempTab = 'tempDNVGLRaw';
        obj = obj.drop('TABLE', tempTab, true);
        
        % Create temp table
        permTab = 'DNVGLRaw';
        obj = obj.createLike(tempTab, permTab);
        
        % Load into temp table
        cols_c = [];
        delimiter_s = ',';
        ignore_s = 1;
        set_s = ['SET Date_UTC = STR_TO_DATE(@Date_UTC, ''%d/%m/%Y''), ', ...
         'Time_UTC = STR_TO_DATE(@Time_UTC, '' %H:%i''), '];
        setnull_c = {'Date_UTC', 'Time_UTC'};
        [obj, cols] = obj.loadInFile(filename, tempTab, cols_c, ...
            delimiter_s, ignore_s, set_s, setnull_c);
        
        % Generate DateTime prior to using it for identification
        expr_sql = 'ADDTIME(Date_UTC, Time_UTC)';
        col = 'DateTime_UTC';
        obj = obj.update(tempTab, col, expr_sql);
        
        % Update insert into final table
        tab1 = tempTab;
        finalCols = [cols, {col}];
        cols1 = finalCols;
        tab2 = permTab;
        cols2 = finalCols;
        obj = obj.insertSelectDuplicate(tab1, cols1, tab2, cols2);
        
        % Drop temp
        obj = obj.drop('TABLE', tempTab);
        
        end
        
    end
    
    methods(Static)
        
    
    end
    
end
