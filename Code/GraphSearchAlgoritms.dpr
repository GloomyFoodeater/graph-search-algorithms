program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  NodesCounter := 1;
  Form1.Image1.Canvas.Pen.Width := 3;
  Form1.Image1.Canvas.Font.Size := 10;
  Application.Run;
end.
