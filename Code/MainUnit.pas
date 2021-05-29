unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph,
  DynamicStructures, GraphDrawing, AboutUnit, ArcInputUnit, SearchOutputUnit;

type

  // ��� ������ ������ � �������
  TCanvasState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stMove,
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
    N1: TMenuItem;
    nExportBMP: TMenuItem;
    sdExport: TSaveDialog;
    sbMove: TSpeedButton;
    cbNoWeight: TCheckBox;
    nImportExcel: TMenuItem;
    odImport: TOpenDialog;
    N2: TMenuItem;
    pbCanvas: TPaintBox;
    procedure fmEditorCreate(Sender: TObject);
    procedure fmEditorClose(Sender: TObject; var Action: TCloseAction);
    procedure SetCanvasState(Sender: TObject);
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
    FState: TCanvasState; // ���������� ��������� ��� ������ � ������
    FGraph: TGraph; // ���� ��� ��������������
    FActiveVertice: TPVertice; // ��������� �� ����������� �������
    procedure StartSearch(State: TCanvasState; v, u: Integer);
  end;

var
  fmEditor: TfmEditor;

implementation

{$R *.dfm}

procedure TfmEditor.fmEditorCreate(Sender: TObject);
begin
  FState := stNone;
  InitializeGraph(FGraph);
  FActiveVertice := nil;
end;

procedure TfmEditor.fmEditorClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyGraph(FGraph); // ������������ ������� ������
end;

procedure TfmEditor.SetCanvasState(Sender: TObject);
begin

  if FGraph.isPainted then
  begin
    MakePassive(FGraph);
    pbCanvas.Invalidate;
  end
  else if FActiveVertice <> nil then
  begin
    FActiveVertice.Style := stPassive;
    FActiveVertice := nil;
    pbCanvas.Invalidate;
  end;

  if (Sender as TSpeedButton).Down then
    FState := TCanvasState((Sender as TSpeedButton).Tag)
  else
    FState := stNone;
end;

procedure TfmEditor.pbCanvasClick(Sender: TObject);
var
  Pos: TPoint; // ������� ������� ����
  SelectedVertice: TPVertice; // ��������� �� �������
  mrInput: TModalResult;
begin

  Pos := ScreenToClient(Mouse.CursorPos);
  if FGraph.isPainted then
    MakePassive(FGraph);

  // ������� ���������� ���������
  case FState of
    stAddVertice: // ���������� �������
      AddVertice(FGraph, Pos);

    stDeleteVertice: // �������� �������
      begin
        SelectedVertice := GetByPoint(FGraph, Pos);
        if SelectedVertice <> nil then
          DeleteVertice(FGraph, SelectedVertice.Number);

      end;
    stAddArc, stDeleteArc, stDFS, stBFS, stDijkstra: // �������� �� 2-� ��������
      begin
        SelectedVertice := GetByPoint(FGraph, Pos);

        if (SelectedVertice <> nil) and (FActiveVertice = nil) then
        begin
          FActiveVertice := SelectedVertice;
          FActiveVertice.Style := stActive;
          SelectedVertice := nil;
          pbCanvas.Invalidate;
        end;

        if (FActiveVertice = nil) or (SelectedVertice = nil) then
          Exit;

        case FState of
          stAddArc: // ���������� ����
            begin
              if not cbNoWeight.Checked then
                mrInput := fmArcInput.ShowModal
              else
                mrInput := mrOk;

              if mrInput = mrOk then
                AddArc(FGraph, FActiveVertice.Number, SelectedVertice.Number,
                  fmArcInput.Weight);
            end;

          stDeleteArc: // �������� ����
            DeleteArc(FGraph, FActiveVertice.Number, SelectedVertice.Number);

          stDFS, stBFS, stDijkstra: // ��������� ������
            StartSearch(FState, FActiveVertice.Number, SelectedVertice.Number);
        end;
        // ����� case

        // ����� ��������� �������
        if FActiveVertice.Style = stActive then
          FActiveVertice.Style := stPassive;
        FActiveVertice := nil;

      end;
  end; // ����� case

  if FState <> stNone then
    pbCanvas.Invalidate;
end;

procedure TfmEditor.pbCanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Pos: TPoint;
begin
  if FState = stMove then
  begin
    Pos := ScreenToClient(Mouse.CursorPos);
    FActiveVertice := GetByPoint(FGraph, Pos);
    if FActiveVertice <> nil then
      FActiveVertice.Style := stActive;
  end;
end;

procedure TfmEditor.pbCanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (FState = stMove) and (FActiveVertice <> nil) then
  begin
    FActiveVertice.Style := stPassive;
    FActiveVertice := nil;
    pbCanvas.Invalidate;
  end;
end;

procedure TfmEditor.pbCanvasMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  Pos: TPoint;
begin
  if (FState = stMove) and (FActiveVertice <> nil) then
  begin
    Pos := ScreenToClient(Mouse.CursorPos);
    FActiveVertice.Center := Pos;
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
    DestroyGraph(FGraph);
    FGraph := NewGraph;
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
  SaveGraph(FGraph, sdVertices.FileName, sdArcs.FileName);

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
  DestroyGraph(FGraph);
  InitializeGraph(FGraph);
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
      RedrawGraph(Bitmap.Canvas, Bitmap.Width, Bitmap.Height, FGraph);
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
      ImportGraph(NewGraph, odImport.FileName);
      MakeRegPolygon(NewGraph, pbCanvas.Width, pbCanvas.Height);
      DestroyGraph(FGraph);
      FGraph := NewGraph;
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
  try
    RedrawGraph(pbCanvas.Canvas, pbCanvas.Width, pbCanvas.Height, FGraph);
  except
    DestroyGraph(FGraph);
    InitializeGraph(FGraph);
  end;
end;

procedure TfmEditor.StartSearch(State: TCanvasState; v, u: Integer);
var
  Weights: TWeightMatrix;
  // ������� �����
  Info: TSearchInfo;
begin
  Weights := ToWeightMatrix(FGraph);
  // �������������� � ������� ����������

  // ����� ��������� ������
  case State of
    stDFS:
      Info := DFS(Weights, v, u);
    stBFS:
      Info := BFS(Weights, v, u);
    stDijkstra:
      Info := Dijkstra(Weights, v, u);
  end;

  // ��������� � ������������ �������� �������
  if Info.Path <> nil then
  begin
    MakeVisited(FGraph, Info.Path);
    fmSearchOutput.Info := Info;
    fmSearchOutput.Show;
  end
  else
    ShowMessage('���� �� ������.');
end;

end.
