% pop_rejchanspec() - reject artifacts channels in an EEG dataset using joint 
%                  probability of the recorded electrode.
%
% Usage:
%   >> pop_rejchanspec( INEEG ) % pop-up interative window mode
%   >> [OUTEEG, indelec] = pop_rejchanspec( INEEG, 'key', 'val');
%
% Inputs:
%   INEEG      - input dataset
%
% Optional inputs:
%   'freqlimts' - [min max] frequency limits. May also be an array where
%                 each row defines a different set of limits.
%   'stdthresh' - [max] positive threshold in terms of standard deviation
%   'averef'    - ['on'|'off'] 'on' computes average reference before
%                 applying threshold. Default is 'off'.
%   'plothist'  - ['on'|'off'] 'on' plot the histogram of values along 
%                 with the threshold.
%
% Outputs:
%   OUTEEG    - output dataset with updated joint probability array
%   indelec   - indices of rejected electrodes
%
% Author: Arnaud Delorme, CERCO, UPS/CNRS, 2008-
%
% See also: jointprob(), rejkurt()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2008 Arnaud Delorme, CERCO, UPS/CNRS
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

function [EEG allrmchan] = pop_rejchanspec(EEG, varargin)

if nargin < 1
    help pop_rejchanspec;
    return;
end;
    
if nargin < 2
    uilist = { { 'style' 'text' 'string' 'Electrode (number(s); Ex: 2 4 5)' } ...
               { 'style' 'edit' 'string' ['1:' int2str(EEG.nbchan)] } ...
               { 'style' 'text' 'string' 'Frequency limits [min max]' } ...
               { 'style' 'edit' 'string' [ '35 ' int2str(floor(EEG.srate/2)) ] } ...
               { 'style' 'text' 'string' 'Standard dev. threshold limits [max]' } ...
               { 'style' 'edit' 'string' '5' } ...
               { 'style' 'text' 'string' 'OR absolute threshold limit [min max]' } ...
               { 'style' 'edit' 'string' '' } ...
               { 'style' 'text' 'string' 'Compute average reference first (check=on)' } ...
               { 'style' 'checkbox' 'string' '' 'value' 0 } { } ...
               { 'style' 'text' 'string' 'Plot histogram of power values (check=on)' } ...
               { 'style' 'checkbox' 'string' '' 'value' 0 } { } };
           
    geom = { [2 1] [2 1] [2 1] [2 1] [2 0.3 0.7] [2 0.3 0.7] };
    result = inputgui( 'uilist', uilist, 'geometry', geom, 'title', 'Reject channel using spectrum -- pop_rejchanspec()', ...
        'helpcom', 'pophelp(''pop_rejchan'')');
    if isempty(result), return; end;
    
    options = { 'elec' eval( [ '[' result{1} ']' ] ) 'stdthresh' str2num(result{3}) 'freqlims' str2num(result{2}) };
    if ~isempty(result{4})
        options = { options{:} 'absthresh' str2num(result{4}) };
    end;
    if result{5}, 
         options = { options{:} 'averef', 'on' }; 
    end;
    if result{6}, 
         options = { options{:} 'plothist', 'on' }; 
    end;
else
    options = varargin;
end;

% decode options
% --------------
opt = finputcheck( options, { 'averef'    'string'    { 'on' 'off' }       'off';
                              'plothist'  'string'    { 'on' 'off' }       'off';
                              'elec'      'integer'   []                   [1:EEG.nbchan];
                              'freqlims'  'real'   []                      [35 EEG.srate/2];
                              'absthresh' 'real'   []                      [];
                              'stdthresh' 'real'   []                      5 }, 'pop_rejchanspec');
if isstr(opt), error(opt); end;

% compute average referecne if necessary
if strcmpi(opt.averef, 'on')
     NEWEEG = pop_reref(EEG, [], 'exclude', setdiff([1:EEG.nbchan], opt.elec));
else NEWEEG = EEG;
end;
[tmpspec freqs] = pop_spectopo(NEWEEG, 1, [], 'EEG' , 'percent', 100, 'freqrange',[0 EEG.srate/2], 'plot', 'off');

if length(opt.stdthresh) == 1 && size(opt.freqlims,1) > 1
    opt.stdthresh = ones(1, size(opt.freqlims,1))*opt.stdthresh;
end;

allrmchan = [];
for index = 1:size(opt.freqlims,1)
    % select frequencies, compute median and std then reject channels
    % ---------------------------------------------------------------
    [tmp fbeg] = min(abs(freqs - opt.freqlims(index,1)));
    [tmp fend] = min(abs(freqs - opt.freqlims(index,2)));
    selectedspec = mean(tmpspec(opt.elec, fbeg:fend), 2);
    if ~isempty(opt.absthresh)
        rmchan = find(selectedspec <= opt.absthresh(1) | selectedspec >= opt.absthresh(2));
    else
        m = median(selectedspec);
        s = std( selectedspec);
        rmchan = find(selectedspec > m+s*opt.stdthresh(index));
    end;
    
    % print out results
    % -----------------
    if isempty(rmchan)
         textout = sprintf('Range %2.1f-%2.1f Hz: no channel removed\n',  opt.freqlims(index,1), opt.freqlims(index,2));
    else textout = sprintf('Range %2.1f-%2.1f Hz: channels %s removed\n', opt.freqlims(index,1), opt.freqlims(index,2), int2str(opt.elec(rmchan')));
    end;
    fprintf(textout);
    for inde = 1:length(opt.elec)
        if ismember(inde, rmchan)
             fprintf('Elec %s power: %1.2f *\n', EEG.chanlocs(opt.elec(inde)).labels, selectedspec(inde));
        else fprintf('Elec %s power: %1.2f\n', EEG.chanlocs(opt.elec(inde)).labels  , selectedspec(inde));
        end;
    end;
    allrmchan = [ allrmchan rmchan' ];    
    
    % plot histogram
    % --------------
    if strcmpi(opt.plothist, 'on')
        figure; hist(selectedspec);
        hold on; yl = ylim;
        if ~isempty(opt.absthresh)   
            plot([opt.absthresh(1) opt.absthresh(1)], yl, 'r');
            plot([opt.absthresh(2) opt.absthresh(2)], yl, 'r');
        else
            threshold =  m+s*opt.stdthresh(index);
            plot([threshold threshold], yl, 'r');
        end;
        title(textout);
    end;
    
end;
allrmchan = unique(allrmchan);

EEG = pop_select(EEG, 'nochannel', allrmchan);

if nargin < 2
    allrmchan = sprintf('EEG = pop_rejchanspec(EEG, %s);', vararg2str(options));
end;

    
