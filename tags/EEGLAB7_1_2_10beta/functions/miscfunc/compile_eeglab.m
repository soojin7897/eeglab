% EEGLAB cross-platform compiling script
% should be run on a newly checked out EEGLAB version as 
% some folder are temporarily modified
%
% Arnaud Delorme - August 3rd, 2009

% Copyright (C) 2009 Arnaud Delorme
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

disp('This function will compile EEGLAB in the output folder');
disp('provided below. You may also enter a path relative to the EEGLAB');
disp('folder: ../compiled_EEGLAB for instance');
outputfolder = input('Enter output folder name:','s');

eeglab; close;
path_eeglab = fileparts(which('eeglab'));
cd(path_eeglab);

path_fileio = fileparts(which('chantype'));
try, movefile( fullfile(path_fileio, '@uint64'), fullfile(path_fileio, 'uint64') ); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'buffer.m')      ,  fullfile(path_fileio, 'private', 'bufferold.m') ); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'read_24bit.m')  ,  fullfile(path_fileio, 'private', 'read_24bitold.m')); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'read_ctf_shm.m'),  fullfile(path_fileio, 'private', 'read_ctf_shmold.m')); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'write_ctf_shm.m'), fullfile(path_fileio, 'private', 'write_ctf_shmold.m')); catch, end;
path_fileio = path_fileio(length(path_eeglab)+2:end);
files_fileio         = fullfile(path_fileio, '*.m');
files_fileio_private = fullfile(path_fileio, 'private', '*.m');

path_fieldtrip = fileparts(which('electroderealign'));
addpath(fullfile(path_fieldtrip, 'public'));
try, movefile( fullfile(path_fieldtrip, 'fileio', '@uint64'), fullfile(path_fieldtrip, 'fileio', 'uint64') ); catch, end;
try, movefile( fullfile(path_fieldtrip, '@uint64'), fullfile(path_fieldtrip, 'uint64') ); catch, end;
try, movefile( fullfile(path_fieldtrip, 'topoplot.m'), fullfile(path_fieldtrip, 'topoplotold.m') ); catch, end;
path_fieldtrip = path_fieldtrip(length(path_eeglab)+2:end);
files_fieldtrip         = fullfile(path_fieldtrip, '*.m');
files_fieldtrip_private = fullfile(path_fieldtrip, 'private', '*.m');
files_forwinv           = fullfile(path_fieldtrip, 'forwinv', '*.m');
files_forwinv_private   = fullfile(path_fieldtrip, 'forwinv', 'private', '*.m');

try
    rmpath('C:\Documents and Settings\delorme\My Documents\eeglab\plugins\editevents_arno');
catch, end;
path_biosig = fileparts(which('install'));
path_biosig = path_biosig(length(path_eeglab)+2:end);
biosig  = ' sopen.m sclose.m sread.m ';
% note that the order is important if the two first folders are inverted,
% it does not work
fieldt  = [ ' -a ' files_fieldtrip_private ...
            ' -a ' files_fieldtrip ...
            ' -a ' files_forwinv ...
            ' -a ' files_forwinv_private ...
            ' -a ' files_fileio ...
            ' -a ' files_fileio_private ];
%fieldt  = [ ' -a external\fieldtrip-20090727\private\*.m -a external\fieldtrip-20090727\*.m  ' ...
%            ' -a external\fieldtrip-20090727\forwinv\*.m -a external\fieldtrip-20090727\forwinv\private\*.m ' ...
%            ' -a external\fileio-20090511\*.m -a external\fileio-20090511\private\*.m ' ];
% topoplot
% uint64 in fieldtrip and file-io
% other mex files in file-io private folder
[allfiles1 plugins]   = scanfold('plugins/');
[allfiles2 functions] = scanfold('functions/');
eval([ 'mcc -v -C -m eeglab' biosig plugins functions fieldt ]);
mkdir(fullfile(outputfolder));
copyfile( 'eeglab.exe', fullfile(outputfolder, 'eeglab.exe'), 'f');
copyfile( 'eeglab.ctf', fullfile(outputfolder, 'eeglab.ctf'), 'f');

% copy BESA files etc
% -------------------
dipfitdefs;
mkdir(fullfile(outputfolder, 'help'));
tmpf = which('eeglablicense.txt');      copyfile(tmpf, fullfile(outputfolder, 'help', 'eeglablicense.txt'));
tmpf = which('eeg_optionsbackup.m');    copyfile(tmpf, fullfile(outputfolder, 'eeg_optionsbackup.txt'));
tmpf = which('eeg_options.m');          copyfile(tmpf, fullfile(outputfolder, 'eeg_options.txt'));
tmpf = which('mheadnew.xyz');           copyfile(tmpf, fullfile(outputfolder, 'mheadnew.xyz'));
tmpf = which('mheadnew.mat');           copyfile(tmpf, fullfile(outputfolder, 'mheadnew.mat'));
tmpf = which('mheadnew.elp');           copyfile(tmpf, fullfile(outputfolder, 'mheadnew.elp'));
tmpf = which('mheadnew.transform');     copyfile(tmpf, fullfile(outputfolder, 'mheadnew.transform'));
mkdir(fullfile(outputfolder, 'standard_BEM'));
mkdir(fullfile(outputfolder, 'standard_BEM', 'elec'));
copyfile(template_models(2).hdmfile , fullfile(outputfolder, 'standard_BEM', 'standard_vol.mat'));
copyfile(template_models(2).mrifile , fullfile(outputfolder, 'standard_BEM', 'standard_mri.mat'));
copyfile(template_models(2).chanfile, fullfile(outputfolder, 'standard_BEM',  'elec', 'standard_1005.elc'));
mkdir(fullfile(outputfolder, 'standard_BESA'));
copyfile(template_models(1).hdmfile , fullfile(outputfolder, 'standard_BESA', 'standard_BESA.mat'));
copyfile(template_models(1).mrifile , fullfile(outputfolder, 'standard_BESA', 'avg152t1.mat'));
copyfile(template_models(1).chanfile, fullfile(outputfolder, 'standard_BESA', 'standard-10-5-cap385.elp'));
copyfile(fullfile(path_biosig, 'doc', 'units.csv'),              fullfile(outputfolder, 'units.csv'));
copyfile(fullfile(path_biosig, 'doc', 'leadidtable_scpecg.txt'), fullfile(outputfolder, 'leadidtable_scpecg.txt'));
copyfile(fullfile(path_biosig, 'doc', 'elecpos.txt'),            fullfile(outputfolder, 'elecpos.txt'));
copyfile(fullfile(path_biosig, 'doc', 'DecimalFactors.txt'),     fullfile(outputfolder, 'DecimalFactors.txt'));

% copy all files for help
% -----------------------
disp('Copying help files');
allfiles = { allfiles1{:} allfiles2{:} };
for index = 1:length(allfiles)
    tmpp = which(allfiles{index});
    copyfile(tmpp, fullfile(outputfolder, 'help', allfiles{index}));
end;

% cleaning up
% -----------
try, movefile( fullfile(path_fileio, 'uint64'), fullfile(path_fileio, '@uint64') ); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'bufferold.m')      ,  fullfile(path_fileio, 'private', 'buffer.m') ); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'read_24bitold.m')  ,  fullfile(path_fileio, 'private', 'read_24bit.m')); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'read_ctf_shmold.m'),  fullfile(path_fileio, 'private', 'read_ctf_shm.m')); catch, end;
try, movefile( fullfile(path_fileio, 'private', 'write_ctf_shmold.m'), fullfile(path_fileio, 'private', 'write_ctf_shm.m')); catch, end;
try, movefile( fullfile(path_fieldtrip, 'fileio', 'uint64'), fullfile(path_fieldtrip, 'fileio', '@uint64') ); catch, end;
try, movefile( fullfile(path_fieldtrip, 'uint64'), fullfile(path_fieldtrip, '@uint64') ); catch, end;
try, movefile( fullfile(path_fieldtrip, 'topoplotold.m'), fullfile(path_fieldtrip, 'topoplot.m') ); catch, end;

return

%histforexe(allfiles1, 'help');

% help for lisence
% 

