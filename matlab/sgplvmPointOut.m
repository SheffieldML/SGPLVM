function X = sgplvmPointOut(model,index_in,index_out,Y,type,N,Nopt,verbose,varargin)

% SGPLVMPOINTOUT Output latent location for observation
% FORMAT
% DESC Takes a sgplvm model and finds latent location
% ARG model : sgplvm model
% ARG index_in : model component index of observation generating
% model
% ARG index_out : model component index of output space
% ARG Y : observation
% ARG type : type of initialisation
% ARG N : type argument
% ARG Nopt : maximum number of iterations in optimisation
% ARG verbose :
% RETURN X : latent location
%
% SEEALSO sgplvmSequenceOut
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

% Set default arguments
if(nargin<8)
  verbose = false;
  if(nargin<7)
    Nopt = 100;
    if(nargin<6)
      N = 5;
      if(nargin<5)
	type = 'NN';
	if(nargin<4)
	  error('Too Few Arguments');
	end
      end
    end
  end
end

%1. Initialise Latent Coordinate
X_init = sgplvmInitialiseLatentPoint(model,Y,index_in,index_out,type,N,verbose);
if(Nopt==0)
  if(verbose)
    fprintf('sgplvmPointOut:\t Returning initialisation\n');
  end
  X = X_init;
else
  %2. Optimise Point
  for(i = 1:1:N)
    X(i,:) = fgplvmOptimisePoint(model.comp{index_in},X_init(i,:),Y,verbose,Nopt);
  end
end

return;

