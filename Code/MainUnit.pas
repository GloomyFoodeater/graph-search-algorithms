unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, GraphSearch, Digraph, Math,
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
  TClickState = (stAddVertice, stAddArc, stDeleteVertice, stDeleteArc, stDFS,
    stBFS, stDijkstra, stNone);

var
  Form1: TForm1;
  State: TClickState;
  G: TGraph;
  StartVertice: TPVertice = nil;
  StartVerticeCenter: TPoint;
  isToRedraw: Boolean = True;

const
  R = 40;

implementation

{$R *.dfm}

{ ��������� ���������� ��������� ������ ����� �� ������ }
procedure GetArcPoints(c1, c2: TPoint; var p: Array of TPoint);
const
  dAngle = (45 / 180) * pi;
var
  StartX, StartY: Integer;
  EndX, EndY: Integer;
  MiddleX, MiddleY: Integer;
  d: Integer;
  Angle: Real;
  Sign: Integer;
begin
  d := Distance(c1, c2);
  StartX := Round(c2.x + R * (c1.x - c2.x) / d);
  StartY := Round(c2.y + R * (c1.y - c2.y) / d);

  EndX := Round(c1.x + R * (c2.x - c1.x) / d);
  EndY := Round(c1.y + R * (c2.y - c1.y) / d);

  MiddleX := StartX + ((EndX - StartX) div 2);
  MiddleY := StartY + ((EndY - StartY) div 2);

  p[0].x := StartX;
  p[0].y := StartY;

  p[1].x := MiddleX;
  p[1].y := MiddleY;

  p[3] := p[1];
  p[5] := p[1];

  p[6].x := EndX;
  p[6].y := EndY;

  Angle := ArcSin((StartY - EndY) / (Distance(p[0], p[6])));

  if (StartX - EndX) <> 0 then
    Sign := Round((StartX - EndX) / abs(StartX - EndX))
  else
    Sign := 1;

  p[2].x := MiddleX - Sign * trunc(cos(dAngle - Sign * Angle) * (R div 2));
  p[2].y := MiddleY + Sign * trunc(sin(dAngle - Sign * Angle) * (R div 2));

  p[4].x := MiddleX - Sign * trunc(cos(dAngle + Sign * Angle) * (R div 2));
  p[4].y := MiddleY - Sign * trunc(sin(dAngle + Sign * Angle) * (R div 2));

end;

{ ��������� ��������� ������� ����� }
procedure DrawVertice(const Vertice: TPVertice);
var
  Caption: String;
  PosX: Integer; // ����� ������� ���� ������
  Copy: Integer; // ����� ������ �������
begin

  // ��������� ����� ������� � ��� x-����������
  Str(Vertice.Number, Caption);
  Copy := Vertice.Number;
  PosX := Vertice.Center.x;
  while Copy <> 0 do
  begin
    Copy := Copy div 10;
    PosX := PosX - 4;
  end;

  case Vertice.Design of
    dgPassive:
      begin
        Form1.Canvas.Pen.Color := clBlack;
        Form1.Canvas.Brush.Color := clWhite;
      end;
    dgActive:
      begin
        Form1.Canvas.Pen.Color := clRed;
        Form1.Canvas.Brush.Color := clCream;
      end;
    dgVisited:
      begin
        Form1.Canvas.Pen.Color := clTeal;
        Form1.Canvas.Brush.Color := clLime;
      end;
  end;

  // ����� �����
  with Vertice.Center do
    Form1.Canvas.Ellipse(x - R, y - R, x + R, y + R);

  // ����� ����� �������
  Form1.Canvas.TextOut(PosX + 1, Vertice.Center.y - 6, Caption);

  Form1.Canvas.Pen.Color := clBlack;
  Form1.Canvas.Brush.Color := clWhite;
end;

{ ��������� ��������� ����� ����� }
procedure DrawArc(const Src, Dest: TPVertice);
var
  d: Integer;
  Points: Array [0 .. 6] of TPoint;
begin
  d := Distance(Src.Center, Dest.Center);
  if d > R then
  begin
    GetArcPoints(Src.Center, Dest.Center, Points);
    if (Src.Design = dgVisited) and (Dest.Design = dgVisited) then
      Form1.Canvas.Pen.Color := clTeal;

    Form1.Canvas.Polyline(Points);
    DrawVertice(Src);
    DrawVertice(Dest);
  end;
end;

procedure RedrawGraph(const G: TGraph);
var
  Vertice, AdjVertice: TPVertice;
  Arc: TPAdjVertice;
begin
  Form1.Canvas.Pen.Color := clWhite;
  Form1.Canvas.Rectangle(0, 0, Form1.Width, Form1.Height);
  Form1.Canvas.Pen.Color := clBlack;

  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Arc := Vertice.Head;
    while Arc <> nil do
    begin
      GetByNumber(G, Arc.Number, AdjVertice);
      DrawArc(Vertice, AdjVertice);
      Arc := Arc.Next;
    end;
    Vertice := Vertice.Next;
  end;

end;

// ������� ������� �� �����
procedure TForm1.FormClick(Sender: TObject);
var
  Pos: TPoint;
  EndVertice: TPVertice;
  d: Integer;
  Path: TStack;
  sPath: String;
  AdjMatrix: TWeights;
  Vertice, AdjVertice: TPVertice;
  v: Integer;
begin
  // ��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);
  case State of
    stAddVertice:
      // ���������� ������� �����
      begin
        AddVertice(G, Pos);
        GetByNumber(G, G.Order, Vertice);
        DrawVertice(Vertice);
      end;
    stAddArc:
      begin
        if StartVertice = nil then
        begin
          Centralize(G, Pos, R, StartVertice);
          StartVerticeCenter := Pos;
        end
        else
        begin
          Centralize(G, Pos, R, EndVertice);
          if (EndVertice <> nil) and (StartVertice <> EndVertice) then
          begin
            AddArc(G, StartVertice.Number, EndVertice.Number);
            DrawArc(StartVertice, EndVertice);
            StartVertice := nil;
          end;
        end;
      end;
    stDeleteVertice:
      begin
        Centralize(G, Pos, R, StartVertice);
        if StartVertice <> nil then
        begin
          if (StartVertice.Number >= 1) and (StartVertice.Number <= G.Order)
          then
            DeleteVertice(G, StartVertice.Number);
          RedrawGraph(G);
        end;
      end;
    stDeleteArc:
      begin
        if StartVertice = nil then
        begin
          Centralize(G, Pos, R, StartVertice);
        end
        else
        begin
          Centralize(G, Pos, R, EndVertice);
          if (EndVertice <> nil) and (StartVertice <> EndVertice) then
          begin
            DeleteArc(G, StartVertice.Number, EndVertice.Number);
            RedrawGraph(G);
            StartVertice := nil;
          end;
        end;
      end;
    stDFS, stBFS, stDijkstra:
      begin
        if StartVertice = nil then
        begin
          Centralize(G, Pos, R, StartVertice);
          StartVerticeCenter := Pos;
        end
        else
        begin
          Centralize(G, Pos, R, EndVertice);
          if (EndVertice <> nil) then
          begin

            ToWeightMatrix(G, AdjMatrix);
            // ��������� ���� � ������� ���������
            case State of
              stDFS:
                DFS(AdjMatrix, StartVertice.Number, EndVertice.Number, Path);
              // ����� � �������
              stBFS:
                BFS(AdjMatrix, StartVertice.Number, EndVertice.Number, Path);
              // ����� � ������
              stDijkstra:
                Dijkstra(AdjMatrix, StartVertice.Number,
                  EndVertice.Number, Path);
            end;

            // ��������������� ��������� � ��������������� ����
            if isEmpty(Path) then
            begin

              sPath := '������� ' + IntToStr(EndVertice.Number) +
                ' �� ��������� �� ������� ' +
                IntToStr(StartVertice.Number) + '.';
              MessageBox(Handle, PChar(sPath),
                PChar('���������� ������'), MB_OK);
            end;

            // ������ ���� � ������
            while not isEmpty(Path) do
            begin
              v := Pop(Path);
              GetByNumber(G, v, Vertice);
              Vertice.Design := dgVisited;
              RedrawGraph(G);
            end;

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
  Vertice: TPVertice;
begin
  InitializeGraph(G);
  for i := 1 to 5 do
  begin
    AddVertice(G, p[i]);
    GetByNumber(G, i, Vertice);
    DrawVertice(Vertice);
  end;
  for i := 2 to 5 do
  begin
    AddArc(G, 1, i);
    GetByNumber(G, i, Vertice);
    DrawArc(Vertice, Vertice);
  end;
  Button1.Visible := false;
end;

end.
