#Requires AutoHotkey v2.0
; 修改版 ColorButton - 支援 Hover 顯示邊框
; 在原始 _BtnColor 類別中添加 hover 追蹤
class _BtnColor extends Gui.Button
{
    static __New() {
        for prop in this.Prototype.OwnProps()
            if (!super.Prototype.HasProp(prop) && SubStr(prop, 1, 1) != "_")
                super.Prototype.DefineProp(prop, this.Prototype.GetOwnPropDesc(prop))

        Gui.CheckBox.Prototype.DefineProp("GetTextFlags", this.Prototype.GetOwnPropDesc("GetTextFlags"))
        Gui.Radio.Prototype.DefineProp("GetTextFlags", this.Prototype.GetOwnPropDesc("GetTextFlags"))
    }

    GetTextFlags(&center?, &vcenter?, &right?, &bottom?)
    {
        static BS_BOTTOM     := 0x800
        static BS_CENTER     := 0x300
        static BS_LEFT       := 0x100
        static BS_MULTILINE  := 0x2000
        static BS_RIGHT      := 0x200
        static BS_TOP        := 0x0400
        static BS_VCENTER    := 0x0C00
        static DT_BOTTOM     := 0x8
        static DT_CENTER     := 0x1
        static DT_LEFT       := 0x0
        static DT_RIGHT      := 0x2
        static DT_SINGLELINE := 0x20
        static DT_TOP        := 0x0
        static DT_VCENTER    := 0x4
        static DT_WORDBREAK  := 0x10
        
        dwStyle     := ControlGetStyle(this)
        txC         := dwStyle & BS_CENTER
        txR         := dwStyle & BS_RIGHT
        txL         := dwStyle & BS_LEFT
        dwTextFlags := (dwStyle & BS_BOTTOM) ? DT_BOTTOM : !(dwStyle & BS_TOP) ? DT_VCENTER : DT_TOP
        
        if (this.Type = "Button") 
            dwTextFlags |= (txC && txR && !txL) ? DT_RIGHT : (txC && txL && !txR) ? DT_LEFT : DT_CENTER
        else
            dwTextFlags |= txL && txR ? DT_CENTER : !txL && txR ? DT_RIGHT : DT_LEFT

        if !(dwStyle & BS_MULTILINE)
            dwTextFlags |= DT_SINGLELINE
        
        center  := !!(dwTextFlags & DT_CENTER)
        vcenter := !!(dwTextFlags & DT_VCENTER)
        right   := !!(dwTextFlags & DT_RIGHT)
        bottom  := !!(dwTextFlags & DT_BOTTOM)
        
        return dwTextFlags | DT_WORDBREAK
    }

    TextColor {
        Get => this.HasProp("_textColor") && _BtnColor.RgbToBgr(this._textColor)
        Set => this._textColor := _BtnColor.RgbToBgr(value)
    }

    BackColor {
        Get => this.HasProp("_clr") && _BtnColor.RgbToBgr(this._clr)
        Set {
            if !this.HasProp("_first")
                this.SetColor(value)
            else {
                b := _BtnColor
                this.opt("-Redraw")
                this._clr         := b.RgbToBgr(value)
                this._isDark      := b.IsColorDark(clr := b.RgbToBgr(this._clr))
                this._hoverColor  := b.RgbToBgr(b.BrightenColor(clr, this._isDark ? 20 : -20))
                this._pushedColor := b.RgbToBgr(b.BrightenColor(clr, this._isDark ? -10 : 10))
                this.opt("+Redraw")
            }
        }
    }

    BorderColor {
        Get => this.HasProp("_borderColor") && _BtnColor.RgbToBgr(this._borderColor)
        Set => this._borderColor := _BtnColor.RgbToBgr(value)
    }
    
    RoundedCorner {
        Get => this.HasProp("_roundedCorner") && this._roundedCorner
        Set => this._roundedCorner := value
    }

    ShowBorder {
        Get => this.HasProp("_showBorder") && this._showBorder
        Set {
            if IsNumber(Value)
                this._showBorder := value
            else throw TypeError("The value must be a number.", "ShowBorder")
        }
    }

    SetBackColor(bgColor, colorBehindBtn?, roundedCorner?, showBorder := 1, borderColor := 0xFFFFFF, txColor?) => this.SetColor(bgColor, txColor?, showBorder, borderColor?, roundedCorner?)
    
    SetColor(bgColor, txColor?, showBorder := 1, borderColor := 0xFFFFFF, roundedCorner?)
    { 
        static BS_BITMAP       := 0x0080
        static BS_FLAT         := 0x8000
        static IS_WIN11        := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
        static NM_CUSTOMDRAW   := -12
        static WM_MOUSEMOVE    := 0x0200
        static WM_MOUSELEAVE   := 0x02A3
        static WS_CLIPSIBLINGS := 0x04000000
        static BTN_STYLE       := (WS_CLIPSIBLINGS | BS_FLAT | BS_BITMAP) 

        this._first         := 1
        this._roundedCorner := roundedCorner ?? (IS_WIN11 ? 9 : 0)
        this._showBorder    := showBorder
        this._clr           := ColorHex(bgColor)
        this._isDark        := _BtnColor.IsColorDark(this._clr)
        this._hoverColor    := _BtnColor.RgbToBgr(BrightenColor(this._clr, this._isDark ? 20 : -20))
        this._pushedColor   := _BtnColor.RgbToBgr(BrightenColor(this._clr, this._isDark ? -10 : 10))
        this._clr           := _BtnColor.RgbToBgr(this._clr)
        this._btnBkColor    := (colorBehindBtn ?? !IS_WIN11) && _BtnColor.RgbToBgr("0x" (this.Gui.BackColor))
        this._borderColor   := _BtnColor.RgbToBgr(borderColor)
        this._isHovering    := false  ; 新增: 追蹤 hover 狀態
        
        if !this.HasProp("_textColor") || IsSet(txColor)
            this._textColor := _BtnColor.RgbToBgr(txColor ?? (this._isDark ? 0xFFFFFF : 0))
        
        if this._btnBkColor
            this.Gui.OnEvent("Close", (*) => DeleteObject(this.__hbrush))

        this.Opt(BTN_STYLE (IsSet(colorBehindBtn) ? " Background" colorBehindBtn : ""))
        this.OnNotify(NM_CUSTOMDRAW, ON_NM_CUSTOMDRAW)

        ; 新增: 使用全局 OnMessage 追蹤滑鼠
        static hovers := Map()
        if !hovers.Count
            OnMessage(WM_MOUSEMOVE, GlobalMouseMove)
        if !hovers.Count
            OnMessage(WM_MOUSELEAVE, GlobalMouseLeave)
        hovers[this.hwnd] := this

        if this._isDark
            SetWindowTheme(this.hwnd, "DarkMode_Explorer")

        SetWindowPos(this.hwnd, 0,,,,, 0x4043)
        this.Redraw()

        ; 全局滑鼠移動處理
        GlobalMouseMove(wParam, lParam, msg, hwnd) {
            if !hovers.Has(hwnd)
                return
            
            btnObj := hovers[hwnd]
            if !btnObj._isHovering {
                btnObj._isHovering := true
                
                ; 註冊離開追蹤
                TRACKMOUSEEVENT := Buffer(16, 0)
                NumPut("UInt", 16, TRACKMOUSEEVENT, 0)
                NumPut("UInt", 0x00000002, TRACKMOUSEEVENT, 4)  ; TME_LEAVE
                NumPut("Ptr", hwnd, TRACKMOUSEEVENT, 8)
                DllCall("TrackMouseEvent", "Ptr", TRACKMOUSEEVENT)
                
                ; 強制重繪
                DllCall("InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", 1)
                DllCall("UpdateWindow", "Ptr", hwnd)
            }
        }

        ; 全局滑鼠離開處理
        GlobalMouseLeave(wParam, lParam, msg, hwnd) {
            if !hovers.Has(hwnd)
                return
                
            btnObj := hovers[hwnd]
            btnObj._isHovering := false
            
            ; 強制重繪
            DllCall("InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow", "Ptr", hwnd)
        }

        ON_NM_CUSTOMDRAW(gCtrl, lParam)
        {
            static CDDS_PREPAINT    := 0x1
            static CDIS_HOT         := 0x40
            static CDRF_DODEFAULT   := 0x0
            static CDRF_SKIPDEFAULT := 0x4
            static DC_BRUSH         := GetStockObject(18)
            static DC_PEN           := GetStockObject(19)
            static DT_CALCRECT      := 0x400
            static DT_WORDBREAK     := 0x10
            static PS_SOLID         := 0
            
            nmcd := NMCUSTOMDRAWINFO(lParam)

            if (nmcd.hdr.code != NM_CUSTOMDRAW 
            || nmcd.hdr.hwndFrom != gCtrl.hwnd
            || nmcd.dwDrawStage  != CDDS_PREPAINT)
                return CDRF_DODEFAULT
            
            isPressed := GetKeyState("LButton", "P")
            isHot     := (nmcd.uItemState & CDIS_HOT)
            brushColor := penColor := (!isHot || this._first ? this._clr : isPressed ? this._pushedColor : this._hoverColor)
            
            rc     := nmcd.rc
            corner := this._roundedCorner
            SetWindowRgn(gCtrl.hwnd, CreateRoundRectRgn(rc.left, rc.top, rc.right, rc.bottom, corner, corner), 1)
            GetWindowRgn(gCtrl.hwnd, rcRgn := CreateRectRgn())
            
            ; 修改: 使用 _isHovering 而不是 Focused
            showBorder := (this._showBorder < 0) || (this._showBorder > 0 && (gCtrl.Focused || this._isHovering))
            
            if (showBorder) {
                penColor := (this._showBorder > 0 && !gCtrl.Focused && !this._isHovering) ? penColor : this._borderColor
                hpen     := CreatePen(PS_SOLID, Abs(this._showBorder), penColor)
                SelectObject(nmcd.hdc, hpen)
                FrameRect(nmcd.hdc, rc, DC_PEN)                
            } else {
                SelectObject(nmcd.hdc, DC_PEN)
                SetDCPenColor(nmcd.hdc, penColor)
            }

            SelectObject(nmcd.hdc, DC_BRUSH)
            SetDCBrushColor(nmcd.hdc, brushColor)
            RoundRect(nmcd.hdc, rc.left, rc.top, rc.right-1, rc.bottom-1, corner, corner)

            textPtr     := StrPtr(gCtrl.Text)
            dwTextFlags := this.GetTextFlags(&hCenter, &vCenter, &right, &bottom)
            SetBkMode(nmcd.hdc, 0)
            SetTextColor(nmcd.hdc, this._textColor)

            CopyRect(rcT := RECT(), nmcd.rc)
            DrawText(nmcd.hdc, textPtr, -1, rcT, DT_CALCRECT | dwTextFlags)

            if (hCenter || right)
                offsetW := ((nmcd.rc.width - rcT.Width - (right * 4)) / (hCenter ? 2 : 1))

            if (bottom || vCenter)
                offsetH := ((nmcd.rc.height - rct.Height - (bottom * 4)) / (vCenter ? 2 : 1))
                
            OffsetRect(rcT, offsetW ?? 2, offsetH ?? 2)
            DrawText(nmcd.hdc, textPtr, -1, rcT, dwTextFlags)

            if this._first
                this._first := 0

            DeleteObject(rcRgn)
            
            if IsSet(hpen)
                DeleteObject(hpen)

            SetWindowPos(this.hwnd, 0, 0, 0, 0, 0, 0x4043)

            return CDRF_SKIPDEFAULT 
        }

        BrightenColor(clr, perc := 5) => _BtnColor.BrightenColor(clr, perc)
        ColorHex(clr) => Number(((Type(clr) = "string" && SubStr(clr, 1, 2) != "0x") ? "0x" clr : clr))
        CopyRect(lprcDst, lprcSrc) => DllCall("CopyRect", "ptr", lprcDst, "ptr", lprcSrc, "int")
        CreateRectRgn(nLeftRect := 0, nTopRect := 0, nRightRect := 0, nBottomRect := 0) => DllCall('Gdi32\CreateRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'ptr')
        CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse) => DllCall('Gdi32\CreateRoundRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidthEllipse, 'int', nHeightEllipse, 'ptr')
        CreatePen(fnPenStyle, nWidth, crColor) => DllCall('Gdi32\CreatePen', 'int', fnPenStyle, 'int', nWidth, 'uint', crColor, 'ptr')
        DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')
        DrawText(hDC, lpchText, nCount, lpRect, uFormat) => DllCall("DrawText", "ptr", hDC, "ptr", lpchText, "int", nCount, "ptr", lpRect, "uint", uFormat, "int")
        FrameRect(hDC, lprc, hbr) => DllCall("FrameRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")
        GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')
        GetWindowRgn(hWnd, hRgn, *) => DllCall("User32\GetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int")
        OffsetRect(lprc, dx, dy) => DllCall("User32\OffsetRect", "ptr", lprc, "int", dx, "int", dy, "int")
        RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nWidth, nHeight) => DllCall('Gdi32\RoundRect', 'ptr', hdc, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidth, 'int', nHeight, 'int')
        SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')
        SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')
        SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')
        SetDCPenColor(hdc, crColor) => DllCall('Gdi32\SetDCPenColor', 'ptr', hdc, 'uint', crColor, 'uint')
        SetTextColor(hdc, color) => DllCall("SetTextColor", "Ptr", hdc, "UInt", color)
        SetWindowPos(hWnd, hWndInsertAfter, X := 0, Y := 0, cx := 0, cy := 0, uFlags := 0x40) => DllCall("User32\SetWindowPos", "ptr", hWnd, "ptr", hWndInsertAfter, "int", X, "int", Y, "int", cx, "int", cy, "uint", uFlags, "int")
        SetWindowRgn(hWnd, hRgn, bRedraw) => DllCall("User32\SetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int", bRedraw, "int")
        SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(appName), "ptr", subIdList ?? 0)
    }

    ; 新增: 移除不需要的 OnMessage 方法
    ; OnMessage 已改用全局處理,此方法可刪除

    static RGB(R := 255, G := 255, B := 255) => ((R << 16) | (G << 8) | B)
    static BrightenColor(clr, perc := 5) => ((p := perc / 100 + 1), _BtnColor.RGB(Round(Min(255, (clr >> 16 & 0xFF) * p)), Round(Min(255, (clr >> 8 & 0xFF) * p)), Round(Min(255, (clr & 0xFF) * p))))
    static IsColorDark(clr) => (((clr >> 16 & 0xFF) / 255 * 0.2126 + (clr >> 8 & 0xFF) / 255 * 0.7152 + (clr & 0xFF) / 255 * 0.0722) < 0.5)
    static RgbToBgr(color) => (Type(color) = "string") ? this.RgbToBgr(Number(SubStr(Color, 1, 2) = "0x" ? color : "0x" color)) : (Color >> 16 & 0xFF) | (Color & 0xFF00) | ((Color & 0xFF) << 16)
}

; ===== 必要的 Buffer 類別 (v2.0 兼容) =====

Buffer.Prototype.PropDesc := PropDesc
PropDesc(buf, name, ofst, type, ptr?) {
    if (ptr??0)
        NumPut(type, NumGet(ptr, ofst, type), buf, ofst)
    buf.DefineProp(name, {
        Get: NumGet.Bind(, ofst, type),
        Set: (p, v) => NumPut(type, v, buf, ofst)
    })
}

class NMHDR extends Buffer {
    __New(ptr?) {
        super.__New(A_PtrSize * 2 + 4)
        this.PropDesc("hwndFrom", 0, "uptr", ptr?)
        this.PropDesc("idFrom", A_PtrSize,"uptr", ptr?)   
        this.PropDesc("code", A_PtrSize * 2 ,"int", ptr?)     
    }
}

class RECT extends Buffer { 
    __New(ptr?) {
        super.__New(16, 0)
        for i, prop in ["left", "top", "right", "bottom"]
            this.PropDesc(prop, 4 * (i-1), "int", ptr?)
        this.DefineProp("Width", {Get: rc => (rc.right - rc.left)})
        this.DefineProp("Height", {Get: rc => (rc.bottom - rc.top)})
    }
}

class NMCUSTOMDRAWINFO extends Buffer {
    __New(ptr?) {
        static x64 := (A_PtrSize = 8)
        super.__New(x64 ? 80 : 48)
        this.hdr := NMHDR(ptr?)
        this.rc  := RECT((ptr??0) ? ptr + (x64 ? 40 : 20) : unset)
        this.PropDesc("dwDrawStage", x64 ? 24 : 12, "uint", ptr?)  
        this.PropDesc("hdc"        , x64 ? 32 : 16, "uptr", ptr?)          
        this.PropDesc("dwItemSpec" , x64 ? 56 : 36, "uptr", ptr?)   
        this.PropDesc("uItemState" , x64 ? 64 : 40, "int", ptr?)   
        this.PropDesc("lItemlParam", x64 ? 72 : 44, "iptr", ptr?)
    }
}

if (A_ScriptName = "ColorButton.ahk") {
    ; Example - ColorButton
    MyGui := Gui()
MyGui.SetFont("s10", "Microsoft JhengHei")
MyGui.BackColor := 0x202020

; 深色主題
DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.hwnd, "UInt", 20, "Ptr*", 1, "UInt", 4)

; 測試 1: Hover 時顯示 2px 紅色邊框
btn1 := MyGui.Add("Button", "x20 y20 w150 h40", "Hover 顯示 2px")
btn1.SetColor(0x0078D4, 0xFFFFFF, 2, 0xFF0000)

; 測試 2: Hover 時顯示 5px 黃色邊框
btn2 := MyGui.Add("Button", "x20 y70 w150 h40", "Hover 顯示 5px")
btn2.SetColor(0x0078D4, 0xFFFFFF, 5, 0xFFFF00)

; 測試 3: 永遠顯示 2px 綠色邊框
btn3 := MyGui.Add("Button", "x20 y120 w150 h40", "永遠顯示 2px")
btn3.SetColor(0x0078D4, 0xFFFFFF, -2, 0x00FF00)

; 測試 4: 無邊框
btn4 := MyGui.Add("Button", "x20 y170 w150 h40", "無邊框")
btn4.SetColor(0x0078D4, 0xFFFFFF, 0)

MyGui.Add("Text", "x20 y220 cWhite", "試試把滑鼠移到按鈕上!")

MyGui.Show("w190")
    }
    