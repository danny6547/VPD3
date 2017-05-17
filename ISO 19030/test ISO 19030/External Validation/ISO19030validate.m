% Validate ISO19030allData = 
allData = ...
[14.0 50.6 10858 10967 8796 .810 1345 .092 .206 .705 1.004
15.0 54.2 13273 13407 10715 .807 1535 .095 .206 .706 1.004
16.0 57.7 15978 16139 12776 .800 1733 .104 .206 .707 1.004
17.0 61.2 18951 19142 15134 .799 1937 .106 .205 .708 1.004
18.0 64.6 22295 22520 18003 .807 2153 .097 .205 .709 1.003
19.0 68.3 26348 26614 21245 .806 2409 .098 .204 .708 1.004
20.0 72.0 30964 31277 24754 .799 2686 .104 .204 .708 1.004
21.0 75.9 36257 36623 28936 .798 2991 .104 .204 .707 1.004
22.0 80.0 43050 43485 34043 .791 3376 .109 .204 .704 1.004
23.0 84.5 51246 51764 39912 .779 3824 .118 .204 .700 1.004
24.0 88.9 60295 60904 46616 .773 4292 .120 .204 .697 1.004
25.0 93.2 70034 70742 54307 .775 4769 .115 .203 .695 1.004];
objSP = cVesselSpeedPower();
objSP.Speed = allData(:, 1);
objSP.Power = allData(:, 3);
objSP.Trim = 0;
objSP.Displacement = 207857.4;

wind16022 = cVesselWindCoefficient();
wind16022.ModelID = 1;

obj = cVessel('IMO', 9454448);
obj.SpeedPower = objSP;
obj.WindCoefficient = wind16022;

% Create files for CMA CGM 16022 TEU vessel Alexander
isoFile = ['C:\Users\damcl\OneDrive - Hempel Group\Documents\MATLAB\'...
    'validateISO19030Test.csv'];
spFiles = {};
windFile = ['C:\Users\damcl\OneDrive - Hempel Group\Documents\MATLAB\'...
    'validateISO19030TestWind.csv'];
filter = true;
obj = obj.validateISO19030(isoFile, spFiles, windFile, filter);

% Insert made-up data into empty columns of file
% iso_m = csvread(isoFile, 0, 0, [0, 2, 400, 14]);
fid = fopen(isoFile);
fileOut_c = textscan(fid, '%19c,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f'); 

numRows = size(fileOut_c{1}, 1);
rAirTemp = randn(numRows, 1)*5 + 15;
rHeading = randn(numRows, 1) + 90;
rRudderAngle = randn(numRows, 1) + 0;
rWaterDepth = abs(randn(numRows, 1)*1) + 250;
rDisplacements = abs(randn(numRows, 1)*0) + 207857.4;

fileOut_c([7, 9:11, 14]) = {rAirTemp, rHeading, rRudderAngle, rWaterDepth, ...
    rDisplacements};
% fileOut_c(2:end) = cellfun(@(x) x(:)', fileOut_c(2:end), 'Uni', 0);
% fileOut_c = fileOut_c';

fclose(fid);
fid = fopen(isoFile, 'w+');
q = [cellfun(@cellstr, fileOut_c(1), 'Uni', 0), ...
    cellfun(@(x) num2cell(x), fileOut_c(2:end), 'Uni', 0)];
w = [q{:}];
for ii = 1:numRows
    fprintf(fid, '%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', w{ii, :});
end
fid = fclose(fid);

% Manually Run Software with the following parameters:

% Read output files

% Compare results