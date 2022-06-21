object FormGuide: TFormGuide
  Left = 192
  Top = 109
  Width = 757
  Height = 579
  Caption = 'Справочник по синтаксису ExprBuild'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox: TListBox
    Left = 12
    Top = 16
    Width = 237
    Height = 485
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    OnClick = ListBoxClick
  end
  object Memo: TMemo
    Left = 264
    Top = 16
    Width = 474
    Height = 161
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'Memo')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ScrollBox1: TScrollBox
    Left = 264
    Top = 192
    Width = 469
    Height = 345
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clInfoBk
    ParentColor = False
    TabOrder = 2
    object Image: TImage
      Left = 0
      Top = 0
      Width = 105
      Height = 105
      Transparent = True
    end
  end
  object BtnPrint: TBitBtn
    Left = 12
    Top = 512
    Width = 81
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Печать'
    TabOrder = 3
    OnClick = BtnPrintClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
      00030888888888888880088888888888888000000000000000000F8F8F8F8F8F
      8F8008F8F8F8F8F8F9F00F8F8F8F8F8F8F8000000000000000003330FFFFFFFF
      03333330F0000F0F03333330FFFFFFFF03333330F00F000003333330FFFF0FF0
      33333330F08F0F0333333330FFFF003333333330000003333333}
  end
end
