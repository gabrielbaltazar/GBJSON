unit GBJSON.Helper;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  REST.Json,
  GBJSON.DateTime.Helper,
  GBJSON.Interfaces;

type
  TGBJSONObjectHelper = class helper for TJSONObject
  public
    {$IF CompilerVersion <= 32.0}
    function Format: string; overload;
    {$ENDIF}

    class function ObjectToJSONString(AValue: TObject): string;
    class function FromObject(AValue: TObject): TJSONObject;
    class function FromFile(AValue: string) : TJSONObject;
    class function FromString(AValue: string) : TJSONObject;
    class function Format(AValue: string): string; overload;

    procedure SaveToFile(AFileName: string);
    procedure ToObject(AValue: TObject; AUseIgnore: Boolean = True);

    function ValueAsString(AName: string; ADefault: string = ''): string;
    function ValueAsInteger(AName: string; ADefault: Integer = 0): Integer;
    function ValueAsFloat(AName: string; ADefault: Double = 0): Double;
    function ValueAsDateTime(AName: string; AFormat: string = ''; ADefault: TDateTime = 0): TDateTime;
    function ValueAsBoolean(AName: string; ADefault: Boolean = True): Boolean;
    function ValueAsJSONObject(AName: string): TJSONObject;
    function ValueAsJSONArray (AName: string): TJSONArray;

    function SetValue(AName: string; AValue: Boolean): TJSONObject; overload;
    function SetValue(AName: string; AValue: Integer): TJSONObject; overload;
    function SetValue(AName: string; AValue: Double): TJSONObject; overload;
    function SetValue(AName, AValue: string): TJSONObject; overload;

    function Encode: string;
  end;

  TGBJSONArrayHelper = class helper for TJSONArray
  private
    {$IF CompilerVersion <= 26.0}
    function GetItems(AIndex: Integer): TJSONValue;
    {$ENDIF}

    function GetFields: TList<string>;
  public
    {$IF CompilerVersion <= 26.0}
    function Count: Integer;
    property Items[Index: Integer]: TJSONValue read GetItems;
    {$ENDIF}

    function Encode: string;
    procedure ToCsvFile(AFileName: string; ASeparator: string); overload;
    class procedure ToCsvFile(AJSONContent: string; AFileName: string; ASeparator: string); overload;
    function ToCsv(ASeparator: string = ';'): string; overload;
    class function ToCsv(AJSONContent: string; ASeparator: string): string; overload;

    function ItemAsString(AIndex: Integer; AName: string; ADefault: string = ''): string;
    function ItemAsInteger(AIndex: Integer; AName: string; ADefault: Integer = 0): Integer;
    function ItemAsFloat(AIndex: Integer; AName: string; ADefault: Double = 0): Double;
    function ItemAsDateTime(AIndex: Integer; AName: string; AFormat: string = ''; Default: TDateTime = 0): TDateTime;
    function ItemAsBoolean(AIndex: Integer; AName: string; ADefault: Boolean = True): Boolean;

    function ItemAsJSONObject(AIndex: Integer): TJSONObject; overload;
    function ItemAsJSONObject(AIndex: Integer; AName: string): TJSONObject; overload;
    function ItemAsJSONArray(AIndex: Integer): TJSONArray; overload;
    function ItemAsJSONArray(AIndex: Integer; AName: string): TJSONArray; overload;
    class function FromString(AValue: string): TJSONArray;
  end;

  TObjectHelper = class helper for TObject
  public
    function ToJSONObject: TJSONObject;
    function ToJSONString(AFormat: Boolean = False): string;
    procedure SaveToJSONFile(AFileName: string);
    procedure FromJSONObject(AValue: TJSONObject);
    procedure FromJSONString(AValue: string);
end;

implementation

{ TGBJSONObjectHelper }

function TGBJSONObjectHelper.Encode: string;
begin
  {$IF CompilerVersion > 26}
  Result := TJson.JsonEncode(Self);
  {$ELSE}
  Result := Self.ToString;
  {$ENDIF}
end;

class function TGBJSONObjectHelper.Format(AValue: string): string;
var
  LJsonObject: TJSONObject;
begin
  Result := EmptyStr;
  LJsonObject := fromString(AValue);
  try
    Result := LJsonObject.Format;
  finally
    LJsonObject.Free;
  end;
end;

{$IF CompilerVersion <= 32.0}
function TGBJSONObjectHelper.Format: string;
begin
  Result := TJson.Format(Self);
end;
{$ENDIF}

class function TGBJSONObjectHelper.FromFile(AValue: string) : TJSONObject;
var
  LFileJSON: TStringList;
begin
  if not FileExists(AValue) then
    raise EFileNotFoundException.CreateFmt('File %s not found.', [AValue]);

  LFileJSON := TStringList.Create;
  try
    LFileJSON.LoadFromFile(AValue);
    Result := fromString(LFileJSON.Text);
  finally
    LFileJSON.Free;
  end;
end;

class function TGBJSONObjectHelper.FromObject(AValue: TObject): TJSONObject;
begin
  Result := TGBJSONDefault.Deserializer.ObjectToJsonObject(AValue);
end;

class function TGBJSONObjectHelper.fromString(AValue: string) : TJSONObject;
begin
  Result := TGBJSONDefault.Deserializer.StringToJsonObject(AValue);
end;

class function TGBJSONObjectHelper.ObjectToJSONString(AValue: TObject): string;
begin
  Result := TGBJSONDefault.Deserializer.ObjectToJsonString(AValue);
end;

procedure TGBJSONObjectHelper.SaveToFile(AFileName: string);
var
  LFileJSON: TStringList;
begin
  LFileJSON := TStringList.Create;
  try
    LFileJSON.Text := Self.Format;
    LFileJSON.SaveToFile(AFileName);
  finally
    LFileJSON.Free;
  end;
end;

function TGBJSONObjectHelper.SetValue(AName: string; AValue: Boolean): TJSONObject;
begin
  Result := Self;
  if AValue then
    Self.AddPair(AName, TJSONTrue.Create)
  else
    Self.AddPair(AName, TJSONFalse.Create)
end;

function TGBJSONObjectHelper.SetValue(AName: string; AValue: Integer): TJSONObject;
begin
  Result := Self;
  Self.AddPair(AName, TJSONNumber.Create(AValue));
end;

function TGBJSONObjectHelper.SetValue(AName: string; AValue: Double): TJSONObject;
begin
  Result := Self;
  Self.AddPair(AName, TJSONNumber.Create(AValue));
end;

function TGBJSONObjectHelper.SetValue(AName, AValue: string): TJSONObject;
begin
  Result := Self;
  Self.AddPair(AName, TJSONString.Create(AValue));
end;

procedure TGBJSONObjectHelper.ToObject(AValue: TObject; AUseIgnore: boolean = True);
begin
  TGBJSONDefault.Serializer(AUseIgnore).JsonObjectToObject(AValue, Self);
end;

function TGBJSONObjectHelper.ValueAsBoolean(AName: string; ADefault: Boolean): Boolean;
var
  LStrValue: string;
begin
  Result := ADefault;
  if GetValue(AName) <> nil then
  begin
    LStrValue := GetValue(AName).ToString;
    Result := not LStrValue.Equals('false');
  end;
end;

function TGBJSONObjectHelper.ValueAsDateTime(AName, AFormat: string; ADefault: TDateTime): TDateTime;
var
  LStrValue: string;
begin
  Result := ADefault;
  LStrValue := ValueAsString(AName, '0');
  Result.fromIso8601ToDateTime(LStrValue);
end;

function TGBJSONObjectHelper.ValueAsFloat(AName: string; ADefault: Double): Double;
var
  LStrValue: string;
begin
  LStrValue := ValueAsString(AName, ADefault.ToString);
  Result := StrToFloatDef(LStrValue, ADefault);
end;

function TGBJSONObjectHelper.ValueAsInteger(AName: string; ADefault: Integer): Integer;
var
  LStrValue: string;
begin
  LStrValue := ValueAsString(AName, ADefault.ToString);
  Result := StrToIntDef(LStrValue, ADefault);
end;

function TGBJSONObjectHelper.ValueAsJSONArray(AName: string): TJSONArray;
begin
  Result := nil;
  if GetValue(AName) is TJSONArray then
    Result := TJSONArray(GetValue(AName));
end;

function TGBJSONObjectHelper.ValueAsJSONObject(AName: string): TJSONObject;
begin
  Result := nil;
  if GetValue(AName) is TJSONObject then
    Result := TJSONObject(GetValue(AName));
end;

function TGBJSONObjectHelper.ValueAsString(AName, ADefault: string): string;
begin
  Result := ADefault;
  if GetValue(AName) <> nil then
    Result := GetValue(AName).Value;
end;

{ TObjectHelper }

procedure TObjectHelper.FromJSONObject(AValue: TJSONObject);
begin
  if Assigned(AValue) then
    AValue.ToObject(Self);
end;

procedure TObjectHelper.FromJSONString(AValue: string);
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.fromString(AValue);
  try
    if Assigned(LJSON) then
      fromJSONObject(LJSON);
  finally
    LJSON.Free;
  end;
end;

procedure TObjectHelper.SaveToJSONFile(AFileName: string);
var
  LJSON: TJSONObject;
begin
  LJSON := Self.ToJSONObject;
  try
    LJSON.SaveToFile(AFileName);
  finally
    LJSON.Free;
  end;
end;

function TObjectHelper.ToJSONObject: TJSONObject;
begin
  Result := TJSONObject.FromObject(Self);
end;

function TObjectHelper.ToJSONString(AFormat: Boolean): string;
begin
  Result := TJSONObject.ObjectToJSONString(Self);
  if AFormat then
    Result := TJSONObject.format(Result);
end;

{ TGBJSONArrayHelper }

{$IF CompilerVersion <= 26.0}
function TGBJSONArrayHelper.Count: Integer;
begin
  Result := Self.Size;
end;
{$ENDIF}

function TGBJSONArrayHelper.Encode: string;
begin
  {$IF CompilerVersion > 26}
  Result := TJson.JsonEncode(Self);
  {$ELSE}
  Result := Self.ToString;
  {$ENDIF}
end;

class function TGBJSONArrayHelper.FromString(AValue: string): TJSONArray;
begin
  Result := TJSONObject.ParseJSONValue(AValue) as TJSONArray;
end;

function TGBJSONArrayHelper.GetFields: TList<string>;
var
  I, J: Integer;
  LJSON: TJSONObject;
  LName: string;
begin
  Result := TList<string>.create;
  try
    for I := 0 to Pred(Self.Count) do
    begin
      LJSON := Self.ItemAsJSONObject(I);
      for J := 0 to Pred(LJSON.Count) do
      begin
        LName := LJSON.Pairs[J].JsonString.Value;
        if (not Result.Contains(LName)) and
           (not (LJSON.GetValue(LName) is TJSONObject)) and
           (not (LJSON.GetValue(LName) is TJSONArray))
        then
          Result.Add(LName);
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

{$IF CompilerVersion <= 26.0}
function TADRIFoodHelperJSONArray.GetItems(AIndex: Integer): TJSONValue;
begin
  {$IF CompilerVersion > 26.0}
  Result := Self.Items[AIndex];
  {$ELSE}
  Result := Self.Get(AIndex);
  {$ENDIF}
end;
{$ENDIF}

function TGBJSONArrayHelper.ItemAsBoolean(AIndex: Integer; AName: string; ADefault: Boolean): Boolean;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsBoolean(AName, ADefault);
end;

function TGBJSONArrayHelper.ItemAsDateTime(AIndex: Integer; AName, AFormat: string; Default: TDateTime): TDateTime;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsDateTime(AName, AFormat, Default);
end;

function TGBJSONArrayHelper.ItemAsFloat(AIndex: Integer; AName: string; ADefault: Double): Double;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsFloat(AName, ADefault);
end;

function TGBJSONArrayHelper.ItemAsInteger(AIndex: Integer; AName: string; ADefault: Integer): Integer;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsInteger(AName, ADefault);
end;

function TGBJSONArrayHelper.ItemAsJSONArray(AIndex: Integer): TJSONArray;
begin
  Result := {$IF CompilerVersion > 26.0} Items[AIndex] as TJSONArray; {$ELSE} Self.Get(AIndex) as TJSONArray; {$ENDIF}
end;

function TGBJSONArrayHelper.ItemAsJSONArray(AIndex: Integer; AName: string): TJSONArray;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsJSONArray(AName);
end;

function TGBJSONArrayHelper.ItemAsJSONObject(AIndex: Integer; AName: string): TJSONObject;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsJSONObject(AName);
end;

function TGBJSONArrayHelper.ItemAsJSONObject(AIndex: Integer): TJSONObject;
begin
  Result := {$IF CompilerVersion > 26.0} Items[AIndex] as TJSONObject; {$ELSE} Self.Get(AIndex) as TJSONObject; {$ENDIF}
end;

function TGBJSONArrayHelper.ItemAsString(AIndex: Integer; AName, ADefault: string): string;
var
  LJSON: TJSONObject;
begin
  LJSON := ItemAsJSONObject(AIndex);
  Result := LJSON.ValueAsString(AName, ADefault);
end;

class function TGBJSONArrayHelper.ToCsv(AJSONContent: string; ASeparator: string): string;
var
  LJSONArray: TJSONArray;
begin
  LJSONArray := Self.FromString(AJSONContent);
  try
    Result := LJSONArray.ToCsv(ASeparator);
  finally
    LJSONArray.Free;
  end;
end;

class procedure TGBJSONArrayHelper.ToCsvFile(AJSONContent, AFileName: string; ASeparator: string);
var
  LJSONArray: TJSONArray;
begin
  LJSONArray := FromString(AJSONContent);
  try
    LJSONArray.ToCsvFile(AFileName, ASeparator);
  finally
    LJSONArray.Free;
  end;
end;

procedure TGBJSONArrayHelper.ToCsvFile(AFileName: string; ASeparator: string);
begin
  with TStringList.Create do
  try
    Text := Self.ToCsv(ASeparator);
    SaveToFile(AFileName);
  finally
    Free;
  end;
end;

function TGBJSONArrayHelper.ToCsv(ASeparator: string = ';'): string;
var
  LFields: TList<string>;
  LCsv: TStrings;
  LLine: string;
  I, J: Integer;
begin
  LFields := GetFields;
  try
    LCsv := TStringList.Create;
    try
      for I := 0 to Pred(LFields.Count) do
      begin
        if I = 0 then
          LLine := '"' + LFields[I] + '"'
        else
          LLine := LLine + ASeparator + '"' + LFields[I] + '"';
      end;

      LCsv.Add(LLine);
      for I := 0 to Pred(Self.Count) do
      begin
        LLine := EmptyStr;
        for J := 0 to Pred(LFields.Count) do
        begin
          if J = 0 then
            LLine := '"' + Self.ItemAsString(I, LFields[J]) + '"'
          else
            LLine := LLine + ASeparator + '"' + Self.ItemAsString(I, LFields[J]) + '"';
        end;
        LCsv.Add(LLine);
      end;

      Result := LCsv.Text;
    finally
      LCsv.Free;
    end;
  finally
    LFields.Free;
  end;
end;

end.
