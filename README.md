# ColorButton Hover 邊框功能 (修改版)

> 基於 [nperovic/ColorButton.ahk](https://github.com/nperovic/ColorButton.ahk) 修改  
> 新增 滑鼠 Hover 時顯示邊框的功能

## 致謝

本項目基於 **Nikola Perovic** 的 [ColorButton.ahk](https://github.com/nperovic/ColorButton.ahk) 進行修改。  
原項目提供了優秀的按鈕自訂顏色功能,在此基礎上我們增加了滑鼠 Hover 邊框效果。

感謝原作者的開源貢獻! 🙏

🙏🙏本專案在 Anthropic 的 Claude 4.5 Sonnet 的協助下完成。Claude 提供了完整的程式設計指導、代碼優化建議以及問題排除方案，對專案的開發有重大貢獻。🙏🙏

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

## SetColor 方法完整說明 

```ahk
btn.SetColor(bgColor, txColor?, showBorder, borderColor?, roundedCorner?)
```
1. ### bgColor 按鈕背景顏色
2. ### txColor?(可選) 按鈕文字顏色 (RGB)
3. ### show Border 參數說明
| 參數值 | 效果 | 
|------|------|
|n > 0 | Hover 或 Focus 時顯示 n 像素粗的邊框 |
| 1  | Hover 或 Focus 時顯示 1px 邊框（預設） |
| 0| 完全無邊框 |
|-1 | 永遠顯示 1px 邊框| 
|-n < 0   | 永遠顯示 n 像素粗的邊框（絕對值越大越粗） |
4. ### borderColor?(可選) 邊框顏色 (RGB)  (預設 = 0xFFFFFF, 白色邊框)
4. ### roundedColor?(可選) 圓角像素值 
```
btn.SetColor(0x0078D4, , , , 9)     // 9px 圓角
btn.SetColor(0x0078D4, , , , 0)     // 方形按鈕
btn.SetColor(0x0078D4)              // 省略:
                                    // Win11 自動 9px 圓角
                                    // Win10 自動方形
```







##使用範例
##範例 1: 最簡單用法
```ahk
btn := MyGui.Add("Button", "w150", "按鈕")
btn.SetColor(0x0078D4)  // 只設背景色,其他都自動
```
##範例 2: 設定文字顏色
```
btn.SetColor(
    0x0078D4,    // 藍色背景
    0xFFFFFF     // 白色文字
)
```

##範例 3: Hover 時顯示邊框
```
btn.SetColor(
    0x0078D4,    // 藍色背景
    0xFFFFFF,    // 白色文字
    2,           // Hover 時 2px 邊框
    0xFF0000     // 紅色邊框
)
```
##範例 4: 永遠顯示粗邊框
```
btn.SetColor(
    0x0078D4,    // 藍色背景
    0xFFFFFF,    // 白色文字
    -5,          // 永遠 5px 邊框
    0x00FF00     // 綠色邊框
)
```
##範例 5: 完整設定
```
btn.SetColor(
    0x0078D4,    // 背景: 藍色
    0xFFFFFF,    // 文字: 白色
    3,           // Hover 時 3px 邊框
    0x4CC2FF,    // 邊框: 淺藍色
    6            // 圓角: 6px
)
```
##範例 6: 無邊框純色塊
```
btn.SetColor(
    0xD13438,    // 背景: 紅色
    0xFFFFFF,    // 文字: 白色
    0            // 完全無邊框
)
```
##快速對照表
```
// 情境 1: 我只想改背景色
btn.SetColor(0x0078D4)

// 情境 2: 背景色 + 文字色
btn.SetColor(0x0078D4, 0xFFFFFF)

// 情境 3: Hover 時要有邊框
btn.SetColor(0x0078D4, 0xFFFFFF, 2, 0xFF0000)

// 情境 4: 邊框永遠顯示
btn.SetColor(0x0078D4, 0xFFFFFF, -2, 0xFF0000)

// 情境 5: 不要邊框
btn.SetColor(0x0078D4, 0xFFFFFF, 0)

// 情境 6: 完全客製化
btn.SetColor(0x0078D4, 0xFFFFFF, 3, 0xFF0000, 9)
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




