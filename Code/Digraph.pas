unit Digraph;

interface

uses System.Types, DynStructures;

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
procedure DisposeGraph(var G: TGraph);

{ ������� ������ � ������� }
function DFS(const G: TGraph; u, v: Integer): Boolean;

implementation

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;
begin
  Result := Round(Sqrt(Sqr(p2.x - p1.x) + Sqr(p2.y - p1.y)));
end;

{ ������� ���������� ������� �� ������ � ������ }
function GetByNumber;
var
  i: Integer;
begin
  Result := G.Head;
  for i := 1 to v - 1 do
  begin
    Result := Result.Next;
  end;

end;

{ ������� ���������� ������� �� ����� �� ������ }
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

  while Node <> nil do
  begin
    isFound := Distance(Node.Center, P) <= 20;
    if isFound then
      Found := Node;
    Node := Node.Next;
  end;

  Result := Found;
end;

{ ��������� ���������� ������� � ���� }
procedure AddNode;
var
  t: TPNode;
begin
  Inc(G.Order);

  // ������������� ����� �������
  New(t);
  with t^ do
  begin
    Center := C;
    Number := G.Order;
    Head := nil;
    Next := nil;
  end;

  // ������������� ��������� �� ����� �������
  if G.Head = nil then
  begin
    G.Head := t;
    G.Tail := t;
  end
  else
  begin
    G.Tail.Next := t;
    G.Tail := t;
  end;

end;

{ ��������� ���������� ���� � ���� }
procedure AddLink;
var
  Node: TPNode;
  a, b: TPList;
  isFound: Boolean;
begin

  // ��������� �������
  Node := GetByNumber(G, u);

  // ������ ��������� ��� ����
  if Node.Head = nil then
  begin
    New(Node.Head);
    Node.Head.Elem := v;
    Node.Head.Next := nil;
  end
  else
  begin

    // ��������� ���������� ������
    a := Node.Head;

    // ����� ������, ������� ������ ������������
    isFound := (a.Elem > v) or (a.Next = nil) or (a.Next.Elem > v);
    while not isFound do
    begin
      a := a.Next;
      isFound := (a.Next = nil) or (a.Next.Elem > v);
    end;

    // ������������� ������ ������
    New(b);
    b.Elem := v;

    if Node.Head.Elem > v then
    begin

      // ������ ����� �������� ����� ������� ������
      b.Next := a;
      Node.Head := b;
    end
    else
    begin
      // ������ ����� �������� ����� ������ �� ��������� �������� ������
      b.Next := a.Next;
      a.Next := b;
    end;

  end;

end;

{ ��������� ������������� ����� }
procedure InitializeGraph;
begin
  G.Head := nil;
  G.Tail := nil;
  G.Order := 0;
end;

{ ��������� �������� ����� }
procedure DisposeGraph;
var
  pNode: TPNode;
  pAdjNode: TPAdjList;
begin

  // ���� �1. ������������ ������ ������
  while G.Head <> nil do
  begin
    pNode := G.Head;

    // ���� �2. ������������ ������ ������� �������
    while pNode.Head <> nil do
    begin
      pAdjNode := pNode.Head;
      pNode.Head := pNode.Head.Next;
      Dispose(pAdjNode);
    end; // ����� �2

    G.Head := G.Head.Next;
    Dispose(pNode);
  end; // ����� �1
end;

// TODO 1: ��������� ���� � �������
function DFS(const G: TGraph; u, v: Integer): Boolean;
var
  Node: TPNode;
  Neighbour: TPAdjList;
  Stack: TStack;
  isFound: Boolean;
  isVisited: Array of Boolean;
  i: Integer;
  w: Cardinal;
begin

  // ���������� �����
  InitList(Stack);
  PushBack(Stack, u);

  // ������������� ������� �����
  SetLength(isVisited, G.Order);
  for i := Low(isVisited) to High(isVisited) do
    isVisited[i] := False;

  isFound := u = v;
  // ���� �� �����, ���� �� ������� �������
  while not(isEmpty(Stack) or isFound) do
  begin

    // ���� �� ������� �������
    Node := GetByNumber(G, u);
    Neighbour := Node.Head;
    while Neighbour <> nil do
    begin
      w := Neighbour.Elem;
      if not isVisited[w] then
        PushBack(Stack, w); // ���������� � ���� ������������ ������
      Neighbour := Neighbour.Next;
    end;

    // ��������� �������
    u := PopBack(Stack);
    isFound := u = v;
    isVisited[u - 1] := true;

  end;

  Result := isFound;
end;

end.
