function [C,Ceq,G,Geq] = sgplvmConstraintsGradient(params, model)

% SGPLVMCONSTRAINTSGRADIENT SGPLVM constraints and gradient function for fmincon usage.
% FORMAT
% DESC : returns the constraints values and their gradients 
% ARG params : the parameters of the model for which the constraints
% and gradients will be evaluated
% ARG model : the sgplvm model
% RETURN C : inequality constraints
% RETURN Ceq : equality constraints
% RETURN G : gradient of the inequality constraints
% RETURN Geq : grandient of equality constraints
%
% SEEALSO : minimize, sgplvmGradient, sgplvmLogLikelihood,
% sgplvmOptimise
%
% COPYRIGHT : Mathieu Salzmann, Neil D. Lawrence, Carl Henrik Ek, 2009

% SGPLVM

% Check how the optimiser has given the parameters
if size(params, 1) > size(params, 2)
  % As a column vector ... transpose everything.
  transpose = true;
  model = sgplvmExpandParam(model, params');
else
  transpose = false;
  model = sgplvmExpandParam(model, params);
end

Ceq = zeros(length(model.qp),1);
Geq = zeros(length(model.qp),length(params));

%constant energy constraints for each dataset
for i=1:length(model.qp)
    inds = find(model.generative_id(i,:));
    [U,S,V] = svd(model.X(:,inds));
    dS = diag(S);
    Ceq(i) = model.sumS2(i) - sum(dS.*dS);
    ddE_dS = -2*S(1:length(inds),1:length(inds));
    gtmp = zeros(model.N,model.q);
    gtmp(:,inds) = U(:,1:length(inds))*ddE_dS*V';
    Geq(i,1:model.N*model.q) = reshape(gtmp,1,model.N*model.q);
end

%enforce singular values to be positive
%
% G = zeros(model.q,length(params));
%  
% [U,S,V] = svd(model.X);
% dS = diag(S);
% C = -dS;
% for j=1:length(dS)
%     G(j,1:model.q*model.N) = -reshape(U(:,j)*V(:,j)',1,model.q*model.N);
% end

C = [];
G = zeros(0,length(params));

if transpose
  Geq = Geq';
  G = G';
end
