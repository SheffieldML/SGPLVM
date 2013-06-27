function Xc = nccaVisualise(model,Ylbls,visualiseFunction,visualiseModify,x,type,N,Y,display)

% NCCAVISUALISE
%
% COPYRIGHT : Carl Henrik Ek and Neil Lawrence, 2008
%

% NCCA


if(nargin<7)
  N = 20;
  if(nargin<6)
    error('Too Few Arguments');
  end
end

visFunc = str2func(visualiseFunction);
modFunc = str2func(visualiseModify);

switch type
 case 'Z'
  model_in = model.gz;
  model_out = model.fy;
 case 'Y'
  model_in = model.gy;
  model_out = model.fz;
 otherwise
  error('Unknown Type');
end

if(model_out.q-model_in.d>2)
  error('Only handles 1D and 2D');
end

if(~isempty(Ylbls))
  X = model_out.X(Ylbls,model.ds+1:1:end);
else
  X = [];
end

for(i = 1:1:size(x,1))
  if(display)
    fprintf('Frame:\t%d\n',i);
  end
  if(exist('Y','var'))
    figure(3);clf;
    if(strcmp(visualiseFunction(end),'2'))
      figure(4);clf;
      figure(5);clf;
    end
    visFunc(Y(i,:),3);
  end
  figure(2);clf;
  xs = modelOut(model_in,x(i,:));
  figure(1);clf;
  nccaDisplayPrivate(model,x(i,:),type,N,false,true,1);
  figure(1);hold on;
  if(model_out.q-model_in.d==2)
    if(~isempty(X))
      scatter(X(:,1),X(:,2),30,'r','filled');
    end
  end
  button = 1;
  k = false;
  if(exist('handle','var'))
    clear handle;
  end
  k = 1;
  while(button~=3)
    figure(1);
    [x1 x2 button] = ginput(1);
    if(button==1)
      if(model_out.q-model_in.d==2)
	x_z = [xs x1 x2];
      else
	x_z = [xs x1];
      end
      if(nargout>0)
	Xc(k,:) = x_z(size(xs,2)+1:1:end)
	k = k+1;
      end
      scatter(x1,x2,30,'g','filled');
      y = modelOut(model_out,x_z);
      if(~exist('handle','var'))
	handle = visFunc(y,2);title('Output');
	k = true;
      else
	handle = modFunc(handle,y);
      end
    end
  end
end
