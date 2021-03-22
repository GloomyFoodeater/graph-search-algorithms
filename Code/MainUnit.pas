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

//Процедура, рисующая вершину графа
procedure DrawNode(Number: Integer; Center: TPoint);
var NodeName: String; //Имя вершины
    TextPosX: Integer; //Левый верхний край текста
    NumberCopy: Integer; //Копия номера вершины
begin

  //Получение имени вершины и его x-координаты
  Str(Number, NodeName);
  NumberCopy := Number;
  TextPosX := Center.X;
  while NumberCopy <> 0 do
  begin
    NumberCopy := NumberCopy div 10;
    TextPosX := TextPosX - 4;
  end;

  //Вывод круга
  Form1.Image1.Canvas.Ellipse(Center.X - 20, Center.Y - 20, Center.X + 20, Center.Y + 20);

  //Вывод имени вершины
  Form1.Image1.Canvas.TextOut(TextPosX + 1, Center.Y - 6, NodeName);
end;

//Событие нажатия на холст
procedure TForm1.Image1Click(Sender: TObject);
var Pos: TPoint; //Координата курсора
begin

  //Получение координаты курсора
  Pos := ScreenToClient(Mouse.CursorPos);

  //Добавление и вывод вершины графа
  DrawNode(NodesCounter, Pos);
  Inc(NodesCounter);
  
end;

end.
