unit ArcInputUnit;
{
  Модуль с описанием формы ввода веса дуги,
  которая появляется при включенных взвешенных
  дугах при добавлении новой дуги.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  // Тип вспомогательной формы
  TfmArcInput = class(TForm)
    leWeight: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    Weight: Integer; // Поле с введённым весом
  end;

var
  fmArcInput: TfmArcInput;
  // fmArcInput - Вспомогательная форма

implementation

{$R *.dfm}
{ TfmArcInput }

// Обработчик нажатия на кнопку
procedure TfmArcInput.btnOKClick(Sender: TObject);
var
  ErrCode: Integer;
  // ErrCode - Признак ошибки при преобразовании

begin
  Val(leWeight.Text, Weight, ErrCode);
  if (ErrCode <> 0) or (Weight <= 0) then
    Weight := 1;
  leWeight.Text := '';
end;

// Обработчик создания формы
procedure TfmArcInput.FormCreate(Sender: TObject);
begin
  Weight := 1;
end;

// Обработчик показа формы
procedure TfmArcInput.FormShow(Sender: TObject);
begin
  leWeight.SetFocus;
end;

end.
