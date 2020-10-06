unit SampleModel;

interface

uses
  System.Generics.Collections,
  System.SysUtils;

type
  TPhoneType = (ptFixed, ptMobile, ptOffice);
  TAddress = class;
  TPhone = class;

  TClient = class
  private
    FidClient: Double;
    Fname: String;
    FdateOfBirthday: TDateTime;
    Faddress: TAddress;
    Fphones: TObjectList<TPhone>;
  public
    property idClient: Double read FidClient write FidClient;
    property name: String read Fname write Fname;
    property dateOfBirthday: TDateTime read FdateOfBirthday write FdateOfBirthday;
    property address: TAddress read Faddress write Faddress;
    property phones: TObjectList<TPhone> read Fphones write Fphones;

    constructor create;
    destructor  Destroy; override;

    class function NewClient: TClient;
  end;

  TAddress = class
  private
    Faddress: String;
    Fnumber: Integer;
    Fcity: string;
    FzipCode: string;
  public
    property address: String read Faddress write Faddress;
    property number: Integer read Fnumber write Fnumber;
    property city: string read Fcity write Fcity;
    property zipCode: string read FzipCode write FzipCode;
  end;

  TPhone = class
  private
    Fnumber: string;
    FphoneType: TPhoneType;
    FvariantValue: Variant;
  public
    property phoneType: TPhoneType read FphoneType write FphoneType;
    property number: string read Fnumber write Fnumber;
    property variantValue: Variant read FvariantValue write FvariantValue;
  end;

implementation

{ TClient }

constructor TClient.create;
begin
  Faddress := TAddress.Create;
  Fphones  := TObjectList<TPhone>.create;
end;

destructor TClient.Destroy;
begin
  Faddress.Free;
  Fphones.Free;
  inherited;
end;

class function TClient.NewClient: TClient;
var
  index: Integer;
begin
  result := Self.create;
  Result.idClient := 5;
  Result.name := 'Client 1';
  result.dateOfBirthday := Now;
  Result.address.address := 'Street 1 \ 2 / 3';
  Result.address.number := 15;
  Result.address.city := 'Center';

  index := Result.phones.Add(TPhone.Create);
  Result.phones[index].phoneType := ptMobile;
  Result.phones[index].number := '99999999';
  Result.phones[index].variantValue := 5;

  index := Result.phones.Add(TPhone.Create);
  Result.phones[index].phoneType := ptFixed;
  Result.phones[index].number := '8888888';
  Result.phones[index].variantValue := 'Some Text';

  index := Result.phones.Add(TPhone.Create);
  Result.phones[index].phoneType := ptFixed;
  Result.phones[index].number := '777777';
  Result.phones[index].variantValue := Now;
end;

end.
