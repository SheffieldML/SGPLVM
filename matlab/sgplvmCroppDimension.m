function model = sgplvmCroppDimension(model_in,options,verbose)

% SGPLVMCROPPDIMENSION Removes latent dimensions representing
% small amount of the variance in the data
% FORMAT
% DESC Returns the cropped sgplvm model
% ARG model_in : sgplvm model
% ARG options : sgplvm options struct
% ARG verbose :
% RETURN model : the cropped sgplvm model
%
% SEEALSO : sgplvmOptimise
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009, 2010

% SGPLVM

if(nargin<3)
  verbose = false;
end

if(model_in.fols.cropp)

  % 1 shared
  dim_shared = 1:1:model_in.fols.qs;

  if(length(dim_shared)>1)
    [S2 V] = pca(model_in.X(:,dim_shared));
    X = model_in.X(:,dim_shared)*V;
    S2 = S2./sum(S2);
    dim_active_shared = find(S2>model_in.fols.cropp_ratio);
    Xs = X(:,dim_active_shared);
    V_shared = V(:,dim_active_shared);
    if(verbose)
      fprintf('Shared:\n');
      for(i = 1:1:length(S2))
        fprintf('%1.4f\n',S2(i))
      end
    end
  else
    Xs = model_in.X(:,dim_shared);
  end

  % 2 private
  Xp = cell(model_in.numModels,1);
  dim_active_private = cell(model_in.numModels,1);
  V_private = cell(model_in.numModels,1);
  dim_private = cell(model_in.numModels,1);
  start = model_in.fols.qs+1;
  for(i = 1:1:model_in.numModels)
    dim_private{i} = start:start+model_in.fols.qp(i)-1;
    if(length(dim_private{i})>1)
      [S2 V] = pca(model_in.X(:,dim_private{i}));
      X = model_in.X(:,dim_private{i})*V;
      S2 = S2./sum(S2);
      dim_active_private{i} = find(S2>model_in.fols.cropp_ratio);
      Xp{i} = X(:,dim_active_private{i});
      V_private{i} = V(:,dim_active_private{i});
      if(verbose)
        fprintf('Private %d:\n',i);
        for(j = 1:1:length(S2))
          fprintf('%1.4f\n',S2(j));
        end
      end
    else
      Xp{i} = model_in.X(:,dim_private{i});
    end
    start = start + model_in.fols.qp(i);
  end
  
  % Global part
  q = size(Xs,2);
  X = Xs;
  for(i = 1:1:model_in.numModels)
    q = q + size(Xp{i},2);
    X = [X Xp{i}];
  end
  
  if(q == model_in.q)
    model = model_in;
    return;
  end

  % Create index vectors
  generative_id = zeros(model_in.numModels,q);
  private_id = zeros(model_in.numModels,q);
  shared_id = zeros(1,q);
  shared_id(1:1:size(Xs,2)) = true;
  start = size(Xs,2)+1;
  for(i = 1:1:model_in.numModels)
    generative_id(i,1:1:size(Xs,2)) = true;
    generative_id(i,start:1:start+size(Xp{i},2)-1) = true;
    private_id(i,start:1:start+size(Xp{i},2)-1) = true;
    start = start + size(Xp{i},2);
  end
  
  % Transfer FGPLVM models
  m = model_in.comp;
  for(i = 1:1:length(m))
    m{i}.X = X;
    m{i}.q = q;
    m{i}.kern.inputDimension = size(X,2);
    for(j = 1:1:length(m{i}.kern.comp))
      m{i}.kern.comp{j}.index = find(generative_id(i,:));
      m{i}.kern.comp{j}.inputDimension = size(X,2);
    end
  end

  % inducing points
  for(i = 1:1:length(m))
    if(isfield(m{i},'X_u')&&~isempty(m{i}.X_u))
      if(length(dim_shared)>1)
        X_u = m{i}.X_u(:,dim_shared)*V_shared;
      else
        X_u = m{i}.X_u(:,dim_shared);
      end
      for(j = 1:1:length(m))
        if(length(dim_private{j})>1)
          X_u = [X_u m{i}.X_u(:,dim_private{j})*V_private{j}];
        else
          X_u = [X_u m{i}.X_u(:,dim_private{j})];
        end
      end
      m{i}.X_u = X_u;
    end
  end
  
  % Transfer back-constraints
  if(model_in.back)
    valid_model = sgplvmCroppDimensionBackValidDimension(model_in);
    for(i = 1:1:model_in.numModels)
      if(valid_model.generating_model(i))
        back_transfer = true;
        switch valid_model.dim{i}
         case 'shared'
          dim = find(shared_id);
         case 'private'
          dim = find(private_id(i,:));
         case 'generative'
          dim = find(generative_id(i,:));
        end
        m{i}.back.indexOut = dim;
        % re-optimise back-constraint
        m{i}.back = mappingOptimise(m{i}.back,m{i}.y,m{i}.X);
      else
        if(isfield(m{i},'back'))
          m{i} = rmfield(m{i},'back');
        end
      end
    end
  end
  
  % Create cropped SGPLVM model
  options.initX = zeros(model_in.numModels,q);
  options.initX(1,:) = true;
  model = sgplvmCreate(m,[],options);
  
  % Add dynamics
  if(model_in.dynamic)
    % Find valid dynamic models
    valid_model = sgplvmCroppDimensionDynamicsGetValidDimension(model_in);    

    for(i = 1:1:model_in.dynamics.numModels)
      nr_transfered_model = 1;
      if(valid_model.dynamic_model(i))
        switch valid_model.type{i}
         case 'shared'
          dim = sgplvmGetDimension(model,'shared');
         case 'private'
          dim = sgplvmGetDimension(model,'private',valid_model.generating_model(i));
         case 'generating'
          dim = find(model.generative_id(valid_model.generating_model(i),:));
        end

        switch model_in.dynamics.comp{i}.type
          % Add model to new model
         case 'gpDynamics'
        
          options_dyn = gpOptions(model_in.dynamics.comp{i}.approx);
          options_dyn.balancing = model_in.dynamics.comp{i}.balancing;
          learn = model_in.dynamics.comp{i}.learn;
          diff = model_in.dynamics.comp{i}.diff;

          model = sgplvmAddDynamics(model,model_in.dynamics.comp{i}.type(1:1:end-8),dim,dim,model.X,options_dyn,diff,learn);
        
          % copy kernel
          model.dynamics.comp{model.dynamics.numModels}.kern = model_in.dynamics.comp{i}.kern;
          model.dynamics.comp{model.dynamics.numModels}.kern.inputDimension = length(dim);
          for(j = 1:1:length(model_in.dynamics.comp{i}))
            model.dynamics.comp{model.dynamics.numModels}.kern.comp{j}.inputDimension = length(dim);
            %model.dynamics.comp{model.dynamics.numModels}.kern.comp{j}.index = dim;
          end
                  
         otherwise
          error('Dynamic Transfer for this model has not been implemented');
        end
        
      end
      
    end
    
  end

  % Add constraints
  if(model_in.constraint)
    valid_model = sgplvmCroppDimensionConstraintsGetValidDimension(model_in);
    for(i = 1:1:model_in.constraints.numConstraints)
      nr_transfered_model = 1;
      if(valid_model.constraint_model(i))
        switch valid_model.type{i}
         case 'shared'
          dim = sgplvmGetDimension(model,'shared');
         case 'private'
          dim = sgplvmGetDimension(model,'private',valid_model.generating_model(i));
         case 'generating'
          dim = sgplvmGetDimension(model,'generative',valid_model.generating_model(i));
        end
        model.constraints.comp{nr_transfered_model} = model_in.constraints.comp{i};
        model.constraints.comp{nr_transfered_model}.dim = dim;
      end
    end
    if(nr_transfered_model>0)
      model.constraint = true;
      model.constraints.numConstraints = nr_transfered_model;
      model.constraint_id = false*ones(model.constraints.numConstraints, ...
                                       model.q);
      for(i = nr_transfered_model)
        model.constraints.comp{i} = constraintExpandParam(model.constraints.comp{i},model.X);
        model.constraints.comp{i}.q = model.q;
        model.constraint_id(i,model.constraints.comp{i}.dim) = true;
      end
    else
      if(model_in.constraint)
        warning('All latent-constraint has been removed');
      end
      model.constraint = false;
    end
  end


  if(verbose)
    fprintf('Cropping Dimensions\n');
    fprintf('Shared  Dimensionality:\t%d\n',model.fols.qs);
    fprintf('Private Dimensionality:\t');
    for(i = 1:1:model.numModels)
      fprintf('%d\t',model.fols.qp(i));
    end
    fprintf('\n');
  end
  
else
  model = model_in;
end

return


