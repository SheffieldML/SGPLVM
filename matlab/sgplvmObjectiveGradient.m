function [f, g] = sgplvmObjectiveGradient(params, model)

% SGPLVMOBJECTIVEGRADIENT Wrapper function for SGPLVM objective and gradient.
% FORMAT
% DESC : returns the negative log likelihood and the gradients of
% the negative log likelihood for the given model and parameters
% ARG params : the parameters of the model for which the objective
% and gradients will be evaluated
% ARG model : the sgplvm model
% RETURN f : negative log likelihood of model
% RETURN g : gradient of negative log likelihood
%
% SEEALSO : minimize, sgplvmGradient, sgplvmLogLikelihood,
% sgplvmOptimise
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM

% Check how the optimiser has given the parameters
if size(params, 1) > size(params, 2)
  % As a column vector ... transpose everything.
  transpose = true;
  model = sgplvmExpandParam(model, params');
else
  transpose = false;
  model = sgplvmExpandParam(model, params);
end

f = - sgplvmLogLikelihood(model);
if nargout > 1
  g = - sgplvmLogLikeGradients(model);
  if transpose
    g = g';
  end
end
