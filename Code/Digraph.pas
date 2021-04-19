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

  { ������� ���������� ������� �� ������ � ������ }
function GetByNumber(const G: TGraph; v: Integer): TPNode;

{ ������� ���������� ������� �� ����� �� ������ }
function GetByPoint(const G: TGraph; P: TPoint): TPNode;

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;

{ ��������� ���������� ������� � ���� }
procedure AddNode(var G: TGraph; const C: TPoint);

{ ��������� ���������� ���� � ���� }
procedure AddLink(var G: TGraph; u, v: Integer);

{ ��������� ������������� ����� }
procedure InitializeGraph(var G: TGraph);

{ ��������� �������� ����� }
procedure DestroyGraph(var G: TGraph);

{ ������� ������ � ������� }
function DFS(const G: TGraph; u, v: Integer): TPList;

implementation

function Distance(const p1, p2: TPoint): Integer;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

function GetByNumber;
begin
  Result := G.Head;

  // ���� �1. ����� ������� � ������ �������
  while Result.Number <> v do
  begin
    Result := Result.Next;
  end; // ����� �1

end;

function GetByPoint;
var
  Node: TPNode;
  Found: TPNode;
  isFound: Boolean;
  x, y: Integer;
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

  Result := Found;
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
    Push(Node.Head, v)
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

function RestorePath(const Parents: array of Cardinal; u, v: Integer): TPList;
begin

  InitializeList(Result); // ������������� �����

  // ���� �1. ���������� ���������� ������ � ����
  while u <> v do
  begin
    Push(Result, v);
    v := Parents[v - 1];
  end; // ����� �1
  Push(Result, u);

end;

function DFS(const G: TGraph; u, v: Integer): TPList;
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
  InitializeList(Stack);
  Push(Stack, u);

  // ������������� ������� �����
  SetLength(isVisited, G.Order);
  for i := Low(isVisited) to High(isVisited) do
    isVisited[i] := False;

  // ������������ ������� �������
  SetLength(Parents, G.Order);
  Parents[u] := 0;

  // ���� �1. ���������� ��������� �� ����� �� ���������� �������
  StartCopy := u; // ���������� ������ ����
  isFound := u = v;
  while not(isEmpty(Stack) or isFound) do
  begin

    // ���� �2. ���������� ������� � ����
    Node := GetByNumber(G, u);
    Neighbour := Node.Head;
    while Neighbour <> nil do
    begin
      w := Neighbour.Elem; // ��������� ���������� ������

      // ���������� � ���� ������������ ������
      if not isVisited[w - 1] then
      begin
        Push(Stack, w);
        Parents[w - 1] := u; // ���������� ����
      end; // ����� if

      Neighbour := Neighbour.Next; // ������� � ���������� ������
    end; // ����� �2

    // ��������� �������
    u := Pop(Stack);
    isFound := u = v;
    isVisited[u - 1] := true;

  end; // ����� �1

  DestroyList(Stack); // ������� �����

  // �������������� ����
  InitializeList(Result);
  if isFound then
    Result := RestorePath(Parents, StartCopy, v);
end;

end.
