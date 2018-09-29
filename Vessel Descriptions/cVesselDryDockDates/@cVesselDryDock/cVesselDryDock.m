classdef cVesselDryDock < cModelID & cDateConvert
    %CVESSELDRYDOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Start_Date
        End_Date
        Vertical_Bottom_Surface_Prep
        Vertical_Bottom_Coating
        Flat_Bottom_Surface_Prep
        Flat_Bottom_Coating
        Bot_Top_Surface_Prep
        Bot_Top_Coating
        Average_Speed_Expected
        Activity_Expected
        Longest_Idle_Period_Expected
    end
    
    properties(Hidden, Constant)
        
        DBTable = 'DryDock';
        DataProperty = {'Start_Date',...
                        'End_Date',...
                        'Vertical_Bottom_Surface_Prep',...
                        'Vertical_Bottom_Coating',...
                        'Flat_Bottom_Surface_Prep',...
                        'Flat_Bottom_Coating',...
                        'Bot_Top_Surface_Prep',...
                        'Bot_Top_Coating',...
                        'Average_Speed_Expected',...
                        'Activity_Expected',...
                        'Longest_Idle_Period_Expected',...
                        'Model_ID',...
                        'Vessel_Id',...
                        'Name',...
                        'Description',...
                        'Deleted'};
        TableIdentifier = 'Dry_Dock_Id';
        ObjectIdentifier = 'Dry_Dock_Id';
        OtherTableIdentifier = {};
        OtherTable = {};
        ModelTable = 'DryDock';
        ValueTable = {};
        ModelField = {'Dry_Dock_Id'};
        ValueObject = {};
        StartDateProp = 'Start_Date';
        EndDateProp = 'End_Date';
        NameAlias = '';
        EmptyIgnore = {'Deleted'};
    end
    
    properties(Hidden)
        
        Vessel_Id = [];
        Dry_Dock_Id = [];
    end
    
    methods
       
       function obj = cVesselDryDock(varargin)
    
           obj = obj@cModelID(varargin{:});
           [obj.Last_Update_Id] = deal(true(size(obj)));
       end
       
       function obj = readFile(obj, filename, dateform)
        % readFile Assign dry dock dates from file to obj
        
        % Inputs
        validateattributes(filename, {'char'}, {'vector'}, 'readFile',...
            'filename', 2);
        validateattributes(dateform, {'char'}, {'vector'}, 'readFile',...
            'dateform', 3);
        
        % Verify file contents, headings
        
        
        % Read table from file
        file_t = readtable(filename);
        
        % Expand obj array if required
        numRows = size(file_t, 1);
        if ~isscalar(obj) && ~isequal(numRows, numel(obj))
            
            errid = 'cDDD:ObjFileSizeMismatch';
            errmsg = ['File contains more rows than there are objects in '...
                'the array. OBJ can be scalar, and will be expanded to the'...
                ' number of rows in the file, or it can be an array with the'...
                ' same number of elements as rows in the file.'];
            error(errid, errmsg);
        end
        
        expand_l = isscalar(obj) && numRows > 1;
        if expand_l
            
            newEmptyObj_v(1, numRows - 1) = cVesselDryDockDates();
            obj = [obj, newEmptyObj_v];
        end
        
        % Relate file headings to object props
        propHeads_c = {...
            'StartDateNum', 'StartDate'; ....
            'EndDateNum', 'EndDate'; ...
            'Vertical_Bottom_Surface_Prep', 'VerticalBottomSurfacePrep'; ...
            'Vertical_Bottom_Coating', 'VerticalBottomCoating'; ...
            'Flat_Bottom_Surface_Prep', 'FlatBottomSurfacePrep'; ...
            'Flat_Bottom_Coating', 'FlatBottomCoating' ...
            };
        fileVar_c = file_t.Properties.VariableNames;
        propsInFile_l = ismember(propHeads_c(:, 2), fileVar_c);
        vars2read_c = propHeads_c(propsInFile_l, 1);
        [~, fileVarIdx_v] = ismember(propHeads_c(propsInFile_l, 2), fileVar_c);
        
        isDateVar_f = @(var) ismember(var, {'StartDate', 'EndDate'});
        
        % Assing into obj
        for oi = 1:numel(obj)
            
            obj(oi).IMO_Vessel_Number = file_t.IMO_Vessel_Number(oi);
            
            % Update for MATLAB 2017a, where file read with datetime objs
            for vi = 1:numel(fileVarIdx_v)
                
                currProp = vars2read_c{vi};
                currFileVar_i = fileVarIdx_v(vi);
                currFileVar = fileVar_c(currFileVar_i);
                
                if isDateVar_f(currFileVar)
                    
                    obj(oi).(currProp) = datenum(file_t{oi, currFileVar_i});
                else
                    
                    obj(oi).(currProp) = file_t{oi, currFileVar_i};
                end
            end
        end
        
       end
       
       function obj = readDatesFromIndex(obj, intervalI)
       % readDatesFromIndex Read from DB dry-docking dates from interval
       % obj = readDatesFromIndex(obj, intervalI) will return in the
       % properties 'StartDate' and 'EndDate' of OBJ the corresponding
       % dates of the dry-docking at the start of the interval whose index 
       % is given by numeric scalar INTERVALI for the vessel given by 
       % property 'IMO_Vessel_Number'. 
       %
       % Example: obj = readDatesFromIndex(obj, 2)
       %        Returns in OBJ the start and end dates of the first
       %        dry-docking for the vessel given by obj.IMO_Vessel_Number,
       %        i.e. the dates of the dry-docking at the start of the
       %        second dry-docking interval.
       
       % Errors
       if (~isscalar(obj) && ~isscalar(intervalI)) &&...
               ~isequal(numel(obj), numel(intervalI))
           
           errid = 'cVDD:DryDockVesselMismatch';
           errmsg = ['If neither OBJ nor INTERVALI are scalar, both must '...
               'have the same number of elements.'];
           error(errid, errmsg);
       end
       
       if isscalar(obj) && ~isscalar(intervalI)
           
           obj = repmat(obj, size(intervalI));
       end
       
       if ~isscalar(obj) && isscalar(intervalI)
           
           intervalI = repmat(intervalI, size(obj));
       end
       
       % Inputs
       validateattributes(intervalI, {'numeric'}, {}, ...
           'cVesselDryDockDates.readDatesFromIndex', 'intervalI', 2);
       
       for oi = 1:numel(obj)
       
           % Genreate SQL
           ddi_sql = ['SELECT StartDate, EndDate from DRYDOCKDATES WHERE '...
               'IMO_Vessel_Number = ', num2str(obj(oi).IMO_Vessel_Number), ...
               ' LIMIT ', num2str(intervalI(oi)) - 1, ', 1'];

           % Execute
           [~, cl] = obj(1).executeIfOneOutput(1, ddi_sql);
           
           % Skip if no input found
           if isempty(cl)
               continue
           end

           % Assign
           currDateForm = obj(oi).DateStrFormat;
           obj(oi).DateStrFormat = 'dd-mm-yyyy';
           obj(oi).StartDate = cl{1};
           obj(oi).EndDate = cl{2};
           obj(oi).DateStrFormat = currDateForm;
       end
       end
    end
    
    methods(Hidden, Static, Access=private)
        
        function ch = oneCellToString(c)
            
            if isequal(c, {''})
                ch = '';
                return
            end
            
            if ischar(c) && isrow(c)
                ch = c;
                return
            end
            
            % Allow for NaN (NULL) values
            isScalarNanCell_l = iscell(c) && isscalar(c) && ...
                isscalar([c{:}]) && isnan([c{:}]);
            if (isnumeric(c) && (isempty(c) || isnan(c)) || isScalarNanCell_l)
                ch = nan;
                return
            end
            
            validateattributes(c, {'cell'}, {'scalar'});
            ch = [c{:}];
            validateattributes(ch, {'char'}, {'vector', 'row'});
        end
        
        function str = removeQuestionMarks(str)
        % removeQuestionMarks Fix bizarre MATLAB error where '?' prepended
        
            str(str == '?') = [];
        end
    end
    
    methods
        
        function obj = set.Vertical_Bottom_Surface_Prep(obj, val)
            
            val = obj.oneCellToString(val);
            obj.Vertical_Bottom_Surface_Prep = val;
        end
        
        function obj = set.Vertical_Bottom_Coating(obj, val)
            
            val = obj.oneCellToString(val);
            obj.Vertical_Bottom_Coating = val;
        end
        
        function obj = set.Flat_Bottom_Surface_Prep(obj, val)
            
            val = obj.oneCellToString(val);
            obj.Flat_Bottom_Surface_Prep = val;
        end
        
        function obj = set.Flat_Bottom_Coating(obj, val)
            
            val = obj.oneCellToString(val);
            obj.Flat_Bottom_Coating = val;
        end
        
        function obj = set.Start_Date(obj, start)
            
            start = obj.removeQuestionMarks(start);
            obj.Valid_From = start;
        end
        
        function start = get.Start_Date(obj)
            
            start = obj.Valid_From;
        end
        
        function obj = set.End_Date(obj, endd)
            
            endd = obj.removeQuestionMarks(endd);
            obj.Valid_To = endd;
        end
        
        function endd = get.End_Date(obj)
            
            endd = obj.Valid_To;
        end
    end
end