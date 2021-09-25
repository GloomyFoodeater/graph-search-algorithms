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

  TfrmGraphEditor = class(TForm)
    plFunctionsContainer: TPanel;
    AddNodeBtn: TSpeedButton;
    AddLinkBtn: TSpeedButton;
    DeleteNodeBtn: TSpeedButton;
    DeleteLinkBtn: TSpeedButton;
    DFSBtn: TSpeedButton;
    BFSbtn: TSpeedButton;
    DijkstraBtn: TSpeedButton;
    imGraphCanvas: TImage;
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
    sdVerticeSaver: TSaveDialog;
    sdArcsSaver: TSaveDialog;
    odVerticeOpener: TOpenDialog;
    odArcsOpener: TOpenDialog;
    procedure frmGraphEditorCreate(Sender: TObject);
    procedure frmGraphEditorClose(Sender: TObject; var Action: TCloseAction);
    procedure SetClickState(Sender: TObject);
    procedure imGraphCanvasClick(Sender: TObject);
    procedure nExitClick(Sender: TObject);
    procedure nClearClick(Sender: TObject);
    procedure nOpenClick(Sender: TObject);
    procedure nSaveClick(Sender: TObject);
    procedure nSaveAsClick(Sender: TObject);
    procedure nAboutClick(Sender: TObject);
  private
    State: TClickState; // ���������� ��������� ��� ������ � ������
    G: TGraph; // ���� ��� ��������������
    StartVertice: TPVertice; // ��������� �� ����������� �������
    wasPainted: Boolean; // ���� � ���, ��� ���������� ������������ ����
    VerticesFileName, ArcsFileName: String; // ��������� ����� ������

    function StartSearch(const G: TGraph; State: TClickState;
      v, u: Integer): Boolean;
    function OpenGraph(var fVertices: TVerFile; var fArcs: TArcFile): Boolean;
    procedure SaveGraph(var fVertices: TVerFile; var fArcs: TArcFile);

  const
    R = 40; // ������ ������� �����

  end;

var
  frmGraphEditor: TfrmGraphEditor;

implementation

{$R *.dfm}

// ��������������� ������� ��� ������ �������� ������
function TfrmGraphEditor.StartSearch(const G: TGraph; State: TClickState;
  v, u: Integer): Boolean;
var
  Weights: TWeights; // ������� �����
  Path: TStack; // ���������� ����
  Vertice: TPVertice; // ��������� �� �������
  flag: Boolean;
begin
  ToWeightMatrix(G, Weights); // �������������� � ������� ����������

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
  Result := not isEmpty(Path);

  // ���� �1. ���������� ������ ����
  flag := true;
  while not isEmpty(Path) do
  begin
    v := Pop(Path);
    GetByNumber(G, v, Vertice);
    if flag or isEmpty(Path) then
    begin
      Vertice.Design := dgEndPoint;
      flag := false;
    end
    else
      Vertice.Design := dgVisited;
  end; // ����� �1

end;

// ����� �������� �����
procedure TfrmGraphEditor.frmGraphEditorCreate(Sender: TObject);
begin
  State := stNone; // ������������� ������ ������
  InitializeGraph(G); // ������������� �����

  // ������������� ��������� ��� ������
  VerticesFileName := '';
  ArcsFileName := '';

  // ������������� ����������� ��������
  with frmGraphEditor.imGraphCanvas.Canvas do
  begin
    Pen.Width := 3;
    Font.Size := 15;
    Font.Style := [fsBold];
    StartVertice := nil;
    wasPainted := false;
  end;
end;

// ����� �������� �����
procedure TfrmGraphEditor.frmGraphEditorClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DestroyGraph(G); // ������������ ������� ������
end;

// ����� ��������� ���������� ��������� ����� ������ �� ������
procedure TfrmGraphEditor.SetClickState(Sender: TObject);
var
  i: Integer; // ����� ������ �� ������
  Child: TControl; // ������ ��������� �� ������
begin

  // ����������� � ������ �������������
  if wasPainted or (StartVertice <> nil) then
  begin
    RedrawGraph(imGraphCanvas, R, G, true);
    wasPainted := false;
  end;

  // ������������� ������ ������ � ��������� �������
  StartVertice := nil;
  State := stNone;

  // ���� �1. ������� ��������� ������
  for i := 0 to plFunctionsContainer.ControlCount - 1 do
  begin
    Child := plFunctionsContainer.Controls[i];
    if (Child as TSpeedButton).Down then
      State := TClickState(i);
  end; // ����� �1
end;

// �������� ����� ��� �������������� �����
procedure TfrmGraphEditor.imGraphCanvasClick(Sender: TObject);
var
  Pos: TPoint; // ������� ������� ����
  Vertice: TPVertice; // ��������� �� �������
  isFound: Boolean; // ���� � ������������ ������� ��� ������
begin

  // ����������� �����
  if wasPainted then
  begin
    RedrawGraph(imGraphCanvas, R, G, wasPainted);
    wasPainted := false;
  end;

  // ������� ���������� ���������
  Pos := ScreenToClient(Mouse.CursorPos);
  case State of
    stAddVertice: // ���������� �������
      AddVertice(G, Pos);
    stDeleteVertice: // �������� �������
      begin
        Centralize(G, Pos, R, Vertice);
        if Vertice <> nil then
          DeleteVertice(G, Vertice.Number);
      end;
    stAddArc, stDeleteArc, stDFS, stBFS, stDijkstra: // �������� �� 2-� ��������
      begin
        if StartVertice = nil then
        begin

          // ��������� ��������� �������
          Centralize(G, Pos, R, StartVertice);
          if StartVertice <> nil then
            StartVertice.Design := dgActive;

        end // ����� if
        else
        begin
          Centralize(G, Pos, R, Vertice);
          if Vertice = nil then
            Exit;

          // ������� ���������� ���������
          case State of
            stAddArc: // ���������� �����
              begin
                if not AreAdjacent(G, Vertice.Number, StartVertice.Number) then
                  AddArc(G, StartVertice.Number, Vertice.Number);
                StartVertice.Design := dgPassive;
              end;
            stDeleteArc: // �������� �����
              begin
                if AreAdjacent(G, StartVertice.Number, Vertice.Number) then
                  DeleteArc(G, StartVertice.Number, Vertice.Number);
                StartVertice.Design := dgPassive;
              end;
            stDFS, stBFS, stDijkstra: // ��������� ������
              begin
                isFound := StartSearch(G, State, StartVertice.Number,
                  Vertice.Number);
                if not isFound then
                  ShowMessage('���� �� ������.');
                wasPainted := true; // ���� � ������������� �����������
              end;
          end;
          StartVertice := nil; // ����� ��������� ������� ����� ��������� �����
        end; // ����� case

      end; // ����� else
  end; // ����� case

  // ����������� �����
  if State <> stNone then
    RedrawGraph(imGraphCanvas, R, G);
end;

procedure TfrmGraphEditor.nOpenClick(Sender: TObject);
var
  fVertices: TVerFile;
  fArcs: TArcFile;
  isSuccess: Boolean;
begin
  odVerticeOpener.FileName := '';
  odArcsOpener.FileName := '';

  // ����� ����� � ���������
  if odVerticeOpener.Execute then
  begin

    // �������� ������������ ����������
    if ExtractFileExt(odVerticeOpener.FileName) <> '.ver' then
    begin
      ShowMessage('������ ���� � �������� �����������.');
      Exit;
    end;

    // ����� ����� � ������
    if odArcsOpener.Execute then
    begin

      // �������� ������������ ����������
      if ExtractFileExt(odArcsOpener.FileName) <> '.arc' then
      begin
        ShowMessage('������ ���� � �������� �����������.');
        Exit;
      end;

      // ������������� �����
      DestroyGraph(G);
      InitializeGraph(G);

      // ���������� ������
      System.Assign(fVertices, odVerticeOpener.FileName);
      System.Assign(fArcs, odArcsOpener.FileName);
      Reset(fVertices);
      Reset(fArcs);

      // ������ �����

      isSuccess := OpenGraph(fVertices, fArcs);
      // ��������� ������
      if not isSuccess then
      begin
        DestroyGraph(G);
        InitializeGraph(G);
        ShowMessage('������ ������ �����������.');
      end
      else
      begin
        VerticesFileName := odVerticeOpener.FileName;
        ArcsFileName := odArcsOpener.FileName;
      end;

      // �������� ������
      CloseFile(fVertices);
      CloseFile(fArcs);

      // ����������� �����
      RedrawGraph(imGraphCanvas, R, G);
    end;

  end;

end;

procedure TfrmGraphEditor.nSaveAsClick(Sender: TObject);
begin

  sdVerticeSaver.FileName := '';
  sdArcsSaver.FileName := '';

  // ����� ����� � ���������
  if not sdVerticeSaver.Execute then
    Exit;

  // �������� ������������ ����������
  if ExtractFileExt(sdVerticeSaver.FileName) <> '.ver' then
  begin
    ShowMessage('������ ���� � �������� �����������.');
    Exit;
  end;

  // ����� ����� � ������
  if not sdArcsSaver.Execute then
    Exit;

  // �������� ������������ ����������
  if ExtractFileExt(sdArcsSaver.FileName) <> '.arc' then
  begin
    ShowMessage('������ ���� � �������� �����������.');
    Exit;
  end;

  // ���������� ����� � ����� � ���������� �����
  VerticesFileName := sdVerticeSaver.FileName;
  ArcsFileName := sdArcsSaver.FileName;
  nSaveClick(Sender);

end;

procedure TfrmGraphEditor.nSaveClick(Sender: TObject);
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
procedure TfrmGraphEditor.nAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmGraphEditor.nClearClick(Sender: TObject);
begin
  DestroyGraph(G);
  InitializeGraph(G);
  RedrawGraph(imGraphCanvas, R, G);
end;

// ����� ������ �� ���������
procedure TfrmGraphEditor.nExitClick(Sender: TObject);
begin
  Close;
end;

// ����� �������� ����� �� �����
function TfrmGraphEditor.OpenGraph(var fVertices: TVerFile;
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
    AddVertice(G, Vertice.Center);

    // �������� ������������ ����������� �������
    with Vertice^ do
    begin
      Result := Number = G.Tail.Number;
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
        AddArc(G, Vertice.Number, AdjVertice.Number);
        Inc(v);
        // ������� � ���������� ������
      end;
    end; // ����� �2

    Result := Result and (AdjVertice.Next = nil); // �������� �� ������� �������

  end; // ����� �1

  Dispose(Vertice);
  Dispose(AdjVertice);
end;

// ����� ���������� ����� � ����
procedure TfrmGraphEditor.SaveGraph(var fVertices: TVerFile;
  var fArcs: TArcFile);
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin

  // ���� �1. ������ �� ��������
  Vertice := G.Head;
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
