function [ obj] = matchArraySizeToSelect(obj, objCol, tbl)
%expandArrayToFitSelect Expand scalar object based on results of select
%   Detailed explanation goes here

% Count number of unique obj found in table returned by SELECT statement
nObj = numel(unique(tbl.(objCol)));
sizeMismatch_l = nObj ~= numel(obj);

% Error if OBJ not scalar
if ~isscalar(obj) && sizeMismatch_l
    
    errid = 'cTO:Expand2Fit';
    errmsg = ['OBJ can only be expanded to exactly the number of objects '...
        'found in TBL when OBJ is scalar'];
    error(errid, errmsg);
end

if isempty(tbl)
    
    return
end

sql = obj.SQL;
sync = obj.Sync;

class_ch = class(obj);
for oi = 2:nObj
   
    [~, ~, in] = obj(1).SQL.connectionData();
    obj(oi) = eval([class_ch, '(',  in, ')']);
    obj(oi) = copyData(obj(1), obj(oi));
end

% Assign connection properties
[obj.SQL] = deal(sql);
[obj.Sync] = deal(sync);
end