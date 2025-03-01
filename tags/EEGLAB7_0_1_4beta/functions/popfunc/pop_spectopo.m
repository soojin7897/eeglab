% pop_spectopo() - Plot spectra of specified data channels or components.
%                  Show scalp maps of power at specified frequencies. 
%                  Calls spectopo(). 
% Usage:
%   >> pop_spectopo( EEG, dataflag); % pops-up interactive window
%  OR
%   >> [spectopo_outputs] = pop_spectopo( EEG, dataflag, timerange, ...
%                        process, 'key', 'val',...); % returns spectopo() outputs
%
% Graphic interface for EEG data (dataflag = 1):
%   "Epoch time range" - [edit box]  [min max] Epoch time range (in ms) to use 
%                      in computing the spectra (by default the whole epoch or data).
%                      Command line equivalent: 'timerange'
%   "Percent data to sample" - [edit box] Percentage of data to use in
%                      computing the spectra (low % speeds up the computation).
%                      spectopo() equivalent: 'percent'
%   "Frequencies to plot as scalp maps" - [edit box] Vector of 1-7 frequencies to 
%                      plot topoplot() scalp maps of power at all channels.
%                      spectopo() equivalent: 'freqs'
%   "Apply to EEG|ERP|BOTH" - [edit box] Plot spectra of the 'EEG', 'ERP' or of 'BOTH'.
%                      NOTE: This edit box does not appear for continuous data.
%                      Command line equivalent: 'process'
%   "Plotting frequency range" - [edit box] [min max] Frequency range (in Hz) to plot.
%                      spectopo() equivalent: 'freqrange'
%   "Spectral and scalp map options (see topoplot)" - [edit box] 'key','val','key',... 
%                      sequence of arguments passed to spectopo() for details of the 
%                      spectral decomposition or to topoplot() to adjust details of 
%                      the scalp maps. For details see  >> help topoplot
%
% Graphic interface for components (dataflag = 0):
%   "Epoch time range" - [edit box]  [min max] Epoch time range (in ms) to use 
%                      in computing the spectra (by default the whole epoch or data).
%                      Command line equivalent: 'timerange'
%   "Frequency (Hz) to analyze" - [edit box] Single frequency (Hz) at which to plot 
%                      component contributions. spectopo() equivalent: 'freqs'
%   "Electrode number to analyze" - [edit box] 1-nchans --> Plot component contributions 
%                      at this channel; [] --> Plot contributions at channel with max 
%                      power; 0 --> Plot component contributions to global (RMS) power.
%                      spectopo() equivalent: 'plotchan'
%   "Percent data to sample" - [edit box] Percent of data to use in computing the spectra 
%                      (low % speeds up the computation). spectopo() equivalent: 'percent'
%   "Components to include ..." - [Edit box] Only compute spectrum of a subset of the
%                      components. spectopo() equivalent: 'icacomps'
%   "Number of largest-contributing ..." - [edit box] Number of component maps 
%                      to plot. spectopo() equivalent: 'nicamaps'
%   "Else, map only these components ..." - [edit box] Use this entry to override 
%                      plotting maps of the components that project most strongly (at
%                      the selected frequency) to the the selected channel (or whole scalp 
%                      if 'plotchan' (above) == 0). spectopo() equivalent: 'icamaps'
%   "[Checked] Compute comp spectra ..." - [checkbox] If checked, compute the spectra 
%                      of the selected component activations; else, if unchecked 
%                      compute the spectra of (the data MINUS each selected component).
%                      spectopo() equivalent: 'icamode' 
%   "Plotting frequency range" - [edit box] [min max] Frequency range (in Hz) to plot.
%                      spectopo() equivalent: 'freqrange'
%   "Spectral and scalp map options (see topoplot)" - [edit box] 'key','val','key',... 
%                      sequence of arguments passed to spectopo() for details of the 
%                      spectral decomposition or to topoplot() to adjust details of 
%                      the scalp maps. For details see  >> help topoplot
% Inputs:
%   EEG         - Input EEGLAB dataset
%   dataflag    - If 1, process the input data channels. 
%                 If 0, process its component activations.
%                   {Default: 1, process the data channels}.
%   timerange   - [min_ms max_ms] Epoch time range to use in computing the spectra
%                   {Default: whole input epochs}
%   process     - 'EEG'|ERP'|'BOTH' If processing data epochs, work on either the
%                   mean single-trial 'EEG' spectra, the spectrum of the trial-average 
%                   'ERP', or plot 'BOTH' the EEG and ERP spectra. {Default: 'EEG'}
%
% Optional inputs:
%   'key','val'  - Optional topoplot() and/or spectopo() plotting arguments 
%                  {Default, 'electrodes','off'}
%
% Outputs: As from spectopo(). When nargin<2, a query window pops-up 
%          to ask for additional arguments and NO outputs are returned.
%          Note: Only the outputs of the 'ERP' spectral analysis 
%          are returned when plotting 'BOTH' ERP and EEG spectra.
%
% Author: Arnaud Delorme & Scott Makeig, CNL / Salk Institute, 10 March 2002
%
% See also: spectopo(), topoplot()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 10 March 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.48  2007/08/02 23:20:41  arno
% fix typo
%
% Revision 1.47  2007/08/02 23:15:14  arno
% adding icachaninds input
%
% Revision 1.46  2006/07/28 02:35:27  toby
% nothing changed
%
% Revision 1.45  2005/05/24 17:23:12  arno
% remove cell2mat
%
% Revision 1.44  2005/03/07 21:16:55  arno
% check for chaninfo
%
% Revision 1.43  2005/03/05 00:11:28  arno
% add chaninfo
%
% Revision 1.42  2005/01/24 00:33:24  arno
% debug plotting with no channel location
%
% Revision 1.41  2004/03/25 16:54:21  arno
% changing edit box text
%
% Revision 1.40  2003/08/11 17:27:59  arno
% command line problem fixed
%
% Revision 1.39  2003/08/11 15:40:01  arno
% text
%
% Revision 1.38  2003/05/12 23:33:18  arno
% verbose off, deteecting time limits
%
% Revision 1.37  2003/03/12 03:16:24  arno
% help update
%
% Revision 1.36  2003/02/26 17:48:01  arno
% correcting corrections
%
% Revision 1.35  2003/02/26 17:42:11  scott
% header edits -sm
%
% Revision 1.34  2003/02/26 17:40:35  scott
% header edits -sm
%
% Revision 1.33  2003/02/26 03:14:28  arno
% graphic interface help
%
% Revision 1.32  2003/01/28 18:02:42  arno
% adding warning messages if no channel location file
%
% Revision 1.31  2002/10/23 02:32:36  arno
% put tag to figure for spectopo to close
%
% Revision 1.30  2002/10/23 01:40:50  arno
% message - sm & ad
%
% Revision 1.29  2002/10/08 15:41:32  arno
% adding icawinv
%
% Revision 1.28  2002/09/05 00:10:09  arno
% update message
%
% Revision 1.27  2002/08/29 17:52:57  arno
% typo
%
% Revision 1.26  2002/08/20 04:25:31  scott
% text
%
% Revision 1.25  2002/08/16 19:15:50  scott
% worked on help msg and legends
%
% Revision 1.24  2002/08/13 18:37:24  scott
% make output window title 'spectopo()'
%
% Revision 1.23  2002/08/12 22:48:25  arno
% frequency range
%
% Revision 1.22  2002/08/12 22:31:03  arno
% edit
%
% Revision 1.21  2002/08/12 01:43:54  arno
% color
%
% Revision 1.20  2002/08/11 22:20:26  arno
% color
%
% Revision 1.19  2002/08/11 18:46:23  arno
% EEG and ERP options
%
% Revision 1.18  2002/08/09 01:33:18  arno
% debugging boundaries
%
% Revision 1.17  2002/08/09 01:13:15  arno
% debugging boundaries
%
% Revision 1.16  2002/08/09 00:54:35  arno
% adding boundaries for cont. data
%
% Revision 1.15  2002/08/09 00:45:42  arno
% text
%
% Revision 1.14  2002/07/30 18:13:23  arno
% same
%
% Revision 1.13  2002/07/30 18:11:04  arno
% debugging
%
% Revision 1.12  2002/07/29 22:25:58  arno
% updating message
%
% Revision 1.11  2002/07/29 22:15:50  arno
% reprogramming for spectopo component
%
% Revision 1.10  2002/07/28 21:23:00  arno
% adding message
%
% Revision 1.9  2002/07/28 21:00:36  arno
% debugging
%
% Revision 1.8  2002/07/26 01:59:53  arno
% debugging
%
% Revision 1.7  2002/07/24 18:16:49  arno
% changing default freqs
%
% Revision 1.6  2002/07/20 19:21:39  arno
% new spectopo compatibility
%
% Revision 1.5  2002/07/20 01:31:03  arno
% same
%
% Revision 1.4  2002/07/20 01:23:28  arno
% debuging varargin decoding
%
% Revision 1.3  2002/04/25 17:05:21  scott
% fruther editting -sm
%
% Revision 1.2  2002/04/25 17:00:47  scott
% editted help nd msgs, added % spectopo call to history -sm
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 03-15-02 debugging -ad
% 03-16-02 add all topoplot options -ad
% 04-04-02 added outputs -ad & sm

function varargout = pop_spectopo( EEG, dataflag, timerange, processflag, varargin);

varargout{1} = '';
if nargin < 1
	help pop_spectopo;
	return;
end;	

if nargin < 2
	dataflag = 1;
end;
if nargin < 3
	processflag = 'EEG';
end;

chanlocs_present = 0;
if ~isempty(EEG.chanlocs)
    if isfield(EEG.chanlocs, 'theta')
        chanlocs_present = 1;
    end;
end;

if nargin < 3
	if dataflag
		geometry = { [2 1] [2 1] [2 1] [2 1] [2 1] [2 1]};
        scalp_freq = fastif(chanlocs_present, { '6 10 22' }, { '' 'enable' 'off' });
		promptstr    = { { 'style' 'text' 'string' 'Epoch time range to analyze [min_ms max_ms]:' }, ...
						 { 'style' 'edit' 'string' [num2str( EEG.xmin*1000) ' ' num2str(EEG.xmax*1000)] }, ...
						 { 'style' 'text' 'string' 'Percent data to sample (1 to 100):'}, ...
						 { 'style' 'edit' 'string' '15' }, ...
						 { 'style' 'text' 'string' 'Frequencies to plot as scalp maps (Hz):'}, ...
						 { 'style' 'edit' 'string'  scalp_freq{:} }, ...
						 { 'style' 'text' 'string' 'Apply to EEG|ERP|BOTH:'}, ...
						 { 'style' 'edit' 'string' 'EEG' }, ...
						 { 'style' 'text' 'string' 'Plotting frequency range [lo_Hz hi_Hz]:'}, ...
						 { 'style' 'edit' 'string' '2 25' }, ...
						 { 'style' 'text' 'string' 'Spectral and scalp map options (see topoplot):' } ...
						 { 'style' 'edit' 'string' '''electrodes'',''off''' } };
		if EEG.trials == 1
			geometry(3) = [];
			promptstr(7:8) = [];
		end;
		result       = inputgui( geometry, promptstr, 'pophelp(''pop_spectopo'')', 'Channel spectra and maps -- pop_spectopo()');
		if size(result,1) == 0 return; end;
		timerange    = eval( [ '[' result{1} ']' ] );
		options = [];
        if isempty(EEG.chanlocs)
            disp('Topographic plot options ignored. First import a channel location file');  
            disp('To plot a single channel, use channel property menu or the following call');
            disp('  >> figure; chan = 1; spectopo(EEG.data(chan,:,:), EEG.pnts, EEG.srate);');
        end;
		if eval(result{2}) ~= 100, options = [ options ', ''percent'', '  result{2} ]; end;
		if ~isempty(result{3}) & ~isempty(EEG.chanlocs), options = [ options ', ''freq'', ['  result{3} ']' ]; end;
		if EEG.trials ~= 1
			processflag = result{4};
			if ~isempty(result{5}),    options = [ options ', ''freqrange'',[' result{5} ']' ]; end;
			if ~isempty(result{6}),    options = [ options ',' result{6} ]; end;
		else 
			if ~isempty(result{4}),    options = [ options ', ''freqrange'',[' result{4} ']' ]; end;
			if ~isempty(result{5}),    options = [ options ',' result{5} ]; end;
		end;
	else
		if ~chanlocs_present
			error('pop_spectopo(): cannot plot component contributions without channel locations');
		end;
		geometry = { [2 1] [2 1] [2 1] [2 1] [2 1] [2 1] [2 1] [2 0.18 0.78] [2 1] [2 1] };
		promptstr    = { { 'style' 'text' 'string' 'Epoch time range to analyze [min_ms max_ms]:' }, ...
						 { 'style' 'edit' 'string' [num2str( EEG.xmin*1000) ' ' num2str(EEG.xmax*1000)] }, ...
						 { 'style' 'text' 'string' 'Frequency (Hz) to analyze:'}, ...
						 { 'style' 'edit' 'string' '10' }, ...
						 { 'style' 'text' 'string' 'Electrode number to analyze ([]=elec with max power; 0=whole scalp):', 'tooltipstring', ...
						 ['If value is 1 to nchans, plot component contributions at this channel' 10 ...
						  'If value is [], plot contributions at channel with max. power' 10 ...
						  'If value is 0, plot component contributions to global (RMS) power'] }, ...
						 { 'style' 'edit' 'string' '0' }, ...
						 { 'style' 'text' 'string' 'Percent data to sample (1 to 100):'}, ...
						 { 'style' 'edit' 'string' '20' }, ...
						 { 'style' 'text' 'string' 'Components to include in the analysis:' }, ...
						 { 'style' 'edit' 'string' ['1:' int2str(size(EEG.icaweights,1))] }, ...
						 { 'style' 'text' 'string' 'Number of largest-contributing components to map:' }, ...
						 { 'style' 'edit' 'string' '5' }, ...
						 { 'style' 'text' 'string' '     Else, map only these component numbers:', 'tooltipstring', ...
						 ['Use this entry to override plotting maps of the components that project' 10 ...
						  'most strongly to the selected channel (or whole scalp) at the selected frequency.' ] }, ...
						 { 'style' 'edit' 'string' '' }, ...
						 { 'style' 'text' 'string' '[Checked] Compute comp spectra; [Unchecked] (data-comp) spectra:', 'tooltipstring' ...
						 ['If checked, compute the spectra of the selected component activations' 10 ...
						 'else [if unchecked], compute the spectra of (the data MINUS each slected component)']}, ...
						 { 'style' 'checkbox' 'value' 1 } { }, ...
						 { 'style' 'text' 'string' 'Plotting frequency range ([min max] Hz):'}, ...
						 { 'style' 'edit' 'string' '2 25' }, ...
						 { 'style' 'text' 'string' 'Spectral and scalp map options (see topoplot):' } ...
						 { 'style' 'edit' 'string' '''electrodes'',''off''' } };
		result       = inputgui( geometry, promptstr, 'pophelp(''spectopo'')', 'Component spectra and maps -- pop_spectopo()');
		if size(result,1) == 0 return; end;
		timerange    = eval( [ '[' result{1} ']' ] );
		options = '';
		if ~isempty(result{2})   , options = [ options ', ''freq'', ['  result{2} ']' ]; end;
		if ~isempty(result{3})   , options = [ options ', ''plotchan'', ' result{3} ]; end;
		if eval(result{4}) ~= 100, options = [ options ', ''percent'', '  result{4} ]; end;
		if ~isempty(result{5})   , options = [ options ', ''icacomps'', [' result{5} ']' ]; end;
		if ~isempty(result{6})   , options = [ options ', ''nicamaps'', ' result{6} ]; end;
		if ~isempty(result{7})   , options = [ options ', ''icamaps'', [' result{7} ']' ]; end;
		if ~result{8}, options = [ options ', ''icamode'', ''sub''' ]; end;
		if ~isempty(result{9}),    options = [ options ', ''freqrange'',[' result{9} ']' ]; end;
		if ~isempty(result{10}), options      =  [ options ',' result{10} ]; end;
	end;		
	figure('tag', 'spectopo');
        set(gcf,'Name','spectopo()');
else
    if ~isempty(varargin)
        options = [',' vararg2str(varargin)];
    else
        options = '';
    end;
	if isempty(timerange)
		timerange = [ EEG.xmin*1000 EEG.xmax*1000 ];
	end;
	if nargin < 3 
		percent = 100;
	end;
	if nargin < 4 
		topofreqs = [];
	end;
end;
try, icadefs; set(gcf, 'color', BACKCOLOR); catch, end;

switch processflag,
 case {'EEG' 'eeg' 'ERP' 'erp' 'BOTH' 'both'},;
 otherwise, if nargin <3, close; end; 
  error('Pop_spectopo: processflag must be ''EEG'', ''ERP'' or ''BOTH''');
end;
if EEG.trials == 1 & ~strcmp(processflag,'EEG')
	 if nargin <3, close; end;
	 error('pop_spectopo(): must use ''EEG'' mode when processing continuous data');
end;

if ~isempty(EEG.chanlocs)
    if ~isfield(EEG, 'chaninfo'), EEG.chaninfo = []; end;
	spectopooptions = [ options ', ''verbose'', ''off'', ''chanlocs'', EEG.chanlocs, ''chaninfo'', EEG.chaninfo' ];
	if dataflag == 0 % i.e. components
		spectopooptions = [ spectopooptions ', ''weights'', EEG.icaweights*EEG.icasphere' ];
	end;
else
	spectopooptions = options;
end;
if ~dataflag
    spectopooptions  = [ spectopooptions ', ''icawinv'', EEG.icawinv, ''icachansind'', EEG.icachansind' ];
end;

% The programming here is a bit redundant but it tries to optimize 
% memory usage.
% ----------------------------------------------------------------
if timerange(1)/1000~=EEG.xmin | timerange(2)/1000~=EEG.xmax
	posi = round( (timerange(1)/1000-EEG.xmin)*EEG.srate )+1;
	posf = min(round( (timerange(2)/1000-EEG.xmin)*EEG.srate )+1, EEG.pnts );
	pointrange = posi:posf;
	if posi == posf, error('pop_spectopo(): empty time range'); end;
	fprintf('pop_spectopo(): selecting time range %6.2f ms to %6.2f ms (points %d to %d)\n', ...
			timerange(1), timerange(2), posi, posf);
end;
if exist('pointrange') == 1, SIGTMP = EEG.data(EEG.icachansind,pointrange,:); totsiz = length( pointrange);
else                         SIGTMP = EEG.data(EEG.icachansind,:,:); totsiz = EEG.pnts;
end;

% add boundaries if continuous data
% ----------------------------------
if EEG.trials == 1 & ~isempty(EEG.event) & isfield(EEG.event, 'type') & isstr(EEG.event(1).type)
	boundaries = strmatch('boundary', {EEG.event.type});
	if ~isempty(boundaries)
		if exist('pointrange')
			boundaries = [ EEG.event(boundaries).latency ] - 0.5-pointrange(1)+1;
			boundaries(find(boundaries>=pointrange(end)-pointrange(1))) = [];
			boundaries(find(boundaries<1)) = [];
			boundaries = [0 boundaries pointrange(end)-pointrange(1)];
		else
			boundaries = [0 [ EEG.event(boundaries).latency ]-0.5 EEG.pnts ];
		end;
		spectopooptions = [ spectopooptions ',''boundaries'',[' int2str(round(boundaries)) ']']; 
	end;		
	fprintf('Pop_spectopo: finding data discontinuities\n');
end;

% outputs
% -------
outstr = '';
if nargin >= 2
	for io = 1:nargout, outstr = [outstr 'varargout{' int2str(io) '},' ]; end;
	if ~isempty(outstr), outstr = [ '[' outstr(1:end-1) '] =' ]; end;
end;

% plot the data and generate output and history commands
% ------------------------------------------------------
popcom = sprintf('figure; pop_spectopo(%s, %d, [%s], ''%s'' %s);', inputname(1), dataflag, num2str(timerange), processflag, options);
switch processflag
	case { 'EEG' 'eeg' }, SIGTMP = reshape(SIGTMP, size(SIGTMP,1), size(SIGTMP,2)*size(SIGTMP,3));
	            com = sprintf('%s spectopo( SIGTMP, totsiz, EEG.srate %s);', outstr, spectopooptions); 
                eval(com)
				
    case { 'ERP' 'erp' }, com = sprintf('%s spectopo( mean(SIGTMP,3), totsiz, EEG.srate %s);', outstr, spectopooptions); eval(com)
	case { 'BOTH' 'both' }, sbplot(2,1,1); com = sprintf('%s spectopo( mean(SIGTMP,3), totsiz, EEG.srate, ''title'', ''ERP'' %s);', outstr, spectopooptions); eval(com)
	             SIGTMP = reshape(SIGTMP, size(SIGTMP,1), size(SIGTMP,2)*size(SIGTMP,3));
				 sbplot(2,1,2); com = sprintf('%s spectopo( SIGTMP, totsiz, EEG.srate, ''title'', ''EEG'' %s);', outstr, spectopooptions); eval(com)
end;

if nargout < 2 & nargin < 3
	varargout{1} = popcom;
end;

return;

		
