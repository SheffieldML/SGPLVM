function X = sgplvmInitialiseLatentPointFromShared(model,Xs,index_out,type,N,verbose)

% SGPLVMINITIALISELATENTPOINTFROMSHARED Initialise latent location given observation(s)
% FORMAT
% DESC Initialise latent location for given observation(s)
% ARG model : sgplvm model
% ARG Xs : shared latent location
% ARG index_out : component index to output generating model
% ARG type : type of initialisation (default NN)
% ARG N : optional argument for type
% ARG verbose :
% RETURN X : latent location of initialisation
%
% SEEALSO : sgplvmInitialiseLatentSequence, sgplvmInitialiseLatentPoint, sgplvmSequenceOut
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

if(nargin<6)
  verbose = false;
  if(nargin<5)
    N = 1;
    if(nargin<4)
      type = 'NN';
      if(nargin<3)
        error('Too Few Arguments');
      end
    end
  end
end

switch type
 case 'all'
  N = size(model.X,1);
end

X = cell(size(Xs,1),1);
for(i = 1:1:N)
  X{i} = zeros(N,model.q);
end
dim_shared = [];
for(i = 1:1:model.q)
  if(length(find(model.generative_id(:,i)))==model.numModels)
    dim_shared = [dim_shared i];
  end
end
if(length(dim_shared)~=size(Xs,2))
  error('Mismatch in Shared Dimensions');
end
dim_private = sgplvmGetDimension(model,'private',index_out);

switch type
 case 'randn'
  
 case {'nn','NN','nn_train','NN_train','min'}
  class = nn_class(model.X(:,dim_shared),Xs,N,'euclidean');
  for(i = 1:1:size(Xs,1))
    switch type
     case {'nn','NN'}
      X{i}(:,dim_private) = model.X(class(i,:),dim_private);
      X{i}(:,dim_shared) = repmat(Xs(i,:),N,1);
     case {'nn_train','NN_train'}
      X{i}(:,:) = model.X(class(i,:),:);
    end
  end
  
 case {'all'}
  for(i = 1:1:size(Xs,1))
    X{i}(:,dim_private) = model.X(:,dim_private);
    X{i}(:,dim_shared) = repmat(Xs(i,:),size(model.X,1),1);
  end
 case {'min'}
  % optimise private locations
  
  
 otherwise
  error('Unknown Initialisation Type');
end

return;

