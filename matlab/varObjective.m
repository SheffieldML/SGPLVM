function f = varObjective(params,model,Xs)

% VAROBJECTIVE
%
% COPYRIGHT : Carl Henrik Ek and Neil Lawrence, 2008

% NCCA

[void f] = gpPosteriorMeanVar(model,[Xs params]);
% For speed skip scaling
%f = 1./sqrt(2*pi*f(:,1));
f = f(:,1);

return