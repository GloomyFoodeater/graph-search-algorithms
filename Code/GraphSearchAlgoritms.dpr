program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {fmEditor},
  Digraph in 'Digraph.pas',
  DynStructures in 'DynStructures.pas',
  GraphSearch in 'GraphSearch.pas',
  GraphDrawing in 'GraphDrawing.pas',
  AboutUnit in 'AboutUnit.pas' {frmAbout},
  ArcInputUnit in 'ArcInputUnit.pas' {fmArcInput};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmEditor, fmEditor);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfmArcInput, fmArcInput);
  Application.Run;

end.
