unit GBJSON.Attributes;

interface

uses
  System.SysUtils;

type
  JSONIgnore = class(TCustomAttribute)
  private
    FIgnoreProperties: TArray<String>;
  public
    property IgnoreProperties: TArray<String> read FIgnoreProperties;

    constructor create; overload;
    constructor create(AIgnoreProperties: String); overload;
  end;

  JSONProp = class(TCustomAttribute)
  private
    Fname: String;
    FreadOnly: Boolean;
  public
    property name: String read Fname;
    property readOnly: Boolean read FreadOnly;

    constructor create(AName: String; bReadOnly: Boolean = false); overload;
    constructor create(bReadOnly: Boolean; AName: String = ''); overload;
  end;

implementation

{ JSONIgnore }

constructor JSONIgnore.create(AIgnoreProperties: String);
begin
  FIgnoreProperties := AIgnoreProperties.Split([',']);
end;

constructor JSONIgnore.create;
begin
  FIgnoreProperties := [];
end;

{ JSONProp }

constructor JSONProp.create(bReadOnly: Boolean; AName: String);
begin
  Fname := AName;
  FReadOnly := bReadOnly;
end;

constructor JSONProp.create(AName: String; bReadOnly: Boolean);
begin
  Fname := AName;
  FReadOnly := bReadOnly;
end;

end.
