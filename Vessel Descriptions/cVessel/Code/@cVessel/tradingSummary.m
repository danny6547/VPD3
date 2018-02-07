function [ obj, lastQuarterSpeed, lastDDSpeed ] = tradingSummary( obj  )
%TRADINGSUMMARY Summary of this function goes here
%   Detailed explanation goes here
    
mps2knots = 1/0.5144444;

    % Iterate over DDi
    while obj.iterateDD
        
        currtbl = obj.currentDD;
        
        % Get idle days
        [rawStruc, rawTable] = obj.rawData;

        % Get last quarter of data
        daysPerQuarter = (365.25 / 4);
        lastDate = max(currtbl.datetime_utc);
        lastQuart_l = currtbl.datetime_utc >= (lastDate - daysPerQuarter);
%         quart = currtbl.datetime_utc(lastQuart_l);
        lastQuarterSpeed = nanmean(currtbl.speed_through_water(lastQuart_l))*mps2knots;
        lastDDSpeed = nanmean(currtbl.speed_through_water)*mps2knots;
        
        % Get non-idle speed
        

        % Longest idle period
        
    end
end