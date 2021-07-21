program GBJSONTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  GBJSON.Test.Register in 'GBJSON.Test.Register.pas',
  GBJSON.Test.Models in 'GBJSON.Test.Models.pas',
  GBJSON.Test.Deserialize.Person in 'GBJSON.Test.Deserialize.Person.pas',
  GBJSON.Test.Serialize.Person in 'GBJSON.Test.Serialize.Person.pas',
  GBJSON.Attributes in '..\Source\GBJSON.Attributes.pas',
  GBJSON.Base in '..\Source\GBJSON.Base.pas',
  GBJSON.Config in '..\Source\GBJSON.Config.pas',
  GBJSON.DateTime.Helper in '..\Source\GBJSON.DateTime.Helper.pas',
  GBJSON.Deserializer in '..\Source\GBJSON.Deserializer.pas',
  GBJSON.Helper in '..\Source\GBJSON.Helper.pas',
  GBJSON.Interfaces in '..\Source\GBJSON.Interfaces.pas',
  GBJSON.RTTI in '..\Source\GBJSON.RTTI.pas',
  GBJSON.Serializer in '..\Source\GBJSON.Serializer.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
  ReportMemoryLeaksOnShutdown := True;
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    IsConsole := False;
    ReportMemoryLeaksOnShutdown := True;
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
