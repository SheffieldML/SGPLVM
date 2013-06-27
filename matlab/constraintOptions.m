function options = constraintOptions(type)

% CONSTRAINTOPTIONS Return default options for latent constraint.
% FORMAT
% DESC Returns the defualt options for a latent constraint
% ARG TYPE : Type of constraint as string
% RETURN options : structure containing defualt options
%
% SEEALSO : fgplvmAddConstraint, sgplvmAddConstraint
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM

switch type
 case 'LDA'
  options.type = type;
  options.lambda = 1;
  options.unknown = -1;
  options.class = [];
  options.dim = [];
  options.reg = 1;
 case 'LDAPos'
  options.type = type;
  options.lambda = 1;
  options.unknown = -1;
  options.class = [];
  options.dim = [];
  options.reg = 1;
 case 'LDANeg'
  options.type = type;
  options.lambda = 1;
  options.unknown = -1;
  options.class = [];
  options.dim = [];
  options.reg = 1;
 case 'LLE'
  options.type = type;
  options.lambda = 1;
  options.nn = 7;
  options.tol = 1e-3;
 case 'CorrespondenceSequenceLDA'
  options.type = type;
  options.lambda = 1;
  options.class = [];
  options.dim = [];
 otherwise
  error('Unknown constraint');
end


return