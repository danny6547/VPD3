clear all
close all

% run('C:\Users\digu\OneDrive - Hempel Group\Documents\MATLAB\Matlab library\SQL_init.m')

 
IMO=[9280603;9334155;9334167;9350381;9350393;9356309;9356311;...
    9399193;9399208;9399222;9410727;9410741;9410753;9410765;...
    9410777;9410789;9410791;9450624;9450648;9451915;9451927;...
    9451939;9451965;9453559;9454395;9454400;9454412;9454424;...
    9454436;9454448;9454450;9674517;9674531;9674543;9674555;...
    9674567;9705055;9705067;9705079;9705081];                               % relevant IMO numbers

names=['CMA CGM CHOPIN, ANL WYONG, ANL WANGARATTA, CMA CGM AMBER, CMA CGM CORAL, CMA CGM HYDRA, CMA CGM MUSCA, CMA CGM LIBRA, CMA CGM LEO, CMA CGM TITAN, CMA CGM ANDROMEDA, CMA CGM AQUILA, CMA CGM CALLISTO, CMA CGM CASSIOPEIA, CMA CGM CENTAURUS, CMA CGM COLUMBA, CMA CGM GEMINI, CMA CGM DALILA, CMA CGM ALMAVIVA, CMA CGM AFRICA ONE, CMA CGM AFRICA TWO, CMA CGM AFRICA THREE, CMA CGM AFRICA FOUR, CMA CGM CHRISTOPHE COLOMB, CMA CGM AMERIGO VESPUCCI, CMA CGM CORTE REAL, CMA CGM LAPEROUSE, CMA CGM MAGELLAN, CMA CGM MARCO POLO, CMA CGM ALEXANDER VON HUMBOLDT, CMA CGM JULES VERNE, NILEDUTCH ORCA, CMA CGM LOIRE, CMA CGM RHONE, CMA CGM TAGE, CMA CGM THAMES, CMA CGM LITANI, CMA CGM TIGRIS, CMA CGM URAL, CMA CGM VOLGA'];
Names=strsplit(names,',');

obj=cVessel('IMO',IMO,'DDi',0);                                             % assign obj

for i=1:length(Names)
    for j=1:3
        if ~isempty(obj(j,i).IMO_Vessel_Number)                                 % Assign names
            obj(j,i).Name=Names(i);
            %obj(j,i)=obj(j,i).insertIntoVessels;
        end
    end
end

for n=1:2
    
    if n==2
        [obj.Variable] = deal('Performance_Index');                                 % Use performance index
    end
    
    obj=obj.regressions(1);                                                     % calculate regression lines
    
    obj=obj.movingAverages(365.25,false,true);                                  % calculate averages for each year
    
    obj=obj.inServicePerformance;
    
    obj=obj.dryDockingPerformance;
    
    obj=obj.serviceInterval;
    
    [obj, ~, ~, ~, ~, semLines(:, n)] = obj.plotPerformanceData;                                                % plot data
    
    
    %% Inservice performance and DD performance values for table
    
    InServicePerformance=[];
    DryDockingPerformance=[];
    StringVesselNames=[];
    VesselIMO=[];
    DryDockDate=[];
    BeforeDryDockLevel=[];
    AfterDryDockLevel=[];
    LengthOfServiceInt=[];
    ServiceIntStart=[];
    ServiceIntEnd=[];
    EqInService=[];
    
    for i=1:length(IMO)                                                         % loop through vessels
        
        for j=1:3                                                               % loop through DD intervals
            
            
            % In Service Performance
            
            if isempty(obj(j,i).InServicePerformance)
                %InServicePerformance(i,j)=nan;                              % put a NaN value when empty in Service value
                %inserviceperformance=nan;
                %lengthofserviceint=nan;
            else
                %InServicePerformance(i,j)=...
                inserviceperformance=...
                    obj(j,i).InServicePerformance(2).Average...
                    -obj(j,i).InServicePerformance(1).Average;              % calculate in service performance from difference in avarages
                lengthofserviceint=obj(j,i).ServiceInterval.Duration;
                begserviceint=obj(j,i).ServiceInterval.StartDate;
                endserviceint=obj(j,i).ServiceInterval.EndDate;
                eqinservice=inserviceperformance/(lengthofserviceint-12)*(4*12);
                
                InServicePerformance=[InServicePerformance; inserviceperformance];
                LengthOfServiceInt=[LengthOfServiceInt; lengthofserviceint];
                ServiceIntStart=[ServiceIntStart; begserviceint];
                ServiceIntEnd=[ServiceIntEnd; endserviceint];
                EqInService=[EqInService; eqinservice];
            end
            
            % Dry Docking Performance
            
            if isempty(obj(j,i).DryDockingPerformance)
                %DryDockingPerformance(i,j)=nan;                             % put a NaN values when empty DD performance value
                %drydockingperformance=nan;
                %beforedrydocklevel=nan;
                %afterdrydocklevel=nan;
            else
                %DryDockingPerformance(i,j)=...
                drydockingperformance=...
                    obj(j,i).DryDockingPerformance.AbsDDPerformance;        % DD performance
                beforedrydocklevel=obj(j,i).DryDockingPerformance.AvgPerPrior;
                afterdrydocklevel=obj(j,i).DryDockingPerformance.AvgPerAfter;
                
                DryDockingPerformance=[DryDockingPerformance drydockingperformance];
                DryDockDate=[DryDockDate; obj(j,i).DryDockDates.EndDate];
                BeforeDryDockLevel=[BeforeDryDockLevel; beforedrydocklevel];
                AfterDryDockLevel=[AfterDryDockLevel; afterdrydocklevel];
            end
            
            % Vessel info
            StringVesselNames=[StringVesselNames; Names(i)];
            VesselIMO=[VesselIMO; IMO(i)];
            StringVesselNames=[StringVesselNames; Names(i)];
            StringVesselNames=[StringVesselNames; Names(i)];
            
        end
        
    end
    
    %% Make table columns
    
    if n==1
        
        InServicePerformance_speed=InServicePerformance;
        % InServicePerformance1_speed=InServicePerformance(:,1);                      % Inservice for speed index
        % InServicePerformance2_speed=InServicePerformance(:,2);
        % InServicePerformance3_speed=InServicePerformance(:,3);
        
        DryDockingPerformance_speed=DryDockingPerformance;
        BeforeDryDockLevel_speed=BeforeDryDockLevel;
        AfterDryDockLevel_speed=AfterDryDockLevel;
        % DDPerformance1_speed=DryDockingPerformance(:,1);                            % DD performance for speed index
        % DDPerformance2_speed=DryDockingPerformance(:,2);
        % DDPerformance3_speed=DryDockingPerformance(:,3);
    end
    
    if n==2
        
        InServicePerformance_power=InServicePerformance;
        EqInService_speed=EqInService;
        % InServicePerformance1_power=InServicePerformance(:,1);                      % In service performance for power increase
        % InServicePerformance2_power=InServicePerformance(:,2);
        % InServicePerformance3_power=InServicePerformance(:,3);
        
        DryDockingPerformance_power=DryDockingPerformance;
        EqInService_power=EqInService;
        BeforeDryDockLevel_power=BeforeDryDockLevel;
        AfterDryDockLevel_power=AfterDryDockLevel;
        % DDPerformance1_power=DryDockingPerformance(:,1);                            % DD performance for power increase
        % DDPerformance2_power=DryDockingPerformance(:,2);
        % DDPerformance3_power=DryDockingPerformance(:,3);
    end
    
    VesselNames=char(StringVesselNames);                                                           % Names for table
    
    
end

% reportdata=table(VesselIMO,VesselNames,ServiceIntStart,ServiceIntEnd,LengthOfServiceInt,...
%     InServicePerformance_speed,EqInService_speed,InServicePerformance_power,...
%     EqInService_power,DryDockDate,BeforeDryDockLevel_speed,AfterDryDockLevel_speed,...
%     DDPerformance_speed,DDPerformance_power,BeforeDryDockLevel_power,AfterDryDockLevel_power);




