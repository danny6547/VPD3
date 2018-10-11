function [ cols, data ] = catNonNullCols(cols, data, vc)
%catNonNullCols Concatenate columns of non-nullable data to insert
%   Detailed explanation goes here

cols = [cols, {'Vessel_Id', 'Vessel_Configuration_Id'}];

vid = vc.Vessel_Id;
vid_c = repmat({vid}, size(data, 1), 1);
vcid = vc.Model_ID;
vcid_c = repmat({vcid}, size(data, 1), 1);
id_c = [vid_c, vcid_c];
data = [data, id_c];

end

