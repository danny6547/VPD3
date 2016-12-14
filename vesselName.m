function [ name, IMOout ] = vesselName( IMOin )
%shipName Vessel name from IMO number
%   name = vesselName(IMO) returns in NAME a string containing the name of 
%   the vessel indentified by numeric integer IMOIN, the vessel's 
%   International Maritime Organisation (IMO) number found in the database,
%   and IMOOUT, the corresponding IMO for those found. If IMOIN is 
%   non-scalar, NAME will be a cell array of strings. If no matches are 
%   found, both outputs will be empty.

% Inputs
validateattributes(IMOin, {'numeric'}, {'vector', 'finite', 'positive',...
    'integer'}, 'vesselName', 'IMOin', 1);

% Connect to Database
conn = adodb_connect(['driver=MySQL ODBC 5.3 ANSI Driver;',...
    'Server=localhost;',...
    'Database=test2;',...
    'Uid=root;',...
    'Pwd=HullPerf2016;']);

w = strcat(strcat(' IMO = ', num2str(IMOin')), ' OR ');
e = w';
r = e(:)';
t = r(1:end-3);

out = adodb_query(conn, ['SELECT name, IMO FROM ships WHERE ', t]);

if isempty(out)
    
    name = '';
    IMOout = [];
    
else
    
    name = out.name;
    if iscell(out.imo)
        IMOout = [out.imo{:}];
    else
        IMOout = [out.imo];
    end
end

% Sort by input order
if ~isscalar(IMOin)
    [imoFilt, imoOrder] = ismember(IMOin, IMOout);
    IMOout = IMOout(imoFilt);
    imoOrder = imoOrder(imoFilt);
    name = name(imoOrder);
    IMOout = IMOout(imoOrder);
end