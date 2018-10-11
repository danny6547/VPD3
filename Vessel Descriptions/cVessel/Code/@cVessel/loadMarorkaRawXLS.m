function [obj, numWarnings, warnings] = loadMarorkaRawXLS(obj, filename, varargin)
%loadMarorkaRawXLS Load raw data from Marorka XLS file
%   Detailed explanation goes here

filename = validateCellStr(filename, 'loadEuronav', 'filename', 2);

for fi = 1:numel(filename)
    
    currFile = filename{fi};
    
    p = inputParser();
    p.addParameter('firstRowIdx', 2);
    p.addParameter('fileColID', [2, 3, 4, 5, 6, 7, 8, 10, 12, 13, ...
        14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25]);
    p.addParameter('tab', 'tempMarorkaRaw');
    p.addParameter('fileColName', [...
                                {'ShipName'                    }
                                {'IMONo'                       }
                                {'Timestamp'                   }
                                {'Latitude'                    }
                                {'Longitude'                   }
                                {'State'                       }
                                {'Boiler consumed [MT]'        }
                                {'ME consumed [MT]'            }
                                {'Shaft power [kW]'            }
                                {'Shaft rpm [rpm]'             }
                                {'Draft fore [m]'              }
                                {'Draft aft [m]'               }
                                {'Relative wind speed [m/s]'   }
                                {'Relative wind direction'}
                                {'COG heading'            }
                                {'GPS speed [knots]'           }
                                {'Log speed [knots]'           }
                                {'Sea depth [m]'    }
                                {'DG1 Power [kW]'              }
                                {'DG2 Power [kW]'              }
                                {'DG3 Power [kW]'              }
                               ]);
    p.addParameter('SetSQL', ...
        {['DateTime_UTC = nullif(STR_TO_DATE(@Timestamp, '...
        '''%d-%m-%Y %H:%i:%s''), ''0000-00-00 00:00:00.000'')']});
    paramValues_c = varargin;
    p.parse(paramValues_c{:});
    firstRowIdx = p.Results.firstRowIdx;
    fileColID = p.Results.fileColID;
    tab = p.Results.tab;
    fileColName = p.Results.fileColName;
    SetSQL = p.Results.SetSQL;
    
    % Call create temp table proc
    obj.SQL.call('createTempMarorkaRaw');
    
    % Load time-seres data from xlsx
    currSheet = 1;
    [obj, numWarnings, warnings] = obj.loadXLSX(currFile, currSheet, ...
        firstRowIdx, fileColID, fileColName, tab, SetSQL);
    
    % Update/insert into final table
    obj.SQL.call('insertFromMarorkaRawIntoRaw');
    
    % Drop the temp
    obj.SQL.drop('TABLE', tab);
end