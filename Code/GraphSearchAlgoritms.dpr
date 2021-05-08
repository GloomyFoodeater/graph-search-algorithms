program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {Form1},
  Digraph in 'Digraph.pas',
  DynStructures in 'DynStructures.pas',
  GraphSearch in 'GraphSearch.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  State := stNone;
  with Form1.Canvas do
  begin
    Pen.Width := 3;
    Font.Size := 10;
  end;
  Application.Run;

end.
