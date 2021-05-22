object fmEditor: TfmEditor
  Left = 389
  Top = 123
  Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1088#1072#1092#1072#1093
  ClientHeight = 690
  ClientWidth = 1376
  Color = clBtnHighlight
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = fmEditorClose
  OnCreate = fmEditorCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pbCanvas: TPaintBox
    Left = 0
    Top = 0
    Width = 1196
    Height = 690
    Align = alClient
    OnClick = pbCanvasClick
    OnMouseDown = pbCanvasMouseDown
    OnMouseMove = pbCanvasMouseMove
    OnMouseUp = pbCanvasMouseUp
    OnPaint = pbCanvasPaint
    ExplicitLeft = 472
    ExplicitTop = 112
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object plFunctionsContainer: TPanel
    Left = 1196
    Top = 0
    Width = 180
    Height = 690
    Align = alRight
    BevelOuter = bvLowered
    BorderWidth = 1
    TabOrder = 0
    object btnAddNode: TSpeedButton
      Left = 24
      Top = 56
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
      OnClick = SetClickState
    end
    object btnAddLinl: TSpeedButton
      Tag = 1
      Left = 24
      Top = 104
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1077#1073#1088#1086
      OnClick = SetClickState
    end
    object btnDeleteNode: TSpeedButton
      Tag = 2
      Left = 24
      Top = 152
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
      OnClick = SetClickState
    end
    object btnDeleteLink: TSpeedButton
      Tag = 3
      Left = 24
      Top = 200
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1088#1077#1073#1088#1086
      OnClick = SetClickState
    end
    object btnDFS: TSpeedButton
      Tag = 5
      Left = 24
      Top = 392
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1083#1091#1073#1080#1085#1091
      OnClick = SetClickState
    end
    object btnBFS: TSpeedButton
      Tag = 6
      Left = 24
      Top = 440
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1074' '#1096#1080#1088#1080#1085#1091
      OnClick = SetClickState
    end
    object btnDijkstra: TSpeedButton
      Tag = 7
      Left = 24
      Top = 488
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1044#1077#1081#1082#1089#1090#1088#1099
      OnClick = SetClickState
    end
    object lbEdit: TLabel
      Left = 6
      Top = 26
      Width = 170
      Height = 16
      Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1101#1083#1077#1084#1077#1085#1090#1086#1074
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbSearch: TLabel
      Left = 22
      Top = 362
      Width = 138
      Height = 16
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084#1099' '#1087#1086#1080#1089#1082#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object sbMove: TSpeedButton
      Tag = 4
      Left = 24
      Top = 256
      Width = 128
      Height = 30
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1077#1088#1077#1084#1077#1097#1072#1090#1100
      OnClick = SetClickState
    end
    object cbNoWeight: TCheckBox
      Left = 24
      Top = 552
      Width = 137
      Height = 17
      Caption = #1058#1086#1083#1100#1082#1086' '#1085#1077' '#1074#1079#1074#1077#1096#1077#1085#1085#1099#1077
      TabOrder = 0
      OnClick = cbNoWeightClick
    end
  end
  object mmMain: TMainMenu
    Left = 8
    Top = 8
    object nFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object nOpen: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = nOpenClick
      end
      object nSave: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        ShortCut = 16467
        OnClick = nSaveClick
      end
      object nSaveAs: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082
        ShortCut = 24659
        OnClick = nSaveAsClick
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
      Caption = #1048#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
      object nExportBMP: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' BMP'
        OnClick = nExportBMPClick
      end
      object nClear: TMenuItem
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1093#1086#1083#1089#1090
        ShortCut = 16453
        OnClick = nClearClick
      end
    end
    object nHelp: TMenuItem
      Caption = #1055#1086#1084#1086#1097#1100
      object nAbout: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
        ShortCut = 112
        OnClick = nAboutClick
      end
    end
  end
  object sdVertices: TSaveDialog
    DefaultExt = 'ver'
    Filter = 'Vertice file|*.ver'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103' '#1074#1077#1088#1096#1080#1085
    Left = 8
    Top = 64
  end
  object sdArcs: TSaveDialog
    DefaultExt = 'arc'
    Filter = 'Arcs file|*.arc'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103' '#1076#1091#1075
    Left = 64
    Top = 64
  end
  object odVertices: TOpenDialog
    DefaultExt = 'ver'
    Filter = 'Vertice file|*.ver'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1086#1090#1082#1088#1099#1090#1080#1103' '#1074#1077#1088#1096#1080#1085
    Left = 8
    Top = 120
  end
  object odArcs: TOpenDialog
    DefaultExt = 'arc'
    Filter = 'Arcs file|*.arc'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1086#1090#1082#1088#1099#1090#1080#1103' '#1076#1091#1075
    Left = 64
    Top = 120
  end
  object sdExport: TSaveDialog
    DefaultExt = 'bmp'
    Filter = 'Bitmap|*.bmp'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1101#1082#1089#1087#1086#1088#1090#1072' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103
    Left = 120
    Top = 64
  end
end
