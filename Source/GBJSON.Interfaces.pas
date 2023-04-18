unit GBJSON.Interfaces;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  GBJSON.Config,
  System.JSON,
  System.Generics.Collections;

type
  TGBJSONConfig = GBJSON.Config.TGBJSONConfig;
  TCaseDefinition = GBJSON.Config.TCaseDefinition;

  IGBJSONSerializer<T: class, constructor> = interface
    ['{F808BE4D-AF1A-4BDF-BF3B-945C39762853}']
    procedure JsonObjectToObject(AObject: TObject; AValue: TJSONObject); overload;
    function JsonObjectToObject(AValue: TJSONObject): T; overload;
    function JsonStringToObject(AValue: string): T;
    function JsonArrayToList(AValue: TJSONArray): TObjectList<T>;
    function JsonStringToList(AValue: string): TObjectList<T>;
  end;

  IGBJSONDeserializer<T: class, constructor> = interface
    ['{C61D8875-A70B-4E65-911E-776FECC610F4}']
    function ObjectToJsonString(AValue: TObject): string;
    function ObjectToJsonObject(AValue: TObject): TJSONObject;
    function StringToJsonObject(AValue: string) : TJSONObject;
    function ListToJSONArray(AList: TObjectList<T>): TJSONArray;
  end;

  TGBJSONDefault = class
  public
    class function Serializer(AUseIgnore: Boolean = True): IGBJSONSerializer<TObject>; overload;
    class function Serializer<T: class, constructor>(AUseIgnore: Boolean = True): IGBJSONSerializer<T>; overload;
    class function Deserializer(AUseIgnore: Boolean = True): IGBJSONDeserializer<TObject>; overload;
    class function Deserializer<T: class, constructor>(AUseIgnore: Boolean = True): IGBJSONDeserializer<T>; overload;
  end;

implementation

uses
  GBJSON.Serializer,
  GBJSON.Deserializer;

class function TGBJSONDefault.Deserializer(AUseIgnore: Boolean = True): IGBJSONDeserializer<TObject>;
begin
  Result := TGBJSONDeserializer<TObject>.New(AUseIgnore);
end;

class function TGBJSONDefault.Deserializer<T>(AUseIgnore: Boolean = True): IGBJSONDeserializer<T>;
begin
  Result := TGBJSONDeserializer<T>.New(AUseIgnore);
end;

class function TGBJSONDefault.Serializer(AUseIgnore: Boolean): IGBJSONSerializer<TObject>;
begin
  Result := TGBJSONSerializer<TObject>.New(AUseIgnore);
end;

class function TGBJSONDefault.Serializer<T>(AUseIgnore: Boolean): IGBJSONSerializer<T>;
begin
  Result := TGBJSONSerializer<T>.New(AUseIgnore);
end;

end.
