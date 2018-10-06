function [ obj ] = analyse(obj)
%analyse Perform analysis through execution of defined procedures
%   Detailed explanation goes here

% validateattributes(proc, {'struct'}, {}, 'cVesselAnalysis.analyse',...
%     'proc', 2);

for oi = obj
    proc = oi.Procedure;

    % Iterate procedures
    for pi = proc

        func = pi.procedure;
        func = str2func(func);
        input_c = pi.input;
        func(input_c{:});
    end
end