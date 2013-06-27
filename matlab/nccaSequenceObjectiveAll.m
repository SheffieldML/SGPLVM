function f = nccaSequenceObjectiveAll(xvec,model,varargin)

% NCCASEQUENCEOBJECTIVEALL Compute objective over full latent space
% FORMAT
% DESC Computes objective for a sequence over the full latent space
% for a ncca model
% ARG xvec : latent positions
% ARG model : model generating output observations
% RETURN f : objective
%
% SEEALSO : fgplvmSequenceObjective
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

X = reshape(xvec,size(xvec,2)/model.q,model.q);
Y = gpOut(model,X);
X = X(:)';

f = fgplvmSequenceObjective(X,model,Y);

return;