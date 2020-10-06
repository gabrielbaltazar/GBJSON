program Exemplo;

uses
  Vcl.Forms,
  FExemplo01 in 'FExemplo01.pas' {Form1},
  SampleModel in 'SampleModel.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown   := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
