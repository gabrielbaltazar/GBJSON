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
  System.Generics.Collections,
  System.JSON,
  System.SysUtils;

type
  [TestFixture]
  TGBJSONTestDeserializePerson = class
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
    procedure TestListFill;
    [Test]
    procedure TestListEmpty;
    [Test]
    procedure TestListOneElement;
    [Test]
    procedure TestListNull;

    [Test]
    procedure TestArrayStringFill;
    [Test]
    procedure TestArrayStringEmpty;
    [Test]
    procedure TestArrayStringOneElement;

    [Test]
    procedure JSONNameAttribute;
  end;

implementation

{ TGBJSONTestDeserializePerson }

function TGBJSONTestDeserializePerson.GetJsonObject(APerson: TPerson): TJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := FDeserialize.ObjectToJsonObject(APerson);
  Result := FJSONObject;
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
  FSerialize := TGBJSONSerializer<TPerson>.New(False);

  FPerson := TPerson.CreatePerson;
  FUpperPerson := TUpperPerson.CreatePerson;
  FJSONObject := GetJsonObject(FPerson);
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdNone);
end;

procedure TGBJSONTestDeserializePerson.TearDown;
begin
  FreeAndNil(FJSONObject);
  FreeAndNil(FPerson);
  FreeAndNil(FUpperPerson);
  FreeAndNil(FAuxPerson);
end;

procedure TGBJSONTestDeserializePerson.TestArrayStringEmpty;
begin
  FPerson.Qualities := [];
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Qualities'));
end;

procedure TGBJSONTestDeserializePerson.TestArrayStringFill;
begin
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(2, FJSONObject.GetValue<TJSONArray>('Qualities').Count);
  Assert.AreEqual('q1', FJSONObject.GetValue<TJSONArray>('Qualities').Items[0].Value);
  Assert.AreEqual('q2', FJSONObject.GetValue<TJSONArray>('Qualities').Items[1].Value);
end;

procedure TGBJSONTestDeserializePerson.TestArrayStringOneElement;
begin
  FPerson.Qualities := ['q1'];
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(1, FJSONObject.GetValue<TJSONArray>('Qualities').Count);
  Assert.AreEqual('q1', FJSONObject.GetValue<TJSONArray>('Qualities').Items[0].Value);
end;

procedure TGBJSONTestDeserializePerson.TestBooleanFalse;
begin
  FPerson.Active := False;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsFalse(FJSONObject.GetValue<Boolean>('Active', True));
end;

procedure TGBJSONTestDeserializePerson.TestBooleanTrue;
begin
  FPerson.Active := True;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsTrue(FJSONObject.GetValue<Boolean>('Active', False));
end;

procedure TGBJSONTestDeserializePerson.TestDateFill;

begin
  FPerson.CreationDate := EncodeDate(2024, 10, 3);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<TDateTime>(EncodeDate(2024, 10, 3), FJSONObject.GetValue<TDateTime>('CreationDate', 0));
end;

procedure TGBJSONTestDeserializePerson.TestDateEmpty;
begin
  FPerson.CreationDate := 0;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('CreationDate'));
end;

procedure TGBJSONTestDeserializePerson.TestEnumString;
begin
  FPerson.PersonType := tpJuridica;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('tpJuridica', FJSONObject.GetValue<string>('PersonType'))
end;

procedure TGBJSONTestDeserializePerson.TestFloatNegative;
begin
  FPerson.Average := -5;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(-5, FJSONObject.ValueAsFloat('Average'));
end;

procedure TGBJSONTestDeserializePerson.TestFloatNegativeWithDecimal;
begin
  FPerson.Average := -5.25;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(-5.25, FJSONObject.ValueAsFloat('Average'));
end;

procedure TGBJSONTestDeserializePerson.TestFloatPositive;
begin
  FPerson.Average := 15;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(15, FJSONObject.ValueAsFloat('Average'));
end;

procedure TGBJSONTestDeserializePerson.TestFloatPositiveWithDecimal;
begin
  FPerson.Average := 15.351;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(15.351, FJSONObject.ValueAsFloat('Average'));
end;

procedure TGBJSONTestDeserializePerson.TestFloatZero;
begin
  FPerson.Average := 0;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual<Double>(1, FJSONObject.ValueAsFloat('Average', 1));
end;

procedure TGBJSONTestDeserializePerson.TestIntegerNegative;
begin
  FPerson.Age := -5;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(-5, FJSONObject.ValueAsInteger('Age'));
end;

procedure TGBJSONTestDeserializePerson.TestIntegerPositive;
begin
  FPerson.Age := 50;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(50, FJSONObject.ValueAsInteger('Age'));
end;

procedure TGBJSONTestDeserializePerson.TestListEmpty;
begin
  FPerson.Notes.Clear;

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.Notes.Count = 0);
end;

procedure TGBJSONTestDeserializePerson.TestListFill;
begin
  FJSONObject := GetJsonObject(FPerson);
  FPerson.Notes[0] := 5;
  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Notes'));
  Assert.IsTrue(FJSONObject.GetValue<TJSONArray>('Notes').Count > 0);
  Assert.AreEqual('5', FJSONObject.GetValue<TJSONArray>('Notes').Items[0].Value);
end;

procedure TGBJSONTestDeserializePerson.TestListNull;
begin
  FPerson.Notes.Free;
  FPerson.Notes := nil;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Notes'));
end;

procedure TGBJSONTestDeserializePerson.TestListOneElement;
begin
  FPerson.Notes.Clear;
  FPerson.Notes.Add(2);
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Notes'));
  Assert.AreEqual(1, FJSONObject.GetValue<TJSONArray>('Notes').Count);
  Assert.AreEqual('2', FJSONObject.GetValue<TJSONArray>('Notes').Items[0].Value);
end;

procedure TGBJSONTestDeserializePerson.TestIntegerEmpty;
begin
  FPerson.Age := 0;
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual(1, FJSONObject.ValueAsInteger('Age', 1));
end;

procedure TGBJSONTestDeserializePerson.TestObjectListFill;
begin
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Phones'));
  Assert.IsTrue(FJSONObject.GetValue<TJSONArray>('Phones').Count > 0);

  Assert.IsFalse(FJSONObject.GetValue<TJSONArray>('Phones').Items[0]
    .GetValue<string>('Number').IsEmpty);
end;

procedure TGBJSONTestDeserializePerson.TestObjectListNull;
begin
  FPerson.Phones.Free;
  FPerson.Phones := nil;

  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Phones'));
end;

procedure TGBJSONTestDeserializePerson.TestObjectListOneElement;
begin
  FPerson.Phones.Remove(FPerson.Phones[1]);
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNotNull(FJSONObject.GetValue<TJSONArray>('Phones'));
  Assert.AreEqual(1, FJSONObject.GetValue<TJSONArray>('Phones').Count);
end;

procedure TGBJSONTestDeserializePerson.TestObjectLowerCase;
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

procedure TGBJSONTestDeserializePerson.TestObjectListEmpty;
begin
  FPerson.Phones.Remove(FPerson.Phones[0]);
  FPerson.Phones.Remove(FPerson.Phones[0]);

  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNull(FJSONObject.GetValue('Phones'));
end;

procedure TGBJSONTestDeserializePerson.TestObjectNull;
begin
  FPerson.Address.Free;
  FPerson.Address := nil;
  FJSONObject := GetJsonObject(FPerson);
  Assert.IsNull(FJSONObject.GetValue('Address'));
end;

procedure TGBJSONTestDeserializePerson.TestObjectUnderlineProperty;
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

procedure TGBJSONTestDeserializePerson.TestObjectUpperCase;
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

procedure TGBJSONTestDeserializePerson.TestObjectValue;
begin
  FPerson.Address.Street := 'Rua Tal';
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Rua Tal', FJSONObject.ValueAsJSONObject('Address').GetValue<string>('Street'));
end;

procedure TGBJSONTestDeserializePerson.TestStringWithAccent;
begin
  FPerson.name := 'Tomé';
  FJSONObject := GetJsonObject(FPerson);

  TGBJSONConfig.GetInstance.CaseDefinition(cdNone);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Tomé', FJSONObject.GetValue<string>('Name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Tomé', FJSONObject.GetValue<string>('name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Tomé', FJSONObject.GetValue<string>('NAME'));
end;

procedure TGBJSONTestDeserializePerson.TestStringWithBar;
begin
  FPerson.name := 'Value 1 / Value 2';
  FJSONObject := GetJsonObject(FPerson);

  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1 / Value 2', FJSONObject.GetValue<string>('Name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1 / Value 2', FJSONObject.GetValue<string>('name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1 / Value 2', FJSONObject.GetValue<string>('NAME'));
end;

procedure TGBJSONTestDeserializePerson.TestStringWithDoubleQuotes;
begin
  FPerson.name := 'Name With "Quotes"';

  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Name With "Quotes"', FJSONObject.GetValue<string>('Name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Name With "Quotes"', FJSONObject.GetValue<string>('name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Name With "Quotes"', FJSONObject.GetValue<string>('NAME'));
end;

procedure TGBJSONTestDeserializePerson.TestStringWithBackslash;
begin
  FPerson.name := 'Value 1 \ Value 2';

  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1 \ Value 2', FJSONObject.GetValue<string>('Name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1 \ Value 2', FJSONObject.GetValue<string>('name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1 \ Value 2', FJSONObject.GetValue<string>('NAME'));
end;

procedure TGBJSONTestDeserializePerson.TestStringEmpty;
begin
  FPerson.name := EmptyStr;
  FJSONObject := GetJsonObject(FPerson);

  Assert.IsNull(FJSONObject.Get('Name'));
  Assert.IsNull(FJSONObject.Get('name'));
  Assert.IsNull(FJSONObject.Get('NAME'));
end;

procedure TGBJSONTestDeserializePerson.TestStringName;
begin
  FPerson.Name := 'Value 1';

  TGBJSONConfig.GetInstance.CaseDefinition(cdNone);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1', FJSONObject.GetValue<string>('Name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdLower);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1', FJSONObject.GetValue<string>('name'));

  TGBJSONConfig.GetInstance.CaseDefinition(cdUpper);
  FJSONObject := GetJsonObject(FPerson);
  Assert.AreEqual('Value 1', FJSONObject.GetValue<string>('NAME'));
end;

end.
