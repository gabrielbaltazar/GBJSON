unit GBJSON.Firedac.Deserializer.Test;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  FireDAC.Comp.Client,
  FireDAC.Phys.MongoDBWrapper,
  FireDAC.Phys.MongoDB,
  FireDAC.Stan.Def,
  DUnitX.TestFramework,
  GBJSON.Config,
  GBJSON.Helper,
  GBJSON.Firedac.Interfaces,
  GBJSON.Firedac.Deserializer;

type
  TAddress = class
  private
    FStreet: string;
    FZipCode: Integer;
    FBuilding: Double;
    FCoord: TList<Double>;
  public
    constructor Create;
    destructor Destroy; override;

    property Street: string read FStreet write FStreet;
    property ZipCode: Integer read FZipCode write FZipCode;
    property Building: Double read FBuilding write FBuilding;
    property Coord: TList<Double> read FCoord write FCoord;
  end;

  TGrade = class
  private
    FData: TDateTime;
    FGrade: string;
    FScore: Integer;
  public
    property Data: TDateTime read FData write FData;
    property Grade: string read FGrade write FGrade;
    property Score: Integer read FScore write FScore;
  end;

  TRestaurant = class
  private
    FRestaurantId: string;
    FName: string;
    FBorough: string;
    FCuisine: string;
    FAddress: TAddress;
    FGrades: TObjectList<TGrade>;
  public
    constructor Create;
    destructor Destroy; override;

    property RestaurantId: string read FRestaurantId write FRestaurantId;
    property Name: string read FName write FName;
    property Borough: string read FBorough write FBorough;
    property Cuisine: string read FCuisine write FCuisine;
    property Address: TAddress read FAddress write FAddress;
    property Grades: TObjectList<TGrade> read FGrades write FGrades;
  end;

  [TestFixture]
  TGBJSONFiredacDeserializerTest = class
  private
    FRestaurant: TRestaurant;
    FDriver: TFDPhysMongoDriverLink;
    FConnection: TFDConnection;
    FMongoConn: TMongoConnection;
    FDeserializer: IGBJSONFDDeserializer<TRestaurant>;
    FDocument: TMongoDocument;

    function CreateSimpleRestaurant: TRestaurant;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure SimpleRestaurant;

    [Test]
    procedure SimpleRestaurantCaseDefinition;

    [Test]
    procedure ListRestaurants;
  end;

implementation

{ TAddress }

constructor TAddress.Create;
begin
  FCoord := TList<Double>.Create;
end;

destructor TAddress.Destroy;
begin
  FCoord.Free;
  inherited;
end;

{ TRestaurant }

constructor TRestaurant.Create;
begin
  FAddress := TAddress.Create;
  FGrades := TObjectList<TGrade>.Create;
end;

destructor TRestaurant.Destroy;
begin
  FAddress.Free;
  FGrades.Free;
  inherited;
end;

{ TGBJSONFiredacDeserializerTest }

function TGBJSONFiredacDeserializerTest.CreateSimpleRestaurant: TRestaurant;
begin
  Result := TRestaurant.Create;
  Result.RestaurantId := '41704620';
  Result.Name := 'Vella';
  Result.Borough := 'Manhattan';
  Result.Cuisine := 'Italian';
  Result.Address.Street := '2 Avenue';
  Result.Address.ZipCode := 10075;
  Result.Address.Building := 1480;
  Result.Address.Coord.Add(-73.9557413);
  Result.Address.Coord.Add(40.7720266);
  Result.Grades.Add(TGrade.Create);
  Result.Grades.Last.Data := EncodeDate(2000, 5, 25);
  Result.Grades.Last.Grade := 'Add';
  Result.Grades.Last.Score := 11;
  Result.Grades.Add(TGrade.Create);
  Result.Grades.Last.Data := EncodeDate(2005, 6, 2);
  Result.Grades.Last.Grade := 'B';
  Result.Grades.Last.Score := 17;
end;

procedure TGBJSONFiredacDeserializerTest.ListRestaurants;
var
  LList: TObjectList<TRestaurant>;
  LJSON: TJSONObject;
  LJSONArray: TJSONArray;
begin
  LList := TObjectList<TRestaurant>.Create;
  LList.Add(CreateSimpleRestaurant);
  LList.Add(CreateSimpleRestaurant);
  LList.Last.RestaurantId := '555';

  FDocument := FDeserializer.ListToMongoDocument('list', LList);
  LJSON := TJSONObject.ParseJSONValue(FDocument.AsJSON) as TJSONObject;
  LJSONArray := LJSON.ValueAsJSONArray('list');
  Assert.AreEqual(2, LJSONArray.Count);
  Assert.AreEqual('41704620', LJSONArray.ItemAsString(0, 'RestaurantId'));
  Assert.AreEqual('555', LJSONArray.ItemAsString(1, 'RestaurantId'));
  LJSON.Free;
  LList.Free;
end;

procedure TGBJSONFiredacDeserializerTest.Setup;
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
  FDeserializer := TGBJSONFiredacDeserializer<TRestaurant>
    .New(FMongoConn);
end;

procedure TGBJSONFiredacDeserializerTest.SimpleRestaurant;
var
  LJSON: TJSONObject;
begin
  FRestaurant := CreateSimpleRestaurant;

  FDocument := FDeserializer.ObjectToMongoDocument(FRestaurant);
  LJSON := TJSONObject.ParseJSONValue(FDocument.AsJSON) as TJSONObject;

  Assert.IsNotNull(LJSON);
  Assert.AreEqual('Vella', LJSON.ValueAsString('Name'));
  Assert.AreEqual('41704620', LJSON.ValueAsString('RestaurantId'));
  Assert.AreEqual<Integer>(10075, LJSON.ValueAsJSONObject('Address').ValueAsInteger('ZipCode'));
  Assert.AreEqual<Double>(1480, LJSON.ValueAsJSONObject('Address').ValueAsInteger('Building'));
  Assert.AreEqual(2, LJSON.ValueAsJSONObject('Address').ValueAsJSONArray('Coord').Count);

  LJSON.Free;
end;

procedure TGBJSONFiredacDeserializerTest.SimpleRestaurantCaseDefinition;
var
  LJSON: TJSONObject;
begin
  FRestaurant := CreateSimpleRestaurant;

  FDocument := FDeserializer.CaseDefinition(TCaseDefinition.cdLowerCamelCase)
    .ObjectToMongoDocument(FRestaurant);
  LJSON := TJSONObject.ParseJSONValue(FDocument.AsJSON) as TJSONObject;

  Assert.IsNotNull(LJSON);
  Assert.AreEqual('Vella', LJSON.ValueAsString('name'));
  Assert.AreEqual('41704620', LJSON.ValueAsString('restaurantId'));
  Assert.AreEqual<Integer>(10075, LJSON.ValueAsJSONObject('address').ValueAsInteger('zipCode'));
  Assert.AreEqual<Double>(1480, LJSON.ValueAsJSONObject('address').ValueAsInteger('building'));
  Assert.AreEqual(2, LJSON.ValueAsJSONObject('address').ValueAsJSONArray('coord').Count);

  LJSON.Free;
end;

procedure TGBJSONFiredacDeserializerTest.TearDown;
begin
  FRestaurant.Free;
  FDocument.Free;
  FConnection.Free;
  FDriver.Free;
end;

end.
