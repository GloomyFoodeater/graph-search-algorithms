object fmArcInput: TfmArcInput
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1042#1074#1086#1076' '#1076#1091#1075#1080
  ClientHeight = 195
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 16
  object leWeight: TLabeledEdit
    Left = 143
    Top = 32
    Width = 137
    Height = 24
    EditLabel.Width = 125
    EditLabel.Height = 16
    EditLabel.Caption = #1042#1074#1077#1076#1080#1090#1077' '#1074#1077#1089' '#1076#1091#1075#1080': '
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = [fsBold]
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 0
    TextHint = #1042#1077#1089' '#1076#1091#1075#1080
  end
  object cbUnweighted: TCheckBox
    Left = 8
    Top = 83
    Width = 106
    Height = 17
    Caption = #1053#1077#1074#1079#1074#1077#1096#1077#1085#1085#1072#1103
    TabOrder = 1
    OnClick = cbUnweightedClick
  end
  object cbEdge: TCheckBox
    Left = 158
    Top = 80
    Width = 89
    Height = 22
    Caption = #1056#1077#1073#1088#1086
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 8
    Top = 129
    Width = 106
    Height = 41
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 158
    Top = 129
    Width = 114
    Height = 41
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 4
  end
end