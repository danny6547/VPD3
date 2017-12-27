function [inlier]=Chauvenet_angle(input,n)
% data in table format 
% n number of points to average over

%for i=validationvariables                                                   % run through relevant columns
% nanlogical=isnan(data);                              % logical for nan-values
% notnanlogical=not(nanlogical);                                    % logical for not-nan-values
% %end
% notnancolumns=find(any(notnanlogical,2));                                   % indices for not-nan-points 

N=size(input,1)/n;

delta=zeros(size(input,1),1);
probability=zeros(size(input,1),1);

for i=1:N                            

    arg1=sum(sin((input((i-1)*n+1:i*n))))/n;
    arg2=sum(cos((input((i-1)*n+1:i*n))))/n;
    meanvalue_rad(i)=atan2(arg1,arg2);                
    meanvalue_deg(i)=(meanvalue_rad(i));
    ri=mod(abs(input((i-1)*n+1:i*n)-meanvalue_deg(i)),360);
 
    if ri>180
        
    delta((i-1)*n+1:i*n)=360-ri;  
    
    else
            delta((i-1)*n+1:i*n)=ri;  
    end


    std(i)=sqrt((1/n)*sum((delta((i-1)*n+1:i*n)).^2));                                         % standart deviation of mean

    probability((i-1)*n+1:i*n)=erfc(delta((i-1)*n+1:i*n)./(std(i).*sqrt(2)));                               % probability of value 

end


%outlierlogical(i*60:i*60+60-1,j)=probability<1/(0.005*N);
%inliers=a(inliersindex);

%outliers(:,j)=outlierlogical;
%end
inlier=(probability>1/(2*N));

assignin('base','probability',probability)

end

