function tbl = loadHigh(file, type)
%loadHigh Return timetable of high-freq data from file name and spec type
%   Detailed explanation goes here

% Read file
opts = detectImportOptions(file);
% var = cWanHai.varFromSpec('high', type);
var = cWanHai.fileVarsHigh(type);
opts = cVesselNoonData.rmVarsFromOpts(opts, var);
tbl = readtable(file, opts);

tbl = table2timetable(tbl);

% Standardise table
tbl = cWanHai.standardiseTable(tbl, 'high', type);

% Standardise variables from different spec type which are non-standard
if type == 1

    oldNames = [...
                {'Longitude_Type'    }
                {'Longitude_Col01'   }
                {'Longitude_Col02'   }
                {'Latitude_Type'     }
                {'Latitude_Col01'    }
                {'Latitude_Col02'    }
                {'Wind_Speed'        }
                {'Wind_Direction'    }];
    newNames = [...
                {'Longitude_Name'               }
                {'Longitude_Deg'                }
                {'Longitude_Min'                }
                {'Latitude_Name'                }
                {'Latitude_Deg'                 }
                {'Latitude_Min'                 }
                {'True_Wind_Speed'        }
                {'True_Wind_Direction'    }];
    tbl = cVesselNoonData.renameTableVar(tbl, oldNames, newNames);
end