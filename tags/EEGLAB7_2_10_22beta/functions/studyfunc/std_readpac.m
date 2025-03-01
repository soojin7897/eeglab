% std_readpac() - read phase-amplitude correlation
%
% Usage:
%         >> [STUDY, clustinfo] = std_readpac(STUDY, ALLEEG);
%         >> [STUDY, clustinfo] = std_readpac(STUDY, ALLEEG, ...
%                                                'key', 'val');
% Inputs:
%       STUDY - studyset structure containing some or all files in ALLEEG
%      ALLEEG - vector of loaded EEG datasets
%
% Optional inputs:
%  'channels'  - [cell] list of channels to import {default: all}
%  'clusters'  - [integer] list of clusters to import {[]|default: all but
%                the parent cluster (1) and any 'NotClust' clusters}
%  'freqrange' - [min max] frequency range {default: whole measure range}
%  'timerange' - [min max] time range {default: whole measure epoch}
%
% Output:
%    STUDY     - (possibly) updated STUDY structure
%    clustinfo - structure of specified cluster information.
%
% Author: Arnaud Delorme, CERCO, 2009-

% Copyright (C) Arnaud Delorme, arno@salk.edu
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
% Revision 1.3  2009/07/30 03:13:46  arno
% fixed recompute
%
% Revision 1.2  2009/07/17 21:59:10  arno
% fixing std_readpac
%
% Revision 1.1  2009/07/13 21:10:26  arno
% still working on std_pac
%

function [STUDY, clustinfo] = std_readpac(STUDY, ALLEEG, varargin);

if nargin < 2
    help std_readpac;
    return;
end

[opt moreopts] = finputcheck( varargin, { ...
    'condition'  'cell'    []       {};
    'channels1'  'cell'    []       {};
    'clusters1'  'integer' []       [];
    'channels2'  'cell'    []       {};
    'clusters2'  'integer' []       [];
    'onepersubj' 'string' { 'on' 'off' } 'off';
    'forceread'  'string' { 'on' 'off' } 'off';
    'recompute'  'string' { 'on' 'off' } 'off';
    'freqrange'  'real'    []       [];
    'timerange'  'real'    []       [] }, ...
    'std_readpac', 'ignore');

if isstr(opt), error(opt); end;

%STUDY = pop_pacparams(STUDY, 'default');
%if isempty(opt.timerange), opt.timerange = STUDY.etc.pacparams.timerange; end;
%if isempty(opt.freqrange), opt.freqrange = STUDY.etc.pacparams.freqrange; end;

nc = max(length(STUDY.condition),1);
ng = max(length(STUDY.group),1);

% find channel indices
% --------------------
if ~isempty(opt.channels1)
    len1 = length(opt.channels1);
    len2 = length(opt.channels2);
    opt.indices1 = std_chaninds(STUDY, opt.channels1);
    opt.indices2 = std_chaninds(STUDY, opt.channels2);
else
    len1 = length(opt.clusters1);
    len2 = length(opt.clusters2);
    opt.indices1 = opt.clusters1;
    opt.indices2 = opt.clusters2;
end;

STUDY = std_convertoldsetformat(STUDY); %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX REMOVE WHEN READY TO GET RID OF OLD FORMAT

for ind1 = 1:len1 % usually only one channel/component
    for ind2 = 1:len2 % usually one channel/component

        % find indices
        % ------------
        if ~isempty(opt.channels1)
            tmpstruct1 = STUDY.changrp(opt.indices1(ind1));
            tmpstruct2 = STUDY.changrp(opt.indices2(ind2));
        else
            tmpstruct1 = STUDY.cluster(opt.indices1(ind1));
            tmpstruct2 = STUDY.cluster(opt.indices2(ind2));
        end;
        allinds1       = tmpstruct1.allinds;
        setinds1       = tmpstruct1.setinds;
        allinds2       = tmpstruct2.allinds;
        setinds2       = tmpstruct2.setinds;

        % check if data is already here
        % -----------------------------
        dataread = 0;
        if isfield(tmpstruct1, 'pacdata') & strcmpi(opt.forceread, 'off') & strcmpi(opt.recompute, 'off')
            if ~isempty(tmpstruct1.pacdata) & iscell(tmpstruct1.pacdata) & length(tmpstruct1.pacdata) >= opt.indices2(ind2)
                if ~isempty(tmpstruct1.pacdata{opt.indices2(ind2)})
                    %if isequal( STUDY.etc.pacparams.timerange, opt.timerange) & ...
                    %        isequal( STUDY.etc.pacparams.freqrange, opt.freqrange) & ~isempty(tmpstruct.pacdata)
                    dataread = 1;
                end;
            end;
        end;

        if ~dataread
            
            % reserve arrays
            % --------------
%             pacarray = cell( max(length(STUDY.condition),1), max(length(STUDY.group),1) );
%             tmpind1 = 1; while(isempty(setinds{tmpind1})), tmpind1 = tmpind1+1; end;
%             tmpind2 = 1; while(isempty(setinds{tmpind2})), tmpind2 = tmpind2+1; end;
%             if ~isempty(opt.channels1)
%                  [ tmp allfreqs alltimes ] = std_readpac( ALLEEG, 'channels1'  , setinds1{tmpind}(1), 'channels2'  , setinds2{tmpind}(1), 'timerange', opt.timerange, 'freqrange', opt.freqrange);
%             else [ tmp allfreqs alltimes ] = std_readpac( ALLEEG, 'components1', setinds1{tmpind}(1), 'components2', setinds2{tmpind}(1), 'timerange', opt.timerange, 'freqrange', opt.freqrange);
%             end;
%             for c = 1:nc
%                 for g = 1:ng
%                     pacarray{c, g} = repmat(zero, [length(alltimes), length(allfreqs), length(allinds1{c,g}) ]);
%                 end;
%             end;

            % read the data and select channels
            % ---------------------------------
            fprintf('Reading all PAC data...\n');
            for c = 1:nc
                for g = 1:ng
                    
                    % scan all subjects
                    count = 1;
                    for subj = 1:length(STUDY.subject)
                        
                        % get dataset indices for this subject
                        [inds1 inds2] = getsubjcomps(STUDY, subj, setinds1{c,g}, setinds2{c,g});
                        if setinds1{c,g}(inds1) ~= setinds2{c,g}(inds2), error('Wrong subject index'); end;
                        if ~strcmpi(ALLEEG(setinds1{c,g}(inds1)).subject, STUDY.subject(subj)), error('Wrong subject index'); end;
                                                
                        if ~isempty(inds1) & ~isempty(inds2)
                            if ~isempty(opt.channels1)
                                 [pacarraytmp allfreqs alltimes] = std_pac( ALLEEG(setinds1{c,g}(subj)), 'channels1'  , allinds1{c,g}(inds1), 'channels2',   allinds2{c,g}(inds2), 'timerange', opt.timerange, 'freqrange', opt.freqrange, 'recompute', opt.recompute, moreopts{:});
                            else [pacarraytmp allfreqs alltimes] = std_pac( ALLEEG(setinds1{c,g}(subj)), 'components1', allinds1{c,g}(inds1), 'components2', allinds2{c,g}(inds2), 'timerange', opt.timerange, 'freqrange', opt.freqrange, 'recompute', opt.recompute, moreopts{:});
                            end;
                            
                            % collapse first 2 dimentions (comps x comps)
                            if ndims(pacarraytmp) == 4
                                 pacarraytmp = reshape(pacarraytmp,    size(pacarraytmp,1)*size(pacarraytmp,2), size(pacarraytmp,3), size(pacarraytmp,4));
                            else pacarraytmp = reshape(pacarraytmp, 1, size(pacarraytmp,1),size(pacarraytmp,2));
                            end;
                            if strcmpi(opt.onepersubj, 'on')
                                pacarray{c, g}(:,:,count) = squeeze(mean(pacarraytmp,1));
                                count = count+1;
                            else
                                for tmpi = 1:size(pacarraytmp,1)
                                    pacarray{c, g}(:,:,count) = pacarraytmp(tmpi,:,:);
                                    count = count+1;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            
            % copy data to structure
            % ----------------------
            if ~isempty(opt.channels1)
                 STUDY.changrp(opt.indices1(ind1)).pacfreqs = allfreqs;
                 STUDY.changrp(opt.indices1(ind1)).pactimes = alltimes;
                 STUDY.changrp(opt.indices1(ind1)).pacdata{opt.indices2(ind2)} = pacarray;
            else STUDY.cluster(opt.indices1(ind1)).pacfreqs = allfreqs;
                 STUDY.cluster(opt.indices1(ind1)).pactimes = alltimes;
                 STUDY.cluster(opt.indices1(ind1)).pacdata{opt.indices2(ind2)} = pacarray;
            end;
        end;
    end;
end;

% return structure
% ----------------
if ~isempty(opt.channels1)
     clustinfo = STUDY.changrp(opt.indices1);
else clustinfo = STUDY.cluster(opt.indices1);
end;

% get components common to a given subject
% ----------------------------------------
function [inds1 inds2] = getsubjcomps(STUDY, subj, setlist1, setlist2, complist1, complist2)

    inds1 = [];
    inds2 = [];
    datasets = strmatch(STUDY.subject{subj}, { STUDY.datasetinfo.subject } ); % all datasets of subject
    [tmp1] = intersect(setlist1, datasets);
    [tmp2] = intersect(setlist2, datasets);
    if length(tmp1) > 1, error('This function does not support sessions for subjects'); end;
    if length(tmp2) > 1, error('This function does not support sessions for subjects'); end;
    if tmp1 ~= tmp2, error('Different datasets while it should be the same'); end;
    if ~isempty(tmp1), inds1 = find(setlist1 == tmp1); end;
    if ~isempty(tmp2), inds2 = find(setlist2 == tmp2); end;


