unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph,
  DynStructures, GraphDrawing, AboutUnit, ArcInputUnit;

type

  // ��� ������ ������ � ������
  TClickState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stMove,
    stDFS, stBFS, stDijkstra, stNone);
  TVerFile = File of TVertice;
  TArcFile = File of TAdjVertice;

  TfmEditor = class(TForm)
    plFunctionsContainer: TPanel;
    btnAddNode: TSpeedButton;
    btnAddLinl: TSpeedButton;
    btnDeleteNode: TSpeedButton;
    btnDeleteLink: TSpeedButton;
    btnDFS: TSpeedButton;
    btnBFS: TSpeedButton;
    btnDijkstra: TSpeedButton;
    mmMain: TMainMenu;
    nFile: TMenuItem;
    nEdit: TMenuItem;
    nHelp: TMenuItem;
    nSave: TMenuItem;
    nExit: TMenuItem;
    nClear: TMenuItem;
    nAbout: TMenuItem;
    nOpen: TMenuItem;
    nSaveAs: TMenuItem;
    sdVertices: TSaveDialog;
    sdArcs: TSaveDialog;
    odVertices: TOpenDialog;
    odArcs: TOpenDialog;
    lbEdit: TLabel;
    lbSearch: TLabel;
    pbCanvas: TPaintBox;
    N1: TMenuItem;
    nExportBMP: TMenuItem;
    sdExport: TSaveDialog;
    sbMove: TSpeedButton;
    cbNoWeight: TCheckBox;
    procedure fmEditorCreate(Sender: TObject);
    procedure fmEditorClose(Sender: TObject; var Action: TCloseAction);
    procedure SetClickState(Sender: TObject);
    procedure pbCanvasClick(Sender: TObject);
    procedure pbCanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbCanvasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbCanvasMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure nOpenClick(Sender: TObject);
    procedure nSaveClick(Sender: TObject);
    procedure nSaveAsClick(Sender: TObject);
    procedure nExitClick(Sender: TObject);
    procedure nClearClick(Sender: TObject);
    procedure pbCanvasPaint(Sender: TObject);
    procedure nExportBMPClick(Sender: TObject);
    procedure nAboutClick(Sender: TObject);
    procedure cbNoWeightClick(Sender: TObject);
  private
    State: TClickState; // ���������� ��������� ��� ������ � ������
    Graph: TGraph; // ���� ��� ��������������
    VStart: TPVertice; // ��������� �� ����������� �������

    function StartSearch(State: TClickState; v, u: Integer): Boolean;
    procedure OpenGraph(var G: TGraph; var VerFile: TVerFile;
      var ArcFile: TArcFile);
    procedure SaveGraph(var G: TGraph; var VerFile: TVerFile;
      var ArcFile: TArcFile);
  end;

var
  fmEditor: TfmEditor;

implementation

{$R *.dfm}

procedure TfmEditor.fmEditorCreate(Sender: TObject);
begin
  State := stNone;
  InitializeGraph(Graph, 40);
  VStart := nil;
end;

procedure TfmEditor.fmEditorClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyGraph(Graph); // ������������ ������� ������
end;

procedure TfmEditor.SetClickState(Sender: TObject);
begin

  if Graph.isPainted then
  begin
    MakePassive(Graph);
    pbCanvas.Invalidate;
  end;

  if VStart <> nil then
  begin
    VStart.Design := dgPassive;
    VStart := nil;
    pbCanvas.Invalidate;
  end;

  if (Sender as TSpeedButton).Down then
    State := TClickState((Sender as TSpeedButton).Tag)
  else
    State := stNone;
end;

procedure TfmEditor.pbCanvasClick(Sender: TObject);
var
  Pos: TPoint; // ������� ������� ����
  VEnd: TPVertice; // ��������� �� �������
  mrInput: TModalResult;
  isFound: Boolean;
begin

  Pos := ScreenToClient(Mouse.CursorPos);
  if Graph.isPainted then
    MakePassive(Graph);
  // ������� ���������� ���������
  case State of
    stAddVertice: // ���������� �������
      AddVertice(Graph, Pos);
    stDeleteVertice: // �������� �������
      if Centralize(Graph, Pos, VEnd) then
        DeleteVertice(Graph, VEnd.Number);
    stAddArc, stDeleteArc, stDFS, stBFS, stDijkstra: // �������� �� 2-� ��������
      begin
        if VStart = nil then
        begin
          if Centralize(Graph, Pos, VStart) then
            VStart.Design := dgActive;
        end
        else if Centralize(Graph, Pos, VEnd) then
        begin

          // ������� ���������� ���������
          case State of
            stAddArc: // ���������� ����
              begin
                if not cbNoWeight.Checked then
                  mrInput := fmArcInput.ShowModal
                else
                  mrInput := mrOk;
                if mrInput = mrOk then
                begin
                  AddArc(Graph, VStart.Number, VEnd.Number, fmArcInput.Weight);
                  if fmArcInput.isEdge then
                    AddArc(Graph, VEnd.Number, VStart.Number,
                      fmArcInput.Weight);
                end;
              end;
            stDeleteArc: // �������� ����
              DeleteArc(Graph, VStart.Number, VEnd.Number);
            stDFS, stBFS, stDijkstra: // ��������� ������
              begin
                isFound := StartSearch(State, VStart.Number, VEnd.Number);
                if not isFound then
                  ShowMessage('���� �� ������.');
              end;
          end; // ����� case

          // ����� ��������� �������
          if VStart.Design = dgActive then
            VStart.Design := dgPassive;
          VStart := nil;
        end; // ����� else if

      end;
  end; // ����� case

  if State <> stNone then
    pbCanvas.Invalidate;
end;

procedure TfmEditor.pbCanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Pos: TPoint;
begin
  if State = stMove then
  begin
    Pos := ScreenToClient(Mouse.CursorPos);
    Centralize(Graph, Pos, VStart);
    if VStart <> nil then
      VStart.Design := dgActive;
  end;
end;

procedure TfmEditor.pbCanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (State = stMove) and (VStart <> nil) then
  begin
    VStart.Design := dgPassive;
    VStart := nil;
    pbCanvas.Invalidate;
  end;
end;

procedure TfmEditor.pbCanvasMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  Pos: TPoint;
begin
  if (State = stMove) and (VStart <> nil) then
  begin
    Pos := ScreenToClient(Mouse.CursorPos);
    VStart.Center := Pos;
    pbCanvas.Invalidate;
  end;
end;

procedure TfmEditor.nOpenClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
  isSuccess: Boolean;
  NewGraph: TGraph;
begin

  odVertices.FileName := '';
  odArcs.FileName := '';

  // ����� ����� � ���������
  if not(odVertices.Execute and odArcs.Execute) then
    Exit;

  // ���������� ������
  System.Assign(fVertices, odVertices.FileName);
  System.Assign(fArcs, odArcs.FileName);
  Reset(fVertices);
  Reset(fArcs);

  // ������ �����
  try
    InitializeGraph(NewGraph, 40);
    OpenGraph(NewGraph, fVertices, fArcs);
    DestroyGraph(Graph);
    Graph := NewGraph;
    sdVertices.FileName := odVertices.FileName;
    sdArcs.FileName := odArcs.FileName;
  except
    DestroyGraph(NewGraph);
    ShowMessage('������ ��� �������� �����');
  end;

  // �������� ������
  CloseFile(fVertices);
  CloseFile(fArcs);

  // ����������� �����
  pbCanvas.Invalidate;

end;

procedure TfmEditor.nSaveClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
begin

  // ������� � "���������� ���"
  if (sdVertices.FileName = '') or (sdArcs.FileName = '') then
  begin
    nSaveAsClick(Sender);
    Exit
  end;

  // ���������� ������
  System.Assign(fVertices, sdVertices.FileName);
  System.Assign(fArcs, sdArcs.FileName);
  Rewrite(fVertices);
  Rewrite(fArcs);

  // ���������� �����
  SaveGraph(Graph, fVertices, fArcs);

  // �������� ������
  CloseFile(fVertices);
  CloseFile(fArcs);
end;

procedure TfmEditor.nSaveAsClick(Sender: TObject);
begin

  sdVertices.FileName := '';
  sdArcs.FileName := '';

  if sdVertices.Execute and sdArcs.Execute then
    nSaveClick(Sender);

end;

procedure TfmEditor.nExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmEditor.nClearClick(Sender: TObject);
begin
  DestroyGraph(Graph);
  InitializeGraph(Graph, 40);
  pbCanvas.Invalidate;
end;

procedure TfmEditor.nExportBMPClick(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  sdExport.FileName := '';
  if sdExport.Execute then
  begin
    Bitmap := TBitmap.Create;
    try
      Bitmap.SetSize(pbCanvas.Width, pbCanvas.Height);
      RedrawGraph(Bitmap.Canvas, Bitmap.Width, Bitmap.Height, Graph);
      Bitmap.SaveToFile(sdExport.FileName);
    finally
      Bitmap.Free;
    end;
  end;
end;

procedure TfmEditor.nAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfmEditor.cbNoWeightClick(Sender: TObject);
begin
  fmArcInput.isEdge := false;
end;

function TfmEditor.StartSearch;
var
  Weights: TWeights; // ������� �����
  Path: TStack; // ���������� ����
  Vertice: TPVertice; // ��������� �� �������
begin
  ToWeightMatrix(Graph, Weights); // �������������� � ������� ����������

  // ����� ��������� ������
  case State of
    stDFS:
      DFS(Weights, v, u, Path);
    stBFS:
      BFS(Weights, v, u, Path);
    stDijkstra:
      Dijkstra(Weights, v, u, Path);
  end;

  // ��������� � ������������ �������� �������
  Result := Path <> nil;
  Visit(Graph, Path);

end;

procedure TfmEditor.OpenGraph(var G: TGraph; var VerFile: TVerFile;
  var ArcFile: TArcFile);
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
  v: Integer;
begin

  New(Vertice);
  New(AdjVertice);
  // ���� �1. ������ �� ����� ������
  while not Eof(VerFile) do
  begin

    // ������ ��������� �������
    Read(VerFile, Vertice^);
    AddVertice(G, Vertice.Center);

    // ���� �2. ��������� ������ �� ����� ����
    for v := 1 to Vertice.Deg do
    begin
      Read(ArcFile, AdjVertice^);
      AddArc(G, Vertice.Number, AdjVertice.Number, AdjVertice.Weight);
    end; // ����� �2
  end; // ����� �1

  Dispose(Vertice);
  Dispose(AdjVertice);
end;

procedure TfmEditor.SaveGraph;
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin

  // ���� �1. ������ �� ��������
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Write(VerFile, Vertice^);

    // ���� �2. ������ �� �������
    AdjVertice := Vertice.Head;
    while AdjVertice <> nil do
    begin
      Write(ArcFile, AdjVertice^);
      AdjVertice := AdjVertice.Next;
    end; // ����� �1
    Vertice := Vertice.Next;
  end; // ����� �2
end;

procedure TfmEditor.pbCanvasPaint(Sender: TObject);
begin
  RedrawGraph(pbCanvas.Canvas, pbCanvas.Width, pbCanvas.Height, Graph);
end;

end.
