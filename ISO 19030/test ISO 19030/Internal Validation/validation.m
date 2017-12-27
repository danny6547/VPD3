function [valdata,FilterOutput]=validation(data)

n=10*60*data.ship.f;

rawdata=(data.rawdata);

inliers=ones(size(rawdata));

for i=2:size(rawdata,2)
    if ~ismember(i,data.notuseforChauvenet);
        if ~ismember(i,data.angledata)
            input=table2array((rawdata(:,i)));
            inliers_varX=Chauvenet_general(input,n);
            
            inliers(:,i)=inliers_varX;
            
        end
        
        if ismember(i,data.angledata)
            input=table2array((rawdata(:,i)));
            inliers_varX=Chauvenet_angle(input,n);
        end
            inliers(:,i)=inliers_varX;
    end
end

inlierrows=all(inliers,2);

valdata=rawdata(inlierrows,:);

FilterOutput=inliers(:,1:15);
FilterOutput(:,1)=data.rawdata.date;


end
