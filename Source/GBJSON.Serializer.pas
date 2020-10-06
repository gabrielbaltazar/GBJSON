unit GBJSON.Serializer;

interface

uses
  GBJSON.Interfaces,
  GBJSON.Base,
  GBJSON.RTTI,
  GBJSON.DateTime.Helper,
  System.Generics.Collections,
  System.Rtti,
  System.JSON,
  System.Math,
  System.SysUtils,
  System.StrUtils,
  System.TypInfo;

type TGBJSONSerializer<T: class, constructor> = class(TGBJSONBase, IGBJSONSerializer<T>)

  private
    FUseIgnore: Boolean;

    procedure jsonObjectToObject    (AObject: TObject; AJsonObject: TJSONObject; AType: TRttiType); overload;
    procedure jsonObjectToObjectList(AObject: TObject; AJsonArray: TJSONArray; AProperty: TRttiProperty);
  public
    procedure JsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject); overload;
    function  JsonObjectToObject(AJsonObject: TJSONObject): T; overload;
    function  JsonStringToObject(AJsonString: String): T;
    function  JsonArrayToList(Value: TJSONArray): TObjectList<T>;
    function  JsonStringToList(Value: String): TObjectList<T>;

    class function New(bUseIgnore: Boolean): IGBJSONSerializer<T>;
    constructor create(bUseIgnore: Boolean = True); reintroduce;
    destructor  Destroy; override;
end;

implementation

{ TGBJSONSerializer }

constructor TGBJSONSerializer<T>.create(bUseIgnore: Boolean);
begin
  inherited create;
  FUseIgnore := bUseIgnore;
end;

destructor TGBJSONSerializer<T>.Destroy;
begin

  inherited;
end;

function TGBJSONSerializer<T>.JsonArrayToList(Value: TJSONArray): TObjectList<T>;
var
  i: Integer;
begin
  result := TObjectList<T>.Create;

  for i := 0 to Pred(Value.Count) do
    Result.Add(JsonObjectToObject(TJSONObject(Value.Items[i])));
end;

procedure TGBJSONSerializer<T>.jsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject; AType: TRttiType);
var
  rttiProperty: TRttiProperty;
  jsonValue   : TJSONValue;
  date        : TDateTime;
  enumValue   : Integer;
  boolValue   : Boolean;
begin
  for rttiProperty in AType.GetProperties do
  begin
    if (FUseIgnore) and (rttiProperty.IsIgnore(AObject.ClassType)) then
      Continue;

    jsonValue := AJsonObject.Values[rttiProperty.Name];

    if (not Assigned(jsonValue)) or (not rttiProperty.IsWritable) then
      Continue;

    if rttiProperty.IsString then
    begin
      rttiProperty.SetValue(AObject, jsonValue.Value);
      Continue;
    end;

    if rttiProperty.IsVariant then
    begin
      rttiProperty.SetValue(AObject, jsonValue.Value);
      Continue;
    end;

    if rttiProperty.IsInteger then
    begin
      rttiProperty.SetValue(AObject, jsonValue.Value.ToInteger);
      Continue;
    end;

    if rttiProperty.IsEnum then
    begin
      enumValue := GetEnumValue(rttiProperty.GetValue(AObject).TypeInfo, jsonValue.Value);
      rttiProperty.SetValue(AObject,
        TValue.FromOrdinal(rttiProperty.GetValue(AObject).TypeInfo, enumValue));
      Continue;
    end;

    if rttiProperty.IsObject then
    begin
      JsonObjectToObject(rttiProperty.GetValue(AObject).AsObject, TJSONObject(jsonValue));
      Continue;
    end;

    if rttiProperty.IsFloat then
    begin
      rttiProperty.SetValue(AObject, TValue.From<Double>(jsonValue.Value.ToDouble));
      Continue;
    end;

    if rttiProperty.IsDateTime then
    begin
      date.fromIso8601ToDateTime(jsonValue.Value);
      rttiProperty.SetValue(AObject, TValue.From<TDateTime>(date));
      Continue;
    end;

    if rttiProperty.IsList then
    begin
      jsonObjectToObjectList(AObject, TJSONArray(jsonValue), rttiProperty);
      Continue;
    end;

    if rttiProperty.IsBoolean then
    begin
      boolValue := jsonValue.Value.ToLower.Equals('true');
      rttiProperty.SetValue(AObject, TValue.From<Boolean>(boolValue));
      Continue;
    end;
  end;
end;

procedure TGBJSONSerializer<T>.jsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject);
var
  rttiType: TRttiType;
begin
  if (not Assigned(AObject)) or (not Assigned(AJsonObject)) then
    exit;

  rttiType := TGBRTTI.GetInstance.GetType(AObject.ClassType);

  JsonObjectToObject(AObject, AJsonObject, rttiType);
end;

function TGBJSONSerializer<T>.JsonObjectToObject(AJsonObject: TJSONObject): T;
begin
  result := T.create;
  JsonObjectToObject(Result, AJsonObject);
end;

procedure TGBJSONSerializer<T>.jsonObjectToObjectList(AObject: TObject; AJsonArray: TJSONArray; AProperty: TRttiProperty);
var
  i          : Integer;
  objectItem : TObject;
  listType   : TRttiType;
begin
  if not Assigned(AJsonArray) then
    Exit;

  listType := AProperty.GetListType(AObject);
  for i := 0 to Pred(AJsonArray.Count) do
  begin
    objectItem := listType.AsInstance.MetaclassType.Create;
    objectItem.invokeMethod('create', []);

    Self.JsonObjectToObject(objectItem, TJSONObject(AJsonArray.Items[i]));
    AProperty.GetValue(AObject).AsObject.InvokeMethod('Add', [objectItem]);
  end;
end;

function TGBJSONSerializer<T>.JsonStringToList(Value: String): TObjectList<T>;
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONObject.ParseJSONValue(Value) as TJSONArray;
  try
    result := JsonArrayToList(jsonArray);
  finally
    jsonArray.Free;
  end;
end;

function TGBJSONSerializer<T>.JsonStringToObject(AJsonString: String): T;
var
  json: TJSONObject;
begin
  result := nil;
  json   := TJSONObject.ParseJSONValue(AJsonString) as TJSONObject;
  try
    if Assigned(json) then
      result := Self.JsonObjectToObject(json);
  finally
    json.Free;
  end;
end;

class function TGBJSONSerializer<T>.New(bUseIgnore: Boolean): IGBJSONSerializer<T>;
begin
  result := Self.create(bUseIgnore);
end;

end.
