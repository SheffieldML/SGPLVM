function model = nccaOptimise(model,display,iters,map_id)

% NCCAOPTIMISE Optimise a given NCCA model
% FORMAT
% DESC model = nccaOptimise(model,display,iters) optimise a NCCA
% model
% ARG model : the model to be optimised
% ARG display : whether or not to display while optimisation
% proceeds, set to 2 for the most verbose and 0 for the least
% verbose.
% ARG iters : maximum number of iterations
% ARG map_id : Optimise only specific mapping
% ('fy','fz','gy','gz','dyn_y','dyn_z') (default map all mappings
% contained in model)
% RETURN model : the optimised model
%
% SEEALSO : modelOptimise
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

if(nargin<3)
  iters = 1500;
  if(nargin<2)
    display = false;
    if(nargin<1)
      error('To Few Arguments');
    end
  end
end

if(~exist('map_id','var'))
  fprintf('Optimising all created mappings\n');
  
  if(isfield(model,'gy')&&~isempty(model.gy))
    model.gy = gpOptimise(model.gy,display,iters);
  end
  if(isfield(model,'hy')&&~isempty(model.hy))
    model.hy = gpOptimise(model.hy,display,iters);
  end
  if(isfield(model,'fy')&&~isempty(model.fy))
    model.fy = gpOptimise(model.fy,display,iters);
  end
  
  if(isfield(model,'gz')&&~isempty(model.gz))
    model.gz = gpOptimise(model.gz,display,iters);
  end
  if(isfield(model,'hz')&&~isempty(model.gz))
    model.hz = gpOptimise(model.hz,display,iters);
  end
  if(isfield(model,'fz')&&~isempty(model.fz))
    model.fz = gpOptimise(model.fz,display,iters);
  end
  
  % dynamics
  tmp{3} = display;tmp{4} = iters;
  if(isfield(model,'dyn_y')&&~isempty(model.dyn_y))
    model.dyn_y = modelOptimise(model.dyn_y,[],[],display,iters);
  end
  
  if(isfield(model,'dyn_z')&&~isempty(model.dyn_z))
    model.dyn_z = modelOptimise(model.dyn_z,[],[],display,iters);
  end
else
  fprintf('Optimising only specified mappings\n');
  if(~iscell(map_id))
    tmp = map_id;clear map_id;
    map_id{1} = tmp;clear tmp;
  end
  for(i = 1:1:length(map_id))
    if(isfield(model,'gy')&&~isempty(model.gy)&&strcmp(map_id{i},'gy'))
      fprintf('Optimising gy\n');
      model.gy = gpOptimise(model.gy,display,iters);
    elseif(isfield(model,'hy')&&~isempty(model.hy)&&strcmp(map_id{i},'hy'))
      fprintf('Optimising hy\n');
      model.hy = gpOptimise(model.hy,display,iters);
    elseif(isfield(model,'fy')&&~isempty(model.fy)&&strcmp(map_id{i},'fy'))
      fprintf('Optimising fy\n');
      model.fy = gpOptimise(model.fy,display,iters);
    elseif(isfield(model,'gz')&&~isempty(model.gz)&&strcmp(map_id{i},'gz'))
      fprintf('Optimising gz\n');
      model.gz = gpOptimise(model.gz,display,iters);
    elseif(isfield(model,'hz')&&~isempty(model.hz)&&strcmp(map_id{i},'hz'))
      fprintf('Optimising hz\n');
      model.hz = gpOptimise(model.hz,display,iters);
    elseif(isfield(model,'fz')&&~isempty(model.fz)&&strcmp(map_id{i},'fz'))
      fprintf('Optimising fz\n');
      model.fz = gpOptimise(model.fz,display,iters);
    elseif(isfield(model,'dyn_y')&&~isempty(model.dyn_y)&&strcmp(map_id{i},'dyn_y'))
      fprintf('Optimising dyn_y\n');
      model.dyn_y = modelOptimise(model.dyn_y,[],[],display,iters);
    elseif(isfield(model,'dyn_z')&&~isempty(model.dyn_z)&&strcmp(map_id{i},'dyn_z'))
      fprintf('Optimising dyn_z\n');
      model.dyn_z = modelOptimise(model.dyn_z,[],[],display,iters);
    end
  end
end

return

