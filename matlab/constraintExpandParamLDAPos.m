function model = constraintExpandParamLDAPos(model,X)

% CONSTRAINTEXPANDPARAMLDAPOS Expands a LDAPOS constraint model
% FORMAT
% DESC Returns expanded model
% ARG model : constraint model
% ARG X : Latent locations
% RETURN model : Returns expanded model
%
% SEEALSO : constraintExpandParam
%
% COPYRIGHT : Carl Henrik Ek, 2009

% DGPLVM

mean_X = mean( X(:,model.dim), 1);
model.numDim = size(model.dim,2);
S_w=zeros(model.numDim,model.numDim);
S_b=zeros(model.numDim,model.numDim);
W = zeros(model.numLabled,model.numLabled);
B = zeros(model.numLabled,model.numLabled);
Ox = [];

N_acum = 1;
N_s = [];
for i = 1:model.numClass;
  inx_i = model.indices{i};
  X_i = X(inx_i,model.dim);
  mean_Xi = mean(X_i,1);
  model.mean_Xi{i} = mean_Xi;
  N_i = length(inx_i);
  index = N_acum:N_acum+N_i-1;
  W(index,index) = eye(N_i) - (1./N_i)*ones(N_i,N_i);
  N_s = [N_s, N_i];
  G(index,i) = (1./N_i) * ones(N_i,1);
  Ox = [Ox,X_i'];
  N_acum = N_acum + N_i;
end
B_p = diag(N_s);
G = G - (1./model.numLabled)*ones(model.numLabled,model.numClass);
B = G*B_p*G';

S_w = (1./model.numLabled)*Ox*W*Ox';
S_b = (1./model.numLabled)*Ox*B*Ox';

if(isfield(model,'reg')&&~isempty(model.reg))
  S_b_r = S_b + model.reg*eye(model.numDim);
  S_b_inv = inv(S_b_r);
else
  S_b_inv = inv(S_b);
end
A = S_w;

model.A = A;
model.S_w = S_w;
model.S_b = S_b;
model.S_b_inv = S_b_inv;
model.mean_X = mean_X;
model.B = B;
model.W = W;
model.Ox = Ox;

return
