function x = sgplvmOptimisePoint(model,x,Y,display,iters,comps,gradcheck)

% SGPLVMOPTIMISEPOINT Optimise the latent location.
% FORMAT
% DESC Takes a sgplvm model structure, observed point and latent initialisation 
% and optimises latent location
% ARG model : sgplvm model
% ARG x : latent initialisation
% ARG Y : observed data
% ARG display : flag dictating wheter or not to display
% optimisation progress (set to greater than zero) (default = 1)
% ARG iters : maximum number of iterations (default = 2000)
% ARG comps: generative models associated with observed data
% ARG gradcheck : Should analytic gradientes be compared with finite
% differences of objective (default = false)
% RETURN model : x latent location
%
% SEEALSO : sgplvmObjective, sgplvmGradient
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM


if(nargin<7)
  gradcheck = false;
end

options = optOptions;
if(display)
  options(1) = true;
end
if(gradcheck)
  options(9) = true;
end
options(14) = iters;

if isfield(model, 'optimiser')
  optim = str2func(model.optimiser);
else
  optim = str2func('scg');
end

x = optim('sgplvmPointObjective',x,options,'sgplvmPointGradient',model,Y, ...
          comps);

return;