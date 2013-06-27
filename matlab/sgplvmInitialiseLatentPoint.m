function X = sgplvmInitialiseLatentPoint(model,Y,index_in,index_out,type,N,verbose)

% SGPLVMINITIALISELATENTPOINT Initialise latent location given observation(s)
% FORMAT
% DESC Initialise latent location for given observation(s)
% ARG model : sgplvm model
% ARG Y : observation, if multiple observation spaces as cell-array
% ARG index_in : component index to model generating observations
% ARG index_out : component index to output generating model
% ARG type : type of initialisation (default NN)
% ARG N : optional argument for type
% ARG verbose :
% RETURN X : latent location of initialisation
%
% SEEALSO : sgplvmInitialiseLatentSequence, sgplvmSequenceOut
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM


if(nargin<7)
  verbose = 0;
  if(nargin<6)
    N = 1;
    if(nargin<5)
      type = 'NN';
      if(nargin<4)
	error('Too Few Arguments');
      end
    end
  end
end

% check arguments
if(iscell(Y))
  nr_input_models = length(Y);
  if(length(Y)~=length(index_in))
    error('Observation and Observation model mismatch');
  end
else
  nr_input_models = 1;
end

% dimensions to determine, for each output model
dim = false.*ones(1,model.q);
for(i = 1:1:length(index_out))
  tmp = find(model.generative_id(index_out,:)==true);
  tmp2 = find(dim==1);
  tmp = union(tmp,tmp2);
  dim(tmp) = true;
end
dim = find(dim==true);
clear tmp,tmp2;
if(verbose)
  fprintf('sgplvmInitialiseLatentPoint:\tNeed to initialise dimension:\t');
  for(i = 1:1:length(dim))
    fprintf('%d, ',dim(i));
  end
  fprintf('\n');
end

X = zeros(1,model.q);
dim_done = false.*ones(size(dim));
% 1. Back-Constrained Dimensions
for(i = 1:1:length(dim))
  back_model_id = [];
  for(j = 1:1:nr_input_models)
    % Use first model back-constraining dimension
    if(model.back_id(index_in(j),dim(i)))
      back_model_id = index_in(j);
      back_observation_id = j;
    end
  end
  if(~isempty(back_model_id))
    tmp = modelOut(model.comp{back_model_id}.back,Y(back_observation_id,:));
    X(dim(i)) = tmp(dim(i));
    dim_done(i) = true;
    if(verbose)
      fprintf('sgplvmInitialiseLatentPoint:\tModel %d back-mapping initialises dimension %d\n',back_model_id,dim(i));
    end
    clear tmp;
  end
end
X = repmat(X,N,1);
% 2. Non-Back-Constrained Dimensions
dim_nbc = dim(find(dim.*not(dim_done)));
dim_nbc = [dim_nbc setdiff(1:1:model.q,dim)];
if(~isempty(dim_nbc))
  switch type
   case 'randn'
    X(:,dim_nbc) = repmat(mean(model.X(:,dim_nbc)),N,1) + repmat(std(model.X(:,dim_nbc)),N,1).*randn(N,length(dim_nbc));
   case {'nn','NN'}
    model_id = find(model.generative_id(:,dim_nbc));
    [model_id void] = ind2sub(model_id,size(model.generative_id));
    model_id = intersect(model_id,index_in);
    if(isempty(model_id))
      % if no generating model choose any
      model_id = index_in;
    end
    % choose a random generating model
    tmp = randperm(length(model_id));
    model_id = index_in(tmp(1));
    model_id_index = find(index_in==model_id);
    class = nn_class(model.comp{model_id}.y,Y(model_id_index,:),N,'euclidean');
    X(:,dim_nbc) = model.comp{model_id}.X(class,dim_nbc);
    clear tmp,tmp2;
   case {'nn_concat','NN_concat'}
    model_id = find(model.generative_id(:,dim_nbc));
    model_id = intersect(model_id,index_in);
    y_train = [];
    y_test = [];
    for(i = 1:1:length(model_id))
      y_train = [y_train model.comp{model_id(i)}.y];
      y_test = [y_test Y{i}];
    end
    class = nn_class(y_train,y_class,N,'euclidean');
    X(:,dim_nbc) = model.comp{model_id(1)}.X(class,dim_nbc);
    clear y_train, y_test;
   case {'nn_dim','NN_DIM'}
    % Nearest Neighbor over each remaining dimension in turn
    for(i = 1:1:length(dim_nbc))
      % choose model
      model_id = find(model.generative_id(:,dim_nbc(i)));
      model_id = intersect(model_id,index_in);
      if(isempty(model_id))
	% if no generating model choose any
	model_id = index_in;
      end
      tmp = randperm(length(model_id));
      model_id = model_id(tmp(1));
      model_id_index = find(index_in==model_id);
      class = nn_class(model.comp{model_id}.y,Y(model_id_index,:),1,'euclidean');
      X(dim_nbc(i)) = model.comp{model_id}.X(class,dim_nbc(i));
    end
    clear tmp,tmp2;
   case {'nn_dim_bc','NN_DIM_BC'}
    % Nearest Neighbor over back-constrained sub-space
    model_id = find(model.generative_id(:,dim_nbc));
    [model_id void] = ind2sub(model_id,size(model.generative_id));
    model_id = intersect(model_id,index_in);
    if(isempty(model_id))
      % if no generating model choose any
      model_id = index_in;
    end
    % choose a random generating model
    tmp = randperm(length(model_id));
    model_id = index_in(tmp(1));
    model_id_index = find(index_in==model_id);
    class = nn_class(model.comp{model_id}.y(:,dim(find(dim_done))),Y(model_id_index,dim(find(dim_done))),N,'euclidean');
    X(:,dim_nbc) = model.comp{model_id}.X(class,dim_nbc);
    clear tmp,tmp2;
   otherwise
    error('Unkown Type');
  end
end

return






