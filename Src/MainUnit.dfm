object fmEditor: TfmEditor
  Left = 389
  Top = 123
  Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1088#1072#1092#1072#1093
  ClientHeight = 702
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
    Width = 1112
    Height = 702
    Margins.Bottom = 0
    Align = alClient
    OnClick = pbCanvasClick
    OnMouseDown = pbCanvasMouseDown
    OnMouseMove = pbCanvasMouseMove
    OnMouseUp = pbCanvasMouseUp
    OnPaint = pbCanvasPaint
  end
  object plContainer: TPanel
    Left = 1112
    Top = 0
    Width = 264
    Height = 702
    Align = alRight
    BevelOuter = bvLowered
    BorderWidth = 1
    TabOrder = 0
    object btnAddNode: TSpeedButton
      Left = 64
      Top = 48
      Width = 144
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = SetCanvasState
    end
    object btnAddLinl: TSpeedButton
      Tag = 1
      Left = 64
      Top = 96
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1076#1091#1075#1091
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = SetCanvasState
    end
    object btnDeleteNode: TSpeedButton
      Tag = 2
      Left = 64
      Top = 152
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1077#1088#1096#1080#1085#1091
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = SetCanvasState
    end
    object btnDeleteLink: TSpeedButton
      Tag = 3
      Left = 64
      Top = 209
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1076#1091#1075#1091
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = SetCanvasState
    end
    object btnDFS: TSpeedButton
      Tag = 5
      Left = 64
      Top = 400
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1083#1091#1073#1080#1085#1091
      OnClick = SetCanvasState
    end
    object btnBFS: TSpeedButton
      Tag = 6
      Left = 64
      Top = 465
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1074' '#1096#1080#1088#1080#1085#1091
      OnClick = SetCanvasState
    end
    object btnDijkstra: TSpeedButton
      Tag = 7
      Left = 64
      Top = 529
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1086#1080#1089#1082' '#1044#1077#1081#1082#1089#1090#1088#1099
      OnClick = SetCanvasState
    end
    object lbEdit: TLabel
      Left = 30
      Top = 18
      Width = 206
      Height = 24
      Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1101#1083#1077#1084#1077#1085#1090#1086#1074
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbSearch: TLabel
      Left = 46
      Top = 362
      Width = 182
      Height = 24
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084#1099' '#1087#1086#1080#1089#1082#1072
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object sbMove: TSpeedButton
      Tag = 4
      Left = 64
      Top = 266
      Width = 145
      Height = 33
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1055#1077#1088#1077#1084#1077#1097#1072#1090#1100
      OnClick = SetCanvasState
    end
    object cbNoWeight: TCheckBox
      Left = 48
      Top = 313
      Width = 185
      Height = 25
      TabStop = False
      Caption = #1053#1077#1074#1079#1074#1077#1096#1077#1085#1085#1099#1077' '#1076#1091#1075#1080
      Checked = True
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      State = cbChecked
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
    object nGraph: TMenuItem
      Caption = #1043#1088#1072#1092
      object nImportExcel: TMenuItem
        Caption = #1048#1084#1087#1086#1088#1090' '#1080#1079' Excel'
        OnClick = nImportFromExcel
      end
      object nExportBMP: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' BMP'
        OnClick = nExportBMPClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object nClear: TMenuItem
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100
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
  object odImport: TOpenDialog
    Filter = 
      #1050#1085#1080#1075#1072' Excel|*.xlsx|'#1050#1085#1080#1075#1072' Excel 97-2003|*.xls|'#1044#1074#1086#1080#1095#1085#1072#1103' '#1082#1085#1080#1075#1072' Exce' +
      'l|*.xlsb|'#1050#1085#1080#1075#1072' Excel '#1089' '#1087#1086#1076#1076#1077#1088#1078#1082#1086#1081' '#1084#1072#1082#1088#1086#1089#1086#1074'|*.xlsm'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 120
    Top = 120
  end
end
