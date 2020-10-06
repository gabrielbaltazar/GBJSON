object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 328
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 660
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnObjectToJson: TButton
      Left = 16
      Top = 18
      Width = 89
      Height = 40
      Caption = 'Object To Json'
      TabOrder = 0
      OnClick = btnObjectToJsonClick
    end
    object btnJsonToObject: TButton
      Left = 119
      Top = 18
      Width = 97
      Height = 40
      Caption = 'Json To Object'
      TabOrder = 1
      OnClick = btnJsonToObjectClick
    end
    object btnObjectToJsonListEmpty: TButton
      Left = 222
      Top = 18
      Width = 147
      Height = 40
      Caption = 'Json To Object Empty List'
      TabOrder = 2
      OnClick = btnObjectToJsonListEmptyClick
    end
    object btnListToJsonArray: TButton
      Left = 375
      Top = 18
      Width = 97
      Height = 40
      Caption = 'List To JSONArray'
      TabOrder = 3
      OnClick = btnListToJsonArrayClick
    end
    object btnJSONArrayToList: TButton
      Left = 478
      Top = 18
      Width = 97
      Height = 40
      Caption = 'JSONArray to List'
      TabOrder = 4
      OnClick = btnJSONArrayToListClick
    end
  end
  object mmoJSON: TMemo
    Left = 0
    Top = 73
    Width = 660
    Height = 255
    Align = alClient
    TabOrder = 1
  end
end
