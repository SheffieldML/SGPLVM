function X = nccaComputeModes(model_g,model_f,Y,nr_nn,display,nr_iters)

% NCCACOMPUTEMODES Compute modes over latent space from NCCA model
% FORMAT
% DESC X = nccaComputeModes(model_g,model_f,Y,nr_nn,display)
% ARG model_g : model mapping onto shared latent space from Y
% domain
% ARG model_f : model mapping from latent space to output domain
% ARG Y : input data
% ARG nr_nn : number of optimisation initialisations
% ARG display : display progress (requiers active matlab display)
% RETURN X : modes on output latent space
%
% SEEALSO : NULL
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% NCCA


Xs = modelOut(model_g,Y);
dim_independent = setdiff(1:1:model_f.q,1:1:size(Xs,2));;
if(isempty(dim_independent))
  X = Xs;
  return
end

opt_options = optOptions;
if(exist('nr_iters','var'))
  opt_options(14) = nr_iters;
else
  opt_options(14) = 100;
end
opt_options(9) = false;
opt_options(1) = false;

X = cell(size(Y,1),1);
if(display)
  handle_waitbar = waitbar(0,'Optimising');
end
for(i = 1:1:size(Y,1))
  class = nn_class(model_g.y,Xs(i,:),nr_nn,'euclidean');
  for(j = 1:1:length(class))
    X{i}(j,:) = scg('varObjective',model_f.X(class(j),dim_independent),opt_options,'varGradient',model_f,Xs(i,:));
  end
  % append shared dimensions
  X{i} = [repmat(Xs(i,:),size(X{i},1),1) X{i}];
  if(display)
    waitbar(i/size(Y,1));
  end
end
if(display)
  close(handle_waitbar);
end


return
  

