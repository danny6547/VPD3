classdef cVesselDB < cMySQL
    %CVESSELDB Manage vessel databases
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
    
       function obj = cVesselDB()
    
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
    end
    
    methods(Static)
        
    
    end
    
end
