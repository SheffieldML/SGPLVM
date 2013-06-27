function model = constraintCreate(model,void,options,varargin)

% CONSTRAINTCREATE Creates a constraint model from a options struct
% FORMAT
% DESC Creates a constraint model from a options struct
% ARG model : fgplvm or sgplvm model
% ARG void : empty for compatibility reasons
% ARG options : options structure as returned by constraintOptions
% RETURN model : the model created
%
% SEEALSO : constraintOptions
%
% COPYRIGHT : Carl Henrik Ek, 2009, 2010

% DGPLVM

options.q = model.q;
options.N = model.N;

fhandle = str2func(['constraintCreate' options.type]);
if(isfield(model.constraints,'numConstraints')&&model.constraints.numConstraints>0)
  model.constraints.comp{model.constraints.numConstraints+1} = fhandle(options,varargin{:});
else
  model.constraints.comp{1} = fhandle(options,varargin{:});
end

return
