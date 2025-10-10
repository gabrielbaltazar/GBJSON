unit GBJSON.Firedac.Models.Classes;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  GBJSON.Attributes;

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
    FId: string;
  public
    constructor Create;
    destructor Destroy; override;

    [MongoId]
    property Id: string read FId write FId;
    property RestaurantId: string read FRestaurantId write FRestaurantId;
    property Name: string read FName write FName;
    property Borough: string read FBorough write FBorough;
    property Cuisine: string read FCuisine write FCuisine;
    property Address: TAddress read FAddress write FAddress;
    property Grades: TObjectList<TGrade> read FGrades write FGrades;
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

end.
