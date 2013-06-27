function handle = pointModify(handle,pos,X)

% POINTMODIFY
%
% COPYRIGHT : Carl Henrik Ek and Neil Lawrence, 2008

% NCCA

if(nargin>=3)
  pos = [pos; X];
end

if(size(pos,2)>=3)
  set(handle,'XData',pos(:,1));
  set(handle,'YData',pos(:,2));
  set(handle,'ZData',pos(:,3));
end
if(size(pos,2)==2)
  set(handle,'XData',pos(:,1));
  set(handle,'YData',pos(:,2));
end
if(size(pos,1)==1)
  set(handle,'XData',pos(:,1));
end

return;