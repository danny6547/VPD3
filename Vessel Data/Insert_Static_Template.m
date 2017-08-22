% This is an "Insert data" script. It will create a cVessel object in
% variable VESS and insert the data into the database, unless VESS already
% exists in which case it will assign data to the object but not insert.

% Inputs
vesselInput = exist('vess', 'var');
if ~vesselInput
    
    vess = cVessel();
end

% Create vessels, Assign IMO
imo = [...
		1234567 ...
        ];
vess = cVessel('IMO', imo);

% Assign Static Data
[vess.Owner] = deal('Owner Co.');

engine = cVesselEngine();
engine.Name = '';

vess.Engine = engine;
vess.Transverse_Projected_Area_Design = [];
vess.Block_Coefficient = [];
vess.Length_Overall = [];
vess.Breadth_Moulded = [];
vess.Draft_Design = [];
vess.LBP = [];
vess.Anemometer_Height = [];
vess.Name = 'Vessel Name';

% Assign Speed, Power
knots2mps = 0.514444444;
bhp2Kw = 0.745699872;
design = [...
        ];

vessSP = cVesselSpeedPower([1, 2]);
[vessSP(1).Speed] = design(:, 1) * knots2mps;
[vessSP(1).Power] = design(:, 2) * bhp2Kw * 1e3;
[vessSP(1).Trim] = [];
[vessSP(1).Displacement] =  [] * 1e3;
vessSP(1).Name = 'Example speed-power curve Design';

ballast = [...
        ];
vessSP(2).Speed = ballast(:, 1) * knots2mps;
vessSP(2).Power = ballast(:, 2) * bhp2Kw * 1e3;
vessSP(2).Trim = [];
vessSP(2).Displacement = [];
vessSP(2).Name = 'Example speed-power curve Ballast';
[vess(1).SpeedPower] = deal(vessSP);

% Assign Wind
wind = cVesselWindCoefficient();
wind.Name = 'Insert existing wind model name here, or create your own.';
wind.Wind_Reference_Height_Design = 10;
[vess.WindCoefficient] = deal(wind);

% Engine
engine = cVesselEngine();
engine.Name = 'Engine Name here';
mcr = []; 
sfoc = [];
powerPCT = [];
engine.fitData2Quadratic(mcr, sfoc, powerPCT);
vessel.Engine = engine;
vessel = vessel.insertIntoSFOCCoefficients();

% Dry dock dates
ddd = cVesselDryDockDates();
ddd = ddd.assignDates('startDate', 'endDate');
vessel.DryDockDates = ddd;
vessel = vessel.insertIntoDryDockDates;

% Assign Bunker Delivery
...

if ~vesselInput
    
    % Insert data
    vess = vess.insert;
    
    % Load time-series data
    
end