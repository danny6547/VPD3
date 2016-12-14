% Get all table data for TMS into excel %

% Inputs
HempelDDi_c = [num2cell(2*ones(1, 3)), {4}, {2:3}, {2:3}];
relevantHempelDDi_c = [num2cell(2*ones(1, 3)), {4}, {2}, {2}];

% Get data
tmsimo_v = [9389083, 9395329, 9395331, 9308857, 9308833, 9308821];
out = performanceData(tmsimo_v, 0);

% Write xls
xlsfile = 'TMSReportData1.xlsx';

% Service Interval %
servStruct = serviceInterval(out);
tmsDDI = [1, 1, 1, 1, 2, 2];
vesselServ = arrayfun(@(x) x.ServiceInterval, servStruct, 'Uni', 0);
coli = 1:size(vesselServ, 2);
vesselServNan = vesselServ;
vesselServNan(cellfun(@isempty, vesselServNan)) = {nan};
firstNanI = arrayfun(@(x) find(~isnan([vesselServNan{:, x}]), 1, 'last'), coli);
vesselServNan_m = reshape([vesselServNan{:}], [4, 6]);
% vesselServTotal = arrayfun(@(x, y, z) nansum(vesselServNan_m(x - y + 1:end, z)), firstNanI, tmsDDI, coli);
vesselServTotal_c = cellfun(@(x, z) [vesselServNan{x, z}],...
    relevantHempelDDi_c, num2cell(coli), 'Uni', 0);

[vesselNamesUnordered, w] = vesselName(tmsimo_v);
[~, vesselNameI] = ismember(tmsimo_v, w);
vesselNamesOrdered = vesselNamesUnordered(vesselNameI);

% Power Increase over the service interval
[~, powerInc] = powerIncreasePerCoating( out );
powerInc_c = squeeze(struct2cell( powerInc ));
vesselPowerInc_c = cellfun(@(x, y) [powerInc_c{x, y}], relevantHempelDDi_c,...
    num2cell(coli), 'Uni', 0);

% Performance mark
markStruct = performanceMark( out );
perMark_c = squeeze(struct2cell( markStruct ));
vesselPerMark_c = cellfun(@(x, y) [perMark_c{x, y}], relevantHempelDDi_c,...
    num2cell(coli), 'Uni', 0);

% Write to file
servTable = {'Ship', ...
    'Service interval / months', ...
    'Power increase over the service interval / %',...
    'Performance Mark'};
servTable = [servTable; vesselNamesOrdered(:), vesselServTotal_c(:), ...
    vesselPowerInc_c(:), vesselPerMark_c(:)];
xlswrite(xlsfile, servTable, 'Sheet1', 'A1');

% Power increase per coating
coli_c = num2cell(coli);
idx_c = cellfun(@(x, y) num2cell([x, y]), relevantHempelDDi_c, coli_c,...
    'Uni', 0);
hempelData = cellfun(@(x) out(x{:}), idx_c); % out([relevantHempelDDi_c{:}], coli);
powerCoatingStruct = powerIncreasePerCoating( hempelData );

coatPerTable = {'Coating Technology', 'Average service time / months',...
    'Power increase / %'};
coatPerTable = [coatPerTable; ...
                {powerCoatingStruct.Coating}',...
                {powerCoatingStruct.AvgServiceInterval}',...
                {powerCoatingStruct.AvgPwrIncrease}'];
xlswrite(xlsfile, coatPerTable, 'Sheet1', 'F1');

% Table for DD performance
coli_c = [coli_c; coli_c];
relevantHempelDDi_c = [num2cell([relevantHempelDDi_c{:}] - 1); ...
    relevantHempelDDi_c];
idx_c = cellfun(@(x, y) num2cell([x, y]), relevantHempelDDi_c, coli_c,...
    'Uni', 0);
hempelData = cellfun(@(x) out(x{:}), idx_c);
% hempelData = reshape(hempelData, [2, 6]);
ddPer = dryDockingPerformance(hempelData);
vessels = vesselName(tmsimo_v);

ddPerTable = [{'Vessel', ...
    'Performance level prior to dry-docking / %',...
    'Performance level after dry-docking / %',...
    'Performance level increase after dry-docking (Absolute) / %', ...
    'Performance level increase after dry-docking (Relative) / %'}; ...
    vessels,...
    num2cell([ddPer.AvgPerPrior]*100)', ...
    num2cell([ddPer.AvgPerAfter]*100)', ...
    num2cell([ddPer.AbsDDPerformance])', ...
    num2cell([ddPer.RelDDPerformance])'...
    ];
xlswrite(xlsfile, ddPerTable, 'Sheet1', 'K1');

% Table for DD performance-based fuel savings
activity_v = [78, 77, 59, 59, 75, 70]./100;
savingsDDStruc = annualSavingsDD(hempelData, activity_v);
savingsTable = [{'Vessel', ...
    'Fuel consumption descrease due to DD / %',...
    'Annual savings vs. pre-docking baseline / mil $'}; ...
    vessels,...
    {ddPer.RelDDPerformance}', ...
    {savingsDDStruc.Savings_MUSD}'
    ];
xlswrite(xlsfile, savingsTable, 'Sheet1', 't1');