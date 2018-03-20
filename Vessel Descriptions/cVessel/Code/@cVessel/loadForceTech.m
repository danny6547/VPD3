function obj = loadForceTech(obj, filename, varargin)
%loadForceTech Load file downloaded from Force Technologies SeaTrend 
%   Detailed explanation goes here

% Inputs
filename = validateCellStr(filename);

acceptableTables_c = {'forceraw', 'performanceData'};
tab_c = acceptableTables_c;
if nargin > 2
    
    % Tables
    if ~isempty(varargin{1})
        
        tab_c = varargin{1};
        tab_c = validateCellStr(tab_c);
        cellfun(@(x) validatestring(x, acceptableTables_c, 'loadForceTech', ...
            'tab_c', 3), tab_c);
    end
end

% Convert file decimal separator to that of MySQL
replaceCommaWithPoint(filename);

% Load in file
tab = 'forceraw';
cols = {};
delimiter_ch = ';';
ignore_ch = 1;
set_ch = '';
setnull_c = {'all'};

obj = obj.loadInFile(filename, tab, cols, delimiter_ch, ignore_ch, set_ch, setnull_c);

    function [success, message] = replaceCommaWithPoint(filename)
        
        filename = validateCellStr(filename);
        szOut = size(filename);
        success = cell(szOut);
        message = cell(szOut);
        
        for fi = 1:numel(filename)
            
            file = filename{fi};
            perlCmd = sprintf('"%s"', fullfile(matlabroot, 'sys\perl\win32\bin\perl'));
            perlstr = sprintf('%s -i.bak -pe"s/%s/%s/g" "%s"', perlCmd, ',',...
                    '.', file);
            [s, msg] = dos(perlstr);
            success{fi} = s;
            message{fi} = msg;
        end
        
        if numel(filename) == 1
            
            success = [success{:}];
            message = [message{:}];
        end
    end
end