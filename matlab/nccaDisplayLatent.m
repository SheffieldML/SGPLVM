function [C X Y] = nccaDisplayLatent(model,x,type,N,display)

% NCCADISPLAYLATENT
%
% COPYRIGHT : Carl Henrik Ek, 2008

% NCCA

if(nargin<5)
  display = false;
  if(nargin<4)
    N = 50;
    if(nargin<3)
      if(size(x,2)==size(model.fy.y,1))
	type = 'Y';
      elseif(size(x,2)==size(model.fz.z,2))
	type = 'Z';
      end
      if(nargin<2)
	error('Too Few Arguments');
      end
    end
  end
end

if(~exist('type','var'))
  error('Could not determine type of input');
end
if(~strcmp(model.type,'ncca'))
  error('The supplied model is not of required type');
end

switch type
 case 'Y'
  model_in = model.gy;
  model_out = model.fz;
 case 'Z'
  model_in = model.gz;
  model_out = model.fy;
 otherwise
  error('Unkown Type');
end
if(size(x,2)~=model_in.q)
  error('Dimensionality mismatch between model and input data');
end

if(model_out.q~=2)
  error('Only Two Dimensional Latent Spaces');
end

mu = gpPosteriorMeanVar(model_in,x);
if(size(mu,2)~=1)
  error('This is a regression model, not a NCCA model');
end

dim_min = min(model_out.X.*1.1);
dim_max = max(model_out.X.*1.1);
X_inv = zeros(2,N);
for(i = 1:1:2)
  X_inv(i,:) = (linspace(dim_min(i),dim_max(i),N))';
end
X_inv = X_inv';
[X_inv1 X_inv2] = meshgrid(X_inv(:,1),X_inv(:,2));
X = [X_inv1(:) X_inv2(:)];

if(display)
  handle_waitbar = waitbar(0,'Computing predicted variance');
  for(i = 1:1:size(X,1))
    [void varSigma(i,:)] = gpPosteriorMeanVar(model_out,X(i,:));
    waitbar(i/size(X,1));
  end
  close(handle_waitbar);
else
  [void varSigma] = gpPosteriorMeanVar(model.fz,X);
end
clear void;

varSigma = real(varSigma(:,1));
C = (reshape(sqrt(1./(2*pi.*varSigma)),N,N));

if(display)
  clf(figure(1));
  imagesc(X_inv(:,1),X_inv(:,2),C);
  colormap gray;hold on;axis off;
end

X = X_inv(:,1);
Y = X_inv(:,2);

return