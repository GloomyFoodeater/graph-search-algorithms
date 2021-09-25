program GraphSearchAlgoritms;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {fmEditor},
  Digraph in 'Digraph.pas',
  DynamicStructures in 'DynamicStructures.pas',
  GraphSearch in 'GraphSearch.pas',
  GraphDrawing in 'GraphDrawing.pas',
  AboutUnit in 'AboutUnit.pas' {fmAbout},
  ArcInputUnit in 'ArcInputUnit.pas' {fmArcInput},
  SearchOutputUnit in 'SearchOutputUnit.pas' {fmSearchOutput};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmEditor, fmEditor);
  Application.CreateForm(TfmAbout, fmAbout);
  Application.CreateForm(TfmArcInput, fmArcInput);
  Application.CreateForm(TfmSearchOutput, fmSearchOutput);
  Application.Run;

end.
