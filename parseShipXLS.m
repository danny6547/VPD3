function [ date, pidx, regr ] = parseShipXLS(xlsfile, tablename)
%parseShipXLS Return input data from EXCEL Vessel Analysis Template copy
%   [DATE, PIDX, REGR] = parseShipXLS(XLSFILE, TABLENAME) takes as input
%   file path string XLSFILE and string TABLENAME giving the name of an
%   Excel Table within XLSFILE which has the column names 'Date', 
%   'Performance Index', 'Regression' and returns in DATE a vector of
%   serial date numbers, in PIDX a vector of the corresponding performance 
%   index values and in REGR a vector of the corresponding regression
%   values.

% Construct range strings
daterangestr = strcat(tablename, '[Date]');
pirangestr = strcat(tablename, '[Performance Index]');
regressionrangestr = strcat(tablename, '[Regression]');

% Read file
[~, ~, date_c] = xlsread(xlsfile, '', daterangestr);
[~, ~, pidx] = xlsread(xlsfile, '', pirangestr);
[~, ~, regr] = xlsread(xlsfile, '', regressionrangestr);

pidx = [pidx{:}];
regr = [regr{:}];

% Convert date vector to matlab datetime values
numerDates_l = cellfun(@isnumeric, date_c);
date_c(numerDates_l) = cellfun(@x2mdate, date_c(numerDates_l), 'Uni', 0);
strDates_l = cellfun(@ischar, date_c);
date_c(strDates_l) = cellfun(@(x) datenum(x, 'dd-mm-yyyy'), ...
    date_c(strDates_l), 'Uni', 0);
date = [date_c{:}];

end

