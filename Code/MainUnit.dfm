object Form1: TForm1
  Left = 389
  Top = 123
  Caption = 'Graph Search'
  ClientHeight = 690
  ClientWidth = 1376
  Color = clBtnHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClick = FormClick
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 1196
    Top = 0
    Width = 180
    Height = 690
    Align = alRight
    BevelOuter = bvLowered
    TabOrder = 0
    object AddNodeBtn: TSpeedButton
      Left = 24
      Top = 24
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
      OnClick = AddNodeBtnClick
    end
    object AddLinkBtn: TSpeedButton
      Left = 24
      Top = 64
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1077#1073#1088#1086
      OnClick = AddLinkBtnClick
    end
    object SpeedButton3: TSpeedButton
      Left = 24
      Top = 112
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
    end
    object SpeedButton4: TSpeedButton
      Left = 24
      Top = 160
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1088#1077#1073#1088#1086
    end
    object DFSBtn: TSpeedButton
      Left = 24
      Top = 328
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1054#1073#1093#1086#1076' '#1074' '#1075#1083#1091#1073#1080#1085#1091
      OnClick = DFSBtnClick
    end
    object SpeedButton6: TSpeedButton
      Left = 24
      Top = 392
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1054#1073#1093#1086#1076' '#1074' '#1096#1080#1088#1080#1085#1091
    end
    object SpeedButton7: TSpeedButton
      Left = 24
      Top = 456
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1053#1072#1081#1090#1080' '#1082#1088#1072#1090#1095#1072#1081#1096#1080#1081' '#1087#1091#1090#1100
    end
    object Button1: TButton
      Left = 48
      Top = 552
      Width = 75
      Height = 25
      Caption = 'Sample'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object MainMenu1: TMainMenu
    Left = 208
    Top = 72
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N4: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
      end
      object N5: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      end
      object N6: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090
      end
      object N7: TMenuItem
        Caption = #1042#1099#1093#1086#1076
      end
    end
    object N2: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      object N8: TMenuItem
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1093#1086#1083#1089#1090
      end
    end
    object N3: TMenuItem
      Caption = #1055#1086#1084#1086#1097#1100
      object N9: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
end
