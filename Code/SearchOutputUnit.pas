unit SearchOutputUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GraphSearch;

type
  TfmSearchOutput = class(TForm)
    lbResults: TLabel;
    procedure FormShow(Sender: TObject);
  public
    Info: TSearchInfo;
  end;

var
  fmSearchOutput: TfmSearchOutput;

implementation

{$R *.dfm}

procedure TfmSearchOutput.FormShow(Sender: TObject);
begin
  lbResults.Caption := '��������� ����:'#13#10 + Info.PathString +
    #13#10 + #13#10;
  lbResults.Caption := lbResults.Caption + '���������� ��� � ����: ' +
    IntToStr(Info.ArcsCount) + #13#10;
  lbResults.Caption := lbResults.Caption + '����� ���������� ����: ' +
    IntToStr(Info.Distance) + #13#10;
  lbResults.Caption := lbResults.Caption + '���������� ���������: ' +
    IntToStr(Info.VisitsCount) + #13#10;
end;

end.
