program AntSim60;

uses
  Forms,
  AntSim60Unit in 'AntSim60Unit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
