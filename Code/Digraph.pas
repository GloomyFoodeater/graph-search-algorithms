unit Digraph;

interface

uses System.Types, DynStructures, System.SysUtils, ComObj, Variants, ActiveX,
  Math;

type

  // ��� ������������ ����� ������
  TDesign = (dgPassive, dgActive, dgVisited);

  // ��� ������ ���������
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
    Center: TPoint;
    Number: Integer;
    Head: TPNeighbour;
    Next: TPVertice;
    Deg: Integer;
    Design: TDesign;
  end;

  // ��� ��������������� ����
  TGraph = record
    Head: TPVertice;
    Tail: TPVertice;
    Order: Integer;
    isPainted: Boolean;
    R: Integer;
  end;

  { ��������� ������������� ����� }
procedure InitializeGraph(var G: TGraph);

{ ��������� �������� ����� }
procedure DestroyGraph(var G: TGraph);

{ ��������� ���������� ������� � ���� }
procedure AddVertice(var G: TGraph; const C: TPoint);

{ ��������� ���������� ���� � ���� }
procedure AddArc(var G: TGraph; v, u: Integer; w: Integer);

{ ��������� �������� ������� �� ����� }
procedure DeleteVertice(var G: TGraph; v: Integer);

{ ��������� �������� ���� �� ����� }
procedure DeleteArc(var G: TGraph; v, u: Integer);

{ ��������� ��������� ������� �� ������ }
procedure GetByNumber(const G: TGraph; v: Integer; out Vertice: TPVertice);

{ ��������� ���������� ������� �� ����� �� ������ }
function Centralize(const G: TGraph; const P: TPoint;
  out Vertice: TPVertice): Boolean;

// ������������ �������� ����� �� �������������� ������
procedure OpenGraph(var G: TGraph; VerFileName, ArcFileName: String);

// ������������ ���������� ����� � �������������� ����
procedure SaveGraph(var G: TGraph; VerFileName, ArcFileName: String);

// ������������ �������� ����� �� ������
procedure ImportFromExcel(var G: TGraph; FileName: String;
  Width, Height: Integer);

{ ������� ���������� ���������� ����� ����� ������� � �������� }
function Distance(const p1, p2: TPoint): Integer;

implementation

function AreAdjacent(const G: TGraph; Vertice: TPVertice; u: Integer): Boolean;
var
  Neighbour: TPNeighbour;
begin
  Result := false;

  if Vertice <> nil then
    Neighbour := Vertice.Head
  else
    Neighbour := nil;

  while not Result and (Neighbour <> nil) do
  begin
    Result := Neighbour.Number = u;
    Neighbour := Neighbour.Next;
  end;

end;

procedure DestroyAdjList(var Head: TPNeighbour);
var
  Neighbour: TPNeighbour;
begin
  while Head <> nil do
  begin
    Neighbour := Head;
    Head := Head.Next;
    Dispose(Neighbour);
  end;
  Head := nil;
end;

procedure AddVertice;
var
  Vertice: TPVertice;
begin
  Inc(G.Order);

  // ������������� ����� �������
  New(Vertice);
  with Vertice^ do
  begin
    Center := C;
    Number := G.Order;
    Head := nil;
    Next := nil;
    Deg := 0;
    Design := dgPassive;
  end;

  // ������ ����� �������
  if G.Head = nil then
    G.Head := Vertice
  else
    G.Tail.Next := Vertice;
  G.Tail := Vertice;

end;

procedure AddArc;
var
  Vertice, AdjVertice: TPVertice;
  Neighbour: TPNeighbour;
  isIncorrect: Boolean;
begin

  GetByNumber(G, v, Vertice);
  GetByNumber(G, u, AdjVertice);

  isIncorrect := AreAdjacent(G, Vertice, u) or AreAdjacent(G, AdjVertice, v);
  if not isIncorrect then
  begin

    Inc(Vertice.Deg);

    // ���������� ������ � ������ ���������
    New(Neighbour);
    Neighbour.Number := u;
    Neighbour.Weight := w;
    Neighbour.isVisited := false;
    Neighbour.Next := Vertice.Head;
    Vertice.Head := Neighbour;

  end;
end;

procedure DeleteVertice;
var
  PrevVertice, Vertice: TPVertice;
  PrevAdjVertice, Neighbour: TPNeighbour;
begin
  Dec(G.Order);

  if v = G.Head.Number then
  begin
    // �������� �������� �������
    Vertice := G.Head;
    G.Head := G.Head.Next;
  end
  else
  begin
    // �������� �� �������� �������
    GetByNumber(G, v - 1, PrevVertice);
    Vertice := PrevVertice.Next;
    PrevVertice.Next := Vertice.Next;
  end;

  // ������������ ������
  DestroyAdjList(Vertice.Head);
  Dispose(Vertice);

  // ���� �1. ������ �� �������� �����
  Vertice := G.Head;
  while Vertice <> nil do
  begin

    // ���������� ������� ������
    if Vertice.Number > v then
      Dec(Vertice.Number);

    // ��������� ������ ������
    if Vertice.Next = nil then
      G.Tail := Vertice;

    // ���� �2. ������ �� ������� �������
    PrevAdjVertice := nil;
    Neighbour := Vertice.Head;
    while Neighbour <> nil do
    begin

      // �������� ������ ������� �������
      if Neighbour.Number = v then
      begin
        if PrevAdjVertice = nil then
          Vertice.Head := Neighbour.Next
        else
          PrevAdjVertice.Next := Neighbour.Next;
        Dispose(Neighbour);
      end
      else if Neighbour.Number > v then
        Dec(Neighbour.Number); // ���������� ������ ������

      PrevAdjVertice := Neighbour;
      Neighbour := Neighbour.Next;
    end; // ����� �2
    Vertice := Vertice.Next;
  end; // ����� �1
end;

procedure DeleteArc;
var
  Vertice: TPVertice;
  Neighbour, PrevAdjVertice: TPNeighbour;
  isFound: Boolean;
begin

  // ��������� ������ ����
  GetByNumber(G, v, Vertice);

  if not AreAdjacent(G, Vertice, u) then
    Exit;

  Dec(Vertice.Deg);

  // ��������� ������� ������
  PrevAdjVertice := Vertice.Head;
  Neighbour := nil;

  // ����� ����� ����� ������ � ������� �������
  if (PrevAdjVertice = nil) or (PrevAdjVertice.Number = u) then
  begin
    if PrevAdjVertice <> nil then
      Vertice.Head := PrevAdjVertice.Next
    else
      Vertice.Head := nil;
  end
  else
  begin

    isFound := (PrevAdjVertice.Next.Number = u) or (PrevAdjVertice = nil);

    // ��������� ����������� ������ ����������
    while not isFound do
    begin
      PrevAdjVertice := PrevAdjVertice.Next;
      isFound := (PrevAdjVertice = nil) or (PrevAdjVertice.Next.Number = u);
    end;

    Neighbour := PrevAdjVertice.Next;
    PrevAdjVertice.Next := Neighbour.Next;
  end;

  // �������� ������
  if Neighbour <> nil then
  begin
    Dispose(Neighbour);
  end;

end;

procedure InitializeGraph;
begin
  G.Head := nil;
  G.Tail := nil;
  G.Order := 0;
  G.isPainted := false;
  G.R := 40;
end;

procedure DestroyGraph;
var
  Vertice: TPVertice;
begin

  // ���� �1. ������������ ������ ������
  while G.Head <> nil do
  begin
    Vertice := G.Head;

    // ���� �2. ������������ ������ ������� �������
    DestroyAdjList(Vertice.Head);

    G.Head := G.Head.Next;
    Dispose(Vertice);
  end; // ����� �1
end;

procedure GetByNumber;
begin
  Vertice := G.Head;
  while (Vertice <> nil) and (Vertice.Number <> v) do
    Vertice := Vertice.Next;
end;

function Centralize;
var
  Found: TPVertice;
begin

  Found := nil;
  Vertice := G.Head;

  // ���� �1. ����� ��������� ������� � �������� ������������
  while Vertice <> nil do
  begin
    if Distance(Vertice.Center, P) <= G.R then
      Found := Vertice;
    Vertice := Vertice.Next;
  end; // ����� �1

  Result := Found <> nil;
  Vertice := Found;

end;

procedure OpenGraph;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  VerFile: File of TVertice;
  ArcFile: File of TNeighbour;
  v: Integer;
begin

  // ���������� ������
  System.Assign(VerFile, VerFileName);
  System.Assign(ArcFile, ArcFileName);
  Reset(VerFile);
  Reset(ArcFile);

  InitializeGraph(G);
  New(Vertice);
  New(Neighbour);
  // ���� �1. ������ �� ����� ������
  while not Eof(VerFile) do
  begin

    // ������ ��������� �������
    Read(VerFile, Vertice^);
    AddVertice(G, Vertice.Center);

    // ���� �2. ��������� ������ �� ����� ����
    for v := 1 to Vertice.Deg do
    begin
      Read(ArcFile, Neighbour^);
      AddArc(G, Vertice.Number, Neighbour.Number, Neighbour.Weight);
    end; // ����� �2
  end; // ����� �1

  Dispose(Vertice);
  Dispose(Neighbour);

  // �������� ������
  CloseFile(VerFile);
  CloseFile(ArcFile);

end;

procedure SaveGraph;
var
  Vertice: TPVertice;
  Neighbour: TPNeighbour;
  VerFile: File of TVertice;
  ArcFile: File of TNeighbour;
begin

  // ���������� ������
  System.Assign(VerFile, VerFileName);
  System.Assign(ArcFile, ArcFileName);
  Rewrite(VerFile);
  Rewrite(ArcFile);

  // ���� �1. ������ �� ��������
  Vertice := G.Head;
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

procedure ImportFromExcel;
const
  ExcelApp = 'Excel.Application';
var
  MyExcel: Variant;
  Sheet: OLEVariant;
  ClassID: TCLSID;
  Rez: HRESULT;
  i, j, Rows, Cols: Integer;
  Weights: OLEVariant;
  w, ww: Integer;
  ImageCenter, VerticeCenter: TPoint;
  PolygonRadius: Integer;
  Angle: Real;
  isIncorrect: Boolean;
begin
  if CLSIDFromProgID(PWideChar(WideString(ExcelApp)), ClassID) = S_OK then
  begin
    // �������� ����������, ����� � �����
    Coinitialize(nil);
    MyExcel := CreateOleObject(ExcelApp);
    MyExcel.WorkBooks.Open(FileName);
    Sheet := MyExcel.ActiveWorkBook.ActiveSheet;

    // ��������� ������������� ��������� �����
    Rows := Sheet.UsedRange.Rows.Count;
    Cols := Sheet.UsedRange.Columns.Count;
    if Rows <> Cols then
      raise Exception.Create('������� ���������� �� ���� ����������.');
    Weights := Sheet.UsedRange.Value;

    // ���������� �����
    try
      Angle := 0;
      PolygonRadius := Min(Width, Height) div 2 - 40;
      ImageCenter.X := Width div 2;
      ImageCenter.Y := Height div 2;
      InitializeGraph(G);
      for i := 1 to Rows do
      begin
        VerticeCenter.X := ImageCenter.X + trunc(PolygonRadius * sin(Angle));
        VerticeCenter.Y := ImageCenter.Y - trunc(PolygonRadius * cos(Angle));
        AddVertice(G, VerticeCenter);
        for j := 1 to Cols do
        begin
          w := StrToInt(VarToStr(Weights[i, j]));
          ww := StrToInt(VarToStr(Weights[j, i]));

          // �������� �� ������������ ����
          isIncorrect := (i = j) and (w <> 0) or (w < 0) or (w > 0) and
            (ww <> 0);
          if isIncorrect then
            raise Exception.Create('������� ������������ ����.');

          // ���������� ������������ ����
          if w <> 0 then
            AddArc(G, i, j, w);
        end;
        Angle := Angle + 2 * pi / Rows;
      end;
    finally
      MyExcel.Quit;
      MyExcel := Unassigned;
      CoUninitialize;
    end;
  end;
end;

function Distance;
begin
  Result := Round(Sqrt(Sqr(p2.X - p1.X) + Sqr(p2.Y - p1.Y)));
end;

end.
