function [ obj ] = loadMarorkaRaw( obj, filename )
%loadMarorka Load data from Marorka file into table RawData
%   Detailed explanation goes here

% Call create temp table proc
obj = obj.call('createTempMarorkaRaw');

% Load into temp (convert time)
tempTab = 'tempMarorkaRaw';
cols_c = [];
delimiter_s = ',';
ignore_s = 1;
set_s = 'SET DateTime_UTC = STR_TO_DATE(@TimeStamp, ''%d.%m.%Y %H:%i''),';
setnull_c = {'TimeStamp'};
obj = obj.loadInFile(filename, tempTab, cols_c, delimiter_s, ignore_s, ...
    set_s, setnull_c);

% Update/insert into final table
obj = obj.call('insertFromMarorkaRawIntoRaw');

% Drop the temp
obj = obj.drop('TABLE', tempTab);

% Return IMO if requested

end