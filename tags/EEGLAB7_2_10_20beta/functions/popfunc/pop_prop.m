% pop_prop() - plot the properties of a channel or of an independent
%              component. 
% Usage:
%   >> pop_prop( EEG);           % pops up a query window 
%   >> pop_prop( EEG, typecomp); % pops up a query window 
%   >> pop_prop( EEG, typecomp, chanorcomp, winhandle,spectopo_options);
%
% Inputs:
%   EEG        - EEGLAB dataset structure (see EEGGLOBAL)
%
% Optional inputs:
%   typecomp   - [0|1] 1 -> display channel properties 
%                0 -> component properties {default: 1 = channel}
%   chanorcomp - channel or component number[s] to display {default: 1}
%
%   winhandle  - if this parameter is present or non-NaN, buttons 
%                allowing the rejection of the component are drawn. 
%                If non-zero, this parameter is used to back-propagate
%                the color of the rejection button.
%   spectopo_options - [cell array] optional cell arry of options for 
%                the spectopo() function.
% 
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: pop_runica(), eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
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
%
% 'erp_vltg_ticks' option added to erpimage calls for epoched data.  This
% makes ERP/ERA plots under ERPimages more readable by limiting the number
% of y-ticks to 2. Minor 'ei_smooth == 1' bug changed to 'ei_smooth = 1'
% and some mistaken typecomp comments fixed. -DG
%
% Revision 1.43  2008/02/29 16:09:42  arno
% fixing (again) the buggy erpimage plot for continuous data
%
% Revision 1.42  2007/11/29 22:05:45  arno
% change text in gui
%
% Revision 1.41  2007/11/29 22:04:22  arno
% hostory for multiple plots
%
% Revision 1.40  2007/11/29 22:01:44  arno
% multi-plot frequency limits
%
% Revision 1.39  2007/11/29 21:55:56  arno
% indent
%
% Revision 1.38  2007/08/04 05:18:46  scott
% filled in help msg, var numcompo -> chanorcomp; added chanorcomp default
%
% Revision 1.37  2007/04/20 01:17:30  toby
% ERPIMAGELINES misspelled ERPIMAGESLINES at line 320. BUG 286
%
% Revision 1.36  2007/04/18 00:20:33  toby
% Bug 280, incorrect reshape call, fixed
%
% Revision 1.35  2007/01/26 18:03:09  arno
% do not know
%
% Revision 1.33  2006/11/22 21:28:11  arno
% scott fix crashed, reverting to previous version
%
% Revision 1.31  2006/11/07 19:17:09  toby
% changed topoplot title -sm
%
% Revision 1.30  2006/11/07 18:40:42  toby
% debug same -sm
%
% Revision 1.29  2006/11/07 18:39:24  toby
% added skip if data too small for erpimage -sm
%
% Revision 1.28  2006/11/07 18:35:18  toby
% added Continuous data title to erpimage if continuous data
%
% Revision 1.27  2006/11/07 18:32:16  toby
% debug same
%
% Revision 1.26  2006/11/07 18:30:16  toby
% added erpimage if continuous data
%
% Revision 1.25  2006/02/13 23:26:31  arno
% changing default label
%
% Revision 1.24  2006/01/31 20:20:52  arno
% options
%
% Revision 1.23  2006/01/31 20:16:47  arno\
% options
%
% Revision 1.22  2005/09/05 21:25:14  scott
% added pop_prop() to title of properties figure -sm
%
% Revision 1.21  2005/03/05 00:09:11  arno
% chaninfo
%
% Revision 1.20  2004/07/29 23:32:26  arno
% fixing spectra limits
%
% Revision 1.19  2004/07/29 23:13:55  arno
% debug typecomp
%
% Revision 1.18  2004/03/18 00:31:05  arno
% remove skirt
%
% Revision 1.17  2004/02/23 15:45:00  scott
% changed erpimage smoothing width to 1 when EEG.trials < 6
%
% Revision 1.16  2004/02/23 15:37:35  scott
% same
%
% Revision 1.15  2004/02/23 15:36:16  scott
% added 'shrink','skirt' to topoplot calls
%
% Revision 1.14  2003/04/18 00:51:16  arno
% nromalizing component spectrum by map RMS
%
% Revision 1.13  2003/04/16 15:42:32  arno
% help command
%
% Revision 1.12  2003/01/30 17:23:37  arno
% allowing to plot several component properties
%
% Revision 1.11  2003/01/02 16:40:40  arno
% erpimage 1/4 -> 2/3 caxis  - sm
%
% Revision 1.10  2002/10/15 17:19:32  arno
% visible on/off
% /
%
% Revision 1.9  2002/10/13 23:49:07  arno
% use nan_mean instead of mean
%
% Revision 1.8  2002/10/13 21:41:23  arno
% undo last change
%
% Revision 1.7  2002/10/12 01:24:10  arno
% update mean power
%
% Revision 1.6  2002/10/08 14:46:49  arno
% adding global offset
%
% Revision 1.5  2002/10/07 23:04:42  arno
% topography" -> "map"
%
% Revision 1.4  2002/09/05 16:36:45  arno
% default plotting location
%
% Revision 1.3  2002/09/04 23:46:30  arno
% debug
%
% Revision 1.2  2002/09/04 23:18:35  arno
% addding typecomp for output command
%
% Revision 1.1  2002/09/04 23:13:59  arno
% Initial revision
%
% Revision 1.17  2002/09/04 23:12:51  arno
% channel property
%
% Revision 1.16  2002/08/20 21:45:18  arno
% title/button overlap
%
% Revision 1.15  2002/08/12 22:41:03  arno
% [A[Adebug help button
%
% Revision 1.14  2002/08/12 21:01:15  arno
% text
%
% Revision 1.13  2002/08/12 16:24:15  arno
% [6~inputdlg2
%
% Revision 1.12  2002/08/12 14:59:42  arno
% button color
%
% Revision 1.11  2002/08/12 01:30:43  arno
% color
%
% Revision 1.10  2002/08/11 20:49:49  arno
% color
%
% Revision 1.9  2002/07/29 00:42:00  arno
% debugging
%
% Revision 1.8  2002/07/18 16:03:44  arno
% using spectopo to compute spectrum
%
% Revision 1.7  2002/07/12 16:46:19  arno
% accept button update
%
% Revision 1.6  2002/04/23 21:14:27  scott
% [same] -sm
%
% Revision 1.5  2002/04/23 21:13:02  scott
% test for EEG.icaact -> EEG.icaweights  -sm
%
% Revision 1.4  2002/04/07 20:24:47  scott
% adjusting erpimage title position -sm
%
% Revision 1.3  2002/04/07 20:01:44  scott
% dealing with title() in erpimage with 'erp' -sm
%
% Revision 1.2  2002/04/07 19:48:25  scott
% added 'erp' to erpimage -sm
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision

% hidden parameter winhandle

% 01-25-02 reformated help & license -ad 
% 02-17-02 removed event index option -ad
% 03-17-02 debugging -ad & sm
% 03-18-02 text settings -ad & sm
% 03-18-02 added title -ad & sm

function com = pop_prop(EEG, typecomp, chanorcomp, winhandle, spec_opt)

com = '';
if nargin < 1
	help pop_prop;
	return;   
end;
if nargin < 5
	spec_opt = {};
end;
if nargin == 1
	typecomp = 1;    % defaults
        chanorcomp = 1;
end;
if typecomp == 0 & isempty(EEG.icaweights)
   error('No ICA weights recorded for this dataset -- first run ICA on it');
end;   
if nargin == 2
	promptstr    = { fastif(typecomp,'Channel index(ices) to plot:','Component index(ices) to plot:') ...
                     'Spectral options (see spectopo() help):' };
	inistr       = { '1' '''freqrange'', [2 50]' };
	result       = inputdlg2( promptstr, 'Component properties - pop_prop()', 1,  inistr, 'pop_prop');
	if size( result, 1 ) == 0 return; end;
   
	chanorcomp   = eval( [ '[' result{1} ']' ] );
    spec_opt     = eval( [ '{' result{2} '}' ] );
end;

% plotting several component properties
% -------------------------------------
if length(chanorcomp) > 1
    for index = chanorcomp
        pop_prop(EEG, typecomp, index, 0, spec_opt);  % call recursively for each chanorcomp
    end;
	com = sprintf('pop_prop( %s, %d, [%s], NaN, %s);', inputname(1), ...
                  typecomp, int2str(chanorcomp), vararg2str( { spec_opt } ));
    return;
end;

if chanorcomp < 1 | chanorcomp > EEG.nbchan % should test for > number of components ??? -sm
   error('Component index out of range');
end;   

% assumed input is chanorcomp
% -------------------------
try, icadefs; 
catch, 
	BACKCOLOR = [0.8 0.8 0.8];
	GUIBUTTONCOLOR   = [0.8 0.8 0.8]; 
end;
basename = [fastif(typecomp,'Channel ', 'Component ') int2str(chanorcomp) ];

fh = figure('name', ['pop_prop() - ' basename ' properties'], 'color', BACKCOLOR, 'numbertitle', 'off', 'visible', 'off');
pos = get(gcf,'Position');
set(gcf,'Position', [pos(1) pos(2)-500+pos(4) 500 500], 'visible', 'on');
pos = get(gca,'position'); % plot relative to current axes
hh = gca;
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;
axis off;

% plotting topoplot
% -----------------
h = axes('Units','Normalized', 'Position',[-10 60 40 42].*s+q);

%topoplot( EEG.icawinv(:,chanorcomp), EEG.chanlocs); axis square; 

if typecomp == 1 % plot single channel locations
	topoplot( chanorcomp, EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
             'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12); axis square;
else             % plot component map
	topoplot( EEG.icawinv(:,chanorcomp), EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
             'shading', 'interp', 'numcontour', 3); axis square;
end;
basename = [fastif(typecomp,'Channel ', 'IC') int2str(chanorcomp) ];
% title([ basename fastif(typecomp, ' location', ' map')], 'fontsize', 14); 
title(basename, 'fontsize', 14); 

% plotting erpimage
% -----------------
hhh = axes('Units','Normalized', 'Position',[45 62 48 38].*s+q);
eeglab_options; 
if EEG.trials > 1
    % put title at top of erpimage
    axis off
    hh = axes('Units','Normalized', 'Position',[45 62 48 38].*s+q);
    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
    if EEG.trials < 6
      ei_smooth = 1;
    else
      ei_smooth = 3;
    end
    if typecomp == 1 % plot channel
         offset = nan_mean(EEG.data(chanorcomp,:));
         erp=nan_mean(squeeze(EEG.data(chanorcomp,:,:))')-offset;
         erp_limits=get_era_limits(erp);
         erpimage( EEG.data(chanorcomp,:)-offset, ones(1,EEG.trials)*10000, EEG.times , ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp','erp_vltg_ticks',erp_limits);   
    else % plot component
          if option_computeica  
                  offset = nan_mean(EEG.icaact(chanorcomp,:));
                  era=nan_mean(squeeze(EEG.icaact(chanorcomp,:,:))')-offset;
                  era_limits=get_era_limits(era);
                  erpimage( EEG.icaact(chanorcomp,:)-offset, ones(1,EEG.trials)*10000, EEG.times , ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp', 'yerplabel', '','erp_vltg_ticks',era_limits);   
          else
                  icaacttmp = (EEG.icaweights(chanorcomp,:) * EEG.icasphere) ...
                                   * reshape(EEG.data(EEG.icachansind,:,:), length(EEG.icachansind), EEG.trials*EEG.pnts);
                  offset = nan_mean(icaacttmp);
                  era=nan_mean(reshape(icaacttmp,EEG.pnts,EEG.trials)')-offset;
                  era_limits=get_era_limits(era);
                  erpimage( icaacttmp-offset, ones(1,EEG.trials)*10000, EEG.times, ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp', 'yerplabel', '','erp_vltg_ticks',era_limits);  
          end;
    end;
    axes(hhh);
    title(sprintf('%s activity \\fontsize{10}(global offset %3.3f)', basename, offset), 'fontsize', 14);
else
    % put title at top of erpimage
    EI_TITLE = 'Continous data';
    axis off
    hh = axes('Units','Normalized', 'Position',[45 62 48 38].*s+q);
    ERPIMAGELINES = 200; % show 200-line erpimage
    while size(EEG.data,2) < ERPIMAGELINES*EEG.srate
       ERPIMAGELINES = round(0.9 * ERPIMAGELINES);
    end
    if ERPIMAGELINES > 2   % give up if data too small
        if ERPIMAGELINES < 10
            ei_smooth = 1;
        else
            ei_smooth = 3;
        end
      erpimageframes = floor(size(EEG.data,2)/ERPIMAGELINES);
      erpimageframestot = erpimageframes*ERPIMAGELINES;
      eegtimes = linspace(0, erpimageframes-1, EEG.srate/1000);
      if typecomp == 1 % plot channel
           offset = nan_mean(EEG.data(chanorcomp,:));
           % Note: we don't need to worry about ERP limits, since ERPs
           % aren't visualized for continuous data
           erpimage( reshape(EEG.data(chanorcomp,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset, ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                         EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar');  
      else % plot component
            if option_computeica  
                offset = nan_mean(EEG.icaact(chanorcomp,:));
                % Note: we don't need to worry about ERA limits, since ERAs
                % aren't visualized for continuous data
                erpimage(reshape(EEG.icaact(chanorcomp,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset,ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                    EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar','yerplabel', '');
            else
                icaacttmp = EEG.icaweights(chanorcomp,:) * EEG.icasphere ...
                    * EEG.data(EEG.icachansind,1:erpimageframestot);
                offset = nan_mean(icaacttmp);
                % Note: we don't need to worry about ERA limits, since ERAs
                % aren't visualized for continuous data
                erpimage( icaacttmp-offset, ones(1,ERPIMAGELINES)*10000, eegtimes, ...
                    EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar', 'yerplabel', '');
            end;
      end
    else
            axis off;
            text(0.1, 0.3, [ 'No erpimage plotted' 10 'for small continuous data']);
    end;
    axes(hhh);
end;	

% plotting spectrum
% -----------------
if ~exist('winhandle')
    winhandle = NaN;
end;
if ~isnan(winhandle)
	h = axes('units','normalized', 'position',[5 10 95 35].*s+q);
else
	h = axes('units','normalized', 'position',[5 0 95 40].*s+q);
end;
%h = axes('units','normalized', 'position',[45 5 60 40].*s+q);
try
	eeglab_options; 
	if typecomp == 1
		[spectra freqs] = spectopo( EEG.data(chanorcomp,:), EEG.pnts, EEG.srate, spec_opt{:} );
	else 
		if option_computeica  
			[spectra freqs] = spectopo( EEG.icaact(chanorcomp,:), EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,chanorcomp), spec_opt{:} );
        else
    		icaacttmp = (EEG.icaweights(chanorcomp,:)*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts); 
			[spectra freqs] = spectopo( icaacttmp, EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,chanorcomp), spec_opt{:} );
		end;
	end;
    % set up new limits
    % -----------------
    %freqslim = 50;
	%set(gca, 'xlim', [0 min(freqslim, EEG.srate/2)]);
    %spectra = spectra(find(freqs <= freqslim));
	%set(gca, 'ylim', [min(spectra) max(spectra)]);
    
	%tmpy = get(gca, 'ylim');
    %set(gca, 'ylim', [max(tmpy(1),-1) tmpy(2)]);
	set( get(gca, 'ylabel'), 'string', 'Power 10*log_{10}(\muV^{2}/Hz)', 'fontsize', 14); 
	set( get(gca, 'xlabel'), 'string', 'Frequency (Hz)', 'fontsize', 14); 
	title('Activity power spectrum', 'fontsize', 14); 
catch
	axis off;
	text(0.1, 0.3, [ 'Error: no spectrum plotted' 10 ' make sure you have the ' 10 'signal processing toolbox']);
end;	
	
% display buttons
% ---------------

if ~isnan(winhandle)
	COLREJ = '[1 0.6 0.6]';
	COLACC = '[0.75 1 0.75]';
	% CANCEL button
	% -------------
	h  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Cancel', 'Units','Normalized','Position',[-10 -10 15 6].*s+q, 'callback', 'close(gcf);');

	% VALUE button
	% -------------
	hval  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Values', 'Units','Normalized', 'Position', [15 -10 15 6].*s+q);

	% REJECT button
	% -------------
	status = EEG.reject.gcompreject(chanorcomp);
	hr = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', eval(fastif(status,COLREJ,COLACC)), ...
				'string', fastif(status, 'REJECT', 'ACCEPT'), 'Units','Normalized', 'Position', [40 -10 15 6].*s+q, 'userdata', status, 'tag', 'rejstatus');
	command = [ 'set(gcbo, ''userdata'', ~get(gcbo, ''userdata''));' ...
				'if get(gcbo, ''userdata''),' ...
				'     set( gcbo, ''backgroundcolor'',' COLREJ ', ''string'', ''REJECT'');' ...
				'else ' ...
				'     set( gcbo, ''backgroundcolor'',' COLACC ', ''string'', ''ACCEPT'');' ...
				'end;' ];					
	set( hr, 'callback', command); 

	% HELP button
	% -------------
	h  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'HELP', 'Units','Normalized', 'Position', [65 -10 15 6].*s+q, 'callback', 'pophelp(''pop_prop'');');

	% OK button
	% ---------
 	command = [ 'global EEG;' ...
 				'tmpstatus = get( findobj(''parent'', gcbf, ''tag'', ''rejstatus''), ''userdata'');' ...
 				'EEG.reject.gcompreject(' num2str(chanorcomp) ') = tmpstatus;' ]; 
	if winhandle ~= 0
	 	command = [ command ...
	 				sprintf('if tmpstatus set(%3.15f, ''backgroundcolor'', %s); else set(%3.15f, ''backgroundcolor'', %s); end;', ...
					winhandle, COLREJ, winhandle, COLACC)];
	end;				
	command = [ command 'close(gcf); clear tmpstatus' ];
	h  = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'backgroundcolor', GUIBUTTONCOLOR, 'Units','Normalized', 'Position',[90 -10 15 6].*s+q, 'callback', command);

	% draw the figure for statistical values
	% --------------------------------------
	index = num2str( chanorcomp );
	command = [ ...
		'figure(''MenuBar'', ''none'', ''name'', ''Statistics of the component'', ''numbertitle'', ''off'');' ...
		'' ...
		'pos = get(gcf,''Position'');' ...
		'set(gcf,''Position'', [pos(1) pos(2) 340 340]);' ...
		'pos = get(gca,''position'');' ...
		'q = [pos(1) pos(2) 0 0];' ...
		's = [pos(3) pos(4) pos(3) pos(4)]./100;' ...
		'axis off;' ...
		''  ...
		'txt1 = sprintf(''(\n' ...
						'Entropy of component activity\t\t%2.2f\n' ...
					    '> Rejection threshold \t\t%2.2f\n\n' ...
					    ' AND                 \t\t\t----\n\n' ...
					    'Kurtosis of component activity\t\t%2.2f\n' ...
					    '> Rejection threshold \t\t%2.2f\n\n' ...
					    ') OR                  \t\t\t----\n\n' ...
					    'Kurtosis distibution \t\t\t%2.2f\n' ...
					    '> Rejection threhold\t\t\t%2.2f\n\n' ...
					    '\n' ...
					    'Current thesholds sujest to %s the component\n\n' ...
					    '(after manually accepting/rejecting the component, you may recalibrate thresholds for future automatic rejection on other datasets)'',' ...
						'EEG.stats.compenta(' index '), EEG.reject.threshentropy, EEG.stats.compkurta(' index '), ' ...
						'EEG.reject.threshkurtact, EEG.stats.compkurtdist(' index '), EEG.reject.threshkurtdist, fastif(EEG.reject.gcompreject(' index '), ''REJECT'', ''ACCEPT''));' ...
		'' ...				
		'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-11 4 117 100].*s+q, ''Style'', ''frame'' );' ...
		'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-5 5 100 95].*s+q, ''String'', txt1, ''Style'',''text'', ''HorizontalAlignment'', ''left'' );' ...
		'h = uicontrol(gcf, ''Style'', ''pushbutton'', ''string'', ''Close'', ''Units'',''Normalized'', ''Position'', [35 -10 25 10].*s+q, ''callback'', ''close(gcf);'');' ...
		'clear txt1 q s h pos;' ];
	set( hval, 'callback', command); 
	if isempty( EEG.stats.compenta )
		set(hval, 'enable', 'off');
	end;
	
	com = sprintf('pop_prop( %s, %d, %d, 0, %s);', inputname(1), typecomp, chanorcomp, vararg2str( { spec_opt } ) );
else
	com = sprintf('pop_prop( %s, %d, %d, NaN, %s);', inputname(1), typecomp, chanorcomp, vararg2str( { spec_opt } ) );
end;

return;

function out = nan_mean(in)

    nans = find(isnan(in));
    in(nans) = 0;
    sums = sum(in);
    nonnans = ones(size(in));
    nonnans(nans) = 0;
    nonnans = sum(nonnans);
    nononnans = find(nonnans==0);
    nonnans(nononnans) = 1;
    out = sum(in)./nonnans;
    out(nononnans) = NaN;

    
function era_limits=get_era_limits(era)
%function era_limits=get_era_limits(era)
%
% Returns the minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)
%
% Inputs:
% era - [vector] Event related activation or potential
%
% Output:
% era_limits - [min max] minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)

mn=min(era);
mx=max(era);
mn=orderofmag(mn)*round(mn/orderofmag(mn));
mx=orderofmag(mx)*round(mx/orderofmag(mx));
era_limits=[mn mx];


function ord=orderofmag(val)
%function ord=orderofmag(val)
%
% Returns the order of magnitude of the value of 'val' in multiples of 10
% (e.g., 10^-1, 10^0, 10^1, 10^2, etc ...)
% used for computing erpimage trial axis tick labels as an alternative for
% plotting sorting variable

val=abs(val);
if val>=1
    ord=1;
    val=floor(val/10);
    while val>=1,
        ord=ord*10;
        val=floor(val/10);
    end
    return;
else
    ord=1/10;
    val=val*10;
    while val<1,
        ord=ord/10;
        val=val*10;
    end
    return;
end

