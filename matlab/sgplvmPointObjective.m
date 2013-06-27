function f = sgplvmPointObjective(x,model,Y,comps)

% SGPLVMPOINTOBJECTIVE Gradient of latent location given observed points
% FORMAT
% DESC Takes a sgplvm model structure, observed point and latent location and returns objective
% ARG x : latent initialisation
% ARG model : sgplvm model
% ARG Y : observed data (if more than one observation space as cell array)
% ARG comps: generative models associated with observed data
% RETURN model : the optimised model
%
% SEEALSO : sgplvmPointGradient, 
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM


if(length(comps)==1&&~iscell(Y))
  f = fgplvmPointObjective(x,model.comp{comps(1)},Y);
else
  f = 0;
  for(i = 1:1:length(comps))
    f = f + fgplvmPointObjective(x,model.comp{comps(i)},Y{i});
  end
end

return