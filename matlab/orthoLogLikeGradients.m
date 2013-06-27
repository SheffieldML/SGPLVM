function g = orthoLogLikeGradients(model)

% ORTHOLOGLIKEGRADIENTS Compute the FOLS orthogonality constraint gradients for the SGPLVM.
% FORMAT
% DESC Returns the gradients of the log likelihood with respect to
% the latent locations of the model
% ARG model : sgplvm model
% RETURN g : the gradients of the latent positions
%
% SEEALSO : sgplvmLogLikelihood, sgplvmCreate,
% modelLogLikeGradients
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM


g = zeros(1,model.N*model.q);
if(isfield(model,'fols')&&~isempty(model.fols)&&isfield(model.fols.ortho,'weight')&&(model.fols.ortho.weight>0))
  nd = length(model.fols.qp);
  qsi = model.fols.qs;
  start = model.fols.qs;
  for(i = 1:1:nd)
    Xy = model.X(:,find(model.generative_id(i,:)));
    start2 = start+model.fols.qp(i);
    for(j = i+1:1:nd)
      Xz = model.X(:,find(model.generative_id(j,:)));
      dp = (Xy(:,qsi+1:end)'*Xz(:,qsi+1:end));%./(model.N*model.N);
      g(start*model.N+1:(start+model.fols.qp(i))*model.N) = g(start* ...
                                                        model.N+1:(start+model.fols.qp(i))*model.N) - model.fols.ortho.weight*(2.0)*reshape(Xz(:,qsi+1:end)*dp',1,model.N*model.fols.qp(i));
      g(start2*model.N+1:(start2+model.fols.qp(j))*model.N) = ...
          g(start2*model.N+1:(start2+model.fols.qp(j))*model.N) - model.fols.ortho.weight*(2.0)*reshape(Xy(:,qsi+1:end)*dp,1,model.N*model.fols.qp(j));
      start2 = start2+model.fols.qp(j);
    end
    start = start+model.fols.qp(i);
  end
  dp = (model.X(:,1:model.fols.qs)'*model.X(:,model.fols.qs+1:end));%./(model.N*model.N);
  g(1:model.fols.qs*model.N) = g(1:model.fols.qs*model.N) - model.fols.ortho.weight*(2.0)*reshape(model.X(:,model.fols.qs+1:end)*dp',1,model.N*model.fols.qs);
  g(model.fols.qs*model.N+1:end) = g(model.fols.qs*model.N+1:end) - model.fols.ortho.weight*(2.0)*reshape(model.X(:,1:model.fols.qs)*dp,1,model.N*sum(model.fols.qp));
end