function [X ll] = nccaSortModes(model,X)

% NCCASORTMODES
%
% COPYRIGHT : Carl Henrik Ek and Neil Lawrence, 2008

% NCCA


if(nargin<2)
  error('Too Few Arguments');
end

if(iscell(X))
  for(i = 1:1:size(X,1))
    [X{i} ll{i}] = nccaSortModes(model,X{i});
  end
  return;
end

ll = zeros(size(X,1),1);
for(i = 1:1:size(X,1))
  [void varSigma] = gpPosteriorMeanVar(model,X(i,:));
  ll(i) = 1./sqrt(2*pi*varSigma(:,1));
end

[void ind] = sort(ll,'descend');
ll = ll(ind);
X = X(ind,:);

return;