function [var, stdVar] = varFromSpec(freq, type)
%varFromSpec Get variable names from specification cell
%   Detailed explanation goes here

[spec, time] = cWanHai.specification(freq, type);
var = [time; spec(:, 1)]';

stdVar = [time; spec(:, 2)]';