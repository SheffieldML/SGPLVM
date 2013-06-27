function valid_model = sgplvmCroppDimensionBackValidDimension(model)

% SGPLVMCROPPDIMENSIONBACKVALIDDIMENSION Returns valid
% back constraints for dimension cropping
% DESC Returns the back-constraints that are valid when cropping
% dimension of a model. This means constraints that are either
% active on either all shared dimensions of the model
% or all generative or private dimension of a particular sub-model
% ARG model : sgplvm model
% RETURN valid_model : valid_model struct
%
% SEEALSO : sgplvmCroppDimension
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM

valid_model.generating_model = false.*ones(1,model.numModels);
valid_model.dim = cell(1,model.numModels);

for(i = 1:1:model.numModels)
  if(~isempty(find(model.back_id(i,:))))
    dim_shared = sgplvmGetDimension(model,'shared');
    dim_private = sgplvmGetDimension(model,'private',i);
    dim_generative = find(model.generative_id(i,:));
    dim_back = find(model.back_id(i,:));
    dim = [];
    if(isempty(setxor(dim_back,dim_shared)))
      % back-constraint on shared only
      dim = 'shared';
    else
      if(isempty(setxor(dim_back,dim_private)))
        % back-constraint on private only
        dim = 'private';
      elseif(isempty(setxor(dim_back,dim_generative)))
        % back-constraint active on generating dimensions
        dim = 'generative';
      end
    end
    if(~isempty(dim))
      % back-constraint valid
      valid_model.generating_model(i) = true;
    else
      % back-constraint invalid
      valid_model.generating_model(i) = false;
    end
    valid_model.dim{i} = dim;
  end
end

return;
