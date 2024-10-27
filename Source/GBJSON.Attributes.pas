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
    constructor Create(AIgnoreProperties: string); overload;

    property IgnoreProperties: TArray<string> read FIgnoreProperties;
  end;

  JSONProp = class(TCustomAttribute)
  private
    FName: string;
    FReadOnly: Boolean;
  public
    constructor Create(AName: string; AReadOnly: Boolean = False); overload;
    constructor create(AReadOnly: Boolean; AName: string = ''); overload;

    property Name: string read FName;
    property ReadOnly: Boolean read FReadOnly;
  end;

implementation

{ JSONIgnore }

constructor JSONIgnore.Create(AIgnoreProperties: string);
begin
  FIgnoreProperties := AIgnoreProperties.Split([',']);
end;

constructor JSONIgnore.Create;
begin
  FIgnoreProperties := [];
end;

{ JSONProp }

constructor JSONProp.Create(AReadOnly: Boolean; AName: string);
begin
  FName := AName;
  FReadOnly := AReadOnly;
end;

constructor JSONProp.Create(AName: string; AReadOnly: Boolean);
begin
  FName := AName;
  FReadOnly := AReadOnly;
end;

end.
