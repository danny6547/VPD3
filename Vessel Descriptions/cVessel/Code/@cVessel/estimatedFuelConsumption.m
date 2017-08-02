function [ obj, savings ] = estimatedFuelConsumption( obj )
%fuelSavings Summary of this function goes here
%   Detailed explanation goes here

% Output
savings = struct('Fuel', [], 'Cost', []);

% Input
speed2fuel = 3;
consumptionPerDay = 36.5;
daysPerYear = 365.25;
activity = 0.65;
fuelCost = 300;

obj = obj.regressions(1);

% Second DDi is evaluation, first is reference
muRef = 0.059; % nanmean(obj(1).Speed_Index);
muEval = obj.Regression.Coefficients(1) * daysPerYear; % nanmean(obj(2).Speed_Index);

annualConsRef = (1 + speed2fuel*abs(muRef)) * consumptionPerDay * daysPerYear * activity;
annualConsEval = (1 + speed2fuel*abs(muEval)) * consumptionPerDay * daysPerYear * activity;

fuelSavings = annualConsRef - annualConsEval;
costSavings = fuelSavings * fuelCost;

savings.Fuel = fuelSavings;
savings.Cost = costSavings;

% Assign struct to output
obj.EstimatedFuelConsumption = savings;

end