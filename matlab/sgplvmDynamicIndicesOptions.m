function ind = sgplvmDynamicIndicesOptions(model,N,seq,type);

% SGPLVMDYNAMICINDICESOPTIONS 
% FORMAT
% DESC Returns a set of indices to be used as inducing indices for
% a GP-Dynamic model
% ARG model : sgplvm model
% ARG N : number of inducing points
% ARG seq : sequence
% ARG type : type of spacing of indices (default = linspace)
% RETURN ind : index vector
%
% SEEALSO : sgplvmCreate
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM

if(nargin<4)
  type = 'linspace';
  if(nargin<3)
    seq = [];
    if(nargin<2)
      N = model.k;
      if(nargin<1)
	error('To Few Arguments');
      end
    end
  end
end

validIndices = 1:1:(model.N-length(seq));
switch type
 case 'linspace'
  ind = round(linspace(1,length(validIndices),N));
 case 'rand'
  ind = randperm(length(validIndices));
  ind = validIndices(ind);
 otherwise
  error('Unkown Type');
end

return
