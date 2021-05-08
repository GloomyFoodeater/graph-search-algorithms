unit GraphSearch;

interface

uses Digraph, DynStructures;

{ ��������� ������ � ������� }
procedure DFS(const Graph: TWeights; const Src, Dest: Integer;
  out Path: TStack);

{ ��������� ������ � ������ }
procedure BFS(const Graph: TWeights; const Src, Dest: Integer;
  out Path: TStack);

{ ��������� ������ ���������� �������� }
procedure Dijkstra(const Graph: TWeights; const Src, Dest: Integer;
  out Path: TStack);

implementation

{ ��������� ������ �� ���������� ������� � ���������� ������ }
procedure MinDist(const Distances: array of Integer;
  const isVisited: Array of Boolean; out v, d: Integer);
var
  i: Integer;
begin

  d := INFINITY;

  // ���� �1. ����� ������������ ��������
  for i := Low(Distances) to High(Distances) do
  begin

    // �������� ������������ � ���������
    if not isVisited[i] and (Distances[i] < d) then
    begin
      d := Distances[i];
      v := i + 1;
    end; // ����� if

  end; // ����� �1

end;

{ ��������� �������������� ���� �� ������� ������� }
procedure RestorePath(const Parents: array of Integer; const Src, Dest: Integer;
  out Path: TStack);
var
  v: Integer;
begin

  InitializeStack(Path); // ������������� �����
  v := Dest; // ���������� ����� ����

  // ���� �1. ���������� ���������� ������ � ����
  while (v <> Src) and (v <> 0) do
  begin
    Push(Path, v);
    v := Parents[v - 1];
  end; // ����� �1

  Push(Path, v);

  // ������, ���� ���� �� ��� ������
  if v = 0 then
    DestroyList(Path);
end;

procedure DFS(const Graph: TWeights; const Src, Dest: Integer;
  out Path: TStack);
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
  isUsed[v - 1] := true;

  // ���������� ������� �������
  SetLength(Parents, Order);
  Parents[v - 1] := 0;

  // ���� �1. ��������� ������ � �����
  while not isEmpty(s) do
  begin

    // ��������� �������
    v := Pop(s);

    // ���� �2. ���������� � ���� ���� ������� �������
    for u := 1 to Order do
    begin
      if not isUsed[u - 1] and (Graph[v - 1, u - 1] <> INFINITY) then
      begin
        isUsed[u - 1] := true;
        Parents[u - 1] := v;
        Push(s, u);
      end; // ����� if

    end; // ����� �2

  end; // ����� �1

  // �������������� ����
  RestorePath(Parents, Src, Dest, Path);
end;

procedure BFS(const Graph: TWeights; const Src, Dest: Integer;
  out Path: TStack);
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
  while not isEmpty(q.Head) do
  begin

    // ��������� �������
    v := Dequeue(q);

    // ���� �2. ���������� � ���� ���� ������� �������
    for u := 1 to Order do
    begin
      if not isUsed[u - 1] and (Graph[v - 1, u - 1] <> INFINITY) then
      begin
        isUsed[u - 1] := true;
        Parents[u - 1] := v;
        Enqueue(q, u);
      end; // ����� if

    end; // ����� �2

  end; // ����� �1

  // �������������� ����
  RestorePath(Parents, Src, Dest, Path);

end;

procedure Dijkstra(const Graph: TWeights; const Src, Dest: Integer;
  out Path: TStack);
var
  v, u: Integer;
  Order: Integer;
  isVisited: Array of Boolean;
  Parents: Array of Integer;
  Marks: Array of Integer;
  isFound: Boolean;
  d: Integer;
begin

  Order := Length(Graph); // ��������� ������� �����
  v := Src; // ���������� ������

  // ���������� ������� ����������
  SetLength(Marks, Order);
  for u := 1 to Order do
    Marks[u - 1] := INFINITY;
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
  while not(isFound or (d = INFINITY)) do
  begin

    for u := 1 to Order do
    begin
      if not isVisited[u - 1] and (Marks[u - 1] > d + Graph[v - 1, u - 1]) then
      begin
        Parents[u - 1] := v;
        Marks[u - 1] := d + Graph[v - 1, u - 1];
      end;
    end;

    // ��������� ��������� �������
    isVisited[v - 1] := true;
    isFound := v = Dest;
    MinDist(Marks, isVisited, v, d);

  end; // ����� �1

  // �������������� ����
  RestorePath(Parents, Src, Dest, Path);

end;

end.
