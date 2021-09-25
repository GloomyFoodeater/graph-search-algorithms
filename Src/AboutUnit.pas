unit AboutUnit;
{
  Модуль с описанием формы вызова окна
  'О программе', при котором читается
  и выводится на компонент формы
  содержимое текстового файла
  README.txt.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type

  // Тип вспомогательной формы
  TfmAbout = class(TForm)
    memText: TMemo;
    procedure FormCreate(Sender: TObject);
  end;

var
  fmAbout: TfmAbout;
  // fmAbout - Вспомогательная форма

implementation

{$R *.dfm}

procedure TfmAbout.FormCreate(Sender: TObject);
const
  FileName = 'README.txt';
  NL = #13#10;
  // FileName - Имя файла со справкой
  // NL - Переход на новую строку

var
  fText: TextFile;
  Line: String;
  // fText - Текстовый файл
  // Line - Прочитанная строка

begin
  try
    System.Assign(fText, FileName);
    Reset(fText);
    while not Eof(fText) do
    begin
      ReadLn(fText, Line);
      memText.Lines.Add(Utf8ToAnsi(Line))
    end;
    CloseFile(fText);
  except
    memText.Lines.Add(Format('Файл %s не был найден.', [FileName]));
  end;
end;

end.
