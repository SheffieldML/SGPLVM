function Trans = computeTransT(model,X,normalise,display)

% COMPUTETRANST Compute Transitional Probabilities for sequence of modes from ncca model
% FORMAT
% DESC Computes a Translation matrix for a sequence of mode from a
% ncca model
% ARG model : transition model
% ARG X : modes
% ARG normalise : should transition be normalised (default = true)
% ARG display : display progress (default = false)
% RETURN Trans : Transition log likelihood matrix
%
% SEEALSO : NULL
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2007

% NCCA

if(nargin<4)
  display = false;
  if(nargin<3)
    normalise = 1;
  end
end

if(display)
  handle_waitbar = waitbar(0,'Computing Transition Probabilities');
end
for(i = 1:1:size(X,1)-1)
  for(j = 1:1:size(X{i},1))
    [mu varSigma] = gpPosteriorMeanVar(model,X{i}(j,:));
    for(k = 1:1:size(X{i+1},1))
      diff = X{i+1}(k,:)-mu;
      if(normalise)
	Trans(j,k,i) = prod(1./sqrt(2*pi*varSigma).*exp(-1/2.*diff.*diff./varSigma));
      else
	ll = log(2*pi)+log(varSigma)+(diff.*diff)./varSigma;
	ll(find(isnan(ll))) = 0;
	ll = -0.5*sum(ll,2);
	Trans(j,k,i) = ll;
      end
    end
    if(normalise==1)
      part = sum(Trans(j,:,i));
      if(part~=0)
	Trans(j,:,i) = Trans(j,:,i)./part;
      end
    end
  end
  if(normalise==2)
    part = sum(sum(Trans(:,:,i)));
    if(part~=0)
      Trans(:,:,i) = Trans(:,:,i)./part;
    end
  end
  if(display)
    waitbar(i/(size(X,1)-1));
  end
end
if(display)
  close(handle_waitbar);
end

if(normalise)
  ind = find(Trans>0);
  Trans(ind) = log(Trans(ind));
end

return