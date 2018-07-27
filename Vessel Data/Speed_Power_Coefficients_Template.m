% This script demonstrates how to calculate speed power coefficients. It 
% will create a cVessel object in variable VESS and insert the data into 
% the database.

% Assign Speed, Power
sp = cVesselSpeedPower();

knots2mps = 0.514444444;
bhp2Kw = 0.745699872 * 1e3;
design = [...
                                ];
sp(1).Speed = design(:, 1) * knots2mps; % m/s
sp(1).Power = design(:, 2) * bhp2Kw; % kW
sp(1).Trim = [];% Positive by the bow, negative by the stern
sp(1).Displacement = []; % tonnes of seawater displaced at given seawater density
sp(1).FluidDensity = []; % tn / m^3, optional, default values is 1025
sp(1).Name = 'Design';

ballast = [...
                                ];
sp(2).Speed = ballast(:, 1) * knots2mps;
sp(2).Power = ballast(:, 2) * bhp2Kw;
sp(2).Trim = [];
sp(2).Displacement = [];
sp(2).FluidDensity = [];
sp(2).Name = 'Ballast';