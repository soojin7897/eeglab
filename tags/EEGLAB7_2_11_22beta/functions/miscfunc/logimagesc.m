% logimagesc() - make an imagesc(0) plot with log y-axis values (ala semilogy())
%
% Usage:  >> [logfreqs,dataout] = logimagesc(times,freqs,data);
%
% Input:
%   times = vector of x-axis values
%   freqs = vector of y-axis values
%   data  = matrix of size (freqs,times)
%
% Optional Input:
%   plot = ['on'|'off'] plot image or return output (default 'on').
%
% Note: Entering text() onto the image requires specifying (x,log(y)).

% Author: Scott Makeig, SCCN/INC/UCSD, La Jolla, 4/2000 

% Copyright (C) 4/2000 Scott Makeig, SCCN/INC/UCSD, scott@sccn.ucsd.edu
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
% Revision 1.8  2006/05/12 04:03:00  toby
% use stable interpolation 'v4' if fast int. from qhull crashes
%
% Revision 1.7  2006/05/12 03:41:53  toby
% qhull related bug, this fix works but slows things down
%
% Revision 1.6  2005/06/30 17:48:06  scott
% same
%
% Revision 1.5  2005/06/30 17:46:23  scott
% fixed bug in yticklabel (sometimes was non-monotonic) -sm
%
% Revision 1.4  2005/02/12 01:42:29  hilit
% added a plot 'on'|'off' option
%
% Revision 1.3  2002/10/09 17:37:28  arno
% set NaNs to 0
%
% Revision 1.2  2002/09/27 17:24:22  scott
% help msg -sm
%
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 08-07-00 made ydir normal -sm
% 01-25-02 reformated help & license -ad 

function [lgfreqs,datout] = logimagesc(times,freqs,data,varargin)

  if size(data,1) ~= length(freqs)
      fprintf('logfreq(): data matrix must have %d rows!\n',length(freqs));
      datout = data;
      return
  end
  if size(data,2) ~= length(times)
      fprintf('logfreq(): data matrix must have %d columns!\n',length(times));
      datout = data;
      return
  end
  if min(freqs)<= 0
      fprintf('logfreq(): frequencies must be > 0!\n');
      datout = data;
      return
  end
  lfreqs = log(freqs);
  lgfreqs = linspace(lfreqs(1),lfreqs(end),length(lfreqs));
  lgfreqs = lgfreqs(:);
  lfreqs = lfreqs(:);
  [mesht meshf] = meshgrid(times,lfreqs);
  try
      datout = griddata(mesht,meshf,data,times,lgfreqs);
  catch
      fprintf('error in logimagesc.m calling griddata.m, trying v4 method.');
      datout = griddata(mesht,meshf,data,times,lgfreqs,'v4');
  end
  datout(find(isnan(datout(:)))) = 0;
  
  if ~isempty(varargin)
      plot = varargin{2};
  else
      plot = 'on';
  end
  
  if strcmp(plot, 'on')
      imagesc(times,freqs,data);
      nt = ceil(min(freqs)); % new tick - round up min y to int
      ht = floor(max(freqs)); % high freq - round down

      yt=get(gca,'ytick');
      yl=get(gca,'yticklabel');
      
      imagesc(times,lgfreqs,datout); % plot the image
      set(gca,'ydir','normal')

      i = 0; yt = [];
      yl = cell(1,100);

      tickscale = 1.618; % log scaling power for frequency ticks
      while (nt*tickscale^i < ht )
        yt = [yt log(round(nt*tickscale^i))];
        yl{i+1}=int2str(round(nt*tickscale^i));
        i=i+1;
      end

      if ht/(nt*tickscale^(i-1)) > 1.35
         yt = [yt log(ht)];
         yl{i+1} = ht;
      else
         i=i-1;
      end
     yl = {yl{1:i+1}};
     set(gca,'ytick',yt);
     set(gca,'yticklabel',yl);

%     if nt > min(yt),
%         set(gca,'ytick',log([nt yt]));
%         set(gca,'yticklabel',{int2str(nt) yl});
%      else
%         set(gca,'ytick',log([yt]));
%         set(gca,'yticklabel',{yl});
%      end

  end 
