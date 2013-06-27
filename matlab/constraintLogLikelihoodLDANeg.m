function ll = constraintLogLikelihoodLDANeg(model,X)

% CONSTRAINTLOGLIKELIHOODLDANEG Constraint loglikelihood LDA Neg model
% FORMAT
% DESC Returns loglikelihood for constraint
% ARG model : fgplvm or sgplvm model
% ARG X : Latent locations
% RETURN ll : Returns loglikelihood
%
% SEEALSO :
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM


ll = -model.lambda*trace(model.A);

return;