program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  NodeCounter := 0;
  State := stNone;
  with Form1.Canvas do
  begin
    Pen.Width := 3;
    Font.Size := 10;
  end;
  Application.Run;

end.
