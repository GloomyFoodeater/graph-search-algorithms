unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils;

const
  INFINITY = 1000000;

type

  TDesign = (dgPassive, dgActive, dgVisited);

  // ��� ������ ���������

  TPAdjVertice = TPItem;
  // TODO: �������� ������� ������� ��������� �����
  { TPAdjVertice = ^TAdjVertice;

    TAdjVertice = record
    Number: Integer;
    Next: TPAdjVertice;
    end; }

  // ��� ������� �����
  TPVertice = ^TVertice;

  TVertice = record
    Center: TPoint;
    Number: Integer;
    Head: TPAdjVertice;
    Next: TPVertice;
    Deg: Integer;
    Design: TDesign;
  end;

  // ��� ��������������� ����
  TGraph = record
    Head: TPVertice;
    Order: Integer;
  end;

  // ��� ������� �����
  TWeights = array of array of Integer;

  { ��������� ��������� ������� �� ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TPVertice);

{ ��������� ���������� ������� � � ���������� �� ����� �� ������ }
procedure Centralize(const G: TGraph; var P: TPoint; R: Integer;
  out Vertice: TPVertice);

{ ������� ��������� ������ ������� }
function GetCenter(const G: TGraph; v: Integer): TPoint;

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;

{ ��������� ���������� ������� � ���� }
procedure AddVertice(var G: TGraph; const C: TPoint);

{ ��������� ���������� ���� � ���� }
procedure AddArc(var G: TGraph; v, u: Integer);

{ ��������� �������� ������� �� ����� }
procedure DeleteVertice(var G: TGraph; v: Integer);

{ ��������� �������� ���� �� ����� }
procedure DeleteArc(var G: TGraph; v, u: Integer);

{ ��������� ������������� ����� }
procedure InitializeGraph(var G: TGraph);

{ ��������� �������� ����� }
procedure DestroyGraph(var G: TGraph);

{ ��������� �������������� ����� � ������� ����� }
procedure ToWeightMatrix(const G: TGraph; out Matrix: TWeights);

implementation

function Distance(const p1, p2: TPoint): Integer;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

{ ������� ���������� ������� �� ������ � ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TPVertice);
begin
  Vertice := G.Head;

  // ���� �1. ����� ������� � ������ �������
  while (Vertice <> nil) and (Vertice.Number <> v) do
  begin
    Vertice := Vertice.Next;
  end; // ����� �1

end;

procedure Centralize(const G: TGraph; var P: TPoint; R: Integer;
  out Vertice: TPVertice);
var
  isFound: Boolean;
begin
  Vertice := G.Head;
  isFound := Distance(Vertice.Center, P) <= R;

  // ���� �1. ����� ��������� ������� � �������� ������������
  while not isFound and (Vertice <> nil) do
  begin
    Vertice := Vertice.Next;
    isFound := Distance(Vertice.Center, P) <= R;
  end; // ����� �1

end;

function GetCenter(const G: TGraph; v: Integer): TPoint;
var
  Vertice: TPVertice;
begin
  GetByNumber(G, v, Vertice);
  if Vertice <> nil then
    Result := Vertice.Center;
end;

procedure AddVertice(var G: TGraph; const C: TPoint);
var
  Vertice: TPVertice;
begin
  Inc(G.Order);

  // ������������� ����� �������
  New(Vertice);
  with Vertice^ do
  begin
    Center := C;
    Number := G.Order;
    Head := nil;
    Next := G.Head;
    Deg := 0;
    Design := dgPassive;
  end;

  // ������ ����� �������
  G.Head := Vertice;

end;

procedure AddArc(var G: TGraph; v, u: Integer);
var
  Vertice: TPVertice;
  PrevArc, Arc: TPAdjVertice;
  isFound: Boolean;
begin

  // ��������� �������
  GetByNumber(G, v, Vertice);
  Inc(Vertice.Deg);

  // ���������� ������ � ������ ���������
  Push(Vertice.Head, u);

end;

procedure DeleteVertice(var G: TGraph; v: Integer);
var
  PrevVertice, Vertice: TPVertice;
  PrevArc, Arc: TPAdjVertice;
begin
  Dec(G.Order);
  if v = G.Head.Number then
  begin
    Vertice := G.Head;
    G.Head := G.Head.Next;
  end
  else
  begin
    GetByNumber(G, v + 1, PrevVertice);
    Vertice := PrevVertice.Next;
    PrevVertice.Next := Vertice.Next;
  end;

  DestroyList(Vertice.Head);
  Dispose(Vertice);

  Vertice := G.Head;
  while Vertice <> nil do
  begin
    if Vertice.Number > v then
      Dec(Vertice.Number);

    PrevArc := nil;
    Arc := Vertice.Head;
    while Arc <> nil do
    begin
      if Arc.Number = v then
      begin
        if PrevArc = nil then
          Vertice.Head := Arc.Next
        else
          PrevArc.Next := Arc.Next;
        Dispose(Arc);
      end
      else if Arc.Number > v then
        Dec(Arc.Number);

      PrevArc := Arc;
      Arc := Arc.Next;
    end;
    Vertice := Vertice.Next;
  end;
end;

procedure DeleteArc(var G: TGraph; v, u: Integer);
var
  Vertice: TPVertice;
  Arc, PrevArc: TPAdjVertice;
  isFound: Boolean;
begin

  // ��������� ������ ����
  GetByNumber(G, v, Vertice);

  Dec(Vertice.Deg);

  // ��������� ������� ������
  PrevArc := Vertice.Head;

  // ����� ����� ����� ������ � ������� �������
  if (PrevArc = nil) or (PrevArc.Number = u) then
  begin
    if PrevArc <> nil then
      Vertice.Head := PrevArc.Next
    else
      Vertice.Head := nil;
  end
  else
  begin

    isFound := (PrevArc.Next.Number = u) or (PrevArc = nil);

    // ��������� ����������� ������ ����������
    while not isFound do
    begin
      PrevArc := PrevArc.Next;
      isFound := (PrevArc = nil) or (PrevArc.Next.Number = u);
    end;

    Arc := PrevArc.Next;
    PrevArc.Next := Arc.Next;
  end;

  // �������� ������
  if not(Arc = nil) then
  begin
    Dispose(Arc);
  end;

end;

procedure InitializeGraph(var G: TGraph);
begin
  G.Head := nil;
  G.Order := 0;
end;

procedure DestroyGraph(var G: TGraph);
var
  Vertice: TPVertice;
begin

  // ���� �1. ������������ ������ ������
  while G.Head <> nil do
  begin
    Vertice := G.Head;

    // ���� �2. ������������ ������ ������� �������
    DestroyList(Vertice.Head);

    G.Head := G.Head.Next;
    Dispose(Vertice);
  end; // ����� �1
end;

procedure ToWeightMatrix(const G: TGraph; out Matrix: TWeights);
var
  v, u: Integer;
  Vertice: TPVertice;
  Arc: TPAdjVertice;
begin

  // ������������� �������
  SetLength(Matrix, G.Order, G.Order);

  for v := 1 to G.Order do
  begin
    for u := 1 to G.Order do
      Matrix[v - 1, u - 1] := INFINITY;
  end;

  // ���� �2. ������ �� ��������
  Vertice := G.Head;
  while Vertice <> nil do
  begin

    // ���� B2. ���������� ����� ������������ ����
    Arc := Vertice.Head;
    while Arc <> nil do
    begin
      Matrix[Vertice.Number - 1, Arc.Number - 1] := 1;
      Arc := Arc.Next;
    end; // ����� B2

    // ������� � ��������� �������
    Vertice := Vertice.Next;
  end; // ����� �1
end;

end.
