function [outputArg1,outputArg2] = insertPivotsFile(obj, filename)
%insertPivotsFile Insert pivots file into Marorka table
%   Detailed explanation goes here

cv = cVessel('SavedConnection', 'static');
cols_c = [
        {'ShipName'                                             }
        {'IMONo'                                                }
        {'CompanyName'                                                }
        {'Timestamp'                                            }
        {'State'                                            }
        {'Latitude'                                             }
        {'Longitude'                                            }
        {'GPS speed [knots]'                                    }
        {'Log speed [knots]'                                    }
        {'ME consumed [MT]'                                     }
        {'Cargo weight [TEU]'                                   }
        {'Draft aft [m]'                                        }
        {'Draft fore [m]'                                       }
        {'Shaft power [kW]'                                     }
        {'Shaft rpm [rpm]'                                      }
        {'Relative wind speed [m/s]'                            }
        {'Relative wind direction'                              }
        {'DGTotalConsumed'                              }
        {'Boiler consumed [MT]'                                 }
        {'Shaft generator power [kW]'                           }
        {'DG1 Power [kW]'                                       }
        {'DG2 Power [kW]'                                       }
        {'DG3 Power [kW]'                                       }
        {'DG4ElectricalPower'                                   }
        {'DG5ElectricalPower'                                   }
        {'DG6ElectricalPower'                                   }
        {'Sea depth [m]'                                        }];
set_ch = 'SET TimeStamp = STR_TO_DATE(@Timestamp_TXT, ''%Y-%m-%dT%H:%i:%s''), ';
colsNotInTab_c = [...
        {'CompanyName'                                                }
        {'DGTotalConsumed'                              }
        {'DG4ElectricalPower'                                   }
        {'DG5ElectricalPower'                                   }
        {'DG6ElectricalPower'                                   }];
fileCols_c = setdiff(cols_c, colsNotInTab_c);
[~, fileCols_c] = cv.SQL.escapeSQL(fileCols_c);
[~, setNull_ch] = cv.SQL.setNullIfEmpty(fileCols_c, false);
filename = validateCellStr(filename);
for fi = 1:numel(filename)
    
    currFile = filename{fi};
    cv.loadMarorkaRaw(currFile, cols_c, set_ch, setNull_ch);
end