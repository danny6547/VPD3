function [ obj, savingsDDStruc ] = annualSavingsDD(obj, activity, varargin)
%annualSavingsDD Annual savings due to dry-docking performance improvement
%   Detailed explanation goes here

% Output
savingsDDStruc = struct('Savings_MUSD', []);

% Input
% validateattributes(obj, {'struct'}, {}, 'performanceMark', 'obj',...
%     1);
validateattributes(activity, {'numeric'}, {'vector', 'real'}, ...
    'performanceMark', 'activity', 2);
fuelPricePerTonne = 250;
if nargin > 2
    fuelPricePerTonne = varargin{1};
    validateattributes(fuelPricePerTonne, {'numeric'}, {'scalar', 'real'},...
        'annualSavingsDD', 'fuelPricePerTonne', 3);
end

fuelConsumptionTonnesPerDay = 75;
if nargin > 3
    fuelConsumptionTonnesPerDay = varargin{2};
    validateattributes(fuelPricePerTonne, {'numeric'}, {'scalar', 'real'},...
        'annualSavingsDD', 'fuelConsumptionTonnesPerDay', 4);
end

% Get all DD Performance Improvement
ddPer = dryDockingPerformance(obj);
sz = size(ddPer);
savingsDDStruc = repmat(savingsDDStruc, sz);

% Iterate over guarantee struct to get averages
idx_c = cell(1, ndims(ddPer));
daysPerYear = 365.25;
for ii = 1:numel(ddPer)
   
   [idx_c{:}] = ind2sub(sz, ii);
   currData = ddPer(idx_c{:});
   currActivity = activity( idx_c{2} );
   
   % Skip DDi if empty
   if all(isnan(currData.RelDDPerformance))
       continue
   end
   
   % Get this DD Performance Improvement
   currDDPer = ddPer(idx_c{:}).RelDDPerformance / 100;
   currDDSavings = currDDPer * fuelPricePerTonne * ...
       fuelConsumptionTonnesPerDay * daysPerYear * currActivity;
   savingsDDStruc(idx_c{:}).Savings_MUSD = currDDSavings / 1E6;
   
end

% Assign
obj.AnnualSavingsDD = savingsDDStruc;