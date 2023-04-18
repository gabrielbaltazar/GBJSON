unit GBJSON.Config;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

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
    class function GetInstance: TGBJSONConfig;
    class destructor UnInitialize;

    function CaseDefinition(AValue: TCaseDefinition): TGBJSONConfig; overload;
    function CaseDefinition: TCaseDefinition; overload;

    function IgnoreEmptyValues(AValue: Boolean): TGBJSONConfig; overload;
    function IgnoreEmptyValues: Boolean; overload;
  end;

implementation

{ TGBJSONConfig }

function TGBJSONConfig.CaseDefinition(AValue: TCaseDefinition): TGBJSONConfig;
begin
  Result := Self;
  FCaseDefinition := AValue;
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
