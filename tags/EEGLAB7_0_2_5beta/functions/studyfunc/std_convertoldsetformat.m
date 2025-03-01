% FONCTION INTERNAL CONTAINS THE STEPS REQUIRED FOR TOTAL CONVERSION
%
% std_convertoldsetformat - convert old format to store component to the
%                           new more flexible format
%
% STUDY = std_convertoldsetformat(STUDY);
%
% Author: Arnaud Delorme, SCCN/INC, UCSD 2009-

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more information

% $Log: not supported by cvs2svn $

% How to remove .setind
%   It is now only in std_preclust but is really embeded in the function
%   To remove it, one would need
%    - build the preclustering array and two additional cell array
%    - component indices (can be 2 per component)
%    - set array (can be 2 per component)
%    - these array already exist in STUDY.etc.preclustcomp
%
% Remove .comps and .sets from clusters
% pop_clustedit -> major
% pop_preclust  -> minor 4 lines
% std_preclust  -> minor 2 lines but it seems to define the order of components
%                  below for actual clustering
% pop_clust     -> not much, only assignment. However components in the
%                  preclustering array are organized according to their
%                  position in the .comps field of the parent cluster
% std_readdata  -> really minor

function STUDY = std_convertoldsetformat(STUDY);

for index = 1:length(STUDY.cluster)
    [ tmpstruct setinds allinds ] = getsetinds(STUDY, index);
    STUDY.cluster(index).setinds = setinds;
    STUDY.cluster(index).allinds = allinds;
end;
STUDY.cluster = rmfield(STUDY.cluster, 'sets');
STUDY.cluster = rmfield(STUDY.cluster, 'comps');

% get set and indices for components cluster
% ------------------------------------------
function [ tmpstruct setinds allinds ] = getsetinds(STUDY, ind)

tmpstruct = STUDY.cluster(ind);
alldatasets = tmpstruct.sets;
allchanorcomp = repmat(tmpstruct.comps, [size(tmpstruct.sets,1) 1]); % old format

alldatasets   = alldatasets(:)';
allchanorcomp = allchanorcomp(:)';

% get indices for all groups and conditions
% -----------------------------------------
nc = max(length(STUDY.condition),1);
ng = max(length(STUDY.group),1);
allinds = cell( nc, ng );
setinds = cell( nc, ng );
for indtmp = 1:length(alldatasets)
    if ~isnan(alldatasets(indtmp))
        index = alldatasets(indtmp);
        condind = strmatch( STUDY.datasetinfo(index).condition, STUDY.condition, 'exact'); if isempty(condind), condind = 1; end;
        grpind  = strmatch( STUDY.datasetinfo(index).group    , STUDY.group    , 'exact'); if isempty(grpind) , grpind  = 1; end;
        indcellarray = length(allinds{condind, grpind})+1;
    end
    % load data
    % ---------
    tmpind = allchanorcomp(indtmp);
    if ~isnan(tmpind)
        allinds{ condind, grpind}(indcellarray) = tmpind;
        setinds{ condind, grpind}(indcellarray) = index;
    end;
end;
tmpstruct.allinds = allinds;
tmpstruct.setinds = setinds;
