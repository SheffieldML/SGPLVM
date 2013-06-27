function [C Xout Yout latent_axis] = sgplvmVisualise(model,Ylbls,visualiseFunction,visualiseModify,Y,type,N,Z,display,fid,verbose,varargin)

% SGPLVMVISUALISE Display sgplvm model
% FORMAT
% DESC Displays a sgplvm model
% ARG model : sgplvm model
% ARG Ylbls : index to training data to plot
% ARG visualiseFunction : output visualisation function
% ARG visualiseModify : visualisation modify function
% ARG Y : observations
% ARG type : visualisation type
% ARG N : number of sample points
% ARG Z : optional corresponding observation
% ARG display : display latent space
% ARG fid : figure index
% ARG verbose :
% RETURN C : sample points
% RETURN Xout : Latent Locations
% RETURN Yout : Output space locations
% RETURN latent_axis : latent axis
%
% SEEALSO : 
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

if(nargin<11)
  verbose = false;
  if(nargin<10)
    fid = 1;
    if(nargin<9)
      display = false;
      if(nargin<8)
	Z = [];
	if(nargin<7)
	  N = 20;
	  if(nargin<6)
	    error('Too Few Arguments');
	  end
	end
      end
    end
  end
end
    
visFunc = str2func(visualiseFunction);
modFunc = str2func(visualiseModify);

if(length(type)>5&&strcmp(type(1:4),'ncca'))
  index_in = str2num(type(5));
  index_out = str2num(type(6));
  type = 'ncca';
elseif(length(type)>6&&strcmp(type(1:5),'point'))
  index_in = str2num(type(6));
  index_out = str2num(type(7));
  type = 'point';
elseif(length(type)>9&&strcmp(type(1:8),'transfer'))
  index_in = str2num(type(9));
  index_out = str2num(type(10));
  type = 'transfer';
end

switch type
 case 'ncca'

  for(i = 1:1:size(Y,1))
    if(verbose)
      fprintf('Point:\t%d\n',i);
    end
    
    if(exist('handle_gt','var'))
      figure(fid_latent+2);clf;
      clear handle_gt;
    end
    if(exist('handle_vis','var'))
      figure(fid_latent+1);clf;
    end
    if(exist('fid_latent','var'))
      figure(fid_latent);clf
    end
    %1. Display Private 
    [C Xa Ya XZ fid_latent] = sgplvmDisplayPrivate(model,Y(i,:),['ncca' num2str(index_in) num2str(index_out)],N,1,1,1);
    latent_axis{i}.x = Xa;
    latent_axis{i}.y = Ya;
    dim_orthogonal = find(isnan(XZ));
    %4. Display Ground Truth
    if(~isempty(Z)&&size(Z,1)>=i)
      handle_gt = visFunc(Z(i,:),fid_latent+1,varargin{:});title('Ground Truth');
    end
    %2. Map points
    button = 1;
    if(exist('handle_vis','var'))
      clear handle_vis;
    end
    Xout{i} = [];
    Yout{i} = [];
    while(button~=3)
      figure(fid_latent);
      [x1 x2 button] = ginput(1);
      if(button==1)
	if(length(dim_orthogonal)==2)
	  XZ(dim_orthogonal) = [x1 x2];
	else
	  XZ(dim_orthogonal) = x1;
	end
	[z varSigma] = gpPosteriorMeanVar(model.comp{index_out},XZ);
	if(verbose)
	  fprintf('Log-Likelihood:\t%e\n',log(prod(sqrt(1./(2*pi*varSigma)))));
	end
	Xout{i} = [Xout{i};
		   XZ];
	Yout{i} = [Yout{i};
		   z];
	%3. Display Mapped point
	if(~exist('handle_vis','var'))
	  handle_vis = visFunc(z,fid_latent+2,varargin{:});title('Output');
	else
	  handle_vis = modFunc(handle_vis,z,varargin{:});title('Output');
	end
      end
    end
  end
    
 case {'point','transfer'}
  fid_latent = 1;
  for(i = 1:1:size(Y,1))
    if(verbose)
      fprintf('Point:\t%d\n',i);
    end
    
    if(exist('handle_gt','var'))
      figure(fid_latent+2);clf;
      clear handle_gt;
    end
    if(exist('handle_vis','var'))
      figure(fid_latent+1);clf;
    end
    if(exist('fid_latent','var'))
      figure(fid_latent);clf
    end
    %1. Sample Likelihood 
    [C Xa Ya] = sgplvmDisplayLatent(model.comp{index_in},Y(i,:),N,false,[]);
    figure(fid_latent);imagesc(Xa,Ya,C);
    latent_axis{i}.x = Xa;
    latent_axis{i}.y = Ya;
    %4. Display Ground Truth
    if(~isempty(Z)&&size(Z,1)>=i)
      handle_gt = visFunc(Z(i,:),fid_latent+2);title('Ground Truth');
    end
    %2. Map points
    button = 1;
    if(exist('handle_vis','var'))
      clear handle_vis;
    end
    Xout{i} = [];
    Yout{i} = [];
    while(button~=3)
      figure(fid_latent);
      [x1 x2 button] = ginput(1);
      XZ = [x1 x2];
      if(button==1)
	z = gpPosteriorMeanVar(model.comp{index_out},XZ);
	Xout{i} = [Xout{i};
		   XZ];
	Yout{i} = [Yout{i};
		   z];
	%3. Display Mapped point
	if(~exist('handle_vis','var'))
	  handle_vis = visFunc(z,fid_latent+1);title('Output');
	else
	  handle_vis = modFunc(handle_vis,z);
	end
      end
    end
    
  end
 otherwise
  error('Unkown Visualisation Type');
end

if(length(C)==1)
  C = cell2mat(C);
end

return;