function model = ncca2sgplvm(model_ncca,options)

% NCCA2SGPLVM Convert a NCCA model into a SGPLVM model
% Only creates Generative mappings
% Dynamical mappings and Back-Constraints are added afterwards.
% FORMAT
% DESC 	MODEL = NCCA2SGPLVM(MODEL_NCCA,OPTIONS)
% Converts a NCCA model into a SGPLVM model
% ARG model_ncca : ncca model
% ARG options : options structure as defined by fgplvmOptions.m
% RETURN model : model structure containing the Gaussian process.
%
% SEEALSO : nccaOptions, nccaCreate, modelCreate, fgplvmOptions, sgplvmCreate
% sgplvmSetLatentDimension
%
% COPYRIGHT : Neil D. Lawrence and Carl Henrik Ek, 2008

% SGPLVM

Y = model_ncca.fy.y;
Z = model_ncca.fz.y;

Xs = model_ncca.fy.X(:,1:1:model_ncca.ds);
Xy = model_ncca.fy.X(:,model_ncca.ds+1:1:end);
Xz = model_ncca.fz.X(:,model_ncca.ds+1:1:end);
latent_dim = model_ncca.ds+model_ncca.dy+model_ncca.dz;
X = [Xs Xy Xz];
      
% create model
if(nargin<2)
  options = fgplvmOptions('fitc');
  options.numActive = min([100 size(Y,1)]);
  options.fixInducing = true;
  options.fixIndices = round(linspace(1,size(Y,1),options.numActive));
  options.optimiser = 'scg';
  options.scale2var1 = false;
  options.initX = X;
end
  
model{1} = fgplvmCreate(latent_dim,size(Y,2),Y,options);
model{1} = sgplvmSetLatentDimension(model{1},'gen',1:1:size(Xs,2)+size(Xy,2),true);


model{2} = fgplvmCreate(latent_dim,size(Z,2),Z,options);
model{2} = sgplvmSetLatentDimension(model{2},'gen',[1:1:size(Xs,2) size(Xs,2)+size(Xy,2)+1:size(X,2)],true);

for(i = 1:1:size(model{1}.X,2))
  model{1}.X(:,i) = model{1}.X(:,i)./std(model{1}.X(:,i));
  model{2}.X(:,i) = model{2}.X(:,i)./std(model{2}.X(:,i));
end


options = sgplvmOptions;
options.save_intermediate = inf;
options.name = 'sgplvm_ncca';
options.initX = zeros(2,latent_dim);
options.initX(1,:) = true;
options.initX(2,:) = true;

model = sgplvmCreate(model,[],options);
model.back = false;

return