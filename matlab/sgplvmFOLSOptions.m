function options = sgplvmFOLSOptions(type)

% SGPLVMFOLSOPTIONS Returns options struct for fols model
% FORMAT
% DESC Return a options struct for the fols model
% ARG type : options specifier
% RETURN options : fols option struct
%
% SEEALSO : sgplvmCreate
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009, 2010

% SGPLVM

if(nargin<1)
  type = 'standard';
end

switch type
 case 'none'
  options = [];
  
  return
 otherwise
  options.cropp = true;
  options.cropp_iter = 10;
  options.cropp_ratio = 0.05;

  options.rank.alpha.weight = 100;
  options.rank.alpha.decay.rate = -0.5;
  options.rank.alpha.decay.shift = 100;
  options.rank.alpha.decay.truncate = 0;

  options.rank.beta.weight = 1;
  options.rank.beta.decay.rate = 0;
  options.rank.beta.decay.shift = 0;
  options.rank.beta.decay.truncate = 0;

  options.rank.gamma.observed = true;
  options.rank.gamma.weight = 5e-3;
  options.rank.gamma.decay.rate = 0;
  options.rank.gamma.decay.shift = 0;
  options.rank.gamma.decay.truncate = 0;

  options.ortho.weight = 1;
  options.ortho.decay.rate = 0;
  options.ortho.beta.decay.shift = 0;
  options.ortho.decay.truncate = 0;
end