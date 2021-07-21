# GBJSON
Parse Delphi Objects to JSON Objects

## Object To JSON
```delphi

uses
  GBJSON.Helper;
  
type TClient = class
  private
    FidClient: Double;
    Fname: String;
    FdateOfBirthday: TDateTime;
  public
    property idClient: Double read FidClient write FidClient;
    property name: String read Fname write Fname;
    property dateOfBirthday: TDateTime read FdateOfBirthday write FdateOfBirthday;
  end;
  
function objectToJSON: String;
var
  client: TClient;
begin
  client := TClient.create;
  try
    client.idClient := 1;
    client.name := 'Client 1';
    client.dateOfBirthday := now;
    
    result := client.ToJSONString;
  finally
    client.Free;
  end;
end;

```

## JSON to Object 
```delphi

uses
  System.JSON,
  GBJSON.Helper;
  
type TClient = class
  private
    FidClient: Double;
    Fname: String;
    FdateOfBirthday: TDateTime;
  public
    property idClient: Double read FidClient write FidClient;
    property name: String read Fname write Fname;
    property dateOfBirthday: TDateTime read FdateOfBirthday write FdateOfBirthday;
  end;
  
function JSONToObject: TClient;
var
  json: TJSONObject;
begin
  json := TJSONObject.create;
  try
    json.AddPair('idClient', TJSONNumber.Create(1))
        .AddPair('name', 'Client 1')
        .AddPair('dateOfBirthday', '1990-02-01');
        
    result := TClient.create;
    result.fromJSONObject(json);
  finally
    json.Free;
  end;
end;

```

## Object To JSON Lower Case
```delphi

uses
  GBJSON.Helper,
  GBJSON.Config;
  
type TClient = class
  private
    FIDCLIENT: Double;
    FNAME: String;
    FDATEOFBIRTHDAY: TDateTime;
  public
    property IDCLIENT: Double read FIDCLIENT write FIDCLIENT;
    property NAME: String read FNAME write FNAME;
    property DATEOFBIRTHDAY: TDateTime read FDATEOFBIRTHDAY write FDATEOFBIRTHDAY;
  end;
  
function objectToJSON: String;
var
  client: TClient;
begin
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLower);
  client := TClient.create;
  try
    client.IDCLIENT := 1;
    client.NAME := 'Client 1';
    client.DATEOFBIRTHDAY := now;
    
    result := client.ToJSONString;
  finally
    client.Free;
  end;
end;
```

## JSON to Object Lower Case
```delphi

uses
  System.JSON,
  GBJSON.Helper;
  
type TClient = class
  private
    FIDCLIENT: Double;
    FNAME: String;
    FDATEOFBIRTHDAY: TDateTime;
  public
    property IDCLIENT: Double read FIDCLIENT write FIDCLIENT;
    property NAME: String read FNAME write FNAME;
    property DATEOFBIRTHDAY: TDateTime read FDATEOFBIRTHDAY write FDATEOFBIRTHDAY;
  end;
  
function JSONToObject: TClient;
var
  json: TJSONObject;
begin
  TGBJSONConfig.GetInstance.CaseDefinition(TCaseDefinition.cdLower);
  json := TJSONObject.create;
  try
    json.AddPair('idclient', TJSONNumber.Create(1))
        .AddPair('name', 'Client 1')
        .AddPair('dateofbirthday', '1990-02-01');
        
    result := TClient.create;
    result.fromJSONObject(json);
  finally
    json.Free;
  end;
end;

```
