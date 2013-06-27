function w = sgplvmPlotDecayFunction(model,t,verbose)

% SGPLVMPLOTDECAYFUNCTION Plot fols decay functions
% FORMAT
% DESC Returns fols weight over time
% ARG model : sgplvm model
% ARG t : time vector
% ARG verbose :
% RETURN w : weight vector
%
% SEEALSO : sgplvmOptimise, sgplvmWeightUpdate, sgplvmFOLSOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM

if(nargin<3)
  verbose = true;
end

w = ones(3,length(t));


if(isfield(model,'fols')&&~isempty(model.fols.rank.alpha.decay))
  w(1,:) = computeSigmoidWeight(t,model.fols.rank.alpha.decay.rate,model.fols.rank.alpha.decay.shift);
else
  w(1,:) = ones(size(t,1),1);
end
if(isfield(model,'fols')&&~isempty(model.fols.rank.gamma.decay))
  w(2,:) = computeSigmoidWeight(t,model.fols.rank.gamma.decay.rate,model.fols.rank.gamma.decay.shift);                   
else
  w(2,:) = ones(size(t,1),1);
end
if(isfield(model,'fols')&&~isempty(model.fols.ortho.decay))
  w(3,:) = computeSigmoidWeight(t,model.fols.ortho.decay.rate,model.fols.ortho.decay.shift);
else
  w(3,:) = ones(size(t,1),1);
end

if(verbose)
  figure; hold on;
  plot(t,w(1,:),'b');
  plot(t,w(2,:),'r');
  plot(t,w(3,:),'g');
  legend({'Alpha','Gamma','Ortho'});
end

return
