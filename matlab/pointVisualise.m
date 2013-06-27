function handle = pointVisualise(pos,fid,X,dot_size)

% POINTVISUALISE
%
% COPYRIGHT : Carl Henrik Ek and Neil Lawrence, 2008

% NCCA

if(nargin<4)
  dot_size = 30;
  if(nargin<2)
    fid = 2;
    if(nargin<1)
      error('Too Few Arguments');
    end
  end
end

figure(fid);
if(size(pos,2)>=3)
  if(nargin>=3)
    scatter3(X(:,1),X(:,2),X(:,3),dot_size,'b','filled');
    hold on;
  end
  handle = scatter3(pos(:,1),pos(:,2),pos(:,3),dot_size,'r','filled');
end
if(size(pos,2)==2)
  if(nargin>=3)
    scatter(X(:,1),X(:,2),dot_size,'b','filled');
    hold on;
  end
  handle = scatter(pos(:,1),pos(:,2),dot_size,'r','filled');
end
if(size(pos,2)==1)
  if(nargin>=3)
    plot(X,'b.');
    hold on;
  end
  handle = plot(pos,'r.');
end

axis equal;


return
