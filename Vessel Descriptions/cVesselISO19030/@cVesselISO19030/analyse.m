function [ obj ] = analyse(obj)
%analyse Analyse data according to procedure described in ISO19030
%   Detailed explanation goes here

% Analyse
obj = analyse@cVesselAnalysis(obj);

% Insert
obj.SQL.call('insertIntoCalculatedData');
end