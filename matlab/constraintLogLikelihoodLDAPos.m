function ll = constraintLogLikelihoodLDAPos(model,X);

% CONSTRAINTLOGLIKELIHOODLDAPOS Returns loglikelihood for LDAPos constraint
% FORMAT
% DESC Returns loglikelihood for LDAPos constraint
% ARG model : fgplvm model
% ARG X : Latent locations
% RETURN ll : Returns loglikelihood
%
% SEEALSO : constraintLogLikelihood
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM

ll = -model.lambda*trace(model.A);

return