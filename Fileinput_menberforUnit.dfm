object frm_Fileinput_menberfor: Tfrm_Fileinput_menberfor
  Left = 249
  Top = 135
  Width = 724
  Height = 499
  BorderIcons = []
  Caption = '3F'#20339#26519#31185#25216'-'#36164#26009#24405#20837'-'#20250#21592#22871#39184
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgcMenberfor: TPageControl
    Left = 0
    Top = 0
    Width = 716
    Height = 465
    ActivePage = TabSheet1
    Align = alClient
    MultiLine = True
    TabOrder = 0
    object tbsConfig: TTabSheet
      Caption = #20250#21592#31561#32423#35774#32622
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 708
        Height = 153
        Align = alTop
        BorderStyle = bsSingle
        TabOrder = 0
        object Label3: TLabel
          Left = 257
          Top = 13
          Width = 60
          Height = 13
          Caption = #22791'        '#27880#65306
        end
        object Label24: TLabel
          Left = 16
          Top = 77
          Width = 60
          Height = 13
          Caption = #31215'        '#20998#65306
        end
        object Label23: TLabel
          Left = 16
          Top = 43
          Width = 60
          Height = 13
          Caption = #31561#32423#21517#31216#65306
        end
        object Label22: TLabel
          Left = 16
          Top = 12
          Width = 60
          Height = 13
          Caption = #31561#32423#32534#21495#65306
        end
        object Bit_Add: TBitBtn
          Left = 16
          Top = 112
          Width = 81
          Height = 33
          Caption = #28155#21152
          TabOrder = 0
          OnClick = Bit_AddClick
        end
        object Bit_Update: TBitBtn
          Left = 208
          Top = 112
          Width = 81
          Height = 33
          Caption = #20462#25913
          Enabled = False
          TabOrder = 1
          OnClick = Bit_UpdateClick
        end
        object Bit_Delete: TBitBtn
          Left = 424
          Top = 112
          Width = 81
          Height = 33
          Caption = #21024#38500
          TabOrder = 2
          OnClick = Bit_DeleteClick
        end
        object Bit_Close: TBitBtn
          Left = 592
          Top = 112
          Width = 81
          Height = 33
          Caption = #20851#38381
          TabOrder = 3
          OnClick = Bit_CloseClick
        end
        object Edit_core: TEdit
          Left = 112
          Top = 72
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 4
        end
        object Edit_levelname: TEdit
          Left = 112
          Top = 40
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 5
        end
        object Edit_level: TEdit
          Left = 112
          Top = 8
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 6
        end
        object Memo_instruction: TMemo
          Left = 344
          Top = 8
          Width = 353
          Height = 81
          Lines.Strings = (
            '')
          TabOrder = 7
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 153
        Width = 708
        Height = 284
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 1
        object DBGrid1: TDBGrid
          Left = 1
          Top = 1
          Width = 706
          Height = 282
          Align = alClient
          DataSource = DataSource_Setmenberfor
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
          OnDblClick = DBGrid1DblClick
          Columns = <
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'Lev_ID'
              Title.Alignment = taCenter
              Title.Caption = #24207#21495
              Width = 50
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'LevNo'
              Title.Alignment = taCenter
              Title.Caption = #31561#32423#32534#21495' '
              Width = 100
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'LevName'
              Title.Alignment = taCenter
              Title.Caption = #31561#32423#21517#31216
              Width = 116
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'Score'
              Title.Alignment = taCenter
              Title.Caption = #31215#20998
              Width = 100
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'cUserNo'
              Title.Caption = #25805#20316#21592
              Width = 120
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'Remark'
              Title.Caption = #22791#27880
              Width = 200
              Visible = True
            end>
        end
      end
    end
    object tbsLowLevel: TTabSheet
      Caption = #36865#20998#27963#21160#22871#39184#36164#26009
      object Panel1: TPanel
        Left = 0
        Top = 153
        Width = 708
        Height = 284
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 0
        object DBGrid2: TDBGrid
          Left = 1
          Top = 1
          Width = 706
          Height = 282
          Align = alClient
          DataSource = DataSource_SetmenberGive
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
          OnDblClick = DBGrid2DblClick
          Columns = <
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'ID'
              Title.Alignment = taCenter
              Title.Caption = #24207#21495
              Width = 50
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = #22871#39184#32534#21495
              Title.Alignment = taCenter
              Width = 100
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = #36865#20998#20805#20540#19978#38480
              Title.Alignment = taCenter
              Width = 80
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = #36865#20998#20805#20540#19979#38480
              Title.Alignment = taCenter
              Width = 80
              Visible = True
            end
            item
              Expanded = False
              FieldName = #36865#31215#20998#20540
              Title.Caption = #36865#20998#20540
              Width = 80
              Visible = True
            end
            item
              Expanded = False
              FieldName = #25805#20316#21592
              Width = 100
              Visible = True
            end
            item
              Expanded = False
              FieldName = #22791#27880
              Width = 190
              Visible = True
            end>
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 708
        Height = 153
        Align = alTop
        BorderStyle = bsSingle
        TabOrder = 1
        object Label1: TLabel
          Left = 8
          Top = 12
          Width = 60
          Height = 13
          Caption = #22871#39184#32534#21495#65306
        end
        object Label2: TLabel
          Left = 8
          Top = 43
          Width = 84
          Height = 13
          Caption = #36865#20998#20805#20540#19978#38480#65306
        end
        object Label4: TLabel
          Left = 8
          Top = 77
          Width = 84
          Height = 13
          Caption = #36865#20998#20805#20540#19979#38480#65306
        end
        object Label5: TLabel
          Left = 257
          Top = 45
          Width = 60
          Height = 13
          Caption = #22791'        '#27880#65306
        end
        object Label6: TLabel
          Left = 256
          Top = 8
          Width = 60
          Height = 13
          Caption = #36865'        '#20998#65306
        end
        object Bit_Add_Give: TBitBtn
          Left = 32
          Top = 104
          Width = 81
          Height = 33
          Caption = #28155#21152
          TabOrder = 0
          OnClick = Bit_Add_GiveClick
        end
        object Bit_Update_Give: TBitBtn
          Left = 232
          Top = 104
          Width = 89
          Height = 33
          Caption = #20462#25913
          Enabled = False
          TabOrder = 1
          OnClick = Bit_Update_GiveClick
        end
        object Bit_Delete_Give: TBitBtn
          Left = 400
          Top = 104
          Width = 81
          Height = 33
          Caption = #21024#38500
          TabOrder = 2
          OnClick = Bit_Delete_GiveClick
        end
        object Bit_Close_Give: TBitBtn
          Left = 576
          Top = 104
          Width = 81
          Height = 33
          Caption = #20851#38381
          TabOrder = 3
          OnClick = Bit_Close_GiveClick
        end
        object Edit_GiveNO: TEdit
          Left = 112
          Top = 8
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 4
        end
        object Edit_Giveuplimit: TEdit
          Left = 112
          Top = 40
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 5
        end
        object Edit_Givelowlimit: TEdit
          Left = 112
          Top = 72
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 6
        end
        object Memo_Giveinstruction: TMemo
          Left = 344
          Top = 32
          Width = 353
          Height = 65
          Lines.Strings = (
            '')
          TabOrder = 7
        end
        object Edit_Givevalue: TEdit
          Left = 344
          Top = 7
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 8
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = #33410#26085#27963#21160#22871#39184
      ImageIndex = 2
      object Panel5: TPanel
        Left = 0
        Top = 129
        Width = 708
        Height = 308
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 0
        object DBGrid_Festpack: TDBGrid
          Left = 1
          Top = 1
          Width = 706
          Height = 306
          Align = alClient
          DataSource = DataSource_Festpack
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
          OnDblClick = DBGrid_FestpackDblClick
          Columns = <
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'ID'
              Title.Alignment = taCenter
              Title.Caption = #24207#21495
              Width = 50
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'FestNo'
              Title.Alignment = taCenter
              Title.Caption = #27963#21160#22871#39184#32534#21495' '
              Width = 100
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'FestName'
              Title.Alignment = taCenter
              Title.Caption = #27963#21160#22871#39184#21517#31216
              Width = 116
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'IsUse'
              Title.Alignment = taCenter
              Title.Caption = #26159#21542#21551#29992
              Width = 100
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'cUserNo'
              Title.Caption = #25805#20316#21592
              Width = 120
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'Remark'
              Title.Caption = #22791#27880
              Width = 200
              Visible = True
            end>
        end
      end
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 708
        Height = 129
        Align = alTop
        BorderStyle = bsSingle
        TabOrder = 1
        object Label7: TLabel
          Left = 425
          Top = 13
          Width = 60
          Height = 13
          Caption = #22791'        '#27880#65306
        end
        object Label9: TLabel
          Left = 16
          Top = 49
          Width = 84
          Height = 13
          Caption = #27963#21160#22871#39184#21517#31216#65306
        end
        object Label10: TLabel
          Left = 16
          Top = 12
          Width = 84
          Height = 13
          Caption = #27963#21160#22871#39184#32534#21495#65306
        end
        object Label11: TLabel
          Left = 240
          Top = 41
          Width = 60
          Height = 13
          Caption = #26159#21542#21551#29992'    '
        end
        object Label12: TLabel
          Left = 240
          Top = 8
          Width = 42
          Height = 13
          Caption = #25805#20316#21592'  '
        end
        object Bit_Add_Festpack: TBitBtn
          Left = 16
          Top = 80
          Width = 81
          Height = 33
          Caption = #28155#21152
          TabOrder = 0
          OnClick = Bit_Add_FestpackClick
        end
        object Bit_Update_Festpack: TBitBtn
          Left = 208
          Top = 80
          Width = 81
          Height = 33
          Caption = #20462#25913
          Enabled = False
          TabOrder = 1
          OnClick = Bit_Update_FestpackClick
        end
        object Bit__Del_Festpack: TBitBtn
          Left = 424
          Top = 80
          Width = 81
          Height = 33
          Caption = #21024#38500
          TabOrder = 2
          OnClick = Bit__Del_FestpackClick
        end
        object Bit_Close_Festpack: TBitBtn
          Left = 592
          Top = 80
          Width = 81
          Height = 33
          Caption = #20851#38381
          TabOrder = 3
          OnClick = Bit_Close_FestpackClick
        end
        object Edit_FestName: TEdit
          Left = 112
          Top = 46
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 4
        end
        object Edit_FestNo: TEdit
          Left = 112
          Top = 8
          Width = 121
          Height = 21
          CharCase = ecUpperCase
          TabOrder = 5
        end
        object Memo_Remark: TMemo
          Left = 488
          Top = 8
          Width = 209
          Height = 57
          Lines.Strings = (
            '')
          TabOrder = 6
        end
        object rg_IsUse: TRadioGroup
          Left = 304
          Top = 34
          Width = 121
          Height = 32
          Columns = 2
          ItemIndex = 0
          Items.Strings = (
            #26159
            #21542)
          TabOrder = 7
        end
        object Edit_cUserNo: TEdit
          Left = 304
          Top = 8
          Width = 121
          Height = 21
          Enabled = False
          TabOrder = 8
        end
      end
    end
  end
  object DataSource_SetmenberGive: TDataSource
    DataSet = ADOQuery_SetmenberGive
    Left = 33
    Top = 268
  end
  object ADOQuery_SetmenberGive: TADOQuery
    Parameters = <>
    Left = 65
    Top = 268
  end
  object ADOQuery_Setmenberfor: TADOQuery
    Parameters = <>
    Left = 377
    Top = 292
  end
  object DataSource_Setmenberfor: TDataSource
    DataSet = ADOQuery_Setmenberfor
    Left = 337
    Top = 292
  end
  object DataSource_Festpack: TDataSource
    DataSet = ADOQuery_Festpack
    Left = 537
    Top = 276
  end
  object ADOQuery_Festpack: TADOQuery
    Parameters = <>
    Left = 577
    Top = 276
  end
end
