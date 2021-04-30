unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils;

type

  // ��� ������ ���������
  TPAdjList = TPList;

  // ��� ������� �����
  TPNode = ^TNode;

  TNode = record
    Center: TPoint;
    Number: Cardinal;
    Head: TPAdjList;
    Next: TPNode;
  end;

  // ��� ������� ����
  TGraph = record
    Head: TPNode;
    Tail: TPNode;
    Order: Cardinal;
  end;

  { ������� ���������� ������� � � ���������� �� ����� �� ������ }
procedure Centralize(const G: TGraph; var P: TPoint; out u: Cardinal);

{ ������� ��������� ������ ������� }
function GetCenter(const G: TGraph; u: Cardinal): TPoint;

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;

{ ��������� ���������� ������� � ���� }
procedure AddNode(var G: TGraph; const C: TPoint);

{ ��������� ���������� ���� � ���� }
procedure AddLink(var G: TGraph; u, v: Cardinal);

{ ��������� �������� ������� �� ����� }
procedure DeleteNode(var G: TGraph; u: Cardinal);

{ ��������� �������� ����� �� ����� }
procedure DeleteLink(var G: TGraph; u, v: Cardinal);

{ ��������� ������������� ����� }
procedure InitializeGraph(var G: TGraph);

{ ��������� �������� ����� }
procedure DestroyGraph(var G: TGraph);

{ ������� ������ � ������� }
function DFS(const G: TGraph; u, v: Cardinal): TStack;

{ ������� ������ � ������ }
function BFS(const G: TGraph; u, v: Cardinal): TStack;

{ ������� ������ ���������� �������� }
function Dijkstra(const G: TGraph; u, v: Cardinal): TStack;

implementation

function Distance(const p1, p2: TPoint): Integer;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

{ ������� ���������� ������� �� ������ � ������ }
function GetByNumber(const G: TGraph; u: Integer): TPNode;
begin
  Result := G.Head;

  // ���� �1. ����� ������� � ������ �������
  while Result.Number <> u do
  begin
    Result := Result.Next;
  end; // ����� �1

end;

procedure Centralize;
var
  Node: TPNode;
  Found: TPNode;
  isFound: Boolean;
begin
  Node := G.Head;
  isFound := False;
  Found := nil;

  // ���� �1. ����� ��������� ������� � �������� ������������
  while Node <> nil do
  begin
    isFound := Distance(Node.Center, P) <= 20;
    if isFound then
      Found := Node;
    Node := Node.Next;
  end; // ����� �1

  // ������� ��������� �������
  if Found <> nil then
  begin
    u := Found.Number;
    P := Found.Center;
  end
  else
    u := 0; // ������� �� ���� �������
end;

function GetCenter;
var
  Node: TPNode;
begin
  Node := GetByNumber(G, u);
  Result := Node.Center;
end;

procedure AddNode;
var
  Node: TPNode;
begin
  Inc(G.Order);

  // ������������� ����� �������
  New(Node);
  with Node^ do
  begin
    Center := C;
    Number := G.Order;
    Head := nil;
    Next := nil;
  end;

  // ������������� ��������� �� ����� �������
  if G.Head = nil then
    G.Head := Node
  else
    G.Tail.Next := Node;

  // ���������� ������
  G.Tail := Node;

end;

procedure AddLink;
var
  Node: TPNode;
  Prev, Curr: TPList;
  isFound: Boolean;
begin

  // ��������� �������
  Node := GetByNumber(G, u);

  // ������������� ������ ������
  New(Curr);
  Curr.Elem := v;

  // ��������� ���������� ������
  Prev := Node.Head;

  // ������ ��������� ��� ���� ��� ������ ���� ������ ������ ������
  if (Prev = nil) or (Prev.Elem > v) then
  begin
    Curr.Next := Prev;
    Node.Head := Curr;
  end
  else
  begin

    // ���� �1. ����� ����� ������� (����������� ������)
    isFound := (Prev.Next = nil) or (Prev.Next.Elem > v);
    while not isFound do
    begin
      Prev := Prev.Next;
      isFound := (Prev.Next = nil) or (Prev.Next.Elem > v);
    end;

    // ������� ������ ������
    Curr.Next := Prev.Next;
    Prev.Next := Curr;

  end; // ����� if

end;

procedure DeleteNode;
begin

end;

procedure DeleteLink;
var
  Node: TPNode;
  Neighbour: TPList;
  DelNeighbour: TPList;
  isFound: Boolean;
begin

  // ��������� ������ ����
  Node := GetByNumber(G, u);

  // ��������� ������� ������
  Neighbour := Node.Head;

  // ����� ����� ����� ������ � ������� �������
  if (Neighbour = nil) or (Neighbour.Elem = v) then
  begin
    DelNeighbour := Neighbour;
    Node.Head := DelNeighbour.Next
  end
  else
  begin

    isFound := (Neighbour.Next.Elem = v) or (Neighbour = nil);

    // ��������� ����������� ������ ����������
    while not isFound do
    begin
      Neighbour := Neighbour.Next;
      isFound := (Neighbour = nil) or (Neighbour.Next.Elem = v);
    end;

    DelNeighbour := Neighbour.Next;
    Neighbour.Next := DelNeighbour.Next;
  end;

  // �������� ������
  if not(DelNeighbour = nil) then
  begin
    Dispose(DelNeighbour);
  end;

end;

procedure InitializeGraph;
begin
  G.Head := nil;
  G.Tail := nil;
  G.Order := 0;
end;

procedure DestroyGraph;
var
  Node: TPNode;
  Neighbour: TPAdjList;
begin

  // ���� �1. ������������ ������ ������
  while G.Head <> nil do
  begin
    Node := G.Head;

    // ���� �2. ������������ ������ ������� �������
    while Node.Head <> nil do
    begin
      Neighbour := Node.Head;
      Node.Head := Node.Head.Next;
      Dispose(Neighbour);
    end; // ����� �2

    G.Head := G.Head.Next;
    Dispose(Node);
  end; // ����� �1
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
  Neighbour: TPAdjList;
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

  DestroyStack(Stack); // ������� �����

  // �������������� ����
  InitializeStack(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);
end;

function BFS;
var
  Node: TPNode;
  Neighbour: TPAdjList;
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
  DestroyQueue(Queue);

  // �������������� ����
  InitializeStack(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);

end;

function Dijkstra;
const
  INFINITY: Cardinal = MaxInt; //TODO: Max cardinal
var
  Node: TPNode;
  Neighbour: TPAdjList;
  isVisited: Array of Boolean;
  Marks: Array of Cardinal;
  i: Cardinal;
  w: Cardinal;
  Parents: Array of Cardinal;
  StartCopy: Cardinal;
  isFound: Boolean;
begin

  // ������������� �����
  for i := Low(Marks) to High(Marks) do
    Marks[i] := INFINITY;
  Marks[u] := 0;

  // ������������� ������� �����
  SetLength(isVisited, G.Order);
  for i := Low(isVisited) to High(isVisited) do
    isVisited[i] := False;

  // ������������� ������� �������
  SetLength(Parents, G.Order);

  StartCopy := u;
  isFound := u = v;

  // �������������� ����
  InitializeStack(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);

end;

end.
