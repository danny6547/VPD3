function [in, name] = noon2TimeOpt()
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here

name = 'LOG_DATE';
in = {...
        {'InputFormat', 'yyyy/M/dd a hh:mm:SS', 'Locale', 'zh_CN'},...
        {'InputFormat', 'dd-MMM-yyyy HH:mm:ss.S', 'Locale', 'da_DK'}...
        };
end

