function model = sgplvmAddConstraint(model,param1);

% SGPLVMADDCONSTRAINT Add latent constraints to SGPLVM model
% FORMAT
% DESC Adds constraint structure to FGPLVM model
% ARG model : fgplvm model
% ARG options : options strucure as returnded from
% constraintOptions
% RETURN model : the SGP-LVM model.
%
% COPYRIGHT : Carl Henrik Ek, 2009
%
% SEEALSO : constraintOptions

% SGPLVM


if(isfield(model,'type')&&strcmp(model.type,'fgplvm'))
  m = param1;
  type = 'model';
else
  options = param1;
  type = 'options';
end
  

switch type
 case 'options'
  % create new constraints
  fhandle = str2func(['constraintCreate',options.type]);
  options.N = model.N;
  options.q = model.q;
  if(isfield(model,'constraints')&&~isempty(model.constraints))
    model.constraints.comp{model.constraints.numConstraints+1} = fhandle(options);
  else
    model.constraints.comp{1} = fhandle(options);
    model.constraints.numConstraints = 0;
    model.constraints.id = [];
  end  
  model.constraints.numConstraints = model.constraints.numConstraints + 1;
  model.constraints.id = [model.constraints.id; false*ones(1,model.q)];
  model.constraints.id(end,options.dim) = true;
  model.constraint_id = model.constraints.id;
 case 'model'
  % transfer constraints
  if(isfield(model,'constraints')&&~isempty(model.constraints))
    for(i = 1:1:m.constraints.numConstraints)
      model.constraints.comp{model.constraints.numConstraints+1} = m.constraints.comp{i};
      model.constraint_id = [model.constraint_id m.constraints.id]; 
      model.constraints.numConstraints = model.constraints.numConstraints + 1;
    end
  else
    for(i = 1:1:m.constraints.numConstraints)
      model.constraints.comp{i} = m.constraints.comp{i};
      model.constraint_id = false*one(1,model.q);
      model.constraint_id(i.m.constraints.dim) = true;
    end
    model.constraints.numConstraints = m.constraints.numConstraints;
  end
end

if(~isempty(model.constraints))
  model.constraint = true;
else
  model.constraint = false;
end

% update constraints
for(i = 1:1:model.constraints.numConstraints)
  model.constraints.comp{i} = constraintExpandParam(model.constraints.comp{i},model.X);
end

return
