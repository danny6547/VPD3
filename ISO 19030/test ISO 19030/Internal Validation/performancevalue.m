function [data]=performancevalue(data)

% PV:
%Vd=zeros(size(data.cordata,1),1);
coeffs=zeros(size(data.trial.coeffs));

for i=1:height(data.cordata)
    [~,I(i)]=min(abs(data.cordata.displacement(i)-data.trial.displacement(:)));
    
   ve1(i)=(data.cordata.power(i)./exp(data.trial.coeffs(2,I(i)))).^(1./data.trial.coeffs(1,I(i)));%  speed of trial curve closest draft actual power
   % ve1=sqrt((data.cordata.power(i)-data.trial.coeffs(I(i),2))/data.trial.coeffs(I(i),1)) 
%coeffs=(data.trial.coeffs(I(i),:));
%coeffs(3)=data.trial.coeffs(I(i),3)-data.cordata.power(i);
%ve_roots=roots(coeffs);
%ve1=ve_roots(find(ve_roots>0));                                             % expected speed trial curve closest draft actual power

Ve(i)=ve1(i).*(data.trial.displacement(I(i))./data.cordata.displacement(i)).^(2/9)                              % expected speed at actual draft
performancevalue(i)=((data.cordata.vw(i)-Ve(i))./Ve(i)).';                                           % speed loss

%Ve=(i)=data.cordata.vw(i).*(data.cordata.displacement(i)./data.trial.displacement(I(i))).^(2/9) % actual (corrected) speed at reference displacement
%performancevalue(i)=(Ve(i)-ve1(ve(i))./ve1(i);
end

 %[~,I(i)]=min(abs((cordata.tm(i)-d_trial(:))./d_trial(:)));
id_disp=(data.cordata.displacement<data.trial.displacement(I).'*1.05 & data.cordata.displacement>data.trial.displacement(I).'*0.95);             % draft within 5% trial range
id_trim=abs((data.cordata.ta-data.cordata.tf)-data.trial.trim(I)')<0.002*data.ship.lpp;                % trim within 0.2% of lpp

data.cordata.PV=performancevalue.';
data.performancedata=data.cordata(all([id_disp,id_trim],2),:);
end