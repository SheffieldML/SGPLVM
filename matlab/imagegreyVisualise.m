function handle = imagegreyVisualise(pos,fid,imageSize)

% IMAGEGREYVISUALISE Callback function to visualise 2D image

% SGPLVM

if(nargin<2)
  fid = 2;
end

figure(fid);
colormap gray;

imageData = reshape(pos, imageSize(1), imageSize(2));
imageData = imageData./max(max(imageData));
handle = imagesc(imageData);

return;