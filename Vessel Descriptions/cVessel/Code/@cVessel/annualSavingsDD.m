function [ obj, savingsDD ] = annualSavingsDD(obj, varargin)
%annualSavingsDD Annual savings due to dry-docking performance improvement
%   Detailed explanation goes here

% Output
savingsDDStruc = struct('Savings_MUSD', [], 'Savings_mt', []);
savingsDD = struct('DryDockInterval', savingsDDStruc);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);
% validateattributes(activity, {'numeric'}, {'vector', 'real'}, ...
%     'performanceMark', 'activity', 2);
fuelPricePerTonne = 250;
if nargin > 1
    fuelPricePerTonne = varargin{1};
    validateattributes(fuelPricePerTonne, {'numeric'}, {'scalar', 'real'},...
        'annualSavingsDD', 'fuelPricePerTonne', 2);
end

fuelConsumptionTonnesPerDay = 75;
if nargin > 2
    fuelConsumptionTonnesPerDay = varargin{2};
    validateattributes(fuelPricePerTonne, {'numeric'}, {'scalar', 'real'},...
        'annualSavingsDD', 'fuelConsumptionTonnesPerDay', 3);
end

% Get all DD Performance Improvement
obj = obj.dryDockingImprovement;
% sz = size(obj);
% savingsDDStruc = repmat(savingsDDStruc, sz);

% Iterate over guarantee struct to get averages
% idx_c = cell(1, ndims(obj));
daysPerYear = 365.25;

% Assign into property
% [obj.Report.AnnualSavingsDD] = deal(savingsDDStruc);

while obj.iterateDD
%    
%    [obj, ii] = obj.iterDD;
   
% for ii = 1:numel(obj)
%    [idx_c{:}] = ind2sub(sz, ii);

%    currData = obj(idx_c{:});
   
    % Dry Docking Improvement only calculated from second interval on

    [~, currVessel, ddi] = obj.currentDD;

   % Skip DDi if empty
%    if isempty(obj(ii).DryDockingPerformance)
   if numel(currVessel.Report.DryDockingImprovement) < ddi || ...
        isempty(currVessel.Report.DryDockingImprovement(ddi).RelDDImprovement) || ...
           numel(currVessel.Report.Activity) < (ddi)
       continue
   end
   
   % Get this DD Performance Improvement
%    [~, currVesseli] = obj.ind2sub( ii );
%    currActivity = activity( currVesseli );
   currActivity = currVessel.Report.Activity(ddi);
   currDDPer = currVessel.Report.DryDockingImprovement(ddi).RelDDImprovement / 100;
   currDDSavings = currDDPer * fuelPricePerTonne * ...
       fuelConsumptionTonnesPerDay * daysPerYear * currActivity;
   savingsDDStruc(1).Savings_MUSD = currDDSavings / 1E6;
   savingsDDStruc(1).Savings_mt = currDDPer * ...
       fuelConsumptionTonnesPerDay * daysPerYear * currActivity;
   
   % Assign
%    obj(ii).AnnualSavingsDD = savingsDDStruc(ii);
   currVessel.Report.AnnualSavingsDD(ddi) = savingsDDStruc;
end
% obj = obj.iterReset;