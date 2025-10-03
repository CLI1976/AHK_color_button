# ColorButton Hover 邊框功能 (修改版)

> 基於 [nperovic/ColorButton.ahk](https://github.com/nperovic/ColorButton.ahk) 修改  
> 新增 滑鼠 Hover 時顯示邊框的功能

## 致謝

本項目基於 **Nikola Perovic** 的 [ColorButton.ahk](https://github.com/nperovic/ColorButton.ahk) 進行修改。  
原項目提供了優秀的按鈕自訂顏色功能,在此基礎上我們增加了滑鼠 Hover 邊框效果。

感謝原作者的開源貢獻! 🙏

## 與原版的差異

| 功能 | 原版 | 修改版 |
|------|------|--------|
| 背景/文字/邊框顏色 | ✅ | ✅ |
| Focus 時顯示邊框 | ✅ | ✅ |
| **Hover 時顯示邊框** | ❌ | ✅ |
| 圓角設定 | ✅ | ✅ |

## 修改內容

- 新增滑鼠 Hover 事件追蹤 (`TrackMouseEvent` API)
- 使用全局 `OnMessage` 處理滑鼠進入/離開事件
- 修改邊框繪製邏輯,支援 Hover 狀態
- 保持與原版的完整兼容性

## 授權

本專案基於 [ColorButton.ahk](https://github.com/nperovic/ColorButton.ahk) 修改，
遵循原專案的 MIT License。

### 原專案授權
MIT License  
Copyright (c) 2024 Nikola Perovic

（完整授權文字見 LICENSE 文件）

---

# 功能特色

這個修改版的 ColorButton 支援滑鼠 Hover 時顯示邊框,提供更好的互動體驗。


### 主要特點
- **Hover 即時反饋**：滑鼠移到按鈕上時自動顯示邊框
- **輕量級實作**：使用 Windows 原生的 `TrackMouseEvent` API
- **資源友善**：僅在狀態改變時重繪，無持續輪詢
- **多種邊框模式**：支援 Hover 顯示、永久顯示或完全隱藏

## ShowBorder 參數說明

```ahk
btn.SetColor(bgColor, txColor?, showBorder, borderColor?, roundedCorner?)
參數值效果n > 0Hover 或 Focus 時顯示 n 像素粗的邊框1Hover 或 Focus 時顯示 1px 邊框（預設）0完全無邊框-1永遠顯示 1px 邊框-n < 0永遠顯示 n 像素粗的邊框（絕對值越大越粗）
```

##使用範例
##基本用法
```ahk
#Requires AutoHotkey v2.0
#Include ColorButton_HoverBorder.ahk

MyGui := Gui()
MyGui.BackColor := 0x202020

; Hover 時顯示 2px 紅色邊框
btn := MyGui.Add("Button", "x20 y20 w150", "Hover 我看看")
btn.SetColor(0x0078D4, 0xFFFFFF, 2, 0xFF0000)

MyGui.Show()



##多種樣式展示
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
```



##屬性設定方式
###除了使用 SetColor() 方法，也可以透過屬性個別設定：
```ahk
btn := MyGui.Add("Button", "w150", "我的按鈕")

; 方法 1: 使用 SetColor
btn.SetColor(0x0078D4, 0xFFFFFF, 3, 0xFF0000, 6)

; 方法 2: 先設定背景色，再調整其他屬性
btn.BackColor := 0x0078D4
btn.TextColor := 0xFFFFFF
btn.BorderColor := 0xFF0000
btn.ShowBorder := 3
btn.RoundedCorner := 6
```


##技術說明
事件機制：使用 Windows API TrackMouseEvent 追蹤滑鼠進入/離開
全局 OnMessage：避免與原始 ColorButton 的 SubClass 機制衝突
按需重繪：僅在 hover 狀態改變時觸發重繪，不會持續消耗資源
兼容性：支援 AutoHotkey v2.0+


