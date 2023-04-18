unit GBJSON.Base;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.SysUtils;

type
  TGBJSONBase = class(TInterfacedObject)
  protected
    FDateTimeFormat: String;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure DateTimeFormat(AValue: String);
  end;

implementation

{ TGBJSONBase }

constructor TGBJSONBase.Create;
begin
  FDateTimeFormat := EmptyStr;
end;

procedure TGBJSONBase.DateTimeFormat(AValue: String);
begin
  FDateTimeFormat := AValue;
end;

destructor TGBJSONBase.Destroy;
begin
  inherited;
end;

end.
