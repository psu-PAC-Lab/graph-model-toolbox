Mc = blkdiag(MainTank.Properties.M,TankSplit.Properties.M,RecirTank.Properties.M,CoolerLoad.Properties.M,EngineSplit.Properties.M,HeatLoad.Properties.M);
sum(MainTank.Properties.Nv+TankSplit.Properties.Nv+RecirTank.Properties.Nv+CoolerLoad.Properties.Nv+EngineSplit.Properties.Nv+HeatLoad.Properties.Nv);


Prev_Ne = MainTank.Properties.Ne;
Prev_Nv = MainTank.Properties.Nv;
Cur_Nv = TankSplit.Properties.Nv;
Adj_Ne = MainTank.Ports(2).ElementNumber;
Mc(:,Prev_Ne+TankSplit.Ports(1).ElementNumber) = [];
Mc(Prev_Nv+1:Prev_Nv+Cur_Nv,Adj_Ne) = TankSplit.Properties.M(:,TankSplit.Ports(1).ElementNumber);

% SubSysA = gmt_Graph.gmt_CombineSimple(MainTank,TankSplit,[2, 1]);
% SubSysB = gmt_Graph.gmt_CombineSimple(SubSysA,RecirTank,[4, 2]);
% SubSysC = gmt_Graph.gmt_CombineSimple(SubSysB,CoolerLoad,[5, 2]);
% SubSysD = gmt_Graph.gmt_CombineSimple(SubSysC,EngineSplit,[6, 2]);
% SubSysE = gmt_Graph.gmt_CombineSimple(SubSysD,HeatLoad,[7, 2]);
% SysFin = gmt_Graph.gmt_CombineSys(SubSysE,[4, 8]);
