function [tbl] = loadKyma(obj, dest)
%loadKyma Summary of this function goes here
%   Detailed explanation goes here

isDir_l = exist(dest, 'dir') == 7;

if isDir_l
    
    % Get all files names
    fileExt = '.txt';
    dirSearch = fullfile(dest, ['**', fileExt]);
    filename_st = dirr(dirSearch);
    filename = cellfun(@(x) fullfile(dest, x), {filename_st.name}, 'Uni', 0);
end

if isempty(filename)
    
    return
end

% Generate options for file type
opts = detectImportOptions(filename{1});

var2keep = [...
            {'Date_yyyy_mm_dd_'      }
            {'Time_hh_mm_ss_'        }
            {'DraftAft_m_'           }
            {'DraftFwd_m_'           }
            {'Latitude_Deg_'         }
            {'Longitude_Deg_'        }
            {'ShipCourse_Deg_'       }
            {'ShipSpeedGPS_knot_'    }
            {'ShipSpeedLog_knot_'    }
            {'WindDir_Rel__Deg_'     }
            {'WindSpeedRel__knot_'   }
            {'ShaftPower_kW_'        }
            {'ShaftSpeed_rpm_'       }
            {'ShaftTorque_kNm_'      }
            {'RudderAngle_Deg_'      }
            {'DepthOfWater_m_'       }];
opts = cVesselNoonData.rmVarsFromOpts(opts, var2keep);
tbl = readtable(filename{1}, opts);

for fi = 2:numel(filename)
    
    % Read
    currFile = filename{fi};
    currTbl = readtable(currFile, opts);
    
    % Concatenate table
    tbl = [tbl; currTbl];
end

% Process table
knots2mps = 0.5144444;
tbl.Timestamp = tbl.Date_yyyy_mm_dd_ + tbl.Time_hh_mm_ss_;
tbl.ShipSpeedGPS_knot_ = tbl.ShipSpeedGPS_knot_*knots2mps;
tbl.ShipSpeedLog_knot_ = tbl.ShipSpeedLog_knot_*knots2mps;
tbl.WindSpeedRel__knot_ = tbl.WindSpeedRel__knot_*knots2mps;

% Remove unwanted variables
tbl(:, 1:2) = [];

% Rename variables
oldNames = [...
            {'DraftAft_m_'          }
            {'DraftFwd_m_'           }
            {'Latitude_Deg_'         }
            {'Longitude_Deg_'        }
            {'ShipCourse_Deg_'       }
            {'ShipSpeedGPS_knot_'    }
            {'ShipSpeedLog_knot_'    }
            {'WindDir_Rel__Deg_'     }
            {'WindSpeedRel__knot_'   }
            {'ShaftPower_kW_'        }
            {'ShaftSpeed_rpm_'       }
            {'ShaftTorque_kNm_'      }
            {'RudderAngle_Deg_'      }
            {'DepthOfWater_m_'       }];
newNames = [...
            {'Static_Draught_Fore'        }
            {'Static_Draught_Aft'}
            {'Latitude'     }
            {'Longitude'}
            {'Ship_Heading'}
            {'Speed_Over_Ground'        }
            {'Speed_Through_Water'}
            {'Relative_Wind_Direction'     }
            {'Relative_Wind_Speed'}
            {'Shaft_Power'}
            {'Shaft_Revolutions'}
            {'Shaft_Torque'}
            {'Rudder_Angle'}
            {'Water_Depth'}];
tbl = cVesselNoonData.renameTableVar(tbl, oldNames, newNames);