function [ coatingStruc ] = vesselCoatings( perData )
%vesselCoatings Coating system data for vessels at given dates
%   Detailed explanation goes here

% Output
sz = size(perData);
coatingStruc = struct('Coating',[]);
coatingStruc = repmat(coatingStruc, sz);

% Input
validateattributes(perData, {'struct'}, {});

% Connect to Database
conn = adodb_connect(['driver=MySQL ODBC 5.3 ANSI Driver;',...
    'Server=localhost;',...
    'Database=hull_performance;',...
    'Uid=root;',...
    'Pwd=HullPerf2016;']);

% Iterate over guarantee struct to get averages
idx_c = cell(1, ndims(perData));
for ii = 1:numel(perData)
   
   [idx_c{:}] = ind2sub(sz, ii);
   currData = perData(idx_c{:});
   
   % Skip DDi if empty
   if all(isnan([currData.DateTime_UTC{:}]))
       continue
   end
   
   % Get relevant inputs
   currIMO = currData.IMO_Vessel_Number;
   currDateNum = datenum(currData.DateTime_UTC{1}, 'dd-mm-yyyy');
   currDateStr = datestr(currDateNum, 'yyyy-mm-dd HH:MM:SS');
   
   % Get coating for this ship, DD interval
   sqlQuery = ['set @imo = ', num2str(currIMO) '; ',...
       'set @datet = ''', currDateStr ,'''; ',...
       'set @coating = '''' ; ',...
       'CALL vesselCoatingAtDate(',...
                                   '@coating, ',...
                                   '@datet, ',...
                                   '@imo); ',...
       'SELECT @coating;'];
   sqlQuery_c = strsplit(sqlQuery, ';');
   sqlQuery_c(end) = [];
   [~, currCoating_c] = cellfun(@(x) adodb_query(conn, x), sqlQuery_c,...
       'Uni', 0);
   currCoating_s = [currCoating_c{end}{:}];
   if isnan(currCoating_s)
      currCoating_s = 'Unknown Coating'; 
   end
   
   % Assign into output
   coatingStruc(idx_c{:}).Coating = currCoating_s;
   
end
end