function names = variableNames()
%variableNames Names of variables recorded by Veinland datalogger
%   Detailed explanation goes here

names = [...
        {'AppVersion'                 }
    {'DBStructure'                }
    {'IMONumber'                  }
    {'Sequence'                   }
    {'UTC'                        }
    {'VesselName'                 }
    {'id'                         }
    {'report_date'                }
    {'report_time'                }
    {'voyage_nr'                  }
    {'nautical_miles'             }
    {'position_lat'               }
    {'position_long'              }
    {'gps_speed'                  }
    {'displacement'               }
    {'draft_forw'                 }
    {'draft_aft'                  }
    {'shaft_rpm'                  }
    {'shaft_power'                }
    {'shaft_torque'               }
    {'thrust'                     }
    {'foc_shaft_power'            }
    {'log_speed'                  }
    {'foc_me_actual'              }
    {'foc_ae_actual'              }
    {'foc_me_average'             }
    {'foc_ae_average'             }
    {'fuel_cost'                  }
    {'co2_me_actual'              }
    {'co2_ae_actual'              }
    {'foc_me_24h'                 }
    {'foc_ae_24h'                 }
    {'true_wind_angle_heading'    }
    {'true_wind_speed'            }
    {'true_wind_speed_unit'       }
    {'rel_wind_angle_heading'     }
    {'rel_wind_speed'             }
    {'wind_speed_unit'            }
    {'report_status'              }
    {'fld_upd'                    }
    {'imo_number'                 }
    {'gmt_offset'                 }
    {'voyage_number'              }
    {'time_at_operat'             }
    {'speed_order'                }
    {'rudder_angle'               }
    {'actual_heel_angle'          }
    {'roll_period'                }
    {'roll_amplitude_port'        }
    {'roll_amplitude_stbd'        }
    {'roll_peak_hold_value_stbd'  }
    {'peak_hold_value_reset_time' }
    {'peak_hold_value_reset_day'  }
    {'peak_hold_value_reset_month'}
    {'roll_alarm_threshold'       }
    {'roll_peak_hold_value_port'  }
    {'heading_course'             }
    {'water_depth'                }
    {'air_temperature'            }
    {'air_pressure'               }
    {'temperature_me_IN'          }
    {'wind_angle_heading'         }
    {'wind_reference'             }
    {'flowcounter_me_in'          }
    {'foc_me_'                    }
    {'density_me_in'              }
    {'lcvalue_me_in'              }
    {'trim'                       }
    {'dcrate_me_in'               }
    {'seawater_temperature'       }
    {'vessel_gps_course'          }
    {'foc_boiler_actual'          }
    {'foc_boiler_average'         }
    {'rudder_angle_port'          }
    {'SLIP'                       }
    {'foc_ae1_in'                 }
    {'foc_ae2_in'                 }];
otherNamesFoundInFiles = [...
    {'seawater_temp'       }
    {'depth'               }
    {'draft_fwd'           }
    {'dcrate_ae1_in'       }
    {'dcrate_ae2_in'       }
    {'density_ae1_in'      }
    {'density_ae2_in'      }
    {'flowcounter_ae1_in'  }
    {'flowcounter_ae2_in'  }
    {'lcvalue_ae1_in'      }
    {'lcvalue_ae2_in'      }
    {'lcvalue_me'          }
    {'temperature_ae1_in'  }
    {'temperature_ae2_in'  }];
names = [names; otherNamesFoundInFiles]';
end