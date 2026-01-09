function [x1_dot,x2_dot] = Engine(x1,x2,u1)
x1_dot = -u1*x2;
x2_dot = (0.35*Qhv*u1)/J;
end
