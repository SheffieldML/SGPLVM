function w = computeSigmoidWeight(t,rate,shift)

% COMPUTESIGMOIDWEIGHT Compute weight decay function for fols model
% FORMAT
% DESC Returns current iterations weight
% ARG t : current iteration
% ARG rate : decay rate
% ARG shift : offset of sigmoid
% RETURN w : current weight
%
% SEEALSO : sgplvmWeightUpdate, sgplvmFOLSOptions
%
% COPYRIGHT : Neil D. Lawrence, Carl Henrik Ek, Mathieu Salzmann, 2009

% SGPLVM 

w = sigmoid((t-shift).*rate);

return