function [ obj ] = loadMarorkaRaw( obj, filename, varargin )
%loadMarorka Load data from Marorka file into table RawData
%   Detailed explanation goes here

% Default
cols_c = [
    {'ShipName'                                             }
    {'IMONo'                                                }
    {'Timestamp'                                            }
    {'Latitude'                                             }
    {'Longitude'                                            }
    {'State'                                                }
    {'Boiler consumed [MT]'                                 }
    {'Aux consumed [MT]'                                    }
    {'ME consumed [MT]'                                     }
    {'Aux electrical power output [kW]'                     }
    {'Shaft power [kW]'                                     }
    {'Shaft rpm [rpm]'                                      }
    {'Draft fore [m]'                                       }
    {'Draft aft [m]'                                        }
    {'Relative wind speed [m/s]'                            }
    {'Relative wind direction'                              }
    {'COG heading'                                          }
    {'GPS speed [knots]'                                    }
    {'Log speed [knots]'                                    }
    {'Shaft generator power [kW]'                           }
    {'Sea depth [m]'                                        }
    {'DG1 Power [kW]'                                       }
    {'DG2 Power [kW]'                                       }
    {'DG3 Power [kW]'                                       }
    {'Propeller Pitch [m]'                                  }
    {'Cargo weight [TEU]'                                   }
    {'Shaft Torque [kNm]'                                   }
    {'M.C.S.W_PRESS []'                                     }
    {'SGM_ACTUAL_ACTIVE_POWER_ABSOLUTE []'                  }
    {'WHR - SM nominal electrical power [kW]'               }
    {'WHR - SG nominal electrical power []'                 }
    {'SGM_MACHINE_POWER []'                                 }
    {'WHR - SCM electrical power []'                        }
    {'ME_EXH_GAS_RECEIVER_PRESSURE []'                      }
    {'ME_EXH_GAS_PRESS_AT_TURBO_CHARGER_IN []'              }
    {'WHR - HP SH steam mass flow []'                       }
    {'WHR - HP SH steam temperature []'                     }
    {'WHR - HP SH steam pressure []'                        }
    {'WHR - HP FW pressure []'                              }
    {'WHR - LP circ. pump water-steam mass flow []'         }
    {'WHR - LP FW temperature []'                           }
    {'WHR - LP SH steam temperature []'                     }
    {'WHR - LP SH steam pressure []'                        }
    {'PERFORMACE_LEVEL_HP_SECTION []'                       }
    {'PERFORMACE_LEVEL_LP_SECTION []'                       }
    {'WHR - ME exhaust gas mass flow calculated []'         }
    {'WHR - LP EVA water-steam pressure []'                 }
    {'WHR - HP ST steam inlet pressure []'                  }
    {'WHR - LP ST steam inlet pressure []'                  }
    {'WHR - ST HP steam inlet temperature []'               }
    {'WHR - ST LP steam inlet temperature []'               }
    {'WHR - HP bypass steam inlet temperature []'           }
    {'WHR - HP steam available power []'                    }
    {'WHR - Power turbine available power []'               }
    {'WHR - ST speed []'                                    }
    {'WHR - ST steam nozzle pressure []'                    }
    {'WHR - Turbogenerator electrical power [kW]'           }
    {'WHR - Turbogenerator nominal electrical power []'     }
    {'WHR - HP circ. pump water-steam mass flow []'         }
    {'WHR - Boiler HP exhaust gas pressure drop []'         }
    {'WHR - HP SH steam inlet temperature []'               }
    {'WHR - Boiler HP exhaust gas pressure drop expected []'}
    {'WHR - Boiler LP exhaust gas pressure drop []'         }
    {'WHR - Boiler LP exhaust gas pressure drop expected []'}
    {'WHR - LP bypass valve outlet temperature []'          }
    {'WHR - LP bypass dump tube pressure []'                }
    {'WHR - HP bypass valve outlet temperature []'          }
    {'WHR - HP steam bypass dump tube pressure []'          }
    {'WHR - Boiler LP pressure []'                          }
    {'WHR - Boiler HP pressure []'                          }
    {'WHR - ST HP inlet valve position []'                  }
    {'WHR - ST LP inlet valve position []'                  }
    {'WHR - LP bypass steam inlet temperature []'           }
    {'WHR - HP ST steam dump valve available power []'      }
    {'WHR - HP steam dump valve position []'                }
    {'WHR - LP steam dump valve position []'                }
    {'Trim recommendation max [m]'                          }
    {'Trim recommendation min [m]'                          }
    {'Trim potential savings [%]'                           }
    {'ME load [%]'                                          }
    {'Trim recommendation [m]'                              }
    {'GPS speed recommendation [knots]'                     }
    {'GPS speed recommendation min [knots]'                 }
    {'GPS speed recommendation max [knots]'                 }
    {'Shaft RPM recommendation [rpm]'                       }
    {'Shaft RPM recommendation min [rpm]'                   }
    {'Shaft RPM recommendation max [rpm]'                   }
    {'DG recommendation [num]'                              }
    {'DG potential savings [%]'                             }
    {'WHR Turbine Generator [kW]'                           }
    {'DG Group 1 No. Running Actual [-]'                    }
    {'DG Group 1 No. Running Recommended [-]'               }
    {'DG Potential Savings [%]'                             }
    {'ME Power [KW]'                                        }];

% Input
p = inputParser();
p.addParameter('set', 'SET DateTime_UTC = STR_TO_DATE(@TimeStamp, ''%d.%m.%Y %H:%i'')',...
    @ischar);
p.addParameter('cols', cols_c, @iscell);
p.addParameter('setCols2Skip', {''}, @iscell);
p.parse(varargin{:});
res = p.Results;
set_s = res.set;
cols_c = res.cols;
setColsSkip_c = res.setCols2Skip;

% Call create temp table proc
obj = obj.call('createTempMarorkaRaw');

% Load into temp (convert time)
tempTab = 'tempMarorkaRaw';

delimiter_s = ',';
ignore_s = 1;
% set_s = 'SET DateTime_UTC = STR_TO_DATE(@TimeStamp, ''%d.%m.%Y %H:%i'')';
setnull_c = 'all';
[obj] = obj.loadInFile(filename, tempTab, cols_c, delimiter_s, ignore_s, ...
    set_s, setnull_c, '', setColsSkip_c);

% Update/insert into final table
obj = obj.call('insertFromMarorkaRawIntoRaw');

% Drop the temp
obj = obj.drop('TABLE', tempTab);

% Return IMO if requested

end