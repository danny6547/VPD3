function [obj, answer_tbl] = results(obj)
%results Parse results from output file
%   Detailed explanation goes here

% Check output file
obj.errorIfNoOutFile();
filename = obj.outName;
[~, answer_tbl] = obj.readFileTable(filename, true);

% Get x and y limits
minSpeedName = strcat('Answer_', obj.MinSpeedName);
maxSpeedName = strcat('Answer_', obj.MaxSpeedName);
minPowerName = strcat('Answer_', obj.MinPowerName);
maxPowerName = strcat('Answer_', obj.MaxPowerName);
minSpeed = answer_tbl.(minSpeedName);
maxSpeed = answer_tbl.(maxSpeedName);
minPower = answer_tbl.(minPowerName);
maxPower = answer_tbl.(maxPowerName);

% Find speed, power values
speedRange = [maxSpeed, minSpeed];
horizontalWidth = obj.GraphWidthPixels;
powerRange = [maxPower, minPower];
verticalHeight = obj.GraphHeightPixels;

conv_f = @(idx, rng, nr) min(rng) + (idx/nr)*(max(rng)-min(rng));

% Iterate curves to get pixel grid indices
for ci = 1:obj.NCurve
    
    currObj = obj.CurveObj(ci);
    currObj = results@cMTurkHIT(currObj, '', false);
    
    speedCol = currObj.FileData.(currObj.Names{1});
    powerCol = currObj.FileData.(currObj.Names{2});
    
    % Calculate physical units from graph pixel values
    speedColPhysical = conv_f(speedCol, speedRange, horizontalWidth);
    powerColPhysical = conv_f(powerCol, powerRange, verticalHeight);
    speedColPhysicalName = obj.PhysicalSpeedName; % strcat(obj.ColumnNames{1}, '_Physical');
    powerColPhysicalName = obj.PhysicalPowerName; % strcat(obj.ColumnNames{2}, '_Physical');
    
    % Calculate image pixel values from graph pixel values
    speedColImage = speedCol + obj.GraphImageOffsetHorizontal;
    powerColImage = powerCol + obj.GraphImageOffsetVertical;
    speedColImageName = obj.ImageSpeedName; % strcat(obj.ColumnNames{1}, '_Image');
    powerColImageName = obj.ImagePowerName; % strcat(obj.ColumnNames{2}, '_Image');
    
    % Assign
    currObj.FileData.(speedColPhysicalName) = speedColPhysical;
    currObj.FileData.(powerColPhysicalName) = powerColPhysical;
    currObj.FileData.(speedColImageName) = speedColImage;
    currObj.FileData.(powerColImageName) = powerColImage;
    
%     obj.FileData = [obj.FileData, currObj.FileData];
end