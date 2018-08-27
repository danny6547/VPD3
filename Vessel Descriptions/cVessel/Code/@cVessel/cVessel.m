classdef cVessel < cModelID
    %CVESSEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Dependent)
        
    end
    
    properties
        
        IMO double = [];
        Vessel_Id double = [];
        Database char = '';
        
        Configuration = [];
        SpeedPower = [];
        DryDock = [];
        WindCoefficient = [];
        Displacement = [];
        Engine = [];
        Owner = [];
        FuelType = 'HFO';
        
        Variable = 'speed_loss';
        TimeStep double = 1;
        InService;
        
        Report = [];
    end
    
    properties(Hidden)
        
        DateFormStr char = 'dd-mm-yyyy HH:MM:SS';
        IterFinished = false;
        DryDockIndexDB = [];
        DDIterator = [0, 1, 0];
        Info = [];
        PreviousConfiguration;
    end
    
    properties(Dependent)
        
        Propulsive_Efficiency;
        Engine_Model;
        Wind_Reference_Height_Design;
    end
    
    properties(Hidden, Dependent)
        
        DDIntervals;
        numDDIntervals;
    end
    
    properties(Access = private)
        
        PerformanceTable = 'PerformanceData';
    end
    
    properties(Hidden, Constant)
        
        ModelTable = 'Vessel';
        ValueTable = {'VesselConfiguration', 'VesselInfo'};
        ModelField = {'IMO', 'Vessel_Id', 'Vessel_Id'};
        ValueObject = {'Configuration', 'Info'};
        DataProperty = {'IMO', 'Vessel_Id', 'Deleted', 'Model_ID'};
        OtherTable = {};
        OtherTableIdentifier = {};
        TableIdentifier = 'Vessel_Id';
        NameAlias = '';
        EmptyIgnore = {'Deleted', 'R_Squared'};
    end
    
    methods
       
       function obj = cVessel(varargin)
       % Class constructor. Construct new object, assign array of IMO.
       
       % Initialise Connections
       obj = obj@cModelID(varargin{:});

        % Inputs
        p = inputParser();
        p.addParameter('IMO', []);
        p.addParameter('FileName', '');
        p.KeepUnmatched = true;
        p.parse(varargin{:});
        res = p.Results;

        imo = res.IMO;
        imo_l = ~isempty(imo);
        readInputs_c = {imo};
        
        obj = obj.assignDefaults(varargin{:});
        if ~imo_l
            return
        end


        if imo_l

           % Read data out from DB
           validateattributes(imo, {'numeric'},...
              {'positive', 'real', 'integer'}, 'cVessel constructor',...
              'IMO', 1);
           
           % Expand into array
           obj = [obj, arrayfun(@(x) cVessel(), nan([1, numel(imo)-1]))];
           
           [obj, ~, ~, indb] = obj.performanceData(readInputs_c{:});
        end

        obj = obj.assignDefaults();

        % Get IMO from struct
        if ~any(indb)

           size_c = num2cell(size(imo));
           obj(size_c{:}) = cVessel();
           imo_c = num2cell(imo);
           [obj.IMO] = deal(imo_c{:});
        else
            
            % Remove from array any without data
            obj(~indb) = [];

            % Check that no duplicates were added when concatenating struct
            % data with that read from DB
            index_c = 'datetime_utc';
            prop_c = {'performance_index'...
                    'speed_index'};
            obj = obj.filterOnUniqueIndex(index_c, prop_c);
        end
       end
       
       function obj = assignClass(obj, vesselclass)
       % assignClass Assign vessel to vessel class.
       
       % Inputs
       validateattributes(vesselclass, {'cVesselClass'}, {'scalar'}, ...
           'assignClass', 'vesselclass', 1);
       if isscalar(vesselclass)
           vesselclass = repmat(vesselclass, size(obj));
       end
       
       [obj.LBP] = vesselclass(:).LBP;
       [obj.Engine] = vesselclass(:).Engine;
       [obj.Transverse_Projected_Area_Design] = vesselclass(:).Transverse_Projected_Area_Design;
       [obj.Block_Coefficient] = vesselclass(:).Block_Coefficient;
       [obj.Length_Overall] = vesselclass(:).Length_Overall;
       [obj.Breadth_Moulded] = vesselclass(:).Breadth_Moulded;
       [obj.Draft_Design] = vesselclass(:).Draft_Design;
       [obj.Class] = vesselclass(:).WeightTEU;
       [obj.Anemometer_Height] = vesselclass(:).Anemometer_Height;
       
       end
       
       function obj = insert(obj)
       % insert Insert all available vessel data into database
           
           % Vessels
           if any(isempty([obj.IMO]))
               
               errid = 'cV:EmptyIMO';
               errmsg = 'Vessel cannot be inserted without an IMO number';
               error(errid, errmsg);
           end

           % Insert models that may need to get identifier from DB first
           if ~isempty([obj.SpeedPower])
               obj.SpeedPower.insert();
           end
           
           if ~isempty([obj.Engine])
               
               obj.Engine.insert();
           end
           
           if ~isempty([obj.WindCoefficient])
               obj.WindCoefficient.insert();
           end
           
           if ~isempty([obj.Displacement])
               obj.Displacement.insert();
           end
           
           for oi = 1:numel(obj)
               
               currObj = obj(oi);
               
               % Assign model identifiers to objects not directly
               % identified by it
               spcMID = unique([currObj.SpeedPower.Speed_Power_Coefficient_Model_Id]);
               currObj.Configuration.Speed_Power_Coefficient_Model_Id = spcMID;
               
               engMID = currObj.Engine.Model_ID;
               currObj.Configuration.Engine_Model_Id = engMID;
               
               winMID = currObj.WindCoefficient.Model_ID;
               currObj.Configuration.Wind_Coefficient_Model_Id = winMID;
               
               disMID = currObj.Displacement.Model_ID;
               currObj.Configuration.Displacement_Model_Id = disMID;
               
               % Insert vessel
               currObj = insert@cModelID(currObj);
               
               % Insert DD
               vid = currObj.Model_ID;
%                [currObj.DryDock.Model_ID] = deal(vid);
               [currObj.DryDock.Vessel_Id] = deal(vid);
               currObj.DryDock.insert();
               
               % Insert owner
%                [currObj.Owner.Model_ID] = deal(vid);
               [currObj.Owner.Vessel_Id] = deal(vid);
               currObj.Owner.insert();
           end
       end
       
%        function obj = insertIntoVessels(obj)
%        % insertIntoVessels Insert vessel data into table 'Vessels'.
%        
%        % If wind model given, assign id to particulars
%        wind_cvw = [obj.WindCoefficient];
%        hasWind_l = ~cellfun(@isempty, {wind_cvw.Name});
%        wind_cv = obj(hasWind_l);
%        
%        for oi = 1:numel(wind_cv)
%            
%            wind_cv(oi).Particulars.Wind_Model_ID = ...
%                wind_cv(oi).WindCoefficient.Models_id;
%        end
%        
%        % Insert
%        parts = [obj.Particulars];
%        parts.insertIntoTable();
%            
%        obj.insertIntoTable();
%        
%        end

       function written = reportTable(obj, filename)
       % reportTable Write tables for report into xlsx file
       % written = reportTable(obj, filename) will write into partial or
       % full file path string FILENAME the tables for the hull performance
       % report and return in the fields of struct WRITTEN logical values
       % indicating which tables were generated. Tables whose values are
       % fully given in OBJ are generated.
       
       % Output
       written = struct('Service', false,...
                        'Coating', false,...
                        'DDPerformance', false, ...
                        'Savings', false);
       
       % Input
       validateattributes(filename, {'char'}, {'vector'}, 'reportTable',...
           'filename', 2);
       if exist(filename, 'file') == 2
           
          errid = 'ShipAnalysis:FileInvalid';
          errmsg = 'Input FILENAME must not exist.';
          error(errid, errmsg);
       end
       
       % Write table 1
       
       
       end

        function obj = loadDNVGLPerformance(obj, filename, varargin)
        % loadDNVGLPerformance Load performance data sourced from DNVGL.

        % Input
        filename = validateCellStr(filename);
        imo = [];
        if nargin > 2
            
            imo = varargin{1};
            validateattributes(imo, {'numeric'}, {'vector', 'integer', ...
                'positive'}, 'loadDNVGLPerformance', 'imo', 3);
        end

        deleteTab_l = true;
        if nargin > 3

            deleteTab_l = varargin{1};
            validateattributes(deleteTab_l, {'logical'}, {'scalar'},...
                'loadDNVGLPerformance', 'deleteTab_l', 2);
        end

        % Convert xls files to tab, if necessary
        if ~isscalar(filename)

            [~, file, ext] = cellfun(@fileparts, filename, 'Uni', 0);
            ext = unique(ext);

            if numel(ext) > 1

                errid = 'VesselDB:MultiFileTypes';
                errmsg = ['If FILENAME is a non-scalar, file extensions '...
                    'must all be either ''tab'' or ''xlsx''.'];
                error(errid, errmsg);
            end

            file = file{1};
            ext = [ext{:}];

            if strcmpi(ext, '.tab')

                tabfile = filename;
            elseif strcmpi(ext, '.xlsx')

                outfilename = filename{1};
                tabfile = strrep(outfilename, file, ['temp', file]);
                tabfile = strrep(tabfile, ext, '.tab');
                if exist(tabfile, 'file') == 2
                    delete(tabfile);
                end
                [~, ~, ~, tabfile] = convertEcoInsightXLS2tab( filename, ...
                    tabfile, true, imo);
            else
                errid = 'VesselDB:FileTypeUnrecognised';
                errmsg = ['Extension of file given by input FILENAME must be '...
                    'either ''xlsx'' or ''tab''.'];
                error(errid, errmsg);
            end

        else

            filename = [filename{:}];
            [~, file, ext] = fileparts(filename);
            if strcmpi(ext, '.tab')

                tabfile = filename;
            elseif strcmpi(ext, '.xlsx') 

                [p, f] = fileparts(filename);
                tabfile = ['temp', f, '.tab'];
                tabfile = fullfile(p, tabfile);
%                 tabfile = strrep(filename, file, ['temp', file]);
                tabfile = strrep(tabfile, ext, '.tab');
                if exist(tabfile, 'file') == 2
                    delete(tabfile);
                end
                [~, ~, ~, tabfile] = convertEcoInsightXLS2tab( filename, ...
                    tabfile, true, imo);
            else

                errid = 'VesselDB:FileTypeUnrecognised';
                errmsg = ['Extension of file given by input FILENAME must be '...
                    'either ''xlsx'' or ''tab''.'];
                error(errid, errmsg);
            end
        end
        
        % Load performance, speed files
        tempTab = 'tempDNVPer';
        permTab = 'PerformanceData';
        delimiter_ch = '\t';
        ignore_i = 1;
        
        % Load in tab file
        tabfile = validateCellStr(tabfile);
        for ti = 1:numel(tabfile)

            currTab = tabfile{ti};
            currTabid = fopen(currTab);
            currCols_cc = textscan(currTabid, '%s', 3);
            fclose(currTabid);
            currCols_c = [currCols_cc{:}];
            obj.SQL.loadInFileDuplicate(currTab, currCols_c, tempTab,...
                permTab, delimiter_ch, ignore_i);
        end

        % Delete tab file, unless requested
        if deleteTab_l

           cellfun(@delete, tabfile);
        end
        end

        function [obj, IMO, numWarnings, warnings] = loadDNVGLRaw(obj, filename)
        % loadDNVGLRaw Load raw data sourced from DNVGL
        
        % Input
        filename = validateCellStr(filename, 'cVessel.loadDNVGLRaw', ...
            'filename', 2);
        
        % Drop if exists
        tempTab = 'tempDNVGLRaw';
        obj = obj.drop('TABLE', tempTab, true);
        
        % Create temp table
        permTab = 'DNVGLRaw';
        obj = obj.createLike(tempTab, permTab);
        
        % Drop unique constraint, allowing for duplicates in temporary
        % loading table which will not carry through to final table
        dropCons_sql = ['ALTER TABLE `' tempTab '` DROP INDEX ' ...
            '`UniqueIMODates`'];
        execute(obj, dropCons_sql);
        
        % Load into temp table
        delimiter_s = ',';
        ignore_s = 1;
        set_s = ['SET Date_UTC = STR_TO_DATE(@Date_UTC, ''%d-%m-%Y''), ', ...
         'Time_UTC = STR_TO_DATE(@Time_UTC, ''%H:%i''), '];
        setnull_c = {'Date_UTC', 'Time_UTC'};
        cols_c = strsplit(['IMO_Vessel_Number;Date_UTC;Time_UTC;Date_Local;',...
            'Time_Local;Reporting_Time;Voyage_From;Voyage_To;ETA;RTA;',...
            'Reason_For_Schedule_Deviation;No_Of_Tugs;Voyage_Number;',...
            'Voyage_Type;Service;System_Condition;Travel_Condition;',...
            'Voyage_Stage;Voyage_Leg;Voyage_Leg_Type;Port_To_Port_Id;',...
            'Area_From;Area_To;Position;Latitude_Degree;Latitude_Minutes;',...
            'Latitude_North_South;Longitude_Degree;Longitude_Minutes;',...
            'Longitude_East_West;Wind_Dir;Wind_Dir_Degree;Wind_Force_Kn;',...
            'Wind_Force_Bft;Sea_state_Dir;Sea_state_Dir_Degree;',...
            'Sea_state_Force_Douglas;Period_Of_Wind_Waves;Swell_Dir;',...
            'Swell_Dir_Degree;Swell_Force;Period_Of_Primary_Swell_Waves;',...
            'Current_Dir;Current_Dir_Degree;Current_Speed;',...
            'Temperature_Ambient;Temperature_Water;Water_Depth;',...
            'Draft_Actual_Fore;Draft_Actual_Aft;Draft_Recommended_Fore;',...
            'Draft_Recommended_Aft;Draft_Ballast_Actual;',...
            'Draft_Ballast_Optimum;Draft_Displacement_Actual;Event;',...
            'Time_Since_Previous_Report;Time_Elapsed_Sailing;',...
            'Time_Elapsed_Maneuvering;Time_Elapsed_Waiting;',...
            'Time_Elapsed_Loading_Unloading;Distance;Distance_To_Go;',...
            'Average_Speed_GPS;Average_Speed_Through_Water;',...
            'Average_Propeller_Speed;Intended_Speed_Next_24Hrs;Nominal_Slip;',...
            'Apparent_Slip;Cargo_Mt;Cargo_Total_TEU;Cargo_Total_Full_TEU;',...
            'Cargo_Reefer_TEU;Reefer_20_Chilled;Reefer_40_Chilled;',...
            'Reefer_20_Frozen;Reefer_40_Frozen;Cargo_CEU;Crew;Passengers;',...
            'ME_Fuel_BDN;ME_Fuel_BDN_2;ME_Fuel_BDN_3;ME_Fuel_BDN_4;',...
            'ME_Consumption;ME_Consumption_BDN_2;ME_Consumption_BDN_3;',...
            'ME_Consumption_BDN_4;ME_Projected_Consumption;',...
            'ME_Cylinder_Oil_Consumption;ME_System_Oil_Consumption;',...
            'ME_1_Running_Hours;ME_1_Consumption;',...
            'ME_1_Cylinder_Oil_Consumption;ME_1_System_Oil_Consumption;',...
            'ME_1_Work;ME_1_Shaft_Gen_Work;ME_1_Shaft_Gen_Running_Hours;',...
            'ME_2_Running_Hours;ME_2_Consumption;',...
            'ME_2_Cylinder_Oil_Consumption;ME_2_System_Oil_Consumption;',...
            'ME_2_Work;ME_2_Shaft_Gen_Work;ME_2_Shaft_Gen_Running_Hours;',...
            'ME_3_Running_Hours;ME_3_Consumption;',...
            'ME_3_Cylinder_Oil_Consumption;ME_3_System_Oil_Consumption;',...
            'ME_3_Work;ME_3_Shaft_Gen_Work;ME_3_Shaft_Gen_Running_Hours;',...
            'ME_4_Running_Hours;ME_4_Consumption;',...
            'ME_4_Cylinder_Oil_Consumption;ME_4_System_Oil_Consumption;',...
            'ME_4_Work;ME_4_Shaft_Gen_Work;ME_4_Shaft_Gen_Running_Hours;',...
            'AE_Fuel_BDN;AE_Fuel_BDN_2;AE_Fuel_BDN_3;AE_Fuel_BDN_4;',...
            'AE_Consumption;AE_Consumption_BDN_2;AE_Consumption_BDN_3;',...
            'AE_Consumption_BDN_4;AE_Projected_Consumption;',...
            'AE_System_Oil_Consumption;AE_1_Running_Hours;',...
            'AE_1_Consumption;AE_1_System_Oil_Consumption;AE_1_Work;',...
            'AE_2_Running_Hours;AE_2_Consumption;',...
            'AE_2_System_Oil_Consumption;AE_2_Work;AE_3_Running_Hours;',...
            'AE_3_Consumption;AE_3_System_Oil_Consumption;AE_3_Work;',...
            'AE_4_Running_Hours;AE_4_Consumption;',...
            'AE_4_System_Oil_Consumption;AE_4_Work;AE_5_Running_Hours;',...
            'AE_5_Consumption;AE_5_System_Oil_Consumption;AE_5_Work;',...
            'AE_6_Running_Hours;AE_6_Consumption;',...
            'AE_6_System_Oil_Consumption;AE_6_Work;Boiler_Consumption;',...
            'Boiler_Consumption_BDN_2;Boiler_Consumption_BDN_3;',...
            'Boiler_Consumption_BDN_4;Boiler_1_Running_Hours;',...
            'Boiler_1_Consumption;Boiler_2_Running_Hours;',...
            'Boiler_2_Consumption;Air_Compr_1_Running_Time;',...
            'Air_Compr_2_Running_Time;Thruster_1_Running_Time;',...
            'Thruster_2_Running_Time;Thruster_3_Running_Time;',...
            'Fresh_Water_Bunkered;Fresh_Water_Consumption_Drinking;',...
            'Fresh_Water_Consumption_Technical;',...
            'Fresh_Water_Consumption_Washing;Fresh_Water_Produced;',...
            'Fresh_Water_ROB;Duration_Fresh_Water;Sludge_ROB;HFO_HS_ROB;',...
            'HFO_LS_ROB;MDO_MGO_HS_ROB;MDO_MGO_LS_ROB;ME_Cylinder_Oil_ROB;',...
            'ME_System_Oil_ROB;AE_System_Oil_ROB;Cleaning_Event;Mode;',...
            'Speed_GPS;Speed_Through_Water;',...
            'Speed_Projected_From_Charter_Party;Course;True_Heading;',...
            'ME_Barometric_Pressure;ME_Charge_Air_Coolant_Inlet_Temp;',...
            'ME_Air_Intake_Temp;ME_1_Load;ME_1_Speed_RPM;Prop_1_Pitch;',...
            'ME_1_Aux_Blower;ME_1_Shaft_Gen_Power;',...
            'ME_1_Charge_Air_Inlet_Temp;ME_1_Charge_Air_Pressure;',...
            'ME_1_Pressure_Drop_Over_Charge_Air_Cooler;ME_1_TC_Speed;',...
            'ME_1_Exh_Temp_Before_TC;ME_1_Exh_Temp_After_TC;',...
            'ME_1_Current_Consumption;ME_1_SFOC_ISO_Corrected;ME_1_SFOC;',...
            'ME_1_Pmax;ME_1_Pcomp;ME_2_Load;ME_2_Speed_RPM;Prop_2_Pitch;',...
            'ME_2_Aux_Blower;ME_2_Shaft_Gen_Power;',...
            'ME_2_Charge_Air_Inlet_Temp;ME_2_Charge_Air_Pressure;',...
            'ME_2_Pressure_Drop_Over_Charge_Air_Cooler;ME_2_TC_Speed;',...
            'ME_2_Exh_Temp_Before_TC;ME_2_Exh_Temp_After_TC;',...
            'ME_2_Current_Consumption;ME_2_SFOC_ISO_Corrected;ME_2_SFOC;',...
            'ME_2_Pmax;ME_2_Pcomp;ME_3_Load;ME_3_Speed_RPM;Prop_3_Pitch;',...
            'ME_3_Aux_Blower;ME_3_Shaft_Gen_Power;',...
            'ME_3_Charge_Air_Inlet_Temp;ME_3_Charge_Air_Pressure;',...
            'ME_3_Pressure_Drop_Over_Charge_Air_Cooler;ME_3_TC_Speed;',...
            'ME_3_Exh_Temp_Before_TC;ME_3_Exh_Temp_After_TC;',...
            'ME_3_Current_Consumption;ME_3_SFOC;ME_3_SFOC_ISO_Corrected;',...
            'ME_3_Pmax;ME_3_Pcomp;ME_4_Load;ME_4_Speed_RPM;Prop_4_Pitch;',...
            'ME_4_Aux_Blower;ME_4_Shaft_Gen_Power;',...
            'ME_4_Charge_Air_Inlet_Temp;ME_4_Charge_Air_Pressure;',...
            'ME_4_Pressure_Drop_Over_Charge_Air_Cooler;ME_4_TC_Speed;',...
            'ME_4_Exh_Temp_Before_TC;ME_4_Exh_Temp_After_TC;',...
            'ME_4_Current_Consumption;ME_4_SFOC;ME_4_SFOC_ISO_Corrected;',...
            'ME_4_Pmax;ME_4_Pcomp;AE_Barometric_Pressure;',...
            'AE_Charge_Air_Coolant_Inlet_Temp;AE_Air_Intake_Temp;',...
            'AE_1_Load;AE_1_Charge_Air_Inlet_Temp;AE_1_Charge_Air_Pressure;',...
            'AE_1_Pressure_Drop_Over_Charge_Air_Cooler;AE_1_TC_Speed;',...
            'AE_1_Exh_Temp_Before_TC;AE_1_Exh_Temp_After_TC;',...
            'AE_1_Current_Consumption;AE_1_SFOC_ISO_Corrected;AE_1_SFOC;',...
            'AE_1_Pmax;AE_1_Pcomp;AE_2_Load;AE_2_Charge_Air_Inlet_Temp;',...
            'AE_2_Charge_Air_Pressure;',...
            'AE_2_Pressure_Drop_Over_Charge_Air_Cooler;AE_2_TC_Speed;',...
            'AE_2_Exh_Temp_Before_TC;AE_2_Exh_Temp_After_TC;',...
            'AE_2_Current_Consumption;AE_2_SFOC_ISO_Corrected;AE_2_SFOC;',...
            'AE_2_Pmax;AE_2_Pcomp;AE_3_Load;AE_3_Charge_Air_Inlet_Temp;',...
            'AE_3_Charge_Air_Pressure;',...
            'AE_3_Pressure_Drop_Over_Charge_Air_Cooler;AE_3_TC_Speed;',...
            'AE_3_Exh_Temp_Before_TC;AE_3_Exh_Temp_After_TC;',...
            'AE_3_Current_Consumption;AE_3_SFOC_ISO_Corrected;AE_3_SFOC;',...
            'AE_3_Pmax;AE_3_Pcomp;AE_4_Load;AE_4_Charge_Air_Inlet_Temp;',...
            'AE_4_Charge_Air_Pressure;',...
            'AE_4_Pressure_Drop_Over_Charge_Air_Cooler;AE_4_TC_Speed;',...
            'AE_4_Exh_Temp_Before_TC;AE_4_Exh_Temp_After_TC;',...
            'AE_4_Current_Consumption;AE_4_SFOC_ISO_Corrected;AE_4_SFOC;',...
            'AE_4_Pmax;AE_4_Pcomp;AE_5_Load;AE_5_Charge_Air_Inlet_Temp;',...
            'AE_5_Charge_Air_Pressure;',...
            'AE_5_Pressure_Drop_Over_Charge_Air_Cooler;AE_5_TC_Speed;',...
            'AE_5_Exh_Temp_Before_TC;AE_5_Exh_Temp_After_TC;',...
            'AE_5_Current_Consumption;AE_5_SFOC_ISO_Corrected;AE_5_SFOC;',...
            'AE_5_Pmax;AE_5_Pcomp;AE_6_Load;AE_6_Charge_Air_Inlet_Temp;',...
            'AE_6_Charge_Air_Pressure;',...
            'AE_6_Pressure_Drop_Over_Charge_Air_Cooler;AE_6_TC_Speed;',...
            'AE_6_Exh_Temp_Before_TC;AE_6_Exh_Temp_After_TC;',...
            'AE_6_Current_Consumption;AE_6_SFOC_ISO_Corrected;AE_6_SFOC;',...
            'AE_6_Pmax;AE_6_Pcomp;Boiler_1_Operation_Mode;',...
            'Boiler_1_Feed_Water_Flow;Boiler_1_Steam_Pressure;',...
            'Boiler_2_Operation_Mode;Boiler_2_Feed_Water_Flow;',...
            'Boiler_2_Steam_Pressure;',...
            'Cooling_Water_System_SW_Pumps_In_Service;',...
            'Cooling_Water_System_SW_Inlet_Temp;',...
            'Cooling_Water_System_SW_Outlet_Temp;',...
            'Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger;',...
            'Cooling_Water_System_Pump_Pressure;',...
            'ER_Ventilation_Fans_In_Service;ER_Ventilation_Waste_Air_Temp;',...
            'Remarks;Entry_Made_By_1;Entry_Made_By_2'], ';');
        [~, setnull_ch] = obj.setNullIfEmpty(setdiff(cols_c, setnull_c), false);
        set_s = [set_s, setnull_ch];
        obj = obj.loadInFile(filename, tempTab, cols_c, ...
            delimiter_s, ignore_s, set_s, setnull_c);
		
	   % Get warnings from load infile statement
	   [obj, numWarnings] = obj.warnings;
	   [obj, warn_tbl] = obj.warnings(false, 0, 10);
	   warnings = warn_tbl;
        
        % Generate DateTime prior to using it for identification
        expr_sql = 'ADDTIME(Date_UTC, Time_UTC)';
        col = 'DateTime_UTC';
        obj = obj.update(tempTab, col, expr_sql);
        
        % Update insert into final table
        tab1 = tempTab;
        finalCols = [cols_c, {col}];
        cols1 = finalCols;
        tab2 = permTab;
        cols2 = finalCols;
        obj = obj.insertSelectDuplicate(tab1, cols1, tab2, cols2);
        
        % Get IMO contained in file
        filename = cellstr(filename);
        IMO = [];
        for fi = 1:numel(filename)

           filei = filename{fi};
           fid = fopen(filei);
           w = {};
           while fgetl(fid) ~= -1

               q = textscan(fid, '%[0123456789]', 'Headerlines', 1,...
                   'TreatAsEmpty', '');
               w = [w, q{1}];
           end

           IMO = [IMO, str2double(unique(w))];
        end
    
        % Insert into RawData table
        arrayfun(@(x) obj.call('insertFromDNVGLRawIntoRaw', num2str(x)), ...
            IMO, 'Uni', 0);
        
        % Drop temp
        obj = obj.drop('TABLE', tempTab);
        
        end

        function [obj, exc_st] = ISO19030(obj, varargin)
        % Process raw data for this vessel according to ISO19030 procedure 
        
        % Initalise outputs
        exc_st = struct('IMO_Vessel_Number', [], 'message', [],...
                        'identifier', [], 'stack', []);
        
        % Call SQL procedure, with filter inputs
        for oi = 1:numel(obj)
            
            imo = obj(oi).IMO_Vessel_Number;
            imo_ch = num2str(imo);
            
            try

                tic;
                
                % Call ISO
                obj(oi) = obj(oi).call('ISO19030A', imo_ch);
                
                % Check if displacement values needed
                [~, iso_tbl] = obj(oi).select('tempRawISO', 'Displacement');
                disp_v = iso_tbl.displacement;
                needDisplacement_l = all(isnan(disp_v));
                
                if needDisplacement_l
                    obj(oi) = obj(oi).updateDisplacement;
                end
                obj(oi) = obj(oi).call('ISO19030B', imo_ch);
                obj(oi) = obj(oi).updateWindResistanceRelative;
                obj(oi) = obj(oi).call('ISO19030C', imo_ch);
                
                % Copy ISO data into new temp table
                currTab = ['tempRawISO_', imo_ch];
                obj(oi) = obj(oi).drop('TABLE', currTab, true);
                obj(oi) = obj(oi).createLike(currTab, 'tempRawISO');
                obj(oi) = obj(oi).insertSelect('tempRawISO', '*', currTab, '*');

                % Update filters
                if nargin > 1

                    obj(oi) = obj(oi).updateFilters(varargin{:});
                end

                % Refresh performance data
                [obj(oi), tempISOTbl] = obj(oi).applyFilters(varargin{:});
                cols = {'DateTime_UTC', 'Speed_Loss'};
                props = {'DateTime_UTC', 'Speed_Index'};
                if isempty(tempISOTbl)
                    obj(oi).DateTime_UTC = [];
                    obj(oi).Performance_Index = [];
                    obj(oi).Speed_Index = [];
                else

                    obj(oi) = assignPerformanceData(obj(oi), tempISOTbl, props, cols);
                end
                
            catch ee
                
                exc_st(oi).IMO_Vessel_Number = imo;
                exc_st(oi).message = ee.message;
                exc_st(oi).identifier = ee.identifier;
                exc_st(oi).stack = ee.stack;
            end
            
            toc;
        end
        
        % Remove empty elements from exceptions structure
        empty_l = cellfun(@isempty, {exc_st.IMO_Vessel_Number});
        exc_st(empty_l) = [];
        end
        
        function [obj, exc_st] = ISO19030Analysis(obj, comment, varargin)
        % Update ISO19030 analysis with filter criteria and comment
        
        % Input
        comment = validateCellStr(comment, 'cVessel.ISO19030Analysis', 'comment', 2);
        comment = comment(:);
        params_c = [varargin{:}];
        nAdditionalArgin = numel(params_c);
        
        if nargin > 2
            
           allCell = all(cellfun(@iscell, varargin));
           if allCell && ~isequal(nAdditionalArgin, numel(obj))
            
               errid = 'cV:ISO:InputsSizeMismatchParams';
               errmsg = ['If a cell array of parameter, value inputs are'...
                   ' given, the number of cells must match the number of'...
                   ' OBJ'];
               error(errid, errmsg);
           end
           
           if ~allCell
               
               params_c = repmat({varargin}, numel(obj), 2);
           end
           
        else
            
            params_c = repmat({{}}, numel(comment), 1);
        end
        
        if (~isempty(comment) && ~isempty(params_c))...
                && ~isequal(numel(comment), numel(params_c))
            
            errid = 'cV:ISO:InputsSizeMismatchComment';
            errmsg = ['If multiple sets of name, value parameters are '...
                'input, their number must match that of cell array of '...
                'strings COMMENT'];
            error(errid, errmsg);
        end
        
        commentParams_c = cellfun(@(x, y) [x, y], comment, params_c, ...
            'Uni', 0);
        
        % Call SQL procedure, with filter inputs
        for oi = 1:numel(obj)
            
            % Current inputs
            currParams_c = params_c{oi, :};
            currCommentParams_c = commentParams_c{oi, :};
            
            % Perform analysis
            [obj(oi), exc_st] = obj(oi).ISO19030(currParams_c{:});
            
            % Insert into performance data table
            obj(oi) = obj(oi).insertIntoPerformanceData(currCommentParams_c{:});
        end
        
        end

        function obj = updatePerformanceTable(obj, newTable)
        % updatePerformanceTable Change value of PerformanceTable property
            
            % Error if input not member of accepted table names
            dataTables_c = {'DNVGLPerformanceData', 'PerformanceData', ...
               'ForcePerformanceData'};
            if ~ismember(newTable, dataTables_c)

                errid = 'cV:IncorrectPerformanceTable';
                errmsg = 'Performance table name must match one of those in DB';
                error(errid, errmsg);
            end
            
            % If name has changed, load performance data from new table
            oldTabl = obj.PerformanceTable;
            if ~isequal(oldTabl, newTable)
                
                % Assign table name
                [obj.PerformanceTable] = deal(newTable);
                
                % Get new dd, vessel data
                [imo, ddi] = currentIMODryDockIndex(obj);
                ddi_c = {ddi};
                newData = obj.performanceData(imo, ddi_c{:});

                % Resize array to fit new data
                obj = obj.fitToData(newData);

                % Assign data
                obj = obj.assignPerformanceData(newData);
            end
        end
        
        function [obj, rawTable] = rawData(obj, varargin)
        % rawData Get raw data for this vessel at this dry-docking interval
        
            cols = '*';
            if nargin > 1 && ~isempty(varargin{1})
                
                cols = varargin{1};
                cols = validateCellStr(cols);
            end
            
            start_l = false;
            if nargin > 2 && ~isempty(varargin{2})
                
                start_dt = varargin{2};
                startCondition_sql = ['DateTime_UTC >= ''',...
                    datestr(start_dt, 'yyyy-mm-dd HH:MM:SS''')];
                start_l = true;
            end
            
            end_l = false;
            if nargin > 3 && ~isempty(varargin{3})
                
                end_dt = varargin{3};
                endCondition_sql = ['DateTime_UTC <= ''',...
                    datestr(end_dt, 'yyyy-mm-dd HH:MM:SS''')];
                end_l = true;
            end
            
            for oi = 1:numel(obj)
                
                % Get dry dock interval dates
%                 [startDate, endDate, whereSQL] = obj(oi).DDIntervalDates();
                
                % Read from rawdata table with dates
                tab = 'RawData';
                where_sql = ['IMO_Vessel_Number = ', ...
                    num2str(obj(oi).IMO_Vessel_Number)];
                if start_l
                    [~, where_sql] = obj(oi).combineSQL(where_sql, 'AND', ...
                        startCondition_sql);
                end
                if end_l
                    [~, where_sql] = obj(oi).combineSQL(where_sql, 'AND', ...
                        endCondition_sql);
                end
                
                % Columns read out must include date time
                if ~isequal(cols, '*')
                    cols = union(cols, 'datetime_utc');
                end
                
                % Read data and convert to timetable
                [~, rawTable] = obj(oi).select(tab, cols, where_sql);
                rawTable.datetime_utc = datetime(rawTable.datetime_utc,...
                    'ConvertFrom', 'datenum');
                rawTable = table2timetable(rawTable, 'RowTimes', ...
                    'datetime_utc');
                
                % Remove variables which don't support empty values for
                % auto-filling
                rawVars = rawTable.Properties.VariableNames;
                if ismember('imo_vessel_number', rawVars)
                    
                    rawTable.imo_vessel_number = [];
                end
                if ismember('id', rawVars)
                    
                    rawTable.id = [];
                end
                
                % Get out performance data again, so table is re-created
%                 obj(oi) = obj(oi).performanceData(obj(oi).IMO_Vessel_Number);
                
                if isempty(obj(oi).InService)
                    
                    obj(oi).InService = rawTable;
                else
                    
                    % Synchronise raw table with InService data
                    obj(oi).InService = synchronize(obj(oi).InService, rawTable);
                end
            end
        end
    end
    
    methods(Static, Hidden)
        
        function varargout = repeatInputs(inputs)
        % repeatInputs Repeat any scalar inputs to match others' size
        % [A, B, ...] = repeatInputs(inputs) will return in A, B... vectors
        % of size equal to the size of any non-scalar in INPUTS, i.e. any
        % scalars in INPUTS will be repeated to match the size of the
        % non-scalars and returned in A, B... There can be multiple scalars
        % and non-scalars but all non-scalars must be the same size. 
        % If any of INPUTS are strings, they will be treated as scalars.
        
        % Check that all inputs are the same size or are scalar
        scalars_l = cellfun(@(x) isscalar(x) || ischar(x), inputs);
        empty_l = cellfun(@isempty, inputs);
        emptyOrScalar_l = scalars_l | empty_l;
        allSizes_c = cellfun(@size, inputs(~emptyOrScalar_l), 'Uni', 0);
        
        if ~isempty(allSizes_c)
        
            szMat_c = allSizes_c(1);
            chkSize_c = repmat(szMat_c, size(allSizes_c));
            if ~isequal(allSizes_c, chkSize_c)
               errid = 'DBTab:SizesMustMatch';
               errmsg = ['All inputs must be the same size, or any can '...
                   'be scalar'];
               error(errid, errmsg);
            end

            % Repeat scalars
            inputs(scalars_l) = cellfun(@(x) repmat(x, chkSize_c{1}),...
                inputs(scalars_l), 'Uni', 0);
        end
        
        % Assign outputs
        varargout = inputs;
        
        end
        
        function [valid, errmsg] = validateFileExists(filename, varargin)
        % validateFile Check whether file exists or not.
        
        % Output
        valid = false;
        
        % Input
        validateattributes(filename, {'char'}, {'vector'}, 'validateFile',...
            'filename', 1);
        
        existCriteria = true;
        if nargin > 1
            
            existCriteria = varargin{1};
            validateattributes(existCriteria, {'logical'}, {'scalar'},...
                'validateFile', 'existCriteria', 2);
        end
        
        % Create error message in case either criteria fail
        if existCriteria
            errmsg = ['Input file ' filename ' must exist.'];
        else
            errmsg = ['Input file ' filename ' must not exist.'];
        end
        
        % Check if file exists
        fileExists = (exist(filename, 'file') == 2);
        
        % Assign output based on criteria matching file state
        if existCriteria == fileExists
           valid = true;
        end
        
        end
        
    end
    
    methods(Hidden)
       
       function skip = isPerDataEmpty(obj)
       % isPerDataEmpty True if performance data variable empty or NAN.
       
           vars = {obj.Variable};
           skip = arrayfun(@(x, y) isempty(x.InService.(y{:})) || ...
                all(isnan(x.InService.(y{:}))), obj, vars);
       end
       
        function obj = updateWindResistanceRelative(obj)
        % 
        
        % Get Variables
        tab = 'tempRawISO';
        cols_c = {'IMO_Vessel_Number', 'DateTime_UTC', 'Air_Density', ...
            'Transverse_Projected_Area_Current',...
            'Relative_Wind_Speed_Reference',...
            'Relative_Wind_Direction_Reference'};
        [~, iso_tbl] = obj.select(tab, cols_c);
        
        % Find nearest coefficient
        currIMO = iso_tbl.imo_vessel_number(1);
        windCols_c = {'Direction', 'Coefficient'};
        whereModel_sql = ['ModelID = (SELECT Wind_Model_ID FROM Vessels '...
            'WHERE IMO_Vessel_Number = ', num2str(currIMO), ')'];
        windTab = 'windcoefficientdirection';
        [~, wind_tbl] = obj.select(windTab, windCols_c, whereModel_sql);
        if isempty(wind_tbl)
            return
        end
        reldir = iso_tbl.relative_wind_direction_reference;
        dir = wind_tbl.direction;
        coeffs = wind_tbl.coefficient;
        [~, coeffi] = FindNearestInVector(reldir, dir);
        coeff = coeffs(coeffi);
        
        % Find resistance
        rho = iso_tbl.air_density;
        At = iso_tbl.transverse_projected_area_current;
        relspeed = iso_tbl.relative_wind_speed_reference;
        res = 0.5 .* rho .* At .* coeff .* relspeed.^2;
        
        % Insert update resistance
        resCol = {'IMO_Vessel_Number', 'DateTime_UTC', ...
            'Wind_Resistance_Relative'};
        midnights_l = cellfun(@(x) length(x) == 10, iso_tbl.timestamp);
        sqldates_c = iso_tbl.timestamp;
        sqldates_c(midnights_l) = cellfun(@(x) [x, ' 00:00:00'], ...
            iso_tbl.timestamp(midnights_l), 'Uni', 0);
        
        sqldates_ch = datestr(datenum(sqldates_c, obj(1).DateFormStr),...'dd-mm-yyyy HH:MM:SS'),...
            'yyyy-mm-dd HH:MM');
        sqldates_c = cellstr(sqldates_ch);
        resData_c = [num2cell(iso_tbl.imo_vessel_number),...
            sqldates_c, num2cell(res)];
        
       % Create temp file and load, if data too big
       if size(resData_c, 1) > 5e4
          
           tempFile = fullfile(cd, 'tempWindRes.csv');
           try
           
               tempTab = cell2table(resData_c);
               nan_l = isnan(tempTab.resData_c3);
               tempTab.resData_c3 = num2cell(tempTab.resData_c3);
               tempTab.resData_c3(nan_l) = {'NULL'};
               tempTabName = 'tempTempRawISO';
               obj = obj.drop('TABLE', tempTabName, true);
               obj.createLike('tempTempRawISO', 'tempRawISO');
               writetable(tempTab, tempFile, 'WriteVariableNames', false);
           
           catch ee
               
               delete(tempFile);
               rethrow(ee);
           end
           
           obj.loadInFileDuplicate(tempFile, resCol, tempTabName, 'tempRawISO');
           delete(tempFile);
           
       else
       
           obj.insertValuesDuplicate(tab, resCol, resData_c);
       end
       end
        
        function obj = assignPerformanceData(obj, dataStruct, varargin)
        % assignPerformanceData Assign from struct or table to obj
        
        % Input
        propName = lower({'DateTime_UTC',...
                    'Speed_Index',...
                    'Performance_Index',...
                    'DryDockInterval'
                    });
        if nargin > 2
            
            propName = varargin{1};
            propName = validateCellStr(propName, ...
                'cVessel.assignPerformanceData', 'propName', 3);
        end
        
        dataName = propName;
        if nargin > 3
            
            alias = varargin{2};
            validateCellStr(alias, 'cVessel.assignPerformanceData', ...
                'alias', 4);
            dataName = alias;
        end
        
        % Iterate objects and assign to properties
        for oi = 1:numel(obj)
            for pi = 1:numel(propName)

                obj(oi).(propName{pi}) = dataStruct.(lower(dataName{pi}));
            end
        end
        end
        
        function obj = filterOnUniqueIndex(obj, index, ~)
        % filterOnUniqueIndex Filter data based on duplicate keys.
        
        % Input
        validateattributes(index, {'char'}, {'vector'}, ...
            'filterOnUniqueIndex', 'index', 2);
        
        % Iterate and filter non-unique indices of index data
        for ii = 1:numel(obj)
            
            [~, uniIndexI] = unique(obj(ii).InService.(index));
            obj(ii).InService = obj(ii).InService(uniIndexI, :);
        end
        end

        function mat = DDIntervalsFromDates(obj)
        % DDIntervalsFromDates Logical matrix giving dry-docking intervals
        
        for oi = 1:numel(obj)
            
            % Check whether dry-dock data given, pre-allocate arrays
%             nDDi = obj(oi).numDDIntervals; % numel(obj(oi).DryDock) + 1;
            nDDi = numel(obj(oi).DryDock) + 1;
            if isempty(obj(oi).DryDock)
                mat = true(numel(obj(oi).InService.timestamp), 1);
                continue
            end
            mat = false(numel(obj(oi).InService.timestamp), nDDi);
            currDates = obj(oi).InService.timestamp;
            
            for di = 1:nDDi
                
                % Create logical vectors for current interval from index
                if di == 1
                    
                    currIntEnd = datetime(...
                        obj(oi).DryDock(di).StartDateNum,...
                        'ConvertFrom', 'datenum');
                    currInt_l = currDates <= currIntEnd;
                    
                elseif di == nDDi
                    
                    currIntEnd = datetime(...
                        obj(oi).DryDock(di-1).EndDateNum,...
                        'ConvertFrom', 'datenum');
                    currInt_l = currDates >= currIntEnd;
                    
                else
                    
                    currIntStart = datetime(...
                        obj(oi).DryDock(di - 1).EndDateNum,...
                        'ConvertFrom', 'datenum');
                    currIntEnd = datetime(...
                        obj(oi).DryDock(di).StartDateNum,...
                        'ConvertFrom', 'datenum');
                    currInt_l = currDates >= currIntStart & ...
                        currDates <= currIntEnd;
                end
                
                % Assign values for current interval to true
                mat(currInt_l, di) = true;
            end
        end
        end
        
        function iter = iterateDD(obj)
        % iterateDD Return for current dry docking interval while iterating
           
           % Don't iterate if no data given
           noData_l = arrayfun(@(x) isempty(x.InService), obj);
           if all(noData_l(:))
               
               iter = false;
               return
           end
        
           % Get current iteration
           currIdx = obj(1).DDIterator;
           currDDi = currIdx(3);
           currVessel = currIdx(2);
           
           iterFinished = currVessel == numel(obj) && ...
               currDDi == obj(currVessel).numDDIntervals;
           iter = ~iterFinished;
           if iterFinished
               
               obj.resetIteratorDD();
           end
        end
        
        function obj = incrementIteratorDD(obj)
        % 
        
           currIdx = obj(1).DDIterator;
           currDDI = currIdx(1);
           currVessel = currIdx(2);
           nextDDINonEmpty_i = currIdx(3);
           
           % Check for data in next DD interval
           DDI_m = obj(currVessel).DDIntervalsFromDates;
           nonEmptyDDI_l = any(DDI_m);
           nonEmptyDD_i = find(nonEmptyDDI_l);
           nextDDI_i = currDDI + 1;
           
           q = zeros(1, length(nonEmptyDDI_l));
           q(nonEmptyDDI_l) = find(nonEmptyDDI_l);
           nextDDI_i = find(q >= nextDDI_i, 1, 'first');
           
           nextDDIEmpty_l = ~nonEmptyDDI_l(nextDDI_i);
           remainingAreEmpty_l = ~any(nonEmptyDDI_l(nextDDI_i:end));
           nextVessel_l = isempty(nextDDI_i) ||...
               nextDDI_i > length(nonEmptyDDI_l) || remainingAreEmpty_l;
           nextVessel = currVessel;
           
           % If the next DD interval has no corresponding data
           if nextVessel_l
               
               % Continue looking for data in next vessels
               nextVessel = currVessel + 1;
               nextDDINonEmpty_i = 0;
               dataFound_l = false;
               while nextVessel <= numel(obj)
                   
                   % Check for data as before
                   DDI_m = obj(nextVessel).DDIntervalsFromDates;
                   nonEmptyDDI_l = any(DDI_m);
                   nextDDI_i = find(nonEmptyDDI_l, 1, 'first');
                   if ~isempty(nextDDI_i)
                       dataFound_l = true;
                       break
                   end
               end
               
               % If no DD intervals remain with data, end iteration
               if ~dataFound_l
                   
                   nextVessel = numel(obj);
                   nextDDI_i = obj(currVessel).numDDIntervals;
               end
           end
           nextDDIEmpty_i = nextDDI_i(1);
           nextDDINonEmpty_i = nextDDINonEmpty_i + 1;
           currIdx = [nextDDIEmpty_i, nextVessel, nextDDINonEmpty_i];
           
           % Assign
           [obj.DDIterator] = deal(currIdx);
        end
        
        function obj = resetIteratorDD(obj)
            
            startIdx = [0, 1, 0];
            [obj.DDIterator] = deal(startIdx);
        end
        
        function [tbl, objDD, ddi, vi] = currentDD(obj)
           
           % Iterate
           obj.incrementIteratorDD;
           
           % Assuming that array is non-empty, iterators can be taken from
           % first element
           refIndex = 1;
           
           % Get current iterators
           ddiNonEmpty_i = obj(refIndex).DDIterator(1);
           vi = obj(refIndex).DDIterator(2);
           ddi = obj(refIndex).DDIterator(3);
           
           % Get corresponding logical array
           objDD = obj(vi);
           DDI_l = objDD.DDIntervalsFromDates;
           data_l = DDI_l(:, ddiNonEmpty_i);
           
           % Temp code: build table from current data properties
           tbl = objDD.InService(data_l, :);
           tbl = timetable2table(tbl);
           tbl.timestamp = datenum(tbl.timestamp);
        end
        
        function obj = assignDefaults(obj, varargin)
            
            % Iterate and assign
            for oi = 1:numel(obj)
                
                obj(oi).DryDock = cVesselDryDock(varargin{:});
                obj(oi).Configuration = cVesselConfiguration(varargin{:});
                obj(oi).SpeedPower = cVesselSpeedPower(varargin{:});
                obj(oi).Report = cVesselReport(varargin{:});
                obj(oi).WindCoefficient = cVesselWindCoefficient(varargin{:});
                obj(oi).Displacement = cVesselDisplacement(varargin{:});
                obj(oi).Engine = cVesselEngine(varargin{:});
                obj(oi).Owner = cVesselOwner(varargin{:});
                obj(oi).Info = cVesselInfo(varargin{:});
            end
        end
        
        function [obj, vid] = vessel_Id(obj, imo)
        % vessel_Id DB identifier for vessel, increment if necessary
            
            imo_ch = num2str(imo);
            [~, vid_tbl] = obj.SQL.select('Vessel', '*', ...
                ['IMO = ', imo_ch], 1);
            
            % Vessel not found in DB
            if isempty(vid_tbl)
                vid = []; 
            else
                vid = vid_tbl.vessel_id;
            end
        end
    end
    
    methods(Static)
        
        [trading_tbl, idleDD_tbl, idleQuart_tbl, speed_tbl] = ...
            activityFromVesselTrackerXLSX(filename, dd, varargin);
    end
    
    methods
        
       function obj = set.Database(obj, dbname)
        % Change database of object and all nested objects
        
        % Change DB connection for object and nested objects
        ddSQL = [obj.DryDock];
        dbname_c = repmat({dbname}, 1, numel(ddSQL));
        [ddSQL.SavedConnection] = dbname_c{:};
        spSQL = [obj.SpeedPower];
        dbname_c = repmat({dbname}, 1, numel(spSQL));
        [spSQL.SavedConnection] = dbname_c{:};
        
        obj.Configuration.SavedConnection = dbname;
        obj.WindCoefficient.SavedConnection = dbname;
        obj.Displacement.SavedConnection = dbname;
        obj.Engine.SavedConnection = dbname;
        obj.Owner.SavedConnection = dbname;
        
        obj.SavedConnection = dbname;
       end
        
       function obj = set.IMO(obj, IMO)
           
           if ~obj.Sync
               
               return
           end
           
           if ~isempty(IMO(~isnan(IMO)))
                validateattributes(IMO, {'numeric'}, ...
                    {'scalar', 'positive', 'real', 'nonnan', 'integer'});
                return_l = false;
           else
                validateattributes(IMO, {'numeric'}, {});
                IMO = [];
                return_l = true;
           end
           obj.IMO = IMO;
           
           if return_l
               
               return
           end
           
           % Get Vessel_Id for given IMO
           [~, vid] = obj.vessel_Id(IMO);
           obj.Model_ID = vid;
           obj.Vessel_Id = vid;
           
           % Get connection data for this object
           [~, connInput_c] = obj.SQL.connectionData();
           
           % Read DD
           if ~isempty(vid)
               
               ddd = obj.DryDock;
               tab = ddd.DBTable;
               field = ddd.TableIdentifier;
               alias_c = ddd.propertyAlias;
               expand_l = true;
               ddd = ddd.select(tab, field, [], alias_c,...
                   [], expand_l, 'Vessel_Id', vid);
               obj.DryDock = ddd;
           end
           
           % Read Owner
           if ~isempty(vid)
               
               tab = 'VesselToVesselOwner';
               field = {'Vessel_Owner_Id'};
               owner = obj.Owner;
               alias_c = owner.propertyAlias;
               expand_l = true;
               obj.select(tab, field, [], alias_c, {owner}, expand_l, 'Vessel_Id', vid);

               tab = 'VesselOwner';
               field = {'Vessel_Owner_Id'};
               obj.select(tab, field, owner.Model_ID, alias_c, {owner});
           end
           
           % Read SpeedPower
           config = obj.Configuration;
           spmID = config.Speed_Power_Coefficient_Model_Id;
           sp = [obj.SpeedPower];
           if ~isempty(spmID)
               
               % Assign super-model ID to obj and select using that
               currSPSQL = sp.SQL;
               sp = cVesselSpeedPower(connInput_c{:});
               sp.SQL = currSPSQL;
               sp.Speed_Power_Coefficient_Model_Id = spmID;
               [sp.Sync] = deal(false);
               sp = sp.select();

               [sp.Sync] = deal(true);
               obj.SpeedPower = sp;
           end
           
           % Read Displacement
           dispID = config.Displacement_Model_Id;
           obj.Displacement.Model_ID = dispID;
           
           % Read Engine
           engID = config.Engine_Model_Id;
           obj.Engine.Model_ID = engID;
           
           % Read Wind
           windID = config.Wind_Coefficient_Model_Id;
           obj.WindCoefficient.Model_ID = windID;
           
           % In-service
           obj = obj.selectInService;
       end
       
       function obj = set.SpeedPower(obj, sp)
           
           % Input
           validateattributes(sp, {'cVesselSpeedPower'}, {});
       
           obj.SpeedPower = sp;
           
           % Apply connection across array, if array was expanded from default
           obj.SpeedPower.copySQLToArray;
       end

       function obj = set.Variable(obj, variable)
       % Set property method for Variable
           
           obj.checkVarname( variable );
           obj.Variable = variable;
       end
       
       function obj = set.WindCoefficient(obj, wc)
           
           validateattributes(wc, {'cVesselWindCoefficient'}, {'scalar'});
           obj.Configuration.Wind_Coefficient_Model_Id = wc.Model_ID;
           obj.WindCoefficient = wc;
       end
       
       function model = get.Engine_Model(obj)
       % Get method for dependent property Engine_Model
          
          model = '';
          if ~isempty(obj.Engine)
              
              model = obj.Engine.Name;
          end
       end
       
       function windRefHeight = get.Wind_Reference_Height_Design(obj)
           
           windRefHeight = [];
           if ~isempty(obj.WindCoefficient)
               
               windRefHeight = obj.WindCoefficient.Wind_Reference_Height_Design;
           end
       end
       
       function obj = set.DryDock(obj, ddd)
       % 
       
       % Input
       validateattributes(ddd, {'cVesselDryDock'}, {});
       
       % Assign object
       obj.DryDock = ddd;
       
       % Apply connection across array, if array was expanded from default
       obj.DryDock.copySQLToArray;
       
       end
       
       function obj = set.Displacement(obj, disp)
       % Displacement
       
           validateattributes(disp, {'cVesselDisplacement'}, {'scalar'},...
               'cVessel.set.Displacement', 'Displacement');
           obj.Displacement = disp;
       end
        
        function obj = set.DDIntervals(obj, ~)
        % Set method for DDIntervals prevents user assigning to it
        
        end
        
        function ddi = get.DDIntervals(obj)
        % Get method for DDIntervals returns matrix based on data, DD
            
            ddi = obj.DDIntervalsFromDates;
        end
                
        function obj = set.numDDIntervals(obj, ~)
        % Set method for numDDIntervals prevents user assigning to it
        
        end
        
        function ndd = get.numDDIntervals(obj)
        % Get method for DDIntervals returns matrix based on data, DD
        
        if isempty(obj.DryDock)
            
            ndd = 1;
        else
            
            mat = obj.DDIntervalsFromDates;
            ndd = sum(any(mat));
        end
        
        end
        
        function obj = set.DDIterator(obj, di)
            
            validateattributes(di, {'numeric'}, {'integer', '>=', 0, ...
                'size', [1, 3]});
            obj.DDIterator = di;
        end
        
        function obj = set.Configuration(obj, config)
           
           % Validate
           validateattributes(config, {'cVesselConfiguration'}, {});
           
           % Get most recent config and assign
           recent_l = config.currentConfig;
           obj.Configuration = config(recent_l);
           obj.PreviousConfiguration = config(~recent_l);
        end
        
        function obj = set.PreviousConfiguration(obj, config)
            
           % Validate
           validateattributes(config, {'cVesselConfiguration'}, {});
           
           % Assign
           obj.PreviousConfiguration = config;
        end
        
        function obj = set.InService(obj, ins)
            
            if isempty(ins)
                
                ins = timetable();
                obj.InService = ins;
                return
            end
            
            if isa(ins, 'table')
                
                % If all timestamps are midnight, times are omitted
                length_v = cellfun(@length, ins.timestamp);
                dateformstr = obj.DateFormStr;
                if all(length_v == 10)
                    
                    dateformstr = obj.DateFormStr(1:10);
                end
                
                ins.timestamp = datetime(ins.timestamp,'InputFormat',...
                    dateformstr);
                
%                 ins.timestamp = datetime(ins.timestamp, 'ConvertFrom', 'datenum');
                ins = table2timetable(ins, 'RowTimes', 'timestamp');
            end
            
            validateattributes(ins, {'timetable'}, {});
            ins = sortrows(ins);
            obj.InService = ins;
        end
        
        function str = get.DateFormStr(obj)
            
            switch class(obj.SQL)
                
                case 'cTSQL'
                    
                    str = 'yyyy-MM-dd HH:mm:ss.SSSSSSS';
                    
                case 'cMySQL'
                    
                    str = 'dd-MM-yyyy HH:mm:ss';
            end
        end
    end
end