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
  Form1.Canvas.Ellipse(Center.X - 20, Center.Y - 20, Center.X + 20, Center.Y + 20);

  //Вывод имени вершины
  Form1.Canvas.TextOut(TextPosX + 1, Center.Y - 6, NodeName);
end;

//Событие нажатия на холст
procedure TForm1.FormClick(Sender: TObject);
var Pos: TPoint;
begin
  //Получение координаты курсора
  Pos := ScreenToClient(Mouse.CursorPos);

  //Добавление и вывод вершины графа
  DrawNode(NodesCounter, Pos);
  Inc(NodesCounter);

end;

end.
