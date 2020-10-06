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

end.
