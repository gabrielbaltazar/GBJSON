unit GBJSON.Test.DataSet.Serializer;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.DataSet.Interfaces,
  GBJSON.DataSet.Serializer,
  System.Generics.Collections,
  System.SysUtils,
  Datasnap.DBClient,
  Data.DB;

type
  [TestFixture]
  TGBJSONTestDataSetSerializer = class
  private
    FDataSet: TClientDataSet;
    FPerson: TPerson;
    FPersons: TObjectList<TPerson>;
    FSerializer: IGBJSONDataSetSerializer<TPerson>;

  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure CreateFields;

    [Test]
    procedure FillObject;

    [Test]
    procedure ObjectListTest;

    [Test]
    procedure ObjectNil;

  end;

implementation

{ TGBJSONTestDataSetSerializer }

procedure TGBJSONTestDataSetSerializer.CreateFields;
begin
  FSerializer.ObjectToDataSet(FPerson, FDataSet);
  Assert.IsTrue(FDataSet.Active);
  Assert.AreEqual(9, FDataSet.FieldCount)
end;

procedure TGBJSONTestDataSetSerializer.FillObject;
begin
  FSerializer.ObjectToDataSet(FPerson, FDataSet);
  Assert.IsTrue(FDataSet.Active);
  Assert.AreEqual(9, FDataSet.FieldCount);
  Assert.AreEqual<Double>(1, FDataSet.FieldByName('idPerson').AsFloat);
  Assert.AreEqual<string>('Teste', FDataSet.FieldByName('name').AsString);
  Assert.AreEqual<Integer>(18, FDataSet.FieldByName('age').AsInteger);
  Assert.AreEqual<Double>(10, FDataSet.FieldByName('average').AsFloat);
  Assert.IsTrue(FDataSet.FieldByName('creationDate').AsDateTime > 0);
end;

procedure TGBJSONTestDataSetSerializer.ObjectListTest;
begin
  FPersons.Add(TPerson.CreatePerson);
  FPersons.Add(TPerson.CreatePerson);

  FSerializer.ObjectListToDataSet(FPersons, FDataSet);

  Assert.IsTrue(FDataSet.Active);
  Assert.AreEqual(9, FDataSet.FieldCount);
  Assert.AreEqual(2, FDataSet.RecordCount);
end;

procedure TGBJSONTestDataSetSerializer.ObjectNil;
begin
  FSerializer.ObjectToDataSet(nil, FDataSet);
  Assert.IsTrue(FDataSet.Active);
  Assert.AreEqual(9, FDataSet.FieldCount);
  Assert.AreEqual(0, FDataSet.RecordCount);
end;

procedure TGBJSONTestDataSetSerializer.Setup;
begin
  FDataSet := TClientDataSet.Create(nil);
  FPerson := TPerson.CreatePerson;
  FPersons := TObjectList<TPerson>.create;
  FSerializer := TGBJSONDataSetSerializer<TPerson>.new;
end;

procedure TGBJSONTestDataSetSerializer.TearDown;
begin
  FDataSet.Free;
  FPerson.Free;
  FPersons.Free;
end;

end.
