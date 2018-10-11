function [var] = arrivalReportVars()
%arrivalReportVars Variables found in Marorka Arrival Reports
%   Detailed explanation goes here

var = genvarname([...
        {'HFO on Arrival [MT]'                }
    {'LFO on Arrival [MT]'                }
    {'MDO on Arrival [MT]'                }
    {'MGO on Arrival [MT]'                }
    {'Manual Sounding Conducted   '       }
    {'Port Stay Not For Cargo Operation  '}]);
end