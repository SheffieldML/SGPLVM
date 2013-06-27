function model = sgplvmAddInverseMapping(model,model_id,dim_in,dim_out,type,name,nr_iters,varargin)

% SGPLVMADDINVERSEMAPPING
%
% COPYRIGHT : Carl Henrik Ek, 2008

% SGPLVM

X = model.comp{model_id}.y(:,dim_in);
y = model.X(:,dim_out);

% create model
switch type
 case 'kbr'
  
 case {'gp','gpard'}
  options = gpOptions('ftc');
  if(strcmp(type,'gpard'))
    options.kern = {'rbfard' 'bias' 'white'};
  end
  dim_out_id = false.*ones(1,model.q);
  dim_out_id(dim_out) = true;
  m = gpSubspaceCreate(size(X,2),size(y,2),X,y,options,dim_out_id);
  m = gpSubspaceOptimise(m,true,nr_iters);
end

% save model

model.comp{model_id} = setfield(model.comp{model_id},name,m);

return;
