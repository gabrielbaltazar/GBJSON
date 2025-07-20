unit GBJSON.Firedac.Interfaces;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.Generics.Collections,
  FireDAC.Phys.MongoDBWrapper,
  GBJSON.Config;

type
  IGBJSONFDDeserializer<T: class, constructor> = interface
    ['{9927AF0C-3C9A-4605-B1EF-CD3ADF01AD80}']
    function CaseDefinition(const AValue: TCaseDefinition): IGBJSONFDDeserializer<T>;
    function ObjectToMongoDocument(const AValue: TObject): TMongoDocument;
    function ListToMongoDocument(const APropName: string; const AList: TObjectList<T>): TMongoDocument;
  end;

  IGBJSONFDSerializer<T: class, constructor> = interface
    ['{C76B77BB-FEEF-4B4A-8F8E-2EF88E194758}']
    function CaseDefinition(const AValue: TCaseDefinition): IGBJSONFDSerializer<T>;
    function DocumentToObject(const ADocument: TMongoDocument): T; overload;
    procedure DocumentToObject(const ADocument: TMongoDocument; AObject: TObject); overload;
  end;

  TGBJSONFDDefault = class
  public
    class function Serializer(AConnection: TMongoConnection; AUseIgnore: Boolean = True): IGBJSONFDSerializer<TObject>; overload;
    class function Serializer<T: class, constructor>(AConnection: TMongoConnection;
      AUseIgnore: Boolean = True): IGBJSONFDSerializer<T>; overload;
    class function Deserializer(AConnection: TMongoConnection; AUseIgnore: Boolean = True): IGBJSONFDDeserializer<TObject>; overload;
    class function Deserializer<T: class, constructor>(AConnection: TMongoConnection;
      AUseIgnore: Boolean = True): IGBJSONFDDeserializer<T>; overload;
  end;

implementation

{ TGBJSONFDDefault }

uses
  GBJSON.Firedac.Deserializer,
  GBJSON.Firedac.Serializer;

class function TGBJSONFDDefault.Deserializer(AConnection: TMongoConnection;
  AUseIgnore: Boolean): IGBJSONFDDeserializer<TObject>;
begin
  Result := TGBJSONFiredacDeserializer<TObject>.New(AConnection, AUseIgnore);
end;

class function TGBJSONFDDefault.Deserializer<T>(AConnection: TMongoConnection; AUseIgnore: Boolean): IGBJSONFDDeserializer<T>;
begin
  Result := TGBJSONFiredacDeserializer<T>.New(AConnection, AUseIgnore);
end;

class function TGBJSONFDDefault.Serializer(AConnection: TMongoConnection; AUseIgnore: Boolean): IGBJSONFDSerializer<TObject>;
begin
  Result := TGBJSONFiredacSerializer<TObject>.New(AConnection, AUseIgnore);
end;

class function TGBJSONFDDefault.Serializer<T>(AConnection: TMongoConnection; AUseIgnore: Boolean): IGBJSONFDSerializer<T>;
begin
  Result := TGBJSONFiredacSerializer<T>.New(AConnection, AUseIgnore);
end;

end.
