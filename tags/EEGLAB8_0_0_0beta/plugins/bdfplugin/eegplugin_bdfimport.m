% eegplugin_ctfimport() - EEGLAB plugin for importing CTF data files.
%
% Usage:
%   >> eegplugin_ctfimport(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
%
% Notes:
%   This plugins consist of the following Matlab files:
%
% Create a plugin:
%   For more information on how to create an EEGLAB plugin see the
%   help message of eegplugin_besa() or visit http://www.sccn.ucsd.edu/eeglab/contrib.html
%
% Author: Arnaud Delorme (SCCN, UCSD) and Daren Weber (DNL, UCSF)
%         for the EEGLAB interface. Fredrick Carver (NIH) and Daren Weber for
%         the CTF Matlab reading functions.
%
% See also: pop_ctf_read(), ctf_read(), ctf_readmarkerfile()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2003 Arnaud Delorme, Salk Institute, arno@salk.edu
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
% Revision 1.2  2009/07/01 23:31:42  arno
% change mmenu
%
% Revision 1.1  2009/06/19 05:04:22  arno
% bdf plugin
%

function vers = eegplugin_ctfimport(fig, trystrs, catchstrs)

    vers = 'bdfimport';
    if nargin < 3
        error('eegplugin_bdfimport requires 3 arguments');
    end;
    
    % add folder to path
    % ------------------
    if ~exist('readbdf')
        p = which('eegplugin_bdfimport.m');
        p = p(1:findstr(p,'eegplugin_bdfimport.m')-1);
        addpath(p);
    end;
    
    % find import data menu
    % ---------------------
    menu = findobj(fig, 'tag', 'import data');
    
    % menu callbacks
    % --------------
    comcnt = [ trystrs.no_check '[EEG LASTCOM] = pop_readbdf;' catchstrs.new_and_hist ];
    
    % create menus
    % ------------
    uimenu( menu, 'label', 'From EDF/BDF file (secondary backup funct.)', 'callback', comcnt, 'separator', 'on' );
