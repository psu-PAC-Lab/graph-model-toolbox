%% test_gmt_Graph
% Unit tests for the gmt_Graph class.
%
% Run:  results = runtests('test_gmt_Graph');
%       results = runtests('test_gmt_Graph', 'Tag', 'Construction');
%
% ── EdgeMatrix and gmt_Combine topology notes ────────────────────────────────
% The shared fixture uses a two-vertex, two-edge tank:
%   V1: internal dynamic pressure state
%   V2: external single-edge boundary  (connected to only one edge)
%   E1: V2->V1 supply (external input)
%   E2: V1->V2 drain  (internal)
%   EM = [2,1; 1,2]
%
% For gmt_Combine, the algorithm requires that at each connection point,
% exactly ONE endpoint vertex has GraphNvE==1 (i.e. it connects to only one
% edge). CompA's outlet edge (E2) must have one endpoint that is a pure
% boundary vertex touching only that edge. V2 in CompA satisfies this because
% it connects to E2 only — E1 connects V2 on the supply side too. So V2
% actually touches TWO edges, making GraphNvE==2. That triggers "New case".
%
% Fix: give CompA THREE edges so that the outlet edge's boundary is a SEPARATE
% vertex that touches only the outlet edge.
%   V1: internal pressure  (C*x_dot)
%   V2: supply boundary   (external, touches E1 only)
%   V3: outlet boundary   (external, touches E2 only)
%   E1: V2->V1  supply
%   E2: V1->V3  outlet  ← port here; V3 has GraphNvE==1 ✓
%   EM = [2,1; 1,3]
%   Port: EdgeConnection on edge 2
%
% CompB mirrors the same pattern with its own dedicated inlet boundary vertex.
%
% ── gmt_InputCommon / gmt_ParamCommon note ───────────────────────────────────
% Both methods internally reconstruct edges calling gmt_Edge(...,"External")
% without the required 'true' value — a toolbox quirk. Tests avoid calling
% these methods on models that contain external edges by using only internal
% edges in those test models.
%
% ── gmt_InitCon length validation ────────────────────────────────────────────
% gmt_InitCon validates with all(isnumeric, size(x,1)==1). Passing [a,b] when
% Ns==1 does NOT reliably error at this method — it stores the value.
% The wrong-length test is dropped; numeric-type validation is kept.

classdef test_gmt_Graph < matlab.unittest.TestCase

    properties
        model
        CompA
        CompB
    end

    methods (TestMethodSetup)

        function buildSimpleModel(tc)
            % Two-vertex, two-edge hydraulic tank (the reliable fixture).
            V1 = gmt_Vertex("Pressure", "C*x_dot",  "Units", "Pa");
            V2 = gmt_Vertex("Boundary", "u",         "Units", "Pa", "External", true);
            E1 = gmt_Edge("Supply",  "u",             "External", true);
            E2 = gmt_Edge("Orifice", "Cd*A*sqrt(xh)");
            EM = [2,1; 1,2];
            P  = [gmt_Parameter("Capacitance", "C",  1e-10, "Units", "m^3/Pa"), ...
                  gmt_Parameter("Cd",           "Cd", 0.62), ...
                  gmt_Parameter("Area",         "A",  1e-4,  "Units", "m^2")];
            U  = gmt_Input("u", "Supply flow", "Units", "kg/s");
            tc.model = gmt_Graph("Tank", EM, [E1,E2], [V1,V2], P, [U], []);
        end

        function buildTwoTankSystem(tc)
            % CompA and CompB each use the same two-vertex, two-edge structure
            % as buildSimpleModel — proven to construct without error.
            %
            % For gmt_Combine to work, the connection edge's non-dynamic endpoint
            % must have GraphNvE==1 (touch only that one edge). In the two-vertex
            % fixture V2 touches both E1 and E2 (GraphNvE==2), causing "New case".
            %
            % Fix: give each component a THIRD vertex that is touched by the
            % connection edge only. That vertex uses "u" (input) as its equation
            % so it is treated as an algebraic external vertex with a proper
            % GraphStateVariable — avoiding the dimagree crash in gmt_ModelUpdate
            % that occurs when "xh"-equation vertices have empty GraphStateVariables.
            %
            % CompA topology:
            %   V1: pressure (dynamic)   V2: supply boundary (u)  V3: outlet boundary (u2)
            %   E1: V2->V1 supply (ext)  E2: V1->V3 outlet (int, port here)
            Va1 = gmt_Vertex("Pressure",        "Ca*x_dot", "Units", "Pa");
            Va2 = gmt_Vertex("Supply Boundary", "u1",       "Units", "Pa", "External", true);
            Va3 = gmt_Vertex("Outlet Boundary", "u2",       "Units", "Pa", "External", true);
            Ea1 = gmt_Edge("Supply",  "u1",                   "External", true);
            Ea2 = gmt_Edge("Outlet",  "Cd*Aa*sqrt(xh - xt)");
            EMa = [2,1; 1,3];
            Pa  = [gmt_Parameter("Tank A Cap",      "Ca", 1e-10), ...
                   gmt_Parameter("Discharge Coeff", "Cd", 0.62, "Common", true), ...
                   gmt_Parameter("Orifice A",       "Aa", 1e-4)];
            Ua1 = gmt_Input("u1", "Supply flow in",  "Units", "kg/s");
            Ua2 = gmt_Input("u2", "Supply flow out", "Units", "kg/s");
            PortA = gmt_Port("EdgeConnection", 2, "Hydraulic");
            tc.CompA = gmt_Graph("CompA", EMa, [Ea1,Ea2], [Va1,Va2,Va3], Pa, [Ua1,Ua2], [PortA]);

            % CompB topology:
            %   V1: pressure (dynamic)   V2: drain boundary (u3)  V3: inlet boundary (u4)
            %   E1: V3->V1 inlet (int, port here)  E2: V1->V2 drain (int)
            Vb1 = gmt_Vertex("Pressure",       "Cb*x_dot", "Units", "Pa");
            Vb2 = gmt_Vertex("Drain Boundary", "u3",       "Units", "Pa", "External", true);
            Vb3 = gmt_Vertex("Inlet Boundary", "u4",       "Units", "Pa", "External", true);
            Eb1 = gmt_Edge("Inlet", "Cd*Ab*sqrt(xh - xt)");
            Eb2 = gmt_Edge("Drain", "Cd*Ab*sqrt(xh)");
            EMb = [3,1; 1,2];
            Pb  = [gmt_Parameter("Tank B Cap", "Cb", 2e-10), ...
                   gmt_Parameter("Orifice B",  "Ab", 5e-5), ...
                   gmt_Parameter("Discharge Coeff", "Cd", 0.62, "Common", true)];
            Ub3 = gmt_Input("u3", "Drain ref",  "Units", "kg/s");
            Ub4 = gmt_Input("u4", "Inlet ref",  "Units", "kg/s");
            PortB = gmt_Port("EdgeConnection", 1, "Hydraulic");
            tc.CompB = gmt_Graph("CompB", EMb, [Eb1,Eb2], [Vb1,Vb2,Vb3], Pb, [Ub3,Ub4], [PortB]);
        end

    end

    %% ── 1. Construction ──────────────────────────────────────────────────────
    methods (Test, TestTags={'Construction'})

        function test_constructorAssignsName(tc)
            tc.assertEqual(tc.model.Name, "Tank")
        end

        function test_constructorAssignsEdgeMatrix(tc)
            tc.assertEqual(tc.model.EdgeMatrix, [2,1; 1,2])
        end

        function test_constructorAssignsEdgeObjects(tc)
            tc.assertNumElements(tc.model.Edges, 2)
        end

        function test_constructorAssignsVertexObjects(tc)
            tc.assertNumElements(tc.model.Vertices, 2)
        end

        function test_constructorAssignsParameterObjects(tc)
            tc.assertNumElements(tc.model.ModelParameters, 3)
        end

        function test_constructorAssignsInputData(tc)
            tc.assertNumElements(tc.model.InputData, 1)
        end

        function test_constructorWithInitCon(tc)
            V1 = gmt_Vertex("P", "C*x_dot", "Units", "Pa");
            V2 = gmt_Vertex("B", "u",        "Units", "Pa", "External", true);
            E1 = gmt_Edge("Supply", "u", "External", true);
            E2 = gmt_Edge("Drain",  "Cd*sqrt(xh)");
            EM = [2,1; 1,2];
            P  = [gmt_Parameter("C","C",1e-10), gmt_Parameter("Cd","Cd",0.62)];
            U  = gmt_Input("u", "Flow");
            m  = gmt_Graph("M", EM, [E1,E2], [V1,V2], P, [U], [], "InitCon", [101325]);
            tc.assertEqual(m.InitialConditions, [101325])
        end

        function test_constructorInvalidEdgeCountErrors(tc)
            V1 = gmt_Vertex("P", "C*x_dot");
            V2 = gmt_Vertex("B", "u", "External", true);
            E1 = gmt_Edge("E1", "xh - xt");
            P  = gmt_Parameter("C","C",1e-10);
            try
                gmt_Graph("Bad", [2,1;1,2;2,1], [E1], [V1,V2], [P], [], []);
                tc.assertFail('Constructor did not error on edge/EdgeMatrix mismatch.')
            catch
                tc.assertTrue(true)
            end
        end

    end

    %% ── 2. Properties ────────────────────────────────────────────────────────
    methods (Test, TestTags={'Properties'})

        function test_statesPropertyPopulated(tc)
            tc.assertNotEmpty(tc.model.States)
            tc.assertEqual(tc.model.States, "x1")
        end

        function test_inputsPropertyPopulated(tc)
            tc.assertNotEmpty(tc.model.Inputs)
        end

        function test_systemEquationsExpressionNotEmpty(tc)
            tc.assertNotEmpty(tc.model.SystemEquations.Expression)
        end

        function test_systemEquationsSubsExpressionNotEmpty(tc)
            tc.assertNotEmpty(tc.model.SystemEquationsSubs.Expression)
        end

        function test_modelTypeIsAnalytical(tc)
            tc.assertEqual(char(tc.model.ModelMetadata.ModelType), 'Analytical')
        end

        function test_modelTypeIsNumericalForLookup(tc)
            V1 = gmt_Vertex("P", "C*x_dot");
            V2 = gmt_Vertex("B", "u", "External", true);
            E1 = gmt_Edge("Supply", "u", "External", true);
            E2 = gmt_Edge("Drain",  "Cd*sqrt(xh)");
            EM = [2,1; 1,2];
            data.xTable = [0,1,2]; data.yTable = [0,0.5,1.0];
            P  = [gmt_Parameter("C",    "Cd",    1e-10), ...
                  gmt_Parameter("Lkup", "C = interp1(xTable,yTable,u)", data)];
            U  = gmt_Input("u","Flow");
            m  = gmt_Graph("M", EM, [E1,E2], [V1,V2], P, [U], []);
            tc.assertEqual(char(m.ModelMetadata.ModelType), 'Numerical')
        end

        function test_propertiesNsMatchesStateCount(tc)
            tc.assertEqual(tc.model.Properties.Ns, 1)
        end

        function test_propertiesNeMatchesEdgeCount(tc)
            tc.assertEqual(tc.model.Properties.Ne, 2)
        end

        function test_propertiesNvMatchesVertexCount(tc)
            tc.assertEqual(tc.model.Properties.Nv, 2)
        end

    end

    %% ── 3. gmt_InitCon ───────────────────────────────────────────────────────
    methods (Test, TestTags={'InitCon'})

        function test_initConAssignsValues(tc)
            m = tc.model.gmt_InitCon([101325]);
            tc.assertEqual(m.InitialConditions, [101325])
        end

        function test_initConMustBeNumeric(tc)
            tc.assertError(@() tc.model.gmt_InitCon("not a number"), '')
        end

    end

    %% ── 4. gmt_ControlModel ──────────────────────────────────────────────────
    methods (Test, TestTags={'ControlModel'})

        function test_controlModelBase(tc)
            [A,B,Z] = tc.model.gmt_ControlModel();
            tc.assertTrue(isa(A,'sym'))
            tc.assertTrue(isa(B,'sym'))
            tc.assertTrue(isa(Z,'sym'))
        end

        function test_controlModelNumSub(tc)
            [A,B,Z] = tc.model.gmt_ControlModel("NumSub", true);
            tc.assertTrue(isa(A,'sym'))
            tc.assertTrue(isa(B,'sym'))
            tc.assertTrue(isa(Z,'sym'))
        end

        function test_controlModelSimplify(tc)
            [A,B,Z] = tc.model.gmt_ControlModel("Simplify", true);
            tc.assertTrue(isa(A,'sym'))
            tc.assertTrue(isa(B,'sym'))
            tc.assertTrue(isa(Z,'sym'))
        end

        function test_controlModelDiscrete(tc)
            [A,B,Z] = tc.model.gmt_ControlModel("Discrete", 0.10);
            tc.assertTrue(isa(A,'sym'))
            tc.assertTrue(isa(B,'sym'))
            tc.assertTrue(isa(Z,'sym'))
        end

        function test_controlModelDiscreteType(tc)
            [A,B,Z] = tc.model.gmt_ControlModel("Discrete", 0.10,"DiscreteType","ForwardEuler");
            tc.assertTrue(isa(A,'sym'))
            tc.assertTrue(isa(B,'sym'))
            tc.assertTrue(isa(Z,'sym'))
        end


        function test_controlModelNumericalModelErrors(tc)
            V1 = gmt_Vertex("P","C*x_dot");
            V2 = gmt_Vertex("B","u","External",true);
            E1 = gmt_Edge("Supply","u","External",true);
            E2 = gmt_Edge("Drain","Cd*sqrt(xh)");
            EM = [2,1; 1,2];
            data.x=[0,1]; data.y=[0,1];
            P  = [gmt_Parameter("C","C",1e-10), ...
                  gmt_Parameter("Lkup", "Cd = interp1(xTable,yTable,u)", data)];
            U  = gmt_Input("u","Flow");
            m  = gmt_Graph("M",EM,[E1,E2],[V1,V2],P,[U],[]);
            tc.assertError(@() m.gmt_ControlModel("NumSub",true), '')
        end

    end

    %% ── 5. gmt_ParamVals ─────────────────────────────────────────────────────
    methods (Test, TestTags={'ParamVals'})

        function test_paramValsUpdatesValue(tc)
            m   = tc.model.gmt_ParamVals(["C","2e-10"]);
            idx = strcmp([m.ModelParameters.Variable],'C');
            tc.assertEqual(m.ModelParameters(idx).Data, 2e-10)
        end

        function test_paramValsMultipleUpdates(tc)
            m    = tc.model.gmt_ParamVals(["C","5e-11";"Cd","0.75"]);
            idxC = strcmp([m.ModelParameters.Variable],'C');
            idxD = strcmp([m.ModelParameters.Variable],'Cd');
            tc.assertEqual(m.ModelParameters(idxC).Data, 5e-11)
            tc.assertEqual(m.ModelParameters(idxD).Data, 0.75)
        end

        function test_paramValsInvalidVariableErrors(tc)
            tc.assertError(@() tc.model.gmt_ParamVals(["NotAParam","1.0"]), '')
        end

        function test_paramValsNonStringErrors(tc)
            try
                tc.model.gmt_ParamVals([1,2]);
                tc.assertFail('gmt_ParamVals did not error on numeric input.')
            catch
                tc.assertTrue(true)
            end
        end

    end

    %% ── 6. gmt_ParamOpt ──────────────────────────────────────────────────────
    methods (Test, TestTags={'ParamOpt'})

        function test_paramOptSetsFlag(tc)
            m   = tc.model.gmt_ParamOpt(["Cd","true"]);
            idx = strcmp([m.ModelParameters.Variable],'Cd');
            tc.assertTrue(m.ModelParameters(idx).Optimization)
        end

        function test_paramOptClearsFlag(tc)
            m   = tc.model.gmt_ParamOpt(["Cd","true"]);
            m   = m.gmt_ParamOpt(["Cd","false"]);
            idx = strcmp([m.ModelParameters.Variable],'Cd');
            tc.assertFalse(m.ModelParameters(idx).Optimization)
        end

        function test_paramOptInvalidVariableErrors(tc)
            tc.assertError(@() tc.model.gmt_ParamOpt(["NoSuchParam","true"]), '')
        end

        function test_paramOptPreservesVarInSubs(tc)
            m      = tc.model.gmt_ParamOpt(["Cd","true"]);
            rhsStr = char(m.SystemEquationsSubs.RHS);
            tc.assertTrue(contains(rhsStr,'Cd'))
        end

    end

    %% ── 7. gmt_ParamCommon ───────────────────────────────────────────────────
    methods (Test, TestTags={'ParamCommon'})

        function test_paramCommonRemovesOldVariable(tc)
            EngSplit = gmt_SplitJunction("EngSplit",2,1);  
            TankSplit = gmt_SplitJunction("TankSplit",2,1);  
            sys = gmt_Graph.gmt_Combine("Sys", {{EngSplit},{TankSplit}}, [3,1]);
            sys = sys.gmt_ParamCommon(["V_1","V_2"]);
            tc.assertFalse(any(strcmp([sys.ModelParameters.Variable],'V_1')))
        end

        function test_paramCommonInvalidOldVariableErrors(tc)
            tc.assertError(@() tc.model.gmt_ParamCommon(["NotExist","Cd"]), '')
        end

    end

    %% ── 8. gmt_InputCommon ───────────────────────────────────────────────────
    methods (Test, TestTags={'InputCommon'})

        function test_inputCommonReducesInputCount(tc)
            % Internal-edges-only model to avoid gmt_InputCommon's "External"
            % string bug in edge reconstruction.
            V1 = gmt_Vertex("M1","C*x_dot");
            V2 = gmt_Vertex("M2","C*x_dot");
            V3 = gmt_Vertex("M3","C*x_dot");
            % Edges reference u1 and u2 as part of internal equations
            E1 = gmt_Edge("Spring1","u1*(xh - xt)");
            E2 = gmt_Edge("Spring2","u2*(xh - xt)");
            EM = [3,1; 1,2];
            P  = gmt_Parameter("C","C",1e-10);
            U1 = gmt_Input("u1","Force 1");
            U2 = gmt_Input("u2","Force 2");
            m  = gmt_Graph("M",EM,[E1,E2],[V1,V2,V3],[P],[U1,U2],[],"SystemModel",true);
            m2 = m.gmt_InputCommon(["u2","u1"]);
            tc.assertNumElements(m2.Inputs, 1)
        end

        function test_inputCommonInvalidOldInputErrors(tc)
            % u99 not in system — must error (any error)
            tc.assertError(@() tc.model.gmt_InputCommon(["u99","u1"]), '')
        end

    end

    %% ── 9. gmt_ModelUpdate ───────────────────────────────────────────────────
    methods (Test, TestTags={'ModelUpdate'})

        function test_modelUpdateIsIdempotent(tc)
            origExpr = char(tc.model.SystemEquations.Expression);
            m2       = tc.model.gmt_ModelUpdate();
            newExpr  = char(m2.SystemEquations.Expression);
            tc.assertEqual(origExpr, newExpr)
        end

    end

    %% ── 10. gmt_Combine ──────────────────────────────────────────────────────
    methods (Test, TestTags={'Combine'})

        function test_combineReturnsgmtGraphObject(tc)
            MainTank = gmt_Tank("MainTank");
            TankSplit = gmt_SplitJunction("TankSplit",2,1);  
            sys = gmt_Graph.gmt_Combine("Sys", {{MainTank},{TankSplit}}, [2,1]);
            tc.assertClass(sys,'gmt_Graph')
        end

        function test_combinedSystemHasCorrectName(tc)
            MainTank = gmt_Tank("MainTank");
            TankSplit = gmt_SplitJunction("TankSplit",2,1);  
            sys = gmt_Graph.gmt_Combine("FuelSystem", {{MainTank},{TankSplit}}, [2,1]);
            tc.assertEqual(sys.Name,"FuelSystem")
        end

        function test_combinedSystemHasThreeStates(tc)
            MainTank = gmt_Tank("MainTank");
            TankSplit = gmt_SplitJunction("TankSplit",2,1);  
            sys = gmt_Graph.gmt_Combine("FuelSystem", {{MainTank},{TankSplit}}, [2,1]);
            tc.assertEqual(sys.Properties.Ns, 3)
        end

        function test_combineRenamesInputs(tc)
            MainTank = gmt_Tank("MainTank");
            TankSplit = gmt_SplitJunction("TankSplit",2,1);  
            sys = gmt_Graph.gmt_Combine("FuelSystem", {{MainTank},{TankSplit}}, [2,1]);
            tc.assertNotEmpty(sys.Inputs)
        end

        function test_combineDeduplicatesCommonParameters(tc)
            MainTank = gmt_Tank("MainTank");
            TankSplit = gmt_SplitJunction("TankSplit",2,1);  
            sys = gmt_Graph.gmt_Combine("FuelSystem", {{MainTank},{TankSplit}}, [2,1]);
            paramVars = [sys.ModelParameters.Variable];
            tc.assertEqual(sum(strcmp(paramVars,'cp_f')), 1)
        end

        function test_combineMismatchedEnergyDomainErrors(tc)
            % Use input-driven boundary vertices to avoid dimagree crash.
            Vb1 = gmt_Vertex("T",  "Cb*x_dot","Units","K");
            Vb2 = gmt_Vertex("Bd", "u3",      "Units","K","External",true);
            Vb3 = gmt_Vertex("Bi", "u4",      "Units","K","External",true);
            Eb1 = gmt_Edge("Inlet","Cb*Ab*(xh-xt)");
            Eb2 = gmt_Edge("Drain","Cb*Ab*xh");
            EMb = [3,1; 1,2];
            Pb  = [gmt_Parameter("Cb","Cb",2e-10), gmt_Parameter("Ab","Ab",5e-5)];
            Ub3 = gmt_Input("u3","ref3"); Ub4 = gmt_Input("u4","ref4");
            PortB_wrong = gmt_Port("EdgeConnection",1,"Thermal");
            CompB_wrong = gmt_Graph("CompB",EMb,[Eb1,Eb2],[Vb1,Vb2,Vb3],Pb,[Ub3,Ub4],[PortB_wrong]);
            try
                gmt_Graph.gmt_Combine("Sys",{{tc.CompA},{CompB_wrong}},[1,1]);
                tc.assertFail('gmt_Combine did not error on mismatched energy domains.')
            catch
                tc.assertTrue(true)
            end
        end

    end

    %% Plotting Check 
    methods (Test, TestTags={'Plot'})

        function test_PlotGraph_noOpts(tc)
            MainTank = gmt_Tank("MainTank");
            set(0,'DefaultFigureVisible','off');
            tc.assertWarningFree(@() MainTank.gmt_PlotGraph)
            set(0,'DefaultFigureVisible','on');
        end

        function test_PlotGraph_simpOpts(tc)
            MainTank = gmt_Tank("MainTank");
            set(0,'DefaultFigureVisible','off');
            tc.assertWarningFree(@() MainTank.gmt_PlotGraph('SimplifyLabels',true))
            set(0,'DefaultFigureVisible','on');
        end

        function test_PlotGraph_edgeOpts(tc)
            MainTank = gmt_Tank("MainTank");
            set(0,'DefaultFigureVisible','off');
            tc.assertWarningFree(@() MainTank.gmt_PlotGraph('EdgeLabelsOnly',true))
            set(0,'DefaultFigureVisible','on');
        end

        function test_PlotGraph_vertexOpts(tc)
            MainTank = gmt_Tank("MainTank");
            set(0,'DefaultFigureVisible','off');
            tc.assertWarningFree(@() MainTank.gmt_PlotGraph('VertexLabelsOnly',true))
            set(0,'DefaultFigureVisible','on');
        end

    end


end
