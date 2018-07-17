function [obj] = correctDisplacement(obj, base, corr)
%correctDisplacement Correct displacement at draft with that for each trim
%   Detailed explanation goes here

% Perform correction for corresponding drafts
base_tbl = base.FilteredData;
corr_tbl = corr.FilteredData;

% Convert displacement correction vector to matrix
d_v = unique(corr_tbl.Draft);
t_v = unique(corr_tbl.Trim);
nd = numel(d_v);
nt = numel(t_v);
dispCorrection_m = nan(nd, nt);
[~, t_i] = ismember(corr_tbl.Trim, t_v);
[~, d_i] = ismember(corr_tbl.Draft, d_v);
dispCorrection_m(sub2ind(size(dispCorrection_m), d_i, t_i)) = corr_tbl.Displacement;

% Sort base displacement vector to same order as correction matrix
baseDraft_l = ismember(base_tbl.Draft, d_v);
base_tbl = base_tbl(baseDraft_l, :);
[baseDraft_v, sortDraft_i] = sort(base_tbl.Draft);
baseDisp_v = base_tbl.Displacement(sortDraft_i);
[ml, mi] = ismember(d_v, baseDraft_v);

% Apply Correction
dispCorrected_m = baseDisp_v + dispCorrection_m(mi(ml), :);

% Assiign into output table
nd = numel(baseDraft_v);
d_m = repmat(baseDraft_v(:), 1, nt);
t_m = repmat(t_v(:)', nd, 1);
corr_tbl = table(d_m(:), t_m(:), dispCorrected_m(:), ...
    'VariableNames', {'Draft', 'Trim', 'Displacement'});
obj.FilteredData = corr_tbl;
obj.FileData = corr_tbl;
obj.IsGrid = true;
end