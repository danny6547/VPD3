function cordata=windcorrection(data)

% [wstrue,wdtrue,~,~] = ...
%     relativetotruewind2(data.valdata.ws*1.94384,data.valdata.wd,...
%     data.valdata.vg,data.valdata.cog);                                                % true wind at anemometer height [knots] 

data.valdata.ws = data.valdata.ws * 0.514444444;
data.valdata.vg = data.valdata.vg * 0.514444444;

[wstrue,wdtrue,~,~] = ...
    relativetotruewind2(data.valdata.ws, data.valdata.wd,...
    data.valdata.vg,data.valdata.cog);                                                % true wind at anemometer height [knots] 

data.valdata.wstrue = wstrue;

deltaT      = data.ship.designdraft-data.valdata.tm;                                  % difference between design and actual draft [m]
A           = data.ship.A_design+deltaT.*data.ship.b;                                 % cross sectional area at actual draft

Za          = data.ship.Za_des+deltaT;                                           % anemometer height above sea level actual condition [m]
  
Zref        = (data.ship.A_design*(data.ship.Zref_des+deltaT)+...
    0.5*data.ship.b*deltaT.^2)./A;                                               % reference height above sea level actual condition [m]                 
wstrue_ref  = (wstrue).*(Zref./Za).^(1/7);                          % true wind speed at reference height in [m/s]
 
[wv_rel_ref_knots,wdrel_ref,~,~,~] = ...
               truetorelativewind(wstrue_ref,...
               wdtrue,data.valdata.vg,data.valdata.cog);                              % relative wind speed and direction at reference height [knots]    
 
wv_rel_ref  = wv_rel_ref_knots;                                     % relative wind speed at reference height [m/s]
 
% C_rw_wdrel_ref = FindWindCoeff(data.valdata.wd,data.ship.wind_coeffs);
C_rw_wdrel_ref = FindWindCoeff(wdrel_ref,data.ship.wind_coeffs);

%data.ship.C_rw(1)*cos(data.ship.C_rw(2)*wdrel_ref+data.ship.C_rw(3));        % wind resistance coefficient                          
C_0w        = FindWindCoeff(0,data.ship.wind_coeffs);
%data.ship.C_rw(1)*cos(data.ship.C_rw(2)*0          +data.ship.C_rw(3));      % wind resistance coefficient at head (0 deg)

dmcl_rho = ones(32, 1);   
% wv_rel_ref = wv_rel_ref * 0.514444444;
dmcl_rho = 101325.000 ./ (287.058*(0 + 273.15));
        
Rrw         = 0.5*dmcl_rho.*(wv_rel_ref.^2).*A.*C_rw_wdrel_ref.';          % wind resistance 
R0w         = 0.5*dmcl_rho.*((data.valdata.vg).^2).*A*C_0w;           % wind resistance head wind
DeltaPW     = ( (Rrw-R0w).*(data.valdata.vg)/data.ship.etaD0+(data.valdata.power*1E3).*...
    (1-data.ship.etaDm/data.ship.etaD0) ) /1000;                                              % Wind correction [W]
PDcorr      = data.valdata.power-DeltaPW;                                       % Corrected delivered power entries [kW]

% assign data
cordata     = data.valdata;
cordata.cor_power   = PDcorr;

% Test plot
figure(100)                                                                 % plotting validated power, power correction and corrected power      
hold on
p1 = plot(data.valdata.power,'r');
p2 = plot(DeltaPW/1000,'b');
p3 = plot(PDcorr,'g');
legend([p1,p2,p3], 'Power', 'dPW', 'Pcorr')
title('Power corrections due to wind, ISO')
end