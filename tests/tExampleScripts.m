classdef tExampleScripts < matlab.unittest.TestCase
    %TEXAMPLESCRIPTS Test that the example scripts run without errors.

    properties ( TestParameter )
        % List of scripts that should run without errors.
        Script = {"S01_DataProcessing", "S02_TrendDecomposition", ...
            "S03_NonParametricVolatility", "S04_ModelBasedVolatility"}
    end % properties ( TestParameter )

    methods ( TestClassSetup )

        function filterTestOnCI( testCase )

            ci = getenv( "GITHUB_ACTIONS" ) == "true";
            testCase.assumeFalse( ci, ...
                "This test only runs locally, not in CI systems." )

        end % filterTestOnCI

    end % methods ( TestClassSetup )

    methods ( Test )

        function tScriptRunsWithoutErrors( testCase, Script )

            try
                run( Script )
                success = true;
            catch
                success = false;
            end % try/catch

            testCase.verifyTrue( success, ...
                "The " + Script + " script did not run " + ...
                "without errors." )

        end % tScriptRunsWithoutErrors

    end % methods ( Test )

end % classdef