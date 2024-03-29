unit Digraph;
{
  ������ � ������ � ��������������
  ��� ������� �� ���������� �����.
}

interface

uses System.Types, System.SysUtils, Math, ComObj, Variants,
  ActiveX;

type

  // ��� ����� ��������� �������
  TVerticeStyle = (stPassive, stActive, stVisited);

  // ��� ������ ��������� �����
  TPNeighbour = ^TNeighbour;

  TNeighbour = record
    Number: Integer;
    Weight: Integer;
    isVisited: Boolean;
    Next: TPNeighbour;
  end;

  // ��� ������� �����
  TPVertice = ^TVertice;

  TVertice = record
    Number: Integer;
    Center: TPoint;
    OutDeg: Integer;
    Style: TVerticeStyle;
    Head: TPNeighbour;
    Next: TPVertice;
  end;

  // ��� ���������������� �����
  TGraph = record
    Head: TPVertice;
    Tail: TPVertice;
    Order: Integer;
    isPainted: Boolean;
    R: Integer;
  end;

  // ������������ ������������� �����
procedure InitializeGraph(var Graph: TGraph);

// ������������ �������� �����
procedure DestroyGraph(var Graph: TGraph);

// ������������ ���������� ������� � ����
procedure AddVertice(var Graph: TGraph; C: TPoint);

// ������������ ���������� ���� � ����
procedure AddArc(var Graph: TGraph; v, u, w: Integer);

// ������������ �������� ������� �� �����
procedure DeleteVertice(var Graph: TGraph; v: Integer);

// ������������ �������� ���� �� �����
procedure DeleteArc(var Graph: TGraph; v, u: Integer);

// ������������ ��������� ������� �� � ������
function GetByNumber(const Graph: TGraph; v: Integer): TPVertice;

// ������������ ��������� ������� �� ����� �� ������
function GetByPoint(const Graph: TGraph; P: TPoint): TPVertice;

// ������������ �������� ����� �� �������������� ������
procedure OpenGraph(var Graph: TGraph; VerFileName, ArcFileName: String);

// ������������ ���������� ����� � �������������� �����
procedure SaveGraph(const Graph: TGraph; VerFileName, ArcFileName: String);

// ������������ �������� ����� �� ������
procedure ImportGraph(var Graph: TGraph; ExcelFileName: String);

implementation

procedure DestroyAdjList(var Head: TPNeighbour);
var
  Neighbour: TPNeighbour;
  // Neighbour - ������ �� ���������� ������

begin

  // ���� �1. ������ �� ������ ���������
  while Head <> nil do
  begin
    Neighbour := Head;
    Head := Head.Next;
    Dispose(Neighbour);
  end; // ����� �1
end;

procedure InitializeGraph(var Graph: TGraph);
begin
  with Graph do
  begin
    Head := nil;
    Tail := nil;
    Order := 0;
    isPainted := false;
    R := 40;
  end;
end;

procedure DestroyGraph(var Graph: TGraph);
var
  Vertice: TPVertice;
  // Vertice - ������ �� ��������� �������

begin

  // ���� �1. ������ �� ������ ������
  while Graph.Head <> nil do
  begin
    Vertice := Graph.Head;
    DestroyAdjList(Vertice.Head);
    Graph.Head := Graph.Head.Next;
    Dispose(Vertice);
  end; // ����� �1
end;

// ������������ �������� ��������� ������
function IsNeighbour(const Graph: TGraph; Vertice: TPVertice;
  u: Integer): Boolean;
var
  Neighbour: TPNeighbour;
  // Neighbour - ������ �� ����� � ������� u

begin
  Result := false;

  // AddArc ����� �������� nil �� ����� ������/������� �� �����
  if Vertice <> nil then
    Neighbour := Vertice.Head
  else
    Neighbour := nil;

  // ���� �1. ������ �� ������ ���������
  while not Result and (Neighbour <> nil) do
  begin
    Result := Neighbour.Number = u;
    Neighbour := Neighbour.Next;
  end; // ����� �1

end;

procedure AddVertice(var Graph: TGraph; C: TPoint);
var
  Vertice: TPVertice;
  // Vertice - ������ �� ����������� �������

begin
  Inc(Graph.Order); // ���������� �������

  // ������������� ����� �������
  New(Vertice);
  with Vertice^ do
  begin
    Center := C;
    Number := Graph.Order;
    Head := nil;
    Next := nil;
    OutDeg := 0;
    Style := stPassive;
  end;

  // ������ ����� �������
  if Graph.Head = nil then
    Graph.Head := Vertice
  else
    Graph.Tail.Next := Vertice;
  Graph.Tail := Vertice;

end;

procedure AddArc(var Graph: TGraph; v, u, w: Integer);
var
  Vertice, AdjVertice: TPVertice;
  Neighbour: TPNeighbour;
  isIncorrect: Boolean;
  // Vertice - ������ �� ������� v
  // AdjVertice - ������ �� ������� u
  // Neighbour - ������ �� ������������ ������
  // isIncorrect - ���� �� ���������� ������� ��� � ������

begin

  // ��������� ������ �� ������� v � u
  Vertice := GetByNumber(Graph, v);
  AdjVertice := GetByNumber(Graph, u);

  // �������� ������������ ����� � ������ ���������� ����
  isIncorrect := (v = u) or IsNeighbour(Graph, Vertice, u) or
    IsNeighbour(Graph, AdjVertice, v);
  if not isIncorrect then
  begin

    Inc(Vertice.OutDeg);

    // ���������� ������ � ������ ���������
    New(Neighbour);
    with Neighbour^ do
    begin
      Number := u;
      Weight := w;
      isVisited := false;
      Next := Vertice.Head;
    end;
    Vertice.Head := Neighbour;
  end;
end;

procedure DeleteVertice(var Graph: TGraph; v: Integer);
var
  Vertice, PrVertice: TPVertice;
  Neighbour, PrNeighbour: TPNeighbour;
  Exists: Boolean;
  // Vertice - ������ �� �������� �������
  // PrVertice - ������ �� ������� ����� Vertice
  // Neighbour - ������ �� �������� ������
  // PrNeighbour - ������ �� ������ ����� Neighbour
  // Exists - ���� � ������� �������

begin

  // �������� �������
  if v <> Graph.Head.Number then
  begin
    PrVertice := GetByNumber(Graph, v - 1);
    Exists := (PrVertice <> nil) and (PrVertice.Next <> nil);
    if Exists then
    begin
      Vertice := PrVertice.Next;
      PrVertice.Next := Vertice.Next;
    end;
  end
  else
  begin

    // ��������� ������ ������
    Vertice := Graph.Head;
    Graph.Head := Vertice.Next;
    Exists := true;
  end;

  if Exists then
  begin
    Dec(Graph.Order);

    // ������������ ������
    DestroyAdjList(Vertice.Head);
    Dispose(Vertice);

    // ���� �1. ������ �� �������� �����
    Vertice := Graph.Head;
    while Vertice <> nil do
    begin

      // ���������� ������� ������
      if Vertice.Number > v then
        Dec(Vertice.Number);

      // ��������� ������ ������ ������
      if Vertice.Next = nil then
        Graph.Tail := Vertice;

      // ���� �2. ������ �� ������� �������
      PrNeighbour := nil;
      Neighbour := Vertice.Head;
      while Neighbour <> nil do
      begin

        // �������� ������ ������� �������
        if Neighbour.Number = v then
        begin
          if PrNeighbour = nil then
            Vertice.Head := Neighbour.Next
          else
            PrNeighbour.Next := Neighbour.Next;
          Dispose(Neighbour);
        end
        else if Neighbour.Number > v then
          Dec(Neighbour.Number); // ���������� ������ ������

        // ������� � ���������� ������
        PrNeighbour := Neighbour;
        Neighbour := Neighbour.Next;
      end; // ����� �2

      // ������� � ��������� �������
      Vertice := Vertice.Next;
    end; // ����� �1
  end; // ����� if
end;

procedure DeleteArc(var Graph: TGraph; v, u: Integer);
var
  Vertice: TPVertice;
  Neighbour, PrNeighbour: TPNeighbour;
  Exists: Boolean;
  // Vertice - ������ �� �������-������ ����
  // Neighbour - ������ �� ������� ��� �������� �����
  // PrNeighbour - ������ �� ������ ����� Neighbour
  // Exists - ���� � ������� ����

begin

  // ��������� ������ ����
  Vertice := GetByNumber(Graph, v);

  Exists := IsNeighbour(Graph, Vertice, u);
  if Exists then
  begin

    // ���� �1. ������ �� ������ ���������
    PrNeighbour := nil;
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin

      // ��������� ������� �������� � ���������� ������
      if u = Neighbour.Number then
      begin
        Dec(Vertice.OutDeg);

        // �������� ������ �� ������ ���������
        if u = Vertice.Head.Number then
          Vertice.Head := Neighbour.Next
        else
          PrNeighbour.Next := Neighbour.Next;
        Dispose(Neighbour);
        Neighbour := nil;
      end // ����� if
      else
      begin

        // ������� � ���������� ������
        PrNeighbour := Neighbour;
        Neighbour := Neighbour.Next;
      end; // ����� else
    end; // ����� �1
  end; // ����� if
end;

function GetByNumber(const Graph: TGraph; v: Integer): TPVertice;
begin

  // ���� �1. ������ �� ������ ������
  Result := Graph.Head;
  while (Result <> nil) and (Result.Number <> v) do
    Result := Result.Next;
end;

function GetByPoint(const Graph: TGraph; P: TPoint): TPVertice;
var
  Vertice: TPVertice;
  // Vertice - ������ �� ������� ������� �����

begin

  // ���� �1. ����� ��������� ������� � �������� ������������
  Result := nil;
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin

    // �������� �������������� ���������� ������� Graph.R
    if P.Distance(Vertice.Center) <= Graph.R then
      Result := Vertice;
    Vertice := Vertice.Next;
  end; // ����� �1
end;

procedure OpenGraph(var Graph: TGraph; VerFileName, ArcFileName: String);
var
  VerFile: File of TVertice;
  ArcFile: File of TNeighbour;
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  v: Integer;
  // VerFile - �������������� ���� ������
  // ArcFile - �������������� ���� �������
  // Vertice - ������ �� ������� �������
  // Neighbour - ������ �� �������� ������
  // v - �������� ����� �� �������

begin

  // ���������� ������
  Assign(VerFile, VerFileName);
  Assign(ArcFile, ArcFileName);
  Reset(VerFile);
  Reset(ArcFile);

  // ������������� �����, ��������� �� ������� � ������
  InitializeGraph(Graph);
  New(Vertice);
  New(Neighbour);

  // ���� �1. ������ �� ����� ������
  while not Eof(VerFile) do
  begin

    // ������ ��������� �������
    Read(VerFile, Vertice^);
    AddVertice(Graph, Vertice.Center);

    // ���� �2. ��������� ������ �� ����� �������
    for v := 1 to Vertice.OutDeg do
    begin

      // ������ ���������� ������
      Read(ArcFile, Neighbour^);
      AddArc(Graph, Vertice.Number, Neighbour.Number, Neighbour.Weight);
    end; // ����� �2
  end; // ����� �1

  // ������������ ������
  Dispose(Vertice);
  Dispose(Neighbour);

  // �������� ������
  CloseFile(VerFile);
  CloseFile(ArcFile);
end;

procedure SaveGraph(const Graph: TGraph; VerFileName, ArcFileName: String);
var
  VerFile: File of TVertice;
  ArcFile: File of TNeighbour;
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  // VerFile - �������������� ���� ������
  // ArcFile - �������������� ���� �������
  // Vertice - ������ �� ������� �������
  // Neighbour - ������ �� �������� ������

begin

  // ���������� ������
  Assign(VerFile, VerFileName);
  Assign(ArcFile, ArcFileName);
  Rewrite(VerFile);
  Rewrite(ArcFile);

  // ���� �1. ������ �� ��������
  Vertice := Graph.Head;
  while Vertice <> nil do
  begin
    Write(VerFile, Vertice^);

    // ���� �2. ������ �� �������
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin
      Write(ArcFile, Neighbour^);
      Neighbour := Neighbour.Next;
    end; // ����� �1
    Vertice := Vertice.Next;
  end; // ����� �2

  // �������� ������
  CloseFile(VerFile);
  CloseFile(ArcFile);
end;

procedure ImportGraph(var Graph: TGraph; ExcelFileName: String);
const
  ExcelApp = 'Excel.Application';
  VerticeCenter: TPoint = (x: 0; y: 0);
var
  MyExcel: Variant;
  Sheet, Weights: OLEVariant;
  CLSID: TCLSID;
  i, j, Rows, Cols: Integer;
  w, ww: Integer;
  isIncorrect: Boolean;
  // MyExcel - ������ Excel
  // Sheet - ������ ��������� ����� �����
  // Weights - ������ ��������� �����
  // CLSID  - �������������, ������������ ��� COM-�������
  // i, j - ��������� ������ �� ������� � �������� ���������
  // Rows, Cols - ���������� ����� � �������� ���������
  // w, ww - ������������ � ��������� ������
  // VerticeCenter - ����� ��������� ������� �� ������
  // isIncorrect - ���� � ������������� ������������ ���

begin

  // �������� ������� Excel �� ����������
  if CLSIDFromProgID(PWideChar(WideString(ExcelApp)), CLSID) = S_OK then
  begin

    // �������� ����������, ����� � �����
    CoInitialize(nil);
    MyExcel := CreateOleObject(ExcelApp);
    MyExcel.WorkBooks.Open(ExcelFileName);
    Sheet := MyExcel.ActiveWorkBook.ActiveSheet;

    // ��������� ������������� ��������� �����
    Rows := Sheet.UsedRange.Rows.Count;
    Cols := Sheet.UsedRange.Columns.Count;
    if Rows <> Cols then
      raise Exception.Create('������� ���������� �� ���� ����������.');
    Weights := Sheet.UsedRange.Value;

    // ���������� �����
    try

      // ���� �1. ������ �� ������� ���������
      InitializeGraph(Graph); // ������������� �����
      for i := 1 to Rows do
      begin

        // ���������� �������
        AddVertice(Graph, VerticeCenter);

        // ���� �2. ������ �� �������� ���������
        for j := 1 to Cols do
        begin

          // ��������� ����� � ������������ �������
          w := StrToInt(VarToStr(Weights[i, j]));
          ww := StrToInt(VarToStr(Weights[j, i]));

          // �������� �� ������������ ����
          isIncorrect := (i = j) and (w <> 0) or (w < 0) or (w > 0) and
            (ww <> 0);
          if isIncorrect then
            raise Exception.Create('������� ������������ ����.');

          // ���������� ������������ ����
          if w <> 0 then
            AddArc(Graph, i, j, w);
        end; // ����� A2
      end; // ����� A1
    finally

      // ����� �� Excel
      MyExcel.Quit;
      MyExcel := Unassigned;
      CoUninitialize;
    end; // ����� if
  end;
end;

end.
