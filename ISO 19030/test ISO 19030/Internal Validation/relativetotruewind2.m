function [wvtrue,wdtrue,wh,wl]=relativetotruewind2(wv,wd,vg,course)
%% SEE relativetotruewind, instead. Discontinued... nsl 10.2016

    wvx=wv.*cos(wd/180*pi)-vg;
    wvy=wv.*sin(wd/180*pi);
    
    wvtrue=sqrt(wvx.^2+wvy.^2);
    wdtrue=mod(atan2(wvy,wvx)*180/pi+course+360,360); 
    
    wb=(wvtrue/1.9).^(1/1.433);
    wh=0.065*wb.^2.13;
    wl=11*wh.^1.24;
    
    if wv==0 & wd==0
        wb=0;
        wdtrue=0;
        wh=0;
        wl=0;
    end
    
    %wsms=wvtrue*.51444;

end