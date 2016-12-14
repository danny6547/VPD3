classdef cShip
    %CSHIP Summary of this class goes here
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
    
       function obj = cShip(varargin)
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
       
       function obj = assignClass(obj, shipclass)
       % assignClass Assign ship to ship class.
       
       % Inputs
       validateattributes(shipclass, {'cShipClass'}, {'scalar'}, ...
           'assignClass', 'shipclass', 1);
       if isscalar(shipclass)
           shipclass = repmat(shipclass, size(obj));
       end
       
       [obj.LBP] = shipclass(:).LBP;
       [obj.Engine] = shipclass(:).Engine;
       [obj.Wind_Resist_Coeff_Dir] = shipclass(:).Wind_Resist_Coeff_Dir;
       [obj.Transverse_Projected_Area_Design] = shipclass(:).Transverse_Projected_Area_Design;
       [obj.Block_Coefficient] = shipclass(:).Block_Coefficient;
       [obj.Length_Overall] = shipclass(:).Length_Overall;
       [obj.Breadth_Moulded] = shipclass(:).Breadth_Moulded;
       [obj.Draft_Design] = shipclass(:).Draft_Design;
       [obj.Class] = shipclass(:).WeightTEU;
       
       end
       
       function obj = insertIntoVessels(obj)
       % insertIntoVessels Insert ship data into table 'Vessels'.
       
       % Table of ship data
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
       format_s = '%u, %s, %s, %s, %f, %f, %f, %f, %f, %f, %f';
       insertWithoutDuplicates(data, 'Vessels', 'id', 'IMO_Vessel_Number',...
           otherCols_c, format_s);
       
       end
       
       function obj = insertIntoSFOCCoefficients(obj)
       % insertIntoSFOCCoefficients Insert engine data into table
       
       
       if isempty(obj.Engine)
           
          errid = 'ShipPer:EngineNeeded';
          errmsg = ['Ship Engine needed before SFOC data can be inserted'...
              ' into database.'];
          error(errid, errmsg);
       end
       
       % 
       
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