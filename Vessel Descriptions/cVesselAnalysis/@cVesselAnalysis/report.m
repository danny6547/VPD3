function [ rep ] = report(obj, jobname, jobidx, njob)
%report Report progress of analysis
%   Detailed explanation goes here

% Input

% Generate report string
report_c = {};
report_c{end+1} = '\n';
report_c{end+1} = datestr(now);
report_c{end+1} = ': Analysis progress: %u/%u (%4.2f%%) complete.'; 
report_c{end+1} = ['Procedure ', jobname, ' completed.'];
report_ch = strjoin(report_c, ' ');
jobpc = (jobidx/njob)*100;

% Generate string for output
if nargout > 0
    
    rep = sprintf(report_ch, jobidx, njob, jobpc);
end

% Print to screen if requested
if obj.Report

    terminalIndex = 1;
    fprintf(terminalIndex, report_ch, jobidx, njob, jobpc);
end