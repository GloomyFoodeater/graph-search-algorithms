unit AboutUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmAbout = class(TForm)
    lbText: TLabel;
    procedure FormCreate(Sender: TObject);
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  fText: TextFile;
  Line: String;
begin

  try
    System.Assign(fText, 'About.txt');
    Reset(fText);
    while not Eof(fText) do
    begin
      ReadLn(fText, Line);
      lbText.Caption := lbText.Caption + #13 + #10 + Utf8ToAnsi(Line);
    end;
    CloseFile(fText);
  except
    lbText.Caption := 'Файл About.txt не был найден.';
  end;

end;

end.
