unit GBJSON.Test.Register;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Deserialize.Person,
  GBJSON.Test.Serialize.Person;

procedure RegisterTestes;

implementation

procedure RegisterTestes;
begin
  TDUnitX.RegisterTestFixture(TGBJSONTestDeserializePerson);
  TDUnitX.RegisterTestFixture(TGBJSONTestSerializePerson);
end;

initialization
  RegisterTestes;

end.
