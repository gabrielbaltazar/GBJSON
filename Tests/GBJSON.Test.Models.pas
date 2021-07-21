unit GBJSON.Test.Models;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TPersonType = (tpFisica, tpJuridica);

  TPhone = class
  private
    FidTel: Double;
    Fnumber: string;
  public
    property idTel: Double read FidTel write FidTel;
    property number: string read Fnumber write Fnumber;
  end;

  TAddress = class
  private
    FidAddress: string;
    Fstreet: string;
  public
    property idAddress: string read FidAddress write FidAddress;
    property street: string read Fstreet write Fstreet;
  end;

  TPerson = class
  private
    FidPerson: Double;
    Fname: string;
    Faddress: TAddress;
    Fphones: TObjectList<TPhone>;
    FpersonType: TPersonType;
    Fage: Integer;
    FcreationDate: TDateTime;
    Fobs: String;
    Faverage: Double;
    Factive: Boolean;
    Fnotes: TList<Double>;
    Fqualities: TArray<String>;
    Fdocument_number: String;
  public
    property qualities: TArray<String> read Fqualities write Fqualities;
    property idPerson: Double read FidPerson write FidPerson;
    property name: string read Fname write Fname;
    property document_number: String read Fdocument_number write Fdocument_number;
    property age: Integer read Fage write Fage;
    property creationDate: TDateTime read FcreationDate write FcreationDate;
    property average: Double read Faverage write Faverage;
    property active: Boolean read Factive write Factive;
    property obs: String read Fobs write Fobs;
    property address: TAddress read Faddress write Faddress;
    property personType: TPersonType read FpersonType write FpersonType;
    property phones: TObjectList<TPhone> read Fphones write Fphones;
    property notes: TList<Double> read Fnotes write Fnotes;

    class function CreatePerson: TPerson;

    constructor create;
    destructor  Destroy; override;
  end;

  TUpperPerson = class
  private
    FPERSON_ID: Double;
    FPERSON_NAME: string;
  public
    property PERSON_ID: Double read FPERSON_ID write FPERSON_ID;
    property PERSON_NAME: string read FPERSON_NAME write FPERSON_NAME;

    class function CreatePerson: TUpperPerson;
  end;

implementation

{ TPerson }

constructor TPerson.create;
begin
  FpersonType := tpFisica;
  Faddress   := TAddress.Create;
  Fphones  := TObjectList<TPhone>.Create;
  Fnotes   := TList<Double>.create;
  Factive      := False;
end;

class function TPerson.CreatePerson: TPerson;
begin
  result := TPerson.Create;
  Result.idPerson := 1;
  Result.name := 'Teste';
  Result.age := 18;
  Result.average := 10;
  Result.creationDate := Now;
  Result.address.idAddress := '2';
  Result.address.street := 'Teste';
  Result.phones.Add(TPhone.Create);
  Result.phones.Last.idTel := 3;
  Result.phones.Last.number := '321654987';

  Result.phones.Add(TPhone.Create);
  Result.phones.Last.idTel := 4;
  Result.phones.Last.number := '11111111';

  Result.notes.AddRange([5, 6]);

  Result.qualities := ['q1', 'q2'];
end;

destructor TPerson.Destroy;
begin
  Faddress.Free;
  Fphones.Free;
  Fnotes.Free;
  inherited;
end;

{ TUpperPerson }

class function TUpperPerson.CreatePerson: TUpperPerson;
begin
  result := TUpperPerson.Create;
  result.FPERSON_ID := 1;
  result.FPERSON_NAME := 'Person Test';
end;

end.

