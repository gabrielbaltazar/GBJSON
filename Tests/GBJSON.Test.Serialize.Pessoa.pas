unit GBJSON.Test.Serialize.Pessoa;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.DateTime.Helper,
  GBJSON.Interfaces,
  System.JSON,
  System.Generics.Collections,
  System.SysUtils;

type TGBJSONTestSerializePessoa = class

  private
    FPessoa     : TPessoa;
    FDeserialize: IGBJSONDeserializer<TPessoa>;
    FJSONObject : TJSONObject;

    function GetJsonObject(APessoa: TPessoa): TJSONObject;
  public
    [Setup]    procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure TestStringPreenchida;
    [Test] procedure TestStringVazia;
    [Test] procedure TestStringComAcento;
    [Test] procedure TestStringComBarra;
    [Test] procedure TestStringComBarraInvertida;
    [Test] procedure TestStringValorZero;

    [Test] procedure TestIntegerPreenchido;
    [Test] procedure TestIntegerVazio;
    [Test] procedure TestIntegerNegativo;

    [Test] procedure TestFloatPositivo;
    [Test] procedure TestFloatNegativo;
    [Test] procedure TestFloatZero;
    [Test] procedure TestFloatPositivoComDecimal;
    [Test] procedure TestFloatNegativoComDecimal;

    [Test] procedure TestDataVazia;
    [Test] procedure TestDataPreenchida;

    [Test] procedure TestBooleanFalse;
    [Test] procedure TestBooleanTrue;

    [Test] procedure TestEnumString;

    [Test] procedure TestObjectValue;
    [Test] procedure TestObjectNull;

    [Test] procedure TestObjectListCheio;
    [Test] procedure TestObjectListVazio;
    [Test] procedure TestObjectListUmElemento;
    [Test] procedure TestObjectListNull;

    constructor create;
    destructor  Destroy; override;
end;


implementation

{ TGBJSONTestSerializePessoa }

constructor TGBJSONTestSerializePessoa.create;
begin
  FDeserialize := TGBJSONDefault.Deserializer<TPessoa>;
end;

destructor TGBJSONTestSerializePessoa.Destroy;
begin
  inherited;
end;

function TGBJSONTestSerializePessoa.GetJsonObject(APessoa: TPessoa): TJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := FDeserialize.ObjectToJsonObject(APessoa);

  result := FJSONObject;
end;

procedure TGBJSONTestSerializePessoa.Setup;
begin
  FPessoa     := TPessoa.CreatePessoa;
  FJSONObject := GetJsonObject(FPessoa);
end;

procedure TGBJSONTestSerializePessoa.TearDown;
begin
  FreeAndNil(FJSONObject);
  FreeAndNil(FPessoa);
end;

procedure TGBJSONTestSerializePessoa.TestBooleanFalse;
begin
  FPessoa.ativo := False;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['ativo']);
  Assert.AreEqual('false', FJSONObject.Values['ativo'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestBooleanTrue;
begin
  FPessoa.ativo := True;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['ativo']);
  Assert.AreEqual('true', FJSONObject.Values['ativo'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestDataPreenchida;
var
  data : TDateTime;
begin
  FPessoa.dataCadastro := Now;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['dataCadastro']);

  data.fromIso8601ToDateTime( FJSONObject.Values['dataCadastro'].Value);

  Assert.AreEqual(FormatDateTime('yyyy-MM-dd hh:mm:ss', FPessoa.dataCadastro),
                  FormatDateTime('yyyy-MM-dd hh:mm:ss', data));
end;

procedure TGBJSONTestSerializePessoa.TestDataVazia;
begin
  FPessoa.dataCadastro := 0;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNull(FJSONObject.Values['dataCadastro']);
end;

procedure TGBJSONTestSerializePessoa.TestEnumString;
begin
  FPessoa.tipoPessoa := TTipoPessoa.tpJuridica;
  FJSONObject        := FDeserialize.ObjectToJsonObject(FPessoa);

  Assert.AreEqual('tpJuridica', FJSONObject.Values['tipoPessoa'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestFloatNegativo;
begin
  FPessoa.media := -5;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['media']);
  Assert.AreEqual('-5', FJSONObject.Values['media'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestFloatNegativoComDecimal;
begin
  FPessoa.media := -5.15;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['media']);
  Assert.AreEqual('-5.15', FJSONObject.Values['media'].ToString);
end;

procedure TGBJSONTestSerializePessoa.TestFloatPositivo;
begin
  FPessoa.media := 5;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['media']);
  Assert.AreEqual('5', FJSONObject.Values['media'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestFloatPositivoComDecimal;
begin
  FPessoa.media := 5.25;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(FJSONObject.Values['media']);
  Assert.AreEqual('5.25', FJSONObject.Values['media'].ToString);
end;

procedure TGBJSONTestSerializePessoa.TestFloatZero;
begin
  FPessoa.media := 0;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNull(FJSONObject.Values['media']);
end;

procedure TGBJSONTestSerializePessoa.TestIntegerNegativo;
begin
  FPessoa.idade := -5;
  FJSONObject   := GetJsonObject(FPessoa);

  Assert.AreEqual(FPessoa.idade, FJSONObject.Values['idade'].Value.ToInteger);
end;

procedure TGBJSONTestSerializePessoa.TestIntegerPreenchido;
begin
  FPessoa.idade := 18;
  FJSONObject   := GetJsonObject(FPessoa);

  Assert.AreEqual(FPessoa.idade, FJSONObject.Values['idade'].Value.ToInteger);
end;

procedure TGBJSONTestSerializePessoa.TestIntegerVazio;
begin
  FPessoa.idade := 0;
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNull(FJSONObject.Values['idade']);
end;

procedure TGBJSONTestSerializePessoa.TestObjectListCheio;
var
  jsonArray: TJSONArray;
begin
  jsonArray := FJSONObject.Values['telefones'] as TJSONArray;
  Assert.AreEqual(2, jsonArray.Count);
  Assert.IsNotNull(TJSONObject( jsonArray.Items[0]).Values['numero']);
end;

procedure TGBJSONTestSerializePessoa.TestObjectListNull;
begin
  FPessoa.telefones.Free;
  FPessoa.telefones := nil;

  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNull(FJSONObject.Values['telefones']);
end;

procedure TGBJSONTestSerializePessoa.TestObjectListUmElemento;
var
  jsonArray: TJSONArray;
begin
  FPessoa.telefones.Remove(FPessoa.telefones[1]);
  FJSONObject := GetJsonObject(FPessoa);
  jsonArray := FJSONObject.Values['telefones'] as TJSONArray;
  Assert.AreEqual(1, jsonArray.Count);
end;

procedure TGBJSONTestSerializePessoa.TestObjectListVazio;
begin
  FPessoa.telefones.Remove(FPessoa.telefones[0]);
  FPessoa.telefones.Remove(FPessoa.telefones[0]);

  FJSONObject := GetJsonObject(FPessoa);
  Assert.IsNull(FJSONObject.Values['telefones']);
end;

procedure TGBJSONTestSerializePessoa.TestObjectNull;
begin
  FPessoa.endereco.Free;
  FPessoa.endereco := nil;

  FJSONObject := GetJsonObject(FPessoa);
  Assert.IsNull(FJSONObject.Values['endereco']);
end;

procedure TGBJSONTestSerializePessoa.TestObjectValue;
begin
  FPessoa.endereco.logradouro := 'Rua Tal';
  FJSONObject := GetJsonObject(FPessoa);

  Assert.IsNotNull(TJSONObject( FJSONObject.Values['endereco'] ));
  Assert.AreEqual (FPessoa.endereco.logradouro, TJSONObject(FJSONObject.Values['endereco']).Values['logradouro'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestStringComAcento;
begin
  FPessoa.nome := 'João';
  FJSONObject  := GetJsonObject(FPessoa);

  Assert.AreEqual(FPessoa.nome, FJSONObject.Values['nome'].Value );
end;

procedure TGBJSONTestSerializePessoa.TestStringComBarra;
var
  nome: string;
begin
  FPessoa.nome := 'Nome 1 / Nome 2';
  FJSONObject  := GetJsonObject(FPessoa);

  nome := FJSONObject.Values['nome'].Value;

  Assert.AreEqual(FPessoa.nome,  nome);
end;

procedure TGBJSONTestSerializePessoa.TestStringComBarraInvertida;
var
  nome: string;
begin
  FPessoa.nome := 'Nome 1 \ Nome 2';
  FJSONObject  := GetJsonObject(FPessoa);

  nome := FJSONObject.Values['nome'].Value;

  Assert.AreEqual(FPessoa.nome,  nome);
end;

procedure TGBJSONTestSerializePessoa.TestStringPreenchida;
var
  nome : String;
begin
  nome := FJSONObject.GetValue<String>('nome', EmptyStr);
  Assert.AreEqual(FPessoa.nome, nome);
end;

procedure TGBJSONTestSerializePessoa.TestStringValorZero;
begin
  FPessoa.nome := '0';
  FJSONObject  := GetJsonObject(FPessoa);

  Assert.IsNotNull( FJSONObject.Values['nome'] );
  Assert.AreEqual('0', FJSONObject.Values['nome'].Value);
end;

procedure TGBJSONTestSerializePessoa.TestStringVazia;
begin
  FPessoa.nome := EmptyStr;
  FJSONObject  := GetJsonObject(FPessoa);

  Assert.IsNull( FJSONObject.Values['nome'] );
end;

end.
