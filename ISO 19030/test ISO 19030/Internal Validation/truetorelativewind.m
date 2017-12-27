function [wv,wd,wb,wh,wl]=truetorelativewind(wvtrue,wdtrue,vg,cog)
    % vwtrue: true wind speed IN KNOTS
    % wdtrue: true wind direction
    % vg: speed over ground
    % cog: course over ground
    % wv: relative wind speed in knots
    % wd: relative wind direction
    % wb: Beaufort
    % wh: wave height
    % wl: wave length
    
    wvx=wvtrue.*cos((wdtrue-cog)*pi/180);
    wvy=wvtrue.*sin((wdtrue-cog)*pi/180);

    wv=sqrt((wvx+vg).^2+wvy.^2);
%     wv = [...
%             24.06095
%             20.50705
%             17.74327
%             21.02010
%             16.88530
%             17.73556
%             7.50960
%             33.58888
%             51.35721
%             3.01855
%             37.60607
%             53.29761
%             14.93662
%             7.10603
%             8.05378
%             3.31977
%             31.23481
%             19.59605
%             35.24298
%             33.67161
%             1.06717
%             6.75855
%             44.84919
%             20.41923
%             30.69261
%             4.72421
%             15.44263
%             16.38959
%             3.50285
%             5.02465
%             66.00358
%             8.85885];
    wd=mod(atan2(wvy,wvx+vg)+2*pi,2*pi)*180/pi;
    
    wb=(wvtrue/1.9).^(1/1.433);
    wh=0.065*wb.^2.13;
    wl=11*wh.^1.24;
    
    if wv==0 & wd==0
        wb=0;
        wdtrue=0;
        wh=0;
        wl=0;
    end

end