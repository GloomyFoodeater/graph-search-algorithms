unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils;

const
  INFINITY = 1000000000;

type

  // ��� ������������ ����� ������
  TDesign = (dgPassive, dgActive, dgVisited);

  // ��� ������ ���������
  TPNeighbour = ^TNeighbour;

  TNeighbour = record
    Number: Integer;
    Weight: Integer;
    isVisited: Boolean;
    Next: TPNeighbour;
  end;

  // ��� ������� �����
  TPVertice = ^TVertice;

  TVertice = record
    Center: TPoint;
    Number: Integer;
    Head: TPNeighbour;
    Next: TPVertice;
    Deg: Integer;
    Design: TDesign;
  end;

  // �������������� ����� ��� ������ � �������
  TVerFile = File of TVertice;
  TArcFile = File of TNeighbour;

  // ��� ��������������� ����
  TGraph = record
    Head: TPVertice;
    Tail: TPVertice;
    Order: Integer;
    isPainted: Boolean;
    R: Integer;
  end;

  // ��� ������� �����
  TWeights = array of array of Integer;

  { ��������� ������������� ����� }
procedure InitializeGraph(var G: TGraph; R: Integer);

{ ��������� �������� ����� }
procedure DestroyGraph(var G: TGraph);

{ ��������� ���������� ������� � ���� }
procedure AddVertice(var G: TGraph; const C: TPoint);

{ ��������� ���������� ���� � ���� }
procedure AddArc(var G: TGraph; v, u: Integer; w: Integer);

{ ��������� �������� ������� �� ����� }
procedure DeleteVertice(var G: TGraph; v: Integer);

{ ��������� �������� ���� �� ����� }
procedure DeleteArc(var G: TGraph; v, u: Integer);

{ ��������� ��������� ������� �� ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TPVertice);

{ ��������� ���������� ������� �� ����� �� ������ }
function Centralize(const G: TGraph; const P: TPoint;
  out Vertice: TPVertice): Boolean;

// ������������ �������� ����� �� �������������� ������
procedure OpenGraph(var G: TGraph; var VerFile: TVerFile;
  var ArcFile: TArcFile);

// ������������ ���������� ����� � �������������� ����
procedure SaveGraph(var G: TGraph; var VerFile: TVerFile;
  var ArcFile: TArcFile);

{ ��������� �������������� ����� � ������� ����� }
procedure ToWeightMatrix(const G: TGraph; out Matrix: TWeights);

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;

implementation

function AreAdjacent(const G: TGraph; Vertice: TPVertice; u: Integer): Boolean;
var
  Neighbour: TPNeighbour;
begin
  Result := false;

  Neighbour := Vertice.Head;
  while not Result and (Neighbour <> nil) do
  begin
    Result := Neighbour.Number = u;
    Neighbour := Neighbour.Next;
  end;
end;

procedure DestroyAdjList(var Head: TPNeighbour);
var
  Neighbour: TPNeighbour;
begin
  while Head <> nil do
  begin
    Neighbour := Head;
    Head := Head.Next;
    Dispose(Neighbour);
  end;
  Head := nil;
end;

procedure AddVertice;
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

procedure AddArc;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
begin
  GetByNumber(G, v, Vertice);
  if not AreAdjacent(G, Vertice, u) then
  begin

    Inc(Vertice.Deg);

    // ���������� ������ � ������ ���������
    New(Neighbour);
    Neighbour.Number := u;
    Neighbour.Weight := w;
    Neighbour.isVisited := false;
    Neighbour.Next := Vertice.Head;
    Vertice.Head := Neighbour;

  end;
end;

procedure DeleteVertice;
var
  PrevVertice, Vertice: TPVertice;
  PrevAdjVertice, Neighbour: TPNeighbour;
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
  DestroyAdjList(Vertice.Head);
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
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin

      // �������� ������ ������� �������
      if Neighbour.Number = v then
      begin
        if PrevAdjVertice = nil then
          Vertice.Head := Neighbour.Next
        else
          PrevAdjVertice.Next := Neighbour.Next;
        Dispose(Neighbour);
      end
      else if Neighbour.Number > v then
        Dec(Neighbour.Number); // ���������� ������ ������

      PrevAdjVertice := Neighbour;
      Neighbour := Neighbour.Next;
    end; // ����� �2
    Vertice := Vertice.Next;
  end; // ����� �1
end;

procedure DeleteArc;
var
  Vertice: TPVertice;
  Neighbour, PrevAdjVertice: TPNeighbour;
  isFound: Boolean;
begin

  // ��������� ������ ����
  GetByNumber(G, v, Vertice);

  if not AreAdjacent(G, Vertice, u) then
    Exit;

  Dec(Vertice.Deg);

  // ��������� ������� ������
  PrevAdjVertice := Vertice.Head;
  Neighbour := nil;

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

    Neighbour := PrevAdjVertice.Next;
    PrevAdjVertice.Next := Neighbour.Next;
  end;

  // �������� ������
  if Neighbour <> nil then
  begin
    Dispose(Neighbour);
  end;

end;

procedure InitializeGraph;
begin
  G.Head := nil;
  G.Tail := nil;
  G.Order := 0;
  G.isPainted := false;
  G.R := R;
end;

procedure DestroyGraph;
var
  Vertice: TPVertice;
begin

  // ���� �1. ������������ ������ ������
  while G.Head <> nil do
  begin
    Vertice := G.Head;

    // ���� �2. ������������ ������ ������� �������
    DestroyAdjList(Vertice.Head);

    G.Head := G.Head.Next;
    Dispose(Vertice);
  end; // ����� �1
end;

procedure GetByNumber;
begin
  Vertice := G.Head;
  while (Vertice <> nil) and (Vertice.Number <> v) do
    Vertice := Vertice.Next;
end;

function Centralize;
begin
  Vertice := G.Head;
  Result := (Vertice = nil) or (Distance(Vertice.Center, P) <= G.R);

  // ���� �1. ����� ��������� ������� � �������� ������������
  while not Result and (Vertice.Next <> nil) do
  begin
    Vertice := Vertice.Next;
    Result := Distance(Vertice.Center, P) <= G.R;
  end; // ����� �1

  if not Result then
    Vertice := nil;
end;

procedure OpenGraph;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  v: Integer;
begin
  InitializeGraph(G, 40);
  New(Vertice);
  New(Neighbour);
  // ���� �1. ������ �� ����� ������
  while not Eof(VerFile) do
  begin

    // ������ ��������� �������
    Read(VerFile, Vertice^);
    AddVertice(G, Vertice.Center);

    // ���� �2. ��������� ������ �� ����� ����
    for v := 1 to Vertice.Deg do
    begin
      Read(ArcFile, Neighbour^);
      AddArc(G, Vertice.Number, Neighbour.Number, Neighbour.Weight);
    end; // ����� �2
  end; // ����� �1

  Dispose(Vertice);
  Dispose(Neighbour);
end;

procedure SaveGraph;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
begin

  // ���� �1. ������ �� ��������
  Vertice := G.Head;
  while Vertice <> nil do
  begin
    Write(VerFile, Vertice^);

    // ���� �2. ������ �� �������
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      Write(ArcFile, Neighbour^);
      Neighbour := Neighbour.Next;
    end; // ����� �1
    Vertice := Vertice.Next;
  end; // ����� �2
end;

procedure ToWeightMatrix;
var
  v, u: Integer;
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
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
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      Matrix[Vertice.Number - 1, Neighbour.Number - 1] := Neighbour.Weight;
      Neighbour := Neighbour.Next;
    end; // ����� A3

    Vertice := Vertice.Next;
  end; // ����� A2
end;

function Distance;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

end.
