# ColorButton Hover 邊框功能說明

## 功能特色

這個修改版的 ColorButton 支援滑鼠 Hover 時顯示邊框，提供更好的互動體驗。

### 主要特點
- **Hover 即時反饋**：滑鼠移到按鈕上時自動顯示邊框
- **輕量級實作**：使用 Windows 原生的 `TrackMouseEvent` API
- **資源友善**：僅在狀態改變時重繪，無持續輪詢
- **多種邊框模式**：支援 Hover 顯示、永久顯示或完全隱藏

## ShowBorder 參數說明
```ahk
btn.SetColor(bgColor, txColor?, showBorder, borderColor?, roundedCorner?)
參數值效果n > 0Hover 或 Focus 時顯示 n 像素粗的邊框1Hover 或 Focus 時顯示 1px 邊框（預設）0完全無邊框-1永遠顯示 1px 邊框-n < 0永遠顯示 n 像素粗的邊框（絕對值越大越粗）
使用範例
基本用法
ahk#Requires AutoHotkey v2.0
#Include ColorButton_HoverBorder.ahk

MyGui := Gui()
MyGui.BackColor := 0x202020

; Hover 時顯示 2px 紅色邊框
btn := MyGui.Add("Button", "x20 y20 w150", "Hover 我看看")
btn.SetColor(0x0078D4, 0xFFFFFF, 2, 0xFF0000)

MyGui.Show()
完整應用範例
ahk#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ColorButton_HoverBorder.ahk

; 建立深色主題 GUI
MyGui := Gui()
MyGui.SetFont("s10", "Microsoft JhengHei")
MyGui.BackColor := 0x202020

; Windows 11 深色模式
DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.hwnd, "UInt", 20, "Ptr*", 1, "UInt", 4)

; 主要功能按鈕 - Hover 時顯示 2px 藍色邊框
btn1 := MyGui.Add("Button", "x20 y20 w120 h40", "檢驗查詢")
btn1.SetColor(0x0078D4, 0xFFFFFF, 2, 0x4CC2FF, 6)
btn1.OnEvent("Click", (*) => MsgBox("檢驗查詢"))

btn2 := MyGui.Add("Button", "x150 y20 w120 h40", "門急診查詢")
btn2.SetColor(0x0078D4, 0xFFFFFF, 2, 0x4CC2FF, 6)
btn2.OnEvent("Click", (*) => MsgBox("門急診查詢"))

; 次要功能 - Hover 時顯示 3px 綠色邊框
btn3 := MyGui.Add("Button", "x20 y70 w120 h40", "開啟 PACS")
btn3.SetColor(0x107C10, 0xFFFFFF, 3, 0x6FD96F, 6)
btn3.OnEvent("Click", (*) => MsgBox("開啟 PACS"))

; 永遠顯示邊框的按鈕
btn4 := MyGui.Add("Button", "x150 y70 w120 h40", "永久邊框")
btn4.SetColor(0x8B5CF6, 0xFFFFFF, -2, 0xC4B5FD, 6)

; 警告按鈕 - 無邊框純色
btnCancel := MyGui.Add("Button", "x20 y120 w250 h40", "取消")
btnCancel.SetColor(0xD13438, 0xFFFFFF, 0, , 6)
btnCancel.OnEvent("Click", (*) => MyGui.Destroy())

MyGui.Show("w290")
多種樣式展示
ahk#Requires AutoHotkey v2.0
#Include ColorButton_HoverBorder.ahk

MyGui := Gui()
MyGui.BackColor := 0x202020

; Hover 時 1px 邊框
btn1 := MyGui.Add("Button", "x20 y20 w180 h40", "Hover 顯示 1px")
btn1.SetColor(0x0078D4, 0xFFFFFF, 1, 0xFF0000)

; Hover 時 5px 粗邊框
btn2 := MyGui.Add("Button", "x20 y70 w180 h40", "Hover 顯示 5px")
btn2.SetColor(0x0078D4, 0xFFFFFF, 5, 0xFFFF00)

; 永遠 2px 邊框
btn3 := MyGui.Add("Button", "x20 y120 w180 h40", "永遠顯示 2px")
btn3.SetColor(0x0078D4, 0xFFFFFF, -2, 0x00FF00)

; 永遠 5px 粗邊框
btn4 := MyGui.Add("Button", "x20 y170 w180 h40", "永遠顯示 5px")
btn4.SetColor(0x0078D4, 0xFFFFFF, -5, 0xFF00FF)

; 完全無邊框
btn5 := MyGui.Add("Button", "x20 y220 w180 h40", "無邊框")
btn5.SetColor(0x0078D4, 0xFFFFFF, 0)

MyGui.Show("w220")
屬性設定方式
除了使用 SetColor() 方法，也可以透過屬性個別設定：
ahkbtn := MyGui.Add("Button", "w150", "我的按鈕")

; 方法 1: 使用 SetColor
btn.SetColor(0x0078D4, 0xFFFFFF, 3, 0xFF0000, 6)

; 方法 2: 先設定背景色，再調整其他屬性
btn.BackColor := 0x0078D4
btn.TextColor := 0xFFFFFF
btn.BorderColor := 0xFF0000
btn.ShowBorder := 3
btn.RoundedCorner := 6
技術說明

事件機制：使用 Windows API TrackMouseEvent 追蹤滑鼠進入/離開
全局 OnMessage：避免與原始 ColorButton 的 SubClass 機制衝突
按需重繪：僅在 hover 狀態改變時觸發重繪，不會持續消耗資源
兼容性：支援 AutoHotkey v2.0+

注意事項

不要保留調試用的 SetTimer：測試時的 ToolTip 計時器僅供調試，正式使用時必須移除
完全關閉舊腳本：修改代碼後需完全關閉 AHK 腳本再重新運行
使用 #SingleInstance Force：確保每次都載入最新版本


## 方法 3: 建立 AHK 腳本自動生成
```ahk
#Requires AutoHotkey v2.0

mdContent := "
(
# ColorButton Hover 邊框功能說明
... (你的內容)
)"

FileAppend mdContent, "ColorButton_README.md", "UTF-8"
MsgBox "已生成 ColorButton_README.md"
