function X = sgplvmOptimiseDimVarSequence(model_obs,model_dyn,X,dim,balancing,display,iters,gradcheck,optimiser)

% SGPLVMOPTIMISEDIMVARSEQUENCE Optimise subspace of latent sequence
% FORMAT
% DESC Takes a fgplvm model and finds the latent location
% minimizing the variance on the output space
% ARG model_obs : fgplvm model generating observations
% ARG model_dyn : dynamical model
% ARG X : latent initialisation
% ARG dim : dimensions to optimise
% ARG balancing : balancing between generative and sequential
% objective terms
% ARG display : display optimisation iterations
% ARG iters : maximum number of iterations
% ARG gradcheck : check gradients
% ARG optimiser : optimiser (default = 'scg')
% RETURN X : optimised latent location
%
% SEEALSO : sgplvmOptimiseDimVar
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2008

% SGPLVM

if(nargin<9)
  optimiser = 'scg';
  if(nargin<8)
    gradcheck = false;
    if(nargin<7)
      iters = 100;
      if(nargin<6)
	display = 0;
	if(nargin<5)
	  balancing = 1;
	  if(nargin<4)
	    error('Too Few Arguments');
	  end
	end
      end
    end
  end
end

% check arguments
if(~isempty(setdiff(dim,model_dyn.indexOut)))
  fprintf('sgplvmOptimiseDimVarSequence:\tDynamic model does not cover all requested dimensions\n');
end

model = model_obs;
model.dynamics = model_dyn;

% set optimisation settings
options = optOptions;
options(14) = iters;
options(9) = gradcheck;
options(1) = display;

optFunc = str2func(optimiser);

% optimise
params = X(:,dim);
params = params(:)';
params = optFunc('varDimSequenceObjective',params,options,'varDimSequenceGradient',model,X,dim,balancing);

X(:,dim) = reshape(params,size(X,1),length(dim));


return;
