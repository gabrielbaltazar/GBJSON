unit GBJSON.Firedac.Interfaces;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.Generics.Collections,
  FireDAC.Phys.MongoDBWrapper;

type
  IGBJSONFDDeserializer<T: class, constructor> = interface
    ['{9927AF0C-3C9A-4605-B1EF-CD3ADF01AD80}']
    function ObjectToMongoDocument(AValue: TObject): TMongoDocument;
    function ListToMongoDocument(AList: TObjectList<T>): TMongoDocument;
  end;

implementation

end.
