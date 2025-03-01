function volumewrite(cfg, volume)

% VOLUMEWRITE exports anatomical or functional volume data to a Analyze
% or BrainVoyager file. The data in the resulting file(s) can be
% further analyzed and/or visualized in MRIcro, SPM, BrainVoyager,
% AFNI or similar packages.
%
% Use as
%   volumewrite(cfg, volume)
%
% The volume structure should contain a source reconstruction that originates
% from SOURCANALYSIS, a statistical parameter from SOURCESTATISTICS or an
% interpolated and re-aligned anatomical MRI  source reconstruction
% from SOURCEINTERPOLATE.
%
% The configuration structure should contain the following elements
%   cfg.parameter     = string, describing the functional data to be processed, e.g. 'pow', 'coh' or 'nai'
%   cfg.filename      = filename without the extension
%   cfg.filetype      = 'analyze', 'spm', 'vmp' or 'vmr'
%   cfg.vmpversion    = 1 or 2 (default) version of the vmp-format to use
%   cfg.coordinates   = 'spm, 'ctf' or empty for interactive (default = [])
%
% The default fileformat is 'spm', which means that a *.hdr and *.img file
% will be written using the SPM2 toolbox. The SPM format supports a
% homogenous transformation matrix, the other file formats do not support a
% homogenous coordinate transformation matrix and hence will be written in
% their native coordinate system.
%
% You can specify the datatype for the spm and analyze formats using
%   cfg.datatype      = 'bit1', 'uint8', 'int16', 'int32', 'float' or 'double'
%
% By default, integer datatypes will be scaled to the maximum value of the
% physical or statistical parameter, floating point datatypes will not be
% scaled. This can be modified with
%   cfg.scaling       = 'yes' or 'no'
%
% Optional configuration items are
%   cfg.downsample    = integer number (default = 1, i.e. no downsampling)
%   cfg.fiducial.nas  = [x y z]	position of nasion
%   cfg.fiducial.lpa  = [x y z]	position of LPA
%   cfg.fiducial.rpa  = [x y z]	position of RPA
%   cfg.markfiducial  = 'yes' or 'no', mark the fiducials
%   cfg.markorigin    = 'yes' or 'no', mark the origin
%   cfg.markcorner    = 'yes' or 'no', mark the first corner of the volume
%
% See also SOURCEANALYSIS, SOURCESTATISTICS, SOURCEINTERPOLATE

% Undocumented local options:
% cfg.parameter

% Copyright (C) 2003-2006, Robert Oostenveld, Markus Siegel
%
% $Log: not supported by cvs2svn $
% Revision 1.15  2008/09/22 20:17:44  roboos
% added call to fieldtripdefs to the begin of the function
%
% Revision 1.14  2008/09/17 14:53:35  roboos
% removed fixvolume (and underlying grid2transform), not needed any more because checkdata has the possibility of converting a pos to a transform
%
% Revision 1.13  2007/04/03 15:37:07  roboos
% renamed the checkinput function to checkdata
%
% Revision 1.12  2007/03/30 17:05:40  ingnie
% checkinput; only proceed when input data is allowed datatype
%
% Revision 1.11  2006/08/02 17:14:08  marsie
% fixed bug in dimension alignment when exporting vmp/vmr from spm-coordinates
%
% Revision 1.10  2006/08/02 15:28:46  marsie
% corrected max scaling for .vmr output
%
% Revision 1.9  2006/07/27 08:29:09  roboos
% updated documentation
%
% Revision 1.8  2006/07/13 08:48:46  ingnie
% fixed typo's in documentation
%
% Revision 1.7  2006/04/20 09:58:34  roboos
% updated documentation
%
% Revision 1.6  2006/03/07 08:02:33  roboos
% changed incorrectly named variable functional into volume
%
% Revision 1.5  2006/02/24 16:50:18  roboos
% switched from grid2transform to fixvolume, not neccessary to reshape any more
%
% Revision 1.4  2006/01/30 14:19:33  jansch
% added a fclose in the case of brainvoyager data
%
% Revision 1.3  2006/01/30 13:48:04  roboos
% switched order of parameterselection() and grid2transform() for consistency with other functions
%
% Revision 1.2  2006/01/24 14:20:35  roboos
% removed the obsolete option cfg.voxelcoord, new behaviour is that it is always 'yes'
%
% Revision 1.1  2006/01/05 12:58:20  roboos
% This function (VOLUMExxx) replaces a function with the name xxxVOLUME.
% The fields xgrid/ygrid/zgrid are removed (this is from now on handled by
% grid2transform and the VOLUMExxx function should only work on volumes that
% are described using a transformation matrix).
% Writing of spm/analyze volumes is handled by private/volumewrite_spm.
%
% Revision 1.8  2005/08/19 16:56:45  roboos
% add xgrid/ygrid/zgrid to the volume if not present
% swithched the selection of the functional volume to use the new subfunction parameterselection()
%
% Revision 1.7  2005/05/17 17:50:39  roboos
% changed all "if" occurences of & and | into && and ||
% this makes the code more compatible with Octave and also seems to be in closer correspondence with Matlab documentation on shortcircuited evaluation of sequential boolean constructs
%
% Revision 1.6  2005/05/04 07:33:37  roboos
% made chaling optional for int datatypes, added cfg.scaling option
%
% Revision 1.5  2004/10/14 09:33:11  roboos
% added nai, prob and mask as parameters
% improved documentation
%
% Revision 1.4  2003/12/18 22:21:35  roberto
% added "See also" line to the online help
%
% Revision 1.3  2003/12/08 12:33:47  roberto
% only layout changes in code
%
% Revision 1.2  2003/10/28 15:12:04  roberto
% fixed bug: switch...otherwise (instead of switch...default)
%
% Revision 1.1  2003/07/23 09:11:15  roberto
% fixed bug in integer scaling
%

fieldtripdefs

%% checkdata see below!!! %%

% check some of the cfg fields
if ~isfield(cfg, 'filename'),    error('No output filename specified'); end
if ~isfield(cfg, 'parameter'),   error('No parameter specified');       end
if isempty(cfg.filename),        error('Empty output filename');        end

% set the defaults
if ~isfield(cfg, 'filetype'),    cfg.filetype     = 'spm';      end
if ~isfield(cfg, 'datatype')     cfg.datatype     = 'int16';    end
if ~isfield(cfg, 'downsample'),  cfg.downsample   = 1;          end
if ~isfield(cfg, 'markorigin')   cfg.markorigin   = 'no';       end
if ~isfield(cfg, 'markfiducial') cfg.markfiducial = 'no';       end
if ~isfield(cfg, 'markcorner')   cfg.markcorner   = 'no';       end

if ~isfield(cfg, 'scaling'),
  if any(strmatch(cfg.datatype, {'int8', 'int16', 'int32'}))
    cfg.scaling = 'yes';
  else
    cfg.scaling = 'no';
  end
end

if ~isfield(cfg, 'coordinates')
  fprintf('assuming CTF coordinates\n');
  cfg.coordinates = 'ctf';
end

if ~isfield(cfg, 'vmpversion') & strcmp(cfg.filetype, 'vmp');
  fprintf('using BrainVoyager version 2 VMP format\n');
  cfg.vmpversion = 2;
end

% check if the input data is valid for this function
volume = checkdata(volume, 'datatype', 'volume', 'feedback', 'yes');

% select the parameter that should be written
cfg.parameter = parameterselection(cfg.parameter, volume);
% only a single parameter should be selected
try, cfg.parameter = cfg.parameter{1}; end

% downsample the volume
tmpcfg = [];
tmpcfg.downsample = cfg.downsample;
tmpcfg.parameter  = cfg.parameter;
volume = volumedownsample(tmpcfg, volume);

% copy the data and convert into double values so that it can be scaled later
transform = volume.transform;
data      = double(getsubfield(volume, cfg.parameter));
maxval    = max(data(:));
% ensure that the original volume is not used any more
clear volume

if strcmp(cfg.markfiducial, 'yes')
  % FIXME determine the voxel index of the fiducials
  nas = cfg.fiducial.nas;
  lpa = cfg.fiducial.lpa;
  rpa = cfg.fiducial.rpa;
  if any(nas<minxyz) || any(nas>maxxyz)
    warning('nasion does not ly within volume, using nearest voxel');
  end
  if any(lpa<minxyz) || any(lpa>maxxyz)
    warning('LPA does not ly within volume, using nearest voxel');
  end
  if any(rpa<minxyz) || any(rpa>maxxyz)
    warning('RPA does not ly within volume, using nearest voxel');
  end
  idx_nas = [nearest(x, nas(1)) nearest(y, nas(2)) nearest(z, nas(3))];
  idx_lpa = [nearest(x, lpa(1)) nearest(y, lpa(2)) nearest(z, lpa(3))];
  idx_rpa = [nearest(x, rpa(1)) nearest(y, rpa(2)) nearest(z, rpa(3))];
  fprintf('NAS corresponds to voxel [%d, %d, %d]\n', idx_nas);
  fprintf('LPA corresponds to voxel [%d, %d, %d]\n', idx_lpa);
  fprintf('RPA corresponds to voxel [%d, %d, %d]\n', idx_rpa);
  % set the voxel of the fiducials to the maximum value
  data(idx_nas(1), idx_nas(2), idx_nas(3)) = maxval;
  data(idx_lpa(1), idx_lpa(2), idx_lpa(3)) = maxval;
  data(idx_rpa(1), idx_rpa(2), idx_rpa(3)) = maxval;
end

if strcmp(cfg.markorigin, 'yes')
  % FIXME determine the voxel index of the coordinate system origin
  ori = [0 0 0];
  if any(ori<minxyz) || any(ori>maxxyz)
    warning('origin does not ly within volume, using nearest voxel');
  end
  idx_ori = [nearest(x, ori(1)) nearest(y, ori(2)) nearest(z, ori(3))];
  fprintf('origin corresponds to voxel [%d, %d, %d]\n', idx_ori);
  % set the voxel of the origin to the maximum value
  data(idx_ori(1), idx_ori(2), idx_ori(3)) = maxval;
end

if strcmp(cfg.markcorner, 'yes')
  % set the voxel of the first corner to the maximum value
  data(1:2, 1:1, 1:1) = maxval;		% length 2 along x-axis
  data(1:1, 1:3, 1:1) = maxval;		% length 3 along y-axis
  data(1:1, 1:1, 1:4) = maxval;		% length 4 along z-axis
end

% set not-a-number voxels to zero
data(isnan(data)) = 0;

if strcmp(cfg.scaling, 'yes')
  % scale the data so that it fits in the desired numerical data format
  switch lower(cfg.datatype)
    case 'bit1'
      data = (data~=0);
    case 'uint8'
      data = uint8((2^8-1) * data./maxval);
    case 'int16'
      data = int16((2^15-1) * data./maxval);
    case 'int32'
      data = int32((2^31-1) * data./maxval);
    case 'float'
      data = float(data ./ maxval);
    case 'double'
      data = double(data ./ maxval);
    otherwise
      error('unknown datatype');
  end
end

% The coordinate system employed by the ANALYZE programs is left-handed,
% with the coordinate origin in the lower left corner. Thus, with the
% subject lying supine, the coordinate origin is on the right side of
% the body (x), at the back (y), and at the feet (z).

% Analyze   x = right-left
% Analyze   y = post-ant
% Analyze   z = inf-sup

% SPM/MNI   x = left-right
% SPM/MNI   y = post-ant
% SPM/MNI   z = inf-sup

% CTF       x = post-ant
% CTF       y = right-left
% CTF       z = inf-sup

% The BrainVoyager and Analyze format do not support the specification of
% the coordinate system using a homogenous transformation axis, therefore
% the dimensions of the complete volume has to be reordered by flipping and
% permuting to correspond with their native coordinate system.
switch cfg.filetype
  case {'vmp', 'vmr'}
    % the reordering for BrainVoyager has been figured out by Markus Siegel
    if strcmp(cfg.coordinates, 'ctf')
      data = permute(data, [2 3 1]);
    elseif strcmp(cfg.coordinates, 'spm')
      data = permute(data, [2 3 1]);
      data = flipdim(data, 1);
      data = flipdim(data, 2);
    end
    siz = size(data);
  case {'analyze'}
    % the reordering of the Analyze format is according to documentation from Darren Webber
    if strcmp(cfg.coordinates, 'ctf')
      data = permute(data, [2 1 3]);
    elseif strcmp(cfg.coordinates, 'spm')
      data = flipdim(data, 1);
    end
    siz = size(data);
  case 'spm'
    % this format supports a homogenous transformation matrix
    % nothing needs to be changed
  otherwise
    fprintf('unknown fileformat\n');
end

% write the volume data to file
switch cfg.filetype
  case 'vmp'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write in BrainVoyager VMP format
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid = fopen(sprintf('%s.vmp', cfg.filename),'w');
    if fid < 0,
      error('Cannot write to file %s.vmp\n',cfg.filename);
    end

    switch cfg.vmpversion
      case 1
        % write the header
        fwrite(fid, 1, 'short');      % version
        fwrite(fid, 1, 'short');      % number of maps
        fwrite(fid, 1, 'short');      % map type
        fwrite(fid, 0, 'short');      % lag

        fwrite(fid, 0, 'short');      % cluster size
        fwrite(fid, 1, 'float');      % thresh min
        fwrite(fid, maxval, 'float'); % thresh max
        fwrite(fid, 0, 'short');      % df1
        fwrite(fid, 0, 'short');      % df2
        fwrite(fid, 0, 'char');       % name

        fwrite(fid, siz, 'short');    % size
        fwrite(fid, 0, 'short');
        fwrite(fid, siz(1)-1, 'short');
        fwrite(fid, 0, 'short');
        fwrite(fid, siz(2)-1, 'short');
        fwrite(fid, 0, 'short');
        fwrite(fid, siz(3)-1, 'short');
        fwrite(fid, 1, 'short');      % resolution

        % write the data
        fwrite(fid, data, 'float');
      case 2
        % determine relevant subvolume
        % FIXME, this is not functional at the moment, since earlier in this function all nans have been replaced by zeros
        minx = min(find(~isnan(max(max(data,[],3),[],2))));
        maxx = max(find(~isnan(max(max(data,[],3),[],2))));
        miny = min(find(~isnan(max(max(data,[],3),[],1))));
        maxy = max(find(~isnan(max(max(data,[],3),[],1))));
        minz = min(find(~isnan(max(max(data,[],1),[],2))));
        maxz = max(find(~isnan(max(max(data,[],1),[],2))));

        % write the header
        fwrite(fid, 2, 'short');      % version
        fwrite(fid, 1, 'int');        % number of maps
        fwrite(fid, 1, 'int');        % map type
        fwrite(fid, 0, 'int');        % lag

        fwrite(fid, 0, 'int');        % cluster size
        fwrite(fid, 0, 'char');       % cluster enable
        fwrite(fid, 1, 'float');      % thresh
        fwrite(fid, maxval, 'float'); % thresh
        fwrite(fid, 0, 'int');        % df1
        fwrite(fid, 0, 'int');        % df2
        fwrite(fid, 0, 'int');        % bonf
        fwrite(fid, [255,0,0], 'uchar');   % col1
        fwrite(fid, [255,255,0], 'uchar'); % col2
        fwrite(fid, 1, 'char');       % enable SMP
        fwrite(fid, 1, 'float');      % transparency
        fwrite(fid, 0, 'char');       % name

        fwrite(fid, siz, 'int');      % original size
        fwrite(fid, minx-1, 'int');
        fwrite(fid, maxx-1, 'int');
        fwrite(fid, miny-1, 'int');
        fwrite(fid, maxy-1, 'int');
        fwrite(fid, minz-1, 'int');
        fwrite(fid, maxz-1, 'int');
        fwrite(fid, 1, 'int');        % resolution

        % write the data
        fwrite(fid, data(minx:maxx,miny:maxy,minz:maxz), 'float');
    end

  case 'vmr'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write in BrainVoyager VMR format
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid = fopen(sprintf('%s.vmr',cfg.filename),'w');
    if fid < 0,
      error('Cannot write to file %s.vmr\n',cfg.filename);
    end

    % data should be scaled between 0 and 225
    data = data - min(data(:));
    data = round(225*data./max(data(:)));

    % write the header
    fwrite(fid, siz, 'ushort');
    % write the data
    fwrite(fid, data, 'uint8');
    fclose(fid);
  case 'analyze'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write in Analyze format, using some functions from Darren Webbers toolbox
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    avw = avw_hdr_make;

    % specify the image data and dimensions
    avw.hdr.dime.dim(2:4) = siz;
    avw.img = data;

    % orientation 0 means transverse unflipped (axial, radiological)
    % X direction first,  progressing from patient right to left,
    % Y direction second, progressing from patient posterior to anterior,
    % Z direction third,  progressing from patient inferior to superior.
    avw.hdr.hist.orient = 0;

    % specify voxel size
    avw.hdr.dime.pixdim(2:4) = [1 1 1];
    % FIXME, this currently does not work due to all flipping and permuting
    % resx = x(2)-x(1);
    % resy = y(2)-y(1);
    % resz = z(2)-z(1);
    % avw.hdr.dime.pixdim(2:4) = [resy resx resz];

    % specify the data type
    switch lower(cfg.datatype)
      case 'bit1'
        avw.hdr.dime.datatype = 1;
        avw.hdr.dime.bitpix   = 1;
      case 'uint8'
        avw.hdr.dime.datatype = 2;
        avw.hdr.dime.bitpix   = 8;
      case 'int16'
        avw.hdr.dime.datatype = 4;
        avw.hdr.dime.bitpix   = 16;
      case 'int32'
        avw.hdr.dime.datatype = 8;
        avw.hdr.dime.bitpix   = 32;
      case 'float'
        avw.hdr.dime.datatype = 16;
        avw.hdr.dime.bitpix   = 32;
      case 'double'
        avw.hdr.dime.datatype = 64;
        avw.hdr.dime.bitpix   = 64;
      otherwise
        error('unknown datatype');
    end

    % write the header and image data
    avw_img_write(avw, cfg.filename, [], 'ieee-le');

  case 'spm'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write in SPM format, using functions from  the SPM2 toolbox
    % this format supports a homogenous transformation matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    volumewrite_spm(cfg.filename, data, transform);

  otherwise
    fprintf('unknown fileformat\n');
end
