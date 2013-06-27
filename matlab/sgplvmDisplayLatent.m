function [C X Y] = sgplvmDisplayLatent(model,y,N,display,fid)

% SGPLVMDISPLAYLATENT
%
% COPYRIGHT : Carl Henrik Ek, 2008

% SGPLVM

if(nargin<5)
  fid = 1;
  if(nargin<4)
    display = false;
    if(nargin<3)
      N = 50;
      if(nargin<2)
	error('Too Few Arguments');
      end
    end
  end
end

if(model.q~=2)
  error('Only Valid for two dimensional latent spaces');
end

% get limits
dim_min = min(model.X.*1.1);
dim_max = max(model.X.*1.1);
X_inv = zeros(N,2);
for(i = 1:1:2)
  X_inv(:,i) = (linspace(dim_min(i),dim_max(i),N));
end
[X_inv1 X_inv2] = meshgrid(X_inv(:,1),X_inv(:,2));
X = [X_inv1(:) X_inv2(:)];
%if(display)
%  handle_waitbar = waitbar(0,'Computing Likelihood');
%end
ll = fgplvmPointLogLikelihood(model,X,repmat(y,size(X,1),1));

%for(i = 1:1:size(X,1))
%  ll(i) = fgplvmPointLogLikelihood(model,X(i,:),y);
%  if(display)
%    waitbar(i/size(X,1));
%  end
%end
%if(display)
%  close(handle_waitbar);
%end
C = reshape(ll,N,N);

if(display)
  figure(fid);
  imagesc(X_inv(:,1),X_inv(:,2),C);hold on;axis off;colormap jet;
end
  
X = X_inv(:,1);
Y = X_inv(:,2);

return;