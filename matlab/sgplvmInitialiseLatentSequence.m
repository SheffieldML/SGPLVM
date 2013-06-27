function X = sgplvmInitialiseLatentSequence(model,Y,index_in,index_out,index_dyn,type,N,verbose)

% SGPLVMINITIALISELATENTSEQUENCE Initialise latent location given observation(s)
% FORMAT
% DESC Initialise latent location for given observation(s)
% ARG model : sgplvm model
% ARG Y : observation, if multiple observation spaces as cell-array
% ARG index_in : component index to model generating observations
% ARG index_out : component index to output generating model
% ARG index_dyn : component index to dynamic model
% ARG type : type of initialisation (default NN)
% ARG N : optional argument for type
% ARG verbose :
% RETURN X : latent location of initialisation
%
% SEEALSO : sgplvmInitialiseLatentPoint, sgplvmSequenceOut
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

if(~model.dynamic||isempty(model.dynamics.comp{index_dyn}))
  % no dynamic model
  X = zeros(size(Y,1),model.q);
  for(i = 1:1:size(Y,1))
    X(i,:) = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,type,1,verbose);
  end
  return;
end

switch type
 case 'NN'
  X = zeros(size(Y,1),model.q);
  % simple point initialisation
  if(N==1)
    for(i = 1:1:size(Y,1))
      X(i,:) = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,type,1,verbose);
    end
  else
    for(i = 1:1:size(Y,1))
      Xnn = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,type,N,verbose);
      % choose likeliest NN
      [void varSigma] = gpPosteriorMeanVar(model.comp{index_out}, ...
					   Xnn);
      varSigma = varSigma(:,1);
      [void ind] = sort(varSigma,'ascend');
      X(i,:) = Xnn(ind(1),:);
    end
  end
 case {'NN_DIM','NN_dim','nn_dim','nn_dim_bc','NN_DIM_BC'}
  if(N==1)
    for(i = 1:1:size(Y,1))
      X(i,:) = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,type,1,verbose);
    end
  else
    for(i = 1:1:size(Y,1))
      Xnn = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,type,N,verbose);
      % choose likeliest NN
      [void varSigma] = gpPosteriorMeanVar(model.comp{index_out}, ...
					   Xnn);
      varSigma = varSigma(:,1);
      [void ind] = sort(varSigma,'ascend');
      X(i,:) = Xnn(ind(1),:);
    end
  end
 case {'HMM_NN','HMM_nn','HMM_NN_DIM_BC','HMM_nn_dim_bc','HMM_train','HMM_TRAIN'}
  switch type
   case {'HMM_NN','HMM_nn'}
    %1. Compute labels
    Xlabel = cell(size(Y,1),1);
    for(i = 1:1:size(Y,1))
      Xlabel{i} = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,'NN',N,verbose);
    end
   case {'HMM_NN_DIM_BC','HMM_nn_dim_bc'}
    %1. Compute labels
    Xlabel = cell(size(Y,1),1);
    for(i = 1:1:size(Y,1))
      Xlabel{i} = sgplvmInitialiseLatentPoint(model,Y(i,:),index_in,index_out,'NN_DIM_BC',N,verbose);
    end
   case {'HMM_train','HMM_TRAIN'}
    Xlabel = model.X;
    if(isfield(model.dynamics.comp{index_dyn},'Trans_train')&&~ ...
       isempty(model.dynamics.comp{index_dyn}.Trans_train))
      Trans = model.dynamics.comp{index_dyn}.Trans_train;
    end
  end
  if(~isfield(model.dynamics.comp{index_dyn},'Trans_train')||~ ...
       isempty(model.dynamics.comp{index_dyn}.Trans_train))
    %2. Compute Translation Probabilities
    Trans = gpComputeTranslationLogLikelihood(model.dynamics.comp{index_dyn},Xlabel,verbose);
    switch type
     case {'HMM_train','HMM_TRAIN'}
      model.dynamics.comp{index_dyn}.Trans_train = Trans;
    end
  end
  %3. Compute Observation Probabilities
  Obs = gpComputeObservationLogLikelihood(model.comp{index_in},Xlabel,Y,verbose);
  
  %4. Compute Viterbi Path
  path = computeViterbipath(Obs,Trans,[],'log',verbose);
  
  %5. Unravel path
  X = zeros(size(Y,1),model.q);
  if(iscell(Xlabel))
    for(i = 1:1:length(path))
      X(i,:) = Xlabel{i}(path(i),:);
    end
  else
    for(i = 1:1:length(path))
      X(i,:) = Xlabel(path(i),:);
    end
  end
 otherwise
  error('Unknown Type');
end