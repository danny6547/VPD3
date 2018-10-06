function [obj, analysis] = analyse(obj, varargin)
%analyse Analyse vessel data
%   Detailed explanation goes here

% Check input
if nargin > 1
    
    analysis = varargin{1};
    if ~isa(analysis, 'cVesselAnalysis')
        
        errid = 'cV:AnalysisInputType';
        errmsg = ['Analyse method requires an object of a '...
            'cVesselAnalysis child class'];
        error(errid, errmsg);
    end
    
    % Check input analysis is same size as OBJ or scalar
    
else
    
    % Generate default ISO19030 analysis object
    analysis = arrayfun(@(x) cVesselISO19030, obj, 'Uni', 0);
    analysis = [analysis{:}];
end

% Assign data needed by analysis methods
sql_c = {obj.InServicePreferences.SQL};
[analysis.SQL] = deal(sql_c{:});
vcid_v = [obj.Configuration];
[analysis.VesselConfiguration] = deal(vcid_v);

% Error if vessel not inserted into static

% Error if vessel not inserted into in-service

% Analyse
analysis = analysis.analyse;

% Insert outputs into calculated data table
