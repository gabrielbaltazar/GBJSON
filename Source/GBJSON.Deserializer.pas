unit GBJSON.Deserializer;

interface

uses
  GBJSON.Interfaces,
  GBJSON.Base,
  GBJSON.RTTI,
  GBJSON.DateTime.Helper,
  System.Rtti,
  System.JSON,
  System.SysUtils,
  System.Generics.Collections,
  System.StrUtils,
  System.Variants,
  System.TypInfo;

type TGBJSONDeserializer<T: class, constructor> = class(TGBJSONBase, IGBJSONDeserializer<T>)

  private
    FUseIgnore: Boolean;

    procedure ProcessOptions(AJsonObject: TJSOnObject);

    function ObjectToJsonString(AObject: TObject; AType: TRttiType): string; overload;

    function ValueToJson    (AObject: TObject; AProperty: TRttiProperty): string;
    function ValueListToJson(AObject: TObject; AProperty: TRttiProperty): string;

  public
    function ObjectToJsonString(Value: TObject): string; overload;
    function ObjectToJsonObject(Value: TObject): TJSONObject;
    function StringToJsonObject(value: string) : TJSONObject;

    function ListToJSONArray(Value: TObjectList<T>): TJSONArray;

    class function New(bUseIgnore: Boolean = True): IGBJSONDeserializer<T>;
    constructor create(bUseIgnore: Boolean = True); reintroduce;
    destructor  Destroy; override;
end;

implementation

{ TGBJSONDeserializer }

uses
  GBJSON.Helper;

constructor TGBJSONDeserializer<T>.create(bUseIgnore: Boolean = True);
begin
  inherited create;
  FUseIgnore := bUseIgnore;
end;

destructor TGBJSONDeserializer<T>.Destroy;
begin

  inherited;
end;

function TGBJSONDeserializer<T>.StringToJsonObject(value: string): TJSONObject;
var
  json : string;
begin
  json := value.Replace(#$D, EmptyStr)
               .Replace(#$A, EmptyStr);

  result := TJSONObject.ParseJSONValue(json) as TJSONObject;

  if Assigned(Result) then
    ProcessOptions(Result);
end;

function TGBJSONDeserializer<T>.ListToJSONArray(Value: TObjectList<T>): TJSONArray;
var
  myObj: T;
begin
  result := TJSONArray.Create;

  if Assigned(Value) then
    for myObj in Value do
    begin
      result.AddElement(ObjectToJsonObject(myObj));
    end;
end;

class function TGBJSONDeserializer<T>.New(bUseIgnore: Boolean = True): IGBJSONDeserializer<T>;
begin
  result := Self.create(bUseIgnore);
end;

function TGBJSONDeserializer<T>.ObjectToJsonObject(Value: TObject): TJSONObject;
var
  jsonString: string;
begin
  jsonString := ObjectToJsonString(Value);
  result     := TJSONObject.ParseJSONValue(jsonString) as TJSONObject;

  ProcessOptions(Result);
end;

function TGBJSONDeserializer<T>.ObjectToJsonString(Value: TObject): string;
var
  rttiType: TRttiType;
begin
  if not Assigned(Value) then
    Exit('{}');

  rttiType := TGBRTTI.GetInstance.GetType(Value.ClassType);

  result := ObjectToJsonString(Value, rttiType);
end;

procedure TGBJSONDeserializer<T>.ProcessOptions(AJsonObject: TJSOnObject);
var
  LPair: TJSONPair;
  LItem: TObject;
  i: Integer;
  
begin
  if not assigned(AJsonObject) then
    Exit;

  for i := AJsonObject.Count -1 downto 0  do
  begin
    LPair := TJSONPair(AJsonObject.Pairs[i]);
    if LPair.JsonValue is TJSOnObject then
    begin
      ProcessOptions(TJSOnObject(LPair.JsonValue));
      if LPair.JsonValue.ToString.Equals('{}') then
      begin
        AJsonObject.RemovePair(LPair.JsonString.Value).DisposeOf;
        Continue;
      end;
    end
    else if LPair.JsonValue is TJSONArray then
    begin
      if (TJSONArray(LPair.JsonValue).Count = 0) then
      begin
        AJsonObject.RemovePair(LPair.JsonString.Value).DisposeOf;
      end
      else
        for LItem in TJSONArray(LPair.JsonValue) do
        begin
          if LItem is TJSOnObject then
            ProcessOptions(TJSOnObject(LItem));
        end;
    end
    else
    begin
      if (LPair.JsonValue.value = '') or (LPair.JsonValue.ToJSON = '0') then
      begin
        AJsonObject.RemovePair(LPair.JsonString.Value).DisposeOf;
      end;
    end;
  end;
end;

function TGBJSONDeserializer<T>.ValueListToJson(AObject: TObject; AProperty: TRttiProperty): string;
var
  rttiType: TRttiType;
  method  : TRttiMethod;
  value   : TValue;
  i       : Integer;
begin
  value := AProperty.GetValue(AObject);

  if value.AsObject = nil then
    Exit('[]');

  rttiType := TGBRTTI.GetInstance.GetType(value.AsObject.ClassType);

  method   := rttiType.GetMethod('ToArray');
  value    := method.Invoke(value.AsObject, []);

  if value.GetArrayLength = 0 then
    Exit('[]');

  result := '[';
  for i := 0 to value.GetArrayLength - 1 do
  begin
    if value.GetArrayElement(i).IsObject then
      result := Result + ObjectToJsonString(value.GetArrayElement(i).AsObject) + ','
	else
	  result := Result + '"' + (value.GetArrayElement(i).AsString) + '"' + ',';
  end;
  
  result[Length(Result)] := ']';
end;

function TGBJSONDeserializer<T>.ValueToJson(AObject: TObject; AProperty: TRttiProperty): string;
var
  value : TValue;
  data  : TDateTime;
begin
  value := AProperty.GetValue(AObject);

  if AProperty.IsString then
    Exit('"' + Value.AsString.Replace('\', '\\') + '"');

  if AProperty.IsInteger then
    Exit(value.AsInteger.ToString);

  if AProperty.IsEnum then
    Exit('"' + GetEnumName(AProperty.GetValue(AObject).TypeInfo, AProperty.GetValue(AObject).AsOrdinal) + '"');

  if AProperty.IsFloat then
    Exit(value.AsExtended.ToString.Replace(',', '.'));

  if AProperty.IsBoolean then
    Exit(IfThen(value.AsBoolean, 'true', 'false'));

  if AProperty.IsDateTime then
  begin
    data := value.AsExtended;
    if data = 0 then
      Exit('""');

    result := IfThen(FDateTimeFormat.IsEmpty, data.DateTimeToIso8601, data.Format(FDateTimeFormat));
    result := '"' + result + '"';
    Exit;
  end;

  if AProperty.IsObject then
    Exit(ObjectToJsonString(value.AsObject));

  if AProperty.IsList then
    Exit(ValueListToJson(AObject, AProperty));

  if AProperty.IsVariant then
  begin
    if VarType(value.AsVariant) = varDate then
    begin
      data := value.AsVariant;
      if data = 0 then
        Exit('""');

      result := IfThen(FDateTimeFormat.IsEmpty, data.DateTimeToIso8601, data.Format(FDateTimeFormat));
      result := '"' + result + '"';
      Exit;
    end;
    Exit('"' + VartoStrDef(value.AsVariant, '') + '"')
  end;
end;

function TGBJSONDeserializer<T>.ObjectToJsonString(AObject: TObject; AType: TRttiType): string;
var
  rttiProperty: TRttiProperty;
begin
  result := '{';

  for rttiProperty in AType.GetProperties do
  begin
    if ( (not FUseIgnore) or (not rttiProperty.IsIgnore(AObject.ClassType))) and
       (not rttiProperty.IsEmpty(AObject))
    then
    begin
      result := result + Format('"%s":', [rttiProperty.Name]);
      result := result + ValueToJson(AObject, rttiProperty) + ',';
    end;
  end;

  if Result.EndsWith(',') then
    Result[Length(Result)] := '}'
  else
    Result := Result + '}';
end;

end.
