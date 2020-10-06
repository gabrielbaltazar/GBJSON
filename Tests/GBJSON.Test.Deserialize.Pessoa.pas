unit GBJSON.Test.Deserialize.Pessoa;

interface

uses
  DUnitX.TestFramework,
  GBJSON.Test.Models,
  GBJSON.Deserializer,
  GBJSON.Serializer,
  System.JSON,
  System.SysUtils;

type TGBJSONTestDeserializePessoa = class

  private
    FPessoa      : TPessoa;
    FAuxPessoa   : TPessoa;
    FDeserialize : TGBJSONDeserializer;
    FSerialize   : TGBJSONSerializer;
    FJSONObject  : TJSONObject;

    function GetJsonObject(APessoa: TPessoa): TJSONObject;
  public
    [Setup]    procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure TestStringNome;
    [Test] procedure TestStringEmpty;
    [Test] procedure TestStringComAcento;
    [Test] procedure TestStringComBarra;
    [Test] procedure TestStringComBarraInvertida;

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
    [Test] procedure TestBoolVazio;

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

{ TGBJSONTestDeserializePessoa }

constructor TGBJSONTestDeserializePessoa.create;
begin
  FDeserialize := TGBJSONDeserialize.create;
  FSerialize   := TGBJSONSerialize.create;
end;

destructor TGBJSONTestDeserializePessoa.Destroy;
begin
  FDeserialize.Free;
  FSerialize.Free;
  inherited;
end;

function TGBJSONTestDeserializePessoa.GetJsonObject(APessoa: TPessoa): TJSONObject;
begin
  FreeAndNil(FJSONObject);
  FJSONObject := FSerialize.ObjectToJsonObject(APessoa);

  result := FJSONObject;
end;

procedure TGBJSONTestDeserializePessoa.Setup;
begin
  FPessoa     := TPessoa.CreatePessoa;
  FJSONObject := GetJsonObject(FPessoa);
end;

procedure TGBJSONTestDeserializePessoa.TearDown;
begin
  FreeAndNil(FJSONObject);
  FreeAndNil(FPessoa);
  FreeAndNil(FAuxPessoa);
end;

procedure TGBJSONTestDeserializePessoa.TestBooleanFalse;
begin
  FPessoa.ativo := False;
  FJSONObject   := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsFalse(FAuxPessoa.ativo);
end;

procedure TGBJSONTestDeserializePessoa.TestBooleanTrue;
begin
  FPessoa.ativo := True;
  FJSONObject   := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsTrue(FAuxPessoa.ativo);
end;

procedure TGBJSONTestDeserializePessoa.TestBoolVazio;
begin
  FPessoa.ativo := True;
  FJSONObject   := GetJsonObject(FPessoa);
  FJSONObject.RemovePair('ativo');

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsFalse(FAuxPessoa.ativo);
end;

procedure TGBJSONTestDeserializePessoa.TestDataPreenchida;
begin
  FPessoa.dataCadastro := Now;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FormatDateTime('yyyy-MM-dd hh:mm:ss', FPessoa.dataCadastro),
                  FormatDateTime('yyyy-MM-dd hh:mm:ss', FAuxPessoa.dataCadastro));
end;

procedure TGBJSONTestDeserializePessoa.TestDataVazia;
begin
  FPessoa.dataCadastro := 0;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.dataCadastro, FAuxPessoa.dataCadastro);
end;

procedure TGBJSONTestDeserializePessoa.TestEnumString;
begin
  FPessoa.tipoPessoa := tpJuridica;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.tipoPessoa, FAuxPessoa.tipoPessoa);
end;

procedure TGBJSONTestDeserializePessoa.TestFloatNegativo;
begin
  FPessoa.media := -5;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.media, FAuxPessoa.media);
end;

procedure TGBJSONTestDeserializePessoa.TestFloatNegativoComDecimal;
begin
  FPessoa.media := -5.25;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.media, FAuxPessoa.media);
end;

procedure TGBJSONTestDeserializePessoa.TestFloatPositivo;
begin
  FPessoa.media := 15;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.media, FAuxPessoa.media);
end;

procedure TGBJSONTestDeserializePessoa.TestFloatPositivoComDecimal;
begin
  FPessoa.media := 15.351;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.media, FAuxPessoa.media);
end;

procedure TGBJSONTestDeserializePessoa.TestFloatZero;
begin
  FPessoa.media := 0;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsTrue(FAuxPessoa.media = 0);
end;

procedure TGBJSONTestDeserializePessoa.TestIntegerNegativo;
begin
  FPessoa.idade := -5;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.idade, FAuxPessoa.idade);
end;

procedure TGBJSONTestDeserializePessoa.TestIntegerPreenchido;
begin
  FPessoa.idade := 50;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.idade, FAuxPessoa.idade);
end;

procedure TGBJSONTestDeserializePessoa.TestIntegerVazio;
begin
  FPessoa.idade := 0;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.idade, FAuxPessoa.idade);
end;

procedure TGBJSONTestDeserializePessoa.TestObjectListCheio;
begin
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsTrue (FAuxPessoa.telefones.Count > 0);
  Assert.IsFalse(FAuxPessoa.telefones[0].numero.IsEmpty);

  Assert.AreEqual(FPessoa.telefones.Count, FAuxPessoa.telefones.Count);
  Assert.AreEqual(FPessoa.telefones[0].numero, FAuxPessoa.telefones[0].numero);
end;

procedure TGBJSONTestDeserializePessoa.TestObjectListNull;
begin
  FPessoa.telefones.Free;
  FPessoa.telefones := nil;

  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsNotNull(FAuxPessoa.telefones);
  Assert.IsTrue (FAuxPessoa.telefones.Count = 0);
end;

procedure TGBJSONTestDeserializePessoa.TestObjectListUmElemento;
begin
  FPessoa.telefones.Remove(FPessoa.telefones[1]);
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsTrue (FAuxPessoa.telefones.Count = 1);
  Assert.IsFalse(FAuxPessoa.telefones[0].numero.IsEmpty);

  Assert.AreEqual(FPessoa.telefones.Count, FAuxPessoa.telefones.Count);
  Assert.AreEqual(FPessoa.telefones[0].numero, FAuxPessoa.telefones[0].numero);
end;

procedure TGBJSONTestDeserializePessoa.TestObjectListVazio;
begin
  FPessoa.telefones.Remove(FPessoa.telefones[0]);
  FPessoa.telefones.Remove(FPessoa.telefones[0]);

  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsTrue (FAuxPessoa.telefones.Count = 0);
end;

procedure TGBJSONTestDeserializePessoa.TestObjectNull;
begin
  FPessoa.endereco.Free;
  FPessoa.endereco := nil;

  FJSONObject := GetJsonObject(FPessoa);
  FAuxPessoa  := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);

  Assert.IsEmpty(FAuxPessoa.endereco.logradouro);
end;

procedure TGBJSONTestDeserializePessoa.TestObjectValue;
begin
  FPessoa.endereco.logradouro := 'Rua Tal';
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.AreEqual(FPessoa.endereco.logradouro, FAuxPessoa.endereco.logradouro);
end;

procedure TGBJSONTestDeserializePessoa.TestStringComAcento;
begin
  FPessoa.nome := 'Tomé';
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsNotNull(FAuxPessoa);
  Assert.AreEqual(FPessoa.nome, FAuxPessoa.nome);
end;

procedure TGBJSONTestDeserializePessoa.TestStringComBarra;
begin
  FPessoa.nome := 'Value 1 / Value 2';
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsNotNull(FAuxPessoa);
  Assert.AreEqual(FPessoa.nome, FAuxPessoa.nome);
end;

procedure TGBJSONTestDeserializePessoa.TestStringComBarraInvertida;
begin
  FPessoa.nome := 'Value 1 \ Value 2';
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsNotNull(FAuxPessoa);
  Assert.AreEqual(FPessoa.nome, FAuxPessoa.nome);
end;

procedure TGBJSONTestDeserializePessoa.TestStringEmpty;
begin
  FPessoa.nome := EmptyStr;
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsNotNull(FAuxPessoa);
  Assert.AreEqual(FPessoa.nome, FAuxPessoa.nome);
end;

procedure TGBJSONTestDeserializePessoa.TestStringNome;
begin
  FPessoa.nome := 'Value 1';
  FJSONObject := GetJsonObject(FPessoa);

  FAuxPessoa := FDeserialize.JsonObjectToObject<TPessoa>(FJSONObject);
  Assert.IsNotNull(FAuxPessoa);
  Assert.AreEqual(FPessoa.nome, FAuxPessoa.nome);
end;

end.
