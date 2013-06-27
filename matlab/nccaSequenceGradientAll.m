function g = nccaSequenceGradientAll(xvec,model,varargin)

% NCCASEQUENCEGRADIENTALL Compute gradients to latent
% sequence over full latent space
% FORMAT
% DESC Compute Gradients for nccaSequenceObjectiveIndependent
% ARG xvec : latent positions
% ARG model : model generating observations
% RETURN g : gradient of the indpendent latent coordinates
%
% SEEALSO : nccaSequenceGradientIndependent
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

X = reshape(xvec,size(xvec,2)/model.q,model.q);
Y = gpOut(model,X);
X = X(:)';
g = fgplvmSequenceGradient(X,model,Y);

return