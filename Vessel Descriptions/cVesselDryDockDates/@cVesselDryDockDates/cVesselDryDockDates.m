classdef cVesselDryDockDates < cMySQL & cDateConvert
    %CVESSELDRYDOCKDATES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number = [];
        StartDate
        EndDate
        Vertical_Bottom_Surface_Prep
        Vertical_Bottom_Coating
        Flat_Bottom_Surface_Prep
        Flat_Bottom_Coating
    end
    
    properties(Hidden, Constant)
        
        DBTable = 'DryDockDates';
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'StartDate';
        EndDateProp = 'EndDate';
    end
    
    methods
        
       function obj = cVesselDryDockDates(varargin)
    
           obj = obj@cMySQL(varargin{:});
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
            
%             obj(oi).StartDateNum = datenum(file_t.StartDate(oi)); %, dateform);
%             obj(oi).EndDateNum = datenum(file_t.EndDate(oi)); %, dateform);
%             
%             obj(oi).Vertical_Bottom_Surface_Prep = file_t.VerticalBottomSurfacePrep{oi};
%             obj(oi).Vertical_Bottom_Coating = file_t.VerticalBottomCoating{oi};
%             obj(oi).Flat_Bottom_Surface_Prep = file_t.FlatBottomSurfacePrep{oi};
%             obj(oi).Flat_Bottom_Coating = file_t.FlatBottomCoating{oi};
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
       
       function obj = readFromTable(obj)
       % readFromTable
       
       % Can only read when object is empty to prevent overwriting
       if ~isempty(obj)
           
           errid = 'cDDD:overwrite';
           errmsg = ['Dry dock dates can only be read from table when '...
               'calling object is empty'];
           error(errid, errmsg);
       end
       
       % Need IMO number to look up table
       imo = obj(1).IMO_Vessel_Number;
       if isempty(imo)
           
           errid = 'cDDD:NoIMO';
           errmsg = ['Dry dock dates can only be read from table when '...
               'IMO Vessel Number is known.'];
           error(errid, errmsg);
       end
       
        % Read data from table
        tab = obj(1).DBTable;
        cols = {'StartDate', 'EndDate', 'Vertical_Bottom_Surface_Prep', ...
            'Vertical_Bottom_Coating', 'Flat_Bottom_Surface_Prep', ...
            'Flat_Bottom_Coating'};
        where_sql = ['IMO_Vessel_Number = ', num2str(imo)];
        [~, ddd_t] = obj(1).select(tab, cols, where_sql);
        
        % Return if no dry-dockings found for vessel
        if isempty(ddd_t)
            return
        end
        
        % Pre-allocate array of OBJ
        nObj = height(ddd_t);
        obj(nObj) = cVesselDryDockDates();
        [obj.IMO_Vessel_Number] = deal(imo);
        for ri = 1:nObj
            
            obj(ri).DateStrFormat = 'dd-mm-yyyy';
            obj(ri).StartDate = ddd_t.startdate(ri);
            obj(ri).EndDate = ddd_t.enddate(ri);
            obj(ri).Vertical_Bottom_Surface_Prep = ddd_t.vertical_bottom_surface_prep(ri);
            obj(ri).Vertical_Bottom_Coating = ddd_t.vertical_bottom_coating(ri);
            obj(ri).Flat_Bottom_Surface_Prep = ddd_t.flat_bottom_surface_prep(ri);
            obj(ri).Flat_Bottom_Coating = ddd_t.flat_bottom_coating(ri);
        end
       end
      
       function insertIntoTable(obj)
           
%            dataObj = [obj.DryDockDates];
           obj(isempty(obj)) = [];
           if ~isempty(obj)
%                imo = [obj.IMO_Vessel_Number];
%                [dataObj.IMO_Vessel_Number] = deal(imo(:));
%                tab = 'DryDockDates';
               tab = obj(1).DBTable;
               insertIntoTable@cMySQL(obj, tab);
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
            empty = false(numel(props), numel(obj));
            for oi = 1:numel(obj)
                for pi = 1:numel(props)
                    
                    prop = props{pi};
                    empty(pi, oi) = isempty(obj(oi).(prop));
                end
            end
            empty = all(all(empty));
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
            if (isnumeric(c) && isnan(c)) || isScalarNanCell_l
                ch = nan;
                return
            end
            
            validateattributes(c, {'cell'}, {'scalar'});
            ch = [c{:}];
            validateattributes(ch, {'char'}, {'vector', 'row'});
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
    end
end