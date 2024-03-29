unit GraphSearch;
{
  ������ � ��������������,
  ������������ ���������������
  ��������� ������ �� ������.
}

interface

uses SysUtils, Digraph, DynamicStructures;

type
  // ��� ������� �����
  TWeightMatrix = array of array of Integer;

  // ��� ���������� � ������
  TSearchInfo = record
    Path: TStack;
    PathString: String;
    ArcsCount: Integer;
    Distance: Integer;
    VisitsCount: Integer;
  end;

  // ������������ �������������� ����� � ������� �����
function ToWeightMatrix(const Graph: TGraph): TWeightMatrix;

// ������������ ������ � �������
function DFS(const Graph: TWeightMatrix; Src, Dest: Integer): TSearchInfo;

// ������������ ������ � ������
function BFS(const Graph: TWeightMatrix; Src, Dest: Integer): TSearchInfo;

// ������������ ������ ���������� ��������
function Dijkstra(const Graph: TWeightMatrix; Src, Dest: Integer): TSearchInfo;

implementation

const
  INF = 1000000000;

  // ������������ �������������� ����
function RestorePath(const Graph: TWeightMatrix;
  const Parents: array of Integer; const Src, Dest: Integer): TSearchInfo;
const
  Splitter = ', ';
  // Splitter - ����������� ����� ��������� � ������ ����

var
  v, u, w: Integer;
  // v - ����� �������-������ ����
  // u - ����� �������-����� ����

begin
  with Result do
  begin

    // ������������� ��������� ��������
    PathString := '';
    InitializeStack(Path);
    ArcsCount := 0;
    Distance := 0;

    // �������� ������������� ���� ��� ���� �� 1 �������
    if (Parents[Dest - 1] <> 0) or (Src = Dest) then
    begin

      // ���� �1. ������ �� ������� �������
      u := Dest;
      while u <> Src do
      begin
        v := Parents[u - 1];

        // ��������� ���������� � ����
        Push(Path, u);
        PathString := Splitter + IntToStr(u) + PathString;
        Inc(ArcsCount);
        Distance := Distance + Graph[v - 1, u - 1];

        // ������� � ��������� �������
        u := v;
      end; // ����� �1

      // ���������� ������ ����
      Push(Path, Src);
      PathString := IntToStr(u) + PathString;
    end;
  end;
end;

function DFS(const Graph: TWeightMatrix; Src, Dest: Integer): TSearchInfo;
var
  v, u: Integer;
  Order: Integer;
  Stack: TStack;
  isVisited: Array of Boolean;
  Parents: Array of Integer;
  // v - ����� ���������� �������
  // u - ����� ������ �������
  // Order - ������� �����
  // Stack - ���� ������
  // isVisited - ������ ������
  // Parents - ������ �������

begin
  Result.VisitsCount := 0;

  // ������������� ��������������� ������
  Order := Length(Graph);
  InitializeStack(Stack);
  SetLength(isVisited, Order);
  SetLength(Parents, Order);
  for v := 1 to Order do
  begin
    Parents[v - 1] := 0;
    isVisited[v - 1] := False;
  end;

  // ���� �1. ��������� ������ � �����
  Push(Stack, Src);
  while Stack <> nil do
  begin

    // ��������� ������� � ��������� � ��������
    v := Pop(Stack);
    Inc(Result.VisitsCount);
    if v = Dest then
    begin
      DestroyList(Stack);
      isVisited[v - 1] := true;
    end;

    // ���������� � ���� �������
    if not isVisited[v - 1] then
    begin
      isVisited[v - 1] := true;

      // ���� �2. ���������� � ���� ������������ �������
      for u := Order downto 1 do
      begin
        if not isVisited[u - 1] and (Graph[v - 1, u - 1] <> INF) then
        begin
          Parents[u - 1] := v; // ���������� ����
          Push(Stack, u);
        end; // ����� if
      end; // ����� �2
    end; // ����� if
  end; // ����� �1

  // �������������� ����
  Result := RestorePath(Graph, Parents, Src, Dest);
end;

function BFS(const Graph: TWeightMatrix; Src, Dest: Integer): TSearchInfo;
var
  v, u: Integer;
  Order: Integer;
  Queue: TQueue;
  isVisited: Array of Boolean;
  Parents: Array of Integer;
  // v - ����� ���������� �������
  // u - ����� ������ �������
  // Order - ������� �����
  // Stack - ���� ������
  // isVisited - ������ ������
  // Parents - ������ �������

begin
  Result.VisitsCount := 0;

  // ������������� ��������������� ������
  Order := Length(Graph);
  InitializeQueue(Queue);
  SetLength(isVisited, Order);
  SetLength(Parents, Order);
  for v := 1 to Order do
  begin
    Parents[v - 1] := 0;
    isVisited[v - 1] := False;
  end;

  // ���� �1. ��������� ������ � �������
  Enqueue(Queue, Src);
  isVisited[Src - 1] := true;
  while Queue.Head <> nil do
  begin

    // ��������� ������� � ��������� � ��������
    v := Dequeue(Queue);
    Inc(Result.VisitsCount);
    if v = Dest then
    begin
      DestroyList(Queue.Head);
      Order := 0; // ��������� ������� ����� � �2
    end;

    // ���� �2. ���������� � ���� ������� �������
    for u := 1 to Order do
    begin
      if not isVisited[u - 1] and (Graph[v - 1, u - 1] <> INF) then
      begin
        isVisited[u - 1] := true;
        Parents[u - 1] := v;
        Enqueue(Queue, u);
      end; // ����� if
    end; // ����� �2
  end; // ����� �1

  // �������������� ����
  Result := RestorePath(Graph, Parents, Src, Dest);
end;

function Dijkstra(const Graph: TWeightMatrix; Src, Dest: Integer): TSearchInfo;
var
  v, u: Integer;
  Order: Integer;
  Marks: Array of Integer;
  isVisited: Array of Boolean;
  Parents: Array of Integer;
  d: Integer;
  // v - ����� ���������� �������
  // u - ����� ������ �������
  // Order - ������� �����
  // Marks - ������ �����
  // isVisited - ������ ������
  // Parents - ������ �������
  // d - ����� ���������� �������

begin
  Result.VisitsCount := 0;

  // ������������� ��������������� ������
  Order := Length(Graph);
  SetLength(Marks, Order);
  SetLength(isVisited, Order);
  SetLength(Parents, Order);
  for u := 1 to Order do
  begin
    Marks[u - 1] := INF;
    Parents[u - 1] := 0;
    isVisited[u - 1] := False;
  end;
  Marks[Src - 1] := 0;

  // ���� �1. ��������� ������ � ������������ �������
  repeat

    // ���� �2. ����� ���. ����� � ������������ ������
    d := INF;
    for u := 1 to Order do
    begin
      if not isVisited[u - 1] and (Marks[u - 1] < d) then
      begin
        d := Marks[u - 1];
        v := u;
      end; // ����� if
    end; // ����� �2

    // ��������� ��������� �������
    if d <> INF then
    begin
      isVisited[v - 1] := true;
      Inc(Result.VisitsCount);
    end
    else
      Order := 0; // ��������� ������� ����� � �3

    // ��������� � �������� ��������
    if v = Dest then
    begin
      d := INF; // ����� �� �1
      Order := 0; // ��������� ������� ����� � �3
    end;

    // ���� �3. ���������� �����
    for u := 1 to Order do
    begin
      if not isVisited[u - 1] and (Marks[u - 1] > d + Graph[v - 1, u - 1]) then
      begin
        Parents[u - 1] := v; // ���������� ����
        Marks[u - 1] := d + Graph[v - 1, u - 1];
      end; // ����� if
    end; // ����� �3

  until d = INF; // ����� �1

  // �������������� ����
  Result := RestorePath(Graph, Parents, Src, Dest);
end;

function ToWeightMatrix(const Graph: TGraph): TWeightMatrix;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  v, u: Integer;
  // Vertice - ������ �� ������� �������
  // Neighbour - ������ �� �������� ������
  // v - �������� ����� �� ��������
  // u - �������� ����� �� �������

begin
  SetLength(Result, Graph.Order, Graph.Order);

  // ���� �1. ������ �� �������
  for v := 1 to Graph.Order do

    // ���� �2. ������ �� ��������
    for u := 1 to Graph.Order do
      Result[v - 1, u - 1] := INF;

  // ���� �3. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin
    v := Vertice.Number;

    // ���� A4. ������ �� �������
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      u := Neighbour.Number;
      Result[v - 1, u - 1] := Neighbour.Weight;
      Neighbour := Neighbour.Next;
    end; // ����� A4

    Vertice := Vertice.Next;
  end; // ����� A3
end;

end.
