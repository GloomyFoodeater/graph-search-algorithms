program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {fmEditor},
  Digraph in 'Digraph.pas',
  DynStructures in 'DynStructures.pas',
  GraphSearch in 'GraphSearch.pas',
  GraphDrawing in 'GraphDrawing.pas',
  AboutForm in 'AboutForm.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmEditor, fmEditor);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;

end.
