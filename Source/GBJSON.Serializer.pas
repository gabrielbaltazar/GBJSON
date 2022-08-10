unit GBJSON.Serializer;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

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

type
  TGBJSONSerializer<T: class, constructor> = class(TGBJSONBase, IGBJSONSerializer<T>)
  private
    FUseIgnore: Boolean;

    procedure jsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject; AType: TRttiType); overload;
    procedure jsonObjectToObjectList(AObject: TObject; AJsonArray: TJSONArray; AProperty: TRttiProperty);
  public
    class function New(AUseIgnore: Boolean): IGBJSONSerializer<T>;
    constructor Create(AUseIgnore: Boolean = True); reintroduce;
    destructor Destroy; override;

    procedure JsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject); overload;
    function JsonObjectToObject(AJsonObject: TJSONObject): T; overload;
    function JsonStringToObject(AJsonString: string): T;
    function JsonArrayToList(AValue: TJSONArray): TObjectList<T>;
    function JsonStringToList(AValue: string): TObjectList<T>;
  end;

implementation

{ TGBJSONSerializer }

constructor TGBJSONSerializer<T>.Create(AUseIgnore: Boolean);
begin
  inherited Create;
  FUseIgnore := AUseIgnore;
end;

destructor TGBJSONSerializer<T>.Destroy;
begin
  inherited;
end;

function TGBJSONSerializer<T>.JsonArrayToList(AValue: TJSONArray): TObjectList<T>;
var
  I: Integer;
begin
  Result := TObjectList<T>.Create;
  for I := 0 to Pred(AValue.Count) do
    Result.Add(JsonObjectToObject(TJSONObject(AValue.Items[I])));
end;

procedure TGBJSONSerializer<T>.jsonObjectToObject(AObject: TObject; AJsonObject: TJSONObject; AType: TRttiType);
var
  LProperty: TRttiProperty;
  LType: TRttiType;
  LValues: TArray<TValue>;
  LJsonValue: TJSONValue;
  LDate: TDateTime;
  LEnumValue: Integer;
  LBoolValue: Boolean;
  LStrValue: string;
  LValue: TValue;
  I: Integer;
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
        LProperty.SetValue(AObject, LJsonValue.Value);
        Continue;
      end;

      if LProperty.IsVariant then
      begin
        LProperty.SetValue(AObject, LJsonValue.Value);
        Continue;
      end;

      if LProperty.IsInteger then
      begin
        LProperty.SetValue(AObject, StrToIntDef( LJsonValue.Value, 0));
        Continue;
      end;

      if LProperty.IsEnum then
      begin
        if LJsonValue.Value.Trim.IsEmpty then
          Continue;
        LEnumValue := GetEnumValue(LProperty.GetValue(AObject).TypeInfo, LJsonValue.Value);
        LProperty.SetValue(AObject,
          TValue.FromOrdinal(LProperty.GetValue(AObject).TypeInfo, LEnumValue));
        Continue;
      end;

      if LProperty.IsObject then
      begin
        JsonObjectToObject(LProperty.GetValue(AObject).AsObject, TJSONObject(LJsonValue));
        Continue;
      end;

      if LProperty.IsFloat then
      begin
        LStrValue := LJsonValue.Value.Replace('.', FormatSettings.DecimalSeparator);
        LProperty.SetValue(AObject, TValue.From<Double>( StrToFloatDef(LStrValue, 0)));
        Continue;
      end;

      if LProperty.IsDateTime then
      begin
        LDate.fromIso8601ToDateTime(LJsonValue.Value);
        LProperty.SetValue(AObject, TValue.From<TDateTime>(LDate));
        Continue;
      end;

      if LProperty.IsList then
      begin
        jsonObjectToObjectList(AObject, TJSONArray(LJsonValue), LProperty);
        Continue;
      end;

      if LProperty.IsBoolean then
      begin
        LBoolValue := LJsonValue.Value.ToLower.Equals('true');
        LProperty.SetValue(AObject, TValue.From<Boolean>(LBoolValue));
        Continue;
      end;

      if LProperty.IsArray then
      begin
        if (not Assigned(LJsonValue)) or (not (LJsonValue is TJSONArray)) then
          Continue;

        LType := LProperty.GetListType(AObject);
        SetLength(LValues, TJSONArray(LJsonValue).Count);
        for I := 0 to Pred(TJSONArray(LJsonValue).Count) do
        begin
          if LType.TypeKind.IsString then
            LValues[I] := TValue.From<string>(TJSONArray(LJsonValue).Items[I].Value)
          else
          if LType.TypeKind.IsInteger then
            LValues[I] := TValue.From<Integer>(TJSONArray(LJsonValue).Items[I].Value.ToInteger)
          else
          if LType.TypeKind.IsFloat then
            LValues[I] := TValue.From<Double>(TJSONArray(LJsonValue).Items[I].Value.ToDouble)
        end;

        LProperty.SetValue(AObject,
            TValue.FromArray(LProperty.PropertyType.Handle, LValues));
      end;
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

procedure TGBJSONSerializer<T>.jsonObjectToObjectList(AObject: TObject; AJsonArray: TJSONArray; AProperty: TRttiProperty);
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

end.
