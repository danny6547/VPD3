function [obj] = correctDisplacement(obj, base, corr)
%correctDisplacement Correct displacement at draft with that for each trim
%   Detailed explanation goes here

% Perform correction for corresponding drafts
base_tbl = base.FilteredData;
corr_tbl = corr.FilteredData;
[baseDraft_l, baseDraft_i] = ismember(corr_tbl.Draft, base_tbl.Draft);
corr_tbl(baseDraft_l, :) = [];
corr_tbl = corr_tbl(baseDraft_i, :);

% Convert displacement correction vector to matrix
d_v = unique(corr_tbl.Draft);
t_v = unique(corr_tbl.Trim);
nd = numel(d_v);
nt = numel(t_v);
dispCorrection_m = nan(nd, nt);
[~, t_i] = ismember(corr_tbl.Draft, t_v);
[~, d_i] = ismember(corr_tbl.Trim, d_v);
dispCorrection_m(sub2ind(size(disp_m), d_i, t_i)) = corr_tbl.Displacement;

% Correct
dispCorrected_m = base_tbl.Draft + dispCorrection_m;

% Assiign into output table
corr_tbl.Displacement = dispCorrected_m(:);
obj.FilteredData = corr_tbl;

end