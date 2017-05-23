% Create object
vessel = cVessel();

% Ship particulars
vessel.Name = 'CMA CGM DANUBE';
vessel.Owner = 'CMA CGM';
vessel.IMO_Vessel_Number = 9674517;
vessel.Transverse_Projected_Area_Design = 1344;
vessel.Block_Coefficient = 0.673;
vessel.Length_Overall = 299.95;
vessel.Breadth_Moulded = 48.2;
vessel.Draft_Design = 12.5;
vessel.LBP = 186;
vessel = vessel.insertIntoVessels();

% Speed Power
objSP = cVesselSpeedPower();
objSP.Speed = [12;12.5;13;13.5;14;14.5;15;15.5;16;16.5;17;17.5;18;18.5;19;19.5;20;20.5;21;21.5;22;22.5;23;23.5;24;24.5;25];
objSP.Power = [5230;5999.5;6795.4;7614.4;8453.7;9311.1;10188.6;11092.8;12031.9;13015.8;14056.2;15165.9;16359.7;17664.7;19077.3;20608.6;22273;24088.5;26079.6;28273.5;30591.5;33281;36290.2;39670.7;43477.6;47756.5;52548.6];
objSP.Trim = 0;
objSP.Displacement = 115904;
vessel.SpeedPower(1) = objSP;

objSP = cVesselSpeedPower();
objSP.Speed = [12;12.5;13;13.5;14;14.5;15;15.5;16;16.5;17;17.5;18;18.5;19;19.5;20;20.5;21;21.5;22;22.5;23;23.5;24];
objSP.Power = [5351.3;6006.6;6706.6;7458.6;8270.8;9150.9;10106.4;11145.8;12277.9;13511.1;14854.2;16316.6;17908.2;19654.9;21522.1;23551.6;25681.5;28114.2;30805.5;33798.1;37146.7;40915.4;45174;50006.2;55486.5];
objSP.Trim = 0;
objSP.Displacement = 143153;
vessel.SpeedPower(2) = objSP;
vessel = vessel.insertIntoSpeedPowerCoefficients;

% Wind
wind9200 = cVesselWindCoefficient();
dirCoeffs = [-0.9724771;-0.96330273;-1.0550458;-1.0389909;-0.9013761;-0.79816514;-0.6536697;-0.48165137;-0.2614679;0.116972476;0.4885321;0.9036697;1.0298165;1.0665138;0.9105505];
directions = [0 7.5 15 22.5 30 45 60 75 90 105 120 135 150 165 180];
wind9200.Direction = directions;
wind9200.Coefficient = dirCoeffs;
wind9200 = wind9200.mirrorAlong180;
vessel.WindCoefficient = deal( wind9200 );
vessel = vessel.insertIntoWindCoefficients();

% Engine
engine11400 = cVesselEngine();
engine11400.Name = 'Man B&W 12K98ME-C Mk7';
mcr = 72240; 
sfoc = [174.69;174.43;174.1;173.59;173.29;172.98;172.7;172.26;171.75;171.12;170.68;170.07;169.51;168.95;168.44;167.91;167.32;166.83;166.49;166.32;166.39;166.54;166.75;166.98;167.31;167.61;168.03;168.4;168.78;169.22;169.69;170.18;170.76;171.18;171.65;172.16;172.58;172.96;173.31];
powerPCT = [37.2;38.14;39.2;40.62;41.56;42.39;43.33;44.75;46.28;48.29;49.82;51.71;53.72;55.84;57.85;60.21;62.8;65.28;68.11;71.65;75.07;77.55;80.27;82.63;84.87;87.11;89.35;91.36;93.24;95.13;97.26;99.03;101.27;102.68;104.45;106.11;107.29;108.58;110];
engine11400.fitData2Quadratic(mcr, sfoc, powerPCT);
vessel.Engine = engine11400;
vessel = vessel.insertIntoSFOCCoefficients();

% Dry dock dates
ddd = cVesselDryDockDates();
ddd = ddd.assignDates('2015-11-21', '2015-12-07');
vessel.DryDockDates = ddd;
vessel = vessel.insertIntoDryDockDates;

% Just insert everything!
vessel = vessel.insert;