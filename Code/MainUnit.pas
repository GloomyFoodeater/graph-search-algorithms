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
    nGraph: TMenuItem;
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
    nImportExcel: TMenuItem;
    odImport: TOpenDialog;
    lbResults: TLabel;
    N2: TMenuItem;
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
    procedure nExportBMPClick(Sender: TObject);
    procedure nAboutClick(Sender: TObject);
    procedure cbNoWeightClick(Sender: TObject);
    procedure pbCanvasPaint(Sender: TObject);
    procedure nImportFromExcel(Sender: TObject);
  private
    State: TClickState; // ���������� ��������� ��� ������ � ������
    Graph: TGraph; // ���� ��� ��������������
    VStart: TPVertice; // ��������� �� ����������� �������
    procedure StartSearch(State: TClickState; v, u: Integer);
  end;

var
  fmEditor: TfmEditor;

implementation

{$R *.dfm}

procedure TfmEditor.fmEditorCreate(Sender: TObject);
begin
  State := stNone;
  InitializeGraph(Graph);
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
    lbResults.Caption := '';
    pbCanvas.Invalidate;
  end
  else if VStart <> nil then
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
begin

  Pos := ScreenToClient(Mouse.CursorPos);
  if Graph.isPainted then
  begin
    MakePassive(Graph);
    lbResults.Caption := '';
  end;
  // ������� ���������� ���������
  case State of
    stAddVertice: // ���������� �������
      AddVertice(Graph, Pos);

    stDeleteVertice: // �������� �������
      if Centralize(Graph, Pos, VEnd) then
        DeleteVertice(Graph, VEnd.Number);

    stAddArc, stDeleteArc, stDFS, stBFS, stDijkstra: // �������� �� 2-� ��������

      if (VStart <> nil) and Centralize(Graph, Pos, VEnd) then
      begin
        case State of
          stAddArc: // ���������� ����
            begin
              if not cbNoWeight.Checked then
                mrInput := fmArcInput.ShowModal
              else
                mrInput := mrOk;

              if mrInput = mrOk then
                AddArc(Graph, VStart.Number, VEnd.Number, fmArcInput.Weight);
            end;

          stDeleteArc: // �������� ����
            DeleteArc(Graph, VStart.Number, VEnd.Number);

          stDFS, stBFS, stDijkstra: // ��������� ������
            StartSearch(State, VStart.Number, VEnd.Number);
        end; // ����� case

        // ����� ��������� �������
        if VStart.Design = dgActive then
          VStart.Design := dgPassive;
        VStart := nil;
      end
      else if Centralize(Graph, Pos, VStart) then
        VStart.Design := dgActive;

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
  NewGraph: TGraph;
begin

  odVertices.FileName := '';
  odArcs.FileName := '';

  // ����� ����� � ���������
  if not(odVertices.Execute and odArcs.Execute) then
    Exit;

  // ������ �����
  try
    OpenGraph(NewGraph, odVertices.FileName, odArcs.FileName);
    DestroyGraph(Graph);
    Graph := NewGraph;
    sdVertices.FileName := odVertices.FileName;
    sdArcs.FileName := odArcs.FileName;
  except
    DestroyGraph(NewGraph);
    ShowMessage('������ ��� �������� �����');
  end;

  // ����������� �����
  pbCanvas.Invalidate;

end;

procedure TfmEditor.nSaveClick(Sender: TObject);
begin

  // ������� � "���������� ���"
  if (sdVertices.FileName = '') or (sdArcs.FileName = '') then
  begin
    nSaveAsClick(Sender);
    Exit
  end;

  // ���������� �����
  SaveGraph(Graph, sdVertices.FileName, sdArcs.FileName);

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
  InitializeGraph(Graph);
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

procedure TfmEditor.nImportFromExcel(Sender: TObject);
var
  NewGraph: TGraph;
begin
  odImport.FileName := '';
  if odImport.Execute then
  begin
    try
      ImportFromExcel(NewGraph, odImport.FileName, pbCanvas.Width,
        pbCanvas.Height);
      DestroyGraph(Graph);
      Graph := NewGraph;
      pbCanvas.Invalidate;
    except
      DestroyGraph(NewGraph);
    end;
  end;
end;

procedure TfmEditor.nAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfmEditor.cbNoWeightClick(Sender: TObject);
begin
  fmArcInput.Weight := 1;
end;

procedure TfmEditor.pbCanvasPaint(Sender: TObject);
begin
  RedrawGraph(pbCanvas.Canvas, pbCanvas.Width, pbCanvas.Height, Graph);
end;

procedure TfmEditor.StartSearch;
var
  Weights: TWeights; // ������� �����
  Info: TSearchInfo;
begin
  ToWeightMatrix(Graph, Weights); // �������������� � ������� ����������

  // ����� ��������� ������
  case State of
    stDFS:
      DFS(Weights, v, u, Info);
    stBFS:
      BFS(Weights, v, u, Info);
    stDijkstra:
      Dijkstra(Weights, v, u, Info);
  end;

  // ��������� � ������������ �������� �������
  if Info.Path <> nil then
  begin
    Visit(Graph, Info.Path);
    lbResults.Caption := '���������� � ������'#13#10;
    lbResults.Caption := lbResults.Caption + '����� ���: ' +
      IntToStr(Info.ArcsCount) + #13#10;
    lbResults.Caption := lbResults.Caption + '�����: ' +
      IntToStr(Info.Distance);
  end
  else
    ShowMessage('���� �� ������.');

end;

end.
