program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {frmGraphEditor} ,
  Digraph in 'Digraph.pas',
  DynStructures in 'DynStructures.pas',
  GraphSearch in 'GraphSearch.pas',
  GraphDrawing in 'GraphDrawing.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGraphEditor, frmGraphEditor);
  Application.Run;

end.
