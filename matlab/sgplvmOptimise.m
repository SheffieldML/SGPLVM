function model = sgplvmOptimise(model,display,iters,g_check,save_flag,options_sgplvm)

% SGPLVMOPTIMISE Optimise the SGPLVM.
% FORMAT
% DESC Takes a sgplvm model structure and optimises with respect to
% parameters and latent coordinates
% ARG model : sgplvm model
% ARG display : flag dictating wheter or not to display
% optimisation progress (set to greater than zero) (default = 1)
% ARG iters : maximum number of iterations (default = 2000)
% ARG g_check : Should analytic gradientes be compared with finite
% differences of objective (default = false)
% ARG save_flag : Should final model be saved to disk (default =
% false)
% RETURN model : the optimised model
%
% SEEALSO : sgplvmObjective, sgplvmGradient
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007
%
% MODIFICATIONS : Mathieu Salzmann, Carl Henrik Ek, 2009

% SGPLVM

if(nargin<5)
  save_flag = false;
  if(nargin<4)
    g_check = false;
    if(nargin<3)
      iters = 2000;
      if(nargin<2)
	display = true;
	if(nargin<1)
	  error('To Few Arguments');
	end
      end
    end
  end
end

global CURRENT_ITERATION;
CURRENT_ITERATION = 0;

params = sgplvmExtractParam(model);
options = optOptions;
if(display)
  options(1) = true;
  if(exist('g_check'))
    options(9) = g_check;
  else
    if(length(params)<= 100)
      options(9) = true;
    end
  end
end
options(14) = iters;

if(isfield(model,'optimiser'))
  if(~isempty(model.optimiser))
    optim = str2func(model.optimiser);
  else
    optim = str2func('scg');
  end
else
  optim = str2func('scg');
end

if strcmp(func2str(optim), 'optimiMinimize')
  % Carl Rasmussen's minimize function 
  params = optim('sgplvmObjectiveGradient', params, options, model);
elseif strcmp(func2str(optim), 'fmincon')
    %constrained optimization
    if(exist('g_check') && g_check)
        Options=optimset('MaxFunEvals',10*iters,'MaxIter',iters,'GradObj','on','GradConstr','on','DerivativeCheck','on','Display','iter','Algorithm','interior-point','SubproblemAlgorithm','cg');
    else
        Options=optimset('MaxFunEvals',10*iters,'MaxIter',iters,'GradObj','on','GradConstr','on','DerivativeCheck','off','Display','iter','Algorithm','interior-point','SubproblemAlgorithm','cg');
    end
    params = optim(@sgplvmObjectiveGradient, params', [], [], [], [], [], [], @sgplvmConstraintsGradient, Options, model);
    params = params';
else
  % NETLAB style optimization.
  if(isfield(model,'fols')&&~isempty(model.fols)&&model.fols.cropp&&exist('options_sgplvm','var'))
    options(14) = model.fols.cropp_iter;
    iteration = CURRENT_ITERATION;
    if(isfield(model,'iteration')&&~isempty(model.iteration))
      iteration = iteration + model.iteration;
    end
    for(i = 1:1:round(iters/model.fols.cropp_iter))
      model = sgplvmWeightUpdate(model,iteration,false);                                  
      sgplvmLogLikelihood(model,display);
      sgplvmLogLikeGradients(model,display);
      params = optim('sgplvmObjective', params, options, 'sgplvmGradient',model);
      model = sgplvmExpandParam(model, params);
      model = sgplvmCroppDimension(model,options_sgplvm,display);
      params = sgplvmExtractParam(model);
      iteration = iteration + model.fols.cropp_iter;
    end
  else
    params = optim('sgplvmObjective', params,  options, 'sgplvmGradient', model);
  end
end

model = sgplvmExpandParam(model, params);
if(~isfield(model,'iteration')||model.iteration==0)
  model.iteration = CURRENT_ITERATION-1;
else
  model.iteration = model.iteration + CURRENT_ITERATION-1;
end

if(save_flag)
  filename = strcat('model_',model.name,datestr(now),'_iter_',num2str(model.iteration),'FINAL');
  filename(find(isspace(filename)==true)) = '-';
  save(filename,'model');
  fprintf('Save converged model, iteration %d\n',model.iteration);
end

return