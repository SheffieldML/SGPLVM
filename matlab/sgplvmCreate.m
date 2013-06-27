function model = sgplvmCreate(m,void,options)

% SGPLVMCREATE Creates a shared FGPLVM model from a set of FGPLVM models
% FORMAT
% DESC Creates a shared FGPLVM model from a set of FGPLVM models
% ARG m : a cell structure of FGPLVM models
% ARG void : empy for compatibility reasons
% ARG options : options structure as returned by sgplvmOptions
% RETURN model : the model created
%
% SEEALSO : sgplvmOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007
%
% COPYRIGHT : Mathieu Salzmann, Carl Henrik Ek, 2009
%
% MODIFICATIONS : Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM

clear void;

if(nargin<1)
  error('To Few Arguments');
end

model.type = 'sgplvm';
if(isfield(options,'name'))
  model.name = options.name;
else
  model.name = 'sgplvm_';
end
model.iteration = 0;
if(isfield(options,'save_intermediate'))
  model.save_intermediate = options.save_intermediate;
else
  model.save_intermediate = inf;
end
model.numModels = length(m);
for(i = 1:1:model.numModels-1)
  if(m{i}.q~=m{i+1}.q)
    error('Each model needs to have the same latent dimension');
  end
  if(m{i}.N~=m{i+1}.N)
    error('Each model needs to have the same nr of points');
  end
end
model.q = m{1}.q;
model.N = m{1}.N;
if(isfield(options,'optimiser'))
  model.optimiser = options.optimiser;
else
  model.optimiser = 'scg';
end
  
% back constrained part
model.back = false;
for(i = 1:1:model.numModels)
  if(isfield(m{i},'back')&&~isempty(model.back))
    model.back = true;
  end
end
if(model.back)
  % check that back-constraints are valid
  back_dim = [];
  for(i = 1:1:model.numModels)
    if(isfield(m{i},'back'))
      if(~isempty(m{i}.back))
	if(~isfield(m{i}.back,'indexOut'))
	  m{i}.back.indexOut = 1:1:model.q;
	end
	back_dim = [back_dim m{i}.back.indexOut];
      else
	% remove back place holder if no constraint
	m{i} = rmfield(m{i},'back');
      end
    end
  end
  if(length(unique(back_dim))~=length(back_dim))
    error('A latent dimension can only be constrained by a single model');
  end
  if(~isempty(back_dim)&&(max(back_dim)>model.q||min(back_dim)<1))
    error('Not a valid latent dimension to back-constrain');
  end
  clear back_dim;
  model.back_id = zeros(model.numModels,model.q);
  for(i = 1:1:model.numModels)
    if(isfield(m{i},'back'))
      model.back_id(i,m{i}.back.indexOut) = true;
    end
  end
else
  model.back_id = zeros(model.numModels,model.q);
end

% generative part
model.generative_id = zeros(model.numModels,model.q);
for(i = 1:1:model.numModels)
  % Check generative model active subspace
  for(j = 1:1:length(m{i}.kern.comp)-1)
    if(isfield(m{i}.kern.comp{j},'index'))
      if(m{i}.kern.comp{j}.index~=m{i}.kern.comp{j+1}.index)
	error('All components of the generative model needs to be active on the same space');
      end
    end
  end
  if(isfield(m{i}.kern.comp{1},'index')&&~isempty(m{i}.kern.comp{1}.index))
    model.generative_id(i,m{i}.kern.comp{1}.index) = true;
  else
    model.generative_id(i,:) = true;
  end
end


% dynamic part
for(i = 1:1:model.numModels)
  if(isfield(m{i},'dynamics'))
    if(~isempty(m{i}.dynamics))
      model.dynamic = true;
      % separate dynamic
      if(~isfield(m{i}.dynamics,'indexOut'))
	m{i}.dynamics.indexOut = 1:1:m{i}.dynamics.q;
      end
      if(~isfield(m{i}.dynamics,'indexIn'))
	m{i}.dynamics.indexIn = 1:1:m{i}.dynamics.q;
      end
      model = sgplvmAddDynamics(model,m{i}.dynamics.type,m{i}.dynamics.indexIn,m{i}.dynamics.indexOut,m{i}.dynamics.X);
    else
      m{i} = rmfield(m{i},'dynamics');
    end
  end
end
if(~isfield(model,'dynamic'))
  model.dynamic = false;
  model.dynamic_id = [];
end

% Constraint part
for(i = 1:1:model.numModels)
  if(isfield(m{i},'constraint'))
    model.constraint = true;
    model = sgplvmAddConstraint(model,m{i});
  end
end
if(~isfield(model,'constraint'))
  model.constraint = false;
  model.constraint_id = [];
end

% inducing part
model.inducing_id = zeros(model.numModels,model.q);
for(i = 1:1:model.numModels)
  for(j = 1:1:model.q)
    if(model.generative_id(i,j))
      switch m{i}.approx
       case 'ftc'
	model.inducing_id(i,j) = false;
       case {'dtc','fitc','pitc'}
	model.inducing_id(i,j) = true;
       otherwise
	error('Unkown Approximation');
      end
    else
      model.inducing_id(i,j) = false;
    end
  end
end

% initialise latent coordinates
model.X = zeros(model.N,model.q);
if(~isfield(options,'initX')||isempty(options.initX))
  options.initX = zeros(model.numModels,model.q);
  for(i = 1:1:model.q)
    ind = randperm(model.numModels);
    options.initX(ind(1),i) = true;
  end
end
model.initX = options.initX;
for(i = 1:1:model.q)
  ind = find(model.back_id(:,i));
  if(~isempty(ind))
    tmp = modelOut(m{ind}.back,m{ind}.y);
    model.X(:,i) = tmp(:,i);
  else
    ind = find(model.initX(:,i));
    if(isempty(ind))
      warning('Not specified which model initialise latent space');
      fprintf('Initialising using model 1');
      model.X(:,i) = m{1}.X(:,i);
    else
      % average over models initializing space
      tmp = zeros(model.N,1);
      for(j = 1:1:length(ind))
	tmp = tmp + m{ind(j)}.X(:,i);
      end
      tmp = tmp./length(ind);
      model.X(:,i) = tmp;
      clear tmp;
    end
  end
end
% initialise each model with shared initialisation
for(i = 1:1:model.numModels)
  m{i}.X = model.X;
end
clear tmp ind;

model.comp = m;

% determine parameter size for each model per parameter chunk
nr_parameter_chunks = 3; % [latent/back,gp,dyn-gp]
model.parameter_size = cell(1,nr_parameter_chunks); 
model.parameter_index = cell(1,nr_parameter_chunks);
model.numParams = 0;
startVal = 1;
for(i = 1:1:nr_parameter_chunks)
  if(i==1)
    model.parameter_size{i} = cell(1,model.q);
    % latent/back part
    model.parameter_size{i} = zeros(1,model.q);
    for(j = 1:1:model.q)
      ind = find(model.back_id(:,j));
      if(~isempty(ind))
	% dimension j is back-constrained by model ind
	model.parameter_size{i}(j) = length(modelExtractParam(model.comp{ind}.back,j));
      else
	model.parameter_size{i}(j) = model.N; % latent points
      end
      model.numParams = model.numParams + model.parameter_size{i}(j);
      model.parameter_index{i}{j} = startVal:1:startVal + model.parameter_size{i}(j)-1;
      startVal = model.numParams + 1;
    end
  end
  if(i==2)
    % gp part
    model.parameter_size{i} = zeros(1,model.numModels);
    model.parameter_index{i} = cell(1,model.numModels);
    for(j = 1:1:model.numModels)
      model.parameter_size{i}(j) = length(gpExtractParam(model.comp{j}));
      model.numParams = model.numParams + model.parameter_size{i}(j);
      model.parameter_index{i}{j} = startVal:1:startVal + model.parameter_size{i}(j)-1; 
      startVal = model.numParams + 1;
    end
  end
  if(i==3)
    % dynamic part
    if(isfield(model,'dynamic'))
      if(model.dynamic)
	model.parameter_size{i} = zeros(1,model.dynamics.numModels);
	model.parameter_index{i} = cell(1,model.dynamics.numModels);
	for(j = 1:1:model.dynamics.numModels)
	  if(model.dynamics.comp{j}.learn)
	    model.parameter_size{i}(j) = length(modelExtractParam(model.dynamics.comp{j}));
	    model.parameter_index{i}{j} = startVal:1:startVal+model.parameter_size{i}(j)-1;
	  else
	    % model has no parameters
	    model.parameter_size{i}(j) = 0;
	    model.parameter_index{i}{j} = [];
	  end
	  %model.numParams = model.numParams + model.dynamics.comp{j}.numParams;
	  model.numParams = model.numParams + model.parameter_size{i}{j}
	  startVal = model.numParams + 1;
	end
      end
    end
  end
end


% FOLS model
if(isfield(options,'fols')&&~isempty(options.fols))
  model.fols = options.fols;

  % set initalisation weights
  model.fols.rank.alpha.weight_init = model.fols.rank.alpha.weight;
  model.fols.rank.beta.weight_init = model.fols.rank.beta.weight;
  model.fols.rank.gamma.weight_init = model.fols.rank.gamma.weight;
  model.fols.ortho.weight_init = model.fols.ortho.weight;

  model.fols.qs = length(sgplvmGetDimension(model,'shared'));
  model.fols.qp = zeros(1,model.numModels);
  for(i = 1:1:model.numModels)
    model.fols.qp(i) = length(sgplvmGetDimension(model,'private',i));
  end
  %S = svd(model.X(:,1:model.fols.qs));
  %sS2 = sum(S.*S);
  for(i = 1:1:length(model.fols.qp))
    if(m{i}.isMissingData)
      index_present = m{i}.indexPresent{1};
      for(j = 2:1:m{i}.d)
        index_present = intersect(index_present,m{i}.indexPresent{j});
      end
    else
      index_present = 1:1:m{i}.N;
    end
    if(options.fols.rank.gamma.observed)
      % preserve energy spectrum of observation
      S = svd(m{i}.y(index_present,:));
      model.fols.sumS2(i) = sum(S.*S);
    else
      % preserve energy spectrum of initialisation
      S = svd(m{i}.X(:,sgplvmGetDimension(model,'generative',i)));
      model.fols.sumS2(i) = sum(S.*S);
    end
    %S = svd(model.X(:,find(model.generative_id(i,:))));
  end
  model.fols.rank.alpha.rel_alphas = model.fols.sumS2./max(model.fols.sumS2);
end


% force kernel computation
initParams = sgplvmExtractParam(model);
model = sgplvmExpandParam(model,initParams);

return