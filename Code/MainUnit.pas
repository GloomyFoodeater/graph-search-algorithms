unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph,
  DynStructures;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    AddNodeBtn: TSpeedButton;
    AddLinkBtn: TSpeedButton;
    DeleteNodeBtn: TSpeedButton;
    DeleteLinkBtn: TSpeedButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    DFSBtn: TSpeedButton;
    BFSbtn: TSpeedButton;
    DijkstraBtn: TSpeedButton;
    Button1: TButton;
    procedure FormClick(Sender: TObject);
    procedure AddNodeBtnClick(Sender: TObject);
    procedure AddLinkBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DFSBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BFSbtnClick(Sender: TObject);
    procedure DeleteLinkBtnClick(Sender: TObject);
    procedure DeleteNodeBtnClick(Sender: TObject);
    procedure DijkstraBtnClick(Sender: TObject);
    procedure SaveGraph(Sender: TObject);
    procedure OpenGraph(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  // ��� ������ ������ � ������
  TClickState = (stAddNode, stAddLink, stDeleteNode, stDeleteLink, stDFS, stBFS,
    stDijkstra, stNone);

var
  Form1: TForm1;
  State: TClickState;
  G: TGraph;
  StartNode: Integer = 0;
  StartNodeCenter: TPoint;

const
  R = 40;

implementation

{$R *.dfm}

{ ��������� ���������� ��������� ������ ����� �� ������ }
procedure GetLinkPoints(c1, c2: TPoint; var p: Array of TPoint);
var
  d: Integer;
begin
  d := Distance(c1, c2);

  p[0].x := Round(c2.x + R * (c1.x - c2.x) / d);
  p[0].y := Round(c2.y + R * (c1.y - c2.y) / d);

  p[1].x := Round(c1.x + R * (c2.x - c1.x) / d);
  p[1].y := Round(c1.y + R * (c2.y - c1.y) / d);

end;

{ ��������� ��������� ������� ����� }
procedure DrawNode(u: Integer; Center: TPoint);
var
  Caption: String; // ��� �������
  PosX: Integer; // ����� ������� ���� ������
  Copy: Integer; // ����� ������ �������
begin

  // ��������� ����� ������� � ��� x-����������
  Str(u, Caption);
  Copy := u;
  PosX := Center.x;
  while Copy <> 0 do
  begin
    Copy := Copy div 10;
    PosX := PosX - 4;
  end;

  // ����� �����
  Form1.Canvas.Ellipse(Center.x - R, Center.y - R, Center.x + R, Center.y + R);

  // ����� ����� �������
  Form1.Canvas.TextOut(PosX + 1, Center.y - 6, Caption);
end;

{ ��������� ��������� ����� ����� }
procedure DrawLink(G: TGraph; c1, c2: TPoint);
var
  d: Integer;
  Points: Array [1 .. 2] of TPoint;
begin
  d := Distance(c1, c2);
  if d > R then
  begin
    GetLinkPoints(c1, c2, Points);
    Form1.Canvas.Polyline(Points);

    Form1.Canvas.Ellipse(Points[1].x - 5, Points[1].y - 5, Points[1].x + 5,
      Points[1].y + 5);
  end;
end;

procedure RedrawGraph(const G: TGraph);
var
  Weights: TWeights;
  u, v: Integer;
begin
  Form1.Canvas.Pen.Color := clWhite;
  Form1.Canvas.Rectangle(0, 0, Form1.Width, Form1.Height);
  Form1.Canvas.Pen.Color := clBlack;
  ToWeightMatrix(G, Weights);
  if Length(Weights) = 0 then
    Exit;

  for u := 0 to G.Order - 1 do
  begin
    DrawNode(u + 1, GetCenter(G, u + 1));
    for v := 0 to G.Order - 1 do
    begin
      if Weights[u, v] <> INFINITY then
        DrawLink(G, GetCenter(G, u + 1), GetCenter(G, v + 1));

    end;
  end;

end;

// ������� ������� �� �����
procedure TForm1.FormClick(Sender: TObject);
var
  Pos: TPoint;
  EndNode: Integer;
  d: Integer;
  Path: TStack;
  sPath: String;
  AdjMatrix: TWeights;
begin
  // ��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);
  case State of
    stAddNode: // ���������� ������� �����
      begin
        AddNode(G, Pos);
        DrawNode(G.Order, Pos);
      end;
    stAddLink:
      begin
        if StartNode = 0 then
        begin
          Centralize(G, Pos, R, StartNode);
          StartNodeCenter := Pos;
        end
        else
        begin
          Centralize(G, Pos, R, EndNode);
          if (EndNode <> 0) and (StartNode <> EndNode) then
          begin
            AddLink(G, StartNode, EndNode);
            DrawLink(G, StartNodeCenter, Pos);
            StartNode := 0;
            EndNode := 0;
          end;
        end;
      end;
    stDeleteNode:
      begin
        Centralize(G, Pos, R, StartNode);
        if StartNode <> 0 then
        begin
          if (StartNode >= 1) and (StartNode < G.Order) then
            DeleteNode(G, StartNode);
          RedrawGraph(G);
        end;
      end;
    stDeleteLink:
      begin
        if StartNode = 0 then
        begin
          Centralize(G, Pos, R, StartNode);
        end
        else
        begin
          Centralize(G, Pos, R, EndNode);
          if (EndNode <> 0) and (StartNode <> EndNode) then
          begin
            DeleteLink(G, StartNode, EndNode);
            RedrawGraph(G);
            StartNode := 0;
          end;
        end;
      end;
    stDFS, stBFS, stDijkstra:
      begin
        if StartNode = 0 then
        begin
          Centralize(G, Pos, R, StartNode);
          StartNodeCenter := Pos;
        end
        else
        begin
          Centralize(G, Pos, R, EndNode);
          if (EndNode <> 0) then
          begin

            ToWeightMatrix(G, AdjMatrix);
            // ��������� ���� � ������� ���������
            case State of
              stDFS:
                DFS(AdjMatrix, StartNode, EndNode, Path); // ����� � �������
              stBFS:
                BFS(AdjMatrix, StartNode, EndNode, Path); // ����� � ������
              stDijkstra:
                Dijkstra(AdjMatrix, StartNode, EndNode, Path);
            end;

            if not isEmpty(Path) then
            begin

              // ������ ���������������� ���������
              sPath := '��������� ���� �� ������� ' + IntToStr(StartNode) +
                ' � ������� ' + IntToStr(EndNode) + ':'#13#10;

              // ��������� 1-�� �������� ����
              sPath := sPath + IntToStr(Pop(Path));
            end
            else

              // ��������������� ��������� � ��������������� ����
              sPath := '������� ' + IntToStr(EndNode) +
                ' �� ��������� �� ������� ' + IntToStr(StartNode) + '.';

            // ������ ���� � ������
            while not isEmpty(Path) do
              sPath := sPath + '->' + IntToStr(Pop(Path));

            // ����� ����
            MessageBox(Handle, PChar(sPath), PChar('���������� ������'), MB_OK);

            // ��������� ��������� � �������� �������
            StartNode := 0;
          end;
        end;
      end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyGraph(G);
end;

procedure TForm1.OpenGraph(Sender: TObject);
var
  fVertices: File of TVerticeNode;
  fArcs: File of TNode;
  Node: TVerticeList;
  Neighbour: TList;
  i: Integer;
  j: Integer;
begin
  DestroyGraph(G);
  InitializeGraph(G);

  System.Assign(fVertices, 'Graph.ver');
  System.Assign(fArcs, 'Graph.arc');

  Reset(fVertices);
  Reset(fArcs);

  i := 0;
  while not Eof(fVertices) do
  begin

    // ������ ������� �� ����� ������
    if i = 0 then
    begin

      // ������ ������ ������ ������
      New(Node);
      Read(fVertices, Node^);
      G.Head := Node;
    end
    else
    begin

      // ������ �� �������� �������
      New(Node.Next);
      Node := Node.Next;
      Read(fVertices, Node^);
    end;

    if Node.Deg <> 0 then
    begin
      for j := 1 to Node.Deg do
      begin
        if j = 1 then
        begin
          New(Neighbour);
          Read(fArcs, Neighbour^);
          Node.Head := Neighbour;
        end
        else
        begin
          New(Neighbour.Next);
          Neighbour := Neighbour.Next;
          Read(fArcs, Neighbour^);
        end;

      end;
    end;

    Inc(i);
  end;

  G.Tail := Node;
  G.Order := i;
  RedrawGraph(G);
end;

procedure TForm1.SaveGraph(Sender: TObject);
var
  fVertices: File of TVerticeNode;
  fArcs: File of TNode;
  Node: TVerticeList;
  Neighbour: TList;
begin
  System.Assign(fVertices, 'Graph.ver');
  System.Assign(fArcs, 'Graph.arc');

  Rewrite(fVertices);
  Rewrite(fArcs);

  Node := G.Head;
  while Node <> nil do
  begin
    Write(fVertices, Node^);
    Neighbour := Node.Head;
    while Neighbour <> nil do
    begin
      Write(fArcs, Neighbour^);
      Neighbour := Neighbour.Next;
    end;
    Node := Node.Next;
  end;
end;

procedure TForm1.DijkstraBtnClick(Sender: TObject);
begin
  StartNode := 0;
  if DijkstraBtn.Down then
    State := stDijkstra
  else
    State := stNone;
end;

procedure TForm1.DeleteNodeBtnClick(Sender: TObject);
begin
  StartNode := 0;
  if DeleteNodeBtn.Down then
    State := stDeleteNode
  else
    State := stNone;
end;

procedure TForm1.DeleteLinkBtnClick(Sender: TObject);
begin
  StartNode := 0;
  if DeleteLinkBtn.Down then
    State := stDeleteLink
  else
    State := stNone;
end;

procedure TForm1.BFSbtnClick(Sender: TObject);
begin
  StartNode := 0;
  if BFSbtn.Down then
    State := stBFS
  else
    State := stNone;
end;

procedure TForm1.DFSBtnClick(Sender: TObject);
begin
  StartNode := 0;
  if DFSBtn.Down then
    State := stDFS
  else
    State := stNone;
end;

procedure TForm1.AddLinkBtnClick(Sender: TObject);
begin
  StartNode := 0;
  if AddLinkBtn.Down then
    State := stAddLink
  else
    State := stNone;
end;

procedure TForm1.AddNodeBtnClick(Sender: TObject);
begin
  StartNode := 0;
  if AddNodeBtn.Down then
    State := stAddNode
  else
    State := stNone;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  p: Array [1 .. 5] of TPoint = ((x: 300; y: 300), (x: 200; y: 400), (x: 400;
    y: 400), (x: 300; y: 500), (x: 300; y: 100));
var
  i: Integer;
begin
  InitializeGraph(G);
  for i := 1 to 5 do
  begin
    AddNode(G, p[i]);
    DrawNode(i, p[i]);
  end;
  for i := 2 to 5 do
  begin
    AddLink(G, 1, i);
    DrawLink(G, GetCenter(G, 1), GetCenter(G, i));
  end;
  Button1.Visible := false;
end;

end.
