unit ArcInputUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmArcInput = class(TForm)
    leWeight: TLabeledEdit;
    cbUnweighted: TCheckBox;
    cbEdge: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure cbUnweightedClick(Sender: TObject);
  public
    Weight: Integer;
    isEdge: Boolean;
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
  isEdge := cbEdge.Checked;
  if not cbUnweighted.Checked then
    Val(leWeight.Text, Weight, ErrCode);
  if (ErrCode <> 0) or (Weight <= 0) or cbUnweighted.Checked then
    Weight := 1;

  leWeight.Text := '';
  cbUnweighted.Checked := false;
  cbEdge.Checked := false;
end;

procedure TfmArcInput.cbUnweightedClick(Sender: TObject);
begin
  with leWeight do
    Enabled := not Enabled;
end;

end.