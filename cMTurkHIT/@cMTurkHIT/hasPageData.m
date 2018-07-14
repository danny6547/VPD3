function [log] = hasPageData(obj)
%hasPageData True when object describes page data
%   Detailed explanation goes here

log = ~isempty(obj.PageName);
end