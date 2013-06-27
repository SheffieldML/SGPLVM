function g = sgplvmGradient(params, model)

% SGPLVMGRADIENT sGP-LVM gradient wrapper.
% FORMAT
% DESC is a wrapper function for the gradient of the negative log
% likelihood of an sgplvm model with respect to the latent
% positions and model parameters
% ARG params : model parameters for which gradient is to be
% evaluated
% ARG model : sgplvm model
% RETURN g : the gradient of the model negative log likelihood
%
% SEEALSO : sgplvmLogLikeGradients, sgplvmExpandParam
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM

model = sgplvmExpandParam(model,params);
g = - sgplvmLogLikeGradients(model);

return