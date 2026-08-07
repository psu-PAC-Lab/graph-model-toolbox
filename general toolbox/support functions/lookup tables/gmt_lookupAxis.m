%% gmt_lookupAxis
% Purpose: Computationaly efficient 2D lookup within axis limits 
% Input Arguments 
%   xD: x-axis data 
%   xL: x-axis lookup value for interpolation 
% Ouput Arguments 
%   idxL: lookup lower limit index
%   idxU: lookup upper limit index
%   idxBias: lookup interpolation bias to lower index 
function [idxL, idxU, idxBias] = gmt_lookupAxis(xD,xL)
    % clip to upper limit 
    if xL > xD(length(xD))
        idxU = length(xD);
        idxL = idxU - 1;
        idxBias = 1;
        warning('gmt_lookupAxis:upperlimit','Lookup value outside upper axis limit')
    % clip to lower limit
    elseif xL < xD(1)
        idxL = 1;
        idxU = 2; 
        idxBias = 0;
        warning('gmt_lookupAxis:lowerlimit','Lookup value outside lower axis limit')
    % compute upper and lower index 
    else
        idxU = 1;
        idxL = length(xD);
        
        while idxU <= idxL
        
            idxMid = idxL + floor((idxU - idxL)/2);
            deltaXd = xD(idxMid) - xL;
    
            if  deltaXd < 0
                % lookup value above idxMid
                idxU = idxMid + 1;
            elseif deltaXd > 0 
                % lookup value below idxMid
                idxL = idxMid - 1;
            else
                % lookup value matches idxMid
                idxU = idxMid + 1;
                idxL = idxMid;
                break;
            end
        end    
        idxBias = (xL - xD(idxL))/(xD(idxU) - xD(idxL));
    end
end
