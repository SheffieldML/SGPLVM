function [beta Xs Xp] = nccaExtract(Y,alpha,var_keep,verbose)

% check arguments
if(size(Y,1)==size(Y,2))
  if(verbose)
    fprintf('Y given in terms of Kernel Matrix\n');
  end
  K = Y;
  clear Y;
else
  if(verbose)
    fprintf('Y given in terms of points\n');
  end
  K = Y*Y';
end

K = kernelCenter(K);
K = K./sum(diag(K));
K = (K+K')./2;
S = K'*K;

N_consolidation = sum(diag(alpha'*S*alpha))/trace(S);
beta = [];
if(isinteger(var_keep))
  for(i = 1:1:var_keep)
    beta(:,i) = ncca_lin(S,[alpha beta],verbose);
  end
else
  i = 1;
  while(N_consolidation<var_keep)
    beta(:,i) = ncca_lin(S,[alpha beta],verbose);
    N_consolidation = sum(diag([alpha beta]'*S*[alpha beta]))/trace(S);
    i = i+1;
  end
end

if(nargout>1)
  Xs = K*alpha;
  Xp = K*beta;
end
  
return

function beta = ncca_lin(S,alpha,verbose)

if(nargin<3)
  verbose = false;
end

A = S - alpha*alpha'*S;
[D beta] = eigdec(A,1);

if(verbose)
  if(any(~isreal(D)))
    warning('NCCA: Complex Eigenvalues');
  end
  if(length(find(D<0))~=0)
    warning('NCCA: Negative Eigenvalues');
  end
end

return
