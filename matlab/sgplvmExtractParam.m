function params = sgplvmExtractParam(model)

% SGPLVMEXTRACTPARAM Extract a parameter vector from a GP-LVM model.
% FORMAT
% DESC extracts a parameter vector from a given SGPLVM model.
% ARG model : sgplvm model from which to extract parameters
% RETURN params : model parameter vector
%
% SEEALSO : sgplvmCreate, sgplvmExpandParam, modelExtractParam
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM


if(~strcmp(model.type,'sgplvm'))
  error('Not correct model type');
end


params = [];

if(model.back)
  for(i = 1:1:model.q)
    ind = find(model.back_id(:,i));
    if(~isempty(ind))
      % dimension back-constrained
      params = [params modelExtractParam(model.comp{ind}.back,i)];
    else
      % dimension NOT back-constrained
      params = [params model.X(:,i)'];
    end
  end
  clear ind;
else
  params = model.X(:)';
end

% GP-model part
for(i = 1:1:model.numModels)
  params = [params gpExtractParam(model.comp{i})];
end

% Dynamic part
if(isfield(model,'dynamic'))
  if(model.dynamic)
    for(i = 1:1:model.dynamics.numModels)
      ind = unique([model.dynamics.comp{i}.indexOut model.dynamics.comp{i}.indexIn]);
      if(~isempty(ind))
	params = [params modelExtractParam(model.dynamics.comp{i},ind)];
      else
	warning('Dynamic model specified with no active dimensions');
      end
    end
  end
end

return

