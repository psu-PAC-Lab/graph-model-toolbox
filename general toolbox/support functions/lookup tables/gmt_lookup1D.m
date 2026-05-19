%% gmt_lookup1D
% Purpose: Computationaly efficient 1D lookup within axis limits 
% Input Arguments 
%   xD: x-axis data 
%   yD: y-axis data
%   xL: x-axis lookup value for interpolation 
% Ouput Arguments 
%   yL: y-axis interpolation from lookup
function [yL] = gmt_lookup1D(xD,yD,xL)

    % perform binary search 
    [idxL, idxU, idxBias] = gmt_lookupAxis(xD,xL);

    % perform interpolation
    yL = yD(idxL) + idxBias * (yD(idxU) - yD(idxL));

end
