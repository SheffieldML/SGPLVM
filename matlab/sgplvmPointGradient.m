function g = sgplvmPointGradient(x,model,Y,comps)

% SGPLVMPOINTGRADIENT Gradient of latent location given observed points
% FORMAT
% DESC Takes a sgplvm model structure, observed point and latent initialisation 
% and returns latent gradients
% ARG x : latent initialisation
% ARG model : sgplvm model
% ARG Y : observed data (if more than one observation space as cell array)
% ARG comps: generative models associated with observed data
% RETURN model : the optimised model
%
% SEEALSO : sgplvmPointObjective, 
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM


if(length(comps)==1&&~iscell(Y))
  g = fgplvmPointGradient(x,model.comp{comps(1)},Y);
else
  g = zeros(1,model.q);
  for(i = 1:1:length(comps))
    g = g + fgplvmPointGradient(x,model.comp{comps(i)},Y{i});
  end
end

return