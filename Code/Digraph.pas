unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils;

const
  INFINITY = MaxInt;

type

  // ��� ������ ���������
  TAdjList = TPList;

  // ��� ������� �����
  TPNode = ^TNode;

  TNode = record
    Center: TPoint;
    Number: Cardinal;
    Head: TAdjList;
    Next: TPNode;
  end;

  // ��� ������� ����
  TGraph = record
    Head: TPNode;
    Tail: TPNode;
    Order: Cardinal;
  end;

  TAdjMatrix = array of array of Integer;

function GetByNumber(const G: TGraph; u: Integer): TPNode;

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

{ ��������� �������������� ����� � ������� ��������� }
procedure ToAdjMatrix(const G: TGraph; var Matrix: TAdjMatrix);

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
  while (Result <> nil) and (Result.Number <> u) do
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
  if Node <> nil then
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
var
  PrNode, Node: TPNode;
  PrNeighbour, Neighbour: TPList;

begin

  // �������� ������������ ���������� ������
  if (u < 1) or (u > G.Order) then
    Exit;
  Dec(G.Order);

  // ���� �1. ������ �� ��������
  PrNode := nil;
  Node := G.Head;
  while Node <> nil do
  begin

    // �������� ������ �������
    if Node.Number = u then
    begin

      // �������������� ����������� ���������
      if PrNode = nil then
        G.Head := Node.Next
      else
        PrNode.Next := Node.Next;

      // ������������ ������ ���������
      DestroyList(Node.Head);
      Dispose(Node);
    end // ����� if
    else
    begin

      // ���������� ���� ������, ������� ��������� �� 1
      if Node.Number > u then
        Dec(Node.Number);

      // ���� �2. ������ �� ������� �������
      PrNeighbour := nil;
      Neighbour := Node.Head;
      while Neighbour <> nil do
      begin

        // �������� ������ ������
        if Neighbour.Elem = u then
        begin

          // �������������� ����������� ���������
          if PrNeighbour = nil then
            Node.Head := Neighbour.Next
          else
            PrNeighbour.Next := Neighbour.Next;

          // ������������ ������ ����� ������
          Dispose(Neighbour);
        end // ����� if
        else if Neighbour.Elem > u then
          Dec(Neighbour.Elem);

        // ������� � ���������� ������
        PrNeighbour := Neighbour;
        Neighbour := Neighbour.Next;

      end; // ����� �2

    end; // ����� else

    // ������� � ��������� �������
    if Node.Next <> nil then
      PrNode := Node;
    Node := Node.Next;
  end; // ����� �1

  // �������������� ������ ������
  G.Tail := PrNode;
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
    if DelNeighbour <> nil then
      Node.Head := DelNeighbour.Next
    else
      Node.Head := nil;
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
begin

  // ���� �1. ������������ ������ ������
  while G.Head <> nil do
  begin
    Node := G.Head;

    // ���� �2. ������������ ������ ������� �������
    DestroyList(Node.Head);

    G.Head := G.Head.Next;
    Dispose(Node);
  end; // ����� �1
end;

procedure ToAdjMatrix;
var
  i: Integer;
  Node: TPNode;
  Neighbour: TPList;
  j: Integer;
begin

  // ������������� �������
  SetLength(Matrix, G.Order, G.Order);

  // ���� �1. ������ �� ��������
  Node := G.Head;
  for i := 0 to G.Order - 1 do
  begin

    // ���� �2. ������ �� �������
    Neighbour := Node.Head;
    for j := 0 to G.Order - 1 do
    begin

      // �������� ��������� ������
      if (Neighbour <> nil) and (Neighbour.Elem = j + 1) then
      begin

        // ������� ���� ������
        Matrix[i, j] := 1;

        // ������� � ���������� ������
        Neighbour := Neighbour.Next;
      end
      else
        Matrix[i, j] := INFINITY;
      // ������� �� ���� ��������
    end; // ����� �2
    Matrix[i, i] := 0;

    // ������� � ��������� �������
    Node := Node.Next;
  end; // ����� �1
end;

end.
