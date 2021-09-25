unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Menus;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  NodesCounter: Integer;

implementation

{$R *.dfm}

//���������, �������� ������� �����
procedure DrawNode(Number: Integer; Center: TPoint);
var NodeName: String; //��� �������
    TextPosX: Integer; //����� ������� ���� ������
    NumberCopy: Integer; //����� ������ �������
begin

  //��������� ����� ������� � ��� x-����������
  Str(Number, NodeName);
  NumberCopy := Number;
  TextPosX := Center.X;
  while NumberCopy <> 0 do
  begin
    NumberCopy := NumberCopy div 10;
    TextPosX := TextPosX - 4;
  end;

  //����� �����
  Form1.Canvas.Ellipse(Center.X - 20, Center.Y - 20, Center.X + 20, Center.Y + 20);

  //����� ����� �������
  Form1.Canvas.TextOut(TextPosX + 1, Center.Y - 6, NodeName);
end;

//������� ������� �� �����
procedure TForm1.FormClick(Sender: TObject);
var Pos: TPoint;
begin
  //��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);

  //���������� � ����� ������� �����
  DrawNode(NodesCounter, Pos);
  Inc(NodesCounter);

end;

end.
