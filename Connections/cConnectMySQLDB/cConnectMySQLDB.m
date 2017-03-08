classdef cConnectMySQLDB
    %cConnectMySQLDB Connect to MySQL Databases via adodb
    %   Detailed explanation goes here
    
    properties
        
        Toolbox = 'adodb';
        
        Server = 'localhost';
        Database = 'hull_performance';
        UserID = 'root';
        Password = 'HullPerf2016';
        Connection = [];
        
    end
    
    methods
        
       function obj = cConnectMySQLDB(varargin)
       % cMySQL Constructor for class cMySQL
       
        % Input
        p = inputParser();
        p.addParameter('Server', obj.Server);
        p.addParameter('Database', obj.Database);
        p.addParameter('UserID', obj.UserID);
        p.addParameter('Password', obj.Password);
        
        p.parse(varargin{:});
        res = p.Results;
        fields = fieldnames(res);
        values = struct2cell(res);
        
        % Assign property values
        for fi = 1:numel(fields)
           obj.( fields{fi} ) = values{fi};
        end
        
        % Make connection
        obj = obj.connect;
       
       end
       
       function obj = connect(obj)
       % connect Create connection to database if none exists
        
        if isempty(obj.Connection)
            
            conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
                        'Server=' obj.Server ';',  ...
                        'Database=', obj.Database, ';',  ...
                        'Uid=' obj.UserID ';',  ...
                        'Pwd=' obj.Password ';'];
                    
            if strcmp(obj.Toolbox, 'adodb')
                obj.Connection = adodb_connect(conn_ch);
            end
        end
       end
       
       function obj = disconnect(obj)
       % disconnect Close connection to database if it exists
           
        if ~isempty(obj.Connection)
            
            obj.Connection.release;
            obj.Connection = [];
            
        end
       end
       
       function obj = hullPer(obj)
       % Connect to schema "hull_performance"
       
           obj = obj.disconnect;
           obj.Server = 'localhost';
           obj.Database = 'hull_performance';
           obj.UserID = 'root';
           obj.Password = 'HullPerf2016';
           obj = obj.connect;
       
       end
       
       function obj = test(obj)
       % Connect to schema "test2"
           
           obj = obj.disconnect;
           obj.Server = 'localhost';
           obj.Database = 'test2';
           obj.UserID = 'root';
           obj.Password = 'HullPerf2016';
           obj = obj.connect;
           
       end
       
    end
end