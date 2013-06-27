function valid_model = sgplvmCroppDimensionDynamicsGetValidDimension(model)

% SGPLVMCROPPDIMENSIONDYNAMICSGETVALIDDIMENSION Returns valid
% dynamic models for dimension cropping
% DESC Returns the dynamic models that are valid when cropping
% dimension of a model. This means that the model are either
% active on either all shared dimensions of the model
% or all generative or private dimension of a particular sub-model
% ARG model : sgplvm model
% RETURN valid_model : valid_model struct
%
% SEEALSO : sgplvmCroppDimension
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM


valid_model.dynamic_model = false.*ones(1,model.dynamics.numModels);
valid_model.generating_model = false.*ones(1,model.dynamics.numModels);
valid_model.type = cell(1,model.dynamics.numModels);

for(i = 1:1:model.dynamics.numModels)
  dim_shared = sgplvmGetDimension(model,'shared');
  % Full shared
  if(isempty(setxor(dim_shared,find(model.dynamic_id(i,:)))))
    valid_model.dynamic_model(i) = true;
    valid_model.generating_model(i) = NaN;
    valid_model.type{i} = 'shared';
  else
    % Only Private
    for(j = 1:1:model.numModels)
      dim_private = sgplvmGetDimension(model,'private',j);
      if(isempty(setxor(dim_private,find(model.dynamic_id(i,:)))))
        valid_model.dynamic_model(i) = true;
        valid_model.generating_model(i) = j;
        valid_model.type{i} = 'private';
      else
        if(isempty(setxor(find(model.generative_id(j,:)),find(model.dynamic_id(i,:)))))
          valid_model.dynamic_model(i) = true;
          valid_model.generating_model(i) = j;
          valid_model.type{i} = 'generating';
        end
      end
    end
  end
end

return
