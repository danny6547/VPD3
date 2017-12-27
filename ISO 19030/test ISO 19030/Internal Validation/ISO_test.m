% Discribtion: template main for ISO analysis and comparrison with ISO
% validation software
% 
% close all;
% clear classes;

% add directories:
% run('C:\Users\digu\OneDrive - Hempel Group\Documents\MATLAB\Matlab library\SQL_init.m')

% which ISO validation software test to run (1 or 0):
data.run_validation=0;
data.run_windcorrection=0;
data.run_performancevalues=1;


%% input files:

% raw data for use in validation/filtering:
if data.run_validation==1
    Dist=['L:\Project\MWB-Fuel efficiency\Hull and propeller performance\'...
        'ISO 19030 Measurements of changes in hull and propeller performance\Validation\3. Filtering\validateISO19030Test2.csv'];
    %File='C:\Documents\Laurin Maritime_clean\Tambourin\Observations_March2015toOctober2015.csv';                                      %output file
    rawdata=readtable(Dist);
end

% filtered/validated data from validation software for wind correction analysis:
if data.run_windcorrection==1
    Dist=['L:\Project\MWB-Fuel efficiency\Hull and propeller performance\'...
        'ISO 19030 Measurements of changes in hull and propeller performance\Validation\'...
        '1. Calculation of Corrected Delivered Power\validateISO19030Test.csv'];
    rawdata=readtable(Dist);
end

% wind coefficent data:
dist_wind_coeffs=['L:\Project\MWB-Fuel efficiency\Hull and propeller performance\'...
    'ISO 19030 Measurements of changes in hull and propeller performance\'...
    'Validation\1. Calculation of Corrected Delivered Power\validateISO19030TestWind.csv'];


% corrected data from validation software for performance value calculation:
if data.run_performancevalues==1
    Dist=['L:\Project\MWB-Fuel efficiency\Hull and propeller performance\'...
        'ISO 19030 Measurements of changes in hull and propeller performance\'...
        'Validation\2. Calculation of Performance Values\validateISO19030Test_mps.csv'];
    rawdata=readtable(Dist);

    % trial data:
    Dist2=['L:\Project\MWB-Fuel efficiency\Hull and propeller performance\'...
        'ISO 19030 Measurements of changes in hull and propeller performance\'...
        'Validation\2. Calculation of Performance Values\500000 0_mps.csv'];
    Dist3=['L:\Project\MWB-Fuel efficiency\Hull and propeller performance\'...
        'ISO 19030 Measurements of changes in hull and propeller performance\'...
        'Validation\2. Calculation of Performance Values\1000000 -5_mps.csv'];
    trial=readtable(Dist2);
    trial2=readtable(Dist3);
    data.trial.speedpower(:,:,1)=table2array(trial);
    data.trial.speedpower(:,:,2)=table2array(trial2);
    displacement(1)=str2num(Dist2(end-15:end-10));
    displacement(2)=str2num(Dist3(end-17:end-11));
    data.trial.displacement=displacement;
    trim(1)=str2num(Dist2(end-9:end-8));
    trim(2)=str2num(Dist3(end-9:end-8));
    data.trial.trim=trim;
end




%% define variables (creates columns with the relevant variables)

data.angledata=[6,9,10];
data.notuseforChauvenet=[16];%[7,9,12,13,14,15,16];

rawdata.Properties.VariableNames{'Var11'}='duk';                               % water depth
rawdata.Properties.VariableNames{'Var1'}='date';                               % date
%data.Properties.VariableNames{'MEConsumed_MT_'}='cf';                      % fuel consumption in t/15min
%data.cf=data.cf*1000*4;                                                    % fuel consumption in kg/h
rawdata.Properties.VariableNames{'Var3'}='power';                                 % power
rawdata.Properties.VariableNames{'Var4'}='rp';                                 % rpm
rawdata.Properties.VariableNames{'Var12'}='tf';                                % fore draft
rawdata.Properties.VariableNames{'Var13'}='ta';                                % aft draft
rawdata.Properties.VariableNames{'Var5'}='ws';                                 % relative wind speed in m/s
rawdata.Properties.VariableNames{'Var6'}='wd';                                 % relative wind direction
rawdata.Properties.VariableNames{'Var7'}='at';                                 % air temperature
rawdata.Properties.VariableNames{'Var8'}='vg';                                 % ship speed in knots
rawdata.Properties.VariableNames{'Var9'}='cog';                                % course over ground
rawdata.Properties.VariableNames{'Var2'}='vw';                                 % speed through water
rawdata.Properties.VariableNames{'Var15'}='sw';                                % water temperature
rawdata.Properties.VariableNames{'Var10'}='ra';                                % rudder angle
rawdata.Properties.VariableNames{'Var14'}='displacement';                      % displacement

rawdata.date=datenum(rawdata.date,'yyyy-mm-dd HH:MM:SS');                         % date in numerical format
%data.dataDate=cellstr(datestr(data.date,'yyyy-mm-dd'));                    % date in date-format

rawdata.tm=mean([rawdata.ta,rawdata.tf],2);                                          % mean draft
data.rawdata=rawdata;

%% Ship data:

data.ship.f                   =   1/(15);                                        % sampling frequency (1/s))                    
%ship.mcr                 =   7680;                                          % Maximum continuous rating
%ship.maxrpm              =   110;                                           % maximum RPM
%ship.designspeed         =   14.2;                                          %
data.ship.designdraft         =   10;
data.ship.b                   =   50;                                          % ship width
data.ship.lpp                 =   400;                                           % length between perpendiculars
data.ship.d_trial             = [5 7 9];
data.ship.rho_air     = 1.225;                                                   % air density [kg/m^3]
data.ship.A_design    = 1000;                                                    % cross sectional area at design draft [m^2]
data.ship.wind_coeffs = readtable(dist_wind_coeffs);
% ship.C_rw        = [0.7404 0.0167 -0.00788];                                % wind resistance coefficient     
data.ship.etaD0       = 0.5;                                                     % prop. coeff, calm cond.
data.ship.etaDm       = 0.4;                                                     % prop. ceoff, actual cond.
data.ship.Zref_des    = 10;                                                      % reference heitgh above sea level for design condition [m]
data.ship.Za_des      = 10;                                                      % anemometer height above sea level for design condition


% trial data:
% trial.d=[7; 12.5; 14.5];                                                    % mean draft for trial conditions
% trial.vg=zeros(5,3);                                            
% trial.vg(:,1)=[22.5, 23.5, 24.5, 25.5, 26.5];                               % speeds for condition 1
% trial.vg(:,2)=[22, 23, 24, 25, 26];                                         % speeds for condition 2
% trial.vg(:,3)=[21.5, 22.5, 23.5, 24.5, 25.5];                               % speeds for condition 3
% trial.p=zeros(5,3);
% trial.p(:,1)=[25024, 28851, 34298, 40406, 47178];                           % power for condition 1
% trial.p(:,2)=[25466, 29366, 34150, 40112, 47472];                           % power for condition 2
% trial.p(:,3)=[26864, 31795, 37610, 44675, 53213];                           % power for condition 3
% trial.trim=[4 0 0];

%% ISO

%data.p=data.et;                                                             % used power
[data]=iso19030(data);

%writetable(FilterOutput,'FilterOutputDitte.xlsx','Filetype','spreadsheet');

%%%%% compare with validation software data %%%%%%%%%%%%%%%%%%%%

if data.run_validation
% validation:
obj=testISO19030Validate;
obj=obj.readFilteredTable;
tbl = obj.OutFilteredTable;

is_validation_same=isequal(tbl(1,:),data.valdata(1,:))
difference_in_number_of_datapoints=size(tbl,1)-size(data.valdata,1)
end

if data.run_windcorrection
% wind correction:
writetable(data.cordata,'CorrectedpowerDitte.xlsx','Filetype','spreadsheet');

end

if 0
%%%% Reference period %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
refminDate=min(refdata.date);                                               % start of reference period, can either be a fixed date or start of data
refmaxDate=refminDate+datenum(90);                                          % end of reference period, 90 days after start of refperiod.
idxref=refdata.date>=refminDate & refdata.date<=refmaxDate;                 % indices for reference period

VdMeanref=mean(refdata.Vd(idxref));                                         % mean value of performance value (speed loss) in reference period


%%%% Evaluation period %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
evamaxDate=max(refdata.date);                                               % end of evaluation period
evaminDate=evamaxDate-datenum(90);                                          % beginning of evaluation period
idxeva=refdata.date>=evaminDate & refdata.date<=evamaxDate;                 % index for evaluation period

VdMeaneva=mean(refdata.Vd(idxeva));                                         % mean value of performance value in evaluation period


%%%%% Performance Indicators %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ISP=VdMeaneva-VdMeanref;                                                     % "In Service Performance"

% n=50;                                                                       % Running average of 100 points (50 on each side)
% my_Vd=zeros(size(cordata.Vd,1)-n,1);                                        %
% for i=(n+1):size(cordata.Vd,1)-n                                            %
%     my_Vd(i,1)=mean(cordata.Vd(i-n:i+n));                                   %
% end

% Maintenance trigger                                                         Difference between 3 months average of speed loss after last
                                                                              % dry-docking and a running average speed loss                                                              

% c=polyfit(cordata.date,cordata.Vd,1);                                       % linear fit through the whole data period
% lindate=linspace(min(cordata.date),max(cordata.date),100);                  %
% linfit=c(1)*lindate+c(2);                                                   % 

figure(5)                                                                   % Performance value overview, maintenance trigger
hold on;
plot(refdata.date,refdata.Vd,'.')                                           % plot data points
plot([refminDate, refmaxDate],[VdMeanref, VdMeanref],'-')                   % plot reference period mean performance value
plot([evaminDate, evamaxDate],[VdMeaneva, VdMeaneva],'-')                   % plot evaluation period mean perofrmance value
%plot(cordata.date((n+1):(end-n)),my_Vd((n+1):end),'-r')                     % plot running average
%plot(lindate,linfit);                                                       % plot linear fit
datetick('x','dd/mm-yy','keepticks');
xticklabel_rotate([],45,[])
xlabel('Date')
ylabel('Speed loss, Knots')

figure(6)                                                                   % speed through water comparrison original data and reduced/corrected
hold on;
plot(data.date,data.vw,'y.')                                                % plot speed through water original
plot(valdata.date,valdata.vw,'b.')                                          % plot speed through water validated data
plot(refdata.date,refdata.vw,'g.')                                          % plot speed through water reference data
datetick('x','dd/mm-yy','keepticks');
xticklabel_rotate([],45,[])
xlabel('Date')
ylabel('Speed through water, Knots')

end