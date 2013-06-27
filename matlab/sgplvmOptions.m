function options = sgplvmOptions

% SGPLVMOPTIONS Return default options for FGPLVM model.
% FORMAT
% DESC Returns the defualt options for a sgplvm model
% ARG NULL : NULL
% RETURN options : structure containing defualt options
%
% SEEALSO : sgplvmCreate, gpOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM

options.optimiser = 'scg';
options.name = 'sgplvm_';
options.save_intermediate = inf;
options.fols = [];