unit GBJSON.Base;

interface

uses
  System.SysUtils;

type TGBJSONBase = class(TInterfacedObject)

  protected
    FDateTimeFormat: String;

  public
    procedure DateTimeFormat(Value: String);

    constructor create; virtual;
    destructor  Destroy; override;
end;

implementation

{ TGBJSONBase }

constructor TGBJSONBase.create;
begin
  FDateTimeFormat := EmptyStr;
end;

procedure TGBJSONBase.DateTimeFormat(Value: String);
begin
  FDateTimeFormat := Value;
end;

destructor TGBJSONBase.Destroy;
begin

  inherited;
end;

end.
