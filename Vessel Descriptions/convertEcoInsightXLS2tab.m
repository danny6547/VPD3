function [bytesWritten, perFile, speedFile, allFile] = convertEcoInsightXLS2tab( xlsfile, tabfile, varargin )
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
%   convertEcoInsightXLS2tab(XLSFILE, TABFILE, MYSQL, IMO) will, in
%   addition to the above, write the IMO numbers of the vessels given in
%   numeric vector IMO into TABFILE and will not write the vessel name. IMO
%   must have the same number of elements as XLSFILE.

% Output
perFile = [];
speedFile = [];
allFile = {};

% Input
if nargin > 2
    mysql_b = varargin{1};
    validateattributes(mysql_b, {'logical'}, {'scalar'}, ...
        'convertEcoInsightXLS2tab', 'MySQLFlag', 3);
else
    mysql_b = false;
end

imo_l = false;
if nargin > 3
    imo_l = true;
    imo = varargin{2};
    validateattributes(imo, {'numeric'}, {'vector'}, ...
        'convertEcoInsightXLS2tab', 'IMO', 4);
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
% for fi = 1:numfiles

    % Control the tab, xlsx iterators for cases where one of either is
    % input and prevent infinite loop
%     if numel(xlsfiles) == 1
%         xi = 1;
%     else
%         xi = fi;
%     end
%     if numel(tabfiles) == 1
%         ti = 1;
%     else
%         ti = fi;
%     end
% 
%     xlsfile = xlsfiles{xi};
%     tabfile = tabfiles{ti};
    
    % Get start point of data
    [timedata_st, ~, ship_s] = parseEcoInsightXLS( xlsfiles );
    
    dates_c = cellfun(@transpose, {timedata_st.dates}, 'Uni', 0);
    pidx_c = cellfun(@transpose, {timedata_st.pidx}, 'Uni', 0);
    
    dates = [dates_c{:}];
    pidx = [pidx_c{:}];
    
if ~mysql_b

    % Create tab file with header line
    fid = fopen(tabfile, 'a');
    fclose(fid);
    dlmwrite(tabfile, [dates; pidx], '-append', 'precision', '%.4f', ...
        'delimiter', '\t');

else

    % Separate data by performance values
    timedata_st = arrayfun(@(x) structfun(@(y) y', x, 'Uni', 0), timedata_st);
%     imo_c = num2cell(imo);
    if ~isfield(timedata_st, 'IMO')
        
        imo_c = arrayfun(@(x, y) repmat(x, size(y.dates)), imo(:)', timedata_st,...
            'Uni', 0);
        [timedata_st(:).IMO] = deal(imo_c{:});
    end
    sidx = [timedata_st(:).sidx];
    pidx = [timedata_st(:).pidx];
    dates = [timedata_st(:).dates];
    imo = [timedata_st(:).IMO];
    
    speed_l = ~isnan(sidx);
    per_l = ~isnan(pidx);
    speedIMO_v = imo(speed_l);
    perIMO_v = imo(per_l);
    dates_ch = datestr(dates, 'yyyymmddHHMMSS');
    t = str2num(dates_ch);
    
    speedDates_s = t(speed_l, :);
    perDates_s = t(per_l, :);
    
    if ~any(speed_l) && ~any(per_l)
        
        errid = 'cEIFile:NoData';
        errmsg = 'No performance data read from input files';
        error(errid, errmsg);
    end
    
    % Write files for speed, performance index, whichever have data
    [~, tabf, tabe] = fileparts(tabfile);
    speedFile = '';
    perFile = '';
    
%     if imo_l
%         shipname = sprintf('%u', imo(fi));
%     else
%         shipname = ship_s.Single_vessel;
%     end
     
    if any(speed_l)
        
        speedFile = strrep(tabfile, [tabf, tabe], [tabf, '_speed', tabe]);
        sfid = fopen(speedFile, 'w');
        fprintf(sfid, ...
            'Speed_Index\tDateTime_UTC\tIMO_Vessel_Number\n');
        
        writeCount_m = fprintf(sfid, '%f\t%u\t%u\n',...
            [sidx(speed_l)', speedDates_s, speedIMO_v']');
        fclose(sfid);
        allFile = [allFile, {speedFile}];
    end
    
    if any(per_l)
        
        perFile = strrep(tabfile, [tabf, tabe], [tabf, '_performance', tabe]);
        pfid = fopen(perFile, 'w');
        fprintf(pfid, ...
            'Performance_Index\tDateTime_UTC\tIMO_Vessel_Number\n');
        writeCount_m = fprintf(pfid, '%f\t%u\t%u\n',...
            [pidx(per_l)', perDates_s, perIMO_v']');
        fclose(pfid);
        allFile = [allFile, {perFile}];
    end
    
%     fid = fopen(tabfile, 'a');
%     fprintf(fid, ...
%         'Performance_Index\tSpeed_Index\tDateTime_UTC\tIMO_Vessel_Number\n');
    
%     for fi = 1:numfiles
%         
%         sidx = timedata_st(fi).sidx;
%         pidx = timedata_st(fi).pidx;
%         dates = timedata_st(fi).dates;
%         dates_ch = datestr(dates, 'yyyymmddHHMMSS');
%         t = str2num(dates_ch);
%         
%         if imo_l
%             shipname = sprintf('%u', imo(fi));
%         else
%             shipname = ship_s.Single_vessel;
%         end
%         writeCount_m = fprintf(fid, ['%f\t%f\t%u\t', shipname, '\n'],...
%             [pidx, sidx, t]');
%     end
%     fclose(fid);
    bytesWritten = writeCount_m;
    
    % Convert NAN to MySQL-friendly NULL values
    perlCmd = sprintf('"%s"', fullfile(matlabroot, 'sys\perl\win32\bin\perl'));
    perlstr = sprintf('%s -i.bak -pe"s/%s/%s/g" "%s"', perlCmd, 'NaN',...
        '\\N', speedFile);
    [s, msg] = dos(perlstr);
    if s ~= 0
        error(char({'Windows command prompt returned the follwing error: ',...
            msg}))
    end
    perlstr = sprintf('%s -i.bak -pe"s/%s/%s/g" "%s"', perlCmd, 'NaN',...
        '\\N', perFile);
    [s, msg] = dos(perlstr);
    if s ~= 0
        error(char({'Windows command prompt returned the follwing error: ',...
            msg}))
    end
end
end


% end