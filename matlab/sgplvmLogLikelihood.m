function ll = sgplvmLogLikelihood(model,verbose)

% SGPLVMLOGLIKELIHOOD Log-likelihood for a SGP-LVM.
% FORMAT
% DESC Returns the log likelihood for the given sgplvm model
% ARG model : sgplvm model
% RETURN ll : log likelihood of given sgplvm model
%
% SEEALSO : fgplvmLogLikelihood, sgplvmCreate
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007, 2009, 2010
%
% MODIFICATIONS : Mathieu Salzmann, Carl Henrik Ek, 2009
%                 Carl Henrik Ek, 2010

% SGPLVM

if(nargin<2)
  verbose = false;
end
if(verbose)
  ll_part_name = {'GP(recon)','Prior/Dyn','Approximation','Constraint','Rank_A(min)','Rank_G(pres)','CCA(ortho)'};
  ll_part = zeros(1,length(ll_part_name));
end


ll = 0;

% 1. gp
for(i = 1:1:model.numModels)
  ll = ll + gpLogLikelihood(model.comp{i});
end
if(verbose)
  ll_part(1) = ll;
end


% 2. latent prior
if(isfield(model,'dynamics')&&~isempty(model.dynamics))
  % dynamic prior
  for(i = 1:1:model.dynamics.numModels)
    if(isfield(model.dynamics.comp{i},'balancing'))
      balancing = model.dynamics.comp{i}.balancing;
    else
      balancing = 1;
    end
    ll = ll + balancing*modelLogLikelihood(model.dynamics.comp{i});
  end
  % find dimensions with no dynamic prior
  non_dyn_dim = [];
  for(i = 1:1:model.q)
    ind = find(model.dynamic_id(:,i));
    if(isempty(ind))
      non_dyn_dim = [non_dyn_dim i];
    end
  end
  if(~isempty(non_dyn_dim))
    % find generative models with input from non_dyn_dim
    gen_model_id = find(model.generative_id(:,non_dyn_dim));
    [gen_model_id void] = ind2sub(size(model.generative_id(:,non_dyn_dim)),gen_model_id);
    gen_model_id = unique(gen_model_id)';
    for(i = 1:1:length(gen_model_id))
      if(isfield(model.comp{gen_model_id(i)},'prior')&&~isempty(model.comp{gen_model_id(i)}))
	dim = find(model.generative_id(gen_model_id(i),:));
	dim = intersect(dim,non_dyn_dim);
	for(j = 1:1:model.N)
	  ll = ll + priorLogProb(model.comp{gen_model_id(i)}.prior,model.X(j,dim));
	end
      end
    end
  end
else
  % no dynamic
  for(i = 1:1:model.numModels)
    if(isfield(model.comp{i},'prior')&&~isempty(model.comp{i}.prior))
      for(j = 1:1:model.N)
	dim = find(model.generative_id(i,:));
	ll = ll + priorLogProb(model.comp{i}.prior,model.X(j,dim));
      end
    end
  end
end
if(verbose)
  ll_part(2) = ll - ll_part(1);
end

% 3. sparse approximation
for(i = 1:1:model.numModels)
  switch model.comp{i}.approx
   case {'dtc','fitc','pitc'}
    if(isfield(model.comp{i},'inducingPrior')&&~isempty(model.comp{i}.inducingPrior))
      for(j = 1:1:model.comp{i}.k)
	ll = ll + priorLogProb(model.comp{i}.inducingPrior, model.comp{i}.X_u(j,:));
      end
    end
   otherwise
  end
end
if(verbose)
  ll_part(3) = ll - sum(ll_part);
end

% 4. constraint
if(isfield(model,'constraints')&&~isempty(model.constraints))
  for(i = 1:1:model.constraints.numConstraints)
    ll = ll + constraintLogLikelihood(model.constraints.comp{i},model.X);
  end
end
if(verbose)
  ll_part(4) = ll - sum(ll_part);
end


% 5. rank constraints
if(isfield(model,'fols')&&isfield(model.fols,'rank')&&(model.fols.rank.alpha.weight>0))
  start = model.fols.qs+1;
  %private ranks
  for i=1:length(model.fols.qp)
    S = svd(model.X(:,find(model.generative_id(i,:))));
    S2 = S.*S;
    ll = ll - model.fols.rank.alpha.weight*sum(log(1+model.fols.rank.beta.weight*S2/model.fols.rank.alpha.rel_alphas(i)));
    if(verbose)
      ll_part(5) = ll_part(5) + ll - sum(ll_part);
    end
    %energy loss penalty
    if(model.fols.rank.gamma.weight > 0)
      dE = model.fols.sumS2(i) - sum(S2);
      ll = ll - (model.fols.rank.gamma.weight/model.fols.rank.alpha.rel_alphas(i))*dE*dE;
    end
    if(verbose)
      ll_part(6) = ll_part(6) + ll - sum(ll_part);
    end
    start = start+model.fols.qp(i);
  end
end

% 6. CCA constraints
if(isfield(model,'fols')&&isfield(model.fols,'ortho')&&(model.fols.ortho.weight>0))
  nd = length(model.fols.qp);
  qsi = model.fols.qs;
  for i=1:nd
    Xy = model.X(:,find(model.generative_id(i,:)));
    for j=i+1:nd
      Xz = model.X(:,find(model.generative_id(j,:)));
      dp = (Xy(:,qsi+1:end)'*Xz(:,qsi+1:end));%./(model.N*model.N);
      ll = ll - model.fols.ortho.weight*trace(dp*dp');
    end
  end
  dp = (model.X(:,1:model.fols.qs)'*model.X(:,model.fols.qs+1:end));%./(model.N*model.N);
  ll = ll - model.fols.ortho.weight*trace(dp*dp');
end
if(verbose)
  ll_part(7) = ll - sum(ll_part);
end

if(verbose)
  fprintf('\nNegative LogLikelihood Components\n');
  ll_part = -ll_part;
  for(i = 1:1:length(ll_part))
    fprintf('%s:\t\t%2.3f\n',ll_part_name{i},100.*abs(ll_part(i))./sum(abs(ll_part)));
  end
  fprintf('\n');
end

return;