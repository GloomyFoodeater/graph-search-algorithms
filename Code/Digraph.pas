unit Digraph;

interface

uses System.Types;

type
  // ��� ������ ���������
  TPAdjList = ^TAdjList;

  TAdjList = record
    Elem: Integer;
    Next: TPAdjList;
  end;

  // ��� ������s �����
  TPNode = ^TNode;

  TNode = record
    Center: TPoint;
    Number: Cardinal;
    Head: TPAdjList;
    Tail: TPAdjList;
    Next: TPNode;
  end;

  // ��� ������� ����
  TGraph = record
    Head: TPNode;
    Tail: TPNode;
    VG: Cardinal;
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

{ ��������� �������� ����� }
procedure DisposeGraph(var G: TGraph);

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
begin
  Inc(G.VG);

  // ������������� ��������� �� ����� �������
  if G.Tail = nil then
    New(G.Tail)
  else
  begin
    New(G.Tail.Next);
    G.Tail := G.Tail.Next
  end;

  // ���������� ����� �������
  with G.Tail^ do
  begin
    Center := C;
    Number := G.VG;
    Head := nil;
    Tail := nil;
    Next := nil;
  end;

  // ������������� ������ ������
  if G.VG = 1 then
    G.Head := G.Tail;

end;

{ ��������� ���������� ���� � ���� }
procedure AddLink;
var
  Node: TPNode;
  i, Tmp: Integer;
begin

  // ��������� ����������� �������
  Node := GetByNumber(G, u);

  with Node^ do
  begin

    // ������������� ��������� �� ������
    if Tail = nil then
      New(Tail)
    else
    begin
      New(Tail.Next);
      Tail := Tail.Next;
    end;

    // ������������� ������ ������ �������
    if Head = nil then
      Head := Tail;

    // ���������� ������
    Tail.Elem := v;
    Tail.Next := nil;

  end;
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

end.
