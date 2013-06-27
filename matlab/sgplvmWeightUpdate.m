function model = sgplvmWeightUpdate(model,t,verbose)

% SGPLVMWEIGHTUPDATE Update iteration dependent objective weights
% FORMAT
% DESC Updated objective function weights of the fols sgplvm model
% ARG model : fols sgplvm model
% ARG t : current iteration number
% ARG verbose :
% RETURN model : sgplvm model with updated weights
%
% SEEALSO : sgplvmLogLikelihood, sgplvmPlotDecayFunction
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM

if(nargin<3)
  verbose = true;
end

if(isfield(model.fols,'rank'))
  % alpha
  w = computeSigmoidWeight(t,model.fols.rank.alpha.decay.rate,model.fols.rank.alpha.decay.shift);
  model.fols.rank.alpha.weight = model.fols.rank.alpha.weight_init*w;
  if(model.fols.rank.alpha.weight<model.fols.rank.alpha.decay.truncate)
    model.fols.rank.alpha.weight = 0;
  end
  % gamma
  w = computeSigmoidWeight(t,model.fols.rank.gamma.decay.rate,model.fols.rank.gamma.decay.shift);                   
  model.fols.rank.gamma.weight = model.fols.rank.gamma.weight_init*w; 
  if(model.fols.rank.gamma.weight<model.fols.rank.gamma.decay.truncate)
    model.fols.rank.gamma.weight = 0;
  end
  if(verbose)
    fprintf('Alpha:\t%f\n',model.fols.rank.alpha.weight);
    fprintf('Gamma:\t%f\n',model.fols.rank.gamma.weight);
  end
end
if(isfield(model.fols,'ortho'))
  w = computeSigmoidWeight(t,model.fols.ortho.decay.rate,model.fols.ortho.decay.shift);
  model.fols.ortho.weight = model.fols.ortho.weight_init*w;
  if(model.fols.ortho.weight<model.fols.ortho.decay.truncate)
    model.fols.ortho.weight = 0;
  end
  if(verbose)
    fprintf('Ortho:\t%f\n',model.fols.ortho.weight);
  end
end

return
