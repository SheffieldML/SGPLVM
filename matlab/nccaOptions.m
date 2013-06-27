function options = nccaOptions(approx,kern_options)

% NCCAOPTIONS Return default options for NCCA model.
% FORMAT
% DESC options = nccaOptions(approx) returns the default options in
% a structure for a NCCA model.
% ARG approx : approximation type, either 'ftc' (no approximation),
% 'dtc' (deterministic training conditional), 'fitc' (fully
% independent training conditional) or 'pitc' (partially
% independent training conditional).
% ARG kern_options : kernel options, either 'standard' (rbf compund
% kernel) or 'ard' (ARD compund rbf kernel)
% RETURN options : option structure
%
% SEEALSO : nccaCreate, gpOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA

if(nargin<2)
  kern_options = 'ard';
  if(nargin<1)
    approx = 'ftc';
  end
end

options = gpOptions(approx);
options.optimiser = 'scg';
options.scale2var1 = true;

switch kern_options
 case 'ard'
  options.kern = {'cmpnd','rbfard','bias','white'};
 case 'standard'
  options.kern = {'cmpnd','rbf','bias','white'};
 case 'linard'
  options.kern = {'cmpnd','linard','bias','white'};
 otherwise
  error('Unkown Kernel Type');
end
  
return