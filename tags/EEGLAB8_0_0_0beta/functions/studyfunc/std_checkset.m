% std_checkset() - check STUDY set consistency
%
% Usage: >> [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);  
%
% Input:
%   STUDY      - EEGLAB STUDY set
%   ALLEEG     - vector of EEG datasets included in the STUDY structure 
%
% Output:
%   STUDY      - a new STUDY set containing some or all of the datasets in ALLEEG, 
%                plus additional information from the optional inputs above. 
%   ALLEEG     - an EEGLAB vector of EEG sets included in the STUDY structure 
%
% Authors:  Arnaud Delorme & Hilit Serby, SCCN, INC, UCSD, November 2005

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, arno@sccn.ucsd.edu
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

% $Log: not supported by cvs2svn $
% Revision 1.70  2008/03/30 12:04:47  arno
% text if old version and remove fields allinds and setinds
%
% Revision 1.69  2007/11/29 20:13:46  nima
% msg comment - Arno
%
% Revision 1.68  2007/11/02 02:13:25  arno
% fix the correct session code
%
% Revision 1.67  2007/11/01 23:10:06  arno
% removing version testing
%
% Revision 1.66  2007/11/01 23:06:05  arno
% removing message
%
% Revision 1.65  2007/10/18 22:02:51  nima
% _
%
% Revision 1.64  2007/09/11 11:13:57  arno
% add bug ref
%
% Revision 1.63  2007/09/11 10:40:42  arno
% detect inconsistent time-frequency decomposition
%
% Revision 1.62  2007/08/24 00:56:36  arno
% better error message
%
% Revision 1.61  2007/08/23 17:27:49  arno
% session and group problem
%
% Revision 1.60  2007/08/23 17:16:03  arno
% remove debug message
%
% Revision 1.59  2007/08/23 17:15:24  arno
% better testing for correcting session
%
% Revision 1.58  2007/08/23 00:52:34  arno
% delete STUDY.cluster and changrp
%
% Revision 1.57  2007/08/23 00:43:50  arno
% checking that different group have different session names
%
% Revision 1.56  2007/08/22 01:39:52  arno
% fix special case of negative indices in STUDY
%
% Revision 1.55  2007/08/22 01:25:57  arno
% bettter check for the study
%
% Revision 1.54  2007/08/13 21:23:51  arno
% nothing
%
% Revision 1.53  2007/08/13 18:32:46  arno
% removing channel group if old version
%
% Revision 1.52  2007/08/12 02:45:47  arno
% aiutomatically generate changrp
%
% Revision 1.51  2007/08/12 02:15:17  arno
% still better warning
%
% Revision 1.50  2007/08/12 02:12:14  arno
% better warning
%
% Revision 1.49  2007/08/09 21:27:02  arno
% messag
%
% Revision 1.48  2007/08/09 21:09:41  arno
% typo
%
% Revision 1.47  2007/08/09 20:26:04  arno
% typos
%
% Revision 1.46  2007/08/09 16:29:31  arno
% message when removing measures
%
% Revision 1.45  2007/08/09 01:25:54  arno
% removing all data if old study
%
% Revision 1.44  2007/07/31 03:41:57  arno
% message
%
% Revision 1.43  2007/07/30 22:20:38  arno
% *** empty log message ***
%
% Revision 1.42  2007/06/25 07:42:57  toby
% added warning if NaNs in STUDY.setind
%
% Revision 1.41  2007/02/28 12:02:42  arno
% minor thing
%
% Revision 1.39  2006/12/07 22:19:17  arno
% removing changrp for now
%
% Revision 1.38  2006/12/07 22:07:23  arno
% changrp check
%
% Revision 1.37  2006/12/07 20:22:02  arno
% make changrp by default
%
% Revision 1.36  2006/11/10 01:42:32  arno
% set changrp to empty
%
% Revision 1.35  2006/11/08 22:37:02  arno
% history, test if studywasempty
%
% Revision 1.34  2006/10/10 04:12:36  toby
% load bug fixed, save revision info added
%

function [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG, option);

if nargin < 2
    help std_checkset;
    return;
end;
    
studywasempty = 0;
if isempty(STUDY), studywasempty = 1; end;

modif = 0;
if ~isfield(STUDY, 'name'),  STUDY.name  = ''; modif = 1; end;
if ~isfield(STUDY, 'task'),  STUDY.task  = ''; modif = 1; end;
if ~isfield(STUDY, 'notes'), STUDY.notes = ''; modif = 1; end;
if ~isfield(STUDY, 'filename'),  STUDY.filename  = ''; modif = 1; end;
if ~isfield(STUDY, 'filepath'),  STUDY.filepath  = ''; modif = 1; end;
if ~isfield(STUDY, 'history'),   STUDY.history   = ''; modif = 1; end;
if ~isfield(STUDY, 'subject'),   STUDY.subject   = {}; modif = 1; end;
if ~isfield(STUDY, 'group'),     STUDY.group     = {}; modif = 1; end;
if ~isfield(STUDY, 'session'),   STUDY.session   = {}; modif = 1; end;
if ~isfield(STUDY, 'condition'), STUDY.condition = {}; modif = 1; end;
if ~isfield(STUDY, 'setind'),    STUDY.setind    = {}; modif = 1; end;
if ~isfield(STUDY, 'etc'),       STUDY.etc       = []; modif = 1; end;
if ~isfield(STUDY, 'etc.warnmemory'), STUDY.etc.warnmemory = 1; modif = 1; end;
if ~isfield(STUDY, 'preclust'),  STUDY.preclust  = []; modif = 1; end;
if ~isfield(STUDY, 'datasetinfo'), STUDY.datasetinfo = []; modif = 1; end;
if ~isfield(STUDY.etc, 'version'), STUDY.etc.version = []; modif = 1; end;
if ~isfield(STUDY.preclust, 'erpclusttimes' ),  STUDY.preclust.erpclusttimes = []; modif = 1; end;
if ~isfield(STUDY.preclust, 'specclustfreqs' ), STUDY.preclust.specclustfreqs = []; modif = 1; end;
if ~isfield(STUDY.preclust, 'erspclustfreqs' ), STUDY.preclust.erspclustfreqs = []; modif = 1; end;
if ~isfield(STUDY.preclust, 'erspclusttimes' ), STUDY.preclust.erspclusttimes = []; modif = 1; end;
if ~isfield(STUDY.datasetinfo, 'comps') & ~isempty(STUDY.datasetinfo), STUDY.datasetinfo(1).comps = []; modif = 1; end;
if ~isfield(STUDY.datasetinfo, 'index') & ~isempty(STUDY.datasetinfo), STUDY.datasetinfo(1).index = []; modif = 1; end;

% all summary fields
% ------------------
try, subject = unique({ STUDY.datasetinfo.subject });
catch, 
     subject = ''; 
     disp('Important warning: some datasets do not have subject codes; some functions may crash!');
end;
try, group = unique({ STUDY.datasetinfo.group });
catch, 
     group = {}; 
     % disp('Important warning: some datasets do not have group codes; some functions may crash!');
end;
try, condition = unique({ STUDY.datasetinfo.condition });
catch, 
     condition = {}; 
     disp('Important warning: some datasets do not have condition codes; some functions may crash!');
end;
try, session = unique([STUDY.datasetinfo.session]);
catch, 
     session = ''; 
     % disp('Important warning: some datasets do not have session numbers; some functions may crash!');
end;
if ~isequal(STUDY.subject,   subject  ), STUDY.subject   = subject;   modif = 1; end;  
if ~isequal(STUDY.group,     group    ), STUDY.group     = group;     modif = 1; end;  
if ~isequal(STUDY.condition, condition), STUDY.condition = condition; modif = 1; end;  
if ~isequal(STUDY.session,   session  ), STUDY.session   = session;   modif = 1; end;  

% recompute setind matrix and check that subjects with different group HAVE different sessions
% --------------------------------------------------------------------------------------------
notsameica = [];
correctsession = 0;
if ~isempty(STUDY.datasetinfo(1).index)
    for is = 1:length(STUDY.subject)
        alldats = strmatch(STUDY.subject{is}, { STUDY.datasetinfo.subject }, 'exact');

        for is = 1:length(STUDY.session)
            tmpind       = find(STUDY.session(is) == [ STUDY.datasetinfo(alldats).session ] );
            if length(unique({ STUDY.datasetinfo(alldats(tmpind)).group } )) > 1
                correctsession = 1;
            end;
            
            tmpdats = alldats(tmpind);
            try nc = size(ALLEEG(STUDY.datasetinfo(tmpdats(1)).index).icaweights,1);
            catch nc = [];
            end
            for ir = 2:length(tmpdats)
                if nc ~= size(ALLEEG(STUDY.datasetinfo(tmpdats(ir)).index).icaweights,1)
                    notsameica = [ notsameica; tmpdats(1) tmpdats(ir) ];
                end;
            end;
        end;
    end;
end;
if correctsession
    fprintf('Warning: different group values have the same session, session now assigned automatically\n');
    for index = 1:length(STUDY.datasetinfo)
        STUDY.datasetinfo(index).session = strmatch( STUDY.datasetinfo(index).group, STUDY.group, 'exact');
    end;
    STUDY.session = unique([STUDY.datasetinfo.session]);
    STUDY.cluster = [];
    STUDY.changrp = [];
    modif = 1;
end;
if ~isempty(notsameica)
    disp('Different ICA decompositions have been found for the same')
    disp('subject in two conditions. if the data were recorded in the')
    disp('same session, it might be best to run ICA on both datasets simultanously.')
    setind = [1:length(STUDY.datasetinfo)];
    if ~isequal(STUDY.setind, setind)
        STUDY.setind = setind; modif = 1;
    end;
else
    if ~isempty(STUDY.condition)
        if ~isempty(STUDY.session)
            setind = zeros(length(STUDY.condition), length(STUDY.subject) *length(STUDY.session));
        else
            setind = zeros(length(STUDY.condition), length(STUDY.subject) );
        end
    else
        if ~isempty(STUDY.session)        
            setind = zeros(1, length(STUDY.subject) *length(STUDY.session));
        else
            setind = zeros(1, length(STUDY.subject) );
        end
    end
    for k = 1:length(STUDY.datasetinfo)
        setcond = find(strcmp(STUDY.datasetinfo(k).condition, STUDY.condition));
        setsubj = find(strcmp(STUDY.datasetinfo(k).subject,   STUDY.subject));
        setsess = find(STUDY.datasetinfo(k).session == STUDY.session);
        ncomps  = [];
        if ~isempty(setcond)
            if ~isempty(setsess)
                setind(setcond, setsubj * length(STUDY.session)+setsess-1) = k; 
                %A 2D matrix of size [conditions (subjects x sessions)]
            else
                setind(setcond, setsubj ) = k; 
            end
        else
            if ~isempty(setsess)
                setind(1, setsubj * length(STUDY.session)+setsess-1) = k; 
            else
                setind(1, setsubj) = k; 
            end
        end

        if ~isequal(STUDY.datasetinfo(k).index, k)
            STUDY.datasetinfo(k).index = k; modif = 1; %The dataset index in the current ALLEEG structure
        end;
    end
end;

% check dataset info consistency 
% ------------------------------
for k = 1:length(STUDY.datasetinfo)
    if ~strcmpi(STUDY.datasetinfo(k).filename, ALLEEG(k).filename)
        STUDY.datasetinfo(k).filename = ALLEEG(k).filename; modif = 1;
        fprintf('Warning: file name has changed for dataset %d and the study has been updated\n', k);
        fprintf('         to discard this change in the study, reload it from disk\n');
    end;
end;

% set to NaN empty indices and remove nan columns
% -----------------------------------------------
setind( find(setind(:) == 0) ) = NaN;
rmind = [];
for k = 1:size(setind,2)
    ind_nonnan = find(~isnan(setind(:,k)));
    if isempty(ind_nonnan), rmind = [ rmind k ]; end;
end
setind(:,rmind) = [];
if ~isequal(setind, STUDY.setind)
    STUDY.setind = setind; modif = 1;
end
if any(isnan(setind))
    warndlg('STUDY.setind contains NaNs. There must be a dataset for every subject, condition, and group combination or some study functions will fail.');
end

% remove cluster information if old version
% -----------------------------------------
if isempty(STUDY.etc.version) | strcmpi(STUDY.etc.version, '6.01b')
    icadefs;
    if isfield(STUDY, 'cluster')
        STUDY = std_reset(STUDY);
    end;
    filename = fullfile( ALLEEG(1).filepath,[ ALLEEG(1).filename(1:end-3) 'icaersp']);
    if isempty(STUDY.etc.version)
        if exist(filename) == 2
            tmp = load('-mat', filename);
            if (length(fieldnames(tmp))-5)/3 < size(ALLEEG(1).icaweights,1)
    %            keyboard; nima
                fprintf(2,'Possibly corrupted ERSP files for ICA. THESE FILES SHOULD BE RECOMPUTED (bug 497).\n');
                fprintf(2,'(This message will not appear again).\n');
                disp('Use menu "Study > Precompute Component Measures", select ERSP and');
                disp('force recomputation. This problem refers to bug 489.');
            end;
        end;
    end;
    if isfield(STUDY, 'changrp')
        if ~isempty(STUDY.changrp)
            STUDY.changrp = [];
        end;
    end;
    modif = 1;
    STUDY.etc.version = EEGLAB_VERSION;
end;

% set cluster array if empty
% --------------------------
if ~isfield(STUDY, 'cluster'), STUDY.cluster = []; modif = 1; end;
if isempty(STUDY.cluster)
    modif = 1; 
    [STUDY] = std_createclust(STUDY, ALLEEG, 'ParentCluster');
    STUDY.cluster(1).parent = []; 
    for k = 1:size(STUDY.setind,2)
        
        ind_nonnan = find(~isnan(STUDY.setind(:,k)));
        ind_nonnan = STUDY.setind(ind_nonnan(1),k);
        comps = STUDY.datasetinfo(ind_nonnan).comps;
        if isempty(comps)
            comps = 1:size(ALLEEG(STUDY.datasetinfo(ind_nonnan).index).icaweights,1);
        end;
        STUDY.cluster(1).sets =  [STUDY.cluster(1).sets       STUDY.setind(:,k)*ones(1,length(comps))];
        STUDY.cluster(1).comps = [STUDY.cluster(1).comps      comps];
    end
else
    for index = 1:length(STUDY.cluster)
        if ~isempty(STUDY.cluster(index).centroid) & ~isstruct(STUDY.cluster(index).centroid)
            STUDY.cluster(index).centroid = [];
            modif = 1; 
        end;
    end;    
end;

% make channel groups
% -------------------
if ~isfield(STUDY, 'changrp'), STUDY.changrp = []; modif = 1; end;
if isempty(STUDY.changrp)
  STUDY = std_changroup(STUDY, ALLEEG);
  modif = 1;
elseif isfield(STUDY.changrp, 'allinds')
    try,
        if ~isempty(STUDY.changrp(1).allinds)
            if any(STUDY.changrp(1).allinds{1} < 0)
                STUDY = std_changroup(STUDY, ALLEEG);
            end;
        end;
    catch, end;
end;

% determine if there has been any change
% --------------------------------------
if modif;
    STUDY.saved = 'no';
    if studywasempty
        command = '[STUDY, ALLEEG] = std_checkset([], ALLEEG);';
    else
        command = '[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);';
    end;
    eegh(command);
    STUDY.history =  sprintf('%s\n%s',  STUDY.history, command);
end;
