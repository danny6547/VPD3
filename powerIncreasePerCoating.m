function [ powerStruct, powerInc ] = powerIncreasePerCoating( perData )
%powerIncreasePerCoating Power increase, service interval for each coating
%   Detailed explanation goes here

% Output
powerStruct = struct('Coating', '', 'AvgPwrIncrease', [],...
    'AvgServiceInterval', []);
powerInc = struct('PowerIncrease', []);
powerInc = repmat(powerInc, size(perData));

% Get all power increase, service interval
guarStruct = guaranteeDurations(perData);
servStruct = serviceInterval(perData);

% Get coatings for each vessel
coatingStruc = vesselCoatings( perData );

% Take only last non-nan power increase
powerInc_c = arrayfun(@(x) x.RelativeDifference(...
    find(~isnan(x.RelativeDifference), 1, 'last')), guarStruct, 'Uni', 0);
[powerInc(:).PowerIncrease] = powerInc_c{:};

% Get unique coating names, indices to all coating names
coatingNames_c = { coatingStruc(:).Coating }';
coatingNames_c( cellfun(@isnumeric, coatingNames_c) ) = {''};
[uniCoats_c, ~, allCoatsI] = unique(coatingNames_c);
numCoats = numel(uniCoats_c);
uniI = 1:numCoats;

% "Flatten" structs containing power increase, service interval
% flatGuarStruct = [guarStruct(:)]; %.RelativeDifference];
% flatServStruct = [servStruct(:)]; %.ServiceInterval];

% Iterate over each unique coating name, average all it's power increases
uniCoatAvg = arrayfun(@(x) mean(...
        [powerInc_c{allCoatsI == x}]), uniI, 'Uni', 0);
uniServAvg = arrayfun(@(x) mean(...
        [servStruct(allCoatsI == x).ServiceInterval]), uniI, 'Uni', 0);

powerStruct = repmat(powerStruct, [1, numCoats]);
[powerStruct(:).Coating] = uniCoats_c{:};
[powerStruct(:).AvgPwrIncrease] = uniCoatAvg{:};
[powerStruct(:).AvgServiceInterval] = uniServAvg{:};

% Reshape to match input
% powerStruct = reshape(powerStruct, size(perData));