object frmGraphEditor: TfrmGraphEditor
  Left = 389
  Top = 123
  Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1088#1072#1092#1072#1093
  ClientHeight = 690
  ClientWidth = 1376
  Color = clBtnHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnClose = frmGraphEditorClose
  OnCreate = frmGraphEditorCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imGraphCanvas: TImage
    Left = 0
    Top = 0
    Width = 1196
    Height = 690
    Align = alClient
    OnClick = imGraphCanvasClick
    ExplicitLeft = -184
  end
  object plFunctionsContainer: TPanel
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
      OnClick = SetClickState
    end
    object AddLinkBtn: TSpeedButton
      Left = 24
      Top = 64
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1077#1073#1088#1086
      OnClick = SetClickState
    end
    object DeleteNodeBtn: TSpeedButton
      Left = 24
      Top = 112
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
      OnClick = SetClickState
    end
    object DeleteLinkBtn: TSpeedButton
      Left = 24
      Top = 160
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1088#1077#1073#1088#1086
      OnClick = SetClickState
    end
    object DFSBtn: TSpeedButton
      Left = 24
      Top = 328
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1083#1091#1073#1080#1085#1091
      OnClick = SetClickState
    end
    object BFSbtn: TSpeedButton
      Left = 24
      Top = 392
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1074' '#1096#1080#1088#1080#1085#1091
      OnClick = SetClickState
    end
    object DijkstraBtn: TSpeedButton
      Left = 24
      Top = 456
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1044#1077#1081#1082#1089#1090#1088#1099
      OnClick = SetClickState
    end
  end
  object mmMain: TMainMenu
    Left = 208
    Top = 72
    object nFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object nOpen: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = OpenGraph
      end
      object nSave: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = SaveGraph
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object nExit: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = nExitClick
      end
    end
    object nEdit: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      object nClear: TMenuItem
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1093#1086#1083#1089#1090
      end
    end
    object nHelp: TMenuItem
      Caption = #1055#1086#1084#1086#1097#1100
      object nAbout: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
end
