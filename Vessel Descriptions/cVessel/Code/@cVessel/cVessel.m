classdef cVessel < cMySQL
    %CVESSEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number double, single, int = [];
        Name char = '';
        Owner char = '';
        Class = [];
        LBP = [];
        Engine = [];
        Wind_Resist_Coeff_Dir = [];
        Transverse_Projected_Area_Design = [];
        Block_Coefficient = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        Speed_Power_Source char = '';
        SpeedPowerCoefficients double = [];
        SpeedPowerRSquared double = [];
        
    end
    
    methods
    
       function obj = cVessel(varargin)
       % Class constructor. Construct new object, assign array of IMO.
         
       
       % Inputs
       szIn = [0, 1];
       if nargin > 0
           
            imo = varargin{1};
            validateattributes(imo, {'numeric'},...
              {'positive', 'real', 'integer'}, 'cShip constructor', 'IMO',...
              1);
            szIn = size(imo);
       end
       if nargin > 1
            name = varargin{2};
            name = validateCellStr(name, 'cShip constructor', 'name', 2);
       else
            name = repmat({''}, szIn);
       end
         
       if nargin ~= 0
            
            numOuts = prod(szIn);
            obj(numOuts) = cShip;
            
            for ii = 1:numel(imo)
                obj(ii).IMO_Vessel_Number = imo(ii);
                obj(ii).Name = name{ii};
            end
            
            obj = reshape(obj, szIn);
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
       [obj.Wind_Resist_Coeff_Dir] = vesselclass(:).Wind_Resist_Coeff_Dir;
       [obj.Transverse_Projected_Area_Design] = vesselclass(:).Transverse_Projected_Area_Design;
       [obj.Block_Coefficient] = vesselclass(:).Block_Coefficient;
       [obj.Length_Overall] = vesselclass(:).Length_Overall;
       [obj.Breadth_Moulded] = vesselclass(:).Breadth_Moulded;
       [obj.Draft_Design] = vesselclass(:).Draft_Design;
       [obj.Class] = vesselclass(:).WeightTEU;
       
       end
       
       function obj = insertIntoVessels(obj)
       % insertIntoVessels Insert vessel data into table 'Vessels'.
       
       % Table of vessel data
       numShips = numel(obj);
       numColumns = 11;
       data = cell(numShips, numColumns);
       
       for ii = 1:numel(obj)
           
           data{ii, 1} = obj(ii).IMO_Vessel_Number;
           data{ii, 2} = obj(ii).Name;
           data{ii, 3} = obj(ii).Owner;
           data{ii, 4} = obj(ii).Engine;
           data{ii, 5} = obj(ii).Wind_Resist_Coeff_Dir;
           data{ii, 6} = obj(ii).Transverse_Projected_Area_Design;
           data{ii, 7} = obj(ii).Block_Coefficient;
           data{ii, 8} = obj(ii).Breadth_Moulded;
           data{ii, 9} = obj(ii).Length_Overall;
           data{ii, 10} = obj(ii).Draft_Design;
           data{ii, 11} = obj(ii).LBP;
       end
       
       
       % Prepate inputs to insert data without duplicates
       otherCols_c = {'Name', ...
                        'Owner', ...
                        'Engine_Model', ...
                        'Wind_Resist_Coeff_Dir', ...
                        'Transverse_Projected_Area_Design', ...
                        'Block_Coefficient', ...
                        'Breadth_Moulded', ...
                        'Length_Overall', ...
                        'Draft_Design', ...
                        'LBP'};
%        format_s = '%u, %s, %s, %s, %f, %f, %f, %f, %f, %f, %f';
       
       % Remove any columns with any empty values
       cols_c = [{'IMO_Vessel_Number'}, otherCols_c];
       emptyMat_l = cellfun(@isempty, data);
       if isvector(emptyMat_l)
           emptyVect_l = emptyMat_l;
       else
           emptyVect_l = any(emptyMat_l);
       end
       cols_c(emptyVect_l) = [];
       data(emptyVect_l) = [];
       
       obj = obj.insertValuesDuplicate('Vessels', cols_c, data);
       
%        insertWithoutDuplicates(data, 'Vessels', 'id', 'IMO_Vessel_Number',...
%            otherCols_c, format_s);
       
       end
       
       function obj = insertIntoSFOCCoefficients(obj)
       % insertIntoSFOCCoefficients Insert engine data into table
       
       
       if isempty(obj.Engine)
           
          errid = 'VesselPer:EngineNeeded';
          errmsg = ['Vessel Engine needed before SFOC data can be inserted'...
              ' into database.'];
          error(errid, errmsg);
       end
       
       % Iterate over engines, build matrix
       [obj.Engine]
       
       % Keep only unique engines
       
       % Call SQL
       obj = obj.insertValuesDuplicate();
       
       end
       
       function obj = insertIntoSpeedPower(obj, speed, power, displacement, trim)
       % insertIntoSpeedPower Insert speed, power, draft, trim data.
       
       % Repeat scalar inputs to match uniform size (call SPCoeffs)
       imo = repmat(obj.IMO_Vessel_Number, size(speed, 1));
       
       data_c = arrayfun(@(x) [repmat(x, size(speed, 1), 1), ...
           speed, displacement, trim, power]', [obj.IMO_Vessel_Number],...
           'Uni', 0);
       data = [data_c{:}]';
       
       % Insert
%        data = [imo, speed, displacement, trim, power];
%        toTable = 'speedPower';
%        key = 'id';
%        uniqueColumns = {'IMO_Vessel_Number', 'Speed', 'Displacement', 'Trim', };
%        otherColumns = {'Power'};
%        format_s = '%u, %f, %f, %f, %f';
       
       table = 'speedPower';
       columns_c = {'IMO_Vessel_Number', 'Speed', 'Displacement', 'Trim',...
           'Power'};
       obj = obj.insertValuesDuplicate(table, columns_c, data);
%        insertWithoutDuplicates(data, toTable, key, uniqueColumns, ...
%            otherColumns, format_s);
       
       end
       
       function obj = insertBunkerDeliveryNote(obj)
       % insertBunkerDeliveryNote Insert data from 
           
           
       end
       
%        function obj = fitSpeedPower(obj, speed, power, varargin)
%        % fitSpeedPower Fit speed, power data to model
%        
%        % Input
%        validateattributes(speed, {'numeric'}, {'real', 'positive', 'vector',...
%            'nonnan'}, 'fitSpeedPower', 'speed', 2);
%        validateattributes(power, {'numeric'}, {'real', 'positive', 'vector',...
%            'nonnan'}, 'fitSpeedPower', 'power', 3);
%        
%        % Fit data
%        coeffs = polyfit();
%        
%            
%        end
    end
    
    methods(Static)
        
        function varargout = repeatInputs(inputs)
        % repeatInputs Repeat any scalar inputs to match others' size
        
        % Check that all inputs are the same size or are scalar
        scalars_l = cellfun(@isscalar, inputs);
        empty_l = cellfun(@isempty, inputs);
        emptyOrScalar_l = scalars_l | empty_l;
        allSizes_c = cellfun(@size, inputs(~emptyOrScalar_l), 'Uni', 0);
        szMat_c = allSizes_c(1);
        chkSize_c = repmat(szMat_c, size(allSizes_c));
        if ~isequal(allSizes_c, chkSize_c)
           errid = 'DBTab:SizesMustMatch';
           errmsg = 'All inputs must be the same size, or any can be scalar';
           error(errid, errmsg);
        end
        
        % Repeat scalars
        inputs(scalars_l) = cellfun(@(x) repmat(x, chkSize_c{1}),...
            inputs(scalars_l), 'Uni', 0);
        
        % Assign outputs
        varargout = inputs;
        
        end
        
    end
    
    methods
        
        function obj = set.IMO_Vessel_Number(obj, IMO)
           
           validateattributes(IMO, {'numeric'}, ...
               {'positive', 'real', 'nonnan', 'integer'});
           obj.IMO_Vessel_Number = IMO;
           
        end
        
    end
end