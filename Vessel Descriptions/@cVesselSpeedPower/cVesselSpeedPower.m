classdef cVesselSpeedPower < handle & matlab.mixin.SetGet
    %CVESSELSPEEDPOWER Vessel speed and power data
    %   Detailed explanation goes here
    
    properties
        
        Speed double;
        Power double;
        Trim double;
        Displacement double;
        Speed_Power_Source char = '';
        SpeedPowerCoefficients double = [];
        Exponent_A double = [];
        Exponent_B double = [];
        R_Squared double = [];
        
    end
    
    properties(Dependent, Hidden)
        
       SpeedPowerDraftTrim double = []; 
        
    end
    
    methods
    
       function obj = cVesselSpeedPower(varargin)
           
%            if nargin > 0
%               
%                size_c = num2cell(size(varargin{1}));
%                obj(size_c{:}) = cVesselSpeedPower();
%                
%            end
       end
       
       
    end
    
    methods(Hidden)
       
       function spdt = speedPowerDraftTrim(obj)
          
           % Repeat all to the same size
           allLengths_c = arrayfun(@(x) length(x.Speed), obj, 'Uni', 0);
           numRows = sum([allLengths_c{:}]);
           
           out_c = cell(1, 4);
           currOut_m = nan(numRows, 4);
           currRow = 1;
            
            for oi = 1:numel(obj)
                [out_c{:}] = cVessel.repeatInputs({obj(oi).Speed, obj(oi).Power,...
                    obj(oi).Displacement, obj(oi).Trim});
                out_c = cellfun(@(x) x(:), out_c, 'Uni', 0);
%                 currOut_m = [currOut_m; cell2mat(out_c)];'
                currMat = cell2mat(out_c);
                currNumRows = size(currMat);
                currOut_m(currRow : currRow + currNumRows - 1, :) = currMat;
                currRow = currRow + currNumRows;
            end
            spdt = currOut_m;
       end
       
       function spc = speedPowerCoefficientsTable(obj)
       % speedPowerCoefficientsTable Table of speed, power coefficient data
           
           % Repeat all to the same size
           allLengths_c = arrayfun(@(x) length(x.Trim), obj, 'Uni', 0);
           numRows = sum([allLengths_c{:}]);
           
           
           
       end
    end
    
    methods
        
        function spdt = get.SpeedPowerDraftTrim(obj)
        % 
            
            % Repeat all to the same size, make into matrix
            [speed, power, draft, trim] = cVessel.repeatInputs({obj.Speed,...
                obj.Power, obj.Trim, obj.Displacement});
            spdt = [speed(:), power(:), draft(:), trim(:)];
            
        end
        
        function set.Speed(obj, speed)
        % 
        
        if ~isempty(speed)
            validateattributes(speed, {'numeric'}, {'real', 'vector',...
                'nonnan'});
        end
        
        power = obj.Power;
        if ~isempty(power) && (~isempty(speed) && ~isempty(power))...
                && ~isequal(size(power), speed)
            
            errID = 'cSP:SPSizeMismatch';
            errMsg = 'Speed vector length must match that of Power';
            error(errID, errMsg);
        end
        
        obj.Speed = speed;
        end
        
        function set.Power(obj, power)
        % 
        
        if ~isempty(power)
            validateattributes(power, {'numeric'}, {'real', 'vector',...
                'nonnan'});
        end
        
        speed = obj.Speed;
        if ~isempty(power) && (~isempty(speed) && ~isempty(power))...
                && ~isequal(size(power), size(speed))
            
            errID = 'cSP:SPSizeMismatch';
            errMsg = 'Power vector length must match that of Speed';
            error(errID, errMsg);
        end
        
        obj.Power = power;
            
        end
        
        function set.Trim(obj, trim)
        % 
        
        if ~isempty(trim)
            validateattributes(trim, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        obj.Trim = trim;
            
        end
        
        function set.Displacement(obj, displacement)
        % 
        
        if ~isempty(displacement)
            validateattributes(displacement, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        obj.Displacement = displacement;
            
        end
        
    end
end