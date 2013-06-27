function f = sgplvmObjective(params,model)

% SGPLVMOBJECTIVE Wrapper function for GP-LVM objective.
% FORMAT
% DESC provides a wrapper function for the sgplvm, updating the
% model parameters and returning the negative log likelihood of the
% model
% ARG params : model parameters
% ARG model : sgplvm model
% RETURN f : negative log likelihood of the model
%
% SEEALSO : sgplvmLogLikelihood, sgplvmExpandParam
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2007, 2009

% SGPLVM

global CURRENT_ITERATION;

if(model.save_intermediate)
  if(mod(CURRENT_ITERATION,model.save_intermediate)==0&& CURRENT_ITERATION~=0)
    model.iteration = CURRENT_ITERATION;
    filename = strcat('model_',model.name,datestr(now),'_iter_',num2str(model.iteration));
    filename(find(isspace(filename)==true)) = '-';
    save(filename,'model');
    fprintf('Save intermediate model, iteration %d\n',model.iteration);
  end
end

CURRENT_ITERATION = CURRENT_ITERATION + 1;

% update models
model = sgplvmExpandParam(model,params);
f = - sgplvmLogLikelihood(model);

return