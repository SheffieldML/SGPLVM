function ll = constraintLogLikelihoodLDA(model,X)

% CONSTRAINTLOGLIKELIHOODLDA Constraint loglikelihood for LDA model
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


ll = -model.lambda*trace(model.A);

return;