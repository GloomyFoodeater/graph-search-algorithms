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
  TClickState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stDFS, stBFS,
    stDijkstra, stNone);

var
  Form1: TForm1;
  State: TClickState;
  G: TGraph;
  StartVertice: Integer = 0;
  StartVerticeCenter: TPoint;

const
  R = 40;

implementation

{$R *.dfm}

{ ��������� ���������� ��������� ������ ����� �� ������ }
procedure GetArcPoints(c1, c2: TPoint; var p: Array of TPoint);
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
procedure DrawVertice(u: Integer; Center: TPoint);
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
procedure DrawArc(G: TGraph; c1, c2: TPoint);
var
  d: Integer;
  Points: Array [1 .. 2] of TPoint;
begin
  d := Distance(c1, c2);
  if d > R then
  begin
    GetArcPoints(c1, c2, Points);
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
    DrawVertice(u + 1, GetCenter(G, u + 1));
    for v := 0 to G.Order - 1 do
    begin
      if Weights[u, v] <> INFINITY then
        DrawArc(G, GetCenter(G, u + 1), GetCenter(G, v + 1));

    end;
  end;

end;

// ������� ������� �� �����
procedure TForm1.FormClick(Sender: TObject);
var
  Pos: TPoint;
  EndVertice: Integer;
  d: Integer;
  Path: TStack;
  sPath: String;
  AdjMatrix: TWeights;
begin
  // ��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);
  case State of
    stAddVertice: // ���������� ������� �����
      begin
        AddVertice(G, Pos);
        DrawVertice(G.Order, Pos);
      end;
    stAddArc:
      begin
        if StartVertice = 0 then
        begin
          Centralize(G, Pos, R, StartVertice);
          StartVerticeCenter := Pos;
        end
        else
        begin
          Centralize(G, Pos, R, EndVertice);
          if (EndVertice <> 0) and (StartVertice <> EndVertice) then
          begin
            AddArc(G, StartVertice, EndVertice);
            DrawArc(G, StartVerticeCenter, Pos);
            StartVertice := 0;
            EndVertice := 0;
          end;
        end;
      end;
    stDeleteVertice:
      begin
        Centralize(G, Pos, R, StartVertice);
        if StartVertice <> 0 then
        begin
          if (StartVertice >= 1) and (StartVertice < G.Order) then
            DeleteVertice(G, StartVertice);
          RedrawGraph(G);
        end;
      end;
    stDeleteArc:
      begin
        if StartVertice = 0 then
        begin
          Centralize(G, Pos, R, StartVertice);
        end
        else
        begin
          Centralize(G, Pos, R, EndVertice);
          if (EndVertice <> 0) and (StartVertice <> EndVertice) then
          begin
            DeleteArc(G, StartVertice, EndVertice);
            RedrawGraph(G);
            StartVertice := 0;
          end;
        end;
      end;
    stDFS, stBFS, stDijkstra:
      begin
        if StartVertice = 0 then
        begin
          Centralize(G, Pos, R, StartVertice);
          StartVerticeCenter := Pos;
        end
        else
        begin
          Centralize(G, Pos, R, EndVertice);
          if (EndVertice <> 0) then
          begin

            ToWeightMatrix(G, AdjMatrix);
            // ��������� ���� � ������� ���������
            case State of
              stDFS:
                DFS(AdjMatrix, StartVertice, EndVertice, Path); // ����� � �������
              stBFS:
                BFS(AdjMatrix, StartVertice, EndVertice, Path); // ����� � ������
              stDijkstra:
                Dijkstra(AdjMatrix, StartVertice, EndVertice, Path);
            end;

            if not isEmpty(Path) then
            begin

              // ������ ���������������� ���������
              sPath := '��������� ���� �� ������� ' + IntToStr(StartVertice) +
                ' � ������� ' + IntToStr(EndVertice) + ':'#13#10;

              // ��������� 1-�� �������� ����
              sPath := sPath + IntToStr(Pop(Path));
            end
            else

              // ��������������� ��������� � ��������������� ����
              sPath := '������� ' + IntToStr(EndVertice) +
                ' �� ��������� �� ������� ' + IntToStr(StartVertice) + '.';

            // ������ ���� � ������
            while not isEmpty(Path) do
              sPath := sPath + '->' + IntToStr(Pop(Path));

            // ����� ����
            MessageBox(Handle, PChar(sPath), PChar('���������� ������'), MB_OK);

            // ��������� ��������� � �������� �������
            StartVertice := 0;
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
  fVertices: File of TVertice;
  fArcs: File of TItem;
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
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
      New(Vertice);
      Read(fVertices, Vertice^);
      G.Head := Vertice;
    end
    else
    begin

      // ������ �� �������� �������
      New(Vertice.Next);
      Vertice := Vertice.Next;
      Read(fVertices, Vertice^);
    end;

    if Vertice.Deg <> 0 then
    begin
      for j := 1 to Vertice.Deg do
      begin
        if j = 1 then
        begin
          New(AdjVertice);
          Read(fArcs, AdjVertice^);
          Vertice.Head := AdjVertice;
        end
        else
        begin
          New(AdjVertice.Next);
          AdjVertice := AdjVertice.Next;
          Read(fArcs, AdjVertice^);
        end;

      end;
    end;

    Inc(i);
  end;

  G.Order := i;
  RedrawGraph(G);
end;

procedure TForm1.SaveGraph(Sender: TObject);
var
  fVertices: File of TVertice;
  fArcs: File of TItem;
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin
  System.Assign(fVertices, 'Graph.ver');
  System.Assign(fArcs, 'Graph.arc');

  Rewrite(fVertices);
  Rewrite(fArcs);

  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Write(fVertices, Vertice^);
    AdjVertice := Vertice.Head;
    while AdjVertice <> nil do
    begin
      Write(fArcs, AdjVertice^);
      AdjVertice := AdjVertice.Next;
    end;
    Vertice := Vertice.Next;
  end;
end;

procedure TForm1.DijkstraBtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if DijkstraBtn.Down then
    State := stDijkstra
  else
    State := stNone;
end;

procedure TForm1.DeleteNodeBtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if DeleteNodeBtn.Down then
    State := stDeleteVertice
  else
    State := stNone;
end;

procedure TForm1.DeleteLinkBtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if DeleteLinkBtn.Down then
    State := stDeleteArc
  else
    State := stNone;
end;

procedure TForm1.BFSbtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if BFSbtn.Down then
    State := stBFS
  else
    State := stNone;
end;

procedure TForm1.DFSBtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if DFSBtn.Down then
    State := stDFS
  else
    State := stNone;
end;

procedure TForm1.AddLinkBtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if AddLinkBtn.Down then
    State := stAddArc
  else
    State := stNone;
end;

procedure TForm1.AddNodeBtnClick(Sender: TObject);
begin
  StartVertice := 0;
  if AddNodeBtn.Down then
    State := stAddVertice
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
    AddVertice(G, p[i]);
    DrawVertice(i, p[i]);
  end;
  for i := 2 to 5 do
  begin
    AddArc(G, 1, i);
    DrawArc(G, GetCenter(G, 1), GetCenter(G, i));
  end;
  Button1.Visible := false;
end;

end.
