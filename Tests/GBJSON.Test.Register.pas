unit GBJSON.Test.Register;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Deserialize.Pessoa,
  GBJSON.Test.Serialize.Pessoa;

procedure RegisterTestes;

implementation

procedure RegisterTestes;
begin
  TDUnitX.RegisterTestFixture(TGBJSONTestSerializePessoa);
  TDUnitX.RegisterTestFixture(TGBJSONTestDeserializePessoa);
end;

initialization
  RegisterTestes;

end.
