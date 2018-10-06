function [ proc ] = procedureDefault(obj)
%procedureDefault Default procedure call structure for ISO19030
%   Detailed explanation goes here

    proc = struct('procedure', {}, 'input', {}, 'isSQL', {});
    if isempty(obj.VesselConfiguration)
        
        return
    end
    
    vcid_ch = num2str(obj.VesselConfiguration.Model_ID);
    
    % Get retreived data set 5.3.3
    proc(end+1).procedure = 'createTempRawISO';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'removeInvalidRecords';
    proc(end).input = {};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'sortOnDateTime';
    proc(end).input = {};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateDefaultValues';
    proc(end).input = {};
    proc(end).isSQL = true;
    
%     % Normalise frequency rates 5.3.3.1
%     proc(end+1).procedure = 'normaliseHigherFreq';
%     proc(end).input = {};
%     proc(end).isSQL = true;
%     proc(end+1).procedure = 'normaliseLowerFreq';
%     proc(end).input = {};
%     proc(end).isSQL = true;
    
    % Get validated data set 5.3.4
    proc(end+1).procedure = 'updateChauvenetCriteria';
    proc(end).input = {};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateValidated';
    proc(end).input = {};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateTrim';
    proc(end).input = {};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateDisplacement';
    proc(end).input = {obj, obj.VesselConfiguration};
    proc(end).isSQL = false;
    proc(end+1).procedure = 'filterSpeedPowerLookup';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    
    % Correct for environmental factors 5.3.5
    proc(end+1).procedure = 'updateDeliveredPower';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateAirDensity';
    proc(end).input = {};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateTransProjArea';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateWindReference';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateWindResistanceRelative';
    proc(end).input = {obj, obj.VesselConfiguration};
    proc(end).isSQL = false;
    proc(end+1).procedure = 'updateAirResistanceNoWind';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateWindResistanceCorrection';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'updateCorrectedPower';
    proc(end).input = {};
    proc(end).isSQL = true;
    
    % Calculate Performance Values, Expected Speed 5.3.6.2
    proc(end+1).procedure = 'updateExpectedSpeed';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    
    % Calculate Performance Values, Percentage speed loss 5.3.6.1
    proc(end+1).procedure = 'updateSpeedLoss';
    proc(end).input = {};
    proc(end).isSQL = true;
    
    % Calculate filter
    proc(end+1).procedure = 'filterSFOCOutOfRange';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'filterPowerBelowMinimum';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
    proc(end+1).procedure = 'filterReferenceConditions';
    proc(end).input = {vcid_ch};
    proc(end).isSQL = true;
end