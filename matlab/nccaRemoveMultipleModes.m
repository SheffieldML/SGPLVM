function X = nccaRemoveMultipleModes(model,X,ratio,type)

% NCCAREMOVEMULTIPLEMODES
%
%
% COPYRIGHT : Carl Henrik Ek, 2008

% NCCA

if(nargin<4)
  type = 'euclidian';
  if(nargin<3)
    ratio = 0.03;
    if(nargin<2)
      error('Too Few Arguments');
    end
  end
end

if(ratio==0)
  return;
end

if(iscell(X))
  for(i = 1:1:size(X,1))
    X{i} = nccaRemoveMultipleModes(model,X{i});
  end
  return
end

dim_private = find(var(X)~=0);

switch type
 case 'L1'
  % compute cut-off distance
  X_cutoff = abs(max(model.X(:,dim_private))-min(model.X(:,dim_private))).*ratio;
  
  multiplier = 1./X_cutoff;
  multiplier = repmat(multiplier,size(X,1),1);
  
  tmp = round(X(:,dim_private).*multiplier);
  [tmp i] = unique(tmp,'rows','first');
  X = X(i,:);
 case {'euclidian','L2'}
  d_max = norm(max(model.X(:,dim_private))-min(model.X(:,dim_private)),2)*ratio;
  tmp = [];
  k = 1;
  for(i = size(X,1):-1:2)
    d = dist_euclidean(X(i,:),X(1:i-1,:));
    ind = 1:1:i-1;
    if(isempty(find(d(ind)<d_max)))
      tmp(k,:) = X(i,:);
      k = k+1;
    end
  end
  X = [X(1,:); tmp(size(tmp,1):-1:1,:)];
end
  
return;