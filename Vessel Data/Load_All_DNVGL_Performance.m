%% Get file paths
homeDir = 'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data';
amcl = 'AMCL';
aesm = 'Anglo-Eastern Ship management';
euronav = 'Euronav';
setaf = 'SETAF-SAGET';

allSubs_c = {amcl, aesm, euronav, setaf};
allFiles = {};

for si = 1:numel(allSubs_c)
    
    currDir = allSubs_c{si};
    currDir_st = dir([fullfile(homeDir, currDir), '\*single vessel timeline*.xlsx']);
    currFiles = cellfun(@(x) fullfile(homeDir, currDir, x), {currDir_st.name}, 'Uni', 0);
    allFiles = [allFiles, currFiles];
end

% CMA CGM
cmaSiDir_ch = fullfile(homeDir, 'CMA CGM\CMA CGM 090217'); %'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217';
cmaSiDir = rdir([cmaSiDir_ch, '\**\*Single vessel timeline*.xlsx']);
cmaSi_c = {cmaSiDir.name}';
cmaPiDir_ch = fullfile(homeDir, 'CMA CGM\CMA CGM 290816'); %'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816';
cmaPiDir = rdir([cmaPiDir_ch, '\**\*Single vessel timeline*.xlsx']);
cmaPi_c = {cmaPiDir.name}';
cmaFile_c = cell(length(cmaPi_c) + length(cmaSi_c), 1);
cmaFile_c(1:2:end) = cmaPi_c;
cmaFile_c(2:2:end) = cmaSi_c;
% cmaFile_c = sort([cmaPi_c; cmaSi_c]);

% cmaNames_c = {
%     'Alexander'
%     'Almaviva'
%     'Cassiopeia'
%     'Chopin'
%     'Dalila'
%     'Danube'
%     'Gemini'
%     'Jules'
%     'Litani'
% };
% cmaDir_c = cellfun(@(x) fullfile(cmaDir_ch, x), cmaNames_c, 'Uni', 0);
% eiFile_s = 'EI2113 Hull and propeller performance - Single vessel timeline.xlsx';
% cmaPiFile_c = cellfun(@(x) fullfile(x, eiFile_s), cmaDir_c, 'Uni', 0);
% siFile_s = 'EI2123 Speed deviation - Single vessel timeline.xlsx';
% cmaSiFile_c = cellfun(@(x) fullfile(x, siFile_s), cmaDir_c, 'Uni', 0);
% cmaFile_c = [cmaPiFile_c; cmaSiFile_c];
% cmaFile_c = sort(cmaFile_c);
allFiles = [allFiles(:); cmaFile_c];

% Teekay
tkDir_ch = fullfile(homeDir, 'Teekay');
tkNames_c = {...
    'Dilong'
    'Godavari'
    'Jiaolong'
    'Narmada'
    'Shenlong'
    'Tianlong'
};

tkDir_c = cellfun(@(x) fullfile(tkDir_ch, x), tkNames_c, 'Uni', 0);
q = cellfun(@rdir, strcat(tkDir_c, '\**\*Single Vessel*'), 'Uni', 0);
w = cellfun(@(x) {x.name}, q, 'Uni', 0);
tkFile_c = flatten(w)';
invalidFiles = ~cellfun(@isempty, strfind(tkFile_c, 'RES_1'));
tkFile_c(invalidFiles) = [];

% tkFile_c = {...
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Dilong\EI2113 Hull and propeller performance - Single vessel timeline (1).xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Dilong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Godavari\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Godavari\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Jiaolong\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Jiaolong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Narmada\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Narmada\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Shenlong\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Shenlong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Tianlong\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Tianlong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%             };
allFiles = [allFiles; tkFile_c(:)];

% TMS
tmsDir_ch = fullfile(homeDir, 'TMS');

aFiles_st = rdir(strcat(tmsDir_ch, '\**\* a.xlsx*'));
bFiles_st = rdir(strcat(tmsDir_ch, '\**\* b.xlsx*'));
aFiles_c = {aFiles_st.name};
bFiles_c = {bFiles_st.name};

tmsFile_c = flatten([aFiles_c, bFiles_c])';
allFiles = [allFiles; tmsFile_c(:)];

% Yang Ming
ymNames_c = {...
    'Cosmos',...
    'Mobility',...
    'Mutuality',...
    'Orchid'
            };
ymDir_ch = fullfile(homeDir, 'Yang Ming');
ym_st = rdir([ymDir_ch, '\**\*Single vessel timeline.xlsx']);
ym_c = {ym_st.name};
allFiles = [allFiles; ym_c(:)];

%%

% allFiles = ...
% {
%     'C:\Users\damcl\Documents\Ship Data\AMCL\EI2113 Hull and propeller performance - Single vessel timeline (2).xlsx'
%     'C:\Users\damcl\Documents\Ship Data\AMCL\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Devon EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Devon EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Hakone EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Hakone EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Hirado EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Hirado EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Sara EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Euronav\Sara EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\SETAF-SAGET\EI2113 Hull and propeller performance - Single vessel timeline (2).xlsx'
%     'C:\Users\damcl\Documents\Ship Data\SETAF-SAGET\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Alexander.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Alexander.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Almaviva.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Almaviva.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Cassiopiea.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Cassiopeia.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Chopin.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Chopin.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Dalila.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Dalila.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Danube.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Danube.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Gemini.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Gemini.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Jules.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Jules Verne.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Litani.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Litani.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 290816\EI2113 Hull and propeller performance - Single vessel timeline Marco.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\CMA CGM\CMA CGM 090217\EI2123 Speed deviation - Single vessel timeline Marco.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Dilong\EI2113 Hull and propeller performance - Single vessel timeline (1).xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Dilong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Godavari\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Godavari\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Jiaolong\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Jiaolong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Narmada\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Narmada\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Shenlong\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Shenlong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Tianlong\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Teekay\Tianlong\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline ASPC a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline BINT a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline CINT a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline CX7 a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline LX7 a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline ZX7 a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline ASPC a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline BINT a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline CINT a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline CX7 a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline LX7 a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline ZX7 a.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline ASPC b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline BINT b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline CINT b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline CX7 b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline LX7 b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2113 Hull and propeller performance - Single vessel timeline ZX7 b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline ASPC b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline BINT b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline CINT b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline CX7 b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline LX7 b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\TMS\EI2123 Speed deviation - Single vessel timeline ZX7 b.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Cosmos\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Cosmos\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Mobility\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Mobility\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Mutuality\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Mutuality\EI2123 Speed deviation - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Orchid\EI2113 Hull and propeller performance - Single vessel timeline.xlsx'
%     'C:\Users\damcl\Documents\Ship Data\Yang Ming\Orchid\EI2123 Speed deviation - Single vessel timeline.xlsx'
% };

%% IMO
IMO_v = [...
  9445631, ... AMCL
  9445631, ...
  9516117, ... Devon
  9516117, ...
  9398084, ... Hakone
  9398084, ...
  9377420, ... Hirado
  9377420, ...
  9537745, ... Sara
  9537745, ...
  9490868, ... SETAF-SAGET
  9490868, ...
  9454448, ... Alexander
  9454448, ...
  9450648, ... Almaviva
  9450648, ...
  9410765, ... Cassiopeia
  9410765, ...
  9280603, ... Chopin
  9280603, ...
  9450624, ... Dalila
  9450624, ...
  9674517, ... Danube
  9674517, ...
  9410791, ... Gemini
  9410791, ...
  9454450, ... Jules
  9454450, ...
  9705055, ... Litani
  9705055, ...
  9454436, ... Marco
  9454436, ...
  9390628, ... Dilong
  9390628, ...
  9286229, ... Godavari
  9286229, ...
  9379208, ... Jiaolong
  9379208, ...
  9269075, ... Narmada
  9269075, ...
  9379210, ... Shenlong
  9379210, ...
  9378369, ... Tianlong
  9378369, ...
  1110006, ... ASPC
  1110004, ... BINT
  1110005, ... CINT
  1110003, ... CX7 77500
  1110002, ... LX7 77500
  1110001, ... ZX7 77500
  1110006, ... ASPC
  1110004, ... BINT
  1110005, ... CINT
  1110003, ... CX7 77500
  1110002, ... LX7 77500
  1110001, ... ZX7 77500
  1110006, ... ASPC
  1110004, ... BINT
  1110005, ... CINT
  1110003, ... CX7 77500
  1110002, ... LX7 77500
  1110001, ... ZX7 77500
  1110006, ... ASPC
  1110004, ... BINT
  1110005, ... CINT
  1110003, ... CX7 77500
  1110002, ... LX7 77500
  1110001, ... ZX7 77500
  9198288, ... Cosmos
  9198288, ...
  9457737, ... Mobility
  9457737, ...
  9455870, ... Mutuality
  9455870, ...
  9198276, ... Orchid
  9198276 ...
];

%% Load into database
obj_ves = cVessel();

% Allow script to be called with cDB object, when creating database
if exist('obj', 'var') && isa(obj, 'cDB')
    obj_ves.Database = obj.Database;
end
% obj = obj.loadDNVGLPerformance(allFiles, IMO_v);
piFile_ch = 'C:\Users\damcl\Documents\Ship Data\AMCL\tempEI2113 Hull and propeller performance - Single vessel timeline (2)_performance.tab';
siFile_ch = 'C:\Users\damcl\Documents\Ship Data\AMCL\tempEI2113 Hull and propeller performance - Single vessel timeline (2)_speed.tab';
tabFiles = {piFile_ch, siFile_ch};
% obj.Da
obj_ves = obj_ves.loadDNVGLPerformance(allFiles, IMO_v);

clear obj;