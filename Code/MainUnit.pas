unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure Image1Click(Sender: TObject);
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
  Form1.Image1.Canvas.Ellipse(Center.X - 20, Center.Y - 20, Center.X + 20, Center.Y + 20);

  //����� ����� �������
  Form1.Image1.Canvas.TextOut(TextPosX + 1, Center.Y - 6, NodeName);
end;

//������� ������� �� �����
procedure TForm1.Image1Click(Sender: TObject);
var Pos: TPoint; //���������� �������
begin

  //��������� ���������� �������
  Pos := ScreenToClient(Mouse.CursorPos);

  //���������� � ����� ������� �����
  DrawNode(NodesCounter, Pos);
  Inc(NodesCounter);
  
end;

end.
