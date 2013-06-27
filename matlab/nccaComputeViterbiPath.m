function X = nccaComputeViterbiPath(model_obs_in,model_obs_out,model_dyn,X_mode,Y,balancing,display)

% NCCACOMPUTEVITERBIPATH Computes Viterbi path through a set of latent modes given model with dynamics
% FORMAT 
% DESC computes Viterbi path through a set of latent modes given model with dynamics.
% ARG model_obs_in : observation space model onto shared latent
% space
% ARG model_obs_out : observation space generation model
% ARG model_dyn : dynamic model
% ARG X_mode : latent space modes
% ARG Y : observations
% ARG balancing : balancing between dynamics and observations
% (default = 1)
% ARG display : display progress (default = false)
% RETURN X : Modes associated with Viterbi path
%
% SEEALSO : computeObs.m, computeTransT.m, viterbi_path_log_transT.m
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2007

% NCCA

if(nargin<7)
  display = false;
  if(nargin<6)
    balancing = 1;
    if(nargin<5)
      error('To Few Arguments');
    end
  end
end

Obs = computeObs(model_obs_in,model_obs_out,X_mode,Y,display);
Trans = computeTransT(model_dyn,X_mode,false,display);
Trans = Trans.*balancing;
path = viterbi_path_log_transT(zeros(1,size(X_mode{1},1)),Trans,Obs,display);

X = zeros(length(path),size(X_mode{1},2));
for(i = 1:1:length(path))
  X(i,:) = X_mode{i}(path(i),:);
end

return

