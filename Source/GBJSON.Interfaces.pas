unit GBJSON.Interfaces;

interface

uses
  System.JSON,
  System.Generics.Collections;

type
  IGBJSONSerializer<T: class, constructor> = interface
    ['{F808BE4D-AF1A-4BDF-BF3B-945C39762853}']
    procedure JsonObjectToObject(AObject: TObject; Value: TJSONObject); overload;
    function  JsonObjectToObject(Value: TJSONObject): T; overload;
    function  JsonStringToObject(Value: String): T;

    function JsonArrayToList (Value: TJSONArray): TObjectList<T>;
    function JsonStringToList(Value: String): TObjectList<T>;
  end;

  IGBJSONDeserializer<T: class, constructor> = interface
    ['{C61D8875-A70B-4E65-911E-776FECC610F4}']
    function ObjectToJsonString(Value: TObject): string;
    function ObjectToJsonObject(Value: TObject): TJSONObject;
    function StringToJsonObject(Value: string) : TJSONObject;

    function ListToJSONArray(AList: TObjectList<T>): TJSONArray;
  end;

  TGBJSONDefault = class
    public
      class function Serializer(bUseIgnore: boolean = True): IGBJSONSerializer<TObject>; overload;
      class function Serializer<T: class, constructor>(bUseIgnore: boolean = True): IGBJSONSerializer<T>; overload;

      class function Deserializer(bUseIgnore: boolean = True): IGBJSONDeserializer<TObject>; overload;
      class function Deserializer<T: class, constructor>(bUseIgnore: boolean = True): IGBJSONDeserializer<T>; overload;
  end;

implementation

uses
  GBJSON.Serializer,
  GBJSON.Deserializer;

class function TGBJSONDefault.Deserializer(bUseIgnore: boolean = True): IGBJSONDeserializer<TObject>;
begin
  result := TGBJSONDeserializer<TObject>.New(bUseIgnore);
end;

class function TGBJSONDefault.Deserializer<T>(bUseIgnore: boolean = True): IGBJSONDeserializer<T>;
begin
  result := TGBJSONDeserializer<T>.New(bUseIgnore);
end;

class function TGBJSONDefault.Serializer(bUseIgnore: boolean): IGBJSONSerializer<TObject>;
begin
  Result := TGBJSONSerializer<TObject>.New(bUseIgnore);
end;

class function TGBJSONDefault.Serializer<T>(bUseIgnore: boolean): IGBJSONSerializer<T>;
begin
  Result := TGBJSONSerializer<T>.New(bUseIgnore);
end;

end.
