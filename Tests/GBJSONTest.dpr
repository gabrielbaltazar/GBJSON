program GBJSONTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  TestInsight.DUnitX,
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
  GBJSON.Serializer in '..\Source\GBJSON.Serializer.pas',
  GBJSON.DataSet.Interfaces in '..\Source\GBJSON.DataSet.Interfaces.pas',
  GBJSON.DataSet.Serializer in '..\Source\GBJSON.DataSet.Serializer.pas',
  GBJSON.Test.DataSet.Serializer in 'GBJSON.Test.DataSet.Serializer.pas',
  GBJSON.Firedac.Interfaces in '..\Source\GBJSON.Firedac.Interfaces.pas',
  GBJSON.Firedac.Deserializer in '..\Source\GBJSON.Firedac.Deserializer.pas',
  GBJSON.Firedac.Deserializer.Test in 'GBJSON.Firedac.Deserializer.Test.pas',
  GBJSON.Firedac.Serializer in '..\Source\GBJSON.Firedac.Serializer.pas',
  GBJSON.Firedac.Serializer.Test in 'GBJSON.Firedac.Serializer.Test.pas',
  GBJSON.Firedac.Models.Classes in 'GBJSON.Firedac.Models.Classes.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  TestInsight.DUnitX.RunRegisteredTests;
end.
