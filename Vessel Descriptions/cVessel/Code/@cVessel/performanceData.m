function [ out, ddd, intd] = performanceData(obj, imo, varargin)
%performanceData Read ship performance data from database, over time range
%   [out] = performanceData(imo) will read all data for the ship
%   identified by numeric vector IMO from the database into output 
%   structure OUT. OUT will have fields Date, PerformanceIndex and 
%   SpeedIndex. The size of OUT will match the size of IMO.
%   [out] = performanceData(imo, ddi) will, in addition to the above,
%   filter the data returned in OUT to that of the dry-dock interval given
%   by DDI, where DDI is a numeric scalar or vector containing only
%   integers. OUT will have as many rows as elements in IMO and as many 
%   columns as elements in DDI. If DDI is zero, all dry-dock intervals will
%   be returned.

% Initialise Outputs
out = struct('DateTime_UTC', [],...
    'Performance_Index', [],...
    'Speed_Index', [],...
    'DryDockInterval', [],...
    'IMO_Vessel_Number', []);
ddd = cVesselDryDockDates();
intd = cell(0, 2);

% Inputs
validateattributes(imo, {'numeric'}, {'vector', 'integer', 'positive'},...
    'performanceData', 'IMO', 2);
ddi_l = false;
iterDD_l = false;

if nargin > 2
    ddi = varargin{1};
    validateattributes(ddi, {'numeric'}, {'integer', '>=', 0},...
        'performanceData', 'DDi', 3);
    ddi_l = ~isempty(ddi);
    
    if ddi_l && isequal(ddi, 0);
        iterDD_l = true;
    end
end

% Fixed inputs to sql procedure
additionalInputs_c = {'@intervalStart', '@intervalEnd', '@ddindex'};

% Iterate over IMO
for vi = 1:numel(imo)
    
    % Convert inputs to char
    currImo = imo(vi);
    imo_ch = num2str(currImo);
    
    % Iterate over Dry Dock interval
    if iterDD_l
        
        % Get data for this dry-docking interval
        currDD = 1;
        currIter_ch = num2str(currDD);
        [obj(1), tbl] = obj(1).call('performanceData', ...
            [{imo_ch, currIter_ch}, additionalInputs_c]);
        % 'Speed_Index', 'IMO_Vessel_Number', 'DryDockInterval'};
        
        while ~isempty(tbl)
            
            tbl.Properties.VariableNames = {'DateTime_UTC', 'Performance_Index',...
                'Speed_Index'};
            [~, ddIndex_c] = obj.execute('SELECT @ddindex;');
            ddIndex_v = str2double([ddIndex_c{:}]);
            
            % Append to output
            currOut = table2struct(tbl, 'ToScalar', 1);
            currOut.DryDockInterval = ddIndex_v;
            currOut.IMO_Vessel_Number = currImo;
            out(currDD, vi) = currOut;
            
            currDD = currDD + 1;
            currIter_ch = num2str(currDD);
            
            [obj(1), tbl] = obj(1).call('performanceData', ...
                [{imo_ch, currIter_ch}, additionalInputs_c]);
        end
        
    else
        
        if ddi_l
        
            ddi_ch = num2str(ddi);
        else
            
            ddi_ch = 'NULL';
        end
        
        [obj(1), tbl] = obj(1).call('performanceData', [{imo_ch, ddi_ch},...
            additionalInputs_c]);
        tbl.Properties.VariableNames = {'DateTime_UTC', 'Performance_Index',...
                                    'Speed_Index'};
        
        % Append to output
        currOut = table2struct(tbl, 'ToScalar', 1);
        currOut.DryDockInterval = 1;
        currOut.IMO_Vessel_Number = currImo;
        out(vi) = currOut;
    end
    
    [~, currIntDates] = obj(1).executeIfOneOutput(1, ...
        'SELECT @intervalStart, @intervalEnd');
    intd = [intd; currIntDates];
end

% Reorder where no data found for a dry dock interval
imo_c = repmat({out(1, :).IMO_Vessel_Number}, [size(out, 1), 1]);
[out.IMO_Vessel_Number] = deal(imo_c{:});
