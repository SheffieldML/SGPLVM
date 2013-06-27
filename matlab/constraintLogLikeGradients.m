function gX = constraintLogLikeGradients(model)

% CONSTRAINTLOGLIKEGRADIENTS Wrapper for constraint loglike gradients
% FORMAT
% DESC Returns loglikelihood for LDAPos constraint
% ARG model : fgplvm model
% RETURN options : Returns loglike gradients
%
% SEEALSO : constraintLogLikellihood
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM

fhandle = str2func(['constraintLogLikeGradients',model.type]);
gX = fhandle(model);

return