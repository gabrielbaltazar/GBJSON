unit GBJSON.Firedac.Deserializer.Test;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Phys.MongoDBWrapper,
  FireDAC.Phys.MongoDB,
  FireDAC.Stan.Def,
  DUnitX.TestFramework,
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
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure SimpleRestaurant;
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

procedure TGBJSONFiredacDeserializerTest.Setup;
begin
  FDocument := nil;
  FRestaurant := TRestaurant.Create;
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
  LJSON: string;
begin
  FRestaurant.RestaurantId := '41704620';
  FRestaurant.Name := 'Vella';
  FRestaurant.Borough := 'Manhattan';
  FRestaurant.Cuisine := 'Italian';
  FRestaurant.Address.Street := '2 Avenue';
  FRestaurant.Address.ZipCode := 10075;
  FRestaurant.Address.Building := 1480;
  FRestaurant.Address.Coord.Add(-73.9557413);
  FRestaurant.Address.Coord.Add(40.7720266);
  FRestaurant.Grades.Add(TGrade.Create);
  FRestaurant.Grades.Last.Data := EncodeDate(2000, 5, 25);
  FRestaurant.Grades.Last.Grade := 'Add';
  FRestaurant.Grades.Last.Score := 11;
  FRestaurant.Grades.Add(TGrade.Create);
  FRestaurant.Grades.Last.Data := EncodeDate(2005, 6, 2);
  FRestaurant.Grades.Last.Grade := 'B';
  FRestaurant.Grades.Last.Score := 17;

  FDocument := FDeserializer.ObjectToMongoDocument(FRestaurant);
  LJSON := FDocument.AsJSON;
  Assert.IsNotEmpty(LJSON);
end;

procedure TGBJSONFiredacDeserializerTest.TearDown;
begin
  FRestaurant.Free;
  FDocument.Free;
  FDriver.Free;
end;

end.
