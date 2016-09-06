function bytesWritten = convertEcoInsightXLS2tab( xlsfile, tabfile, varargin )
%convertEcoInsightXLS2tab Convert EcoInsight xlsx file to delimited ASCII
%   convertEcoInsightXLS2tab(XLSFILE, TABFILE) will convert the .xlsx file
%   given by file-path string XLSFILE to an equivalent tab-delimited text 
%   file at the address given by string TABFILE. XLSFILE must be in the
%   format of the xlsx files downloadable through DNVGL's EcoInsight
%   web-basaed graphical interface.
%   convertEcoInsightXLS2tab(XLSFILE, TABFILE, MYSQL) will, in addition to
%   the above, write the file in a way that allows calls to LOAD INFILE in
%   SQL on TABFILE. These are a header line giving the names of each
%   column of data, a ship name column, and converting all "NaN" to "\N".

% Input
if nargin > 2
    mysql_b = varargin{1};
    validateattributes(mysql_b, {'logical'}, {'scalar'}, ...
        'convertEcoInsightXLS2tab', 'MySQLFlag', 3);
else
    mysql_b = false;
end

validateattributes(xlsfile, {'cell', 'char'}, {}, ...
    'convertEcoInsightXLS2tab', 'xlsfile', 1);
if iscell(xlsfile)
    cellfun(@(x) validateattributes(x, {'char'}, {}, ...
    'convertEcoInsightXLS2tab', 'xlsfile', 1), xlsfile);
end

validateattributes(tabfile, {'cell', 'char'}, {}, ...
    'convertEcoInsightXLS2tab', 'tabfile', 2);
if iscell(tabfile)
    cellfun(@(x) validateattributes(x, {'char'}, {}, ...
    'convertEcoInsightXLS2tab', 'tabfile', 2), tabfile);
end

% Check input sizes match, or one of them is scalar
xlsfiles = cellstr(xlsfile);
tabfiles = cellstr(tabfile);
if (numel(xlsfiles) ~= numel(tabfiles)) && ...
        (numel(xlsfiles) ~= 1 && numel(tabfiles) ~= 1)
    errid = 'EI:InputOutputMismatch';
    errmsg = ['If a cell array of strings is input for either XLSFILE or '...
        'TABFILE, they both must be cell arrays of strings of the same '...
        'length.'];
    error(errid, errmsg);
end

% Iterate files
numfiles = max([numel(xlsfiles), numel(tabfiles)]);
for fi = 1:numfiles

    % Control the tab, xlsx iterators for cases where one of either is
    % input and prevent infinite loop
    if numel(xlsfiles) == 1
        xi = 1;
    else
        xi = fi;
    end
    if numel(tabfiles) == 1
        ti = 1;
    else
        ti = fi;
    end

    xlsfile = xlsfiles{xi};
    tabfile = tabfiles{ti};
    
    % Get start point of data
    [dates, pidx, ~, ~, ship_s] = parseEcoInsightXLS( xlsfile );

    if ~mysql_b

        % Create tab file with header line
        fid = fopen(tabfile, 'a');
%         fprintf(fid, 'Time\tPerformance Index\n');
        fclose(fid);
        dlmwrite(tabfile, [dates, pidx], '-append', 'precision', '%.4f', ...
            'delimiter', '\t');

    else

        % Write File with Ship Name and Column Heading
        fid = fopen(tabfile, 'a');
%         fprintf(fid, 'Time\tPerformance Index\tShip Name\n');
        shipname = ship_s.Single_vessel;
        dates_ch = datestr(dates, 'yyyymmddHHMMSS');
        
        t = str2num(dates_ch);
        writeCount_m = fprintf(fid, ['%f\t%u\t', shipname, '\n'], [pidx, t]');
%         writeCount_m = fprintf(fid, ['%s\t%f\t', shipname '\n'], [dates, pidx]');
        fclose(fid);
        bytesWritten = writeCount_m;

        % Convert NAN to MySQL-friendly NULL values
        perlCmd = sprintf('"%s"', fullfile(matlabroot, 'sys\perl\win32\bin\perl'));
        perlstr = sprintf('%s -i.bak -pe"s/%s/%s/g" "%s"', perlCmd, 'NaN',...
            '\\N', tabfile);
        [s, msg] = dos(perlstr);
        if s ~= 0
            error(char({'Windows command prompt returned the follwing error: ',...
                msg}))
        end
    end
end


end