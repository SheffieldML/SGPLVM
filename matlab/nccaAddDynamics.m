function model = nccaAddDynamics(model,type,space,varargin)
  
% NCCAADDDYNAMICS Add a dynamics kernel to the model.
% FORMAT
% DESC MODEL = NCCAADDDYNAMICS(MODEL,TYPE,SPACE,VARARGIN) adds
% dynamics to a given NCCA model
% ARG model : the to which dynamics is added
% ARG type : type of dynamic model
% ARG space : which part of latent space dynamic should cover
% 'Y' over shared and Y independent space
% 'Z' over shared and Z independent space
% 'YZ' both
% ARG P1, P2, P3,... : optional arguments
% RETURN model : model with specified dynamic appended
%
% SEEALSO : modelCreate, gpOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

if(nargin<3)
  space = 'YZ';
  if(nargin<2)
    type = 'gp';
    if(nargin<1)
      error('To Few Arguments');
    end
  end
end

type = [type 'Dynamics'];

switch space
 case 'Y'
  model.dyn_y = modelCreate(type,model.ds+model.dy,model.ds+model.dy,model.fy.X,varargin{:});
  model.dyn_y.learn = true;
 case 'Z'
  model.dyn_z = modelCreate(type,model.ds+model.dz,model.ds+model.dz,model.fz.X,varargin{:});
  model.dyn_z.learn = true;
 case 'YZ'
  model.dyn_y = modelCreate(type,model.ds+model.dy,model.ds+model.dy,model.fy.X,varargin{:});
  model.dyn_y.learn = true;
  model.dyn_z = modelCreate(type,model.ds+model.dz,model.ds+model.dz,model.fz.X,varargin{:});
  model.dyn_z.learn = true;
 otherwise
  error('Unkown Space to Apply Dynamic To');
end

return