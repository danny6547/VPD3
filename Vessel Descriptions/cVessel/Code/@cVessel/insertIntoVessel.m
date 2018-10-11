function obj = insertIntoVessel(obj)
%insertIntoVessels Insert into table 'Vessel' if IMO not found
%   Detailed explanation goes here

if isempty(obj.IMO) && isempty(obj.Vessel_Id)
    
    errid = 'loadRaw:NeedIdentifier';
    errmsg = ['Vessel_Id needed to load raw data. Assign either a valid '...
        'Vessel_Id or IMO'];
    error(errid, errmsg);
end

tab = 'Vessel';
col = 'COUNT(*) > 0';
where_sql = ['IMO = ', num2str(obj.IMO)];

for oi = 1:numel(obj)
    
    if ~isempty(obj(oi).Vessel_Id)
        
        continue
    end
    
    sql = obj(oi).SQL;
    [~, inTab_tbl] = sql.select(tab, col, where_sql);
    inTab = [inTab_tbl{:, :}];
    
    if ~inTab %#ok<BDSCI,BDLGI>
        
        col = {'IMO', 'Deleted'};
        values = [obj.IMO, 0];
        sql.insert(tab, col, values);
        
        col = 'Vessel_Id';
        vid = sql.select(tab, col, where_sql);
        obj(oi).Vessel_Id = vid;
    end
end