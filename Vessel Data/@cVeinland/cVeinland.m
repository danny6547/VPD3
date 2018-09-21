classdef cVeinland < cGetFiles
    %cVeinland Having a go at downloading Veinland data from ftp
    %   Detailed explanation goes here
    
    properties
        
        Server = 'ftp.veinland.net';
        Source = '/PIM_outbox';
        Destination = '';
    end
    
    properties(Hidden)
        
        SpecFile = 'C:\Users\damcl\OneDrive - Hempel Group\Desktop\PIMOBU_4.1.1806.3.xsd';
        DateFormStr = ['yyyyMMdd''T''HH:mm:SS'];
        UnwantedVariables = {'id'};
        MissingData = {'N/A', '---'};
        FileVariables2Keep = {'report_date',...
                                'log_speed',...
                                'shaft_power',...
                                'rel_wind_speed',...
                                'rel_wind_angle_heading',...
                                'gps_speed',...
                                'heading_course',...
                                'shaft_rpm',...
                                'draft_forw',...
                                'draft_aft',...
                                'water_depth',...
                                'seawater_temperature',...
                                'air_temperature',...
                                'air_pressure',...
                                'shaft_torque',...
                                'foc_me_actual',...
                                'temperature_me_IN',...
                                'foc_me_actual',...
                                'displacement',...
                                'rudder_angle',...
                                'wind_speed_unit'};
    end
    
    methods
        
        function obj = cVeinland()
            %cVeinland Construct an instance of this class
            %   Detailed explanation goes here
            
            uid = 'u46603397-hempel';
            pass = 'Hempel@Veinland14554';
            obj = obj@cGetFiles(uid, pass);
        end
        
        function files = getVessel(obj, imo)
        % getVessel Get files from vessel
            
            for ii = 1:numel(imo)
                
                imo_ch = num2str(imo(ii));
                wildcard = ['*_PIM_', imo_ch, '_*.xml'];
                [~, files] = obj.getDir('', wildcard);
            end
        end
        
        function tbl = readVeinlandDir(obj, filename, varargin)
        % convertToCSVDir
        
        % Input
        filename_l = false;
        if nargin > 1 && ~isempty(varargin{1})
            
            filename = varargin{1};
            validateattributes(filename, {'char'}, {'vector'}, ...
                'cVeinland.readVeinlandDir', 'filename', 2);
            filename_l = true;
        end
        direct = obj.Destination;
        if nargin > 2
            
            direct = varargin{2};
            validateattributes(direct, {'char'}, {'vector'}, ...
                'cVeinland.readVeinlandDir', 'direct', 3);
        end
        
        % Iterate Veinland files in dir
        pimDir = 'PIM_outbox';
        directWild_ch = fullfile(direct, pimDir, '\*_PIM_*.XML');
        veinFile_st = dir(directWild_ch);
        veinFile_c = {veinFile_st.name};
        veinFile_c = cellfun(@(x) fullfile(direct, pimDir, x), veinFile_c,...
            'Uni', 0);
        
        % Generate table
        tbl = obj.readVeinlandFile(veinFile_c);
        
        % Write table to file
        if filename_l
            
            writetable(tbl, filename);
        end
        end
        
        function [raw, proc] = writeInServiceFile(obj, imo, filename)
        % writeInServiceFile
        
        % Input
        validateattributes(filename, {'char'}, {'vector'}, ...
            'cVeinland.writeInServiceFile', 'filename', 3);
        if ~isempty(imo)
            
            % Get files for given vessel
            obj.getVessel(imo);
        end

        % Read files into table
        raw = obj.readVeinlandDir();

        % Clean table
        proc = obj.cleanTable(raw);

        % Convert table to timetable
        proc = obj.convertVeinlandTbl2Timetable(proc);

        % Write import file from prepared timetable
        proc = obj.writeInServiceFileFromTable(proc, filename);
        end
    end
    
    methods(Static)
        
        names = variableNames()
        [out] = writeInServiceFileFromTable(tbl, file)
    end
end