function [ obj, tradst ] = tradingSummary( obj  )
%TRADINGSUMMARY Summary of this function goes here
%   Detailed explanation goes here

    % Iterate over DDi
    
    
    
    % Get idle days
    [rawStruc, rawTable] = obj.rawData;
    
    % Get last quarter of data
    daysPerQuarter = (365.25 / 4);
    lastDate = max(obj.DateTime_UTC);
    lastQuart_l = obj.DateTime_UTC >= (lastDate - daysPerQuarter);
    quart = obj.DateTime_UTC(lastQuart_l);
    
    % Get non-idle speed
    
    
    % Longest idle period

end