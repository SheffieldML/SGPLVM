function model = sgplvmAddBackMapping(model,model_id,dim,type,nr_iters,varargin)

% SGPLVMADDBACKMAPPING
%
% COPYRIGHT : Carl Henrik Ek, 2008

% SGPLVM

model.back = true;
model.back_id(model_id,dim) = true;

% select data
X = model.comp{model_id}.y;
y = model.X(:,dim);

switch type
 case 'kbr'
  
 case {'gp','gpard'}
  options = gpOptions('ftc');
  
  if(strcmp(type,'gpard'))
    options.kern = {'rbfard' 'bias' 'white'};
  end
  model.comp{model_id}.back = gpSubspaceCreate(size(X,2),size(y,2),X,y,options,model.back_id(1,:));
  model.comp{model_id}.back = gpSubspaceOptimise(model.comp{model_id}.back,true,nr_iters);
  model = sgplvmSetLatentDimension(model,'back',dim,true);
 otherwise
  error('Unkown Type');
end

