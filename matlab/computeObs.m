function Obs = computeObs(model_g,model_f,X,Y,display)

% COMPUTEOBS Compute observation likelihoods in the ncca model
% FORMAT
% DESC Compute Observation likelihood for a set of modes and
% observations in a ncca model
% ARG model_g : model generating observation domain
% ARG model_f : model generating corresponding observation domain
% ARG X : modes on latent space
% ARG Y : observations
% ARG display : display progress
% RETURN Obs : Model log likelihood Matrix
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2007

% NCCA

dim_shared = 1:1:model_g.d;

Obs = zeros(size(X{1},1),size(X,1));
if(display)
  handle_waitbar = waitbar(0,'Computing Observation Probabilities');
end
for(i = 1:1:size(X,1))
  Obs(:,i) = ones(size(Obs,1),1)*gpPointLogLikelihood(model_g,Y(i,:),X{i}(1,dim_shared));
  for(j = 1:1:size(X{i},1))
    [mu varSigma] = gpPosteriorMeanVar(model_f,X{i}(j,:));
    ll = -0.5*sum(log(2*pi)+log(varSigma));
    Obs(j,i) = Obs(j,i)+ll;
  end
  if(display)
    waitbar(i/size(X,1));
  end
end
if(display)
  close(handle_waitbar);
end

return