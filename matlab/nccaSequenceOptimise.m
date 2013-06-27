function X = nccaSequenceOptimise(model_in,model_obs,model_trans,X,type,iters,balancing,display)

% NCCASEQUENCEOPTIMISE Jointly optimise sequence and observations
% FORMAT
% DESC 
% ARG model_in : observation model onto shared latent space
% ARG model_obs : model generating output domain
% ARG model_trans : dynamic model
% ARG X : output latent initialisation
% ARG type : optimisation type, 
% 'independent' - optimise over independent subspace generating
% output (default)
% 'all' - optimise over full space generating output
% ARG iters : max number of iterations
% ARG balancing : balancing between dynamics and observations
% (default = 1)
% ARG display : display progress (default = false)
% RETURN X : optimised latent cordinates over full output latent
% domain
%
% SEEALSO : nccaComputeModes, nccaComputeViterbiPath
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2007

% NCCA

if(nargin<8)
  display = false;
  if(nargin<7)
    balancing = 1;
    if(nargin<6)
      iters = 100;
      if(nargin<5)
	type = 'independent';
	if(nargin<4)
	  error('To Few Arguments');
	end
      end
    end
  end
end

model = model_obs;
model.dynamics = model_trans;
model.dynamics.balancing = balancing;

options = optOptions;
if(display)
  options(1) = true;
end
if(length(X(:))<21)
  options(9) = true;
end
options(14) = iters;

if(isfield(model,'optimiser'))
  optim = str2func(model.optimiser);
else
  optim = str2func('scg');
end

switch type
 case 'independent'
  Xs = X(:,1:1:model_in.d);
  dim_independent = model_in.d+1:1:size(X,2);
  X = X(:,dim_independent);
    
  X = optim('nccaSequenceObjectiveIndependent',X(:)',options,'nccaSequenceGradientIndependent',model,Xs,balancing);
  X = [Xs reshape(X,size(X,2)/length(dim_independent),length(dim_independent))];
 case 'all'
  X = optim('nccaSequenceObjectiveAll',X(:)',options,'nccaSequenceGradientAll',model,balancing);
  X = reshape(X,size(X,2)/model.q,model.q);
 otherwise
  error('Unkown Optimisation Type');
end
  
return