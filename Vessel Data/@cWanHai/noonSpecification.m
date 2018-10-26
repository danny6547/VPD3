function [spec, timeName] = noonSpecification(type)
%noonSpecification Specification of noon report for given type
%   First var is time

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