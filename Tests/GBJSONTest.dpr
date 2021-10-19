program GBJSONTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  TestInsight.DUnitX,
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

begin
  ReportMemoryLeaksOnShutdown := True;
  TestInsight.DUnitX.RunRegisteredTests;

end.
