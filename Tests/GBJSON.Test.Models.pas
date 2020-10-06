unit GBJSON.Test.Models;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TTipoPessoa = (tpFisica, tpJuridica);

  TTelefone = class
  private
    FidTel: Double;
    Fnumero: string;
    public
      property idTel: Double read FidTel write FidTel;
      property numero: string read Fnumero write Fnumero;
  end;

  TEndereco = class
  private
    FidEndereco: string;
    Flogradouro: string;
    public
      property idEndereco: string read FidEndereco write FidEndereco;
      property logradouro: string read Flogradouro write Flogradouro;
  end;

  TPessoa = class
  private
    FidPessoa: Double;
    Fnome: string;
    Fendereco: TEndereco;
    Ftelefones: TObjectList<TTelefone>;
    FtipoPessoa: TTipoPessoa;
    Fidade: Integer;
    FdataCadastro: TDateTime;
    Fobservacao: String;
    Fmedia: Double;
    Fativo: Boolean;
    public
      property idPessoa: Double read FidPessoa write FidPessoa;
      property nome: string read Fnome write Fnome;
      property idade: Integer read Fidade write Fidade;
      property dataCadastro: TDateTime read FdataCadastro write FdataCadastro;
      property media: Double read Fmedia write Fmedia;
      property ativo: Boolean read Fativo write Fativo;
      property observacao: String read Fobservacao write Fobservacao;
      property endereco: TEndereco read Fendereco write Fendereco;
      property tipoPessoa: TTipoPessoa read FtipoPessoa write FtipoPessoa;
      property telefones: TObjectList<TTelefone> read Ftelefones write Ftelefones;

      class function CreatePessoa: TPessoa;

      constructor create;
      destructor  Destroy; override;
  end;

implementation

{ TPessoa }

constructor TPessoa.create;
begin
  FtipoPessoa := tpFisica;
  Fendereco   := TEndereco.Create;
  Ftelefones  := TObjectList<TTelefone>.Create;
  Fativo      := False;
end;

class function TPessoa.CreatePessoa: TPessoa;
begin
  result := TPessoa.Create;
  Result.idPessoa := 1;
  Result.nome := 'Teste';
  Result.idade := 18;
  Result.media := 10;
  Result.dataCadastro := Now;
  Result.endereco.idEndereco := '2';
  Result.endereco.logradouro := 'Teste';
  Result.telefones.Add(TTelefone.Create);
  Result.telefones.Last.idTel := 3;
  Result.telefones.Last.numero := '321654987';

  Result.telefones.Add(TTelefone.Create);
  Result.telefones.Last.idTel := 4;
  Result.telefones.Last.numero := '11111111';
end;

destructor TPessoa.Destroy;
begin
  Fendereco.Free;
  Ftelefones.Free;
  inherited;
end;

end.

