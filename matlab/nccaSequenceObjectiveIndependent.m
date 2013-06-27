function f = nccaSequenceObjectiveIndependent(xvec,model,Xs,varargin)

% NCCASEQUENCEOBJECTIVEINDEPENDENT Compute objective over
% independent subspace of latent space
% FORMAT
% DESC Computes objective for a sequence over the independent
% subspace of latent space for a ncca model
% ARG xvec : latent positions
% ARG model : model generating output observations
% RETURN f : objective
%
% SEEALSO : fgplvmSequenceObjective
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

X = [Xs reshape(xvec,size(Xs,1),model.q-size(Xs,2))];
Y = gpOut(model,X);
X = X(:)';

f = fgplvmSequenceObjective(X,model,Y);

return;