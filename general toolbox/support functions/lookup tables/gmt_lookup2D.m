%% gmt_lookup2D
% Purpose: Computationaly efficient 2D lookup within axis limits 
% Input Arguments 
%   xD: x-axis data 
%   yD: y-axis data
%   xL: x-axis lookup value for interpolation 
%   yL: y-axis lookup value for interpolation 
% Ouput Arguments 
%   zL: z-axis interpolation from lookup
function [zL] = gmt_lookup2D(xD,yD,zD,xL,yL)

% perform binary search 
[XidxL, XidxU, XidxBias] = gmt_lookupAxis(xD,xL);
[YidxL, YidxU, YidxBias] = gmt_lookupAxis(yD,yL);

% perform interpolation
zL = (1 - XidxBias) * (1 - YidxBias) * zD(XidxL, YidxL) + ...
     XidxBias * (1 - YidxBias) * zD(XidxU, YidxL) + ...
     (1 - XidxBias) * YidxBias * zD(XidxL, YidxU) + ...
     XidxBias * YidxBias * zD(XidxU, YidxU);
end


