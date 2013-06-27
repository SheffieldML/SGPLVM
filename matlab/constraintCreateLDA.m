function model = constraintCreateLDA(options)

% CONSTRAINTCREATELDA Creates a LDA constraint model from a options struct
% FORMAT
% DESC Creates a LDA constraint model from a options struct
% ARG options : options structure as returned by constraintOptions
% RETURN model : the model created
%
% SEEALSO : constraintOptions
%
% COPYRIGHT : Carl Henrik Ek, 2009, 2010

% DGPLVM

model = {};
model.type = options.type;

if(isfield(options,'lambda')&&~isempty(options.lambda))
  model.lambda = options.lambda;
else
  model.lambda = 1.0;
end
if(isfield(options,'reg')&&~isempty(options.reg))
  model.reg = options.reg;
else
  model.reg = 1;
end

model.N = options.N;
model.q = options.q;
model.numClass = length(unique(options.class));
model.class = unique(options.class);
model.unknown = [];
model.numLabled = 0;
for(i = 1:1:model.numClass)
  model.indices{i} = find(options.class==model.class(i));
  model.class(i) = options.class(model.indices{i}(1));
  if(model.class(i)<0)
    model.unknown = [model.unknown model.indices{i}];
  else
    model.numLabled = model.numLabled + length(model.indices{i});
  end
end


if(isfield(options,'dim')&&~isempty(options.dim))
  model.dim = options.dim;
else
  warning('Active dimensions for constraint not set');
  model.dim = 1:1:options.q;
end
model.numDim = length(model.dim);

return