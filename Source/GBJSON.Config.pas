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
    FIgnoreEmptyValues: Boolean;

    constructor CreatePrivate;
  public
    constructor Create;
    destructor Destroy; override;

    function CaseDefinition(Value: TCaseDefinition): TGBJSONConfig; overload;
    function CaseDefinition: TCaseDefinition; overload;

    function IgnoreEmptyValues(AValue: Boolean): TGBJSONConfig; overload;
    function IgnoreEmptyValues: Boolean; overload;

    class function GetInstance: TGBJSONConfig;
    class destructor UnInitialize;
  end;

implementation

{ TGBJSONConfig }

function TGBJSONConfig.CaseDefinition(Value: TCaseDefinition): TGBJSONConfig;
begin
  Result := Self;
  FCaseDefinition := Value;
end;

function TGBJSONConfig.CaseDefinition: TCaseDefinition;
begin
  Result := FCaseDefinition;
end;

constructor TGBJSONConfig.Create;
begin
  raise Exception.Create('Invoke the GetInstance Method.');
end;

constructor TGBJSONConfig.CreatePrivate;
begin
  FIgnoreEmptyValues := True;
end;

destructor TGBJSONConfig.Destroy;
begin

  inherited;
end;

class function TGBJSONConfig.GetInstance: TGBJSONConfig;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TGBJSONConfig.CreatePrivate;
    FInstance
      .CaseDefinition(cdNone)
      .IgnoreEmptyValues(True);
  end;
  Result := FInstance;
end;

function TGBJSONConfig.IgnoreEmptyValues: Boolean;
begin
  Result := FIgnoreEmptyValues;
end;

function TGBJSONConfig.IgnoreEmptyValues(AValue: Boolean): TGBJSONConfig;
begin
  Result := Self;
  FIgnoreEmptyValues := AValue;
end;

class destructor TGBJSONConfig.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.
