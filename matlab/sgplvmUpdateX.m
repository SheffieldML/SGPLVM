function model = sgplvmUpdateX(model,X);
% SGPLVMUPDATEX Optimise the SGPLVM.
% FORMAT
% DESC Takes a sgplvm model structure and optimises with respect to
% parameters and latent coordinates
% ARG model : sgplvm model
% ARG X : latent representation to update the model with
% RETURN model : the model with updated latent representation
%
% SEEALSO : 
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM


model.X = X;
for(i = 1:1:model.numModels)
      model.comp{1}.X = X;
end

return