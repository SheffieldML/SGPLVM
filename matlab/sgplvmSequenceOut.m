function [X X_init]= sgplvmSequenceOut(model,Y,index_in,index_out,type,dim,index_dyn,N,iters,display,balancing,gradcheck,optimiser,verbose)
% SGPLVMSEQUENCEOUT Output latent location for observation
% FORMAT
% DESC Takes a sgplvm model and finds latent location corresponding
% to a sequence of observations
% ARG model : sgplvm model
% ARG Y : observation sequence
% ARG index_in : model component index of observation generating
% model
% ARG index_out : model component index of output space
% ARG type : type of initialisation
% ARG dim : dimensions to alter
% ARG index_dyn : model component index to dynamic model
% ARG N : type argument
% ARG iters : maximum number of iterations in optimisation
% ARG display : display optimisation iterations
% ARG balancing : balancing between generative and sequential
% objective terms
% ARG gradcheck : check gradients
% ARG optimiser : optimiser (default = 'scg')
% ARG verbose :
% RETURN X : latent location
%
% SEEALSO sgplvmSequenceOut
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

%1. Initialise sequence
X_init = sgplvmInitialiseLatentSequence(model,Y,index_in,index_out,index_dyn,type,N,verbose);

%2. Optimise sequence
if(model.dynamic)
  X = sgplvmOptimiseDimVarSequence(model.comp{index_in},model.dynamics.comp{index_dyn},X_init,dim,balancing,display,iters,gradcheck,optimiser);
else
  X = X_init;
end
  
return;

