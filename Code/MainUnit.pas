unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph,
  DynStructures, GraphDrawing;

type
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
    nOpen: TMenuItem;
    nSave: TMenuItem;
    nExit: TMenuItem;
    nClear: TMenuItem;
    nAbout: TMenuItem;
    N1: TMenuItem;
    procedure frmGraphEditorCreate(Sender: TObject);
    procedure frmGraphEditorClose(Sender: TObject; var Action: TCloseAction);
    procedure SetClickState(Sender: TObject);
    procedure imGraphCanvasClick(Sender: TObject);
    procedure SaveGraph(Sender: TObject);
    procedure OpenGraph(Sender: TObject);
    procedure nExitClick(Sender: TObject);
  end;

  // ��� ������ ������ � ������
  TClickState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stDFS,
    stBFS, stDijkstra, stNone);

var
  frmGraphEditor: TfrmGraphEditor;
  State: TClickState; // ���������� ��������� ��� ������ � ������
  G: TGraph; // ���� ��� ��������������
  StartVertice: TPVertice = nil; // ��������� �� ����������� �������
  isToRedraw: Boolean = false; // ���� � ���, ��� ���������� ������������ ����

const
  R = 40; // ������ ������� �����

implementation

{$R *.dfm}

// ��������������� ������� ��� ������ �������� ������
function StartSearch(const G: TGraph; State: TClickState;
  v, u: Integer): Boolean;
var
  Weights: TWeights; // ������� �����
  Path: TStack; // ���������� ����
  Vertice: TPVertice; // ��������� �� �������
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
  while not isEmpty(Path) do
  begin
    v := Pop(Path);
    GetByNumber(G, v, Vertice);
    Vertice.Design := dgVisited;
  end; // ����� �1

end;

// ����� �������� �����
procedure TfrmGraphEditor.frmGraphEditorCreate(Sender: TObject);
begin
  State := stNone; // ������������� ������ ������

  // ������������� ����������� ��������
  with frmGraphEditor.imGraphCanvas.Canvas do
  begin
    Pen.Width := 3;
    Font.Size := 15;
    Font.Style := [fsBold];
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
  isToRedraw := isToRedraw or (StartVertice <> nil);
  if isToRedraw then
    RedrawGraph(imGraphCanvas, R, G, true);

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
  if isToRedraw then
  begin
    RedrawGraph(imGraphCanvas, R, G, true);
    isToRedraw := false;
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
          if StartVertice = nil then
            Exit;
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
                StartVertice.Design := dgPassive;
                if not AreAdjacent(G, Vertice.Number, StartVertice.Number) then
                  AddArc(G, StartVertice.Number, Vertice.Number)
                else
              end;
            stDeleteArc: // �������� �����
              begin
                StartVertice.Design := dgPassive;
                if AreAdjacent(G, StartVertice.Number, Vertice.Number) then
                  DeleteArc(G, StartVertice.Number, Vertice.Number);
              end;
            stDFS, stBFS, stDijkstra: // ��������� ������
              begin
                isFound := StartSearch(G, State, StartVertice.Number,
                  Vertice.Number);
                if not isFound then
                begin
                  Vertice.Design := dgPassive;
                  ShowMessage('���� �� ������.');
                end;
                isToRedraw := true; // ���� � ������������� �����������
              end;
          end;
          StartVertice := nil; // ����� ��������� ������� ����� ��������� �����
        end; // ����� case

      end; // ����� else
  end; // ����� case

  // ����������� �����
  if State <> stNone then
    RedrawGraph(imGraphCanvas, R, G, false);
end;

// ����� ������ �� ���������
procedure TfrmGraphEditor.nExitClick(Sender: TObject);
begin
  Close;
end;

// ����� �������� ����� �� �����
procedure TfrmGraphEditor.OpenGraph(Sender: TObject);
var
  fVertices: File of TVertice;
  fArcs: File of TItem;
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
  v, u: Integer;
begin

  // ������������� �����
  DestroyGraph(G);
  InitializeGraph(G);

  // ���������� ������
  System.Assign(fVertices, 'Graph.ver');
  System.Assign(fArcs, 'Graph.arc');
  Reset(fVertices);
  Reset(fArcs);

  // ���� �1. ������ �� ����� ������
  v := 0;
  while not Eof(fVertices) do
  begin
    if v = 0 then
    begin

      // ������ ������ ������ ������
      New(Vertice);
      Read(fVertices, Vertice^);
      G.Head := Vertice;

    end // ����� if
    else
    begin

      // ������ �� �������� �������
      New(Vertice.Next);
      Vertice := Vertice.Next;
      Read(fVertices, Vertice^);

    end; // ����� else

    // ���� �2.������ ������� �� ����� ����
    u := 1;
    while (Vertice.Deg <> 0) and (u < Vertice.Deg) do
    begin
      if u = 1 then
      begin

        // ������ ������ � ������ ������
        New(AdjVertice);
        Read(fArcs, AdjVertice^);
        Vertice.Head := AdjVertice;

      end // ����� if
      else
      begin

        // ������ �� ��������� ������
        New(AdjVertice.Next);
        AdjVertice := AdjVertice.Next;
        Read(fArcs, AdjVertice^);

      end; // ����� else
      Inc(u);
    end; // ����� A2

    Inc(v);
  end; // ����� �1

  G.Order := v;
  RedrawGraph(imGraphCanvas, R, G, true);
end;

// ����� ���������� ����� � ����
procedure TfrmGraphEditor.SaveGraph(Sender: TObject);
var
  fVertices: File of TVertice;
  fArcs: File of TItem;
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin

  // ����������� �����
  isToRedraw := isToRedraw or (StartVertice <> nil);
  if isToRedraw then
  begin
    RedrawGraph(imGraphCanvas, R, G, true);
    isToRedraw := false;
  end;

  // ������������� ������
  System.Assign(fVertices, 'Graph.ver');
  System.Assign(fArcs, 'Graph.arc');
  Rewrite(fVertices);
  Rewrite(fArcs);

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
