unit GBJSON.RTTI;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  GBJSON.Config,
  GBJSON.Attributes;

type
  IGBRTTI = interface
    ['{B432A34C-5601-4254-A951-0DE059E73CCE}']
    function GetType(AClass: TClass): TRttiType;
    function FindType(ATypeName: string): TRttiType;
  end;

  TGBRTTI = class(TInterfacedObject, IGBRTTI)
  private
    class var FInstance: IGBRTTI;
  private
    FContext: TRttiContext;

    constructor CreatePrivate;
  public
    class function GetInstance: IGBRTTI;
    constructor Create;
    destructor Destroy; override;

    function GetType(AClass: TClass): TRttiType;
    function FindType(ATypeName: string): TRttiType;
  end;

  TTypeKindHelper = record helper for TTypeKind
  public
    function IsString: Boolean;
    function IsInteger: Boolean;
    function IsArray: Boolean;
    function IsObject: Boolean;
    function IsFloat: Boolean;
    function IsVariant: Boolean;
  end;

  TGBRTTITypeHelper = class helper for TRttiType
  public
    function IsList: Boolean;
  end;

  TGBRTTIPropertyHelper = class helper for TRttiProperty
  public
    function IsList: Boolean;
    function IsString: Boolean;
    function IsInteger: Boolean;
    function IsEnum: Boolean;
    function IsArray: Boolean;
    function IsObject: Boolean;
    function IsFloat: Boolean;
    function IsDateTime: Boolean;
    function IsBoolean: Boolean;
    function IsVariant: Boolean;

    function IsEmpty(AObject: TObject): Boolean;
    function IsIgnore(AClass: TClass): Boolean;
    function IsReadOnly: Boolean;

    function JSONName: string;
    function GetAttribute<T: TCustomAttribute>: T;
    function GetListType(AObject: TObject): TRttiType;
  end;

  TGBObjectHelper = class helper for TObject
  public
    function InvokeMethod(const AMethodName: string; const AParameters: array of TValue): TValue;
    function GetPropertyValue(AName: string): TValue;

    class function GetAttribute<T: TCustomAttribute>: T;
    class function JsonIgnoreFields: TArray<string>;
  end;

implementation

{ TGBRTTI }

constructor TGBRTTI.Create;
begin
  raise Exception.Create('Utilize the GetInstance Construtor.');
end;

constructor TGBRTTI.CreatePrivate;
begin
  FContext := TRttiContext.Create;
end;

destructor TGBRTTI.Destroy;
begin
  FContext.Free;
  inherited;
end;

function TGBRTTI.FindType(ATypeName: string): TRttiType;
begin
  Result := FContext.FindType(ATypeName);
end;

class function TGBRTTI.GetInstance: IGBRTTI;
begin
  if not Assigned(FInstance) then
    FInstance := TGBRTTI.CreatePrivate;
  Result := FInstance;
end;

function TGBRTTI.GetType(AClass: TClass): TRttiType;
begin
  Result := FContext.GetType(AClass);
end;

{ TGBRTTITypeHelper }

function TGBRTTITypeHelper.IsList: Boolean;
begin
  Result := False;
  if Self.AsInstance.Name.ToLower.StartsWith('tobjectlist<') then
    Exit(True);

  if Self.AsInstance.Name.ToLower.StartsWith('tlist<') then
    Exit(True);
end;

{ TGBRTTIPropertyHelper }

function TGBRTTIPropertyHelper.GetAttribute<T>: T;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Pred(Length(Self.GetAttributes)) do
    if Self.GetAttributes[I].ClassNameIs(T.className) then
      Exit(T( Self.GetAttributes[I]));
end;

function TGBRTTIPropertyHelper.GetListType(AObject: TObject): TRttiType;
var
  LListType: TRttiType;
  LListTypeName: string;
begin
  if not Self.GetValue(AObject).IsArray then
  begin
    LListType := TGBRTTI.GetInstance.GetType(Self.GetValue(AObject).AsObject.ClassType);
    LListTypeName := LListType.ToString;
  end
  else
    LListTypeName := Self.PropertyType.ToString;

  LListTypeName := LListTypeName.Replace('TObjectList<', EmptyStr);
  LListTypeName := LListTypeName.Replace('TList<', EmptyStr);
  LListTypeName := LListTypeName.Replace('TArray<', EmptyStr);
  LListTypeName := LListTypeName.Replace('>', EmptyStr);

  Result := TGBRTTI.GetInstance.FindType(LListTypeName);
end;

function TGBRTTIPropertyHelper.IsArray: Boolean;
begin
  Result := Self.PropertyType.TypeKind.IsArray;
end;

function TGBRTTIPropertyHelper.IsBoolean: Boolean;
begin
  Result := Self.PropertyType.ToString.ToLower.Equals('boolean');
end;

function TGBRTTIPropertyHelper.IsDateTime: Boolean;
begin
  Result := (Self.PropertyType.ToString.ToLower.Equals('tdatetime')) or
    (Self.PropertyType.ToString.ToLower.Equals('tdate')) or
    (Self.PropertyType.ToString.ToLower.Equals('ttime'));
end;

function TGBRTTIPropertyHelper.IsEmpty(AObject: TObject): Boolean;
var
  LObjectList : TObject;
begin
  Result := False;
  if (Self.IsString) and (Self.GetValue(AObject).AsString.IsEmpty) then
    Exit(True);

  if (Self.IsInteger) and (Self.GetValue(AObject).AsInteger = 0) then
    Exit(True);

  if (Self.IsObject) and (Self.GetValue(AObject).AsObject = nil) then
    Exit(True);

  if (Self.IsArray) and ((Self.GetValue(AObject).IsEmpty) or (Self.GetValue(AObject).GetArrayLength = 0)) then
    Exit(True);

  if (Self.IsList) then
  begin
    LObjectList := Self.GetValue(AObject).AsObject;
    if (not Assigned(LObjectList)) or (LObjectList.GetPropertyValue('Count').AsInteger = 0) then
      Exit(True);
  end;

  if (Self.IsFloat) and (Self.GetValue(AObject).AsExtended = 0) then
    Exit(True);

  if (Self.IsDateTime) and (Self.GetValue(AObject).AsExtended = 0) then
    Exit(True);
end;

function TGBRTTIPropertyHelper.IsEnum: Boolean;
begin
  Result := (not IsBoolean) and (Self.PropertyType.TypeKind = tkEnumeration);
end;

function TGBRTTIPropertyHelper.IsFloat: Boolean;
begin
  Result := (Self.PropertyType.TypeKind.IsFloat) and (not IsDateTime);
end;

function TGBRTTIPropertyHelper.IsIgnore(AClass: TClass): Boolean;
var
  LIgnoreProperties: TArray<string>;
  I: Integer;
begin
  LIgnoreProperties := AClass.JsonIgnoreFields;
  for I := 0 to Pred(Length(LIgnoreProperties)) do
  begin
    if Name.ToLower.Equals(LIgnoreProperties[I].ToLower) then
      Exit(True);
  end;

  Result := Self.GetAttribute<JSONIgnore> <> nil;
  if not Result then
  begin
    if AClass.InheritsFrom(TInterfacedObject) then
      Result := Self.Name.ToLower.Equals('refcount');
  end;

  if not Result then
  begin
    for I := 0 to Pred(Length(Self.GetAttributes)) do
    begin
      if GetAttributes[I].ClassNameIs('SwagIgnore') then
        Exit(True);
    end;
  end;
end;

function TGBRTTIPropertyHelper.IsInteger: Boolean;
begin
  Result := Self.PropertyType.TypeKind.IsInteger;
end;

function TGBRTTIPropertyHelper.IsList: Boolean;
begin
  Result := False;
  if Self.PropertyType.ToString.ToLower.StartsWith('tobjectlist<') then
    Exit(True);

  if Self.PropertyType.ToString.ToLower.StartsWith('tlist<') then
    Exit(True);
end;

function TGBRTTIPropertyHelper.IsObject: Boolean;
begin
  Result := (not IsList) and (Self.PropertyType.TypeKind.IsObject);
end;

function TGBRTTIPropertyHelper.IsReadOnly: Boolean;
var
  LProp: JSONProp;
begin
  Result := False;
  LProp := GetAttribute<JSONProp>;
  if Assigned(LProp) then
    Result := LProp.readOnly;
end;

function TGBRTTIPropertyHelper.IsString: Boolean;
begin
  Result := Self.PropertyType.TypeKind.IsString;
end;

function TGBRTTIPropertyHelper.IsVariant: Boolean;
begin
  Result := Self.PropertyType.TypeKind.IsVariant;
end;

function TGBRTTIPropertyHelper.JSONName: string;
var
  I: Integer;
  LField: TArray<Char>;
  LProp: JSONProp;
begin
  Result := Self.Name;
  LProp := GetAttribute<JSONProp>;
  if (Assigned(LProp)) and (not LProp.name.IsEmpty) then
    Result := LProp.name;

  case TGBJSONConfig.GetInstance.CaseDefinition of
    cdLower: Result := Result.ToLower;
    cdUpper: Result := Result.ToUpper;

    cdLowerCamelCase:
      begin
        // Copy From DataSet-Serialize - https://github.com/viniciussanchez/dataset-serialize
        // Thanks Vinicius Sanchez
        LField := Self.Name.ToCharArray;
        I := Low(LField);
        while i <= High(LField) do
        begin
          if (LField[I] = '_') then
          begin
            Inc(I);
            Result := Result + UpperCase(LField[I]);
          end
          else
            Result := Result + LowerCase(LField[I]);
          Inc(I);
        end;
        if Result.IsEmpty then
          Result := Self.Name;
      end;
  end;
end;

{ TGBObjectHelper }

class function TGBObjectHelper.GetAttribute<T>: T;
var
  I: Integer;
  LType: TRttiType;
begin
  Result := nil;
  LType := TGBRTTI.GetInstance.GetType(Self);
  for I := 0 to Pred(Length(LType.GetAttributes)) do
    if LType.GetAttributes[I].ClassNameIs(T.className) then
      Exit(T( LType.GetAttributes[I]));
end;

function TGBObjectHelper.GetPropertyValue(AName: string): TValue;
var
  LProp: TRttiProperty;
begin
  if not Assigned(Self) then
    Exit(nil);

  LProp := TGBRTTI.GetInstance.GetType(Self.ClassType)
                .GetProperty(AName);
  if Assigned(LProp) then
    Result := LProp.GetValue(Self);
end;

function TGBObjectHelper.InvokeMethod(const AMethodName: string; const AParameters: array of TValue): TValue;
var
  LiType: TRttiType;
  LMethod: TRttiMethod;
begin
  LiType := TGBRTTI.GetInstance.GetType(Self.ClassType);
  LMethod := LiType.GetMethod(AMethodName);
  if not Assigned(LMethod) then
    raise ENotImplemented.CreateFmt('Cannot find method %s in %s', [AMethodName, Self.ClassName]);

  Result := LMethod.Invoke(Self, AParameters);
end;

class function TGBObjectHelper.JsonIgnoreFields: TArray<string>;
var
  LIgnore: JSONIgnore;
begin
  Result := [];
  LIgnore := GetAttribute<JSONIgnore>;
  if Assigned(LIgnore) then
    Result := LIgnore.IgnoreProperties;
end;

{ TTypeKindHelper }

function TTypeKindHelper.IsArray: Boolean;
begin
  Result := Self in [tkSet, tkArray, tkDynArray];
end;

function TTypeKindHelper.IsFloat: Boolean;
begin
  Result := Self = tkFloat;
end;

function TTypeKindHelper.IsInteger: Boolean;
begin
  Result := Self in [tkInt64, tkInteger];
end;

function TTypeKindHelper.IsObject: Boolean;
begin
  Result := Self = tkClass;
end;

function TTypeKindHelper.IsString: Boolean;
begin
  Result := Self in [tkChar, tkString, tkWChar, tkLString,
    tkWString, tkUString];
end;

function TTypeKindHelper.IsVariant: Boolean;
begin
  Result := Self = tkVariant;
end;

end.
