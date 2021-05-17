unit GraphDrawing;

interface

uses Digraph, System.Types, Math, VCL.ExtCtrls, VCL.Graphics;

procedure RedrawGraph(const Img: TImage; R: Integer; const G: TGraph;
  wasPainted: Boolean = false);

implementation

{ Процедура вычисления координат концов ребра на холсте }
procedure GetArcPoints(c1, c2: TPoint; R: Integer; out p: Array of TPoint);
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

procedure DrawVertice(const Img: TImage; R: Integer; const Vertice: TPVertice);
var
  Caption: String;
  PosX: Integer; // Левый верхний край текста
  Copy: Integer; // Копия номера вершины
begin

  // Получение имени вершины и его x-координаты
  Str(Vertice.Number, Caption);
  Copy := Vertice.Number;
  PosX := Vertice.Center.x;
  while Copy <> 0 do
  begin
    Copy := Copy div 10;
    PosX := PosX - 5;
  end;

  with Img.Canvas do
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
      dgEndPoint:
        begin
          Pen.Color := clRed;
          Brush.Color := clGreen;
        end;
    end;

    // Вывод круга
    with Vertice.Center do
      Ellipse(x - R, y - R, x + R, y + R);

    // Вывод имени вершины
    TextOut(PosX - 2, Vertice.Center.y - 10, Caption);

    // Возврат значений пера и заливки
    Pen.Color := clBlack;
    Brush.Color := clWhite;
  end;

end;

procedure DrawArc(const Img: TImage; R: Integer; const Src, Dest: TPVertice);
var
  d: Integer;
  Points: Array [0 .. 6] of TPoint;
begin
  d := Distance(Src.Center, Dest.Center);
  if d > R then
  begin
    GetArcPoints(Src.Center, Dest.Center, R, Points);
    Img.Canvas.Polyline(Points);
  end;
end;

procedure RedrawGraph(const Img: TImage; R: Integer; const G: TGraph;
  wasPainted: Boolean = false);
var
  Vertice, AdjVertice: TPVertice;
  Arc: TPAdjVertice;
begin
  with Img, Img.Canvas do
  begin
    Pen.Color := clWhite;
    Rectangle(0, 0, Width, Height);
    Pen.Color := clBlack;
  end;

  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Arc := Vertice.Head;
    if wasPainted then
      Vertice.Design := dgPassive;
    while Arc <> nil do
    begin
      GetByNumber(G, Arc.Number, AdjVertice);
      if wasPainted then
        AdjVertice.Design := dgPassive;
      DrawArc(Img, R, Vertice, AdjVertice);
      Arc := Arc.Next;
    end;
    DrawVertice(Img, R, Vertice);
    Vertice := Vertice.Next;
  end;

end;

end.
