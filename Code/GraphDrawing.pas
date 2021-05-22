unit GraphDrawing;

interface

uses Digraph, System.Types, Math, VCL.Graphics, DynStructures;

procedure Visit(var G: TGraph; var Path: TStack);

procedure MakePassive(var G: TGraph);

procedure RedrawGraph(const Canvas: TCanvas; Width, Height: Integer;
  const G: TGraph);

implementation

type
  ArcLine = Array [1 .. 5] of TPoint;

procedure GetArcPoints(c1, c2: TPoint; R: Integer; out p: ArcLine);
const
  ArrowAngle = (45 / 180) * pi;
var
  XStart, YStart: Integer;
  XEnd, YEnd: Integer;
  d: Integer;
  LineAngle: Real;
  Sign: Integer;
begin
  d := Distance(c1, c2);
  XEnd := Round(c2.x + R * (c1.x - c2.x) / d);
  YEnd := Round(c2.y + R * (c1.y - c2.y) / d);
  XStart := Round(c1.x + R * (c2.x - c1.x) / d);
  YStart := Round(c1.y + R * (c2.y - c1.y) / d);

  p[1].x := XStart;
  p[1].y := YStart;
  p[2].x := XEnd;
  p[2].y := YEnd;
  p[4] := p[2];

  d := Distance(p[1], p[2]) + 1;
  LineAngle := ArcSin((YStart - YEnd) / d);
  Sign := 2 * Ord(XStart >= XEnd) - 1;

  p[3].x := XEnd + Sign * trunc(cos(ArrowAngle - Sign * LineAngle) * (R div 2));
  p[3].y := YEnd - Sign * trunc(sin(ArrowAngle - Sign * LineAngle) * (R div 2));
  p[5].x := XEnd + Sign * trunc(cos(ArrowAngle + Sign * LineAngle) * (R div 2));
  p[5].y := YEnd + Sign * trunc(sin(ArrowAngle + Sign * LineAngle) * (R div 2));
end;

procedure DrawVertice(const Canvas: TCanvas; R: Integer;
  const Vertice: TPVertice);
var
  SNumber: String;
  XMid, YMid: Integer;
begin
  with Canvas, Vertice^, Vertice.Center do
  begin
    case Design of
      dgPassive:
        begin
          Pen.Color := clBlack;
          Font.Color := clBlack;
          Brush.Color := clWhite;
        end;
      dgActive:
        begin
          Pen.Color := clRed;
          Font.Color := clBlack;
          Brush.Color := clCream;
        end;
      dgVisited:
        begin
          Pen.Color := clTeal;
          Font.Color := clWhite;
          Brush.Color := clLime;
        end;
    end;

    Str(Vertice.Number, SNumber);
    XMid := x - TextWidth(SNumber) div 2;
    YMid := y - TextHeight(SNumber) div 2;

    Ellipse(x - R, y - R, x + R, y + R);
    TextOut(XMid, YMid, SNumber);
  end;
end;

procedure DrawArc(const Canvas: TCanvas; R: Integer;
  const SrcCenter, DstCenter: TPoint; const Neighbour: TPNeighbour);
var
  Points: ArcLine;
  SWeight: String;
  XMid, YMid: Integer;
  HText, WText: Integer;
begin
  with Canvas do
  begin

    // ������������� ������ ��� ���������
    if Neighbour.isVisited then
      Pen.Color := clTeal
    else
      Pen.Color := clBlack;
    GetArcPoints(SrcCenter, DstCenter, R, Points);
    Str(Neighbour.Weight, SWeight);
    WText := TextWidth(SWeight);
    HText := TextHeight(SWeight);
    XMid := (Points[1].x + Points[2].x - WText) div 2;
    YMid := (Points[1].y + Points[2].y - HText) div 2;

    // ��������� ���� � ����
    Polyline(Points);
    Rectangle(XMid, YMid, XMid + WText + 1, YMid + HText + 1);
    TextOut(XMid, YMid, SWeight);
  end;

end;

procedure Visit;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  v, u: Integer;
begin
  while Path <> nil do
  begin
    v := Pop(Path);
    GetByNumber(G, v, Vertice);
    Vertice.Design := dgVisited;
    if Path <> nil then
    begin
      u := Pop(Path);

      // ��������� �����
      Neighbour := Vertice.Head;
      while u <> Neighbour.Number do
        Neighbour := Neighbour.Next;
      Neighbour.isVisited := true;

      Push(Path, u);
    end;
  end;
  G.isPainted := true;
end;

procedure MakePassive;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
begin
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Vertice.Design := dgPassive;
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      Neighbour.isVisited := false;
      Neighbour := Neighbour.Next;
    end;

    Vertice := Vertice.Next;
  end;
  G.isPainted := false;
end;

procedure RedrawGraph;
var
  Vertice, AdjVertice, Active: TPVertice;
  Neighbour: TPNeighbour;
begin
  with Canvas do
  begin
    Pen.Color := clWhite;
    Rectangle(0, 0, Width, Height);
    Pen.Color := clBlack;
    Pen.Width := 3;
    Font.Size := 15;
    Font.Style := [fsBold];
  end;

  // ���������� ���
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      GetByNumber(G, Neighbour.Number, AdjVertice);
      DrawArc(Canvas, G.R, Vertice.Center, AdjVertice.Center, Neighbour);
      Neighbour := Neighbour.Next;
    end;
    Vertice := Vertice.Next;
  end;

  // ���������� ������
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    DrawVertice(Canvas, G.R, Vertice);
    if Vertice.Design = dgActive then
      Active := Vertice;
    Vertice := Vertice.Next;
  end;
  if Active <> nil then
    DrawVertice(Canvas, G.R, Active);

end;

end.
