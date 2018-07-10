function failSql = delete(obj)
%delete Delete obj from database
%   Detailed explanation goes here

failSql = {};

for oi = 1:numel(obj)

% Remove rows from each static table corresponding to obj
vid = obj(oi).Model_ID;
spid = [obj(oi).SpeedPower.Model_ID];
did = obj(oi).Displacement.Model_ID;
wid = obj(oi).WindCoefficient.Model_ID;
spmid = obj(oi).Configuration.Speed_Power_Coefficient_Model_Id;
oid = obj(oi).Owner.Model_ID;
eid = obj(oi).Engine.Engine_Model;

sql = {};
if ~isempty(vid)
    
    where_sql = ['obj_Id = ', num2str(vid)];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('Vessel', where_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('VesselInfo', where_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('VesselConfiguration', where_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('VesselToVesselOwner', where_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('BunkerDeliveryNote', where_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('DryDock', where_sql);
end

if  ~isempty(spid)
    
    whereSP_sql = ['Speed_Power_Coefficient_Model_Value_Id IN (', sprintf('%u, %u', spid), ')'];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('SpeedPower', whereSP_sql);
end

if  ~isempty(eid)
    
    whereEngine_sql = ['Engine_Model = ''', eid, ''''];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('EngineModel', whereEngine_sql);
end

if  ~isempty(spmid)
    
    whereSPModel_sql = ['Speed_Power_Coefficient_Model_Id = ', num2str(spmid)];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('SpeedPowerCoefficientModel', whereSPModel_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('SpeedPowerCoefficientModelValue', whereSPModel_sql);
end

if  ~isempty(did)
    
    whereDisp_sql = ['Displacement_Model_Id = ', num2str(did)];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('DisplacementModel', whereDisp_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('DisplacementModelValue', whereDisp_sql);
end

if  ~isempty(wid)
    
    whereWind_sql = ['Wind_Coefficient_Model_Id = ', num2str(wid)];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('WindCoefficientModel', whereWind_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('WindCoefficientModelValue', whereWind_sql);
end

if  ~isempty(oid)
    
    whereOwner_sql = ['Vessel_Owner_Id = ', num2str(oid)];
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('VesselOwner', whereOwner_sql);
    [vessel, sql{end+1}] = vessel.SQL.deleteSQL('VesselToVesselOwner', whereOwner_sql);
end

% Remove from in-service tables


% Write file containing any tables where delete operation failed
fails_i = false(1, numel(obj));
for si = 1:numel(sql)
    
    try vessel.execute(sql{si});
        
    catch
        
        fails_i(si) = true;
    end
end
failSql = [failSql, sql(fails_i)];

end