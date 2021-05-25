unit ArcInputUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmArcInput = class(TForm)
    leWeight: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    Weight: Integer;
  end;

var
  fmArcInput: TfmArcInput;

implementation

{$R *.dfm}
{ TfmArcInput }

procedure TfmArcInput.btnOKClick(Sender: TObject);
var
  ErrCode: Integer;
begin
  Val(leWeight.Text, Weight, ErrCode);
  if (ErrCode <> 0) or (Weight <= 0) then
    Weight := 1;

  leWeight.Text := '';
end;

procedure TfmArcInput.FormCreate(Sender: TObject);
begin
  Weight := 1;
end;

end.
