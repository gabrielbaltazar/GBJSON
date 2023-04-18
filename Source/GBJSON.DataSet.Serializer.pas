unit GBJSON.DataSet.Serializer;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  GBJSON.DataSet.Interfaces,
  GBJSON.RTTI,
  GBJSON.Serializer,
  GBJSON.DateTime.Helper,
  System.Generics.Collections,
  System.JSON,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  Data.DB;

type
  TGBJSONDataSetSerializer<T: class, constructor> = class(TInterfacedObject, IGBJSONDataSetSerializer<T>)
  private
    FClearDataSet: Boolean;

    procedure ClearDataSet(ADataSet: TDataSet); overload;
    procedure CreateFields(ADataSet: TDataSet);
    procedure FillDataSet(ADataSet: TDataSet; AObject: TObject);
  protected
    function ClearDataSet(AValue: Boolean): IGBJSONDataSetSerializer<T>; overload;

    procedure JsonObjectToDataSet(AValue: TJSONObject; ADataSet: TDataSet);
    procedure JsonArrayToDataSet(AValue: TJSONArray; ADataSet: TDataSet);

    procedure ObjectToDataSet(AValue: TObject; ADataSet: TDataSet);
    procedure ObjectListToDataSet(AValue: TObjectList<T>; ADataSet: TDataSet);
  public
    constructor Create;
    class function New: IGBJSONDataSetSerializer<T>;
  end;

implementation

{ TGBJSONDataSetSerializer<T> }

function TGBJSONDataSetSerializer<T>.ClearDataSet(AValue: Boolean): IGBJSONDataSetSerializer<T>;
begin
  Result := Self;
  FClearDataSet := AValue;
end;

procedure TGBJSONDataSetSerializer<T>.ClearDataSet(ADataSet: TDataSet);
begin
  ADataSet.DisableControls;
  try
    ADataSet.First;
    while not ADataSet.Eof do
      ADataSet.Delete;
  finally
    ADataSet.EnableControls;
  end;
end;

constructor TGBJSONDataSetSerializer<T>.Create;
begin
  FClearDataSet := False;
end;

procedure TGBJSONDataSetSerializer<T>.CreateFields(ADataSet: TDataSet);
var
  LProperty: TRttiProperty;
  LType: TRttiType;
  LName: String;
  LObject: T;
begin
  LObject := T.create;
  try
    LType := TGBRTTI.GetInstance.GetType(LObject.ClassType);
    for LProperty in LType.GetProperties do
    begin
      try
        LName := LProperty.JSONName;

        if LProperty.IsString then
        begin
          ADataSet.FieldDefs.Add(LName, ftString, 4000, False);
          Continue;
        end;

        if LProperty.IsVariant then
        begin
          ADataSet.FieldDefs.Add(LName, ftString, 4000, False);
          Continue;
        end;

        if LProperty.IsInteger then
        begin
          ADataSet.FieldDefs.Add(LName, ftInteger);
          Continue;
        end;

        if LProperty.IsEnum then
        begin
          ADataSet.FieldDefs.Add(LName, ftString, 4000, False);
          Continue;
        end;

        if LProperty.IsObject then
          Continue;

        if LProperty.IsFloat then
        begin
          ADataSet.FieldDefs.Add(LName, ftFloat);
          Continue;
        end;

        if LProperty.IsDateTime then
        begin
          ADataSet.FieldDefs.Add(LName, ftDateTime);
          Continue;
        end;

        if LProperty.IsList then
          Continue;

        if LProperty.IsBoolean then
        begin
          ADataSet.FieldDefs.Add(LName, ftBoolean);
          Continue;
        end;

        if LProperty.IsArray then
          Continue;
      except
        on E : Exception do
        begin
          E.Message := Format('Error on read property %s from json: %s', [ LProperty.Name, E.message ]);
          raise;
        end;
      end;
    end;

    ADataSet.InvokeMethod('createDataSet', []);
    if not ADataSet.Active then
      ADataSet.Active := True;
  finally
    LObject.Free;
  end;
end;

procedure TGBJSONDataSetSerializer<T>.FillDataSet(ADataSet: TDataSet; AObject: TObject);
var
  LProperty: TRttiProperty;
  LType: TRttiType;
  LName: string;
  LField: TField;
  LValue: TValue;
begin
  LType := TGBRTTI.GetInstance.GetType(AObject.ClassType);
  ADataSet.Append;
  try
    for LProperty in LType.GetProperties do
    begin
      LName := LProperty.JSONName;
      LField := ADataSet.FindField(LName);
      if not Assigned(LField) then
        Continue;

      LValue := LProperty.GetValue(AObject);
      LField.Value := LValue.AsVariant;
    end;

    ADataSet.Post;
  except
    on E: Exception do
    begin
      E.Message := Format('Error on fill property %s from object: %s', [ LProperty.Name, E.Message ]);
      raise;
    end;
  end;
end;

procedure TGBJSONDataSetSerializer<T>.JsonArrayToDataSet(AValue: TJSONArray; ADataSet: TDataSet);
var
  LList: TObjectList<T>;
begin
  LList := TGBJSONSerializer<T>.New(False).JsonArrayToList(AValue);
  try
    ObjectListToDataSet(LList, ADataSet);
  finally
    LList.Free;
  end;
end;

procedure TGBJSONDataSetSerializer<T>.JsonObjectToDataSet(AValue: TJSONObject; ADataSet: TDataSet);
var
  LObject: T;
begin
  LObject := TGBJSONSerializer<T>.New(False).JsonObjectToObject(AValue);
  try
    ObjectToDataSet(LObject, ADataSet);
  finally
    LObject.Free;
  end;
end;

class function TGBJSONDataSetSerializer<T>.New: IGBJSONDataSetSerializer<T>;
begin
  Result := Self.Create;
end;

procedure TGBJSONDataSetSerializer<T>.ObjectListToDataSet(AValue: TObjectList<T>; ADataSet: TDataSet);
var
  LObject: T;
begin
  try
    if (ADataSet.FieldCount > 0) and (FClearDataSet) then
      ClearDataSet(ADataSet);

    if ADataSet.FieldCount = 0 then
      CreateFields(ADataSet);

    for LObject in AValue do
      FillDataSet(ADataSet, LObject);

    ADataSet.First;
  finally
    FClearDataSet := False;
  end;
end;

procedure TGBJSONDataSetSerializer<T>.ObjectToDataSet(AValue: TObject; ADataSet: TDataSet);
begin
  try
    if (ADataSet.FieldCount > 0) and (FClearDataSet) then
      ClearDataSet(ADataSet);

    if ADataSet.FieldCount = 0 then
      CreateFields(ADataSet);

    if Assigned(AValue) then
      FillDataSet(ADataSet, AValue);
  finally
    FClearDataSet := False;
  end;
end;

end.
