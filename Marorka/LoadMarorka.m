% Create list of files
topDir_ch = 'C:\Users\damcl\Documents\Ship Data\UASC';
vNames_c = {'Ain_Snan', 'Al_Bahia', 'Al_Hilal', 'Al_Kharj',...
    'Al_Manamah', 'Al_Qibla', 'Al_Rawdah', 'Al_Safat',...
    'Jazan', 'Jebel_Ali', 'Malik_Al_Ashtar', 'Tayma',...
    'Umm_Salal', 'Unayzah', 'Al_Ula'};
shipFiles_cst = cellfun(@(x) rdir([topDir_ch, '*\**\', x, '*.csv'])', ...
    vNames_c, 'Uni', 0);

% Find any files not included above
marorkaFile_st = [shipFiles_cst{:}];
marorkaFile_c = {marorkaFile_st.name};
allFiles_st = rdir([topDir_ch, '*\**\*.*']);
allFiles_c = {allFiles_st.name};
unassignedFiles_c = setdiff(allFiles_c, marorkaFile_c);

if ~isempty(unassignedFiles_c)
   
    warnid = 'cV:TooManyFiles';
    warnmsg = [num2str(numel(unassignedFiles_c)) ' files have been detected '...
        'under the parent directory that do not match pattern of ship data '...
        'files.'];
    warning(warnid, warnmsg);
end

% Create object and call load methods
obj = cVessel();
obj = obj.loadMarorkaRaw(marorkaFile_c);