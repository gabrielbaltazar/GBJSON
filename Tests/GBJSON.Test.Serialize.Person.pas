unit GBJSON.Test.Serialize.Person;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.Interfaces,
  GBJSON.Helper,
  GBJSON.Deserializer,
  GBJSON.Serializer,
  System.JSON,
  System.SysUtils;

type
  [TestFixture]
  TGBJSONTestSerializePerson = class
  private
    FPerson: TPerson;
    FAuxPerson: TPerson;
    FUpperPerson: TUpperPerson;
    FDeserialize: IGBJSONDeserializer<TPerson>;
    FSerialize: IGBJSONSerializer<TPerson>;
    FJSONObject: TJSONObject;

    function GetJsonObject(APerson: TPerson): TJSONObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestStringName;
    [Test]
    procedure TestStringEmpty;
    [Test]
    procedure TestStringWithAccent;
    [Test]
    procedure TestStringWithBar;
    [Test]
    procedure TestStringWithBackslash;
    [Test]
    procedure TestStringWithDoubleQuotes;

    [Test]
    procedure TestIntegerPositive;
    [Test]
    procedure TestIntegerEmpty;
    [Test]
    procedure TestIntegerNegative;

    [Test]
    procedure TestFloatPositive;
    [Test]
    procedure TestFloatNegative;
    [Test]
    procedure TestFloatZero;
    [Test]
    procedure TestFloatPositiveWithDecimal;
    [Test]
    procedure TestFloatNegativeWithDecimal;

    [Test]
    procedure TestDateEmpty;
    [Test]
    procedure TestDateFill;

    [Test]
    procedure TestBooleanFalse;
    [Test]
    procedure TestBooleanTrue;
    [Test]
    procedure TestBoolEmpty;

    [Test]
    procedure TestEnumString;

    [Test]
    procedure TestObjectValue;
    [Test]
    procedure TestObjectNull;

    [Test]
    procedure TestObjectLowerCase;
    [Test]
    procedure TestObjectUpperCase;
    [Test]
    procedure TestObjectUnderlineProperty;


    [Test]
    procedure TestObjectListFill;
    [Test]
    procedure TestObjectListEmpty;
    [Test]
    procedure TestObjectListOneElement;
    [Test]
    procedure TestObjectListNull;

    [Test]
    procedure TestListFloatFill;
    [Test]
    procedure TestListFloatEmpty;
    [Test]
    procedure TestListFloatOneElement;
    [Test]
    procedure TestListFloatNull;

    [Test]
    procedure TestArrayStringFill;
    [Test]
    procedure TestArrayStringEmpty;
    [Test]
    procedure TestArrayStringOneElement;
  end;

implementation

{ TGBJSONTestSerializePerson }

function TGBJSONTestSerializePerson.GetJsonObject(APerson: TPerson): TJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := FDeserialize.ObjectToJsonObject(APerson);
  Result := FJSONObject;
end;

procedure TGBJSONTestSerializePerson.Setup;
begin
  FDeserialize := TGBJSONDeserializer<TPerson>.New(False);
  FSerialize := TGBJSONSerializer<TPerson>.New(False);
  FPerson := TPerson.CreatePerson;
  FJSONObject := GetJsonObject(FPerson);
end;

procedure TGBJSONTestSerializePerson.TearDown;
begin
  FreeAndNil(FJSONObject);
  FreeAndNil(FUpperPerson);
  FreeAndNil(FPerson);
  FreeAndNil(FAuxPerson);
end;

procedure TGBJSONTestSerializePerson.TestArrayStringEmpty;
begin
  FPerson.Qualities := [];
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(Length(FAuxPerson.Qualities) = 0);
end;

procedure TGBJSONTestSerializePerson.TestArrayStringFill;
begin
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(2, Length( FAuxPerson.Qualities));
  Assert.AreEqual('q1', FAuxPerson.Qualities[0]);
  Assert.AreEqual('q2', FAuxPerson.Qualities[1]);
end;

procedure TGBJSONTestSerializePerson.TestArrayStringOneElement;
begin
  FPerson.Qualities := ['q1'];
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(1, Length( FAuxPerson.Qualities));
  Assert.AreEqual('q1', FAuxPerson.Qualities[0]);
end;

procedure TGBJSONTestSerializePerson.TestBooleanFalse;
begin
  FPerson.Active := False;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsFalse(FAuxPerson.Active);
end;

procedure TGBJSONTestSerializePerson.TestBooleanTrue;
begin
  FPerson.Active := True;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.Active);
end;

procedure TGBJSONTestSerializePerson.TestBoolEmpty;
begin
  FPerson.Active := True;
  FJSONObject := GetJsonObject(FPerson);
  FJSONObject.RemovePair('active').Free;

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsFalse(FAuxPerson.Active);
end;

procedure TGBJSONTestSerializePerson.TestDateFill;
begin
  FPerson.CreationDate := Now;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FormatDateTime('yyyy-MM-dd hh:mm:ss', FPerson.CreationDate),
    FormatDateTime('yyyy-MM-dd hh:mm:ss', FAuxPerson.CreationDate));
end;

procedure TGBJSONTestSerializePerson.TestDateEmpty;
begin
  FPerson.CreationDate := 0;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.CreationDate, FAuxPerson.CreationDate);
end;

procedure TGBJSONTestSerializePerson.TestEnumString;
begin
  FPerson.PersonType := tpJuridica;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.PersonType, FAuxPerson.PersonType);
end;

procedure TGBJSONTestSerializePerson.TestFloatNegative;
begin
  FPerson.Average := -5;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Average, FAuxPerson.Average);
end;

procedure TGBJSONTestSerializePerson.TestFloatNegativeWithDecimal;
begin
  FPerson.Average := -5.25;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Average, FAuxPerson.Average);
end;

procedure TGBJSONTestSerializePerson.TestFloatPositive;
begin
  FPerson.Average := 15;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Average, FAuxPerson.Average);
end;

procedure TGBJSONTestSerializePerson.TestFloatPositiveWithDecimal;
begin
  FPerson.Average := 15.351;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Average, FAuxPerson.Average);
end;

procedure TGBJSONTestSerializePerson.TestFloatZero;
begin
  FPerson.Average := 0;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.Average = 0);
end;

procedure TGBJSONTestSerializePerson.TestIntegerNegative;
begin
  FPerson.Age := -5;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Age, FAuxPerson.Age);
end;

procedure TGBJSONTestSerializePerson.TestIntegerPositive;
begin
  FPerson.Age := 50;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Age, FAuxPerson.Age);
end;

procedure TGBJSONTestSerializePerson.TestListFloatEmpty;
begin
  FPerson.Notes.Clear;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.Notes.Count = 0);
end;

procedure TGBJSONTestSerializePerson.TestListFloatFill;
begin
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(2, FAuxPerson.Notes.Count);
  Assert.AreEqual('5', FAuxPerson.Notes[0].ToString);
  Assert.AreEqual('6', FAuxPerson.Notes[1].ToString);
end;

procedure TGBJSONTestSerializePerson.TestListFloatNull;
begin
  FPerson.Notes.Free;
  FPerson.Notes := nil;

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(0, FAuxPerson.Notes.Count);
end;

procedure TGBJSONTestSerializePerson.TestListFloatOneElement;
begin
  FPerson.Notes.Clear;
  FPerson.Notes.Add(1);

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(1, FAuxPerson.Notes.Count);
  Assert.AreEqual('1', FAuxPerson.Notes[0].ToString);
end;

procedure TGBJSONTestSerializePerson.TestIntegerEmpty;
begin
  FPerson.Age := 0;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Age, FAuxPerson.Age);
end;

procedure TGBJSONTestSerializePerson.TestObjectListFill;
begin
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.Phones.Count > 0);
  Assert.IsFalse(FAuxPerson.Phones[0].Number.IsEmpty);

  Assert.AreEqual(FPerson.Phones.Count, FAuxPerson.Phones.Count);
  Assert.AreEqual(FPerson.Phones[0].Number, FAuxPerson.Phones[0].Number);
end;

procedure TGBJSONTestSerializePerson.TestObjectListNull;
begin
  FPerson.Phones.Free;
  FPerson.Phones := nil;

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson.Phones);
  Assert.IsTrue(FAuxPerson.Phones.Count = 0);
end;

procedure TGBJSONTestSerializePerson.TestObjectListOneElement;
begin
  FPerson.Phones.Remove(FPerson.Phones[1]);
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.Phones.Count = 1);
  Assert.IsFalse(FAuxPerson.Phones[0].Number.IsEmpty);

  Assert.AreEqual(FPerson.Phones.Count, FAuxPerson.Phones.Count);
  Assert.AreEqual(FPerson.Phones[0].Number, FAuxPerson.Phones[0].Number);
end;

procedure TGBJSONTestSerializePerson.TestObjectLowerCase;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := TJSONObject.Create;
  FJSONObject.AddPair('person_id', TJSONNumber.Create(1))
    .AddPair('person_name', 'Person Test');

  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdLower);

  FUpperPerson := TUpperPerson.create;
  FUpperPerson.fromJSONObject(FJSONObject);

  Assert.AreEqual('1', FUpperPerson.PERSON_ID.ToString);
  Assert.AreEqual('Person Test', FUpperPerson.PERSON_NAME);
end;

procedure TGBJSONTestSerializePerson.TestObjectListEmpty;
begin
  FPerson.Phones.Remove(FPerson.Phones[0]);
  FPerson.Phones.Remove(FPerson.Phones[0]);

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue (FAuxPerson.Phones.Count = 0);
end;

procedure TGBJSONTestSerializePerson.TestObjectNull;
begin
  FPerson.Address.Free;
  FPerson.Address := nil;

  FJSONObject := GetJsonObject(FPerson);
  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);

  Assert.IsEmpty(FAuxPerson.Address.Street);
end;

procedure TGBJSONTestSerializePerson.TestObjectUnderlineProperty;
begin
  FreeAndNil(FPerson);
  FreeAndNil(FJSONObject);
  FJSONObject := TJSONObject.Create;
  FJSONObject.AddPair('document_number', '123456');

  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdNone);

  FPerson := TPerson.Create;
  FPerson.fromJSONObject(FJSONObject);

  Assert.AreEqual('123456', FPerson.Document_Number);
end;

procedure TGBJSONTestSerializePerson.TestObjectUpperCase;
begin
  FreeAndNil(FPerson);
  FreeAndNil(FJSONObject);
  FJSONObject := TJSONObject.Create;
  FJSONObject.AddPair('IDPERSON', TJSONNumber.Create(1))
    .AddPair('NAME', 'Person Test');

  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdUpper);

  FPerson := TPerson.Create;
  FPerson.fromJSONObject(FJSONObject);

  Assert.AreEqual('1', FPerson.IdPerson.ToString);
  Assert.AreEqual('Person Test', FPerson.name);
end;

procedure TGBJSONTestSerializePerson.TestObjectValue;
begin
  FPerson.Address.Street := 'Rua Tal';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.Address.Street, FAuxPerson.Address.Street);
end;

procedure TGBJSONTestSerializePerson.TestStringWithAccent;
begin
  FPerson.name := 'Tomé';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestSerializePerson.TestStringWithBar;
begin
  FPerson.name := 'Value 1 / Value 2';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestSerializePerson.TestStringWithDoubleQuotes;
begin
  FPerson.name := 'Name With "Quotes"';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
  Assert.AreEqual('Name With "Quotes"', FAuxPerson.name);
end;

procedure TGBJSONTestSerializePerson.TestStringWithBackslash;
begin
  FPerson.name := 'Value 1 \ Value 2';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
  Assert.AreEqual('Value 1 \ Value 2', FAuxPerson.name);
end;

procedure TGBJSONTestSerializePerson.TestStringEmpty;
begin
  FPerson.name := EmptyStr;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestSerializePerson.TestStringName;
begin
  FPerson.name := 'Value 1';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

end.
