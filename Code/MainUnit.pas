unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph,
  DynStructures, GraphDrawing, AboutForm;

type

  // ��� ������ ������ � ������
  TClickState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stDFS,
    stBFS, stDijkstra, stNone);
  TVerFile = File of TVertice;
  TArcFile = File of TItem;

  TfmEditor = class(TForm)
    plFunctionsContainer: TPanel;
    AddNodeBtn: TSpeedButton;
    AddLinkBtn: TSpeedButton;
    DeleteNodeBtn: TSpeedButton;
    DeleteLinkBtn: TSpeedButton;
    DFSBtn: TSpeedButton;
    BFSbtn: TSpeedButton;
    DijkstraBtn: TSpeedButton;
    mmMain: TMainMenu;
    nFile: TMenuItem;
    nEdit: TMenuItem;
    nHelp: TMenuItem;
    nSave: TMenuItem;
    nExit: TMenuItem;
    nClear: TMenuItem;
    nAbout: TMenuItem;
    N1: TMenuItem;
    nOpen: TMenuItem;
    nSaveAs: TMenuItem;
    sdVertices: TSaveDialog;
    sdArcs: TSaveDialog;
    odVertices: TOpenDialog;
    odArcs: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    pbCanvas: TPaintBox;
    procedure fmEditorCreate(Sender: TObject);
    procedure fmEditorClose(Sender: TObject; var Action: TCloseAction);
    procedure SetClickState(Sender: TObject);
    procedure pbCanvasClick(Sender: TObject);
    procedure nExitClick(Sender: TObject);
    procedure nClearClick(Sender: TObject);
    procedure nOpenClick(Sender: TObject);
    procedure nSaveClick(Sender: TObject);
    procedure nSaveAsClick(Sender: TObject);
    procedure nAboutClick(Sender: TObject);
    procedure pbCanvasPaint(Sender: TObject);
  private
    State: TClickState; // ���������� ��������� ��� ������ � ������
    Graph: TGraph; // ���� ��� ��������������
    VStart: TPVertice; // ��������� �� ����������� �������
    VerticesFileName, ArcsFileName: String; // ��������� ����� ������

    function StartSearch(const Graph: TGraph; State: TClickState;
      v, u: Integer): Boolean;
    function OpenGraph(var fVertices: TVerFile; var fArcs: TArcFile): Boolean;
    procedure SaveGraph(var fVertices: TVerFile; var fArcs: TArcFile);
  end;

var
  fmEditor: TfmEditor;

implementation

{$R *.dfm}

// ��������������� ������� ��� ������ �������� ������
function TfmEditor.StartSearch(const Graph: TGraph; State: TClickState;
  v, u: Integer): Boolean;
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

  // ���� �1. ���������� ������ ����
  while Path <> nil do
  begin
    v := Pop(Path);
    GetByNumber(Graph, v, Vertice);
    Vertice.Design := dgVisited;
  end; // ����� �1

end;

// ����� �������� �����
procedure TfmEditor.fmEditorCreate(Sender: TObject);
begin
  State := stNone;
  InitializeGraph(Graph, 40);
  VerticesFileName := '';
  ArcsFileName := '';
  VStart := nil;
end;

// ����� �������� �����
procedure TfmEditor.fmEditorClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyGraph(Graph); // ������������ ������� ������
end;

// ����� ��������� ���������� ��������� ����� ������ �� ������
procedure TfmEditor.SetClickState(Sender: TObject);
var
  i: Integer; // ����� ������ �� ������
  Child: TControl; // ������ ��������� �� ������
begin

  if Graph.isPainted or (VStart <> nil) then
  begin
    if VStart <> nil then
      VStart.Design := dgPassive
    else
      Graph.isPainted := false;
    pbCanvas.Invalidate;
  end;

  // ������������� ������ ������ � ��������� �������
  VStart := nil;
  State := stNone;

  // ���� �1. ������� ��������� ������
  for i := 0 to plFunctionsContainer.ControlCount - 1 do
  begin
    Child := plFunctionsContainer.Controls[i];
    if (Child is TSpeedButton) and (Child as TSpeedButton).Down then
      State := TClickState(i);
  end; // ����� �1
end;

// �������� ����� ��� �������������� �����
procedure TfmEditor.pbCanvasClick(Sender: TObject);
var
  Pos: TPoint; // ������� ������� ����
  VEnd: TPVertice; // ��������� �� �������
  isFound: Boolean; // ���� � ������������ ������� ��� ������
begin

  // ������� ���������� ���������
  Pos := ScreenToClient(Mouse.CursorPos);

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
          VStart.Design := dgPassive;

          // ������� ���������� ���������
          case State of
            stAddArc: // ���������� ����
              AddArc(Graph, VStart.Number, VEnd.Number);
            stDeleteArc: // �������� ����
              DeleteArc(Graph, VStart.Number, VEnd.Number);
            stDFS, stBFS, stDijkstra: // ��������� ������
              begin
                isFound := StartSearch(Graph, State, VStart.Number,
                  VEnd.Number);
                if not isFound then
                  ShowMessage('���� �� ������.')
                else
                  Graph.isPainted := true;
              end;
          end; // ����� case

          // ����� ��������� �������
          VStart := nil;
        end; // ����� else if

      end;
  end; // ����� case

  if State <> stNone then
    pbCanvas.Invalidate;

end;

procedure TfmEditor.nOpenClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
  isSuccess: Boolean;
begin
  odVertices.FileName := '';
  odArcs.FileName := '';

  // ����� ����� � ���������
  if not odVertices.Execute then
    Exit;

  // �������� ������������ ����������
  if ExtractFileExt(odVertices.FileName) <> '.ver' then
  begin
    ShowMessage('������ ���� � �������� �����������.');
    Exit;
  end;

  // ����� ����� � ������
  if not odArcs.Execute then
    Exit;

  // �������� ������������ ����������
  if ExtractFileExt(odArcs.FileName) <> '.arc' then
  begin
    ShowMessage('������ ���� � �������� �����������.');
    Exit;
  end;

  // ������������� �����
  DestroyGraph(Graph);
  InitializeGraph(Graph, 40);

  // ���������� ������
  System.Assign(fVertices, odVertices.FileName);
  System.Assign(fArcs, odArcs.FileName);
  Reset(fVertices);
  Reset(fArcs);

  // ������ �����
  isSuccess := OpenGraph(fVertices, fArcs);

  // ��������� ������
  if not isSuccess then
  begin
    DestroyGraph(Graph);
    InitializeGraph(Graph, 40);
    ShowMessage('������ ������ �����������.');
  end
  else
  begin
    VerticesFileName := odVertices.FileName;
    ArcsFileName := odArcs.FileName;
  end;

  // �������� ������
  CloseFile(fVertices);
  CloseFile(fArcs);

  // ����������� �����
  pbCanvas.Invalidate;

end;

procedure TfmEditor.nSaveAsClick(Sender: TObject);
begin

  sdVertices.FileName := '';
  sdArcs.FileName := '';

  // ����� ����� � ���������
  if not sdVertices.Execute then
    Exit;

  // �������� ������������ ����������
  if ExtractFileExt(sdVertices.FileName) <> '.ver' then
  begin
    ShowMessage('������ ���� � �������� �����������.');
    Exit;
  end;

  // ����� ����� � ������
  if not sdArcs.Execute then
    Exit;

  // �������� ������������ ����������
  if ExtractFileExt(sdArcs.FileName) <> '.arc' then
  begin
    ShowMessage('������ ���� � �������� �����������.');
    Exit;
  end;

  // ���������� ����� � ����� � ���������� �����
  VerticesFileName := sdVertices.FileName;
  ArcsFileName := sdArcs.FileName;
  nSaveClick(Sender);

end;

procedure TfmEditor.nSaveClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
  isSuccess: Boolean;
begin

  // ������� � "���������� ���"
  if (VerticesFileName = '') or (ArcsFileName = '') then
  begin
    Self.nSaveAsClick(Sender);
    Exit
  end;

  // ���������� ������
  System.Assign(fVertices, VerticesFileName);
  System.Assign(fArcs, ArcsFileName);
  Rewrite(fVertices);
  Rewrite(fArcs);

  // ���������� �����
  SaveGraph(fVertices, fArcs);

  // �������� ������
  CloseFile(fVertices);
  CloseFile(fArcs);
end;

// ����� ������� ������
procedure TfmEditor.nAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfmEditor.nClearClick(Sender: TObject);
begin
  DestroyGraph(Graph);
  InitializeGraph(Graph, 40);
  pbCanvas.Invalidate;
end;

// ����� ������ �� ���������
procedure TfmEditor.nExitClick(Sender: TObject);
begin
  Close;
end;

// ����� �������� ����� �� �����
function TfmEditor.OpenGraph(var fVertices: TVerFile;
  var fArcs: TArcFile): Boolean;
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
  v: Integer;
begin

  // ���� �1. ������ �� ����� ������
  Result := true;
  New(Vertice);
  New(AdjVertice);
  while Result and not Eof(fVertices) do
  begin

    // ������ ��������� �������
    Read(fVertices, Vertice^);
    AddVertice(Graph, Vertice.Center);

    // �������� ������������ ����������� �������
    with Vertice^ do
    begin
      Result := Number = Graph.Tail.Number;
      Result := Result and (Center.X >= 0) and (Center.Y >= 0);
    end;

    // ���� �2. ��������� ������ �� ����� ����
    v := 1;
    while Result and (v <= Vertice.Deg) do
    begin
      Result := not Eof(fArcs); // �������� �� ���������� �������

      // ������ ���������� ������
      if Result then
      begin
        Read(fArcs, AdjVertice^);
        AddArc(Graph, Vertice.Number, AdjVertice.Number);
        Inc(v);
        // ������� � ���������� ������
      end;
    end; // ����� �2

    Result := Result and (AdjVertice.Next = nil); // �������� �� ������� �������

  end; // ����� �1

  Dispose(Vertice);
  Dispose(AdjVertice);
end;

procedure TfmEditor.pbCanvasPaint(Sender: TObject);
begin
  RedrawGraph(pbCanvas.Canvas, pbCanvas.Width, pbCanvas.Height, Graph);
end;

// ����� ���������� ����� � ����
procedure TfmEditor.SaveGraph(var fVertices: TVerFile; var fArcs: TArcFile);
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin

  // ���� �1. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin
    Write(fVertices, Vertice^);

    // ���� �2. ������ �� �������
    AdjVertice := Vertice.Head;
    while AdjVertice <> nil do
    begin
      Write(fArcs, AdjVertice^);
      AdjVertice := AdjVertice.Next;
    end; // ����� �1
    Vertice := Vertice.Next;
  end; // ����� �2
end;

end.
