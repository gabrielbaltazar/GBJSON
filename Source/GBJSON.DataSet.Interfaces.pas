unit GBJSON.DataSet.Interfaces;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.Generics.Collections,
  System.JSON,
  Data.DB;

type
  IGBJSONDataSetSerializer<T: class, constructor> = interface
    ['{D28B21EC-010B-4641-B04C-37832B193F75}']
    function ClearDataSet(AValue: Boolean): IGBJSONDataSetSerializer<T>;

    procedure JsonObjectToDataSet(AValue: TJSONObject; ADataSet: TDataSet);
    procedure JsonArrayToDataSet(AValue: TJSONArray; ADataSet: TDataSet);

    procedure ObjectToDataSet(AValue: TObject; ADataSet: TDataSet);
    procedure ObjectListToDataSet(AValue: TObjectList<T>; ADataSet: TDataSet);
  end;

implementation

end.
