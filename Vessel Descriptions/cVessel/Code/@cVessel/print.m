function obj = print(obj, direct)
%print Write relevant vessel data to file
%   Detailed explanation goes here

% Iterate vessels
for oi = 1:numel(obj)

    % Open file
    filename = fullfile(direct, strcat(obj(oi).Name, '.txt'));
    fid = fopen(filename, 'w');
    
    % Write Vessel IMO and Name
    fprintf(fid, '%s\n', '%% VESSEL IDENTIFIER');
    fprintf(fid, '%s: %s\n', 'Vessel Name', obj(oi).Name);
    fprintf(fid, '%s: %u\n', 'Vessel IMO Number', obj(oi).IMO_Vessel_Number);

    % Write Displacement table
    fprintf(fid, '\n%s\n', '%% DISPLACEMENT MODEL');
    fprintf(fid, '%s: %s\n', 'Displacement Model Name', obj(oi).Displacement.Name);
    fprintf(fid, '%s\t%s\t%s\t%s\n', 'Draft Mean', 'TPC', 'LCF', 'Displacement');
    
    if ~isempty(obj(oi).Displacement.FluidDensity)
        rho = obj(oi).Displacement.FluidDensity /1e3;
    else
        rho = obj(oi).Displacement.DefaultDensity /1e3;
    end
    
    if ~isempty(obj(oi).Displacement.Trim)
        
        fprintf(fid, '%10f\t%10f\t%10f\n', [obj(oi).Displacement.Draft_Mean;
            obj(oi).Displacement.Trim; ...
            obj(oi).Displacement.Displacement/rho]);  % Disp in m3
        
    elseif ~isempty(obj(oi).Displacement.TPC)
        
        fprintf(fid, '%10f\t%10f\t%10f\t%10f\n', [obj(oi).Displacement.Draft_Mean;
            obj(oi).Displacement.TPC; ...
            obj(oi).Displacement.LCF; ...
            obj(oi).Displacement.Displacement/rho]);  % Disp in m3
    end
    
    % Write Wind Coefficient Table
    fprintf(fid, '\n%s\n', '%% WIND COEFFICIENT MODEL');
    fprintf(fid, '%s: %s\n', 'Wind Coefficient Model Name', obj(oi).WindCoefficient.Name);
    fprintf(fid, '%s\t%s\n', 'Direction', 'Coefficient');
    fprintf(fid, '%10f\t%10f\n', [obj(oi).WindCoefficient.Direction; obj(oi).WindCoefficient.Coefficient]);
    
    % Write Speed, Power Table
    fprintf(fid, '\n%s\n', '%% SPEED POWER MODEL');
    speedpowername = strrep(obj(oi).Displacement.Name, 'Empty Displacement Model', 'Speed Power Model');
    fprintf(fid, '%s: %s\n', 'Speed Power Coefficient Model Name', speedpowername);
    
    obj(oi).SpeedPower = obj(oi).SpeedPower.fit;
    for si = 1:numel(obj(oi).SpeedPower)
        
        fprintf(fid, '\n%s\n', 'Click "Add Model Value"');
        fprintf(fid, '%s: %f\n', 'Coefficient A', obj(oi).SpeedPower(si).Coefficients(1));
        fprintf(fid, '%s: %f\n', 'Coefficient B', obj(oi).SpeedPower(si).Coefficients(2));
        fprintf(fid, '%s: %f\n', 'Min Power', min(obj(oi).SpeedPower(si).Power));
        fprintf(fid, '%s: %f\n', 'Max Power', max(obj(oi).SpeedPower(si).Power));
        fprintf(fid, '%s: %f\n', 'Trim', obj(oi).SpeedPower(si).Trim);
        fprintf(fid, '%s: %f\n', 'Disp', obj(oi).SpeedPower(si).Displacement / (obj(oi).SpeedPower(si).FluidDensity / 1e3)); % Disp in m3
    end
    
    % Write Engine Table
    fprintf(fid, '\n%s\n', '%% ENGINE MODEL');
    fprintf(fid, '%s: %s\n', 'Engine Model', obj(oi).Engine.Name);
    fprintf(fid, '%s: %s\n', 'Fuel Info', 'HFO');
    fprintf(fid, '%s: %f\n', 'Lowest Given Brake Power', obj(oi).Engine.Lowest_Given_Brake_Power);
    fprintf(fid, '%s: %f\n', 'X0', obj(oi).Engine.X0);
    fprintf(fid, '%s: %f\n', 'X1', obj(oi).Engine.X1);
    fprintf(fid, '%s: %f\n', 'X2', obj(oi).Engine.X2);
    
    % Write Vessel Info
    fprintf(fid, '\n%s\n', '%% VESSEL INFO');
    fprintf(fid, '%s: %s\n', 'Vessel Name', obj(oi).Name);
    fprintf(fid, '%s: %s\n', 'Valid From', datestr(now, 'dd-mm-yyyy'));

    % Write Vessel Configuration
    fprintf(fid, '\n%s\n', '%% VESSEL CONFIGURATION');
    fprintf(fid, '%s: %s\n', 'Valid From', datestr(now, 'dd-mm-yyyy'));
    fprintf(fid, '%s: %s\n', 'Valid To', datestr(now, 'dd-mm-yyyy'));
    fprintf(fid, '%s: %s\n', 'Description', '');
    
    if ~isempty(obj(oi).WindCoefficient)
        fprintf(fid, '%s: %s\n', 'Wind Coefficient Model', obj(oi).WindCoefficient.Name);
    end
    
    if ~isempty(obj(oi).SpeedPower)
        fprintf(fid, '%s: %s\n', 'Speed Power Coefficient Model', speedpowername);
    end
    
    if ~isempty(obj(oi).Displacement)
        fprintf(fid, '%s: %s\n', 'Displacement Model', obj(oi).Displacement.Name);
    end
    
    if ~isempty(obj(oi).Engine)
        fprintf(fid, '%s: %s\n', 'Engine Model', obj(oi).Engine.Name);
    end
    
    fprintf(fid, '%s: %f\n', 'Transverse Projected Area Design', obj(oi).Transverse_Projected_Area_Design);
    fprintf(fid, '%s: %f\n', 'Block Coefficient', obj(oi).Block_Coefficient);
    fprintf(fid, '%s: %f\n', 'Length Overall', obj(oi).Length_Overall);
    fprintf(fid, '%s: %f\n', 'Breadth Moulded', obj(oi).Breadth_Moulded);
    fprintf(fid, '%s: %s\n', 'Speed, Power Source', 'Model Test');
    fprintf(fid, '%s: %f\n', 'Draft Design', obj(oi).Draft_Design);
    fprintf(fid, '%s: %f\n', 'Wind Reference Height Design', obj(oi).Wind_Reference_Height_Design);
    fprintf(fid, '%s: %f\n', 'Anemometer_Height', obj(oi).Anemometer_Height);
    fprintf(fid, '%s: %f\n', 'LBP', obj(oi).LBP);
    
    % Write Vessel Owners
    fprintf(fid, '\n%s\n', '%% VESSEL OWNERS');
    fprintf(fid, '%s: %s\n', 'Vessel Owner', obj(oi).Owner);
    fprintf(fid, '%s: %s\n', 'Valid From', datestr(now, 'dd-mm-yyyy'));
    fprintf(fid, '%s: %s\n', 'Valid To', datestr(now, 'dd-mm-yyyy'));
    
    % Write Dry Docks
    fprintf(fid, '\n%s\n', '%% DRY DOCKS');
    if ~isempty(obj(oi).DryDockDates)
        
        for di = 1:numel(obj(oi).DryDockDates)
            fprintf(fid, '%s: %s\n', 'Start Date', obj(oi).DryDockDates(di).StartDate);
            fprintf(fid, '%s: %s\n', 'End Date', obj(oi).DryDockDates(di).EndDate);
        end
    else
        
        fprintf(fid, '%s\n', 'No Data');
    end
    fprintf(fid, '%s: %s\n', 'Coating and Surface Prep', 'Ignore for now');
    
    % Write Dry Docks
    fprintf(fid, '\n%s\n', '%% BUNKER DELIVERY NOTES');
    fprintf(fid, '%s: %s\n', 'Fuel Type', 'HFO');
    fprintf(fid, '%s: %f\n', 'Mass', 5000);
    fprintf(fid, '%s: %f\n', 'Sulphur Content', 2.8);
    fprintf(fid, '%s: %f\n', 'Density_15', 0.991);
    fprintf(fid, '%s: %f\n', 'LCV', 40.5);
    fprintf(fid, '%s: %f\n', 'Density_Change_Rate', 1);
    
    % Close file
    fclose(fid);
end