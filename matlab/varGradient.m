function g = varGradient(params,model,Xs)

% VARGRADIENT
%
% COPYRIGHT : Carl Henrik Ek and Neil Lawrence, 2008

% NCCA

dim_independent = setdiff(1:1:model.q,1:1:size(Xs,2));

[void g] = gpPosteriorGradMeanVar(model,[Xs params]);
g = g(dim_independent,1)';

return