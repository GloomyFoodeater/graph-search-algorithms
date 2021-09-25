unit AboutUnit;
{
  ������ � ��������� ����� ������ ����
  '� ���������', ��� ������� ��������
  � ��������� �� ��������� �����
  ���������� ���������� �����
  README.txt.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type

  // ��� ��������������� �����
  TfmAbout = class(TForm)
    memText: TMemo;
    procedure FormCreate(Sender: TObject);
  end;

var
  fmAbout: TfmAbout;
  // fmAbout - ��������������� �����

implementation

{$R *.dfm}

procedure TfmAbout.FormCreate(Sender: TObject);
const
  FileName = 'README.txt';
  NL = #13#10;
  // FileName - ��� ����� �� ��������
  // NL - ������� �� ����� ������

var
  fText: TextFile;
  Line: String;
  // fText - ��������� ����
  // Line - ����������� ������

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
    memText.Lines.Add(Format('���� %s �� ��� ������.', [FileName]));
  end;
end;

end.
