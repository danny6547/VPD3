function [ bytesWritten ] = writeSQLLoadInFileTab( tabfile, imo, dates, pidx, varargin)
%writeSQLLoadInFileTab Write tab-delimited file ready for SQL LOAD INFILE
%   Detailed explanation goes here

% Inputs
validateattributes(tabfile, {'char'}, {'vector'}, 'writeSQLLoadInFileTab',...
    'tabfile', 1);
validateattributes(imo, {'numeric'}, {'positive', 'integer'}, 'writeSQLLoadInFileTab',...
    'imo', 2);
validateattributes(dates, {'numeric'}, {'positive'}, 'writeSQLLoadInFileTab',...
    'dates', 3);
validateattributes(pidx, {'numeric'}, {'positive', 'real'},...
    'writeSQLLoadInFileTab', 'pidx', 4);

sidx = [];
if nargin > 4
    sidx = varargin{1};
    validateattributes(sidx, {'numeric'}, {'positive', 'real'}, ...
        'writeSQLLoadInFileTab', 'sidx', 5);
end

% Check that all inputs are the same size or are scalar
allInputs_c = {imo, dates, pidx, sidx};
scalars_l = cellfun(@isscalar, allInputs_c);
empty_l = cellfun(@isempty, allInputs_c);
emptyOrScalar_l = scalars_l | empty_l;
allSizes_c = cellfun(@size, allInputs_c(~emptyOrScalar_l), 'Uni', 0);
szMat_c = allSizes_c(1);
chkSize_c = repmat( szMat_c, size(allSizes_c));
if ~isequal(allSizes_c, chkSize_c)
   errid = 'DBTab:SizesMustMatch';
   errmsg = 'All inputs must be the same size, or any can be scalar';
   error(errid, errmsg);
end

% Repeat any scalars to the same size as other inputs
allInputs_c(scalars_l) = cellfun(@(x) repmat(x, [szMat_c{:}]), ...
    allInputs_c(scalars_l), 'Uni', 0);
allInputs_c(empty_l) = cellfun(@(x) nan([szMat_c{:}]), ...
    allInputs_c(empty_l), 'Uni', 0);
[imo, dates, pidx, sidx] = deal(allInputs_c{:});

% Convert dates
dates_ch = datestr(dates, 'yyyymmddHHMMSS');
dates_v = str2num(dates_ch);

% Open file and append
fid = fopen(tabfile, 'a');
writeCount_m = fprintf(fid, '%f\t%f\t%u\t%u\n', [pidx, sidx, dates_v, imo]');
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