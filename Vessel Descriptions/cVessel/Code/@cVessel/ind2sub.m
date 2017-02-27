function [ DDi, vesselI, varargout ] = ind2sub( obj, idx )
%ind2sub Convert linear index to subscripts of dry-dock, vessel etc
%   Detailed explanation goes here


idx_c = cell(1, ndims(obj));
[idx_c{:}] = ind2sub(size(obj), idx);
DDi = idx_c{1};
vesselI = idx_c{2};

if length(idx_c) > 2
    varargout = idx_c{3:end};
end

end