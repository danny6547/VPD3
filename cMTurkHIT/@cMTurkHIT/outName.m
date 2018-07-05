function filename = outName(obj)
%outFileName Return name of output file, if found
%   Detailed explanation goes here

outDir = fullfile(obj.Directory, obj.OutputDirectory);

fileId_ch = [outDir, '\*.csv'];
dir_st = dir(fileId_ch);
csv_c = {dir_st.name};

id_ch = 'batch_results';
batchFile_l = contains(csv_c, id_ch);

if sum(batchFile_l) > 1
    
    errid = 'OutFile:MultipleOutfiles';
    errmsg = 'Multiple batch files have been found in output directory';
    error(errid, errmsg);
end

filename = fullfile(outDir, csv_c{batchFile_l});
end