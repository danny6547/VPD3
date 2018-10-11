%% Clone / pull and update the following repositories:
% FileAndDirectory
% MATLAB Type Extension
% mMySQL
% Vessel Performance Database
% Toolboxes
    % adodb
    % nansuite
    
%% Update MATLAB paths with top-level direcory of working copies

%% Create Databases
stage = 'Create SHAPE DB';
report_f = @(stage) fprintf(1, ['\n', datestr(now), ' SHAPEDev installation '...
    'failed to: ', stage, '\n']);
success_f = @() fprintf(1, ['\n', datestr(now), ' SHAPEDev installation '...
    'succeeded.\n']);
reportCannotLoadDB_f = @() fprintf(1, ['\n', datestr(now), ' Cannot access '...
    '''Vessel Library'' folder, external databases not loaded.\n']);

try  % Create local SHAPE DB
    
    obj = cDB();
    obj.createStatic;
    obj.createInService;
catch ee
    
    report_f(stage);
    rethrow(ee)
end

stage = 'Create External DB';
try % Create External Performance DB
    
    obj.createDNVGL;
    obj.createForce;
    if ~obj.LibraryAccessible
        
        reportCannotLoadDB_f();
    end
catch ee
    
    report_f(stage);
end

%% Test Project
stage = 'Test Project';
try % Test Project
    
    res = run(testProject);
    
    if all(~[res.Passed])
        
        errid = 'InstallProject:TestFailure';
        errmsg = 'All project tests failed';
        error(errid, errmsg)
    end
catch ee
    
    report_f(stage);
    rethrow(ee)
end

%% Migrate
stage = 'Migrate';
imoMigrated = [];
try % Migrate
    
    imoMigrated = obj.migrateVessels('hullperformance', 'static');
catch ee
    
    report_f(stage);
end

%% Run ISO on successfully migrated vessels
stage = 'Run ISO19030';
try % Run ISO
    
    imo4ISO = [9036442, 9500728, 9411305, 9330874];
    imoMigrated_l = ismember(imo4ISO, imoMigrated);
    imo4ISO = imo4ISO(imoMigrated_l);
    if isempty(imo4ISO)
        
        report_f(stage);
        errid = 'InstallProject:CannotRunISO';
        errmsg = 'No vessels selected for ISO analysis have been migrated';
        error(errid, errmsg)
    else
        
        obj.migrateVessels('hullperformance', '',...
            'hullperformance', 'inservice', imo4ISO);
        obj = cVessel('DatabaseStatic', 'static',...
                        'DatabaseInService', 'inservice',...
                        'IMO', imo4ISO);
        obj.analyse();
    end
catch ee
    
    report_f(stage);
    rethrow(ee);
end

%% Test report methods
stage = 'Report Generation Methods';
try % Report Generation Methods
    
    existingFig = findall(0, 'type', 'figure');
    run('Test_Vessel_Report');
    allFig = findall(0, 'type', 'figure');
    newFig = setdiff(allFig, existingFig);
    delete(newFig);
    success_f();
catch ee
    
    report_f(stage);
    rethrow(ee);
end