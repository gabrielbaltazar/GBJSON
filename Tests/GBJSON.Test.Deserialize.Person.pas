unit GBJSON.Test.Deserialize.Person;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.Interfaces,
  GBJSON.Deserializer,
  GBJSON.Serializer,
  System.JSON,
  System.SysUtils;

type TGBJSONTestDeserializePerson = class

  private
    FPerson      : TPerson;
    FAuxPerson   : TPerson;
    FUpperPerson : TUpperPerson;
    FDeserialize : IGBJSONDeserializer<TPerson>;
    FSerialize   : IGBJSONSerializer<TPerson>;
    FJSONObject  : TJSONObject;

    function GetJsonObject(APerson: TPerson): TJSONObject;
  public
    [Setup]    procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure TestStringName;
    [Test] procedure TestStringEmpty;
    [Test] procedure TestStringWithAccent;
    [Test] procedure TestStringWithBar;
    [Test] procedure TestStringWithBackslash;

    [Test] procedure TestIntegerPositive;
    [Test] procedure TestIntegerEmpty;
    [Test] procedure TestIntegerNegative;

    [Test] procedure TestFloatPositive;
    [Test] procedure TestFloatNegative;
    [Test] procedure TestFloatZero;
    [Test] procedure TestFloatPositiveWithDecimal;
    [Test] procedure TestFloatNegativeWithDecimal;

    [Test] procedure TestDateEmpty;
    [Test] procedure TestDateFill;

    [Test] procedure TestBooleanFalse;
    [Test] procedure TestBooleanTrue;
    [Test] procedure TestBoolEmpty;

    [Test] procedure TestEnumString;

    [Test] procedure TestObjectValue;
    [Test] procedure TestObjectNull;

    [Test] procedure TestObjectLowerCase;
    [Test] procedure TestObjectUpperCase;

    [Test] procedure TestObjectLowerCamelCase;
    [Test] procedure TestObjectUpperCamelCase;

    [Test] procedure TestObjectListFill;
    [Test] procedure TestObjectListEmpty;
    [Test] procedure TestObjectListOneElement;

    [Test] procedure TestObjectListNull;

    constructor create;
    destructor  Destroy; override;
end;

implementation

{ TGBJSONTestDeserializePerson }

constructor TGBJSONTestDeserializePerson.create;
begin
  FDeserialize := TGBJSONDeserializer<TPerson>.New(False);
  FSerialize   := TGBJSONSerializer<TPerson>.New(False);
end;

destructor TGBJSONTestDeserializePerson.Destroy;
begin
  inherited;
end;

function TGBJSONTestDeserializePerson.GetJsonObject(APerson: TPerson): TJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := FDeserialize.ObjectToJsonObject(APerson);

  result := FJSONObject;
end;

procedure TGBJSONTestDeserializePerson.Setup;
begin
  FPerson     := TPerson.CreatePerson;
  FUpperPerson:= TUpperPerson.CreatePerson;
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

procedure TGBJSONTestDeserializePerson.TestBooleanFalse;
begin
  FPerson.active := False;
  FJSONObject   := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsFalse(FAuxPerson.active);
end;

procedure TGBJSONTestDeserializePerson.TestBooleanTrue;
begin
  FPerson.active := True;
  FJSONObject   := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.active);
end;

procedure TGBJSONTestDeserializePerson.TestBoolEmpty;
begin
  FPerson.active := True;
  FJSONObject   := GetJsonObject(FPerson);
  FJSONObject.RemovePair('active').Free;

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsFalse(FAuxPerson.active);
end;

procedure TGBJSONTestDeserializePerson.TestDateFill;
begin
  FPerson.creationDate := Now;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FormatDateTime('yyyy-MM-dd hh:mm:ss', FPerson.creationDate),
                  FormatDateTime('yyyy-MM-dd hh:mm:ss', FAuxPerson.creationDate));
end;

procedure TGBJSONTestDeserializePerson.TestDateEmpty;
begin
  FPerson.creationDate := 0;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.creationDate, FAuxPerson.creationDate);
end;

procedure TGBJSONTestDeserializePerson.TestEnumString;
begin
  FPerson.personType := tpJuridica;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.personType, FAuxPerson.personType);
end;

procedure TGBJSONTestDeserializePerson.TestFloatNegative;
begin
  FPerson.average := -5;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.average, FAuxPerson.average);
end;

procedure TGBJSONTestDeserializePerson.TestFloatNegativeWithDecimal;
begin
  FPerson.average := -5.25;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.average, FAuxPerson.average);
end;

procedure TGBJSONTestDeserializePerson.TestFloatPositive;
begin
  FPerson.average := 15;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.average, FAuxPerson.average);
end;

procedure TGBJSONTestDeserializePerson.TestFloatPositiveWithDecimal;
begin
  FPerson.average := 15.351;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.average, FAuxPerson.average);
end;

procedure TGBJSONTestDeserializePerson.TestFloatZero;
begin
  FPerson.average := 0;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue(FAuxPerson.average = 0);
end;

procedure TGBJSONTestDeserializePerson.TestIntegerNegative;
begin
  FPerson.age := -5;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.age, FAuxPerson.age);
end;

procedure TGBJSONTestDeserializePerson.TestIntegerPositive;
begin
  FPerson.age := 50;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.age, FAuxPerson.age);
end;

procedure TGBJSONTestDeserializePerson.TestIntegerEmpty;
begin
  FPerson.age := 0;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.age, FAuxPerson.age);
end;

procedure TGBJSONTestDeserializePerson.TestObjectListFill;
begin
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue (FAuxPerson.phones.Count > 0);
  Assert.IsFalse(FAuxPerson.phones[0].number.IsEmpty);

  Assert.AreEqual(FPerson.phones.Count, FAuxPerson.phones.Count);
  Assert.AreEqual(FPerson.phones[0].number, FAuxPerson.phones[0].number);
end;

procedure TGBJSONTestDeserializePerson.TestObjectListNull;
begin
  FPerson.phones.Free;
  FPerson.phones := nil;

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson.phones);
  Assert.IsTrue (FAuxPerson.phones.Count = 0);
end;

procedure TGBJSONTestDeserializePerson.TestObjectListOneElement;
begin
  FPerson.phones.Remove(FPerson.phones[1]);
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue (FAuxPerson.phones.Count = 1);
  Assert.IsFalse(FAuxPerson.phones[0].number.IsEmpty);

  Assert.AreEqual(FPerson.phones.Count, FAuxPerson.phones.Count);
  Assert.AreEqual(FPerson.phones[0].number, FAuxPerson.phones[0].number);
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

  Assert.IsNotNull(FJSONObject.GetValue('person_id'));
  Assert.IsNotNull(FJSONObject.GetValue('person_name'));
end;

procedure TGBJSONTestDeserializePerson.TestObjectListEmpty;
begin
  FPerson.phones.Remove(FPerson.phones[0]);
  FPerson.phones.Remove(FPerson.phones[0]);

  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsTrue (FAuxPerson.phones.Count = 0);
end;

procedure TGBJSONTestDeserializePerson.TestObjectNull;
begin
  FPerson.address.Free;
  FPerson.address := nil;

  FJSONObject := GetJsonObject(FPerson);
  FAuxPerson  := FSerialize.JsonObjectToObject(FJSONObject);

  Assert.IsEmpty(FAuxPerson.address.street);
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

  Assert.IsNotNull(FJSONObject.GetValue('PERSON_ID'));
  Assert.IsNotNull(FJSONObject.GetValue('PERSON_NAME'));
end;

procedure TGBJSONTestDeserializePerson.TestObjectValue;
begin
  FPerson.address.street := 'Rua Tal';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.AreEqual(FPerson.address.street, FAuxPerson.address.street);
end;

procedure TGBJSONTestDeserializePerson.TestStringWithAccent;
begin
  FPerson.name := 'Tom�';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestDeserializePerson.TestStringWithBar;
begin
  FPerson.name := 'Value 1 / Value 2';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestDeserializePerson.TestStringWithBackslash;
begin
  FPerson.name := 'Value 1 \ Value 2';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestDeserializePerson.TestStringEmpty;
begin
  FPerson.name := EmptyStr;
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestDeserializePerson.TestStringName;
begin
  FPerson.name := 'Value 1';
  FJSONObject := GetJsonObject(FPerson);

  FAuxPerson := FSerialize.JsonObjectToObject(FJSONObject);
  Assert.IsNotNull(FAuxPerson);
  Assert.AreEqual(FPerson.name, FAuxPerson.name);
end;

procedure TGBJSONTestDeserializePerson.TestObjectLowerCamelCase;
begin
  FreeAndNil(FJSONObject);
  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdLowerCamelCase);

  FUpperPerson.PERSON_ID := 1;
  FUpperPerson.PERSON_NAME := 'Test Person';

  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
                    .ObjectToJsonObject(FUpperPerson);

  Assert.IsNotNull(FJSONObject.GetValue('personId'));
  Assert.IsNotNull(FJSONObject.GetValue('personName'));
end;

procedure TGBJSONTestDeserializePerson.TestObjectUpperCamelCase;
begin
  FreeAndNil(FJSONObject);
  TGBJSONConfig.GetInstance
    .CaseDefinition(TCaseDefinition.cdUpperCamelCase);

  FUpperPerson.PERSON_ID := 1;
  FUpperPerson.PERSON_NAME := 'Test Person';

  FJSONObject := TGBJSONDefault.Deserializer<TUpperPerson>
                    .ObjectToJsonObject(FUpperPerson);

  Assert.IsNotNull(FJSONObject.GetValue('PersonId'));
  Assert.IsNotNull(FJSONObject.GetValue('PersonName'));
end;

end.
