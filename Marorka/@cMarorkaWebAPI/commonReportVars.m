function [vars] = commonReportVars()
%commonReportVars Variables common to all reports
%   Detailed explanation goes here

vars = genvarname([{'StartDateTimeGMT'   }
                {'EndDateTimeGMT'   }
                {'IMONo'   }
                {'ReportId'   }]);
end

