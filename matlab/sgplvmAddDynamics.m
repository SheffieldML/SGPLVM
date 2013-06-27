function model = sgplvmAddDynamics(model,type,dim_in,dim_out,X,options,varargin)

% SGPLVMADDDYNAMICS Add dynamic model over latent space
% FORMAT
% DESC Add dynamic model over latent space
% ARG model : sgplvm model to add dynamics to
% ARG type : type of dynamic model to add
% ARG dim_in : input dimensions for model
% ARG dim_out : output dimensions for model
% ARG X : latent locations
% ARG options : model options
% RETURN model : sgplvm model
%
% SEEALSO : sgplvmCreate
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

if(nargin<7)
  varargin = [];
  if(nargin<6)
    options = gpOptions('ftc');
    options.balancing = 1;
    if(nargin<5)
      error('Too Few Arguments');
    end
  end
end
if(isfield(options,'balancing')&&isstr(options.balancing))
  switch options.balancing
   case 'urtasun'
    dim_y = 0;
    for(i = 1:1:model.numModels)
      dim_y = dim_y + model.comp{i}.d;
    end
    options.balancing = (dim_y/model.numModels)*(length(dim_in)/model.q);
   otherwise
    error('Unknown balancing type');
  end
end
if(~isfield(options,'balancing')||isempty(options.balancing))
  options.balancing = 1;
end
if(~strcmp(model.type,'sgplvm'))
  error('Wrong Model Type');
end

flag_dim_error = false;
if(length(dim_in)~=length(dim_out))
  flag_dim_error = true;
else
  for(i = 1:1:length(dim_in))
    if(dim_in(i)~=dim_out(i))
      flag_dim_error = true;
    end
  end
end
if(flag_dim_error)
  error('Different latent dimensions for input and output is not yet supported');
end

type = [type 'Dynamics'];
if(isfield(model,'dynamics'))
  id = length(model.dynamics.comp)+1;
else
  id = 1;
end
% Create model
model.dynamic = true;
model.dynamics.comp{id} = modelCreate(type,size(X(:,dim_in),2),size(X(:,dim_out),2),X(:,dim_in),options,varargin{:});
if(~isfield(model,'dynamic_id'))
  model.dynamic_id = [];
end
model.dynamics.comp{id}.balancing = options.balancing;
% Set dimension index
model.dynamics.comp{id}.indexOut = dim_out;
model.dynamics.comp{id}.indexIn = dim_in;
model.dynamics.comp{id}.indexAll = 1:1:model.q;
model.dynamic_id(id,:) = false.*ones(1,model.q);
model.dynamic_id(id,dim_out) = true;
%for(i = 1:1:length(model.dynamics.comp{id}.kern.comp))
%  model.dynamics.comp{id}.kern.comp{i}.index = dim_in;
%end
if(~isempty(setxor(dim_in,dim_out)))
  model.dynamics.comp{id}.dynamicsType = 'regressive';
else
  model.dynamics.comp{id}.dynamicsType = 'auto-regressive';
end
% Update model
model.dynamics.comp{id}.numParams = length(modelExtractParam(model.dynamics.comp{id}));
if(isfield(model.dynamics,'numParams'))
  model.dynamics.numParams = model.dynamics.numParams + model.dynamics.comp{id}.numParams;
  model.dynamics.numModels = model.dynamics.numModels + 1;
else
  model.dynamics.numParams = model.dynamics.comp{id}.numParams;
  model.dynamics.numModels = 1;
end
% have this model passed through sgplvmCreate
if(isfield(model,'parameter_size'))
  % find previous model
  model.parameter_index{3}{id} = model.numParams+1:1:model.numParams+model.dynamics.comp{id}.numParams;
  model.numParams = model.numParams + model.dynamics.comp{id}.numParams;
else
  error('Model needs to be created before adding dynamics');
end

% Update parameters
params = sgplvmExtractParam(model);
model = sgplvmExpandParam(model,params);

fprintf('Added dynamical model:\n\tInput:\t');
for(i = 1:1:length(dim_in))
  fprintf('%d ',dim_in(i));
end
fprintf('\n\tOutput:\t');
for(i = 1:1:length(dim_out))
  fprintf('%d ',dim_out(i));
end
fprintf('\n');


