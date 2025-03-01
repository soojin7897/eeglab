% getkeyval() - get variable value from a 'key', 'val' sequence string.
%
% Usage:
%   >> val = getkeyval( keyvalstr, varname, mode, defaultval);   
%     
% Inputs:            
%   keyvalstr  - string containing 'key', 'val' arguments
%   varname    - string for the name of the variable or index
%                of the value to retrieve (assuming arguments are
%                separated by comas).
%   mode       - if the value extracted is an integer array, the
%                'mode' variable can contain a subset of indexes to return.
%                If mode is 'present', then either 0 or 1 is returned
%                depending on wether the variable is present.
%   defaultval - default value if the varible is not found
%
% Outputs:
%   val  - a value for the variable
%
% Note: this function is helpful for finding arguments in string commands
%       stored in command history.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 29 July 2002
%
% See also: gethelpvar()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 arno@salk.edu, Arnaud Delorme, CNL / Salk Institute
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
% Revision 1.8  2007/08/03 21:45:02  arno
% fix when input does not have quotes
%
% Revision 1.7  2007/03/06 23:26:12  toby
% bug 145, courtesy Ronny Lindner
%
% Revision 1.6  2003/03/12 20:13:34  scott
% header edits -sm
%
% Revision 1.5  2003/03/12 19:21:05  arno
% handle setial case
%
% Revision 1.4  2002/08/21 18:55:23  arno
% same
%
% Revision 1.3  2002/08/21 18:52:07  arno
% debug
%
% Revision 1.2  2002/07/29 23:44:31  arno
% debugging
%
% Revision 1.1  2002/07/29 23:43:44  arno
% Initial revision
%

function txt = getkeyval(lastcom, var, mode, default)
    % mode can be present for 0 and 1 if the variable is present
	if nargin < 4
		default = '';
	end;
	if isempty(lastcom)
		txt = default; return;
	end;
	if nargin < 3
		mode = '';
	end;
	if isstr(mode) & strcmp(mode, 'present')
		if ~isempty(findstr(var, lastcom))
			txt = 1; return;
		else
			txt = 0; return;
		end;
	end;
	if isnumeric(var)
		comas = findstr(lastcom, ',');
		if length(comas) >= var
			txt = lastcom(comas(var-1)+1:comas(var)-1);
            tmpval = eval( txt );
            if isempty(tmpval), txt = '';
            else txt = vararg2str( tmpval );
            end;
            return;
            
% 			txt = deblank(txt(end:-1:1));
% 			txt = deblank(txt(end:-1:1));
%             
% 			if ~isempty(txt) & txt(end) == '}', txt = txt(2:end-1); end;
% 			if ~isempty(txt)
% 				txt = deblank(txt(end:-1:1));
% 				txt = deblank(txt(end:-1:1));
% 			end;
% 			if ~isempty(txt) & txt(end) == ']', txt = txt(2:end-1); end;
% 			if ~isempty(txt)
% 				txt = deblank(txt(end:-1:1));
% 				txt = deblank(txt(end:-1:1));
% 			end;
% 			if ~isempty(txt) & txt(end) == '''', txt = txt(2:end-1); end;
		else
			txt = default;
		end;
		%fprintf('%s:%s\n', var, txt);		
		return;
	else
		comas  = findstr(lastcom, ','); % finding all comas
		comas  = [ comas  findstr(lastcom, ');') ]; % and end of lines
		varloc = findstr(lastcom, var);
		if ~isempty(varloc)
			% finding comas surrounding 'val' var in 'key', 'val' sequence
			comas = comas(find(comas >varloc(end)));
			txt = lastcom(comas(1)+1:comas(2)-1); 
			txt = deblank(txt(end:-1:1));
			txt = deblank(txt(end:-1:1));
			if strcmp(mode, 'full')
				parent = findstr(lastcom, '}');
				if ~isempty(parent)
					comas = comas(find(comas >parent(1)));
					txt = lastcom(comas(1)+1:comas(2)-1);
				end;
				txt = [ '''' var ''', ' txt ];	
			elseif isnumeric(mode)
				txt = str2num(txt);
				if ~isempty(mode)
					if length(txt) >= max(mode)
						if all(isnan(txt(mode))), txt = '';
						else txt = num2str(txt(mode));
						end;	
					elseif length(txt) >= mode(1)
						if all(isnan(txt(mode(1)))), txt = '';
						else txt = num2str(txt(mode(1)));
						end;
					else 
						txt = default;
					end;
				else
                    txt = num2str(txt);
				end;
            elseif txt(1) == ''''
                txt = txt(2:end-1); % remove quotes for text
			end;
		else
			txt = default;
		end;
	end;
	%fprintf('%s:%s\n', var, txt);		
