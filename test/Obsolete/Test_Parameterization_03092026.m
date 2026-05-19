Parameters(1) = gmt_Parameter("Rotational Inertia","J",10);
Parameters(2) = gmt_Parameter("DC Motor Specific Heat","Cp",15);
Parameters(3) = gmt_Parameter("Motor Inductance","L",20);
Parameters(4) = gmt_Parameter("Friction Coefficient b","b",30);
Parameters(5) = gmt_Parameter("Friction Coefficient b","c",40);
Parameters(6) = gmt_Parameter("Motor Armature Resistance","Ra",50);
Parameters(7) = gmt_Parameter("Motor Torque Constant","Kt",60);
Parameters(8) = gmt_Parameter("Thermal Convection Resistance","Ru",70);

Motor = gmt_DCMotor("Motor","ModelParameters",Parameters);

Motor.ModelParameters.Data

Motor.gmt_ReportParameter

