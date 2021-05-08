unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils;

const
  INFINITY = 1000000;

type

  // ��� ������ ���������
  TAdjList = TList;

  // ��� ������� �����
  TVerticeList = ^TVerticeNode;

  TVerticeNode = record
    Center: TPoint;
    Number: Integer;
    Head: TAdjList;
    Next: TVerticeList;
    Deg: Integer;
  end;

  // ��� ��������������� ����
  TGraph = record
    Head: TVerticeList;
    Tail: TVerticeList;
    Order: Integer;
  end;

  // ��� ������� �����
  TWeights = array of array of Integer;

  { ��������� ��������� ������� �� ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TVerticeList);

{ ��������� ���������� ������� � � ���������� �� ����� �� ������ }
procedure Centralize(const G: TGraph; var P: TPoint; R: Integer;
  out v: Integer);

{ ������� ��������� ������ ������� }
function GetCenter(const G: TGraph; v: Integer): TPoint;

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;

{ ��������� ���������� ������� � ���� }
procedure AddNode(var G: TGraph; const C: TPoint);

{ ��������� ���������� ���� � ���� }
procedure AddLink(var G: TGraph; v, u: Integer);

{ ��������� �������� ������� �� ����� }
procedure DeleteNode(var G: TGraph; v: Integer);

{ ��������� �������� ���� �� ����� }
procedure DeleteLink(var G: TGraph; v, u: Integer);

{ ��������� ������������� ����� }
procedure InitializeGraph(var G: TGraph);

{ ��������� �������� ����� }
procedure DestroyGraph(var G: TGraph);

{ ��������� �������������� ����� � ������� ����� }
procedure ToWeightMatrix(const G: TGraph; var Matrix: TWeights);

implementation

function Distance(const p1, p2: TPoint): Integer;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

{ ������� ���������� ������� �� ������ � ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TVerticeList);
begin
  Vertice := G.Head;

  // ���� �1. ����� ������� � ������ �������
  while (Vertice <> nil) and (Vertice.Number <> v) do
  begin
    Vertice := Vertice.Next;
  end; // ����� �1

end;

procedure Centralize(const G: TGraph; var P: TPoint; R: Integer;
  out v: Integer);
var
  Vertice, Found: TVerticeList;
  isFound: Boolean;
begin
  Vertice := G.Head;
  isFound := False;
  Found := nil;

  // ���� �1. ����� ��������� ������� � �������� ������������
  while Vertice <> nil do
  begin
    isFound := Distance(Vertice.Center, P) <= R;
    if isFound then
      Found := Vertice;
    Vertice := Vertice.Next;
  end; // ����� �1

  // ������� ��������� �������
  if Found <> nil then
  begin
    v := Found.Number;
    P := Found.Center;
  end
  else
    v := 0; // ������� �� ���� �������
end;

function GetCenter(const G: TGraph; v: Integer): TPoint;
var
  Vertice: TVerticeList;
begin
  GetByNumber(G, v, Vertice);
  if Vertice <> nil then
    Result := Vertice.Center;
end;

procedure AddNode(var G: TGraph; const C: TPoint);
var
  Vertice: TVerticeList;
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
  end;

  // ������������� ��������� �� ����� �������
  if G.Head = nil then
    G.Head := Vertice
  else
    G.Tail.Next := Vertice;

  // ���������� ������
  G.Tail := Vertice;

end;

procedure AddLink(var G: TGraph; v, u: Integer);
var
  Vertice: TVerticeList;
  PrevArc, CurrArc: TAdjList;
  isFound: Boolean;
begin

  // ��������� �������
  GetByNumber(G, v, Vertice);
  Inc(Vertice.Deg);

  // ������������� ������ ������
  New(CurrArc);
  CurrArc.Number := u;

  // ��������� ���������� ������
  PrevArc := Vertice.Head;

  // ������ ��������� ��� ���� ��� ������ ���� ������ ������ ������
  if (PrevArc = nil) or (PrevArc.Number > u) then
  begin
    CurrArc.Next := PrevArc;
    Vertice.Head := CurrArc;
  end
  else
  begin

    // ���� �1. ����� ����� ������� (����������� ������)
    isFound := (PrevArc.Next = nil) or (PrevArc.Next.Number > u);
    while not isFound do
    begin
      PrevArc := PrevArc.Next;
      isFound := (PrevArc.Next = nil) or (PrevArc.Next.Number > u);
    end; // ����� �1

    // ������� ������ ������
    CurrArc.Next := PrevArc.Next;
    PrevArc.Next := CurrArc;

  end; // ����� if

end;

procedure DeleteNode(var G: TGraph; v: Integer);
var
  PrevVertice, Vertice: TVerticeList;
  PrevArc, Arc: TAdjList;
begin
  Dec(G.Order);

  // ���� �1. ������ �� ��������
  PrevVertice := nil;
  Vertice := G.Head;
  while Vertice <> nil do
  begin

    // �������� ������ �������
    if Vertice.Number = v then
    begin

      // �������������� ����������� ���������
      if PrevVertice = nil then
        G.Head := Vertice.Next
      else
        PrevVertice.Next := Vertice.Next;

      // ������������ ������ ���������
      DestroyList(Vertice.Head);
      Dispose(Vertice);
    end // ����� if
    else
    begin

      // ���������� ���� ������, ������� ��������� �� 1
      if Vertice.Number > v then
        Dec(Vertice.Number);

      // ���� �2. ������ �� ������� �������
      PrevArc := nil;
      Arc := Vertice.Head;
      while Arc <> nil do
      begin

        // �������� ������ ������
        if Arc.Number = v then
        begin

          // �������������� ����������� ���������
          if PrevArc = nil then
            Vertice.Head := Arc.Next
          else
            PrevArc.Next := Arc.Next;

          // ������������ ������ ����� ������
          Dispose(Arc);
        end // ����� if
        else if Arc.Number > v then
          Dec(Arc.Number);

        // ������� � ���������� ������
        PrevArc := Arc;
        Arc := Arc.Next;

      end; // ����� �2

    end; // ����� else

    // ������� � ��������� �������
    if Vertice.Next <> nil then
      PrevVertice := Vertice;
    Vertice := Vertice.Next;
  end; // ����� �1

  // �������������� ������ ������
  G.Tail := PrevVertice;
end;

procedure DeleteLink(var G: TGraph; v, u: Integer);
var
  Vertice: TVerticeList;
  PrevArc: TAdjList;
  Arc: TAdjList;
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
    Arc := PrevArc;
    if Arc <> nil then
      Vertice.Head := Arc.Next
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
  G.Tail := nil;
  G.Order := 0;
end;

procedure DestroyGraph(var G: TGraph);
var
  Vertice: TVerticeList;
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

procedure ToWeightMatrix(const G: TGraph; var Matrix: TWeights);
var
  i, j: Integer;
  Vertice: TVerticeList;
  Arc: TAdjList;
begin

  // ������������� �������
  SetLength(Matrix, G.Order, G.Order);

  // ���� �1. ������ �� ��������
  Vertice := G.Head;
  for i := 0 to G.Order - 1 do
  begin

    // ���� �2. ������ �� �������
    Arc := Vertice.Head;
    for j := 0 to G.Order - 1 do
    begin

      // �������� ��������� ������
      if (Arc <> nil) and (Arc.Number = j + 1) then
      begin

        // ������� ���� ������
        Matrix[i, j] := 1;

        // ������� � ���������� ������
        Arc := Arc.Next;
      end
      else
        Matrix[i, j] := INFINITY;
      // ������� �� ���� ��������
    end; // ����� �2

    // ������� � ��������� �������
    Vertice := Vertice.Next;
  end; // ����� �1
end;

end.
