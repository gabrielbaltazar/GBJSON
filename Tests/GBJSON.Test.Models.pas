unit GBJSON.Test.Models;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  GBJSON.Attributes;

type
  TPersonType = (tpFisica, tpJuridica);

  TPhone = class
  private
    FIdTel: Double;
    FNumber: string;
  public
    property IdTel: Double read FIdTel write FIdTel;
    property Number: string read FNumber write FNumber;
  end;

  TAddress = class
  private
    FIdAddress: string;
    FStreet: string;
  public
    property IdAddress: string read FIdAddress write FIdAddress;
    property Street: string read FStreet write FStreet;
  end;

  TPerson = class
  private
    FIdPerson: Double;
    FName: string;
    FAddress: TAddress;
    FPhones: TObjectList<TPhone>;
    FPersonType: TPersonType;
    FAge: Integer;
    FCreationDate: TDateTime;
    FObs: string;
    FAverage: Double;
    FActive: Boolean;
    FNotes: TList<Double>;
    FQualities: TArray<string>;
    FDocument_Number: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function CreatePerson: TPerson;

    property Qualities: TArray<string> read FQualities write FQualities;
    property IdPerson: Double read FIdPerson write FIdPerson;
    property Name: string read FName write FName;
    property Document_Number: string read FDocument_Number write FDocument_Number;
    property Age: Integer read FAge write FAge;
    property CreationDate: TDateTime read FCreationDate write FCreationDate;
    property Average: Double read FAverage write FAverage;
    property Active: Boolean read FActive write FActive;
    [JsonName('Observacao')]
    property Obs: string read FObs write FObs;
    property Address: TAddress read FAddress write FAddress;
    property PersonType: TPersonType read FPersonType write FPersonType;
    property Phones: TObjectList<TPhone> read FPhones write FPhones;
    property Notes: TList<Double> read FNotes write FNotes;
  end;

  TUpperPerson = class
  private
    FPERSON_ID: Double;
    FPERSON_NAME: string;
  public
    class function CreatePerson: TUpperPerson;

    property PERSON_ID: Double read FPERSON_ID write FPERSON_ID;
    property PERSON_NAME: string read FPERSON_NAME write FPERSON_NAME;
  end;

implementation

{ TPerson }

constructor TPerson.create;
begin
  FPersonType := tpFisica;
  FAddress := TAddress.Create;
  FPhones := TObjectList<TPhone>.Create;
  FNotes := TList<Double>.Create;
  FActive := False;
end;

class function TPerson.CreatePerson: TPerson;
begin
  Result := TPerson.Create;
  Result.IdPerson := 1;
  Result.name := 'Teste';
  Result.Age := 18;
  Result.Average := 10;
  Result.CreationDate := Now;
  Result.Address.IdAddress := '2';
  Result.Address.Street := 'Teste';
  Result.Phones.Add(TPhone.Create);
  Result.Phones.Last.IdTel := 3;
  Result.Phones.Last.Number := '321654987';

  Result.Phones.Add(TPhone.Create);
  Result.Phones.Last.IdTel := 4;
  Result.Phones.Last.Number := '11111111';

  Result.Notes.AddRange([5, 6]);

  Result.Qualities := ['q1', 'q2'];
end;

destructor TPerson.Destroy;
begin
  FAddress.Free;
  FPhones.Free;
  FNotes.Free;
  inherited;
end;

{ TUpperPerson }

class function TUpperPerson.CreatePerson: TUpperPerson;
begin
  Result := TUpperPerson.Create;
  Result.FPERSON_ID := 1;
  Result.FPERSON_NAME := 'Person Test';
end;

end.

