function [data]=iso19030(data)
% ISO19030

if data.run_validation
    [data.valdata,data.FilterOutput]=validation(data);
end

if data.run_windcorrection
    if ~isfield(data,'valdata')
        data.valdata=data.rawdata;
    end
   
    [data.cordata]=windcorrection(data);
end

if data.run_performancevalues;
    if ~isfield(data,'cordata')
        data.cordata=data.rawdata;
    end

    data.trial.coeffs=fittrial(data.trial);

   data=performancevalue(data);
end
%cordata.Vd=Vd;

%refdata=refcondition(cordata,trial,ship);

%idx=idx1 & idx2;

%[VdMean,PdMean]=PI(data(idx,:),data.time(1),data.time(1)+30);
% PI2=PI(data(idx),minDate,maxDate);

end