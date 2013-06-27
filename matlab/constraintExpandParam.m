function model = constraintExpandParam(model,X)

% CONSTRAINTEXPANDPARAM Expands a constraint model
% FORMAT
% DESC Returns updated model
% ARG model : constraint model
% ARG X : Latent locations
% RETURN : constraint model
%
% SEEALSO : 
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM

fhandle = str2func(['constraintExpandParam',model.type]);
model = fhandle(model,X);

return;