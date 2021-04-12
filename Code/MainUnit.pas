unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, Digraph;

{ TODO 3: ������ ����� ������������ Image ��� ���������,
  ����� �� �������� ������� ��� ������������ ����� }
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

var
  Form1: TForm1;
  State: TClickState;
  G: TGraph;
  StartNode: TPNode;

implementation

{$R *.dfm}

// TODO 4: �������� ���������� �������
{ ��������� ���������� ��������� ������ ����� �� ������ }
procedure GetLinkPoints(c1, c2: TPoint; var p: Array of TPoint);
var
  d: Integer;
begin
  d := Distance(c1, c2);

  p[0].x := Round(c2.x + 20 * (c1.x - c2.x) / d);
  p[0].y := Round(c2.y + 20 * (c1.y - c2.y) / d);

  p[1].x := Round(c1.x + 20 * (c2.x - c1.x) / d);
  p[1].y := Round(c1.y + 20 * (c2.y - c1.y) / d);

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

{ ��������� ��������� ����� ����� }
procedure DrawLink(G: TGraph; u, v: TPNode);
var
  d: Integer;
  Points: Array [1 .. 2] of TPoint;
begin
  d := Distance(u.Center, v.Center);
  if d > 20 then
  begin
    GetLinkPoints(u.Center, v.Center, Points);
    Form1.Canvas.Polyline(Points);

    // TODO 4: ������ ��������� �����
    Form1.Canvas.Ellipse(Points[1].x - 5, Points[1].y - 5, Points[1].x + 5,
      Points[1].y + 5);
  end;
end;

// ������� ������� �� �����
procedure TForm1.FormClick(Sender: TObject);
var
  Pos: TPoint;
  EndNode: TPNode;
  d: Integer;
begin
  // ��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);
  case State of
    stAddNode: // ���������� ������� �����
      begin
        AddNode(G, Pos);
        DrawNode(G.VG, Pos);
      end;
    stAddLink:
      begin
        if StartNode = nil then
        begin
          StartNode := GetByPoint(G, Pos);
        end
        else
        begin
          EndNode := GetByPoint(G, Pos);
          if (EndNode <> nil) and (StartNode <> EndNode) then
          begin
            AddLink(G, StartNode.Number, EndNode.Number);
            DrawLink(G, StartNode, EndNode);
            StartNode := nil;
            EndNode := nil;
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

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DisposeGraph(G);
end;

procedure TForm1.AddLinkBtnClick(Sender: TObject);
begin
  StartNode := nil;
  if AddLinkBtn.Down then
    State := stAddLink
  else
    State := stNone;
end;

procedure TForm1.AddNodeBtnClick(Sender: TObject);
begin
  StartNode := nil;
  if AddNodeBtn.Down then
    State := stAddNode
  else
    State := stNone;
end;

end.
