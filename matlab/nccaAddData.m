function ind = nccaAddData(model,Y,ratio)

% NCCAADDDATA

% NCCA

if(size(Y,2)==size(model.fy.y,2))
  input_type = 'Y';
elseif(size(Y,2)==size(model.fz.y,2))
  input_type = 'Z';
end
if(isempty(input_type))
  error('Could not determine observation association');
end

switch input_type
 case 'Y'
  model_var = model.gy;
 case 'Z'
  model_var = model.gz;
end

[mu varSigma] = gpPosteriorMeanVar(model_var,Y);
clear mu;
varSigma = varSigma(:,1);
[void ind] = sort(varSigma,'descend');
clear void;clear varSigma;
if(isinteger(ratio))
  ind = ind(1:1:ratio);
else
  ind = ind(1:1:floor(size(Y,1)*ratio/100));
end

return