unit GBJSON.Attributes;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.SysUtils;

type
  JSONIgnore = class(TCustomAttribute)
  private
    FIgnoreProperties: TArray<string>;
  public
    constructor Create; overload;
    constructor create(AIgnoreProperties: string); overload;

    property IgnoreProperties: TArray<string> read FIgnoreProperties;
  end;

  JSONProp = class(TCustomAttribute)
  private
    Fname: string;
    FreadOnly: Boolean;
  public
    constructor Create(AName: string; AReadOnly: Boolean = False); overload;
    constructor create(AReadOnly: Boolean; AName: string = ''); overload;

    property name: string read Fname;
    property readOnly: Boolean read FreadOnly;
  end;

implementation

{ JSONIgnore }

constructor JSONIgnore.create(AIgnoreProperties: string);
begin
  FIgnoreProperties := AIgnoreProperties.Split([',']);
end;

constructor JSONIgnore.Create;
begin
  FIgnoreProperties := [];
end;

{ JSONProp }

constructor JSONProp.create(AReadOnly: Boolean; AName: string);
begin
  Fname := AName;
  FReadOnly := AReadOnly;
end;

constructor JSONProp.Create(AName: string; AReadOnly: Boolean);
begin
  Fname := AName;
  FReadOnly := AReadOnly;
end;

end.
