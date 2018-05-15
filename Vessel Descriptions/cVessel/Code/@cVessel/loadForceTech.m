function obj = loadForceTech(obj, filename, varargin)
%loadForceTech Load file downloaded from Force Technologies SeaTrend 
%   Detailed explanation goes here

% Inputs
filename = validateCellStr(filename);

acceptableTables_c = {'forceraw', 'performanceData'};
tab_c = acceptableTables_c;
if nargin > 2
    
    % Tables
    if ~isempty(varargin{1})
        
        tab_c = varargin{1};
        tab_c = validateCellStr(tab_c);
        cellfun(@(x) validatestring(x, acceptableTables_c, 'loadForceTech', ...
            'tab_c', 3), tab_c);
    end
end

% Convert file decimal separator to that of MySQL
replaceCommaWithPoint(filename);

% Load in file
tab = 'forceraw';
cols = [{'name'                                                     }
    {'imo_number'                                               }
    {'filtered'                                                 }
    {'start'                                                    }
    {'xEnd'                                                    }
    {'lat_N'                                                    }
    {'lat_t1'                                                   }
    {'lat_t2'                                                   }
    {'lat_mean'                                                 }
    {'lon_N'                                                    }
    {'lon_t1'                                                   }
    {'lon_t2'                                                   }
    {'lon_mean'                                                 }
    {'sog_N'                                                    }
    {'sog_t1'                                                   }
    {'sog_t2'                                                   }
    {'sog_min'                                                  }
    {'sog_max'                                                  }
    {'sog_mean'                                                 }
    {'sog_std'                                                  }
    {'cog_N'                                                    }
    {'cog_t1'                                                   }
    {'cog_t2'                                                   }
    {'cog_min'                                                  }
    {'cog_max'                                                  }
    {'cog_mean'                                                 }
    {'cog_std'                                                  }
    {'stw_N'                                                    }
    {'stw_t1'                                                   }
    {'stw_t2'                                                   }
    {'stw_min'                                                  }
    {'stw_max'                                                  }
    {'stw_mean'                                                 }
    {'stw_std'                                                  }
    {'hdt_N'                                                    }
    {'hdt_t1'                                                   }
    {'hdt_t2'                                                   }
    {'hdt_min'                                                  }
    {'hdt_max'                                                  }
    {'hdt_mean'                                                 }
    {'hdt_std'                                                  }
    {'wins_N'                                                   }
    {'wins_t1'                                                  }
    {'wins_t2'                                                  }
    {'wins_min'                                                 }
    {'wins_max'                                                 }
    {'wins_mean'                                                }
    {'wins_std'                                                 }
    {'wind_N'                                                   }
    {'wind_t1'                                                  }
    {'wind_t2'                                                  }
    {'wind_min'                                                 }
    {'wind_max'                                                 }
    {'wind_mean'                                                }
    {'wind_std'                                                 }
    {'airt_N'                                                   }
    {'airt_t1'                                                  }
    {'airt_t2'                                                  }
    {'airt_min'                                                 }
    {'airt_max'                                                 }
    {'airt_mean'                                                }
    {'airt_std'                                                 }
    {'airp_N'                                                   }
    {'airp_t1'                                                  }
    {'airp_t2'                                                  }
    {'airp_min'                                                 }
    {'airp_max'                                                 }
    {'airp_mean'                                                }
    {'airp_std'                                                 }
    {'rot_N'                                                    }
    {'rot_t1'                                                   }
    {'rot_t2'                                                   }
    {'rot_min'                                                  }
    {'rot_max'                                                  }
    {'rot_mean'                                                 }
    {'rot_std'                                                  }
    {'rud_N'                                                    }
    {'rud_t1'                                                   }
    {'rud_t2'                                                   }
    {'rud_min'                                                  }
    {'rud_max'                                                  }
    {'rud_mean'                                                 }
    {'rud_std'                                                  }
    {'pitch_N'                                                  }
    {'pitch_t1'                                                 }
    {'pitch_t2'                                                 }
    {'pitch_min'                                                }
    {'pitch_max'                                                }
    {'pitch_mean'                                               }
    {'pitch_std'                                                }
    {'roll_N'                                                   }
    {'roll_t1'                                                  }
    {'roll_t2'                                                  }
    {'roll_min'                                                 }
    {'roll_max'                                                 }
    {'roll_mean'                                                }
    {'roll_std'                                                 }
    {'dpt_N'                                                    }
    {'dpt_t1'                                                   }
    {'dpt_t2'                                                   }
    {'dpt_min'                                                  }
    {'dpt_max'                                                  }
    {'dpt_mean'                                                 }
    {'dpt_std'                                                  }
    {'spow_N'                                                   }
    {'spow_t1'                                                  }
    {'spow_t2'                                                  }
    {'spow_min'                                                 }
    {'spow_max'                                                 }
    {'spow_mean'                                                }
    {'spow_std'                                                 }
    {'srpm_N'                                                   }
    {'srpm_t1'                                                  }
    {'srpm_t2'                                                  }
    {'srpm_min'                                                 }
    {'srpm_max'                                                 }
    {'srpm_mean'                                                }
    {'srpm_std'                                                 }
    {'strq_N'                                                   }
    {'strq_t1'                                                  }
    {'strq_t2'                                                  }
    {'strq_min'                                                 }
    {'strq_max'                                                 }
    {'strq_mean'                                                }
    {'strq_std'                                                 }
    {'sthr_N'                                                   }
    {'sthr_t1'                                                  }
    {'sthr_t2'                                                  }
    {'sthr_min'                                                 }
    {'sthr_max'                                                 }
    {'sthr_mean'                                                }
    {'sthr_std'                                                 }
    {'piid'                                                     }
    {'speed_index_propeller'                                    }
    {'consumption_index_propeller'                              }
    {'speed_index_hull'                                         }
    {'consumption_index_hull'                                   }
    {'speed_index_combined'                                     }
    {'consumption_index_combined'                               }
    {'distance_through_water'                                   }
    {'fuel_oil_consumption_iso_corrected'                       }
    {'shaft_power_estimate'                                     }
    {'shaft_power'                                              }
    {'shaft_thrust'                                             }
    {'shaft_power_estimate_from_rpm00'                          }
    {'advance_ratio_estimate00'                                 }
    {'propeller_torque_coefficient'                             }
    {'propeller_tourque_coefficient_estimate00'                 }
    {'propeller_tourque_coefficient_estimate01'                 }
    {'propeller_thrust_estimate00'                              }
    {'shaft_power_theoretical'                                  }
    {'shaft_power_reference_condition_normalized'               }
    {'shaft_power_estimate_reference_condition_normalized'      }
    {'fuel_oil_consumption_reference_condition_normalized'      }
    {'shaft_power_charter_party_condition_normalized'           }
    {'shaft_power_estimate_charter_party_condition_normalized'  }
    {'charter_party_seaState'                                   }
    {'charter_party_wind'                                       }
    {'fuel_oil_consumption_charter_party_condition_normalized'  }
    {'loading_reference'                                        }
    {'shaft_power_loading_condition_normalized'                 }
    {'shaft_power_estimate_loading_condition_normalized'        }
    {'fuel_oil_consumption_loading_condition_normalized'        }
    {'specific_fuel_oil_consumption_reference'                  }
    {'specific_fuel_oil_consumption_normalized_to_reference_mcr'}
    {'towingresistanceestimate00'                               }
    {'towingresistanceestimate01'                               }
    {'towingresistanceestimate02'                               }
    {'excessresistanceestimate00'                               }
    {'excessresistanceestimate01'                               }
    {'iso19030speedloss'                                        }
    {'consolidateddepth'                                        }
    {'type'                                                     }
    {'average_speed'                                            }
    {'report_start_utc'                                         }
    {'report_end_utc'                                           }
    {'remaining_distance'                                       }
    {'heading'                                                  }
    {'report_lat'                                               }
    {'report_lon'                                               }
    {'draught_aft'                                              }
    {'draught_fore'                                             }
    {'distance_logged'                                          }
    {'distance_observed'                                        }
    {'wind_speed'                                               }
    {'wind_direction'                                           }
    {'air_temperature'                                          }
    {'barometric_pressure'                                      }
    {'sea_state'                                                }
    {'waves_direction'                                          }
    {'min_water_depth'                                          }
    {'water_temperature'                                        }
    {'me_power'                                                 }
    {'me_turbo_charger_rpm'                                     }
    {'propeller_rpm'                                            }
    {'pump_index'                                               }
    {'sg_production'                                            }
    {'cp_propeller_pitch'                                       }
    {'cp_propeller_pitch_unit'                                  }
    {'report_shaft_thrust'                                      }
    {'main_engine_hfo_consumption'                              }
    {'main_engine_hfo_ls_consumption'                           }
    {'main_engine_mdo_consumption'                              }
    {'total_hfo_consumption'                                    }
    {'total_hfo_ls_consumption'                                 }
    {'total_mdo_consumption'                                    }
    {'remaining_hfo'                                            }
    {'remaining_hfo_ls'                                         }
    {'remaining_mdo'                                            }
    {'main_engine_mdo_ls_consumption'                           }
    {'main_engine_mgo_consumption'                              }
    {'main_engine_bio_consumption'                              }
    {'total_mdo_ls_consumption'                                 }
    {'total_mgo_consumption'                                    }
    {'total_bio_consumption'                                    }
    {'remaining_mdo_ls'                                         }
    {'remaining_mgo'                                            }
    {'remaining_bio'                                            }
    {'lower_calorific_value_for_bio'                            }
    {'lower_calorific_value_for_hfo'                            }
    {'lower_calorific_value_for_ls_hfo'                         }
    {'lower_calorific_value_for_ls_mdo'                         }
    {'lower_calorific_value_for_mdo'                            }
    {'lower_calorific_value_for_mgo'                            }
    {'payload'                                                  }
    {'payload_unit'                                             }
    {'voyagename'                                               }
    {'eventid'                                                  }
    {'eventstart'                                               }
    {'eventend'                                                 }
    {'eventname'                                                }];
delimiter_ch = ';';
ignore_ch = 1;
set_ch = [' SET `start` = str_to_date(nullif(@`start`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`xEnd` = str_to_date(nullif(@`xEnd`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`report_end_utc` = str_to_date(nullif(@`report_end_utc`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`report_start_utc` = str_to_date(nullif(@`report_start_utc`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`lat_t1` = str_to_date(nullif(@`lat_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`lat_t2` = str_to_date(nullif(@`lat_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`lon_t1` = str_to_date(nullif(@`lon_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`lon_t2` = str_to_date(nullif(@`lon_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`sog_t1` = str_to_date(nullif(@`sog_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`sog_t2` = str_to_date(nullif(@`sog_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`cog_t1` = str_to_date(nullif(@`cog_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`cog_t2` = str_to_date(nullif(@`cog_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`stw_t1` = str_to_date(nullif(@`stw_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`stw_t2` = str_to_date(nullif(@`stw_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`hdt_t1` = str_to_date(nullif(@`hdt_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`hdt_t2` = str_to_date(nullif(@`hdt_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`wins_t1` = str_to_date(nullif(@`wins_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`wins_t2` = str_to_date(nullif(@`wins_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`airt_t1` = str_to_date(nullif(@`airt_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`airt_t2` = str_to_date(nullif(@`airt_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`airp_t1` = str_to_date(nullif(@`airp_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`airp_t2` = str_to_date(nullif(@`airp_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`rot_t1` = str_to_date(nullif(@`rot_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`rot_t2` = str_to_date(nullif(@`rot_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`rud_t1` = str_to_date(nullif(@`rud_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`rud_t2` = str_to_date(nullif(@`rud_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`pitch_t1` = str_to_date(nullif(@`pitch_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`pitch_t2` = str_to_date(nullif(@`pitch_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`roll_t1` = str_to_date(nullif(@`roll_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`roll_t2` = str_to_date(nullif(@`roll_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`dpt_t1` = str_to_date(nullif(@`dpt_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`dpt_t2` = str_to_date(nullif(@`dpt_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`spow_t1` = str_to_date(nullif(@`spow_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`spow_t2` = str_to_date(nullif(@`spow_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`srpm_t1` = str_to_date(nullif(@`srpm_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`srpm_t2` = str_to_date(nullif(@`srpm_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`strq_t1` = str_to_date(nullif(@`strq_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`strq_t2` = str_to_date(nullif(@`strq_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`sthr_t1` = str_to_date(nullif(@`sthr_t1`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`sthr_t2` = str_to_date(nullif(@`sthr_t2`, ''''), ''%d-%m-%Y %H:%i:%s''), ',...
    '`eventstart` = str_to_date(nullif(@`eventstart`,''''), ''%d-%m-%Y %H:%i:%s''), '...                                                                                 
    '`eventend` = str_to_date(nullif(@`eventend`,''''), ''%d-%m-%Y %H:%i:%s''), '...    
    '`report_start_utc` = str_to_date(nullif(@`report_start_utc`,''''), ''%d-%m-%Y %H:%i:%s''), '...                                                                                 
    '`report_end_utc` = str_to_date(nullif(@`report_end_utc`,''''), ''%d-%m-%Y %H:%i:%s''), '...    
    ];
setnull_c = {...
'`name` = nullif(@`name`,''''),'                                                                                                       
'`imo_number` = nullif(@`imo_number`,''''),'      
'`lat_N` = nullif(@`lat_N`,''''),'                                                                                                       
'`lat_mean` = nullif(@`lat_mean`,''''),'                                                                                                 
'`lon_N` = nullif(@`lon_N`,''''),'                                                                                                       
'`lon_mean` = nullif(@`lon_mean`,''''),'                                                                                                 
'`sog_N` = nullif(@`sog_N`,''''),'                                                                                                       
'`sog_min` = nullif(@`sog_min`,''''),'                                                                                                   
'`sog_max` = nullif(@`sog_max`,''''),'                                                                                                   
'`sog_mean` = nullif(@`sog_mean`,''''),'                                                                                                 
'`sog_std` = nullif(@`sog_std`,''''),'                                                                                                   
'`cog_N` = nullif(@`cog_N`,''''),'                                                                                                       
'`cog_min` = nullif(@`cog_min`,''''),'                                                                                                   
'`cog_max` = nullif(@`cog_max`,''''),'                                                                                                   
'`cog_mean` = nullif(@`cog_mean`,''''),'                                                                                                 
'`cog_std` = nullif(@`cog_std`,''''),'                                                                                                   
'`stw_N` = nullif(@`stw_N`,''''),'
'`stw_min` = nullif(@`stw_min`,''''),'                                                                     
'`stw_max` = nullif(@`stw_max`,''''),'                                                                                                   
'`stw_mean` = nullif(@`stw_mean`,''''),'                                                                                                 
'`stw_std` = nullif(@`stw_std`,''''),'                                                                                                   
'`hdt_N` = nullif(@`hdt_N`,''''),'                                                                                                       
'`hdt_min` = nullif(@`hdt_min`,''''),'                                                                                                   
'`hdt_max` = nullif(@`hdt_max`,''''),'                                                                                                   
'`hdt_mean` = nullif(@`hdt_mean`,''''),'                                                                                                 
'`hdt_std` = nullif(@`hdt_std`,''''),'                                                                                                   
'`wins_N` = nullif(@`wins_N`,''''),'
'`wins_min` = nullif(@`wins_min`,''''),'                                                                 
'`wins_max` = nullif(@`wins_max`,''''),'                                                                                                 
'`wins_mean` = nullif(@`wins_mean`,''''),'                                                                                               
'`wins_std` = nullif(@`wins_std`,''''),'                                                                                                 
'`wind_N` = nullif(@`wind_N`,''''),'
'`wind_min` = nullif(@`wind_min`,''''),'                                                                 
'`wind_max` = nullif(@`wind_max`,''''),'                                                                                                 
'`wind_mean` = nullif(@`wind_mean`,''''),'                                                                                               
'`wind_std` = nullif(@`wind_std`,''''),'                                                                                                 
'`airt_N` = nullif(@`airt_N`,''''),'
'`airt_min` = nullif(@`airt_min`,''''),'                                                                 
'`airt_max` = nullif(@`airt_max`,''''),'                                                                                                 
'`airt_mean` = nullif(@`airt_mean`,''''),'                                                                                               
'`airt_std` = nullif(@`airt_std`,''''),'                                                                                                 
'`airp_N` = nullif(@`airp_N`,''''),'                                                                                                     
'`airp_min` = nullif(@`airp_min`,''''),'                                                                                                 
'`airp_max` = nullif(@`airp_max`,''''),'                                                                                                 
'`airp_mean` = nullif(@`airp_mean`,''''),'                                                                                               
'`airp_std` = nullif(@`airp_std`,''''),'                                                                                                 
'`rot_N` = nullif(@`rot_N`,''''),'
'`rot_min` = nullif(@`rot_min`,''''),'                                                                     
'`rot_max` = nullif(@`rot_max`,''''),'                                                                                                   
'`rot_mean` = nullif(@`rot_mean`,''''),'                                                                                                 
'`rot_std` = nullif(@`rot_std`,''''),'                                                                                                   
'`rud_N` = nullif(@`rud_N`,''''),'
'`rud_min` = nullif(@`rud_min`,''''),'                                                                     
'`rud_max` = nullif(@`rud_max`,''''),'                                                                                                   
'`rud_mean` = nullif(@`rud_mean`,''''),'                                                                                                 
'`rud_std` = nullif(@`rud_std`,''''),'                                                                                                   
'`pitch_N` = nullif(@`pitch_N`,''''),'
'`pitch_min` = nullif(@`pitch_min`,''''),'                                                             
'`pitch_max` = nullif(@`pitch_max`,''''),'                                                                                               
'`pitch_mean` = nullif(@`pitch_mean`,''''),'                                                                                             
'`pitch_std` = nullif(@`pitch_std`,''''),'                                                                                               
'`roll_N` = nullif(@`roll_N`,''''),'
'`roll_min` = nullif(@`roll_min`,''''),'                                                                 
'`roll_max` = nullif(@`roll_max`,''''),'                                                                                                 
'`roll_mean` = nullif(@`roll_mean`,''''),'                                                                                               
'`roll_std` = nullif(@`roll_std`,''''),'                                                                                                 
'`dpt_N` = nullif(@`dpt_N`,''''),'                                                                                                       
'`dpt_min` = nullif(@`dpt_min`,''''),'                                                                                                   
'`dpt_max` = nullif(@`dpt_max`,''''),'                                                                                                   
'`dpt_mean` = nullif(@`dpt_mean`,''''),'                                                                                                 
'`dpt_std` = nullif(@`dpt_std`,''''),'                                                                                                   
'`spow_N` = nullif(@`spow_N`,''''),'                                                                                                     
'`spow_min` = nullif(@`spow_min`,''''),'                                                                                                 
'`spow_max` = nullif(@`spow_max`,''''),'                                                                                                 
'`spow_mean` = nullif(@`spow_mean`,''''),'                                                                                               
'`spow_std` = nullif(@`spow_std`,''''),'                                                                                                 
'`srpm_N` = nullif(@`srpm_N`,''''),'
'`srpm_min` = nullif(@`srpm_min`,''''),'                                                                 
'`srpm_max` = nullif(@`srpm_max`,''''),'                                                                                                 
'`srpm_mean` = nullif(@`srpm_mean`,''''),'                                                                                               
'`srpm_std` = nullif(@`srpm_std`,''''),'                                                                                                 
'`strq_N` = nullif(@`strq_N`,''''),'
'`strq_min` = nullif(@`strq_min`,''''),'                                                                 
'`strq_max` = nullif(@`strq_max`,''''),'                                                                                                 
'`strq_mean` = nullif(@`strq_mean`,''''),'                                                                                               
'`strq_std` = nullif(@`strq_std`,''''),'                                                                                                 
'`sthr_N` = nullif(@`sthr_N`,''''),'
'`sthr_min` = nullif(@`sthr_min`,''''),'                                                                 
'`sthr_max` = nullif(@`sthr_max`,''''),'                                                                                                 
'`sthr_mean` = nullif(@`sthr_mean`,''''),'                                                                                               
'`sthr_std` = nullif(@`sthr_std`,''''),'                                                                                                 
'`piid` = nullif(@`piid`,''''),'                                                                                                         
'`speed_index_propeller` = nullif(@`speed_index_propeller`,''''),'                                                                       
'`consumption_index_propeller` = nullif(@`consumption_index_propeller`,''''),'                                                           
'`speed_index_hull` = nullif(@`speed_index_hull`,''''),'                                                                                 
'`consumption_index_hull` = nullif(@`consumption_index_hull`,''''),'                                                                     
'`speed_index_combined` = nullif(@`speed_index_combined`,''''),'                                                                         
'`consumption_index_combined` = nullif(@`consumption_index_combined`,''''),'                                                             
'`distance_through_water` = nullif(@`distance_through_water`,''''),'                                                                     
'`fuel_oil_consumption_iso_corrected` = nullif(@`fuel_oil_consumption_iso_corrected`,''''),'                                             
'`shaft_power_estimate` = nullif(@`shaft_power_estimate`,''''),'                                                                         
'`shaft_power` = nullif(@`shaft_power`,''''),'                                                                                           
'`shaft_thrust` = nullif(@`shaft_thrust`,''''),'                                                                                         
'`shaft_power_estimate_from_rpm00` = nullif(@`shaft_power_estimate_from_rpm00`,''''),'                                                   
'`advance_ratio_estimate00` = nullif(@`advance_ratio_estimate00`,''''),'                                                                 
'`propeller_torque_coefficient` = nullif(@`propeller_torque_coefficient`,''''),'                                                         
'`propeller_tourque_coefficient_estimate00` = nullif(@`propeller_tourque_coefficient_estimate00`,''''),'                                 
'`propeller_tourque_coefficient_estimate01` = nullif(@`propeller_tourque_coefficient_estimate01`,''''),'                                 
'`propeller_thrust_estimate00` = nullif(@`propeller_thrust_estimate00`,''''),'                                                           
'`shaft_power_theoretical` = nullif(@`shaft_power_theoretical`,''''),'                                                                   
'`shaft_power_reference_condition_normalized` = nullif(@`shaft_power_reference_condition_normalized`,''''),'                             
'`shaft_power_estimate_reference_condition_normalized` = nullif(@`shaft_power_estimate_reference_condition_normalized`,''''),'           
'`fuel_oil_consumption_reference_condition_normalized` = nullif(@`fuel_oil_consumption_reference_condition_normalized`,''''),'           
'`shaft_power_charter_party_condition_normalized` = nullif(@`shaft_power_charter_party_condition_normalized`,''''),'                     
'`shaft_power_estimate_charter_party_condition_normalized` = nullif(@`shaft_power_estimate_charter_party_condition_normalized`,''''),'   
'`charter_party_seaState` = nullif(@`charter_party_seaState`,''''),'                                                                     
'`charter_party_wind` = nullif(@`charter_party_wind`,''''),'                                                                             
'`fuel_oil_consumption_charter_party_condition_normalized` = nullif(@`fuel_oil_consumption_charter_party_condition_normalized`,''''),'   
'`loading_reference` = nullif(@`loading_reference`,''''),'                                                                               
'`shaft_power_loading_condition_normalized` = nullif(@`shaft_power_loading_condition_normalized`,''''),'                                 
'`shaft_power_estimate_loading_condition_normalized` = nullif(@`shaft_power_estimate_loading_condition_normalized`,''''),'               
'`fuel_oil_consumption_loading_condition_normalized` = nullif(@`fuel_oil_consumption_loading_condition_normalized`,''''),'               
'`specific_fuel_oil_consumption_reference` = nullif(@`specific_fuel_oil_consumption_reference`,''''),'                                   
'`specific_fuel_oil_consumption_normalized_to_reference_mcr` = nullif(@`specific_fuel_oil_consumption_normalized_to_reference_mcr`,''''),'
'`towingresistanceestimate00` = nullif(@`towingresistanceestimate00`,''''),'                                                             
'`towingresistanceestimate01` = nullif(@`towingresistanceestimate01`,''''),'                                                             
'`towingresistanceestimate02` = nullif(@`towingresistanceestimate02`,''''),'                                                             
'`excessresistanceestimate00` = nullif(@`excessresistanceestimate00`,''''),'                                                             
'`excessresistanceestimate01` = nullif(@`excessresistanceestimate01`,''''),'                                                             
'`iso19030speedloss` = nullif(@`iso19030speedloss`,''''),'                                                                               
'`consolidateddepth` = nullif(@`consolidateddepth`,''''),'                                                                               
'`type` = nullif(@`type`,''''),'                                                                                                         
'`average_speed` = nullif(@`average_speed`,''''),'                                                                                                                                                                       
'`remaining_distance` = nullif(@`remaining_distance`,''''),'                                                                             
'`heading` = nullif(@`heading`,''''),'                                                                                                   
'`report_lat` = nullif(@`report_lat`,''''),'                                                                                             
'`report_lon` = nullif(@`report_lon`,''''),'                                                                                             
'`draught_aft` = nullif(@`draught_aft`,''''),'                                                                                           
'`draught_fore` = nullif(@`draught_fore`,''''),'                                                                                         
'`distance_logged` = nullif(@`distance_logged`,''''),'                                                                                   
'`distance_observed` = nullif(@`distance_observed`,''''),'                                                                               
'`wind_speed` = nullif(@`wind_speed`,''''),'                                                                                             
'`wind_direction` = nullif(@`wind_direction`,''''),'                                                                                     
'`air_temperature` = nullif(@`air_temperature`,''''),'                                                                                   
'`barometric_pressure` = nullif(@`barometric_pressure`,''''),'                                                                           
'`sea_state` = nullif(@`sea_state`,''''),'                                                                                               
'`waves_direction` = nullif(@`waves_direction`,''''),'                                                                                   
'`min_water_depth` = nullif(@`min_water_depth`,''''),'                                                                                   
'`water_temperature` = nullif(@`water_temperature`,''''),'                                                                               
'`me_power` = nullif(@`me_power`,''''),'                                                                                                 
'`me_turbo_charger_rpm` = nullif(@`me_turbo_charger_rpm`,''''),'                                                                         
'`propeller_rpm` = nullif(@`propeller_rpm`,''''),'                                                                                       
'`pump_index` = nullif(@`pump_index`,''''),'                                                                                             
'`sg_production` = nullif(@`sg_production`,''''),'                                                                                       
'`cp_propeller_pitch` = nullif(@`cp_propeller_pitch`,''''),'                                                                             
'`cp_propeller_pitch_unit` = nullif(@`cp_propeller_pitch_unit`,''''),'                                                                   
'`report_shaft_thrust` = nullif(@`report_shaft_thrust`,''''),'                                                                           
'`main_engine_hfo_consumption` = nullif(@`main_engine_hfo_consumption`,''''),'                                                           
'`main_engine_hfo_ls_consumption` = nullif(@`main_engine_hfo_ls_consumption`,''''),'                                                     
'`main_engine_mdo_consumption` = nullif(@`main_engine_mdo_consumption`,''''),'                                                           
'`total_hfo_consumption` = nullif(@`total_hfo_consumption`,''''),'                                                                       
'`total_hfo_ls_consumption` = nullif(@`total_hfo_ls_consumption`,''''),'                                                                 
'`total_mdo_consumption` = nullif(@`total_mdo_consumption`,''''),'                                                                       
'`remaining_hfo` = nullif(@`remaining_hfo`,''''),'                                                                                       
'`remaining_hfo_ls` = nullif(@`remaining_hfo_ls`,''''),'                                                                                 
'`remaining_mdo` = nullif(@`remaining_mdo`,''''),'                                                                                       
'`main_engine_mdo_ls_consumption` = nullif(@`main_engine_mdo_ls_consumption`,''''),'                                                     
'`main_engine_mgo_consumption` = nullif(@`main_engine_mgo_consumption`,''''),'                                                           
'`main_engine_bio_consumption` = nullif(@`main_engine_bio_consumption`,''''),'                                                           
'`total_mdo_ls_consumption` = nullif(@`total_mdo_ls_consumption`,''''),'                                                                 
'`total_mgo_consumption` = nullif(@`total_mgo_consumption`,''''),'                                                                       
'`total_bio_consumption` = nullif(@`total_bio_consumption`,''''),'                                                                       
'`remaining_mdo_ls` = nullif(@`remaining_mdo_ls`,''''),'                                                                                 
'`remaining_mgo` = nullif(@`remaining_mgo`,''''),'                                                                                       
'`remaining_bio` = nullif(@`remaining_bio`,''''),'                                                                                       
'`lower_calorific_value_for_bio` = nullif(@`lower_calorific_value_for_bio`,''''),'                                                       
'`lower_calorific_value_for_ls_hfo` = nullif(@`lower_calorific_value_for_ls_hfo`,''''),'                                                       
'`lower_calorific_value_for_ls_mdo` = nullif(@`lower_calorific_value_for_ls_mdo`,''''),'                                                       
'`lower_calorific_value_for_mdo` = nullif(@`lower_calorific_value_for_mdo`,''''),'                                                       
'`lower_calorific_value_for_mgo` = nullif(@`lower_calorific_value_for_mgo`,''''),'                                                       
'`payload` = nullif(@`payload`,''''),'                                                       
'`payload_unit` = nullif(@`payload_unit`,''''),'                                                       
'`voyagename` = nullif(@`voyagename`,''''),'                                                       
'`lower_calorific_value_for_hfo` = nullif(@`lower_calorific_value_for_hfo`,'''')'                                                      
    };

obj = obj.loadInFile(filename, tab, cols, delimiter_ch, ignore_ch, set_ch, setnull_c);

    function [success, message] = replaceCommaWithPoint(filename)
        
        filename = validateCellStr(filename);
        szOut = size(filename);
        success = cell(szOut);
        message = cell(szOut);
        
        for fi = 1:numel(filename)
            
            file = filename{fi};
            perlCmd = sprintf('"%s"', fullfile(matlabroot, 'sys\perl\win32\bin\perl'));
            perlstr = sprintf('%s -i.bak -pe"s/%s/%s/g" "%s"', perlCmd, ',',...
                    '.', file);
            [s, msg] = dos(perlstr);
            success{fi} = s;
            message{fi} = msg;
        end
        
        if numel(filename) == 1
            
            success = [success{:}];
            message = [message{:}];
        end
    end
end