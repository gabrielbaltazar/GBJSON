unit GBJSON.Serializer;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.Generics.Collections,
  System.Rtti,
  System.JSON,
  System.Math,
  System.SysUtils,
  System.StrUtils,
  System.TypInfo,
  GBJSON.Interfaces,
  GBJSON.Base,
  GBJSON.RTTI,
  GBJSON.DateTime.Helper;

type
  TGBJSONSerializer<T: class, constructor> = class(TGBJSONBase, IGBJSONSerializer<T>)
  private
    FUseIgnore: Boolean;

    procedure SetValueArray(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
    procedure SetValueBool(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
    procedure SetValueDate(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
    procedure SetValueFloat(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
    procedure SetValueEnum(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
    procedure SetValueStr(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);

    procedure JsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject; AType: TRttiType); overload;
    procedure JsonObjectToObjectList(AObject: TObject; AJsonArray: TJSONArray; AProperty: TRttiProperty);
  public
    class function New(AUseIgnore: Boolean): IGBJSONSerializer<T>;
    constructor Create(AUseIgnore: Boolean = True); reintroduce;

    procedure JsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject); overload;
    function JsonObjectToObject(AJsonObject: TJSONObject): T; overload;
    function JsonStringToObject(AJsonString: string): T;
    function JsonArrayToList(AValue: TJSONArray): TObjectList<T>;
    function JsonStringToList(AValue: string): TObjectList<T>;
  end;

implementation

uses
  GBJSON.Attributes;

{ TGBJSONSerializer }

constructor TGBJSONSerializer<T>.Create(AUseIgnore: Boolean);
begin
  inherited Create;
  FUseIgnore := AUseIgnore;
end;

function TGBJSONSerializer<T>.JsonArrayToList(AValue: TJSONArray): TObjectList<T>;
var
  I: Integer;
begin
  Result := TObjectList<T>.Create;
  for I := 0 to Pred(AValue.Count) do
    Result.Add(JsonObjectToObject(TJSONObject(AValue.Items[I])));
end;

procedure TGBJSONSerializer<T>.JsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject; AType: TRttiType);
var
  LProperty: TRttiProperty;
  LJsonValue: TJSONValue;
begin
  for LProperty in AType.GetProperties do
  begin
    try
      if (FUseIgnore) and (LProperty.IsIgnore(AObject.ClassType)) then
        Continue;

      LJsonValue := AJsonObject.Values[LProperty.JSONName];

      if (not Assigned(LJsonValue)) or (not LProperty.IsWritable) then
        Continue;

      if LJsonValue is TJSONNull then
        Continue;

      if LProperty.IsString then
      begin
        SetValueStr(AObject, LProperty, LJsonValue);
        Continue;
      end;

      if LProperty.IsVariant then
      begin
        LProperty.SetValue(AObject, LJsonValue.Value);
        Continue;
      end;

      if LProperty.IsInteger then
      begin
        LProperty.SetValue(AObject, StrToIntDef(LJsonValue.Value, 0));
        Continue;
      end;

      if LProperty.IsEnum then
      begin
        SetValueEnum(AObject, LProperty, LJsonValue);
        Continue;
      end;

      if LProperty.IsObject then
      begin
        JsonObjectToObject(LProperty.GetValue(AObject).AsObject, TJSONObject(LJsonValue));
        Continue;
      end;

      if LProperty.IsFloat then
      begin
        SetValueFloat(AObject, LProperty, LJsonValue);
        Continue;
      end;

      if LProperty.IsDateTime then
      begin
        SetValueDate(AObject, LProperty, LJsonValue);
        Continue;
      end;

      if LProperty.IsList then
      begin
        JsonObjectToObjectList(AObject, TJSONArray(LJsonValue), LProperty);
        Continue;
      end;

      if LProperty.IsBoolean then
      begin
        SetValueBool(AObject, LProperty, LJsonValue);
        Continue;
      end;

      if LProperty.IsArray then
        SetValueArray(AObject, LProperty, LJsonValue);
    except
      on E: Exception do
      begin
        E.Message := Format('Error on read property %s from json: %s', [ LProperty.Name, E.message ]);
        raise;
      end;
    end;
  end;
end;

procedure TGBJSONSerializer<T>.JsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject);
var
  LType: TRttiType;
begin
  if (not Assigned(AObject)) or (not Assigned(AJsonObject)) then
    exit;

  LType := TGBRTTI.GetInstance.GetType(AObject.ClassType);
  JsonObjectToObject(AObject, AJsonObject, LType);
end;

function TGBJSONSerializer<T>.JsonObjectToObject(AJsonObject: TJSONObject): T;
begin
  Result := T.create;
  JsonObjectToObject(Result, AJsonObject);
end;

procedure TGBJSONSerializer<T>.JsonObjectToObjectList(AObject: TObject; AJsonArray: TJSONArray; AProperty: TRttiProperty);
var
  I: Integer;
  LObjectItem: TObject;
  LValue: TValue;
  LListType: TRttiType;
begin
  if not Assigned(AJsonArray) then
    Exit;

  LListType := AProperty.GetListType(AObject);
  for I := 0 to Pred(AJsonArray.Count) do
  begin
    if LListType.TypeKind.IsObject then
    begin
      LObjectItem := LListType.AsInstance.MetaclassType.Create;
      LObjectItem.InvokeMethod('create', []);

      Self.JsonObjectToObject(LObjectItem, TJSONObject(AJsonArray.Items[I]));
      AProperty.GetValue(AObject).AsObject.InvokeMethod('Add', [LObjectItem]);
    end
    else
    begin
      if LListType.TypeKind.IsString then
        LValue := TValue.From<string>(AJsonArray.Items[I].GetValue<string>);

      if LListType.TypeKind.IsFloat then
        LValue := TValue.From<Double>(AJsonArray.Items[I].GetValue<Double>);

      if LListType.TypeKind.IsInteger then
        LValue := TValue.From<Integer>(AJsonArray.Items[I].GetValue<Integer>);

      AProperty.GetValue(AObject).AsObject.InvokeMethod('Add', [LValue]);
    end;
  end;
end;

function TGBJSONSerializer<T>.JsonStringToList(AValue: string): TObjectList<T>;
var
  LJsonArray: TJSONArray;
begin
  LJsonArray := TJSONObject.ParseJSONValue(AValue) as TJSONArray;
  try
    Result := JsonArrayToList(LJsonArray);
  finally
    LJsonArray.Free;
  end;
end;

function TGBJSONSerializer<T>.JsonStringToObject(AJsonString: string): T;
var
  LJSON: TJSONObject;
begin
  Result := nil;
  LJSON := TJSONObject.ParseJSONValue(AJsonString) as TJSONObject;
  try
    if Assigned(LJSON) then
      Result := Self.JsonObjectToObject(LJSON);
  finally
    LJSON.Free;
  end;
end;

class function TGBJSONSerializer<T>.New(AUseIgnore: Boolean): IGBJSONSerializer<T>;
begin
  Result := Self.Create(AUseIgnore);
end;

procedure TGBJSONSerializer<T>.SetValueArray(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
var
  LType: TRttiType;
  LValues: TArray<TValue>;
  I: Integer;
begin
  if (not Assigned(AJSONValue)) or (not (AJSONValue is TJSONArray)) then
    Exit;

  LType := AProperty.GetListType(AObject);
  SetLength(LValues, TJSONArray(AJSONValue).Count);
  for I := 0 to Pred(TJSONArray(AJSONValue).Count) do
  begin
    if LType.TypeKind.IsString then
      LValues[I] := TValue.From<string>(TJSONArray(AJSONValue).Items[I].Value)
    else
    if LType.TypeKind.IsInteger then
      LValues[I] := TValue.From<Integer>(TJSONArray(AJSONValue).Items[I].Value.ToInteger)
    else
    if LType.TypeKind.IsFloat then
      LValues[I] := TValue.From<Double>(TJSONArray(AJSONValue).Items[I].Value.ToDouble)
  end;

  AProperty.SetValue(AObject, TValue.FromArray(AProperty.PropertyType.Handle, LValues));
end;

procedure TGBJSONSerializer<T>.SetValueBool(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
var
  LBoolValue: Boolean;
begin
  LBoolValue := AJSONValue.Value.ToLower.Equals('true');
  AProperty.SetValue(AObject, TValue.From<Boolean>(LBoolValue));
end;

procedure TGBJSONSerializer<T>.SetValueDate(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
var
  LJSONDate: TJSONValue;
  LDate: TDateTime;
begin
  if AJSONValue.TryGetValue<TJSONValue>('$date', LJSONDate) then
    LDate.FromIso8601ToDateTime(LJSONDate.Value)
  else
    LDate.FromIso8601ToDateTime(AJSONValue.Value);
  AProperty.SetValue(AObject, TValue.From<TDateTime>(LDate));
end;

procedure TGBJSONSerializer<T>.SetValueEnum(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
var
  LEnumValue: Integer;
  LValues: TArray<string>;
  LEnumAttribute: JSONEnum;
begin
  if AJSONValue.Value.Trim.IsEmpty then
    Exit;

  LEnumAttribute := AProperty.GetAttribute<JSONEnum>;
  if Assigned(LEnumAttribute) then
  begin
    LValues := LEnumAttribute.Values;
    LEnumValue := IndexText(AJSONValue.Value.Trim, LValues);
    if LEnumValue < 0 then
      LEnumValue := 0;
  end
  else
    LEnumValue := GetEnumValue(AProperty.GetValue(AObject).TypeInfo, AJSONValue.Value);

  AProperty.SetValue(AObject, TValue.FromOrdinal(AProperty.GetValue(AObject).TypeInfo, LEnumValue));
end;

procedure TGBJSONSerializer<T>.SetValueFloat(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
var
  LStrValue: string;
begin
  LStrValue := AJSONValue.Value.Replace('.', FormatSettings.DecimalSeparator);
  AProperty.SetValue(AObject, TValue.From<Double>( StrToFloatDef(LStrValue, 0)));
end;

procedure TGBJSONSerializer<T>.SetValueStr(const AObject: TObject; const AProperty: TRttiProperty; const AJSONValue: TJSONValue);
var
  LJSONId: TJSONValue;
begin
  if AJSONValue.TryGetValue<TJSONValue>('$oid', LJSONId) then
    AProperty.SetValue(AObject, LJSONId.Value)
  else
    AProperty.SetValue(AObject, AJSONValue.Value);
end;

end.
