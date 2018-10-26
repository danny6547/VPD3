function vars = fileVarsHigh(type)
%fileVarsHigh Summary of this function goes here
%   Detailed explanation goes here

if type == 1
    
    vars = [...
                {'Log_Date'}
                {'Longitude_Type'    }
                {'Longitude_Col01'   }
                {'Longitude_Col02'   }
                {'Latitude_Type'     }
                {'Latitude_Col01'    }
                {'Latitude_Col02'    }
                {'Ship_Heading'      }
                {'Ship_Speed'        }
                {'Wind_Speed'        }
                {'Wind_Direction'    }
                {'Shaft_Revolutions' }
                {'Shaft_Torque'      }
                {'Shaft_Power'       }];
elseif type == 2
    
    vars = cWanHai.varFromSpec('high', type);
end

