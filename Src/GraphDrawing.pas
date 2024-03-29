unit GraphDrawing;
{
  ������ � ��������������,
  ������������ ��� ������������
  �����.
}

interface

uses System.Types, VCL.Graphics, Math, Digraph, DynamicStructures;

// ������������ ��������� ����� ������ � ��� ����
procedure MakeVisited(var Graph: TGraph; var Path: TStack);

// ������������ ��������� ����� ������ � ��� �����
procedure MakePassive(var Graph: TGraph);

// ������������ ��������� ��������� �� ������� ����������� ��������������
procedure MakeRegPolygon(var Graph: TGraph; Width, Height: Integer);

// ������������ ����������� ����� �� ������
procedure RedrawGraph(const Canvas: TCanvas; Width, Height: Integer;
  const Graph: TGraph);

implementation

type

  // ��� ������� �� ������, ��������������� ����
  ArcLine = Array [1 .. 5] of TPoint;

  // ������������ ��������� ������� ��� ����
function GetArcPoints(c1, c2: TPoint; R: Integer): ArcLine;
const
  ArrowAngle = pi / 4;
  // ArrowAngle - ���� ������� ������ �������

var
  XStart, YStart: Integer;
  XEnd, YEnd: Integer;
  d: Integer;
  LineAngle: Real;
  Sign: Integer;
  // XStart, YStart - ���������� ������ �������
  // XEnd, YEnd - ���������� ������ �������
  // d - ���������� ��� ���������� ����������
  // LineAngle - ���� ������� ������� �����
  // Sign - ���� �������� ������� ������ � ������ �������

begin

  // ���������� ������ ������� �����
  d := Trunc(c1.Distance(c2));
  XEnd := Round(c2.x + R * (c1.x - c2.x) / d);
  YEnd := Round(c2.y + R * (c1.y - c2.y) / d);
  XStart := Round(c1.x + R * (c2.x - c1.x) / d);
  YStart := Round(c1.y + R * (c2.y - c1.y) / d);

  // ������������� ����� ������� �����
  Result[1].x := XStart;
  Result[1].y := YStart;
  Result[2].x := XEnd;
  Result[2].y := YEnd;
  Result[4] := Result[2];

  // ���������� ������ ��� ������ �������
  d := Trunc(Result[1].Distance(Result[2]));
  if d <> 0 then
    LineAngle := ArcSin((YStart - YEnd) / d)
  else
    LineAngle := 0;
  Sign := 2 * Ord(XStart >= XEnd) - 1;
  d := R div 2;

  // ���������� ��������� �������
  Result[3].x := XEnd + Sign * Trunc(cos(ArrowAngle - Sign * LineAngle) * d);
  Result[3].y := YEnd - Sign * Trunc(sin(ArrowAngle - Sign * LineAngle) * d);
  Result[5].x := XEnd + Sign * Trunc(cos(ArrowAngle + Sign * LineAngle) * d);
  Result[5].y := YEnd + Sign * Trunc(sin(ArrowAngle + Sign * LineAngle) * d);
end;

// ������������ ��������� �������
procedure DrawVertice(const Canvas: TCanvas; R: Integer;
  const Vertice: TPVertice);
var
  SNumber: String;
  XMid, YMid: Integer;
  // SNumber - ������ � ������� �������
  // XMid, YMid - ���������� SNumber

begin
  with Canvas, Vertice^, Vertice.Center do
  begin

    // ������������� ������ ��� ���������
    case Style of
      stPassive:
        begin
          Pen.Color := clBlack;
          Font.Color := clBlack;
          Brush.Color := clWhite;
        end;
      stActive:
        begin
          Pen.Color := clRed;
          Font.Color := clBlack;
          Brush.Color := clCream;
        end;
      stVisited:
        begin
          Pen.Color := clTeal;
          Font.Color := clWhite;
          Brush.Color := clLime;
        end;
    end;

    // ��������� ������� � � �������
    Str(Vertice.Number, SNumber);
    XMid := x - TextWidth(SNumber) div 2;
    YMid := y - TextHeight(SNumber) div 2;
    Ellipse(x - R, y - R, x + R, y + R);
    TextOut(XMid, YMid, SNumber);
  end;
end;

// ������������ ��������� ����
procedure DrawArc(const Canvas: TCanvas; R: Integer;
  const SrcCenter, DstCenter: TPoint; const Neighbour: TPNeighbour);
var
  Points: ArcLine;
  SWeight: String;
  XMid, YMid: Integer;
  HText, WText: Integer;
  // Points - �������, �����. ����
  // Sweight - ������ � �����
  // XMid, YMid - ���������� ������ ����
  // HText, WText - ������� ������ � �����

begin
  with Canvas do
  begin

    // ������������� ������ ��� ���������
    if Neighbour.isVisited then
    begin
      Pen.Color := clTeal;
      Font.Color := clWhite;
      Brush.Color := clBlack;
    end
    else
    begin
      Pen.Color := clBlack;
      Font.Color := clBlack;
      Brush.Color := clWhite;
    end;
    Points := GetArcPoints(SrcCenter, DstCenter, R);

    // ��������� ���� � ����
    Polyline(Points);
    if Neighbour.Weight <> 1 then
    begin
      Str(Neighbour.Weight, SWeight);
      WText := TextWidth(SWeight);
      HText := TextHeight(SWeight);
      XMid := (Points[1].x + Points[2].x - WText) div 2;
      YMid := (Points[1].y + Points[2].y - HText) div 2;
      Rectangle(XMid, YMid, XMid + WText + 1, YMid + HText + 1);
      TextOut(XMid, YMid, SWeight);
    end;
  end;

end;

procedure MakeVisited(var Graph: TGraph; var Path: TStack);
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  v: Integer;
  // Vertice - ������ �� ������� �������
  // Neighbour - ������ �� �������� ������
  // v - ����� �������, ����������� �� ����

begin

  // ���� �1. ������ �� ���� �������� ����
  while Path <> nil do
  begin

    // ��������� ����� �������
    v := Pop(Path);
    Vertice := GetByNumber(Graph, v);
    Vertice.Style := stVisited;

    // ��������� ����� ��������� ����
    if Path <> nil then
    begin
      v := Pop(Path);
      Neighbour := Vertice.Head;

      // ���� �2. ����� ������
      while v <> Neighbour.Number do
        Neighbour := Neighbour.Next;
      Neighbour.isVisited := true;
      Push(Path, v);
    end; // ����� if
  end; // ����� �1

  // ����� � ��������� �����
  Graph.isPainted := true;
end;

procedure MakePassive(var Graph: TGraph);
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  // Vertice - ������ �� ������� �������
  // Neighbour - ������ �� �������� ������

begin

  // ���� �1. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin
    Vertice.Style := stPassive;

    // ���� �2. ������ �� �������
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      Neighbour.isVisited := false;
      Neighbour := Neighbour.Next;
    end; // ����� �2
    Vertice := Vertice.Next;
  end;

  // ��������� ����� � ��������� �����
  Graph.isPainted := false;
end;

procedure MakeRegPolygon(var Graph: TGraph; Width, Height: Integer);
var
  Vertice: TPVertice;
  ImageCenter: TPoint;
  PolygonRadius: Integer;
  Angle: Real;
  // Vertice - ������ �� ������� �������
  // ImageCenter - ����� �����������
  // PolygonRadius - ������ ����������� ��������������
  // Angle - ������� ���� ������� ������-������� �������

begin

  // ������������� ����, ������� � ������ ��������� ����������
  Angle := 0;
  PolygonRadius := Min(Width, Height) div 2 - Graph.R;
  ImageCenter.x := Width div 2;
  ImageCenter.y := Height div 2;

  // ���� �1. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin
    // ���������� ���������
    Vertice.Center.x := ImageCenter.x + Trunc(PolygonRadius * sin(Angle));
    Vertice.Center.y := ImageCenter.y - Trunc(PolygonRadius * cos(Angle));

    // ������� � ��������� �������
    Vertice := Vertice.Next;
    Angle := Angle + 2 * pi / Graph.Order;
  end; // ����� �1
end;

procedure RedrawGraph(const Canvas: TCanvas; Width, Height: Integer;
  const Graph: TGraph);
var
  Vertice, AdjVertice, Active: TPVertice;
  Neighbour: TPNeighbour;
  // Vertice - ������� �������
  // AdjVertice - ������� Vertice �������
  // Active - ������� �� ������ stActive
  // Neighbour - ������� �����

begin

  // ��������� ������ � �������
  with Canvas do
  begin
    Pen.Color := clWhite;
    Rectangle(0, 0, Width, Height);
    Pen.Width := 3;
    Font.Size := 15;
    Font.Style := [fsBold];
  end;

  // ���� �1. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin

    // ���� �2. ������ �� �����
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      AdjVertice := GetByNumber(Graph, Neighbour.Number);

      // ���������� ����
      DrawArc(Canvas, Graph.R, Vertice.Center, AdjVertice.Center, Neighbour);

      Neighbour := Neighbour.Next;
    end;
    Vertice := Vertice.Next;
  end;

  // ���� �3. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin

    // ���������� �������
    DrawVertice(Canvas, Graph.R, Vertice);

    // ���������� �������� �������
    if Vertice.Style = stActive then
      Active := Vertice;
    Vertice := Vertice.Next;
  end;

  // ���������� �������� �������
  if Active <> nil then
    DrawVertice(Canvas, Graph.R, Active);

end;

end.
