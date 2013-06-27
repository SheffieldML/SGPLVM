function [C X Y X_nonorthogonal fhandle] = sgplvmDisplayPrivate(model,x,type,N,display,fid,verbose)

% SGPLVMDISPLAYPRIVATE Display orthogonal subspace of sgplvm model
% FORMAT
% DESC Displays the output variance over observation orthogonal
% latent subspace
% ARG x : latent location
% ARG type : type of display
% ARG N : number of sample points per dimension
% ARG display : display space
% ARG fid : figure id
% ARG verbose :
% RETURN C : sample variance
% RETURN X : locations along X-axis
% RETURN Y : locations along Y-axis
% RETURN X_nonorthogonal : non-orthogonal location
% RETURN fhandle : figure handle
%
% SEEALSO : sgplvmVisualise
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, 2008

% SGPLVM

if(nargin<7)
  verbose = false;
  if(nargin<6)
    fid = 1;
    if(nargin<5)
      display = false;
      if(nargin<4)
	N = 20;
	if(nargin<3)
	  type = 'ncca12';
	  if(nargin<2)
	    error('Too Few Arguments');
	  end
	end
      end
    end
  end
end

if(size(x,1)>1)
  x = x(1,:);
  if(verbose)
    fprintf('sgplvmDisplayPrivate:\tMultiple input points, using first\n');
  end
end

if(strcmp(type(1:4),'ncca'))
  index_in = str2num(type(5));
  index_out = str2num(type(6));
  type = 'ncca';
end

switch type
 case 'ncca'
  dim_in = find(model.generative_id(index_in,:));
  dim_out = find(model.generative_id(index_out,:));
  
  dim_orthogonal = setdiff(dim_out,dim_in);
  dim_nonorthogonal = setdiff(1:1:model.q,dim_orthogonal);
  if(length(dim_orthogonal)>2)
    error('NCCA visualisation only handles one or two dimensions');
  end
  
  % Determine Sample Points
  inv_min = min(model.comp{index_out}.X(:,dim_orthogonal)).*1.1;
  inv_max = max(model.comp{index_out}.X(:,dim_orthogonal)).*1.1;
  X_inv = zeros(length(dim_orthogonal),N);
  for(i = 1:1:length(dim_orthogonal))
    X_inv(i,:) = (linspace(inv_min(i),inv_max(i),N))';
  end
  X_inv = X_inv';
  if(size(X_inv,2)==2)
    X = X_inv(1,:);
    Y = X_inv(2,:);
    [X_inv1 X_inv2] = meshgrid(X_inv(:,1),X_inv(:,2));
    X_inv = [X_inv1(:) X_inv2(:)];
  else
    X = X_inv(1,:);
    Y = [];
    X_inv1 = X_inv;
    X_inv2 = [];
  end
  
  % Determine non-orthogonal dimensions
  X_nonorthogonal = sgplvmPointOut(model,index_in,index_out,x,'NN',1,0,verbose);
  Xsamp = zeros(size(X_inv,1),model.q);
  Xsamp(:,dim_nonorthogonal) = repmat(X_nonorthogonal(dim_nonorthogonal),size(X_inv,1),1);
  Xsamp(:,dim_orthogonal) = X_inv;
  X_nonorthogonal(dim_orthogonal) = NaN;
  
  % compute output variance
  [void varSigma] = gpPosteriorMeanVar(model.comp{index_out},Xsamp);
  clear void;
  varSigma = real(varSigma(:,1));
  if(length(dim_orthogonal)==2)
    C = reshape(sqrt(1./(2*pi*varSigma)),N,N);
  else
    C= sqrt(1./(2*pi*varSigma));
  end
  
  X = X_inv1(1,:);
  if(length(dim_orthogonal)==2)
    Y = X_inv2(:,1);
  else
    Y = [];
  end
  if(display)
    % display output variance
    fhandle = figure(fid);
    clf(fhandle);
    if(length(dim_orthogonal)==2)
      imagesc(X,Y,C);
      colormap jet;
      hold on;
      axis on;
    else
      plot(X_inv,C);
    end
  else
    fhandle = [];
  end
  
 case 'transfer'
  
 otherwise
  error('Unkown Visualisation Type');
end

return;