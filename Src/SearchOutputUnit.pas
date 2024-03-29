unit SearchOutputUnit;
{
  ������ � ��������� ����� ������ ����,
  ������� ���������� ��� ���������� ����
  � ������� ������ �� ����������.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GraphSearch;

type

  // ��� ��������������� �����
  TfmSearchOutput = class(TForm)
    lbResults: TLabel;
    procedure FormShow(Sender: TObject);
  public
    Info: TSearchInfo; // ���������� � ����
  end;

var
  fmSearchOutput: TfmSearchOutput;
  // fmSearchOutput - ��������������� �����

implementation

{$R *.dfm}

procedure TfmSearchOutput.FormShow(Sender: TObject);
const
  NL = #13#10;
  // NL - ������� �� ����� ������

var
  ResString: String;
  // ResString - ������ ��� ��������������

begin
  Info.PathString := NL + Info.PathString;
  ResString := '��������� ����: %s' + NL + NL;
  ResString := ResString + '���������� ��� � ����: %d' + NL;
  ResString := ResString + '����� ���������� ����: %d' + NL;
  ResString := ResString + '���������� ���������: %d' + NL;
  with Info do
    lbResults.Caption := Format(ResString, [PathString, ArcsCount, Distance,
      VisitsCount]);
end;

end.
