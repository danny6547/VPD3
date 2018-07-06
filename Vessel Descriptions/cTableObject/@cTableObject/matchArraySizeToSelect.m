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
%     cl = strcat('''', cl, '''');
    obj(oi) = eval([class_ch, '(',  in, ')']);
    obj(oi) = copyData(obj(1), obj(oi));
    
%     for pi = 1:numel(obj(1).DataProperty)
%         
%         currProp = obj(1).DataProperty{pi};
%         obj(oi).(currProp) = obj(1).(currProp);
%     end
end

% Assign connection properties
[obj.SQL] = deal(sql);
[obj.Sync] = deal(sync);


% size_v = [1, nObj-1];
% size_c = num2cell(size_v);
% size_ch = sprintf('%u, ', size_v);
% size_ch = ['[', size_ch, ']'];
% input_ch = ['''Size'', ', size_ch];
% constructor_ch = [class_ch, '(', input_ch, ');'];
% obj2(size_c{:}) = eval(constructor_ch);

end