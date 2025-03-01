% pop_preclust() - prepare STUDY components' location and activity measures for later clustering.
%                  Collect information in an interactive pop-up query window. To pre-cluster
%                  from the commandline, use std_preclust(). After data entry into the pop window,
%                  selected measures (one or more from options: ERP, dipole locations, spectra,
%                  scalp maps, ERSP, and ITC) are computed for each dataset in the STUDY 
%                  set, unless they already present. After all requested measures are computed 
%                  and saved in the STUDY datasets, a PCA  matrix (by runica() with 'pca' option) 
%                  is constructed (this is the feature reduction step). This matrix will be used 
%                  as input to the clustering  algorithm in pop_clust(). pop_preclust() allows 
%                  selection of a subset of components to cluster. This subset may either be 
%                  user-specified, all components with dipole model residual variance lower than 
%                  a defined threshold (see dipfit()), or components from an already existing cluster 
%                  (for hierarchical clustering). The EEG datasets in the ALLEEG structure are 
%                  updated; then the updated EEG sets are saved to disk.  Calls std_preclust().
% Usage:    
%                >> [STUDY, ALLEEG] = pop_preclust(STUDY, ALLEEG); % pop up interactive window
%                >> [STUDY, ALLEEG] = pop_preclust(STUDY, ALLEEG, clustind); % sub-cluster 
%
% Inputs:
%   STUDY        - STUDY set structure containing (loaded) EEG dataset structures
%   ALLEEG       - ALLEEG vector of EEG structures, else a single EEG dataset.
%   clustind     - (single) cluster index to sub-cluster, Hhierarchical clustering may be
%                  useful, for example, to separate a bilteral cluster into left and right 
%                  hemisphere sub-clusters. Should be empty for whole STUDY (top level) clustering 
%                  {default: []}
% Outputs:
%   STUDY        - the input STUDY set with added pre-clustering data for use by pop_clust() 
%   ALLEEG       - the input ALLEEG vector of EEG dataset structures modified by adding 
%                  pre-clustering data (pointers to .mat files that hold cluster measure information).
%
% Authors: Arnaud Delorme, Hilit Serby & Scott Makeig, SCCN, INC, UCSD, May 13, 2004-
%
% See also: std_preclust()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Hilit Serby, SCCN, INC, UCSD, May 13,2004, hilit@sccn.ucsd.edu
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
% Revision 1.54  2009/11/11 00:28:53  arno
% New GUI format
%
% Revision 1.53  2009/11/04 01:39:30  arno
% remove the option editor for spectral options
%
% Revision 1.52  2009/07/10 00:59:08  arno
% error if no dataset in STUDY
%
% Revision 1.51  2008/02/07 22:08:39  nima
% Measure Product preclustring added.
%
% Revision 1.50  2007/09/11 10:36:52  arno
% now can process ICA components
%
% Revision 1.49  2007/08/09 18:35:22  arno
% remove unused variable
%
% Revision 1.48  2007/08/06 20:20:55  arno
% roudning problem fix
%
% Revision 1.47  2007/04/10 16:24:29  arno
% matching exact names
%
% Revision 1.46  2007/04/07 01:21:27  arno
% *** empty log message ***
%
% Revision 1.45  2006/04/10 05:22:32  toby
% itc weight bug
%
% Revision 1.44  2006/03/29 00:47:59  toby
% dealing with NaNs in STUDY.setind
%
% Revision 1.43  2006/03/23 17:29:40  scott
% msg text
%
% Revision 1.42  2006/03/21 15:42:22  arno
% new .sets format
%
% Revision 1.41  2006/03/12 03:23:03  arno
% save study
%
% Revision 1.40  2006/03/12 02:17:26  arno
% remove fontsize
%
% Revision 1.39  2006/03/11 17:12:41  scott
% help and text msgs -sm
%
% Revision 1.38  2006/03/11 06:57:04  arno
% header
%
% Revision 1.37  2006/03/11 00:18:16  arno
% add function get_ersptime at the end
%
% Revision 1.36  2006/03/10 23:13:00  arno
% min time and max time for ERSP depend on low freq
%
% Revision 1.35  2006/03/10 22:56:24  arno
% timewindow
%
% Revision 1.34  2006/03/08 20:45:26  arno
% rename func
%
% Revision 1.33  2006/03/04 00:40:06  arno
% edit GUI
%
% Revision 1.32  2006/03/04 00:19:37  arno
% fixing edit boxes
%
% Revision 1.31  2006/03/03 23:47:40  arno
% decoding time-frequency parameters
%
% Revision 1.30  2006/03/02 23:18:54  scott
% editing window msgs  -sm
%
% Revision 1.29  2006/02/23 00:19:58  arno
% remove dipole selection option (now mved to pop_study)
%
% Revision 1.28  2006/02/22 23:33:42  arno
% implementing cluster hierarchy
%
% Revision 1.27  2006/02/22 21:21:23  arno
% update for hierarchic clustering
%
% Revision 1.26  2006/02/22 19:57:38  arno
% second level pca
%
% Revision 1.25  2006/02/18 01:00:38  arno
% eeg_preclust -> std_preclust
%
% Revision 1.24  2006/02/18 00:54:37  arno
% changing default value for ERSP and spectrum so it matches the tutorial one
%
% Revision 1.23  2006/02/16 23:11:46  arno
% ERSP -> ersp
%
% Revision 1.22  2006/02/11 00:29:56  arno
% ERSP and ITC parameters
%
% Revision 1.21  2006/02/11 00:17:47  arno
% fixing ersp parameters
%
% Revision 1.20  2006/02/11 00:15:40  arno
% fixing ERSP
%
% Revision 1.19  2006/02/11 00:12:01  arno
% fixing ERP selection
%
% Revision 1.18  2006/02/11 00:08:37  arno
% numeric conversion
%

function [STUDY, ALLEEG, com] = pop_preclust(varargin)

com = '';

if ~isstr(varargin{1}) %intial settings
    if length(varargin) < 2
        error('pop_preclust(): needs both ALLEEG and STUDY structures');
    end
    STUDY  = varargin{1};
    ALLEEG = varargin{2};
    if length(varargin) >= 3
        if length(varargin{3}) > 1
            error('pop_preclust(): To cluster components from several clusters, merge them first!');
        end
        cluster_ind = varargin{3};
    else
        cluster_ind = [];
    end
    
    scalp_options = {'Use channel values' 'Use Laplacian values' 'Use Gradient values'} ;
    
    if isempty(ALLEEG)
        error('STUDY contains no datasets');
    end
         
    % cluster text
    % ------------
    % load leaf clusters
    num_cls = 0;
    cls = 1:length(STUDY.cluster);
    N = length(cls); %number of clusters
    
    show_options{1} = [STUDY.cluster(1).name ' (' num2str(length(STUDY.cluster(1).comps))  ' ICs)'];
    cls(1) = 1;
    count = 2;
    for index1 = 1:length(STUDY.cluster(1).child)
        
        indclust1 = strmatch( STUDY.cluster(1).child(index1), { STUDY.cluster.name }, 'exact');
        show_options{count} = ['   ' STUDY.cluster(indclust1).name ' (' num2str(length(STUDY.cluster(indclust1).comps))  ' ICs)'];
        cls(count) = indclust1;
        count = count+1;
        
        for index2 = 1:length( STUDY.cluster(indclust1).child )
            indclust2 = strmatch( STUDY.cluster(indclust1).child(index2), { STUDY.cluster.name }, 'exact');
            show_options{count} = ['      ' STUDY.cluster(indclust2).name ' (' num2str(length(STUDY.cluster(indclust2).comps))  ' ICs)'];
            cls(count) = indclust2;
            count = count+1;
            
            for index3 = 1:length( STUDY.cluster(indclust2).child )
                indclust3 = strmatch( STUDY.cluster(indclust2).child(index3), { STUDY.cluster.name }, 'exact');
                show_options{count} = ['         ' STUDY.cluster(indclust3).name ' (' num2str(length(STUDY.cluster(indclust3).comps))  ' ICs)'];
                cls(count) = indclust3;
                count = count+1;
            end;
        end;
    end;

    % callbacks
    % ---------
    erspparams_str = [ '''cycles'', [3 0.5], ''padratio'', 1' ];
    specparams_str = '';
    show_clust      = [ 'pop_preclust(''showclust'',gcf);'];
    show_comps      = [ 'pop_preclust(''showcomplist'',gcf);'];
    help_spectopo =  ['pophelp(''spectopo'')'];         
	set_spectra  = ['pop_preclust(''setspec'',gcf);']; 
    set_erp      = ['pop_preclust(''seterp'',gcf);']; 
    set_scalp    = ['pop_preclust(''setscalp'',gcf);']; 
    set_dipole   = ['pop_preclust(''setdipole'',gcf);'];
    set_ersp     = ['pop_preclust(''setersp'',gcf);']; 
    set_itc      = ['pop_preclust(''setitc'',gcf);']; 
    set_secpca   = ['pop_preclust(''setsec'',gcf);']; 
    
    set_mpcluster   = ['tmp_preclust(''mpcluster'',gcf);']; % nima
    
    help_clusteron = ['pophelp(''std_helpselecton'');']; 
    help_ersp    = ['pophelp(''pop_timef'')'];
    preclust_PCA = ['pop_preclust(''preclustOK'',gcf);'];           
    ersp_params  = ['pop_preclust(''erspparams'',gcf);']; 
    ersp_edit    = ['pop_preclust(''erspedit'',gcf);']; 
    test_ersp    = ['pop_precomp(''testersp'',gcf);']; 
    itc_edit     = 'set(findobj(gcbf, ''tag'', ''ersp_params''), ''string'', get(gcbo, ''string''));';
    ersp_edit    = 'set(findobj(gcbf, ''tag'', ''itc_params'' ), ''string'', get(gcbo, ''string''));';
    
    saveSTUDY  = [ 'set(findobj(''parent'', gcbf, ''userdata'', ''save''), ''enable'', fastif(get(gcbo, ''value'')==1, ''on'', ''off''));' ];
    browsesave = [ '[filename, filepath] = uiputfile2(''*.study'', ''Save STUDY with .study extension -- pop_preclust()''); ' ... 
                  'set(findobj(''parent'', gcbf, ''tag'', ''studyfile''), ''string'', [filepath filename]);' ];
    str_name   = ['Build pre-clustering matrix for STUDY set:  ' STUDY.name '' ];
    str_time   = '';
    help_secpca = [ 'warndlg2(strvcat(''This is the final number of dimensions (otherwise use the sum'',' ...
                    '''of dimensions for all the selected options). See tutorial for more info''), ''Final number of dimensions'');' ];

    gui_spec = { ...
    {'style' 'text'       'string' str_name 'FontWeight' 'Bold' 'horizontalalignment' 'left'} ...
	{'style' 'text'       'string' 'Select the cluster to refine by sub-clustering (any existing sub-hierarchy will be overwritten)' } {} ...
    {'style' 'listbox'    'string' show_options 'value' 1 'tag' 'clus_list' 'Callback' show_clust 'max' 1 } {}  {} ...
    {'style' 'text'       'string' 'Note: Only measures that have been precomputed may be used for clustering.'} ...
    {'style' 'text'       'string' 'Measures                         Dims.   Norm.   Rel. Wt.' 'FontWeight' 'Bold'} ...
    {'style' 'checkbox'   'string' '' 'tag' 'spectra_on' 'value' 0 'Callback' set_spectra 'userdata' '1'}  ...
	{'style' 'text'       'string' 'spectra' 'horizontalalignment' 'center' } ...
	{'style' 'edit'       'string' '10' 'tag' 'spectra_PCA' 'enable' 'off' 'userdata' 'specP'} ...
    {'style' 'checkbox'   'string' '' 'tag' 'spectra_norm' 'value' 1 'enable' 'off' 'userdata' 'specP' } ...
    {'style' 'edit'       'string' '1' 'tag' 'spectra_weight' 'enable' 'off' 'userdata' 'specP'} ...
    {'style' 'text'       'string' 'Freq.range [Hz]' 'tag' 'spectra_freq_txt' 'userdata' 'spec' 'enable' 'off' } ...
	{'style' 'edit'       'string' '3  25'  'tag' 'spectra_freq_edit' 'userdata' 'spec' 'enable' 'off' } { } { } ...
    {'style' 'checkbox'   'string' '' 'tag' 'erp_on' 'value' 0 'Callback' set_erp 'userdata' '1'}  ...
	{'style' 'text'       'string' 'ERPs' 'horizontalalignment' 'center' } ...
    {'style' 'edit'       'string' '10' 'tag' 'erp_PCA' 'enable' 'off' 'userdata' 'erpP'} ...
    {'style' 'checkbox'   'string' '' 'tag' 'erp_norm' 'value' 1 'enable' 'off' 'userdata' 'erpP' } ...
    {'style' 'edit'       'string' '1' 'tag' 'erp_weight' 'enable' 'off' 'userdata' 'erpP'} ...
    {'style' 'text'       'string' 'Time range [ms]' 'tag' 'erp_time_txt' 'userdata' 'erp' 'enable' 'off' } ...
	{'style' 'edit'       'string' str_time 'tag' 'erp_time_edit' 'userdata' 'erp' 'enable' 'off' } { } { }...
	{'style' 'checkbox'   'string' '' 'tag' 'dipole_on' 'value' 0 'Callback' set_dipole 'userdata' '1'} ...
	{'style' 'text'       'string' 'dipoles' 'HorizontalAlignment' 'center' } ...
	{'style' 'text'       'string' '3' 'enable' 'off' 'userdata' 'dipoleP' } ...
	{'style' 'checkbox'   'string' '' 'tag' 'locations_norm' 'value' 1 'enable' 'off' 'userdata' 'dipoleP'}  ...
	{'style' 'edit'       'string' '10' 'tag' 'locations_weight' 'enable' 'off' 'userdata' 'dipoleP'} {} {} {} {} ...
    {'style' 'checkbox'   'string' '' 'tag' 'scalp_on' 'value' 0 'Callback' set_scalp 'userdata' '1'} ...
	{'style' 'text'       'string' 'scalp maps' 'HorizontalAlignment' 'center' } ...
	{'style' 'edit'       'string' '10' 'tag' 'scalp_PCA' 'enable' 'off' 'userdata' 'scalpP'} ...
    {'style' 'checkbox'   'string' '' 'tag' 'scalp_norm' 'value' 1 'enable' 'off' 'userdata' 'scalpP'}   ...
    {'style' 'edit'       'string' '1' 'tag' 'scalp_weight' 'enable' 'off' 'userdata' 'scalpP'} ...
    {'style' 'popupmenu'  'string' scalp_options 'value' 1 'tag' 'scalp_choice' 'enable' 'off' 'userdata' 'scalp' } {} ...
    {'style' 'checkbox'   'string' 'Absolute values' 'value' 1 'tag'  'scalp_absolute' 'enable' 'off' 'userdata' 'scalp' } {} ...
    {'style' 'checkbox'   'string' '' 'tag' 'ersp_on' 'value' 0 'Callback' set_ersp 'userdata' '1'} ...
	{'style' 'text'       'string' 'ERSPs' 'horizontalalignment' 'center' } ...
    {'style' 'edit'       'string' '10' 'tag' 'ersp_PCA' 'enable' 'off' 'userdata' 'erspP'} ...
    {'style' 'checkbox'   'string' '' 'tag' 'ersp_norm' 'value' 1 'enable' 'off' 'userdata' 'erspP'}   ...
	{'style' 'edit'       'string' '1' 'tag' 'ersp_weight' 'enable' 'off' 'userdata' 'erspP'} ...
    {'style' 'text'       'string' 'Time range [ms]' 'tag' 'ersp_time_txt' 'userdata' 'ersp' 'enable' 'off' } ...
	{'style' 'edit'       'string' str_time 'tag' 'ersp_time_edit' 'userdata' 'ersp' 'enable' 'off' } ...
    {'style' 'text'       'string' 'Freq. range [Hz]' 'tag' 'ersp_time_txt' 'userdata' 'ersp' 'enable' 'off' } ...
	{'style' 'edit'       'string' str_time 'tag' 'ersp_freq_edit' 'userdata' 'ersp' 'enable' 'off' } ...
    {'style' 'checkbox'   'string' '' 'tag' 'itc_on' 'value' 0 'Callback' set_itc 'userdata' '1'} ...
	{'style' 'text'       'string' 'ITCs' 'horizontalalignment' 'center' } ...
    {'style' 'edit'       'string' '10' 'tag' 'itc_PCA' 'enable' 'off' 'userdata' 'itcP'} ...
    {'style' 'checkbox'   'string' '' 'tag' 'itc_norm' 'value' 1 'enable' 'off' 'userdata' 'itcP'}   ...
	{'style' 'edit'       'string' '1' 'tag' 'itc_weight' 'enable' 'off' 'userdata' 'itcP'} ...
    {'style' 'text'       'string' 'Time range [ms]' 'tag' 'itc_time_txt' 'userdata' 'itcP' 'enable' 'off' } ...
	{'style' 'edit'       'string' str_time 'tag' 'itc_time_edit' 'userdata' 'itcP' 'enable' 'off' } ...
    {'style' 'text'       'string' 'Freq. range [Hz]' 'tag' 'itc_time_txt' 'userdata' 'itcP' 'enable' 'off' } ...
	{'style' 'edit'       'string' str_time 'tag' 'itc_freq_edit' 'userdata' 'itcP' 'enable' 'off' } ...
    {} ...
    {'style' 'checkbox'   'string' '' 'tag' 'sec_on' 'Callback' set_secpca 'value' 0} ...
	{'style' 'text'       'string' 'Final dimensions' } ...
    {'style' 'edit'       'string' '10' 'enable' 'off' 'tag' 'sec_PCA' 'userdata' 'sec' } ...
	{} {'style' 'pushbutton' 'string' 'Help' 'tag' 'finalDimHelp' 'callback' help_secpca } {} {} {} {} };
  

%    {'link2lines' 'style'  'text'   'string' '' } {} {} {} ...
%    {'style' 'text'       'string' 'Time/freq. parameters' 'tag' 'ersp_push' 'value' 1 'enable' 'off' 'userdata' 'ersp' 'Callback' ersp_params} ...
%    {'style' 'edit'       'string' erspparams_str 'tag' 'ersp_params' 'enable' 'off' 'userdata' 'ersp' 'Callback' ersp_edit}...
%    {'style' 'text'       'string' 'Time/freq. parameters' 'tag' 'itc_push' 'value' 1 'enable' 'off' 'userdata' 'itc' 'Callback' ersp_params} ...
%    {'style' 'edit'       'string' erspparams_str 'tag' 'itc_params' 'enable' 'off' 'userdata' 'itc' 'Callback' itc_edit}%    {'style' 'checkbox'   'string' '' 'tag' 'preclust_PCA'  'Callback' preclust_PCA 'value' 0} ...
%    {'style' 'text'       'string' 'Do not prepare dataset for clustering at this time.' 'FontWeight' 'Bold'  } {} ...

    fig_arg{1} = { ALLEEG STUDY cls };
    geomline = [0.5 2 1 0.5 1 2 1 2 1 ];
    geometry = { [1] [1] [1 1 1] [1] [1] ...
                 [3] geomline geomline geomline [0.5 2 1 0.5 1 2.9 .1 2.9 .1 ] geomline geomline [1] geomline };
    geomvert = [ 1 1 3 1 1 1 1 1 1 1 1 1 0.5 1 ];

    %if length(show_options) < 3
    %    gui_spec(2:6) = { {} ...
    %        { 'style' 'text'      'string' [ 'Among the pre-selected components (Edit study),' ...
    %                        'remove those which dipole res. var, exceed' ] 'tag' 'dipole_select_on' }  ...
    %        {'style' 'edit'       'string' '0.15' 'horizontalalignment' 'center' 'tag' 'dipole_rv'} ...
    %        {'style' 'text'       'string'  '(empty=all)'} {} };
    %    geometry{3} = [2.5 0.25 0.4];
    %    geomvert(3) = 1;
    %end;
    
	[preclust_param, userdat2, strhalt, os] = inputgui( 'geometry', geometry, 'uilist', gui_spec, 'geomvert', geomvert, ...
                                                      'helpcom', ' pophelp(''std_preclust'')', ...
                                                      'title', 'Select and compute component measures for later clustering -- pop_preclust()', ...
                                                      'userdata', fig_arg);	
	if isempty(preclust_param), return; end;
    
    options = { STUDY, ALLEEG };
    
    % precluster on what?
    % -------------------
    options{3} = cls(os.clus_list); % hierarchical clustering

    %if ~(os.preclust_PCA) %create PCA data for clustering
    %preclust_command = '[STUDY ALLEEG] = eeg_createdata(STUDY, ALLEEG, ';
    %end
    
    % Spectrum option is on
    % --------------------
    if os.spectra_on== 1 
        options{end+1} = {  'spec' 'npca' str2num(os.spectra_PCA) 'norm' os.spectra_norm ...
                            'weight' str2num(os.spectra_weight)  'freqrange' str2num(os.spectra_freq_edit) };
    end
    
    % ERP option is on
    % ----------------
    if os.erp_on == 1 
        options{end+1} = { 'erp' 'npca' str2num(os.erp_PCA) 'norm' os.erp_norm ...
                         'weight' str2num(os.erp_weight) 'timewindow' str2num(os.erp_time_edit) };
    end
    
    % Scalp maps option is on
    % ----------------------
    if os.scalp_on == 1 
        if os.scalp_absolute %absolute maps
            abso = 1;
        else abso = 0;
        end
        if (os.scalp_choice == 2)  %Laplacian scalp maps
            options{end+1} = { 'scalpLaplac' 'npca' str2num(os.scalp_PCA) 'norm' os.scalp_norm ...
                               'weight' str2num(os.scalp_weight) 'abso' abso };
        elseif (os.scalp_choice == 3)  %Gradient scalp maps
            options{end+1} = { 'scalpGrad' 'npca' str2num(os.scalp_PCA) 'norm' os.scalp_norm, ...
                               'weight' str2num(os.scalp_weight) 'abso' abso };
        elseif (os.scalp_choice == 1) %scalp map case
            options{end+1} = { 'scalp' 'npca' str2num(os.scalp_PCA) 'norm' os.scalp_norm, ...
                               'weight' str2num(os.scalp_weight) 'abso' abso };
        end
    end
    
    % Dipole option is on
    % -------------------
    if os.dipole_on == 1 
        options{end+1} = { 'dipoles' 'norm' os.locations_norm 'weight' str2num(os.locations_weight) };
    end
    
    % ERSP option is on
    % -----------------
    if os.ersp_on  == 1 
        options{end+1} = { 'ersp' 'npca' str2num(os.ersp_PCA) 'freqrange' str2num(os.ersp_freq_edit) ...
                          'timewindow' str2num(os.ersp_time_edit) 'norm' os.ersp_norm 'weight' str2num(os.ersp_weight) };
    end
    
    % ITC option is on 
    % ----------------
    if os.itc_on  == 1 
        options{end+1} = { 'itc' 'npca' str2num(os.itc_PCA) 'freqrange' str2num(os.itc_freq_edit) 'timewindow' ...
                           str2num(os.itc_time_edit) 'norm' os.itc_norm 'weight' str2num(os.itc_weight) };
    end       
    
    % ERSP option is on
    % -----------------
    if os.sec_on  == 1 
        options{end+1} = { 'finaldim' 'npca' str2num(os.sec_PCA) };
    end
    
    % evaluate command
    % ----------------
    if length(options) == 3
        warndlg2('No measure selected: aborting.'); 
        return; 
    end;
    
    [STUDY ALLEEG] = std_preclust(options{:});
    com = sprintf('%s\n[STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, %s);', ...
        STUDY.history, vararg2str(options(3:end)));
    
    % save updated STUDY to the disk
    % ------------------------------
%     if os.saveSTUDY == 1 
%         if ~isempty(os.studyfile)
%             [filepath filename ext] = fileparts(os.studyfile);
%             STUDY.filename = [ filename ext ];
%             STUDY.filepath = filepath;
%         end;
%         STUDY = pop_savestudy(STUDY, ALLEEG, 'filename', STUDY.filename, 'filepath', STUDY.filepath);
%         com = sprintf('%s\nSTUDY = pop_savestudy(STUDY, ALLEEG, %s);',  com, ...
%                       vararg2str( { 'filename', STUDY.filename, 'filepath', STUDY.filepath }));
%     end
else
    hdl = varargin{2}; %figure handle
    userdat = get(varargin{2}, 'userdat');    
    ALLEEG  = userdat{1}{1};
    STUDY   = userdat{1}{2};
    cls     = userdat{1}{3};
    N       = length(cls);

    switch  varargin{1}
               
        case 'setspec'
            set_spec =  get(findobj('parent', hdl, 'tag', 'spectra_on'), 'value'); 
            set(findobj('parent', hdl, 'userdata', 'spec'), 'enable', fastif(set_spec,'on','off'));
            PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
            if PCA_on
                set(findobj('parent', hdl, 'userdata', 'specP'), 'enable', 'off');
            else
                set(findobj('parent', hdl, 'userdata', 'specP'), 'enable', fastif(set_spec,'on','off'));
            end
            
        case 'mpcluster' % nima
            mpclust =  get(findobj('parent', hdl, 'tag', 'mpclust'), 'value');
            if mpclust
                set(findobj('parent', hdl, 'tag', 'spectra_PCA'), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'spectra_norm'), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'spectra_weight'), 'visible','off');
                set(findobj('parent', hdl, 'tag',  'erp_PCA' ), 'visible','off');
                set(findobj('parent', hdl, 'tag','erp_norm' ), 'visible','off');
                set(findobj('parent', hdl, 'tag','erp_weight' ), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'locations_norm' ), 'visible','off');
                set(findobj('parent', hdl, 'tag','locations_weight'), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'scalp_PCA'), 'visible','off');
                set(findobj('parent', hdl, 'tag','scalp_norm'  ), 'visible','off');
                set(findobj('parent', hdl, 'tag','scalp_weight'), 'visible','off');
                set(findobj('parent', hdl, 'tag','ersp_PCA'), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'ersp_norm'), 'visible','off');
                set(findobj('parent', hdl, 'tag','ersp_weight' ), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'itc_PCA'), 'visible','off');
                set(findobj('parent', hdl, 'tag','itc_norm'), 'visible','off');
                set(findobj('parent', hdl, 'tag','itc_weight'), 'visible','off');


                set(findobj('parent', hdl, 'tag','sec_PCA'), 'visible','off');
                set(findobj('parent', hdl, 'tag','sec_on'), 'visible','off');
                set(findobj('parent', hdl, 'userdata' ,'dipoleP'), 'visible','off');
                set(findobj('parent', hdl, 'string','Final dimensions'), 'visible','off');
                set(findobj('parent', hdl, 'tag','finalDimHelp' ), 'visible','off');
                set(findobj('parent', hdl, 'tag','spectra_freq_txt'), 'visible','off');
                set(findobj('parent', hdl, 'tag','spectra_freq_edit'), 'visible','off');

                %% these are made invisible for now,  but in future we might use them in the new method
                set(findobj('parent', hdl, 'tag','erp_time_txt'), 'visible','off');
                set(findobj('parent', hdl, 'tag','erp_time_edit'), 'visible','off');
                set(findobj('parent', hdl, 'tag','scalp_choice'), 'visible','off');
                set(findobj('parent', hdl, 'tag', 'scalp_absolute'), 'visible','off');
                set(findobj('parent', hdl, 'tag','ersp_time_txt'), 'visible','off');
                set(findobj('parent', hdl, 'tag','ersp_time_edit'), 'visible','off');
                set(findobj('parent', hdl, 'tag','ersp_freq_edit'), 'visible','off');
                set(findobj('parent', hdl, 'tag','itc_time_txt'), 'visible','off');
                set(findobj('parent', hdl, 'tag','itc_time_edit'), 'visible','off');
                set(findobj('parent', hdl, 'tag','itc_freq_edit'), 'visible','off');

                set(findobj('parent', hdl, 'string','Measures                         Dims.   Norm.   Rel. Wt.'), 'string','Measures');
            else
                set(findobj('parent', hdl, 'tag', 'spectra_PCA'), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'spectra_norm'), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'spectra_weight'), 'visible','on');
                set(findobj('parent', hdl, 'tag',  'erp_PCA' ), 'visible','on');
                set(findobj('parent', hdl, 'tag','erp_norm' ), 'visible','on');
                set(findobj('parent', hdl, 'tag','erp_weight' ), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'locations_norm' ), 'visible','on');
                set(findobj('parent', hdl, 'tag','locations_weight'), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'scalp_PCA'), 'visible','on');
                set(findobj('parent', hdl, 'tag','scalp_norm'  ), 'visible','on');
                set(findobj('parent', hdl, 'tag','scalp_weight'), 'visible','on');
                set(findobj('parent', hdl, 'tag','ersp_PCA'), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'ersp_norm'), 'visible','on');
                set(findobj('parent', hdl, 'tag','ersp_weight' ), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'itc_PCA'), 'visible','on');
                set(findobj('parent', hdl, 'tag','itc_norm'), 'visible','on');
                set(findobj('parent', hdl, 'tag','itc_weight'), 'visible','on');


                set(findobj('parent', hdl, 'tag','sec_PCA'), 'visible','on');
                set(findobj('parent', hdl, 'tag','sec_on'), 'visible','on');
                set(findobj('parent', hdl, 'userdata' ,'dipoleP'), 'visible','on');
                set(findobj('parent', hdl, 'string','Final dimensions'), 'visible','on');
                set(findobj('parent', hdl, 'tag','finalDimHelp' ), 'visible','on');
                set(findobj('parent', hdl, 'tag','spectra_freq_txt'), 'visible','on');
                set(findobj('parent', hdl, 'tag','spectra_freq_edit'), 'visible','on');

                %% these are made invisible for now,  but in future we might use them in the new method
                set(findobj('parent', hdl, 'tag','erp_time_txt'), 'visible','on');
                set(findobj('parent', hdl, 'tag','erp_time_edit'), 'visible','on');
                set(findobj('parent', hdl, 'tag','scalp_choice'), 'visible','on');
                set(findobj('parent', hdl, 'tag', 'scalp_absolute'), 'visible','on');
                set(findobj('parent', hdl, 'tag','ersp_time_txt'), 'visible','on');
                set(findobj('parent', hdl, 'tag','ersp_time_edit'), 'visible','on');
                set(findobj('parent', hdl, 'tag','ersp_freq_edit'), 'visible','on');
                set(findobj('parent', hdl, 'tag','itc_time_txt'), 'visible','on');
                set(findobj('parent', hdl, 'tag','itc_time_edit'), 'visible','on');
                set(findobj('parent', hdl, 'tag','itc_freq_edit'), 'visible','on');

                set(findobj('parent', hdl, 'string','Measures to Cluster on:'), 'string','Load                                  Dims.   Norm.   Rel. Wt.');
                set(findobj('parent', hdl, 'string','Measures'), 'string', 'Measures                         Dims.   Norm.   Rel. Wt.');
            end;

                
%             set_mpcluster =  get(findobj('parent', hdl, 'tag', 'spectra_on'), 'value'); 
%             set(findobj('parent', hdl, 'userdata', 'spec'), 'enable', fastif(set_spec,'on','off'));
%             PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
%             if PCA_on
%                 set(findobj('parent', hdl, 'userdata', 'specP'), 'enable', 'off');
%             else
%                 set(findobj('parent', hdl, 'userdata', 'specP'), 'enable', fastif(set_spec,'on','off'));
%             end         
            
            
            
        case 'seterp'
            set_erp =  get(findobj('parent', hdl, 'tag', 'erp_on'), 'value'); 
            set(findobj('parent', hdl, 'userdata', 'erp'), 'enable', fastif(set_erp,'on','off'));
            PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
            if PCA_on
                set(findobj('parent', hdl, 'userdata', 'erpP'), 'enable', 'off');
            else
                set(findobj('parent', hdl, 'userdata', 'erpP'), 'enable', fastif(set_erp,'on','off'));
            end
        case 'setscalp'
            set_scalp =  get(findobj('parent', hdl, 'tag', 'scalp_on'), 'value'); 
            set(findobj('parent', hdl, 'userdata', 'scalp'), 'enable', fastif(set_scalp,'on','off'));
            PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
            if PCA_on
                set(findobj('parent', hdl, 'userdata', 'scalpP'), 'enable', 'off');
            else
                set(findobj('parent', hdl, 'userdata', 'scalpP'), 'enable', fastif(set_scalp,'on','off'));
            end
        case 'setdipole'
            set_dipole =  get(findobj('parent', hdl, 'tag', 'dipole_on'), 'value'); 
            set(findobj('parent', hdl, 'userdata', 'dipole'), 'enable', fastif(set_dipole,'on','off'));
            PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
            if PCA_on
               set(findobj('parent', hdl, 'userdata', 'dipoleP'), 'enable','off');
           else
               set(findobj('parent', hdl, 'userdata', 'dipoleP'), 'enable', fastif(set_dipole,'on','off'));
           end
        case 'setersp'
            set_ersp =  get(findobj('parent', hdl, 'tag', 'ersp_on'), 'value'); 
            set(findobj('parent', hdl,'userdata', 'ersp'), 'enable', fastif(set_ersp,'on','off'));
            PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
            if PCA_on
                set(findobj('parent', hdl,'userdata', 'erspP'), 'enable', 'off');
            else
                set(findobj('parent', hdl,'userdata', 'erspP'), 'enable', fastif(set_ersp,'on','off'));
            end
            set_itc =  get(findobj('parent', hdl, 'tag', 'itc_on'), 'value'); 
            set(findobj('parent', hdl,'tag', 'ersp_push'), 'enable', fastif(set_itc,'off','on'));
            set(findobj('parent', hdl,'tag', 'ersp_params'), 'enable', fastif(set_itc,'off','on'));
             if  (set_itc & (~set_ersp) )
                set(findobj('parent', hdl,'tag', 'itc_push'), 'enable', 'on');
                set(findobj('parent', hdl,'tag', 'itc_params'), 'enable', 'on');
            end
       case 'setitc'
            set_itc =  get(findobj('parent', hdl, 'tag', 'itc_on'), 'value'); 
            set(findobj('parent', hdl,'userdata', 'itc'), 'enable', fastif(set_itc,'on','off'));
            PCA_on = get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value');
            if PCA_on
                set(findobj('parent', hdl,'userdata', 'itcP'), 'enable','off');
            else
                set(findobj('parent', hdl,'userdata', 'itcP'), 'enable', fastif(set_itc,'on','off'));
            end
            set_ersp = get(findobj('parent', hdl, 'tag', 'ersp_on'), 'value'); 
            set(findobj('parent', hdl,'tag', 'itc_push'), 'enable', fastif(set_ersp,'off','on'));
            set(findobj('parent', hdl,'tag', 'itc_params'), 'enable', fastif(set_ersp,'off','on'));
            if  (set_ersp & (~set_itc) )
                set(findobj('parent', hdl,'tag', 'ersp_push'), 'enable', 'on');
                set(findobj('parent', hdl,'tag', 'ersp_params'), 'enable', 'on');
            end
        case 'setsec'
            set_sec =  get(findobj('parent', hdl, 'tag', 'sec_on'), 'value'); 
            set(findobj('parent', hdl,'userdata', 'sec'), 'enable', fastif(set_sec,'on','off'));
        case 'erspparams'
            ersp = userdat{2};
            [ersp_paramsout, erspuserdat, strhalt, erspstruct] = inputgui( { [1] [3 1] [3 1] [3 1] [3 1] [3 1] [1]}, ...
                    { {'style' 'text' 'string' 'ERSP and ITC time/freq. parameters' 'FontWeight' 'Bold'} ...
                    {'style' 'text' 'string' 'Frequency range [Hz]' 'tag' 'ersp_freq' } ...
                    {'style' 'edit' 'string' ersp.f 'tag' 'ersp_f' 'Callback' ERSP_timewindow } ...
                    {'style' 'text' 'string' 'Wavelet cycles (see >> help timef())' 'tag' 'ersp_cycle' } ...
                    {'style' 'edit' 'string' ersp.c 'tag' 'ersp_c' 'Callback' ERSP_timewindow} ...    
                    {'style' 'text' 'string' 'Significance level (< 0.1)' 'tag' 'ersp_alpha' } ...
                    {'style' 'edit' 'string' ersp.a 'tag' 'ersp_a'} ...
                    {'style' 'text' 'string' 'timef() padratio' 'tag' 'ersp_pad' } ...
                    {'style' 'edit' 'string' ersp.p 'tag' 'ersp_p' 'Callback'  ERSP_timewindow} ...
					{'style' 'text' 'string' 'Desired time window within the indicated latency range [ms]' 'tag' 'ersp_trtxt' } ...
					{'style' 'edit' 'string' ersp.t 'tag' 'ersp_timewindow' 'Callback'  ERSP_timewindow} {} }, ...
 	                'pophelp(''pop_timef'')', 'Select clustering ERSP and ITC time/freq. parameters -- pop_preclust()');    
            if ~isempty(ersp_paramsout)
                ersp.f = erspstruct(1).ersp_f;
                ersp.c = erspstruct(1).ersp_c;
                ersp.p = erspstruct(1).ersp_p;
                ersp.a = erspstruct(1).ersp_a;
                ersp.t = erspstruct(1).ersp_timewindow;
                userdat{2} = ersp;
                set(findobj('parent', hdl, 'tag', 'ersp_params'), 'string', ...
                    ['                                                             ''frange'', [' ersp.f '], ''cycles'', [' ...
                     ersp.c '], ''alpha'', ' ersp.a ', ''padratio'', ' ersp.p ', ''tlimits'', [' ersp.t ']']);
                set(findobj('parent', hdl, 'tag', 'itc_params'), 'string', ...
                    ['                                                             ''frange'', [' ersp.f '], ''cycles'', [' ...
                     ersp.c '], ''alpha'', ' ersp.a ', ''padratio'', ' ersp.p ', ''tlimits'', [' ersp.t ']']);
                set(hdl, 'userdat',userdat); 
            end
       case 'preclustOK'
           set_PCA =  get(findobj('parent', hdl, 'tag', 'preclust_PCA'), 'value'); 
           set_ersp =  get(findobj('parent', hdl, 'tag', 'ersp_on'), 'value'); 
           set(findobj('parent', hdl,'userdata', 'erspP'), 'enable', fastif(~set_PCA & set_ersp,'on','off'));
           set_itc =  get(findobj('parent', hdl, 'tag', 'itc_on'), 'value'); 
           set(findobj('parent', hdl,'userdata', 'itcP'), 'enable', fastif(~set_PCA & set_itc,'on','off'));
           set_erp =  get(findobj('parent', hdl, 'tag', 'erp_on'), 'value'); 
           set(findobj('parent', hdl,'userdata', 'erpP'), 'enable', fastif(~set_PCA & set_erp,'on','off'));
           set_spec =  get(findobj('parent', hdl, 'tag', 'spectra_on'), 'value'); 
           set(findobj('parent', hdl,'userdata', 'specP'), 'enable', fastif(~set_PCA & set_spec,'on','off'));
           set_scalp =  get(findobj('parent', hdl, 'tag', 'scalp_on'), 'value'); 
           set(findobj('parent', hdl,'userdata', 'scalpP'), 'enable', fastif(~set_PCA & set_scalp,'on','off'));
           set_dipole =  get(findobj('parent', hdl, 'tag', 'dipole_on'), 'value'); 
           set(findobj('parent', hdl,'userdata', 'dipoleP'), 'enable', fastif(~set_PCA & set_dipole,'on','off'));
           set(findobj('parent', hdl,'tag', 'chosen_component'), 'enable', fastif(~set_PCA,'on','off'));
           set(findobj('parent', hdl,'tag', 'dipole_rv'), 'enable', fastif(~set_PCA,'on','off'));
           set(findobj('parent', hdl,'tag', 'compstd_str'), 'enable', fastif(~set_PCA,'on','off'));
    end
end
STUDY.saved = 'no';
