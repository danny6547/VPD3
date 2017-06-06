classdef cVesselDryDockDates < cMySQL
    %CVESSELDRYDOCKDATES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number = [];
    end
    
    properties(Dependent)
        
        StartDate char = '';
        EndDate char = '';
    end
    
    properties
        
        DateStrFormat char = 'yyyy-mm-dd';
    end
    
    properties(Hidden)
        
        StartDateNum = [];
        EndDateNum = [];
    end
    
    methods
    
       function obj = cVesselDryDockDates()
    
       end
       
       function obj = assignDates(obj, startdate, enddate, varargin)
           
           for oi = 1:numel(obj)
                
                dateform = obj(oi).DateStrFormat;
                if nargin > 3
                    dateform = varargin{1};
                end

                obj(oi).StartDateNum = obj(oi).setDate(startdate, dateform);
                obj(oi).EndDateNum = obj(oi).setDate(enddate, dateform);
           end
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
                'number of rows in the file, or it can be an array with the'...
                'same number of elements as rows in the file.'];
            error(errid, errmsg);
        end
        
        expand_l = isscalar(obj) && numRows > 1;
        if expand_l
            
            newEmptyObj_v = repmat(cVesselDryDockDates(), [1, numRows - 1]);
            obj = [obj, newEmptyObj_v];
        end
        
        % Assing into obj
        for oi = 1:numel(obj)
            
            obj(oi).IMO_Vessel_Number = file_t.IMO_Vessel_Number(oi);
            obj(oi).StartDateNum = datenum(file_t.StartDate(oi), dateform);
            obj(oi).EndDateNum = datenum(file_t.EndDate(oi), dateform);
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

           % Assign
           currDateForm = obj(oi).DateStrFormat;
           obj(oi).DateStrFormat = 'dd-mm-yyyy';
           obj(oi).StartDate = cl{1};
           obj(oi).EndDate = cl{2};
           obj(oi).DateStrFormat = currDateForm;
       end
       end
    end
    
    methods(Hidden)
        
        function empty = isempty(obj) 
            
            if any(size(obj) == 0)
                empty = true;
                return
            end
            
            props2skipDD_c = {'IMO_Vessel_Number', 'DateStrFormat'};
            props2skip_c = union(properties(cMySQL), props2skipDD_c);
            props = setdiff(properties(obj), props2skip_c);
            empty = false(size(props));
            for pi = 1:numel(props)
                prop = props{pi};
                empty(pi) = isempty(obj.(prop));
            end
            empty = all(empty);
        end
    end
    
    methods(Hidden, Static)
    
        function datenumeric = setDate(date, stringformat)
            
            if isnumeric(date)
                
                datenumeric = date;
                
            elseif ischar(date) || iscellstr(date)
                
                datenumeric = datenum(date, stringformat);
            end
        end
    end
    
    methods
        
        function date = get.StartDate(obj)
            
            date = datestr(obj.StartDateNum, obj.DateStrFormat);
        end
        
        function date = get.EndDate(obj)
            
            date = datestr(obj.EndDateNum, obj.DateStrFormat);
        end
        
        function obj = set.StartDate(obj, date)
        % Set method for start date, converting date string to number
            
            daten = datenum(date, obj.DateStrFormat);
            obj.StartDateNum = daten;
        end
        
        function obj = set.EndDate(obj, date)
        % Set method for end date, converting date string to number
            
            daten = datenum(date, obj.DateStrFormat);
            obj.EndDateNum = daten;
        end
    end
end