unit FExemplo01;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  SampleModel,
  System.JSON,
  System.Generics.Collections,
  GBJSON.Interfaces,
  GBJSON.Helper;

type
  TForm1 = class(TForm)
    pnlTop: TPanel;
    btnObjectToJson: TButton;
    btnJsonToObject: TButton;
    mmoJSON: TMemo;
    btnObjectToJsonListEmpty: TButton;
    btnListToJsonArray: TButton;
    btnJSONArrayToList: TButton;
    procedure btnObjectToJsonClick(Sender: TObject);
    procedure btnJsonToObjectClick(Sender: TObject);
    procedure btnObjectToJsonListEmptyClick(Sender: TObject);
    procedure btnListToJsonArrayClick(Sender: TObject);
    procedure btnJSONArrayToListClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnJSONArrayToListClick(Sender: TObject);
var
  list : TObjectList<TClient>;
  i: Integer;
begin
  list := TGBJSONDefault.Serializer<TClient>.JsonStringToList(mmoJSON.Lines.Text);
  try
    for i := 0 to Pred(list.Count) do
      ShowMessage(list[i].name);
  finally
    list.Free;
  end;
end;

procedure TForm1.btnJsonToObjectClick(Sender: TObject);
var
  client: TClient;
begin
  client := TClient.create;
  try
    client.fromJSONString(mmoJSON.Lines.Text);
    mmoJSON.Lines.Text := client.ToJSONString;
  finally
    client.Free;
  end;
end;

procedure TForm1.btnObjectToJsonClick(Sender: TObject);
var
  client: TClient;
begin
  client := TClient.NewClient;
  try
    mmoJSON.Lines.Text := client.ToJSONString;
  finally
    client.Free;
  end;
end;

procedure TForm1.btnObjectToJsonListEmptyClick(Sender: TObject);
var
  client: TClient;
begin
  client := TClient.NewClient;
  try
    client.phones.Free;
    client.phones := TObjectList<TPhone>.create;
    mmoJSON.Lines.Text := client.ToJSONString;
  finally
    client.Free;
  end;
end;

procedure TForm1.btnListToJsonArrayClick(Sender: TObject);
var
  list: TObjectList<TClient>;
  json: TJSONArray;
begin
  list := TObjectList<TClient>.create;
  try
    list.Add(TClient.NewClient);
    list.Add(TClient.NewClient);
    list.Add(TClient.NewClient);

    json := TGBJSONDefault.Deserializer<TClient>.ListToJSONArray(list);
    try
      mmoJSON.Lines.Text := json.ToJSON;
    finally
      json.Free;
    end;
  finally
    list.Free;
  end;
end;

end.
