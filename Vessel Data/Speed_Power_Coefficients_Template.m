% This script demonstrates how to calculate speed power coefficients. It 
% will create a cVessel object in variable VESS and insert the data into 
% the database.

sp = cVesselSpeedPower();

knots2mps = 0.514444444;
bhp2Kw = 0.745699872 * 1e3;
design = [...
                                ];
sp(1).Speed = design(:, 1) * knots2mps; % m/s
sp(1).Power = design(:, 2) * bhp2Kw; % kW
sp(1).Trim = [];% Positive by the bow, negative by the stern
sp(1).Displacement = []; % tonnes of seawater displaced at given seawater density
sp(1).FluidDensity = []; % kg / m^3, optional, default values is 1025
sp(1).Name = 'Design';

ballast = [...
                                ];
sp(end+1).Speed = ballast(:, 1) * knots2mps;
sp(end).Power = ballast(:, 2) * bhp2Kw;
sp(end).Trim = [];
sp(end).Displacement = [];
sp(end).FluidDensity = [];
sp(end).Name = 'Ballast';

sp.print;