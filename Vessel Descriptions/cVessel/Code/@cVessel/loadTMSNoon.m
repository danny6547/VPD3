function [obj, numWarnings, warnings] = loadTMSNoon(obj, filename, varargin)
%loadTMSNoon Load noon data sent by TMS
%   Detailed explanation goes here

filename = validateCellStr(filename, 'loadTMSNoon', 'filename', 2);

for fi = 1:numel(filename)
    
    currFile = filename{fi};
    p = inputParser();
    p.addParameter('firstRowIdx', 1);
    p.addParameter('fileColID', [2, 11, 12, 15, 16, 27, 28, 45, 24, 8, 9, 10]);
    p.addParameter('tab', 'RawData');
    p.addParameter('fileColName', {  ...
                    'telegram_date',...
                    'Relative_Wind_Direction',...
                    'Relative_Wind_Speed',...
                    'Ship_Heading',...
                    'Shaft_Revolutions',...
                    'Static_Draught_Fore',      ...
                    'Static_Draught_Aft',        ...
                    'Mass_Consumed_Fuel_Oil',        ...
                    'Delivered_Power',        ...
                    'miles_slc',        ...
                    'hours_slc',        ...
                    'minutes_slc'
                               });
    p.addParameter('SetSQL', ...
                {'Timestamp = STR_TO_DATE(@telegram_date, ''%d/%m/%Y %H:%i:%s'')',...
                ['Relative_Wind_Speed = CASE '...
                    'WHEN @Relative_Wind_Speed = '''' THEN NULL ',...
                    'WHEN @Relative_Wind_Speed = 0 THEN 0.1500 ',...
                    'WHEN @Relative_Wind_Speed = 1 THEN 0.9 ',...
                    'WHEN @Relative_Wind_Speed = 2 THEN 2.45 ',...
                    'WHEN @Relative_Wind_Speed = 3 THEN 4.45 ',...
                    'WHEN @Relative_Wind_Speed = 4 THEN 6.7 ',...
                    'WHEN @Relative_Wind_Speed = 5 THEN 9.35 ',...
                    'WHEN @Relative_Wind_Speed = 6 THEN 12.3 ',...
                    'WHEN @Relative_Wind_Speed = 7 THEN 15.5 ',...
                    'WHEN @Relative_Wind_Speed = 8 THEN 18.95 ',...
                    'WHEN @Relative_Wind_Speed = 9 THEN 22.6 ',...
                    'WHEN @Relative_Wind_Speed = 10 THEN 26.45 ',...
                    'WHEN @Relative_Wind_Speed = 11 THEN 30.55 ',...
                    'WHEN @Relative_Wind_Speed = 12 THEN 34.7 ',...
                    'WHEN CONCAT('''',@Relative_Wind_Speed * 1) = @Relative_Wind_Speed THEN @Relative_Wind_Speed ',...
                    'END'],...
                'Speed_Over_Ground = knots2mps(@miles_slc/(@hours_slc + (@minutes_slc/60)))'...
                'Delivered_Power = @Delivered_Power*144'... % MCR = 14,400kW 
                });
    paramValues_c = varargin;
    p.parse(paramValues_c{:});
    firstRowIdx = p.Results.firstRowIdx;
    fileColID = p.Results.fileColID;
    tab = p.Results.tab;
    fileColName = p.Results.fileColName;
    SetSQL = p.Results.SetSQL;

%     % Load time-seres data from xlsx
%     currSheet = 1;
%     [obj, numWarnings, warnings] = obj.loadXLSX(currFile, currSheet, firstRowIdx, fileColID, fileColName, tab, SetSQL);
    
    % Assign input column names into all names from file
    allNames = [...
                    {'vessel_code'       }
                    {'telegram_date'     }
                    {'telegram_type'     }
                    {'port_name'         }
                    {'fo_rob'            }
                    {'do_rob'            }
                    {'gas_oil_rob'       }
                    {'miles_slc'         }
                    {'hours_slc'         }
                    {'minutes_slc'       }
                    {'wind_direction'    }
                    {'wind_force'        }
                    {'current_direction' }
                    {'current_speed'     }
                    {'vessel_course'     }
                    {'engine_rpm'        }
                    {'longitude_degrees' }
                    {'longitude_seconds' }
                    {'longitude_n_s'     }
                    {'latitude_degrees'  }
                    {'latitude_seconds'  }
                    {'latitude_e_w'      }
                    {'propeller_pitch'   }
                    {'me_load_ind'       }
                    {'tc_rpm'            }
                    {'me_scav_air_pres'  }
                    {'draft_fore'        }
                    {'draft_aft'         }
                    {'cargo_type'        }
                    {'supplied_fo'       }
                    {'supplied_do'       }
                    {'supplied_gas_oil'  }
                    {'supplied_co'       }
                    {'supplied_so'       }
                    {'supplied_go'       }
                    {'lsfo_rob'          }
                    {'lsdo_rob'          }
                    {'supplied_lsfo'     }
                    {'supplied_lsdo'     }
                    {'maneuvering_time'  }
                    {'port_static_time'  }
                    {'vessel_name'       }
                    {'balast_flag'       }
                    {'propeller_pitch'   }
                    {'me_hsfo_cons'      }
                    {'me_lsfo_cons'      }
                    {'me_hsdo_cons'      }
                    {'me_lsdo_cons'      }
                    {'ae_hsfo_cons'      }
                    {'ae_lsfo_cons'      }
                    {'ae_hsdo_cons'      }
                    {'ae_lsdo_cons'      }
                    {'boiler_hsfo_cons'  }
                    {'boiler_lsfo_cons'  }
                    {'boiler_hsdo_cons'  }
                    {'boiler_lsdo_cons'  }
                    {'supplied_hsfo_rob' }
                    {'supplied_hsdo_rob' }
                    {'boiler_cons_fo'    }
                    {'losses_sys'        }
                    {'boiler_cons_do'    }
                    {'losses_ifo'        }
                    {'anchor_me_fo'      }
                    {'anchor_me_lsfo'    }
                    {'anchor_me_do'      }
                    {'anchor_me_lsdo'    }
                    {'anchor_dg_fo'      }
                    {'anchor_dg_lsfo'    }
                    {'anchor_dg_do'      }
                    {'anchor_dg_lsdo'    }
                    {'anchor_boiler_fo'  }
                    {'anchor_boiler_lsfo'}
                    {'anchor_boiler_do'  }
                    {'anchor_boiler_lsdo'}
                                            ];
    colName = allNames;
    colName(fileColID) = fileColName;

    % 
    delimiter_s = ',';
    ignore = 1;
    setnullCols_c = setdiff(fileColName, ...
                                {'telegram_date',        ...
                                'Relative_Wind_Speed',        ...
                                'Delivered_Power',...
                                'miles_slc',        ...
                                'hours_slc',        ...
                                'minutes_slc'        ...
                                            });
    [~, setnullif_ch] = obj.SQL.setNullIfEmpty(setnullCols_c, false);
    vid_ch = num2str(obj.Vessel_Id);
    [~, SetSQL] = obj.SQL.combineSQL('SET Vessel_Id =', vid_ch, ',', strjoin(SetSQL, ','), ',');
    [obj.SQL] = obj.SQL.loadInFile(currFile, tab, colName, delimiter_s, ignore, ...
        SetSQL, setnullif_ch);
end