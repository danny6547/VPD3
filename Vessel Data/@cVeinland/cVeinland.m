classdef cVeinland < cGetFiles
    %cVeinland Having a go at downloading Veinland data from ftp
    %   Detailed explanation goes here
    
    properties
        
        Server = 'ftp.veinland.net';
        Source = '/PIM_outbox';
        Destination = '\\hempelgroup.sharepoint.com@SSL\DavWWWRoot\sites\HullPerformanceManagementTeam\Vessel Library\AMCL\Time series data\New Peace';
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
        
        function tbl = readVeinlandDir(obj, direct, filename)
        % convertToCSVDir
        
        % Input
        
        % Iterate Veinland files in dir
        directWild_ch = fullfile(direct, '*_PIM_*.XML');
        veinFile_st = dir(directWild_ch);
        veinFile_c = {veinFile_st.name};
        veinFile_c = cellfun(@(x) fullfile(direct, x), veinFile_c, 'Uni', 0);
        
        % Generate table
        tbl = obj.readVeinlandFile(veinFile_c);
        
        % Write table to file
        writetable(tbl, filename);
        end
    end
    
    methods(Static)
        
%         tbl = readVeinlandFile(filename);
        names = variableNames()
    end
end