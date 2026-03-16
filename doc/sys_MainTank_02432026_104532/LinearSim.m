clear X deltaX deltaU
NumSteps = 1000;

u1 = 0;
u2 = 1.5;

U = [0;1.5];

X(1,1) = eps;
X(2,1) =eps;
X(3,1) = 0;
X(4,1) = 0;
X(5,1) = 0;
X(6,1) = 0;
deltaX(1:6,1) = 0;
deltaU(1:2,1) = 0;

[A,B,Z] = MainTank.gmt_ControlModel("Simplify",true,"NumSub",true,"Discrete",eps);

Asym = matlabFunction(A);
Bsym = matlabFunction(B);
Zsym = matlabFunction(Z);

for i = 1:NumSteps
   
    Aterm(:,i) = Asym(X(1,i), X(2,i), X(3,i), X(4,i), X(5,i), X(6,i), U(1), U(2))*deltaX(:,i);
    Bterm(:,i) = Bsym(X(1,i), X(2,i), X(3,i), X(4,i), X(5,i), X(6,i), U(1), U(2))*deltaU(:,i);
    Zterm(:,i) = Zsym(X(1,i), X(2,i), X(3,i), X(4,i), X(5,i), X(6,i), U(1), U(2));

    X(:,i+1) = Aterm(:,i) + Bterm(:,i); %+ Zterm(:,i);

    deltaX(:,i+1) = X(:,i+1) - X(:,1);
    deltaU(:,i+1) = [0, 0];

    if X(:,i+1) <= eps
        break
    end

end

plot(X(2,:))