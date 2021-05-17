unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils;

const
  INFINITY = 1000000;

type

  // ��� ������������ ����� ������
  TDesign = (dgPassive, dgActive, dgVisited, dgEndPoint);

  // ��� ������ ���������
  TPAdjVertice = TPItem;

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
    Tail: TPVertice;
    Order: Integer;
  end;

  // ��� ������� �����
  TWeights = array of array of Integer;

  { ��������� ��������� ������� �� ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TPVertice);

{ ������� �������� ������ �� ��������� }
function AreAdjacent(const G: TGraph; v, u: Integer): Boolean;

{ ��������� ���������� ������� �� ����� �� ������ }
procedure Centralize(const G: TGraph; const P: TPoint; R: Integer;
  out Vertice: TPVertice);

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

{ ������� ���������� ���������� ����� ������� �� �������� }
function Distance(const p1, p2: TPoint): Integer;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TPVertice);
begin
  Vertice := G.Head;
  while (Vertice <> nil) and (Vertice.Number <> v) do
    Vertice := Vertice.Next;
end;

procedure Centralize(const G: TGraph; const P: TPoint; R: Integer;
  out Vertice: TPVertice);
var
  isFound: Boolean;
begin
  Vertice := G.Head;
  isFound := (Vertice = nil) or (Distance(Vertice.Center, P) <= R);

  // ���� �1. ����� ��������� ������� � �������� ������������
  while not isFound and (Vertice.Next <> nil) do
  begin
    Vertice := Vertice.Next;
    isFound := Distance(Vertice.Center, P) <= R;
  end; // ����� �1

  if not isFound then
    Vertice := nil;
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
    Next := nil;
    Deg := 0;
    Design := dgPassive;
  end;

  // ������ ����� �������
  if G.Head = nil then
    G.Head := Vertice
  else
    G.Tail.Next := Vertice;
  G.Tail := Vertice;

end;

procedure AddArc(var G: TGraph; v, u: Integer);
var
  Vertice: TPVertice;
begin
  GetByNumber(G, v, Vertice);
  Inc(Vertice.Deg);

  // ���������� ������ � ������ ���������
  Push(Vertice.Head, u);
end;

procedure DeleteVertice(var G: TGraph; v: Integer);
var
  PrevVertice, Vertice: TPVertice;
  PrevAdjVertice, AdjVertice: TPAdjVertice;
begin
  Dec(G.Order);

  if v = G.Head.Number then
  begin
    // �������� �������� �������
    Vertice := G.Head;
    G.Head := G.Head.Next;
  end
  else
  begin
    // �������� �� �������� �������
    GetByNumber(G, v - 1, PrevVertice);
    Vertice := PrevVertice.Next;
    PrevVertice.Next := Vertice.Next;
  end;

  // ������������ ������
  DestroyList(Vertice.Head);
  Dispose(Vertice);

  // ���� �1. ������ �� �������� �����
  Vertice := G.Head;
  while Vertice <> nil do
  begin

    // ���������� ������� ������
    if Vertice.Number > v then
      Dec(Vertice.Number);

    // ��������� ������ ������
    if Vertice.Next = nil then
      G.Tail := Vertice;

    // ���� �2. ������ �� ������� �������
    PrevAdjVertice := nil;
    AdjVertice := Vertice.Head;
    while AdjVertice <> nil do
    begin

      // �������� ������ ������� �������
      if AdjVertice.Number = v then
      begin
        if PrevAdjVertice = nil then
          Vertice.Head := AdjVertice.Next
        else
          PrevAdjVertice.Next := AdjVertice.Next;
        Dispose(AdjVertice);
      end
      else if AdjVertice.Number > v then
        Dec(AdjVertice.Number); // ���������� ������ ������

      PrevAdjVertice := AdjVertice;
      AdjVertice := AdjVertice.Next;
    end; // ����� �2
    Vertice := Vertice.Next;
  end; // ����� �1
end;

procedure DeleteArc(var G: TGraph; v, u: Integer);
var
  Vertice: TPVertice;
  AdjVertice, PrevAdjVertice: TPAdjVertice;
  isFound: Boolean;
begin

  // ��������� ������ ����
  GetByNumber(G, v, Vertice);

  Dec(Vertice.Deg);

  // ��������� ������� ������
  PrevAdjVertice := Vertice.Head;
  AdjVertice := nil;

  // ����� ����� ����� ������ � ������� �������
  if (PrevAdjVertice = nil) or (PrevAdjVertice.Number = u) then
  begin
    if PrevAdjVertice <> nil then
      Vertice.Head := PrevAdjVertice.Next
    else
      Vertice.Head := nil;
  end
  else
  begin

    isFound := (PrevAdjVertice.Next.Number = u) or (PrevAdjVertice = nil);

    // ��������� ����������� ������ ����������
    while not isFound do
    begin
      PrevAdjVertice := PrevAdjVertice.Next;
      isFound := (PrevAdjVertice = nil) or (PrevAdjVertice.Next.Number = u);
    end;

    AdjVertice := PrevAdjVertice.Next;
    PrevAdjVertice.Next := AdjVertice.Next;
  end;

  // �������� ������
  if AdjVertice <> nil then
  begin
    Dispose(AdjVertice);
  end;

end;

procedure InitializeGraph(var G: TGraph);
begin
  G.Head := nil;
  G.Tail := nil;
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
  AdjVertice: TPAdjVertice;
begin

  // ������������� �������
  SetLength(Matrix, G.Order, G.Order);
  for v := 1 to G.Order do
    for u := 1 to G.Order do
      Matrix[v - 1, u - 1] := INFINITY;

  // ���� �2. ������ �� ��������
  Vertice := G.Head;
  while Vertice <> nil do
  begin

    // ���� A3. ������ �� ������� �������
    AdjVertice := Vertice.Head;
    while AdjVertice <> nil do
    begin
      Matrix[Vertice.Number - 1, AdjVertice.Number - 1] := 1;
      AdjVertice := AdjVertice.Next;
    end; // ����� A3

    Vertice := Vertice.Next;
  end; // ����� A2
end;

function AreAdjacent(const G: TGraph; v, u: Integer): Boolean;
var
  Vertice: TPVertice;
  AdjVertice: TPAdjVertice;
begin
  Result := false;
  GetByNumber(G, v, Vertice);
  AdjVertice := Vertice.Head;
  while not Result and (AdjVertice <> nil) do
  begin
    Result := AdjVertice.Number = u;
    AdjVertice := AdjVertice.Next;
  end;
end;

end.
