function tbl = pivotReportEmpty()
%pivotReportEmpty Return empty table corresponding to pivot report
%   Detailed explanation goes here

names = [...
%         {'Id'                    }
    {'ShipName'              }
    {'IMONo'                 }
    {'CompanyName'           }
    {'DateTime'              }
    {'State'                 }
    {'Latitude'              }
    {'Longitude'             }
    {'GPSSpeed'              }
    {'LogSpeed'              }
    {'MEConsumed'            }
    {'Cargo'                 }
    {'DraftAft'              }
    {'DraftFore'             }
    {'ShaftPower'            }
    {'ShaftRPM'              }
    {'WindSpeedRelative'     }
    {'WindDirectionRelative' }
    {'DGTotalConsumed'       }
    {'BoilerConsumed'        }
    {'DGTotalElectricalPower'}
    {'DG1ElectricalPower'    }
    {'DG2ElectricalPower'    }
    {'DG3ElectricalPower'    }
    {'DG4ElectricalPower'    }
    {'DG5ElectricalPower'    }
    {'DG6ElectricalPower'    }
    {'SeaDepth'              }
    {'VoyageIdInternal'      }
    {'VoyageId'              }];
sample = cell(1, length(names));
char_l = logical([1, 1, 0, 1, 1, 1, false(1, length(names)-6)]);
double_l = ~char_l;
sample(char_l) = {'a'};
sample(double_l) = {1};
tbl = table(sample{:}, 'VariableNames', names);
end