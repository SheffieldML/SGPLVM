function [C X Y fhandle]= nccaDisplayPrivate(model,x,type,N,display,display2,fid)

% NCCADISPLAYPRIVATE
%
% COPYRIGHT : Carl Henrik Ek, 2008

% NCCA

if(nargin<7)
  fid = 1;
  if(nargin<6)
    display2 = true;
    if(nargin<5)
      display = false;
      if(nargin<4)
	N = 50;
	if(nargin<3)
	  if(size(x,2)==size(model.fy.y,2))
	    type = 'Y';
	  elseif(size(x,2)==size(model.fz.y,2))
	    type = 'Z';
	  end
	  if(nargin<2)
	    error('Too Few Arguments');
	  end
	end
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

mu = gpPosteriorMeanVar(model_in,x);
dim_inv = setdiff(1:1:model_out.q,1:1:model_in.d);
if(length(dim_inv)>2)
  error('Invariant space has higher dimensionality than 2');
end
inv_min = min(model_out.X(:,dim_inv).*1.1);
inv_max = max(model_out.X(:,dim_inv).*1.1);
X_inv = zeros(length(dim_inv),N);
for(i = 1:1:length(inv_min))
  X_inv(i,:) = (linspace(inv_min(i),inv_max(i),N))';
end
X_inv = X_inv';
if(size(X_inv,2)==2)
  [X_inv1 X_inv2] = meshgrid(X_inv(:,1),X_inv(:,2));
  X = [X_inv1(:) X_inv2(:)];
else
  X = X_inv;
end

X = [repmat(mu,size(X,1),1) X];
%if(display)
%  handle_waitbar = waitbar(0,'Computing predicted variance');
%  for(i = 1:1:size(X,1))
%    [void varSigma(i,:)] = gpPosteriorMeanVar(model_out,X(i,:));
%    waitbar(i/size(X,1));
%  end
%  close(handle_waitbar);
%else
  [void varSigma] = gpPosteriorMeanVar(model_out,X);
%end
clear void;

varSigma = real(varSigma(:,1));
if(size(X_inv,2)==2)
  C = (reshape(sqrt(1./(2*pi.*varSigma)),N,N));
else
  C = sqrt(1./(2*pi.*varSigma));
end
C = exp(real((C)));

if(display2)
  fhandle = figure(fid);
  clf(fhandle);
  if(size(X_inv,2)==2)
    imagesc(X_inv(:,1),X_inv(:,2),C);
    colormap jet;
    hold on;
    axis on;
  else
    plot(X_inv(:,1),C);
  end
end

X = X_inv(:,1);
if(size(X_inv,2)==2)
  Y = X_inv(:,2);
else
  Y = [];
end

return;