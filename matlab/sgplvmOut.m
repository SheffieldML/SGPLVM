function [mu varSigma] = sgplvmOut(model,Y,index_in,index_out,type,varargin)

% SGPLVMOUT 
%
% COPYRIGHT : Carl Henrik Ek, 2008

% SGPLVM

% Check Arguments
if(~strcmp(model.type,'sgplvm'))
  error('Wrong Model Type');
end
if(index_in == index_out)
  warning('Same model used as input and output')
end
if(index_in<1||index_in>model.numModels)
  error('Index to input model invalid');
end
if(index_out<1||index_out>model.numModels)
  error('Index to output model invalid');
end
if(size(Y,2)~=model.comp{index_in}.d)
  error('X dimensionality does not match model');
end

if(length(varargin)<5)
  for(i = 1:1:size(Y,1))
    X{i} = sgplvmPointOut(model,index_in,index_out,Y(i,:),type,varargin{:});
  end
else
  X = sgplvmSequenceOut(model,Y,index_in,index_out,type,varargin{:});
end

if(~iscell(X))
  if(nargout>1)
    [mu varSigma] = gpPosteriorMeanVar(model.comp{index_out},X);
  else
    mu = gpPosteriorMeanVar(model.comp{index_out},X);
  end
else
  if(nargout>1)
    for(i = 1:1:length(X))
      [mu{i} varSigma{i}] = gpPosteriorMeanVar(model.comp{index_out},X{i});
    end
  else
    for(i = 1:1:length(X))
      mu{i} = gpPosteriorMeanVar(model.comp{index_out},X{i});
    end
  end
end

return;

