unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    AddNodeBtn: TSpeedButton;
    AddLinkBtn: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    procedure FormClick(Sender: TObject);
    procedure AddNodeBtnClick(Sender: TObject);
    procedure AddLinkBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  // ��� ������ ������ � ������
  TClickState = (stAddNode, stAddLink, stDeleteNode, stDeleteLink, stDFS, stBFS,
    stDijkstra, stNone);

  // ��� ������ ���������
  TPNode = ^TNode;

  TNode = record
    AdjNode: Integer;
    Next: TPNode;
  end;

  // ��� ������� ����
  TPGraph = ^TGraph;

  TGraph = record
    Center: TPoint;
    NodeHead: TPNode;
    NodeTail: TPNode;
    Next: TPGraph;
  end;

var
  Form1: TForm1;
  NodeCounter: Integer;
  State: TClickState;
  GraphHead: TPGraph;
  GraphTail: TPGraph;
  StartNode: Integer;

implementation

{$R *.dfm}

{ ������� ���������� ������� �� ������ � ������ }
function GetByNumber(const Head: TPGraph; v: Integer): TPGraph;
var
  i: Integer;
begin
  Result := Head;
  for i := 1 to v - 1 do
  begin
    Result := Result.Next;
  end;

end;

{ ������� ���������� ������� �� ����� �� ������ }
function GetByPoint(const Head: TPGraph; P: TPoint): Integer;
var
  Node: TPGraph;
  isFound: Boolean;
  x, y: Integer;
begin
  Result := 0;
  Node := Head;
  isFound := false;
  while not isFound and (Node <> nil) do
  begin
    x := Node.Center.x;
    y := Node.Center.y;
    isFound := Sqr(x - P.x) + Sqr(y - P.y) <= Sqr(20);
    Node := Node.Next;
    Inc(Result);
  end;
  if not isFound then
    Result := 0;
end;

{ ��������� ���������� ��������� ������ ����� �� ������ }
procedure GetLinkPoints(c1, c2: TPoint; var p1, p2: TPoint);
var
  d: Integer;
begin
  d := Round(Sqrt(Sqr(c2.x - c1.x) + Sqr(c2.y - c1.y)));

  p1.x := Round(c1.x + 20 * (c2.x - c1.x) / d);
  p1.y := Round(c1.y + 20 * (c2.y - c1.y) / d);

  p2.x := Round(c2.x + 20 * (c1.x - c2.x) / d);
  p2.y := Round(c2.y + 20 * (c1.y - c2.y) / d);
end;

{ ��������� ���������� ������� � ���� }
procedure AddNode(var Tail: TPGraph; const Center: TPoint);
begin

  // ������������� ��������� �� ����� �������
  if Tail = nil then
    New(Tail)
  else
  begin
    New(Tail.Next);
    Tail := Tail.Next
  end;

  // ���������� ����� �������
  Tail.Center := Center;
  Tail.NodeHead := nil;
  Tail.NodeTail := nil;
  Tail.Next := nil;

end;

{ TODO 4 : ����������� � ������� ������ }
{ ��������� ��������� ������� ����� }
procedure DrawNode(v: Integer; Center: TPoint);
var
  Caption: String; // ��� �������
  PosX: Integer; // ����� ������� ���� ������
  vCopy: Integer; // ����� ������ �������
begin

  // ��������� ����� ������� � ��� x-����������
  Str(v, Caption);
  vCopy := v;
  PosX := Center.x;
  while vCopy <> 0 do
  begin
    vCopy := vCopy div 10;
    PosX := PosX - 4;
  end;

  // ����� �����
  Form1.Canvas.Ellipse(Center.x - 20, Center.y - 20, Center.x + 20,
    Center.y + 20);

  // ����� ����� �������
  Form1.Canvas.TextOut(PosX + 1, Center.y - 6, Caption);
end;

{ TODO 1: ��������� ���� ���������� ���� }
{ ��������� ���������� ���� � ���� }
procedure AddLink(var Head: TPGraph; v, u: Integer);
var
  Node: TPGraph;
  i, Tmp: Integer;
begin
  Tmp := v;
  for i := 1 to 2 do
  begin
    Node := GetByNumber(Head, v); // ��������� ����������� �������

    with Node^ do
    begin

      // ������������� ��������� �� ������
      if NodeTail = nil then
        New(NodeTail)
      else
      begin
        New(NodeTail.Next);
        NodeTail := NodeTail.Next;
      end;

      // ������������� ������ ������ �������
      if NodeHead = nil then
        NodeHead := NodeTail;

      // ���������� ������
      NodeTail.AdjNode := u;
      NodeTail.Next := nil;

    end;

    // ������� � ������ ����������� �������
    v := u;
    u := Tmp;
  end;

end;

{ ��������� ��������� ����� ����� }
procedure DrawLink(Head: TPGraph; v, u: Integer);
var
  Center1, Center2: TPoint;
  d: Integer;
  Point1, Point2: TPoint;
begin
  Center1 := GetByNumber(Head, v).Center;
  Center2 := GetByNumber(Head, u).Center;
  GetLinkPoints(Center1, Center2, Point1, Point2);
  Form1.Canvas.MoveTo(Point1.x, Point1.y);
  Form1.Canvas.LineTo(Point2.x, Point2.y);
end;

// ������� ������� �� �����
procedure TForm1.FormClick(Sender: TObject);
var
  Pos: TPoint;
  EndNode: Integer;
begin
  // ��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);
  Form1.Canvas.Pen.Color := clBlack;
  case State of
    stAddNode: // ���������� ������� �����
      begin
        Inc(NodeCounter);
        AddNode(GraphTail, Pos);

        // ������������� ������ ������
        if NodeCounter = 1 then
          GraphHead := GraphTail;

        DrawNode(NodeCounter, Pos);
      end;
    stAddLink:
      begin
        if StartNode = 0 then
        begin
          StartNode := GetByPoint(GraphHead, Pos);
        end
        else
        begin
          EndNode := GetByPoint(GraphHead, Pos);
          if EndNode <> 0 then
          begin
            // TODO 1: ��������� ������� ����� ����� � �����
            { TODO 3: ���������� ��������� �� ������ �������:
              ����� ��� AddLink, ���� ������ �� ����������� }
            AddLink(GraphHead, StartNode, EndNode);
            DrawLink(GraphHead, StartNode, EndNode);
            StartNode := 0;
          end;
        end;
      end;
    stDeleteNode:
      begin

      end;
    stDeleteLink:
      begin

      end;
    stDFS:
      begin

      end;
    stBFS:
      begin

      end;
    stDijkstra:
      begin

      end;
  end;
end;

{ TODO 2 : �������� ������������ ������ ��� �������� }
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  pNode: TPGraph;
  pAdjNode: TPNode;
begin

  // ���� �1. ������������ ������ ������
  while GraphHead <> nil do
  begin
    pNode := GraphHead;

    // ���� �2. ������������ ������ ������� �������
    while pNode.NodeHead <> nil do
    begin
      pAdjNode := pNode.NodeHead;
      pNode.NodeHead := pNode.NodeHead.Next;
      Dispose(pAdjNode);
    end; // ����� �2

    GraphHead := GraphHead.Next;
    Dispose(pNode);
  end; // ����� �1
end;

procedure TForm1.AddLinkBtnClick(Sender: TObject);
begin
  if AddLinkBtn.Down then
    State := stAddLink
  else
    State := stNone;
end;

procedure TForm1.AddNodeBtnClick(Sender: TObject);
begin
  if AddNodeBtn.Down then
    State := stAddNode
  else
    State := stNone;
end;

end.
