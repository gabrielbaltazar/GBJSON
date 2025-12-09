unit GBJSON.Firedac.Deserializer;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.SysUtils,
  System.Rtti,
  System.StrUtils,
  System.Variants,
  System.TypInfo,
  System.Generics.Collections,
  FireDAC.Phys.MongoDBWrapper,
  GBJSON.RTTI,
  GBJSON.Config,
  GBJSON.DateTime.Helper,
  GBJSON.Firedac.Interfaces;

type
  TGBJSONFiredacDeserializer<T: class, constructor> = class(TInterfacedObject,
    IGBJSONFDDeserializer<T>)
  private
    FConnection: TMongoConnection;
    FUseIgnore: Boolean;
    FOriginalCaseDefinition: TCaseDefinition;
    FCaseDefinition: TCaseDefinition;

    procedure SetValueStr(const AProperty: TRttiProperty; const ADocument: TMongoDocument;
      const AName: string; const AValue: TValue);
    procedure SetValueDate(const AProperty: TRttiProperty; const ADocument: TMongoDocument;
      const AName: string; const AValue: TValue);
    procedure SetValueEnum(const AProperty: TRttiProperty; const ADocument: TMongoDocument;
      const AName: string; const AValue: TValue);

    procedure ObjectToMongoDocument(AValue: TObject; ADocument: TMongoDocument); overload;

    procedure AddValueToDocument(AObject: TObject; AProperty: TRttiProperty;
      ADocument: TMongoDocument);
    procedure AddValueListToDocument(AObject: TObject; AProperty: TRttiProperty;
      ADocument: TMongoDocument);
  protected
    function CaseDefinition(const AValue: TCaseDefinition): IGBJSONFDDeserializer<T>;
    function ObjectToMongoDocument(const AValue: TObject): TMongoDocument; overload;
    function ListToMongoDocument(const APropName: string; const AList: TObjectList<T>): TMongoDocument;
  public
    constructor Create(AConnection: TMongoConnection; AUseIgnore: Boolean = True);
    class function New(AConnection: TMongoConnection; AUseIgnore: Boolean = True): IGBJSONFDDeserializer<T>;
  end;

implementation

uses
  GBJSON.Attributes,
  System.JSON.Types;

{ TGBJSONFiredacDeserializer<T> }

procedure TGBJSONFiredacDeserializer<T>.AddValueListToDocument(AObject: TObject;
  AProperty: TRttiProperty; ADocument: TMongoDocument);
var
  I: Integer;
  LType: TRttiType;
  LMethod: TRttiMethod;
  LValue: TValue;
  LName: string;
begin
  LValue := AProperty.GetValue(AObject);
  LName := AProperty.JSONName;
  if LValue.AsObject = nil then
  begin
    ADocument.BeginArray(LName).EndArray;
    Exit;
  end;

  LType := TGBRTTI.GetInstance.GetType(LValue.AsObject.ClassType);
  LMethod := LType.GetMethod('ToArray');
  LValue := LMethod.Invoke(LValue.AsObject, []);

  ADocument.BeginArray(LName);
  for I := 0 to Pred(LValue.GetArrayLength) do
  begin
    if LValue.GetArrayElement(I).IsObject then
    begin
      ADocument.BeginObject(I.ToString);
      Self.ObjectToMongoDocument(LValue.GetArrayElement(I).AsObject, ADocument);
      ADocument.EndObject;
    end
    else
    begin
      LType := AProperty.GetListType(AObject);

      if LType.TypeKind.IsEnum then
        ADocument.Add(I.ToString, GetEnumName(LValue.GetArrayElement(I).TypeInfo, LValue.GetArrayElement(I).AsOrdinal))
      else
      if LType.TypeKind.IsString then
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsString)
      else
      if LType.TypeKind.IsInteger then
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsInteger)
      else
      if LType.TypeKind.IsFloat then
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsExtended)
      else
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsVariant);
    end;
  end;
  ADocument.EndArray;
end;

procedure TGBJSONFiredacDeserializer<T>.AddValueToDocument(AObject: TObject;
  AProperty: TRttiProperty; ADocument: TMongoDocument);
var
  LValue: TValue;
  LName: string;
  LType: TRttiType;
  I: Integer;
begin
  LValue := AProperty.GetValue(AObject);
  LName := AProperty.JSONName;
  if AProperty.IsString then
    SetValueStr(AProperty, ADocument, LName, LValue)
  else
  if AProperty.IsInteger then
    ADocument.Add(LName, LValue.AsInteger)
  else
  if AProperty.IsEnum then
    SetValueEnum(AProperty, ADocument, LName, LValue)
  else
  if AProperty.IsFloat then
    ADocument.Add(LName, LValue.AsExtended)
  else
  if AProperty.IsBoolean then
    ADocument.Add(LName, LValue.AsBoolean)
  else
  if AProperty.IsDateTime then
    Self.SetValueDate(AProperty, ADocument, LName, LValue)
  else
  if AProperty.IsObject then
  begin
    ADocument.BeginObject(LName);
    ObjectToMongoDocument(LValue.AsObject, ADocument);
    ADocument.EndObject;
  end
  else
  if AProperty.IsList then
    Self.AddValueListToDocument(AObject, AProperty, ADocument)
  else
  if AProperty.IsArray then
  begin
    LType := AProperty.GetListType(AObject);
    ADocument.BeginArray(LName);
    for I := 0 to Pred(LValue.GetArrayLength) do
    begin
      if LType.TypeKind.IsString then
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsString)
      else
      if LType.TypeKind.IsInteger then
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsInteger)
      else
      if LType.TypeKind.IsFloat then
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsExtended)
      else
        ADocument.Add(I.ToString, LValue.GetArrayElement(I).AsVariant);
    end;
    ADocument.EndArray;
  end;
end;

function TGBJSONFiredacDeserializer<T>.CaseDefinition(
  const AValue: TCaseDefinition): IGBJSONFDDeserializer<T>;
begin
  Result := Self;
  FCaseDefinition := AValue;
end;

constructor TGBJSONFiredacDeserializer<T>.Create(AConnection: TMongoConnection;
  AUseIgnore: Boolean = True);
begin
  FConnection := AConnection;
  FUseIgnore := AUseIgnore;
  FCaseDefinition := TGBJSONConfig.GetInstance.CaseDefinition;
  FOriginalCaseDefinition := FCaseDefinition;
end;

function TGBJSONFiredacDeserializer<T>.ListToMongoDocument(const APropName: string; const AList: TObjectList<T>): TMongoDocument;
var
  LEnv: TMongoEnv;
  LArray: TArray<T>;
  I: Integer;
begin
  TGBJSONConfig.GetInstance.CaseDefinition(FCaseDefinition);
  try
    if not Assigned(AList) then
      Exit(nil);

    LArray := AList.ToArray;
    LEnv := FConnection.Env;
    Result := LEnv.NewDoc;
    try
      Result. BeginArray(APropName);
      for I := 0 to Pred(Length(LArray)) do
      begin
        if LArray[I] is TObject then
        begin
          Result.BeginObject(I.ToString);
          Self.ObjectToMongoDocument(TObject(LArray[I]), Result);
          Result.EndObject;
        end
      end;
      Result.EndArray;

    except
      Result.Free;
      raise;
    end;
  finally
    TGBJSONConfig.GetInstance.CaseDefinition(FOriginalCaseDefinition);
  end;
end;

class function TGBJSONFiredacDeserializer<T>.New(
  AConnection: TMongoConnection; AUseIgnore: Boolean = True): IGBJSONFDDeserializer<T>;
begin
  Result := Self.Create(AConnection, AUseIgnore);
end;

function TGBJSONFiredacDeserializer<T>.ObjectToMongoDocument(const AValue: TObject): TMongoDocument;
var
  LEnv: TMongoEnv;
begin
  TGBJSONConfig.GetInstance.CaseDefinition(FCaseDefinition);
  try
    if not Assigned(AValue) then
      Exit(nil);

    LEnv := FConnection.Env;
    Result := LEnv.NewDoc;
    try
      ObjectToMongoDocument(AValue, Result);
    except
      Result.Free;
      raise;
    end;
  finally
    TGBJSONConfig.GetInstance.CaseDefinition(FOriginalCaseDefinition);
  end;
end;

procedure TGBJSONFiredacDeserializer<T>.SetValueDate(const AProperty: TRttiProperty; const ADocument: TMongoDocument;
  const AName: string; const AValue: TValue);
var
  LData: TDateTime;
begin
  LData := AValue.AsExtended;
  if LData = 0 then
    Exit;

  if AProperty.IsMongoDate then
    ADocument.Add(AName, LData)
  else
    ADocument.Add(AName, LData.DateTimeToIso8601);
end;

procedure TGBJSONFiredacDeserializer<T>.SetValueEnum(const AProperty: TRttiProperty; const ADocument: TMongoDocument; const AName: string;
  const AValue: TValue);
var
  LEnumAttribute: JSONEnum;
  LEnumValue: Integer;
  LValue: string;
begin
  LEnumAttribute := AProperty.GetAttribute<JSONEnum>;
  LEnumValue := AValue.AsOrdinal;
  if Assigned(LEnumAttribute) then
  begin
    LValue := LEnumAttribute.Values[LEnumValue];
    if LEnumAttribute.EnumType = etInteger then
      ADocument.Add(AName, StrToInt(LValue))
    else
      ADocument.Add(AName, LValue);
  end
  else
    ADocument.Add(AName, GetEnumName(AValue.TypeInfo, LEnumValue));
end;

procedure TGBJSONFiredacDeserializer<T>.SetValueStr(const AProperty: TRttiProperty; const ADocument: TMongoDocument; const AName: string; const AValue: TValue);
var
  LJSONOId: TJsonOid;
begin
  if AProperty.IsString then
  begin
    if AProperty.IsMongoId then
    begin
      if AValue.AsString <> EmptyStr then
      begin
        LJSONOId := TJsonOid.Create(AValue.AsString);
        ADocument.Add(AName, LJSONOId);
      end;
    end
    else
      ADocument.Add(AName, AValue.AsString)
  end
end;

procedure TGBJSONFiredacDeserializer<T>.ObjectToMongoDocument(AValue: TObject;
  ADocument: TMongoDocument);
var
  LType: TRttiType;
  LProperty: TRttiProperty;
  LFields: TList<string>;
  LName: string;
begin
  LType := TGBRTTI.GetInstance.GetType(AValue.ClassType);
  LFields := TList<string>.create;
  try
    for LProperty in LType.GetProperties do
    begin
      if LProperty.IsMongoIgnore then
        Continue;
      if not LProperty.IsReadable then
        Continue;
      if ((not FUseIgnore) or (not LProperty.IsIgnore(AValue.ClassType))) then
      begin
        LName := LProperty.JSONName.ToLower;
        if not LFields.Contains(LName) then
        begin
          AddValueToDocument(AValue, LProperty, ADocument);
          LFields.Add(LName);
        end;
      end;
    end;
  finally
    LFields.Free;
  end;
end;

end.
