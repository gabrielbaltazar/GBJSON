unit GBJSON.Test.Deserialize.Person;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.Interfaces,
  GBJSON.Deserializer,
  GBJSON.Serializer,
  GBJSON.Helper,
  GBJSON.Config,
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils;

type
  [TestFixture]
  TGBJSONTestDeserializePerson = class
  private
    FPerson: TPerson;
    FUpperPerson: TUpperPerson;
    FDeserialize: IGBJSONDeserializer<TPerson>;
    FJSONObject: TJSONObject;

    function GetJsonObject(APerson: TPerson): TJSONObject;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('Normal', 'Test')]
    [TestCase('WithAccent', 'Tomé')]
    [TestCase('WithBar', 'Value 1 / Value 2')]
    [TestCase('WithBackslash', 'Value 1 \ Value 2')]
    [TestCase('WithDoubleQuotes', 'Name With "Quotes"')]
    procedure StringValue(AValue: string);

    [Test]
    procedure StringEmpty;

    [Test]
    [TestCase('Positive', '5')]
    [TestCase('Negative', '-5')]
    procedure IntegerValue(AValue: Integer);

    [Test]
    procedure IntegerEmpty;

    [Test]
    [TestCase('Positive', '5')]
    [TestCase('Negative', '-5')]
    [TestCase('PositiveWithDecimal', '5.3')]
    [TestCase('NegativeWithDecimal', '-5.3')]
    procedure DoubleValue(AValue: Double);

    [Test]
    procedure DoubleZero;

    [Test]
    procedure DateValue;

    [Test]
    procedure DateTimeValue;

    [Test]
    procedure DateEmpty;

    [Test]
    procedure BoolFalse;

    [Test]
    procedure BoolTrue;

    [Test]
    procedure EnumString;

    [Test]
    procedure ObjectValue;

    [Test]
    procedure ObjectNull;

    [Test]
    procedure ObjectLowerCase;

    [Test]
    procedure ObjectUpperCase;

    [Test]
    procedure ObjectUnderlineProperty;

    [Test]
    procedure ObjectListFill;

    [Test]
    procedure ObjectListEmpty;

    [Test]
    procedure ObjectListOneElement;

    [Test]
    procedure ObjectListNull;

    [Test]
    procedure ListFill;

    [Test]
    procedure ListEmpty;

    [Test]
    procedure ListOneElement;

    [Test]
    procedure ListNull;

    [Test]
    procedure ArrayStringFill;

    [Test]
    procedure ArrayStringEmpty;

    [Test]
    procedure ArrayStringOneElement;

    [Test]
    procedure JSONNameAttribute;
  end;

implementation

{ TGBJSONTestDeserializePerson }

procedure TGBJSONTestDeserializePerson.DateEmpty;
begin
  FPerson.CreationDate := 0;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('CreationDate'));
end;

procedure TGBJSONTestDeserializePerson.DateTimeValue;
var
  LData: TDateTime;
begin
  LData := EncodeDateTime(2024, 10, 3, 8, 36, 24, 0);
  FPerson.CreationDate := LData;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(LData, FJSONObject.GetValue<TDateTime>('CreationDate', 0));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(LData, FJSONObject.GetValue<TDateTime>('creationDate', 0));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(LData, FJSONObject.GetValue<TDateTime>('CREATIONDATE', 0));
end;

procedure TGBJSONTestDeserializePerson.DateValue;
begin
  FPerson.CreationDate := EncodeDate(2024, 10, 3);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 3), FJSONObject.GetValue<TDateTime>('CreationDate', 0));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FPerson.CreationDate := EncodeDate(2024, 10, 3);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 3), FJSONObject.GetValue<TDateTime>('creationDate', 0));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FPerson.CreationDate := EncodeDate(2024, 10, 3);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 3), FJSONObject.GetValue<TDateTime>('CREATIONDATE', 0));
end;

procedure TGBJSONTestDeserializePerson.DoubleValue(AValue: Double);
begin
  FPerson.Average := AValue;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(AValue, FJSONObject.ValueAsFloat('Average'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FPerson.Average := AValue;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(AValue, FJSONObject.ValueAsFloat('average'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FPerson.Average := AValue;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(AValue, FJSONObject.ValueAsFloat('AVERAGE'));
end;

function TGBJSONTestDeserializePerson.GetJsonObject(APerson: TPerson): TJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := FDeserialize.ObjectToJsonObject(APerson);
  Result := FJSONObject;
end;

procedure TGBJSONTestDeserializePerson.IntegerValue(AValue: Integer);
begin
  FPerson.Age := AValue;
  TGBJSONConfig.GetInstance.CaseDefinition(cdNone);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(AValue, FJSONObject.GetValue<Integer>('Age'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(AValue, FJSONObject.GetValue<Integer>('age'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(AValue, FJSONObject.GetValue<Integer>('AGE'));
end;

procedure TGBJSONTestDeserializePerson.JSONNameAttribute;
begin
  FPerson.Obs := 'Test';
  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Obs'));
  Assert.AreEqual('Test', FJSONObject.GetValue<string>('Observacao'));
end;

procedure TGBJSONTestDeserializePerson.Setup;
begin
  FDeserialize := TGBJSONDeserializer<TPerson>.New(False);
  FPerson := TPerson.CreatePerson;
  FUpperPerson := TUpperPerson.CreatePerson;
  FJSONObject := GetJsonObject(FPerson);
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
end;

procedure TGBJSONTestDeserializePerson.StringValue(AValue: string);
begin
  FPerson.Name := AValue;

  TGBJSONConfig.GetInstance.CaseDefinition(cdNone);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(AValue, FJSONObject.GetValue<string>('Name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(AValue, FJSONObject.GetValue<string>('name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(AValue, FJSONObject.GetValue<string>('NAME'));
end;

procedure TGBJSONTestDeserializePerson.TearDown;
begin
  FreeAndNil(FJSONObject);
  FreeAndNil(FPerson);
  FreeAndNil(FUpperPerson);
end;

procedure TGBJSONTestDeserializePerson.ArrayStringEmpty;
begin
  FPerson.Qualities := [];
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Qualities'));
end;

procedure TGBJSONTestDeserializePerson.ArrayStringFill;
begin
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(2, FJSONObject.GetValue<TJSONArray>('Qualities').Count);
  Assert.AreEqual('q1', FJSONObject.GetValue<TJSONArray>('Qualities').Items[0].Value);
  Assert.AreEqual('q2', FJSONObject.GetValue<TJSONArray>('Qualities').Items[1].Value);
end;

procedure TGBJSONTestDeserializePerson.ArrayStringOneElement;
begin
  FPerson.Qualities := ['q1'];
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(1, FJSONObject.GetValue<TJSONArray>('Qualities').Count);
  Assert.AreEqual('q1', FJSONObject.GetValue<TJSONArray>('Qualities').Items[0].Value);
end;

procedure TGBJSONTestDeserializePerson.BoolFalse;
begin
  FPerson.Active := False;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsFalse(FJSONObject.GetValue<Boolean>('Active', True));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsFalse(FJSONObject.GetValue<Boolean>('active', True));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsFalse(FJSONObject.GetValue<Boolean>('ACTIVE', True));
end;

procedure TGBJSONTestDeserializePerson.BoolTrue;
begin
  FPerson.Active := True;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsTrue(FJSONObject.GetValue<Boolean>('Active', False));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsTrue(FJSONObject.GetValue<Boolean>('active', False));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsTrue(FJSONObject.GetValue<Boolean>('ACTIVE', False));
end;

procedure TGBJSONTestDeserializePerson.EnumString;
begin
  FPerson.PersonType := tpJuridica;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('tpJuridica', FJSONObject.GetValue<string>('PersonType'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('tpJuridica', FJSONObject.GetValue<string>('personType'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('tpJuridica', FJSONObject.GetValue<string>('PERSONTYPE'));
end;

procedure TGBJSONTestDeserializePerson.DoubleZero;
begin
  FPerson.Average := 0;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Average'));
end;

procedure TGBJSONTestDeserializePerson.ListEmpty;
begin
  FPerson.Notes.Clear;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Notes'));
end;

procedure TGBJSONTestDeserializePerson.ListFill;
begin
  FJSONObject := GetJsonObject(FPerson);
  FPerson.Notes[0] := 5;
  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Notes'));
  Assert.IsTrue(FJSONObject.GetValue<TJSONArray>('Notes').Count > 0);
  Assert.AreEqual('5', FJSONObject.GetValue<TJSONArray>('Notes').Items[0].Value);
end;

procedure TGBJSONTestDeserializePerson.ListNull;
begin
  FPerson.Notes.Free;
  FPerson.Notes := nil;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Notes'));
end;

procedure TGBJSONTestDeserializePerson.ListOneElement;
begin
  FPerson.Notes.Clear;
  FPerson.Notes.Add(2);
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Notes'));
  Assert.AreEqual(1, FJSONObject.GetValue<TJSONArray>('Notes').Count);
  Assert.AreEqual('2', FJSONObject.GetValue<TJSONArray>('Notes').Items[0].Value);
end;

procedure TGBJSONTestDeserializePerson.IntegerEmpty;
begin
  FPerson.Age := 0;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Age'));
end;

procedure TGBJSONTestDeserializePerson.ObjectListFill;
begin
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Phones'));
  Assert.IsTrue(FJSONObject.GetValue<TJSONArray>('Phones').Count > 0);

  Assert.IsFalse(FJSONObject.GetValue<TJSONArray>('Phones').Items[0]
    .GetValue<string>('Number').IsEmpty);
end;

procedure TGBJSONTestDeserializePerson.ObjectListNull;
begin
  FPerson.Phones.Free;
  FPerson.Phones := nil;

  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Phones'));
end;

procedure TGBJSONTestDeserializePerson.ObjectListOneElement;
begin
  FPerson.Phones.Remove(FPerson.Phones[1]);
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Phones'));
  Assert.AreEqual(1, FJSONObject.GetValue<TJSONArray>('Phones').Count);
end;

procedure TGBJSONTestDeserializePerson.ObjectLowerCase;
begin
  FreeAndNil(FJSONObject);
  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdLower);

  FUpperPerson.PERSON_ID := 1;
  FUpperPerson.PERSON_NAME := 'Test Person';

  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
    .ObjectToJsonObject(FUpperPerson);

  Assert.AreEqual(1, FJSONObject.GetValue<Integer>('person_id'));
  Assert.AreEqual('Test Person', FJSONObject.GetValue<string>('person_name'));
end;

procedure TGBJSONTestDeserializePerson.ObjectListEmpty;
begin
  FPerson.Phones.Remove(FPerson.Phones[0]);
  FPerson.Phones.Remove(FPerson.Phones[0]);

  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNull(FJSONObject.GetValue('Phones'));
end;

procedure TGBJSONTestDeserializePerson.ObjectNull;
begin
  FPerson.Address.Free;
  FPerson.Address := nil;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Address'));
end;

procedure TGBJSONTestDeserializePerson.ObjectUnderlineProperty;
begin
  FreeAndNil(FJSONObject);
  FPerson.Document_Number := '123456';

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
    .ObjectToJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue('Document_Number'));
  Assert.AreEqual('123456', FJSONObject.ValueAsString('Document_Number'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  FreeAndNil(FJSONObject);
  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
    .ObjectToJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue('DOCUMENT_NUMBER'));
  Assert.AreEqual('123456', FJSONObject.ValueAsString('DOCUMENT_NUMBER'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLower);
  FreeAndNil(FJSONObject);
  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
    .ObjectToJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue('document_number'));
  Assert.AreEqual('123456', FJSONObject.ValueAsString('document_number'));

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  FreeAndNil(FJSONObject);
  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
    .ObjectToJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue('documentNumber'));
  Assert.AreEqual('123456', FJSONObject.ValueAsString('documentNumber'));
end;

procedure TGBJSONTestDeserializePerson.ObjectUpperCase;
begin
  FreeAndNil(FJSONObject);
  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdUpper);

  FUpperPerson.PERSON_ID := 1;
  FUpperPerson.PERSON_NAME := 'Test Person';

  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
    .ObjectToJsonObject(FUpperPerson);

  Assert.AreEqual(1, FJSONObject.GetValue<Integer>('PERSON_ID'));
  Assert.AreEqual('Test Person', FJSONObject.GetValue<string>('PERSON_NAME'));
end;

procedure TGBJSONTestDeserializePerson.ObjectValue;
begin
  FPerson.Address.Street := 'Rua Tal';
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Rua Tal', FJSONObject.ValueAsJSONObject('Address').GetValue<string>('Street'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLowerCamelCase);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Rua Tal', FJSONObject.ValueAsJSONObject('address').GetValue<string>('street'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Rua Tal', FJSONObject.ValueAsJSONObject('ADDRESS').GetValue<string>('STREET'));
end;

procedure TGBJSONTestDeserializePerson.StringEmpty;
begin
  FPerson.name := EmptyStr;
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNull(FJSONObject.Get('Name'));
  Assert.IsNull(FJSONObject.Get('name'));
  Assert.IsNull(FJSONObject.Get('NAME'));
end;

end.
