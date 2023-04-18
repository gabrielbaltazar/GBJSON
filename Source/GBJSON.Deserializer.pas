unit GBJSON.Deserializer;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  GBJSON.Interfaces,
  GBJSON.Config,
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

type
  TGBJSONDeserializer<T: class, constructor> = class(TGBJSONBase, IGBJSONDeserializer<T>)
  private
    FUseIgnore: Boolean;

    procedure ProcessOptions(AJsonObject: TJSOnObject);
    function ObjectToJsonString(AObject: TObject; AType: TRttiType): string; overload;
    function ValueToJson(AObject: TObject; AProperty: TRttiProperty): string;
    function ValueListToJson(AObject: TObject; AProperty: TRttiProperty): string;
  public
    class function New(AUseIgnore: Boolean = True): IGBJSONDeserializer<T>;
    constructor Create(AUseIgnore: Boolean = True); reintroduce;
    destructor  Destroy; override;

    function ObjectToJsonString(AValue: TObject): string; overload;
    function ObjectToJsonObject(AValue: TObject): TJSONObject;
    function StringToJsonObject(Avalue: string) : TJSONObject;
    function ListToJSONArray(AValue: TObjectList<T>): TJSONArray;
  end;

implementation

{ TGBJSONDeserializer }

uses
  GBJSON.Helper;

constructor TGBJSONDeserializer<T>.Create(AUseIgnore: Boolean = True);
begin
  inherited Create;
  FUseIgnore := AUseIgnore;
end;

destructor TGBJSONDeserializer<T>.Destroy;
begin
  inherited;
end;

function TGBJSONDeserializer<T>.StringToJsonObject(Avalue: string): TJSONObject;
var
  LJSON: string;
begin
  LJSON := Avalue.Replace(#$D, EmptyStr)
               .Replace(#$A, EmptyStr);

  Result := TJSONObject.ParseJSONValue(LJSON) as TJSONObject;

  if Assigned(Result) then
    ProcessOptions(Result);
end;

function TGBJSONDeserializer<T>.ListToJSONArray(AValue: TObjectList<T>): TJSONArray;
var
  LMyObj: T;
begin
  Result := TJSONArray.Create;
  if Assigned(AValue) then
    for LMyObj in AValue do
    begin
      Result.AddElement(ObjectToJsonObject(LMyObj));
    end;
end;

class function TGBJSONDeserializer<T>.New(AUseIgnore: Boolean = True): IGBJSONDeserializer<T>;
begin
  Result := Self.Create(AUseIgnore);
end;

function TGBJSONDeserializer<T>.ObjectToJsonObject(AValue: TObject): TJSONObject;
var
  LJSONString: string;
begin
  LJSONString := ObjectToJsonString(AValue);
  Result := TJSONObject.ParseJSONValue(LJSONString) as TJSONObject;
  ProcessOptions(Result);
end;

function TGBJSONDeserializer<T>.ObjectToJsonString(AValue: TObject): string;
var
  LType: TRttiType;
begin
  if not Assigned(AValue) then
    Exit('{}');

  LType := TGBRTTI.GetInstance.GetType(AValue.ClassType);
  Result := ObjectToJsonString(AValue, LType);
end;

procedure TGBJSONDeserializer<T>.ProcessOptions(AJsonObject: TJSOnObject);
var
  LPair: TJSONPair;
  LItem: TObject;
  I: Integer;
begin
  if not assigned(AJsonObject) then
    Exit;

  if not TGBJSONConfig.GetInstance.IgnoreEmptyValues then
    Exit;

  for I := AJsonObject.Count -1 downto 0  do
  begin
    LPair := TJSONPair(AJsonObject.Pairs[I]);
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
  LType: TRttiType;
  LMethod: TRttiMethod;
  LValue: TValue;
  I: Integer;
  LJsonValue: string;
begin
  LValue := AProperty.GetValue(AObject);
  if LValue.AsObject = nil then
    Exit('[]');

  LType := TGBRTTI.GetInstance.GetType(LValue.AsObject.ClassType);
  LMethod := LType.GetMethod('ToArray');
  LValue := LMethod.Invoke(LValue.AsObject, []);

  if LValue.GetArrayLength = 0 then
    Exit('[]');

  Result := '[';
  for I := 0 to LValue.GetArrayLength - 1 do
  begin
    if LValue.GetArrayElement(I).IsObject then
      Result := Result + ObjectToJsonString(LValue.GetArrayElement(I).AsObject) + ','
  	else
    begin
      LType := AProperty.GetListType(AObject);
      LJsonValue:= EmptyStr;

      if LType.TypeKind.IsString then
        LJsonValue := '"' + LValue.GetArrayElement(I).AsString + '"'
      else
      if LType.TypeKind.IsInteger then
        LJsonValue := LValue.GetArrayElement(I).AsInteger.ToString
      else
      if LType.TypeKind.IsFloat then
        LJsonValue := LValue.GetArrayElement(I).AsExtended.ToString;

      Result := Result + LJsonValue + ',';
    end;
  end;
  
  Result[Length(Result)] := ']';
end;

function TGBJSONDeserializer<T>.ValueToJson(AObject: TObject; AProperty: TRttiProperty): string;
var
  LValue: TValue;
  LData: TDateTime;
  LType: TRttiType;
  I: Integer;
begin
  LValue := AProperty.GetValue(AObject);
  if AProperty.IsString then
    Exit('"' + LValue.AsString.Replace('\', '\\').Replace('"', '\"') + '"');

  if AProperty.IsInteger then
    Exit(LValue.AsInteger.ToString);

  if AProperty.IsEnum then
    Exit('"' + GetEnumName(AProperty.GetValue(AObject).TypeInfo, AProperty.GetValue(AObject).AsOrdinal) + '"');

  if AProperty.IsFloat then
    Exit(LValue.AsExtended.ToString.Replace(',', '.'));

  if AProperty.IsBoolean then
    Exit(IfThen(LValue.AsBoolean, 'true', 'false'));

  if AProperty.IsArray then
  begin
    if LValue.GetArrayLength = 0 then
      Exit('[]');

    Result := '[';

    LType := AProperty.GetListType(AObject);
    for I := 0 to Pred(LValue.GetArrayLength) do
    begin
      if LType.TypeKind.IsString then
        Result := Result + '"' + LValue.GetArrayElement(I).AsString.Replace('"', '\"') + '"'
      else
      if LType.TypeKind.IsInteger then
        Result := Result + LValue.GetArrayElement(I).AsInteger.ToString
      else
      if LType.TypeKind.IsFloat then
        Result := Result + LValue.GetArrayElement(I).AsExtended.ToString;

      Result := Result + ',';
    end;

    Result[Length(Result)] := ']';
  end;

  if AProperty.IsDateTime then
  begin
    LData := LValue.AsExtended;
    if LData = 0 then
      Exit('""');

    Result := IfThen(FDateTimeFormat.IsEmpty, LData.DateTimeToIso8601, LData.Format(FDateTimeFormat));
    Result := '"' + Result + '"';
    Exit;
  end;

  if AProperty.IsObject then
    Exit(ObjectToJsonString(LValue.AsObject));

  if AProperty.IsList then
    Exit(ValueListToJson(AObject, AProperty));

  if AProperty.IsVariant then
  begin
    if VarType(LValue.AsVariant) = varDate then
    begin
      LData := LValue.AsVariant;
      if LData = 0 then
        Exit('""');

      Result := IfThen(FDateTimeFormat.IsEmpty, LData.DateTimeToIso8601, LData.Format(FDateTimeFormat));
      Result := '"' + Result + '"';
      Exit;
    end;
    Exit('"' + VartoStrDef(LValue.AsVariant, '').Replace('"', '\"') + '"')
  end;
end;

function TGBJSONDeserializer<T>.ObjectToJsonString(AObject: TObject; AType: TRttiType): string;
var
  LProperty: TRttiProperty;
  LFields: TList<string>;
  LName: string;
begin
  Result := '{';
  LFields := TList<string>.create;
  try
    for LProperty in AType.GetProperties do
    begin
    if not LProperty.IsReadable then
      Continue;
      if ((not FUseIgnore) or (not LProperty.IsIgnore(AObject.ClassType)))
      then
      begin
        LName := LProperty.JSONName.ToLower;
        if not LFields.Contains(LName) then
        begin
          Result := Result + Format('"%s":', [LProperty.JSONName]);
          Result := Result + ValueToJson(AObject, LProperty) + ',';
          LFields.Add(LName);
        end;
      end;
    end;
  finally
    LFields.Free;
  end;

  if Result.EndsWith(',') then
    Result[Length(Result)] := '}'
  else
    Result := Result + '}';
end;

end.
