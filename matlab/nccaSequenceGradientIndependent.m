function g = nccaSequenceGradientIndependent(xvec,model,Xs,varargin)

% NCCASEQUENCEGRADIENTINDEPENDENT Compute gradients to latent
% sequence for independent part of ncca embedding
% FORMAT
% DESC Compute Gradients for nccaSequenceObjectiveIndependent
% ARG xvec : latent positions
% ARG model : model generating observations
% ARG Xs : shared latent positions
% RETURN g : gradient of the indpendent latent coordinates
%
% SEEALSO : nccaSequenceGradientAll
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

X = [Xs reshape(xvec,size(Xs,1),model.q-size(Xs,2))];
Y = gpOut(model,X);
X = X(:)';
g = fgplvmSequenceGradient(X,model,Y);
g = g(prod(size(Xs))+1:1:end);

return