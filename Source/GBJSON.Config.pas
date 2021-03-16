unit GBJSON.Config;

interface

uses
  System.SysUtils;

type
  TCaseDefinition = (cdNone, cdLower, cdUpper, cdLowerCamelCase);

  TGBJSONConfig = class
  private
    class var FInstance: TGBJSONConfig;

    FCaseDefinition: TCaseDefinition;

    constructor createPrivate;
  public
    constructor Create;
    destructor Destroy; override;

    function CaseDefinition(Value: TCaseDefinition): TGBJSONConfig; overload;
    function CaseDefinition: TCaseDefinition; overload;

    class function GetInstance: TGBJSONConfig;
    class destructor UnInitialize;
  end;

implementation

{ TGBJSONConfig }

function TGBJSONConfig.CaseDefinition(Value: TCaseDefinition): TGBJSONConfig;
begin
  result := Self;
  FCaseDefinition := Value;
end;

function TGBJSONConfig.CaseDefinition: TCaseDefinition;
begin
  result := FCaseDefinition;
end;

constructor TGBJSONConfig.Create;
begin
  raise Exception.Create('Invoke the GetInstance Method.');
end;

constructor TGBJSONConfig.createPrivate;
begin

end;

destructor TGBJSONConfig.Destroy;
begin

  inherited;
end;

class function TGBJSONConfig.GetInstance: TGBJSONConfig;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TGBJSONConfig.createPrivate;
    FInstance.CaseDefinition(cdNone);
  end;
  Result := FInstance;
end;

class destructor TGBJSONConfig.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.
