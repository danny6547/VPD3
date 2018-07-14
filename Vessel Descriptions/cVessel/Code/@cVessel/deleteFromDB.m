function [failSql, errSt] = deleteFromDB(obj)
%delete Delete obj from database
%   Detailed explanation goes here

% Write file containing any tables where delete operation failed
nSQL = 19;
errSt = cell(numel(obj), nSQL);
failSql = cell(numel(obj), nSQL);

for oi = 1:numel(obj)

    % Remove rows from each static table corresponding to obj
    vid = obj(oi).Model_ID;
    spid = [obj(oi).SpeedPower.Model_ID];
    did = obj(oi).Displacement.Model_ID;
    wid = obj(oi).WindCoefficient.Model_ID;
    spmid = obj(oi).Configuration.Speed_Power_Coefficient_Model_Id;
    oid = obj(oi).Owner.Model_ID;
    eid = obj(oi).Engine.Engine_Model;
    ddid = [obj(oi).DryDock.Model_ID];
    vcid = [obj(oi).Configuration.Model_ID];

    sql = cell(1, nSQL);
    if ~isempty(vid)

        where_sql = ['Vessel_Id = ', num2str(vid)];
        [~, sql{1}] = obj.SQL.deleteSQL('vessel', where_sql);
        [~, sql{2}] = obj.SQL.deleteSQL('vesselInfo', where_sql);
        [~, sql{3}] = obj.SQL.deleteSQL('vesselConfiguration', where_sql);
        [~, sql{4}] = obj.SQL.deleteSQL('vesselToVesselOwner', where_sql);
        [~, sql{5}] = obj.SQL.deleteSQL('BunkerDeliveryNote', where_sql);
        [~, sql{6}] = obj.SQL.deleteSQL('DryDock', where_sql);
    end

    if ~isempty(spid)

        whereSP_sql = ['Speed_Power_Coefficient_Model_Value_Id IN (', sprintf('%u, %u', spid), ')'];
        [~, sql{7}] = obj.SQL.deleteSQL('SpeedPower', whereSP_sql);
    end

    if ~isempty(eid)

        whereEngine_sql = ['Engine_Model = ''', eid, ''''];
        [~, sql{8}] = obj.SQL.deleteSQL('EngineModel', whereEngine_sql);
    end

    if ~isempty(spmid)

        whereSPModel_sql = ['Speed_Power_Coefficient_Model_Id = ', num2str(spmid)];
        [~, sql{9}] = obj.SQL.deleteSQL('SpeedPowerCoefficientModel', whereSPModel_sql);
        [~, sql{10}] = obj.SQL.deleteSQL('SpeedPowerCoefficientModelValue', whereSPModel_sql);
    end

    if ~isempty(did)

        whereDisp_sql = ['Displacement_Model_Id = ', num2str(did)];
        [~, sql{11}] = obj.SQL.deleteSQL('DisplacementModel', whereDisp_sql);
        [~, sql{12}] = obj.SQL.deleteSQL('DisplacementModelValue', whereDisp_sql);
    end

    if ~isempty(wid)

        whereWind_sql = ['Wind_Coefficient_Model_Id = ', num2str(wid)];
        [~, sql{13}] = obj.SQL.deleteSQL('WindCoefficientModel', whereWind_sql);
        [~, sql{14}] = obj.SQL.deleteSQL('WindCoefficientModelValue', whereWind_sql);
    end

    if ~isempty(oid)

        whereOwner_sql = ['Vessel_Owner_Id = ', num2str(oid)];
        [~, sql{15}] = obj.SQL.deleteSQL('vesselOwner', whereOwner_sql);
        [~, sql{16}] = obj.SQL.deleteSQL('vesselToVesselOwner', whereOwner_sql);
    end
    
    if ~isempty(ddid)
        
        whereDryDock_sql = ['Dry_Dock_Id IN ', obj.SQL.colList(num2str([obj.DryDock.Model_ID]'))];
        [~, sql{17}] = obj.SQL.deleteSQL('DryDock', whereDryDock_sql);
    end

    % Remove from in-service tables
    if ~isempty(vcid)
        
        whereConfig_sql = ['Vessel_Configuration_Id IN ', obj.SQL.colList(num2str(vcid'))];
        [~, sql{18}] = obj.SQL.deleteSQL('CalculatedData', whereConfig_sql);
    end
    
    if ~isempty(vid)
        
        [~, sql{19}] = obj.SQL.deleteSQL('RawData', where_sql);
    end

    errid = cell(1, numel(sql));
    fails_i = false(1, numel(sql));
    for si = 1:numel(sql)

        try obj.SQL.execute(sql{si});
        catch ee

            errid(si) = {ee};
            fails_i(si) = true;
        end

        failSql(si, fails_i) = sql(fails_i);
        errSt(si, fails_i) = errid(fails_i);
    end
end

failSql(cellfun(@isempty, failSql)) = [];
errSt(cellfun(@isempty, errSt)) = [];