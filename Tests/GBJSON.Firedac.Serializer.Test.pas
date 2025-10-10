unit GBJSON.Firedac.Serializer.Test;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.JSON.Types,
  FireDAC.Comp.Client,
  FireDAC.Phys.MongoDBWrapper,
  FireDAC.Phys.MongoDB,
  FireDAC.Stan.Def,
  DUnitX.TestFramework,
  GBJSON.Config,
  GBJSON.Helper,
  GBJSON.Firedac.Interfaces,
  GBJSON.Firedac.Serializer,
  GBJSON.Firedac.Models.Classes;

type
  [TestFixture]
  TGBJSONFiredacSerializerTest = class
  private
    FRestaurant: TRestaurant;
    FDriver: TFDPhysMongoDriverLink;
    FConnection: TFDConnection;
    FMongoConn: TMongoConnection;
    FSerializer: IGBJSONFDSerializer<TRestaurant>;
    FDocument: TMongoDocument;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure SimpleRestaurant;

    [Test]
    procedure SimpleRestaurantCaseDefinition;
  end;

implementation

{ TGBJSONFiredacSerializerTest }

procedure TGBJSONFiredacSerializerTest.Setup;
begin
  FDocument := nil;
  FRestaurant := nil;
  FConnection := TFDConnection.Create(nil);
  FDriver := TFDPhysMongoDriverLink.Create(nil);
  FConnection.DriverName := 'Mongo';
  FConnection.Params.DriverID := 'Mongo';
  FConnection.Params.Database := 'GBJSON';
  FConnection.Params.Values['Port'] := '27017';
  FConnection.Connected := True;
  FMongoConn := TMongoConnection(FConnection.CliObj);
  Fserializer := TGBJSONFiredacSerializer<TRestaurant>
    .New(FMongoConn);
end;

procedure TGBJSONFiredacSerializerTest.SimpleRestaurant;
begin
  FDocument := FMongoConn.Env.NewDoc;
  FDocument
    .Add('Id', TJsonOid.Create('68d685cff842a913436e24a0'))
    .BeginObject('Address')
      .Add('Street', '2 Avenue')
      .Add('ZipCode', 10075)
      .Add('Building', 1480)
      .BeginArray('Coord')
        .Add('0', -73.9557413)
        .Add('1', 40.7720266)
      .EndArray
    .EndObject
    .Add('Borough', 'Manhattan')
    .Add('Cuisine', 'Italian')
    .BeginArray('Grades')
      .BeginObject('0')
        .Add('Data', EncodeDate(2000, 5, 25))
        .Add('Grade', 'Add')
        .Add('Score', 11)
      .EndObject
      .BeginObject('1')
        .Add('Data', EncodeDate(2005, 6, 2))
        .Add('Grade', 'B')
        .Add('Score', 17)
      .EndObject
    .EndArray
    .Add('Name', 'Vella')
    .Add('RestaurantId', '41704620');

  FRestaurant := FSerializer.DocumentToObject(FDocument);
  Assert.IsNotNull(FRestaurant);
  Assert.AreEqual('68d685cff842a913436e24a0', FRestaurant.Id);
  Assert.AreEqual('41704620', FRestaurant.RestaurantId);
  Assert.AreEqual('Vella', FRestaurant.Name);
  Assert.AreEqual('Manhattan', FRestaurant.Borough);
  Assert.AreEqual('Italian', FRestaurant.Cuisine);
  Assert.AreEqual('2 Avenue', FRestaurant.Address.Street);
  Assert.AreEqual<Integer>(10075, FRestaurant.Address.ZipCode);
  Assert.AreEqual<Double>(1480, FRestaurant.Address.Building);
  Assert.AreEqual(2, FRestaurant.Address.Coord.Count);
  Assert.AreEqual<Double>(-73.9557413, FRestaurant.Address.Coord[0]);
  Assert.AreEqual<Double>(40.7720266, FRestaurant.Address.Coord[1]);
  Assert.AreEqual(2, FRestaurant.Grades.Count);
  Assert.AreEqual<TDateTime>(EncodeDate(2000, 5, 25), FRestaurant.Grades[0].Data);
  Assert.AreEqual('Add', FRestaurant.Grades[0].Grade);
  Assert.AreEqual<Integer>(11, FRestaurant.Grades[0].Score);
  Assert.AreEqual<TDateTime>(EncodeDate(2005, 6, 2), FRestaurant.Grades[1].Data);
  Assert.AreEqual('B', FRestaurant.Grades[1].Grade);
  Assert.AreEqual<Integer>(17, FRestaurant.Grades[1].Score);
end;

procedure TGBJSONFiredacSerializerTest.SimpleRestaurantCaseDefinition;
begin
  FDocument := FMongoConn.Env.NewDoc;
  FDocument
    .BeginObject('address')
      .Add('street', '2 Avenue')
      .Add('zipCode', 10075)
      .Add('building', 1480)
      .BeginArray('coord')
        .Add('0', -73.9557413)
        .Add('1', 40.7720266)
      .EndArray
    .EndObject
    .Add('borough', 'Manhattan')
    .Add('cuisine', 'Italian')
    .BeginArray('grades')
      .BeginObject('0')
        .Add('data', EncodeDate(2000, 5, 25))
        .Add('grade', 'Add')
        .Add('score', 11)
      .EndObject
      .BeginObject('1')
        .Add('data', EncodeDate(2005, 6, 2))
        .Add('grade', 'B')
        .Add('score', 17)
      .EndObject
    .EndArray
    .Add('name', 'Vella')
    .Add('restaurantId', '41704620');

  FRestaurant := FSerializer.CaseDefinition(TCaseDefinition.cdLowerCamelCase).DocumentToObject(FDocument);
  Assert.IsNotNull(FRestaurant);
  Assert.AreEqual('41704620', FRestaurant.RestaurantId);
  Assert.AreEqual('Vella', FRestaurant.Name);
  Assert.AreEqual('Manhattan', FRestaurant.Borough);
  Assert.AreEqual('Italian', FRestaurant.Cuisine);
  Assert.AreEqual('2 Avenue', FRestaurant.Address.Street);
  Assert.AreEqual<Integer>(10075, FRestaurant.Address.ZipCode);
  Assert.AreEqual<Double>(1480, FRestaurant.Address.Building);
  Assert.AreEqual(2, FRestaurant.Address.Coord.Count);
  Assert.AreEqual<Double>(-73.9557413, FRestaurant.Address.Coord[0]);
  Assert.AreEqual<Double>(40.7720266, FRestaurant.Address.Coord[1]);
  Assert.AreEqual(2, FRestaurant.Grades.Count);
  Assert.AreEqual<TDateTime>(EncodeDate(2000, 5, 25), FRestaurant.Grades[0].Data);
  Assert.AreEqual('Add', FRestaurant.Grades[0].Grade);
  Assert.AreEqual<Integer>(11, FRestaurant.Grades[0].Score);
  Assert.AreEqual<TDateTime>(EncodeDate(2005, 6, 2), FRestaurant.Grades[1].Data);
  Assert.AreEqual('B', FRestaurant.Grades[1].Grade);
  Assert.AreEqual<Integer>(17, FRestaurant.Grades[1].Score);
end;

procedure TGBJSONFiredacSerializerTest.TearDown;
begin
  FRestaurant.Free;
  FDocument.Free;
  FConnection.Free;
  FDriver.Free;
end;

end.
