unit GraphDrawing;

interface

uses Digraph, System.Types, Math, VCL.ExtCtrls, VCL.Graphics;

procedure RedrawGraph(const Img: TCanvas; Width, Height: Integer;
  const G: TGraph);

implementation

{ ��������� ���������� ��������� ������ ����� �� ������ }
procedure GetArcPoints(c1, c2: TPoint; R: Integer; out p: Array of TPoint);
const
  ArrAngle = (45 / 180) * pi;
var
  StartX, StartY: Integer;
  EndX, EndY: Integer;
  d: Integer;
  deltaX, deltaY: Integer;
  LineAngle: Real;
  Sign: Integer;
begin
  d := Distance(c1, c2);
  EndX := Round(c2.x + R * (c1.x - c2.x) / d);
  EndY := Round(c2.y + R * (c1.y - c2.y) / d);

  StartX := Round(c1.x + R * (c2.x - c1.x) / d);
  StartY := Round(c1.y + R * (c2.y - c1.y) / d);

  p[0].x := StartX;
  p[0].y := StartY;

  p[1].x := EndX;
  p[1].y := EndY;

  p[3] := p[1];

  LineAngle := ArcSin((StartY - EndY) / (Distance(p[0], p[1]) + 1));

  if (StartX - EndX) <> 0 then
    Sign := Round((StartX - EndX) / abs(StartX - EndX))
  else
    Sign := 1;

  p[2].x := EndX + Sign * trunc(cos(ArrAngle - Sign * LineAngle) * R);
  p[2].y := EndY - Sign * trunc(sin(ArrAngle - Sign * LineAngle) * R);

  p[4].x := EndX + Sign * trunc(cos(ArrAngle + Sign * LineAngle) * R);
  p[4].y := EndY + Sign * trunc(sin(ArrAngle + Sign * LineAngle) * R);
end;

procedure DrawVertice(const Img: TCanvas; R: Integer; const Vertice: TPVertice);
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
    PosX := PosX - 5;
  end;

  with Img do
  begin
    case Vertice.Design of
      dgPassive:
        begin
          Pen.Color := clBlack;
          Brush.Color := clWhite;
        end;
      dgActive:
        begin
          Pen.Color := clRed;
          Brush.Color := clCream;
        end;
      dgVisited:
        begin
          Pen.Color := clTeal;
          Brush.Color := clLime;
        end;
    end;

    // ����� �����
    with Vertice.Center do
      Ellipse(x - R, y - R, x + R, y + R);

    // ����� ����� �������
    TextOut(PosX - 2, Vertice.Center.y - 10, Caption);

    // ������� �������� ���� � �������
    Pen.Color := clBlack;
    Brush.Color := clWhite;
  end;

end;

procedure DrawArc(const Img: TCanvas; R: Integer; const Src, Dest: TPVertice);
var
  d: Integer;
  Points: Array [0 .. 4] of TPoint;
begin
  d := Distance(Src.Center, Dest.Center);
  if d > R then
  begin
    GetArcPoints(Src.Center, Dest.Center, R, Points);
    Img.Polyline(Points);
  end;
end;

procedure RedrawGraph(const Img: TCanvas; Width, Height: Integer;
  const G: TGraph);
var
  Vertice, AdjVertice, Active: TPVertice;
  Arc: TPAdjVertice;
begin
  with Img do
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
    Arc := Vertice.Head;
    while Arc <> nil do
    begin
      GetByNumber(G, Arc.Number, AdjVertice);
      DrawArc(Img, G.R div 2, Vertice, AdjVertice);
      Arc := Arc.Next;
    end;
    Vertice := Vertice.Next;
  end;

  // ���������� ������
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    DrawVertice(Img, G.R, Vertice);
    if Vertice.Design = dgVisited then
      Vertice.Design := dgPassive
    else if Vertice.Design = dgActive then
      Active := Vertice;
    Vertice := Vertice.Next;
  end;
  DrawVertice(Img, G.R, Active);

end;

end.
