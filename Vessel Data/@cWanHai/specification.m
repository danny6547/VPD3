function [spec, timeName] = specification(freq, type)
%highSpecification Specification of high frequency data for given type
%   First var is time

switch freq
    
    case 'high'

        switch type

            case 1

                timeName = 'Log_Date';
                spec1 = [...
                            {'Longitude_Name'               }
                            {'Longitude_Deg'                }
                            {'Longitude_Min'                }
                            {'Latitude_Name'                }
                            {'Latitude_Deg'                 }
                            {'Latitude_Min'                 }
                            {'Ship_Heading'      }
                            {'Ship_Speed'        }
                            {'True_Wind_Speed'        }
                            {'True_Wind_Direction'    }
                            {'Shaft_Revolutions' }
                            {'Shaft_Torque'      }
                            {'Shaft_Power'       }];

                spec2 = [...
                            {''    }
                            {''   }
                            {''   }
                            {''     }
                            {''    }
                            {''    }
                            {'Ship_Heading'      }
                            {'Speed_Over_Ground'        }
                            {''        }
                            {''    }
                            {'Shaft_Revolutions' }
                            {'Shaft_Torque'      }
                            {'Shaft_Power'       }];
                spec = [spec1, spec2];

            case 2

                timeName = 'Log_Date';
                spec1 = [...
                            {'Latitude_Name'                }
                            {'Latitude_Deg'                 }
                            {'Latitude_Min'                 }
                            {'Longitude_Name'               }
                            {'Longitude_Deg'                }
                            {'Longitude_Min'                }
                            {'Heading'                      }
                            {'Speed_Over_Ground'            }
                            {'Current_Speed'                }
                            {'Current_Direction'            }
                            {'True_Wind_Speed'              }
                            {'True_Wind_Direction'          }
                            {'Shaft_Revolutions'            }
                            {'Shaft_Torque'                 }
                            {'Shaft_Power'                  }
                            {'Rudder1_Angle'                }
                            {'Fuel_Me_Total_Tons10min'      }
                            {'Fuel_Temp_Me'                 }];
                spec2 = [...
                            {''                }
                            {''                 }
                            {''                 }
                            {''               }
                            {''                }
                            {''                }
                            {'Ship_Heading'                 }
                            {'Speed_Over_Ground'            }
                            {''                }
                            {''            }
                            {''              }
                            {''          }
                            {'Shaft_Revolutions'            }
                            {'Shaft_Torque'                 }
                            {'Shaft_Power'                  }
                            {'Rudder_Angle'                }
                            {'Mass_Consumed_Fuel_Oil'      }
                            {'Temp_Fuel_Oil_At_Flow_Meter' }];
                spec = [spec1, spec2];
        end
    
    case 'noon'
        
        switch type

            case 1

                timeName = 'log_date';
                spec = [...
                            {'Draftf'                        }, {'Static_Draught_Fore'        }
                            {'Drafta'                        }, {'Static_Draught_Aft'         }];
            case 2

                timeName = 'LOG_DATE';
                spec = [...
                            {'DRAFTF'                        }, {'Static_Draught_Fore'        }
                            {'DRAFTA'                        }, {'Static_Draught_Aft'         }];
        end
end