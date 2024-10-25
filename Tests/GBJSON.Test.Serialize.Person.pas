unit GBJSON.Test.Serialize.Person;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.Interfaces,
  GBJSON.Helper,
  GBJSON.Deserializer,
  GBJSON.Serializer,
  System.DateUtils,
  System.JSON,
  System.SysUtils;

type
  [TestFixture]
  TGBJSONTestSerializePerson = class
  private
    FPerson: TPerson;
    FUpperPerson: TUpperPerson;
    FSerialize: IGBJSONSerializer<TPerson>;
    FJSONObject: TJSONObject;

    procedure ResetJSONObject;
    procedure CreateJSONObject;
    procedure CreatePerson;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('Normal', 'Test')]
    [TestCase('Empty', '')]
    [TestCase('WithAccent', 'Tomé')]
    [TestCase('WithBar', 'Value 1 / Value 2')]
    [TestCase('WithBackslash', 'Value 1 \ Value 2')]
    [TestCase('WithDoubleQuotes', 'Name With "Quotes"')]
    procedure StringValue(AValue: string);

    [Test]
    [TestCase('Positive', '5')]
    [TestCase('Negative', '-5')]
    [TestCase('Zero', '0')]
    procedure IntegerValue(AValue: Integer);

    [Test]
    [TestCase('Positive', '5')]
    [TestCase('Negative', '-5')]
    [TestCase('PositiveWithDecimal', '5.3')]
    [TestCase('NegativeWithDecimal', '-5.3')]
    [TestCase('Zero', '0')]
    procedure DoubleValue(AValue: Double);

    [Test]
    procedure DateValue;

    [Test]
    procedure DateTimeValue;

    [Test]
    [TestCase('TrueValue', 'True')]
    [TestCase('FalseValue', 'False')]
    procedure BoolValue(AValue: Boolean);

    [Test]
    procedure EnumValue;

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
    procedure ListFloatFill;

    [Test]
    procedure ListFloatEmpty;

    [Test]
    procedure ListFloatOneElement;

    [Test]
    procedure ListFloatNull;

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

{ TGBJSONTestSerializePerson }

procedure TGBJSONTestSerializePerson.BoolValue(AValue: Boolean);
begin
  ResetJSONObject;
  FJSONObject.AddPair('active', TJSONBool.Create(AValue));
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Active);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Active', TJSONBool.Create(AValue));
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Active);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('ACTIVE', TJSONBool.Create(AValue));
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Active);
end;

procedure TGBJSONTestSerializePerson.CreateJSONObject;
var
  LJSONObject: TJSONObject;
  LJSONArray: TJSONArray;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := TJSONObject.Create;
  FJSONObject.AddPair('idPerson', TJSONNumber.Create(1))
    .AddPair('name', 'Test')
    .AddPair('age', TJSONNumber.Create(18))
    .AddPair('average', TJSONNumber.Create(10.5))
    .AddPair('creationDate', '2024-10-25 06:30:27');

  // Address
  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('idAddress', '2')
    .AddPair('street', 'Test');
  FJSONObject.AddPair('address', LJSONObject);

  // Phones
  LJSONArray := TJSONArray.Create;
  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('idTel', TJSONNumber.Create(3))
    .AddPair('number', '321654987');
  LJSONArray.AddElement(LJSONObject);
  LJSONObject := TJSONObject.Create;
  LJSONObject.AddPair('idTel', TJSONNumber.Create(4))
    .AddPair('number', '11111111');
  LJSONArray.AddElement(LJSONObject);
  FJSONObject.AddPair('phones', LJSONArray);

  // Notes
  LJSONArray := TJSONArray.Create;
  LJSONArray.Add(5).Add(6);
  FJSONObject.AddPair('notes', LJSONArray);

  // Qualities
  LJSONArray := TJSONArray.Create;
  LJSONArray.Add('q1').Add('q2');
  FJSONObject.AddPair('qualities', LJSONArray);
end;

procedure TGBJSONTestSerializePerson.CreatePerson;
begin
  FreeAndNil(FPerson);
  FPerson := FSerialize.JsonObjectToObject(FJSONObject);
end;

procedure TGBJSONTestSerializePerson.DateTimeValue;
begin
  ResetJSONObject;
  FJSONObject.AddPair('creationDate', '2024-10-25 05:25:59');
  CreatePerson;
  Assert.AreEqual<TDateTime>(EncodeDateTime(2024, 10, 25, 5, 25, 59, 0), FPerson.CreationDate);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('CreationDate', '2024-10-25 05:25:59');
  CreatePerson;
  Assert.AreEqual<TDateTime>(EncodeDateTime(2024, 10, 25, 5, 25, 59, 0), FPerson.CreationDate);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('CREATIONDATE', '2024-10-25 05:25:59');
  CreatePerson;
  Assert.AreEqual<TDateTime>(EncodeDateTime(2024, 10, 25, 5, 25, 59, 0), FPerson.CreationDate);
end;

procedure TGBJSONTestSerializePerson.DateValue;
begin
  ResetJSONObject;
  FJSONObject.AddPair('creationDate', '2024-10-25');
  CreatePerson;
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 25), FPerson.CreationDate);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('CreationDate', '2024-10-25');
  CreatePerson;
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 25), FPerson.CreationDate);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('CREATIONDATE', '2024-10-25');
  CreatePerson;
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 25), FPerson.CreationDate);
end;

procedure TGBJSONTestSerializePerson.DoubleValue(AValue: Double);
begin
  ResetJSONObject;
  FJSONObject.AddPair('average', TJSONNumber.Create(AValue));
  CreatePerson;
  Assert.AreEqual<Double>(AValue, FPerson.Average);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Average', TJSONNumber.Create(AValue));
  CreatePerson;
  Assert.AreEqual<Double>(AValue, FPerson.Average);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('AVERAGE', TJSONNumber.Create(AValue));
  CreatePerson;
  Assert.AreEqual<Double>(AValue, FPerson.Average);
end;

procedure TGBJSONTestSerializePerson.EnumValue;
begin
  ResetJSONObject;
  FJSONObject.AddPair('personType', 'tpJuridica');
  CreatePerson;
  Assert.AreEqual(tpJuridica, FPerson.PersonType);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('PersonType', 'tpJuridica');
  CreatePerson;
  Assert.AreEqual(tpJuridica, FPerson.PersonType);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('PERSONTYPE', 'tpJuridica');
  CreatePerson;
  Assert.AreEqual(tpJuridica, FPerson.PersonType);
end;

procedure TGBJSONTestSerializePerson.IntegerValue(AValue: Integer);
begin
  ResetJSONObject;
  FJSONObject.AddPair('name', 'Test')
    .AddPair('age', TJSONNumber.Create(AValue));
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Age);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Name', 'Test')
    .AddPair('Age', TJSONNumber.Create(AValue));
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Age);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('NAME', 'Test')
    .AddPair('AGE', TJSONNumber.Create(AValue));
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Age);
end;

procedure TGBJSONTestSerializePerson.JSONNameAttribute;
begin
  ResetJSONObject;
  FJSONObject.AddPair('Observacao', 'test');
  CreatePerson;
  Assert.AreEqual('test', FPerson.Obs);
end;

procedure TGBJSONTestSerializePerson.ResetJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := TJSONObject.Create;
end;

procedure TGBJSONTestSerializePerson.Setup;
begin
  FSerialize := TGBJSONSerializer<TPerson>.New(False);
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
end;

procedure TGBJSONTestSerializePerson.TearDown;
begin
  FreeAndNil(FJSONObject);
  FreeAndNil(FPerson);
  FreeAndNil(FUpperPerson);
end;

procedure TGBJSONTestSerializePerson.ArrayStringEmpty;
begin
  ResetJSONObject;
  FJSONObject.AddPair('qualities', TJSONArray.Create);
  CreatePerson;
  Assert.AreEqual(0, Length(FPerson.Qualities));
end;

procedure TGBJSONTestSerializePerson.ArrayStringFill;
begin
  CreateJSONObject;
  CreatePerson;
  Assert.AreEqual(2, Length(FPerson.Qualities));
  Assert.AreEqual('q1', FPerson.Qualities[0]);
  Assert.AreEqual('q2', FPerson.Qualities[1]);
end;

procedure TGBJSONTestSerializePerson.ArrayStringOneElement;
begin
  ResetJSONObject;
  FJSONObject.AddPair('qualities', TJSONArray.Create.Add('q1'));
  CreatePerson;
  Assert.AreEqual('q1', FPerson.Qualities[0]);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Qualities', TJSONArray.Create.Add('q1'));
  CreatePerson;
  Assert.AreEqual('q1', FPerson.Qualities[0]);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('QUALITIES', TJSONArray.Create.Add('q1'));
  CreatePerson;
  Assert.AreEqual('q1', FPerson.Qualities[0]);
end;

procedure TGBJSONTestSerializePerson.ListFloatEmpty;
begin
  ResetJSONObject;
  FJSONObject.AddPair('notes', TJSONArray.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Notes.Count);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Notes', TJSONArray.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Notes.Count);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('NOTES', TJSONArray.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Notes.Count);
end;

procedure TGBJSONTestSerializePerson.ListFloatFill;
begin
  CreateJSONObject;
  CreatePerson;
  Assert.AreEqual(2, FPerson.Notes.Count);
  Assert.AreEqual('5', FPerson.Notes[0].ToString);
  Assert.AreEqual('6', FPerson.Notes[1].ToString);
end;

procedure TGBJSONTestSerializePerson.ListFloatNull;
begin
  ResetJSONObject;
  FJSONObject.AddPair('notes', TJSONNull.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Notes.Count);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Notes', TJSONNull.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Notes.Count);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('NOTES', TJSONNull.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Notes.Count);
end;

procedure TGBJSONTestSerializePerson.ListFloatOneElement;
begin
  ResetJSONObject;
  FJSONObject.AddPair('notes', TJSONArray.Create.Add(5));
  CreatePerson;
  Assert.AreEqual(1, FPerson.Notes.Count);
  Assert.AreEqual<Double>(5, FPerson.Notes[0]);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Notes', TJSONArray.Create.Add(5));
  CreatePerson;
  Assert.AreEqual(1, FPerson.Notes.Count);
  Assert.AreEqual<Double>(5, FPerson.Notes[0]);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('NOTES', TJSONArray.Create.Add(5));
  CreatePerson;
  Assert.AreEqual(1, FPerson.Notes.Count);
  Assert.AreEqual<Double>(5, FPerson.Notes[0]);
end;

procedure TGBJSONTestSerializePerson.ObjectListFill;
begin
  CreateJSONObject;
  CreatePerson;
  Assert.AreEqual(2, FPerson.Phones.Count);
  Assert.AreEqual<Double>(3, FPerson.Phones[0].IdTel);
  Assert.AreEqual('321654987', FPerson.Phones[0].Number);
  Assert.AreEqual<Double>(4, FPerson.Phones[1].IdTel);
  Assert.AreEqual('11111111', FPerson.Phones[1].Number);
end;

procedure TGBJSONTestSerializePerson.ObjectListNull;
begin
  ResetJSONObject;
  FJSONObject.AddPair('phones', TJSONNull.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Phones.Count);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Phones', TJSONNull.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Phones.Count);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('PHONES', TJSONNull.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Phones.Count);
end;

procedure TGBJSONTestSerializePerson.ObjectListOneElement;
var
  LJSONArray: TJSONArray;
begin
  CreateJSONObject;
  LJSONArray := FJSONObject.GetValue<TJSONArray>('phones');
  LJSONArray.Remove(1).Free;
  CreatePerson;
  Assert.AreEqual(1, FPerson.Phones.Count);
end;

procedure TGBJSONTestSerializePerson.ObjectLowerCase;
begin
  ResetJSONObject;
  FJSONObject.AddPair('person_id', TJSONNumber.Create(1))
    .AddPair('person_name', 'Person Test');

  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdLower);

  FUpperPerson := TUpperPerson.Create;
  FUpperPerson.FromJSONObject(FJSONObject);

  Assert.AreEqual('1', FUpperPerson.PERSON_ID.ToString);
  Assert.AreEqual('Person Test', FUpperPerson.PERSON_NAME);
end;

procedure TGBJSONTestSerializePerson.ObjectListEmpty;
begin
  ResetJSONObject;
  FJSONObject.AddPair('phones', TJSONArray.Create);
  CreatePerson;
  Assert.AreEqual(0, FPerson.Phones.Count);
end;

procedure TGBJSONTestSerializePerson.ObjectNull;
begin
  ResetJSONObject;
  FJSONObject.AddPair('address', TJSONNull.Create);
  CreatePerson;
  Assert.IsNotNull(FPerson.Address);
end;

procedure TGBJSONTestSerializePerson.ObjectUnderlineProperty;
begin
  ResetJSONObject;
  FJSONObject.AddPair('document_number', '123456');
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLower);
  CreatePerson;
  Assert.AreEqual('123456', FPerson.Document_Number);

  ResetJSONObject;
  FJSONObject.AddPair('documentNumber', '123456');
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLowerCamelCase);
  CreatePerson;
  Assert.AreEqual('123456', FPerson.Document_Number);

  ResetJSONObject;
  FJSONObject.AddPair('DOCUMENT_NUMBER', '123456');
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  CreatePerson;
  Assert.AreEqual('123456', FPerson.Document_Number);

  ResetJSONObject;
  FJSONObject.AddPair('Document_Number', '123456');
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  CreatePerson;
  Assert.AreEqual('123456', FPerson.Document_Number);
end;

procedure TGBJSONTestSerializePerson.ObjectUpperCase;
begin
  ResetJSONObject;
  FJSONObject.AddPair('IDPERSON', TJSONNumber.Create(1))
    .AddPair('NAME', 'Person Test');

  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdUpper);

  CreatePerson;

  Assert.AreEqual('1', FPerson.IdPerson.ToString);
  Assert.AreEqual('Person Test', FPerson.name);
end;

procedure TGBJSONTestSerializePerson.ObjectValue;
begin
  ResetJSONObject;
  FJSONObject.AddPair('address', TJSONObject.Create
    .AddPair('street', 'Rua Tal'));
  CreatePerson;
  Assert.AreEqual('Rua Tal', FPerson.Address.Street);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Address', TJSONObject.Create
    .AddPair('Street', 'Rua Tal'));
  CreatePerson;
  Assert.AreEqual('Rua Tal', FPerson.Address.Street);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('ADDRESS', TJSONObject.Create
    .AddPair('STREET', 'Rua Tal'));
  CreatePerson;
  Assert.AreEqual('Rua Tal', FPerson.Address.Street);
end;

procedure TGBJSONTestSerializePerson.StringValue(AValue: string);
begin
  FJSONObject := TJSONObject.Create;
  FJSONObject.AddPair('name', AValue);
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Name);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
  ResetJSONObject;
  FJSONObject.AddPair('Name', AValue);
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Name);

  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdUpper);
  ResetJSONObject;
  FJSONObject.AddPair('NAME', AValue);
  CreatePerson;
  Assert.AreEqual(AValue, FPerson.Name);
end;

end.
