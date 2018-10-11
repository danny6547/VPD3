function [vars] = departureReportVars()
%departureReportVars Variables found in Marorka Departure Reports
%   Detailed explanation goes here

vars = genvarname([...
    {'Cargo Weight'                }
    {'Cargo Weight (MT)'           }
    {'Cargo Weight [MT]  '         }
    {'Cargo Weight [MT] (MT)'      }
    {'Draft Aft [m] (m)'           }
    {'Draft Forward [m] (m)'       }
    {'Draft [Aft]'                 }
    {'Draft [Aft] (m)'             }
    {'Draft [Fwd]'                 }
    {'Draft [Fwd]      '           }
    {'Draft [Fwd] (m)'             }
    {'HFO on Departure [MT]'       }
    {'LFO on Departure [MT]'       }
    {'MDO on Departure [MT]'       }
    {'MGO on Departure [MT]'       }
    {'Manual Sounding Conducted   '}
    {'Number of Cargo Units'       }
    {'Voyage ID'                   }]);
end