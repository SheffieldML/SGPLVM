function model = nccaCreate(void1,void2,Y,Z,data_var_keep,shared_var_keep,consolidation_var_keep,shared_space,options,Y_obs,Z_obs,scale2var1)

% NCCACREATE Create a NCCA model
% FORMAT
% DESC creates a NCCA model structure with default parameter settings as
% specified by the options vector.
% ARG void : for compatibility
% ARG void : for compatibility
% ARG Y : Observations in space 1 (either in form on Kernel or
% Datapoints (in which case linear algorithm will be applied)
% ARG Z : Observations in space 2
% ARG data_var_keep : Percentage of variance to keep after
% PCA-reduction
% ARG shared_var_keep : Minimum percentage of cannonical variate
% shared dimension needs to explain
% ARG consolidation_var_keep : Percentage of variance of data
% Consolidation needs to explain
% ARG shared_space : Shared Space from 'Y' or 'Z'
% ARG options : options structure as defined by nccaOptions.m
% ARG Y_obs : optional Y space observations
% ARG Z_obs : optional Z space observations
% ARG scale2var1 : scale each latent dimension to have variance 1
% ARG varagin : optional arguments
% RETURN model : model structure containing the Gaussian process.
%
% SEEALSO : nccaOptions, nccaCreate, modelCreate
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2007

% NCCA

if(nargin<9)
  options = nccaOptions('ftc');
  if(nargin<8)
    shared_space = 'Z';
    if(nargin<7)
      consolidation_var_keep = 90;
      if(nargin<6)
	shared_var_keep = 10;
	if(nargin<5)
	  data_var_keep = 97;
	  if(nargin<4)
	    error('To Few Arguments');
	  end
	end
      end
    end
  end
end

clear void1 void2;

% check format of option vector
mappings = {'gy','hy','fy','gz','hz','fz'};
if(isfield(options,'approx'))
  tmp = [];
  for(i = 1:1:length(mappings))
    tmp = setfield(tmp,mappings{i},options);
  end
  options = tmp;
  clear tmp;
else
  for(i = 1:1:length(mappings))
    if(~isfield(options,mappings{i}))
      options = setfield(options,mappings{i},nccaOptions('ftc','standard'));
    end
  end
end
  
% learn Embedding
[Xsy Xsz Xy Xz] = nccaEmbed(Y,Z,data_var_keep,shared_var_keep,consolidation_var_keep,true);

if(exist('scale2var1','var'))
  if(scale2var1==1)
    Xsy = Xsy./repmat(std(Xsy),size(Xsy,1),1);
    Xsz = Xsz./repmat(std(Xsz),size(Xsz,1),1);
    if(~isempty(Xy))
      Xy = Xy./repmat(std(Xy),size(Xy,1),1);
    end
    if(~isempty(Xz))
      Xz = Xz./repmat(std(Xz),size(Xz,1),1);
    end
  elseif(scale2var1==2)
    tmp = std([Xsz Xsy Xz Xy]);
    tmp = min(find(tmp~=0));
    Xsy = Xsy./repmat(tmp,size(Xsy,1),size(Xsy,2));
    Xsz = Xsz./repmat(tmp,size(Xsz,1),size(Xsz,2));
    if(~isempty(Xy))
      Xy = Xy./repmat(tmp,size(Xy,1),size(Xy,2));
    end
    if(~isempty(Xz))
      Xz = Xz./repmat(tmp,size(Xz,1),size(Xz,2));
    end
    clear tmp;
  end
end

% check what form data is represented in
if(size(Y,1)==size(Y,2))
  if(exist('Y_obs','var'))
    Y = Y_obs;
  else
    warning('Data given in terms of kernel but no points given');
  end
end
if(size(Z,1)==size(Z,1))
  if(exist('Z_obs','var'))
    Z = Z_obs;
  else
    warning('Data given in terms of kernel but no points given'); 
  end
end

switch shared_space
 case 'Y'
  Xs = Xsy;
 case 'Z'
  Xs = Xsz;
 otherwise
  Xs = Xsz;
end

% create model
model.type = 'ncca';
model.N = size(Y,1);
model.ds = size(Xs,2);
model.dy = size(Xy,2);
model.dz = size(Xz,2);

model.gy = gpCreate(size(Y,2),size(Xs,2),Y,Xs,options.gy);
model.hy = gpCreate(size(Y,2),size(Xy,2),Y,Xy,options.hy);

if(~isempty(Xy))
  model.fy = gpCreate(size(Xs,2)+size(Xy,2),size(Y,2),[Xs Xy],Y,options.fy);
else
  model.fy = [];
end

model.gz = gpCreate(size(Z,2),size(Xs,2),Z,Xs,options.gz);
model.hz = gpCreate(size(Z,2),size(Xz,2),Z,Xz,options.hz);

if(~isempty(Xz))
  model.fz = gpCreate(size(Xs,2)+size(Xz,2),size(Z,2),[Xs Xz],Z,options.fz);
else
  model.fz = [];
end

return