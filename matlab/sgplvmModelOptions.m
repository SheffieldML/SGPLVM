function options = sgplvmModelOptions(option_type,data,options)

% SGPLVMMODELOPTIONS Return default options for SGPLVM model.
% FORMAT
% DESC Returns the default options for a sgplvm model
% ARG option_type : option type string
% ARG data : observation
% ARG options : option structure as returned by gpOptions
% RETURN options : sgplvmOption structure
%
% SEEALSO : gpOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2007

% SGPLVM

% defaults
options.prescale = true;

  if(~isempty(str2num(option_type)))
    N = str2num(option_type);
    options.fixInducing = true;
    options.fixIndices = round(linspace(1,size(data,1),N));
    options.numActive = N;
  else
    switch option_type
     case 'fixInd_temporal5'
      % fix inducing variables, use 10% of the data points linearly spaces
      options.fixInducing = true;
      options.fixIndices = round(linspace(1,size(data,1),round(0.05*size(data,1))));
      options.numActive = round(0.05*size(data,1));
     case 'fixInd_temporal10'
      % fix inducing variables, use 10% of the data points linearly spaces
      options.fixInducing = true;
      options.fixIndices = round(linspace(1,size(data,1),round(0.1*size(data,1))));
      options.numActive = round(0.1*size(data,1));
     case 'fixInd_temporal20'
      options.fixInducing = true;
      options.fixIndices = round(linspace(1,size(data,1),round(0.2*size(data,1))));
      options.numActive = round(0.2*size(data,1));
     case 'fixInd_temporal30'
      options.fixInducing = true;
      options.fixIndices = round(linspace(1,size(data,1),round(0.3*size(data,1))));
      options.numActive = round(0.3*size(data,1));
     case 'fixInd_temporal35'
      options.fixInducing = true;
      options.fixIndices = round(linspace(1,size(data,1),round(0.35*size(data,1))));
      options.numActive = round(0.35*size(data,1));
     case 'fixInd_temporal40'
      options.fixInducing = true;
      options.fixIndices = round(linspace(1,size(data,1),round(0.4*size(data,1))));
      options.numActive = round(0.4*size(data,1));
     case 'freeIndAll'
      options.fixInducing = false;
      options.fixIndices = [];
      options.numActive = size(data,1);
     case 'freeInd10'
      options.fixInducing = false;
      options.fixIndices = [];
      options.numActive = round(0.1*size(data,1));
     case 'freeInd20'
      options.fixInducing = false;
      options.fixIndices = [];
      options.numActive = round(0.2*size(data,1));
     otherwise
      error('Unknown options model');
    end
  end
  