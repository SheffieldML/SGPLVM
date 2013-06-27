function ll = constraintLogLikelihood(model,X)

% CONSTRAINTLOGLIKELIHOOD Wrapper for Constraint loglikelihood
% FORMAT
% DESC Returns loglikelihood for constraint
% ARG model : fgplvm model
% ARG X : Latent locations
% RETURN ll : Returns loglikelihood
%
% SEEALSO :
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM

fhandle = str2func(['constraintLogLikelihood' model.type]);
ll = fhandle(model,X);

return