unit GBJSON.Firedac.Serializer;

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
  System.JSON,
  FireDAC.Phys.MongoDBWrapper,
  GBJSON.RTTI,
  GBJSON.Config,
  GBJSON.Firedac.Interfaces;

type
  TGBJSONFiredacSerializer<T: class, constructor> = class(TInterfacedObject,
    IGBJSONFDSerializer<T>)
  private
    FConnection: TMongoConnection;
    FUseIgnore: Boolean;
    FOriginalCaseDefinition: TCaseDefinition;
    FCaseDefinition: TCaseDefinition;
  protected
    function CaseDefinition(const AValue: TCaseDefinition): IGBJSONFDSerializer<T>;
    function DocumentToObject(const ADocument: TMongoDocument): T; overload;
    procedure DocumentToObject(const ADocument: TMongoDocument; AObject: TObject); overload;
  public
    constructor Create(AConnection: TMongoConnection; AUseIgnore: Boolean = True);
    class function New(AConnection: TMongoConnection; AUseIgnore: Boolean = True): IGBJSONFDSerializer<T>;
  end;

implementation

{ TGBJSONFiredacSerializer<T> }

uses
  GBJSON.Interfaces;

function TGBJSONFiredacSerializer<T>.CaseDefinition(
  const AValue: TCaseDefinition): IGBJSONFDSerializer<T>;
begin
  Result := Self;
  FCaseDefinition := AValue;
end;

constructor TGBJSONFiredacSerializer<T>.Create(AConnection: TMongoConnection;
  AUseIgnore: Boolean);
begin
  FConnection := AConnection;
  FUseIgnore := AUseIgnore;
  FCaseDefinition := TGBJSONConfig.GetInstance.CaseDefinition;
  FOriginalCaseDefinition := FCaseDefinition;
end;

function TGBJSONFiredacSerializer<T>.DocumentToObject(const ADocument: TMongoDocument): T;
begin
  if not Assigned(ADocument) then
    Exit(nil);

  Result := T.Create;
  try
    DocumentToObject(ADocument, Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TGBJSONFiredacSerializer<T>.DocumentToObject(const ADocument: TMongoDocument;
  AObject: TObject);
var
  LJSON: TJSONObject;
begin
  if (not Assigned(ADocument)) or (not Assigned(AObject)) then
    Exit;

  TGBJSONConfig.GetInstance.CaseDefinition(FCaseDefinition);
  try
    LJSON := TJSONObject.ParseJSONValue(ADocument.AsJSON) as TJSONObject;
    try
      if Assigned(LJSON) then
        TGBJSONDefault.Serializer(FUseIgnore).JsonObjectToObject(AObject, LJSON);
    finally
      LJSON.Free;
    end;
  finally
    TGBJSONConfig.GetInstance.CaseDefinition(FOriginalCaseDefinition);
  end;
end;

class function TGBJSONFiredacSerializer<T>.New(AConnection: TMongoConnection;
  AUseIgnore: Boolean): IGBJSONFDSerializer<T>;
begin
  Result := Self.Create(AConnection, AUseIgnore);
end;

end.
