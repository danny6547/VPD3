function [ obj ] = analyse(obj)
%analyse Analyse data according to procedure described in ISO19030
%   Detailed explanation goes here

% Analyse
for oi = obj
    
    analyse@cVesselAnalysis(oi);
    
    % Insert
    oi.SQL.call('insertIntoCalculatedData');
end