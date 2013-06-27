function handle = imagegreyModify(handle,imageValues,imageSize)

% IMAGEGREYMODIFY Callback function to visualise 2D image

% SGPLVM


set(handle, 'CData', reshape(imageValues, imageSize(1),imageSize(2)));

return