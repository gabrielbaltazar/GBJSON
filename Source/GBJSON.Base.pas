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

    procedure DateTimeFormat(AValue: string);
  end;

implementation

{ TGBJSONBase }

constructor TGBJSONBase.Create;
begin
  FDateTimeFormat := EmptyStr;
end;

procedure TGBJSONBase.DateTimeFormat(AValue: string);
begin
  FDateTimeFormat := AValue;
end;

end.
