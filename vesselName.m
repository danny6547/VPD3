function [ name ] = vesselName( IMOin )
%shipName Vessel name from IMO number
%   name = vesselName(IMO) returns in NAME a string containing the name of 
%   the vessel indentified by numeric integer IMOIN, the vessel's 
%   International Maritime Organisation (IMO) number found in the database,
%   and IMOOUT, the corresponding IMO for those found. If IMOIN is 
%   non-scalar, NAME will be a cell array of strings. If no matches are 
%   found, both outputs will be empty.

% Initialise Outputs

% Get indices to valid IMO in vector
validIMO_l = ~isnan(IMOin) & (IMOin ~= 0);
IMOOut = IMOin;
nameOut = repmat({''}, size(IMOOut));
IMOin = IMOin(validIMO_l);
if isempty(IMOin)
    name = '';
    return
end
name = repmat({''}, size(IMOin));

% Inputs
validateattributes(IMOin, {'numeric'}, {'vector', 'finite', 'positive',...
    'integer'}, 'vesselName', 'IMOin', 1);

% Connect to Database
conn = adodb_connect(['driver=MySQL ODBC 5.3 ANSI Driver;',...
    'Server=localhost;',...
    'Database=hull_performance;',...
    'Uid=root;',...
    'Pwd=HullPerf2016;']);

IMOin = IMOin(:);
w = strcat(strcat(' IMO_Vessel_Number = ', num2str(IMOin)), ' OR ');
e = w';
r = e(:)';
t = r(1:end-3);

out = adodb_query(conn, ['SELECT name, IMO_Vessel_Number FROM vessels WHERE ', t]);
% out = arrayfun(@(t) adodb_query(conn, ...
%     ['SELECT name, IMO FROM ships WHERE ', t]), IMOin, 'Uni', 0);

% If scalar name not found, return empty string
if isempty(out)
    
    name = '';
%     IMOout = [];
    
% If scalar name found, return string
elseif isscalar(IMOin)
    
    name = out.name;
    
% If array names found, return cell
else
    
    outName_c = out.name;
    outName_c = validateCellStr(outName_c);
    outIMO_c = out.imo_vessel_number;
    if iscell(outIMO_c)
        outIMO_v = [outIMO_c{:}];
    else
        outIMO_v = outIMO_c;
    end
    [inorder_l, inorder_i] = ismember(IMOin, outIMO_v);
    
    IMOout = int32(nan(size(IMOin)));
    IMOout(inorder_l) = outIMO_v(inorder_i(inorder_l));
    name(inorder_l) = outName_c(inorder_i(inorder_l));
    
%     if iscell(out.imo_vessel_number)
%         IMOout = [out.imo_vessel_number{:}];
%     else
%         IMOout = [out.imo_vessel_number];
%     end
    nameOut(validIMO_l) = name;
    name = nameOut;
end


if isscalar(name)
    name = [name{:}];
end

% % Sort by input order
% if ~isscalar(IMOout)
%     [imoFilt, imoOrder] = ismember(IMOin, IMOout);
%     IMOout = IMOout(imoFilt);
%     imoOrder = imoOrder(imoFilt);
%     name = name(imoOrder);
%     IMOout = IMOout(imoOrder);
% end