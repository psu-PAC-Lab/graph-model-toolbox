n= 100;

for i = 1:n

tic;
set_param('untitled1', 'FastRestart', 'on');
sim('untitled1');
elapsedTime(i) = toc;

end

DAEMOT_SimAvg = mean(elapsedTime);
DAEMOT_SimStd = std(elapsedTime);
message = ['Average DAEMOT Simulation Time (s): ' num2str(DAEMOT_SimAvg) ' Standard Deviation (s):' num2str(DAEMOT_SimStd)];
disp(message);

for i = 1:n

tic;
set_param('untitled', 'FastRestart', 'on');
sim('untitled');
elapsedTime2(i) = toc;

end

GMT_Simulink_SimAvg = mean(elapsedTime2);
GMT_Simulink_SimStd = std(elapsedTime2);
message1 = ['Average GMT V2 Simulink Simulation Time (s): ' num2str(GMT_Simulink_SimAvg) ' Standard Deviation (s):' num2str(GMT_Simulink_SimStd)];
disp(message1);

y0 = [1 1 1]';
tspan = [0 10];
options = odeset('Mass', Motor.MassMatrix, 'MassSingular', 'yes');

for i = 1:n
    tic; 
    [t, y] = ode15s(@(t,y) sysFun_Motor(t,y), tspan, y0, options);
    elapsedTime3(i) = toc;
end

GMT_CmdLine_SimAvg = mean(elapsedTime3);
GMT_CmdLine_SimStd = std(elapsedTime3);
message2 = ['Average GMT V2 CommandLine Simulation Time (s): ' num2str(GMT_CmdLine_SimAvg) ' Standard Deviation (s):' num2str(GMT_CmdLine_SimStd)];
disp(message2);