unit GraphSearch;

interface

uses Digraph, DynStructures;

{ ������� ������ � ������� }
function DFS(const G: TGraph; u, v: Cardinal): TStack;

{ ������� ������ � ������ }
function BFS(const G: TGraph; u, v: Cardinal): TStack;

{ ������� ������ ���������� �������� }
function Dijkstra(const G: TGraph; u, v: Cardinal): TStack;

implementation

procedure MinDist(const Distances: array of Integer;
  const isVisited: Array of Boolean; var u, d: Cardinal);
var
  i: Integer;
begin

  d := INFINITY;

  for i := Low(Distances) to High(Distances) do
  begin
    if not isVisited[i] and (Distances[i] < d) then
    begin
      d := Distances[i];
      u := i + 1;
    end;
  end;
end;

function RestorePath(const Parents: array of Cardinal; u, v: Integer): TStack;
begin

  InitializeStack(Result); // ������������� �����

  // ���� �1. ���������� ���������� ������ � ����
  while u <> v do
  begin
    Push(Result, v);
    v := Parents[v - 1];
  end; // ����� �1
  Push(Result, u);

end;

function DFS;
var
  Node: TPNode;
  Neighbour: TAdjList;
  Stack: TStack;
  isFound: Boolean;
  Parents: Array of Cardinal;
  isVisited: Array of Boolean;
  i: Integer;
  w, StartCopy: Cardinal;
begin

  // ������������� �����
  InitializeStack(Stack);
  Push(Stack, u);

  // ������������� ������� �����
  SetLength(isVisited, G.Order);
  for i := Low(isVisited) to High(isVisited) do
    isVisited[i] := False;

  // ������������ ������� �������
  SetLength(Parents, G.Order);

  // ���� �1. ���������� ��������� �� ����� �� ���������� �������
  StartCopy := u; // ���������� ������ ����
  isFound := u = v;
  while not(isEmpty(Stack) or isFound) do
  begin
    // ��������� �������
    u := Pop(Stack);
    if not isVisited[u - 1] then
    begin

      // ��������� �������
      isVisited[u - 1] := true;
      isFound := u = v;

      // ���� �2. ���������� ������� � ����
      Node := GetByNumber(G, u);
      Neighbour := Node.Head;
      while not((Neighbour = nil) or isFound) do
      begin
        w := Neighbour.Elem;
        // ��������� ���������� ������

        // ���������� � ���� ������������ ������
        if not isVisited[w - 1] then
        begin
          Push(Stack, w); // ������� ������� � ����
          Parents[w - 1] := u; // ���������� ����
        end; // ����� if

        Neighbour := Neighbour.Next; // ������� � ���������� ������
      end; // ����� �2

    end; // ����� if

  end; // ����� �1

  DestroyList(Stack); // ������� �����

  // �������������� ����
  InitializeStack(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);
end;

function BFS;
var
  Node: TPNode;
  Neighbour: TAdjList;
  Queue: TQueue;
  i: Cardinal;
  isVisited: Array of Boolean;
  Parents: Array of Cardinal;
  StartCopy: Cardinal;
  w: Cardinal;
  isFound: Boolean;
begin

  // ������������� �������
  InitializeQueue(Queue);
  Enqueue(Queue, u);

  // ������������� ������� �����
  SetLength(isVisited, G.Order);
  for i := Low(isVisited) to High(isVisited) do
    isVisited[i] := False;

  // ������������� ������� �������
  SetLength(Parents, G.Order);

  // ���� �1. ���������� �� ������� ������
  StartCopy := u;
  isFound := u = v;
  while not(isEmpty(Queue.Head) or isFound) do
  begin
    u := Dequeue(Queue);
    if not isVisited[u - 1] then
    begin

      // ��������� �������
      isVisited[u - 1] := true;
      isFound := u = v;

      // ���� �2. ������� � ������� ������� �������
      Node := GetByNumber(G, u);
      Neighbour := Node.Head;
      while not((Neighbour = nil) or isFound) do
      begin
        w := Neighbour.Elem;
        if not isVisited[w - 1] then
        begin
          Enqueue(Queue, w); // ������ � �������
          Parents[w - 1] := u; // ���������� ����
        end; // ����� if
        Neighbour := Neighbour.Next;
      end; // ����� �2

    end; // ����� if

  end; // ����� �1

  // ������� �������
  DestroyList(Queue.Head);

  // �������������� ����
  InitializeStack(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);

end;

function Dijkstra;
var
  Node: TPNode;
  Neighbour: TAdjList;
  isVisited: Array of Boolean;
  Marks: Array of Integer;
  i: Cardinal;
  w: Cardinal;
  Parents: Array of Cardinal;
  StartCopy: Cardinal;
  isFound: Boolean;
  d: Cardinal;
  AdjMatrix: TAdjMatrix;
begin

  ToAdjMatrix(G, AdjMatrix);

  // ������������� �����
  SetLength(Marks, G.Order);
  for i := Low(Marks) to High(Marks) do
    Marks[i] := INFINITY;
  Marks[u - 1] := 0;

  // ������������� ������� �����
  SetLength(isVisited, G.Order);
  for i := Low(isVisited) to High(isVisited) do
    isVisited[i] := False;

  // ������������� ������� �������
  SetLength(Parents, G.Order);

  StartCopy := u;
  isFound := False;
  d := 0;

  while not(isFound or (d = INFINITY)) do
  begin
    MinDist(Marks, isVisited, u, d);
    isFound := u = v;
    isVisited[u - 1] := true;

    // TODO 3: ������ �� ����� � ������, ����� ������� �������
    for w := 0 to G.Order - 1 do
    begin
      if not isVisited[w] and (Marks[w] > d + AdjMatrix[u - 1, w]) then
      begin
        Marks[w] := d + AdjMatrix[u - 1, w];
        Parents[w] := u;
      end;

    end;
  end;

  // �������������� ����
  InitializeStack(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);
end;

end.
