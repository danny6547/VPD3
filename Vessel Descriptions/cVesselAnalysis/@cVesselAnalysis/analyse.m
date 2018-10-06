function [ obj ] = analyse(obj)
%analyse Perform analysis through execution of defined procedures
%   Detailed explanation goes here

% validateattributes(proc, {'struct'}, {}, 'cVesselAnalysis.analyse',...
%     'proc', 2);

for oi = obj
    proc = oi.Procedure;

    % Iterate procedures
    pidx = 1;
    for pi = proc

        func = pi.procedure;
        func = str2func(func);
        input_c = pi.input;
        func(input_c{:});
        obj.report(pi.procedure, pidx, numel(proc));
        pidx = pidx + 1;
    end
end