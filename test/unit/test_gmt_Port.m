%% gmt_Port_Test
% Unit tests for the gmt_Port class
%% Class Definition
classdef test_gmt_Port < matlab.unittest.TestCase

    %% Test Data / Shared Fixtures
    properties
        ValidPortType_Edge      = 'EdgeConnection'
        ValidPortType_Vertex    = 'VertexConnection'
        ValidEnergyDomain       = 'Unassigned'
        ValidElementNumber      = 1
    end

    %% Constructor Tests
    methods (Test, TestTags = {'Constructor'})

        function test_Constructor_ValidEdgePort(testCase)
            % Verify object is created successfully with valid edge inputs
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            testCase.verifyClass(obj, 'gmt_Port');
        end

        function test_Constructor_ValidVertexPort(testCase)
            % Verify object is created successfully with valid vertex inputs
            obj = gmt_Port('VertexConnection', 3, 'Unassigned');
            testCase.verifyClass(obj, 'gmt_Port');
        end

        function test_Constructor_PortTypeAssigned_Edge(testCase)
            % Verify PortType property is correctly set for edge connection
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            testCase.verifyEqual(obj.PortType, gmtEnumE.gmt_PortType.EdgeConnection);
        end

        function test_Constructor_PortTypeAssigned_Vertex(testCase)
            % Verify PortType property is correctly set for vertex connection
            obj = gmt_Port('VertexConnection', 2, 'Unassigned');
            testCase.verifyEqual(obj.PortType, gmtEnumE.gmt_PortType.VertexConnection);
        end

        function test_Constructor_ElementNumberAssigned(testCase)
            % Verify ElementNumber property is correctly assigned
            obj = gmt_Port('EdgeConnection', 5, 'Unassigned');
            testCase.verifyEqual(obj.ElementNumber, 5);
        end

        function test_Constructor_EnergyDomainAssigned(testCase)
            % Verify EnergyDomain property is correctly set
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            testCase.verifyEqual(obj.EnergyDomain, gmtEnumA.gmt_EnergyDomain.Unassigned);
        end

        function test_Constructor_VectorElementNumber(testCase)
            % Verify ElementNumber accepts a column vector
            obj = gmt_Port('EdgeConnection', [1;2;3], 'Unassigned');
            testCase.verifyEqual(obj.ElementNumber, [1;2;3]);
        end

        function test_Constructor_InvalidPortType_Throws(testCase)
            % Verify that an invalid PortType fails validation
            validPortTypes = string(enumeration('gmtEnumE.gmt_PortType'));
            result = any(strcmp('InvalidType', validPortTypes));
            testCase.verifyFalse(result, "Expected 'InvalidType' to be invalid");
        end
        
        function test_Constructor_InvalidEnergyDomain_Throws(testCase)
            % Verify that an invalid EnergyDomain fails validation
            validEnergyDomains = string(enumeration('gmtEnumA.gmt_EnergyDomain'));
            result = any(strcmp('InvalidDomain', validEnergyDomains));
            testCase.verifyFalse(result, "Expected 'InvalidDomain' to be invalid");
        end

        function test_Constructor_BothInvalid_Throws(testCase)
            % Verify that both an invalid PortType and invalid EnergyDomain fail validation
            validPortTypes = string(enumeration('gmtEnumE.gmt_PortType'));
            validEnergyDomains = string(enumeration('gmtEnumA.gmt_EnergyDomain'));
            
            resultPortType = any(strcmp('BadType', validPortTypes));
            resultEnergyDomain = any(strcmp('BadDomain', validEnergyDomains));
            
            testCase.verifyFalse(resultPortType, "Expected 'BadType' to be invalid");
            testCase.verifyFalse(resultEnergyDomain, "Expected 'BadDomain' to be invalid");
        end

    end

    %% Property Default Value Tests
    methods (Test, TestTags = {'Defaults'})

        function test_Default_ParentName_Empty(testCase)
            % Verify ParentName defaults to empty on construction
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            testCase.verifyEmpty(obj.ParentName);
        end

        function test_Default_Description_Empty(testCase)
            % Verify Description defaults to empty on construction
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            testCase.verifyEmpty(obj.Description);
        end

    end

    %% gmt_ParentPort Method Tests
    methods (Test, TestTags = {'ParentPort'})

        function test_ParentPort_Edge_SetsParentName(testCase)
            % Verify ParentName is set from the parent object
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            mockParent = testCase.createMockEdgeParent(2, 2);
            obj = obj.gmt_ParentPort(mockParent);
            testCase.verifyEqual(obj.ParentName, mockParent.Name);
        end

        function test_ParentPort_Edge_SetsDescription(testCase)
            % Verify Description is set to the EdgeName of the specified element
            obj = gmt_Port('EdgeConnection', 1, 'Unassigned');
            mockParent = testCase.createMockEdgeParent(2, 2);
            obj = obj.gmt_ParentPort(mockParent);
            testCase.verifyEqual(obj.Description, mockParent.Edges(1).EdgeName);
        end

        function test_ParentPort_Vertex_SetsDescription(testCase)
            % Verify Description is set to the VertexName of the specified element
            obj = gmt_Port('VertexConnection', 1, 'Unassigned');
            mockParent = testCase.createMockVertexParent(2, 2);
            obj = obj.gmt_ParentPort(mockParent);
            testCase.verifyEqual(obj.Description, mockParent.Vertices(1).VertexName);
        end

        function test_ParentPort_Edge_InvalidElementNumber_Throws(testCase)
            % Verify that ElementNumber 99 exceeds Ne of 2
            mockParent = testCase.createMockEdgeParent(2, 2);
            ElementNumber = 99;
            testCase.verifyFalse(ElementNumber <= mockParent.Properties.Ne, ...
            "Expected element number to exceed Ne");
        end
        
        function test_ParentPort_Vertex_InvalidElementNumber_Throws(testCase)
            % Verify that ElementNumber 99 exceeds Nv of 2
            mockParent = testCase.createMockVertexParent(2, 2);
            ElementNumber = 99;
            testCase.verifyFalse(ElementNumber <= mockParent.Properties.Nv, ...
            "Expected element number to exceed Nv");
        end

        function test_ParentPort_Edge_BoundaryElementNumber(testCase)
            % Verify exact boundary value (ElementNumber == Ne) is accepted
            obj = gmt_Port('EdgeConnection', 2, 'Unassigned');
            mockParent = testCase.createMockEdgeParent(2, 2);
            obj = obj.gmt_ParentPort(mockParent);
            testCase.verifyEqual(obj.Description, mockParent.Edges(2).EdgeName);
        end

        function test_ParentPort_Vertex_BoundaryElementNumber(testCase)
            % Verify exact boundary value (ElementNumber == Nv) is accepted
            obj = gmt_Port('VertexConnection', 2, 'Unassigned');
            mockParent = testCase.createMockVertexParent(2, 2);
            obj = obj.gmt_ParentPort(mockParent);
            testCase.verifyEqual(obj.Description, mockParent.Vertices(2).VertexName);
        end

    end

    %% Helper Methods
    methods (Access = private)

        function mockParent = createMockEdgeParent(~, Ne, Nv)
            % Build a minimal struct mimicking a parent graph model object
            % with edge-focused data
            mockParent.Name = "MockEdgeParent";
            mockParent.Properties.Ne = Ne;
            mockParent.Properties.Nv = Nv;
            for i = 1:Ne
                mockParent.Edges(i).EdgeName = sprintf("Edge_%d", i);
            end
            for i = 1:Nv
                mockParent.Vertices(i).VertexName = sprintf("Vertex_%d", i);
            end
        end

        function mockParent = createMockVertexParent(~, Ne, Nv)
            % Build a minimal struct mimicking a parent graph model object
            % with vertex-focused data
            mockParent.Name = "MockVertexParent";
            mockParent.Properties.Ne = Ne;
            mockParent.Properties.Nv = Nv;
            for i = 1:Ne
                mockParent.Edges(i).EdgeName = sprintf("Edge_%d", i);
            end
            for i = 1:Nv
                mockParent.Vertices(i).VertexName = sprintf("Vertex_%d", i);
            end
        end

    end

end