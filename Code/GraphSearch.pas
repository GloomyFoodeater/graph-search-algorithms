unit GraphSearch;

interface

uses Digraph, DynStructures;

type
  // ��� ������� �����
  TWeights = array of array of Integer;

  TSearchInfo = record
    Distance: Integer;
    ArcsCount: Integer;
    Path: TStack;
  end;

  { ��������� �������������� ����� � ������� ����� }
procedure ToWeightMatrix(const G: TGraph; out Matrix: TWeights);

{ ��������� ������ � ������� }
procedure DFS(const Graph: TWeights; const Src, Dest: Integer;
  out Info: TSearchInfo);

{ ��������� ������ � ������ }
procedure BFS(const Graph: TWeights; const Src, Dest: Integer;
  out Info: TSearchInfo);

{ ��������� ������ ���������� �������� }
procedure Dijkstra(const Graph: TWeights; const Src, Dest: Integer;
  out Info: TSearchInfo);

implementation

const
  INF = 1000000000;

  { ��������� �������������� ���� �� ������� ������� }
procedure RestorePath(const Graph: TWeights; const Parents: array of Integer;
  const Src, Dest: Integer; out Info: TSearchInfo);
var
  v, w: Integer;
begin

  with Info do
  begin
    InitializeStack(Path); // ������������� �����
    v := Dest; // ���������� ����� ����
    ArcsCount := 0;
    Distance := 0;
    // ���� �1. ���������� ���������� ������ � ����
    while (v <> Src) and (v <> 0) do
    begin
      Push(Path, v);
      Inc(ArcsCount);
      w := Graph[Parents[v - 1] - 1, v - 1];
      if w = INF then
        w := 0;
      Distance := Distance + w;
      v := Parents[v - 1];
    end; // ����� �1

    Push(Path, v);

    // ������, ���� ���� �� ��� ������
    if v = 0 then
      DestroyList(Path);
  end;

end;

procedure DFS(const Graph: TWeights; const Src, Dest: Integer;
  out Info: TSearchInfo);
var
  v, u: Integer;
  Order: Integer;
  s: TStack;
  isUsed: Array of Boolean;
  Parents: Array of Integer;
begin

  Order := Length(Graph); // ��������� ������� �����
  v := Src; // ���������� ������

  // ���������� �����
  InitializeStack(s);
  Push(s, v);

  // ���������� �����
  SetLength(isUsed, Order);
  for u := 1 to Order do
    isUsed[u - 1] := False;

  // ���������� ������� �������
  SetLength(Parents, Order);
  Parents[v - 1] := 0;

  // ���� �1. ��������� ������ � �����
  while s <> nil do
  begin

    // ��������� �������
    v := Pop(s);
    if not isUsed[v - 1] then
    begin
      isUsed[v - 1] := true;

      // ���� �2. ���������� � ���� ���� ������� �������
      for u := Order downto 1 do
      begin
        if not isUsed[u - 1] and (Graph[v - 1, u - 1] <> INF) then
        begin
          Parents[u - 1] := v;
          Push(s, u);
        end; // ����� if

      end; // ����� �2

    end;

  end; // ����� �1

  // �������������� ����
  RestorePath(Graph, Parents, Src, Dest, Info);
end;

procedure BFS(const Graph: TWeights; const Src, Dest: Integer;
  out Info: TSearchInfo);
var
  v, u: Integer;
  Order: Integer;
  q: TQueue;
  isUsed: Array of Boolean;
  Parents: Array of Integer;
begin

  Order := Length(Graph); // ��������� ������� �����
  v := Src; // ���������� ������

  // ���������� �����
  InitializeQueue(q);
  Enqueue(q, v);

  // ���������� �����
  SetLength(isUsed, Order);
  for u := 1 to Order do
    isUsed[u - 1] := False;
  isUsed[v - 1] := true;

  // ���������� ������� �������
  SetLength(Parents, Order);
  Parents[v - 1] := 0;

  // ���� �1. ��������� ���� ������ �� �������
  while q.Head <> nil do
  begin

    // ��������� �������
    v := Dequeue(q);

    // ���� �2. ���������� � ���� ���� ������� �������
    for u := 1 to Order do
    begin
      if not isUsed[u - 1] and (Graph[v - 1, u - 1] <> INF) then
      begin
        isUsed[u - 1] := true;
        Parents[u - 1] := v;
        Enqueue(q, u);
      end; // ����� if

    end; // ����� �2

  end; // ����� �1

  // �������������� ����
  RestorePath(Graph, Parents, Src, Dest, Info);

end;

procedure Dijkstra(const Graph: TWeights; const Src, Dest: Integer;
  out Info: TSearchInfo);
var
  v, u: Integer;
  Order: Integer;
  isVisited: Array of Boolean;
  Parents: Array of Integer;
  Marks: Array of Integer;
  isFound: Boolean;
  d: Integer;
  i: Integer;
begin

  Order := Length(Graph); // ��������� ������� �����
  v := Src; // ���������� ������

  // ���������� ������� ����������
  SetLength(Marks, Order);
  for u := 1 to Order do
    Marks[u - 1] := INF;
  Marks[v - 1] := 0;

  // ���������� ������� �����
  SetLength(isVisited, Order);
  for u := 1 to Order do
    isVisited[u - 1] := False;

  // ���������� ������� �������
  SetLength(Parents, Order);
  Parents[v - 1] := 0;

  // ������������� ������� ����� � ����
  isFound := v = Dest;
  d := 0;

  // ���� �1. ��������� ������ � ������������ ������������
  while not(isFound or (d = INF)) do
  begin

    // ���� �2. ���������� �����
    for u := 1 to Order do
    begin
      if not isVisited[u - 1] and (Marks[u - 1] > d + Graph[v - 1, u - 1]) then
      begin
        Parents[u - 1] := v;
        Marks[u - 1] := d + Graph[v - 1, u - 1];
      end;
    end; // ����� �2

    // ��������� �������� �������
    isVisited[v - 1] := true;
    isFound := v = Dest;

    d := INF;

    // ���� �1. ����� ������������ ��������
    for i := Low(Marks) to High(Marks) do
    begin

      // �������� ������������ � ���������
      if not isVisited[i] and (Marks[i] < d) then
      begin
        d := Marks[i];
        v := i + 1;
      end; // ����� if

    end; // ����� �1

  end; // ����� �1

  // �������������� ����
  RestorePath(Graph, Parents, Src, Dest, Info);

end;

{ ��������� �������������� ����� � ������� ����� }
procedure ToWeightMatrix(const G: TGraph; out Matrix: TWeights);
var
  v, u: Integer;
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
begin

  // ������������� �������
  SetLength(Matrix, G.Order, G.Order);
  for v := 1 to G.Order do
    for u := 1 to G.Order do
      Matrix[v - 1, u - 1] := INF;

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
    end;
    // ����� A3

    Vertice := Vertice.Next;
  end; // ����� A2
end;

end.
