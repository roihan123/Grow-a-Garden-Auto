; Virage Grow a Garden Macro [LUNAR GLOW UPDATE]
#SingleInstance, Force
#NoEnv
SetWorkingDir %A_ScriptDir%
#WinActivateForce
SetMouseDelay, -1 
SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1   

settingsFile := A_ScriptDir "\settings.ini"

IniRead, userName, %settingsFile%, Main, RobloxUser, UnknownPlayer

global webhookURL := "https://discord.com/api/webhooks/1193614908139503616/erD8p_BAoCkL4_6jxLToZU73hIAZt67QJERK_ZUwylr9svPACUj0FWEDWVfKpN6klVBu"

SendWebhook(msg) {
    global webhookURL
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    json := "{""content"":""[" timestamp "] " msg """}"

    try {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", webhookURL, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(json)
    } 
}

global gearAutoActive := false
global eggAutoActive  := false


global actionQueue := []




; ======== Global Data & Defaults ========
seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Orange Tulip"
             , "Tomato Seed", "Corn Seed", "Daffodil Seed", "Watermelon Seed"
             , "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Coconut Seed"
             , "Cactus Seed", "Dragon Fruit Seed", "Mango Seed", "Grape Seed"
             , "Mushroom Seed", "Pepper Seed", "Cacao Seed"] ;

gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
             , "Godly Sprinkler", "Lightning Rod", "Master Sprinkler", "Favorite Tool"]

slotChoice             := 1

; ======== Script State Flags ========
started    := false

Gosub, ShowGui

ShowGui:
    Gui, Destroy
    Gui, +Resize +MinimizeBox +SysMenu
    Gui, Margin, 10, 10
    Gui, Color, 0x202020
    Gui, Font, s10 cWhite, Segoe UI

    Gui, Font, s9 cWhite, Segoe UI
    Gui, Add, GroupBox, x20 y50 w260 h260 cWhite, Gear Shop Items
    Loop, % gearItems.Length() {
        IniRead, gVal, %settingsFile%, Gear, Item%A_Index%, 0
        y := 70 + (A_Index - 1) * 25
        Gui, Add, Checkbox, % "x40 y" y " vGearItem" A_Index " cWhite " . (gVal ? "Checked" : ""), % gearItems[A_Index]
    }

    Gui, Add, GroupBox, x300 y50 w260 h260 cWhite, Egg Shop
    IniRead, EggBuyAll, %settingsFile%, Egg, BuyAll, 0
    Gui, Add, Checkbox, % "x320 y70 vEggBuyAll cWhite " . (EggBuyAll ? "Checked" : ""), Buy All Eggs

    Gui, Add, GroupBox, x20 y330 w560 h300 cWhite, Seed Shop Items
    Loop, % seedItems.Length() {
        IniRead, sVal, %settingsFile%, Seed, Item%A_Index%, 0
        col := (A_Index > 9 ? 300 : 40)
        idx := (A_Index > 9 ? A_Index-9 : A_Index)
        y := 350 + (idx - 1) * 25
        Gui, Add, Checkbox, % "x" col " y" y " vSeedItem" A_Index " cWhite " . (sVal ? "Checked" : ""), % seedItems[A_Index]
    }
        Gui, Tab
    Gui, Font, s10 cWhite Bold, Segoe UI
    Gui, Add, Button, x50 y645 w200 h40 gStartScan Background202020, Start Macro (F5)
    Gui, Add, Button, x350 y645 w200 h40 gQuit Background202020, Exit Macro (F7)

    Gui, Show, w620 h740, Virage Grow a Garden Macro [LUNAR GLOW UPDATE]
Return

; ========== ITEM SELECTION ==========
UpdateSelectedItems:
    Gui, Submit, NoHide
    selectedSeedItems := []
    Loop, % seedItems.Length() {
        if (SeedItem%A_Index%)
            selectedSeedItems.Push(seedItems[A_Index])
    }
    selectedGearItems := []
    Loop, % gearItems.Length() {
        if (GearItem%A_Index%)
            selectedGearItems.Push(gearItems[A_Index])
    }
Return


GetSelectedItems() {
    result := ""
    if (selectedSeedItems.Length()) {
        result .= "Seed Items:`n"
        for _, name in selectedSeedItems
            result .= "  - " name "`n"
    }
    if (selectedGearItems.Length()) {
        result .= "Gear Items:`n"
        for _, name in selectedGearItems
            result .= "  - " name "`n"
    }
    return result
}

; ========== MAIN ENTRY ==========
StartScan:
    currentSection := "StartScan"
    started    := true

if WinExist("Roblox")
    {
        WinActivate   ; activates the last found window (Roblox)
        WinWaitActive, , , 2  ; wait up to 2s for it to become active
    }
    Gui, Submit, NoHide

    
    Gosub, UpdateSelectedItems
    itemsText := GetSelectedItems()

    ToolTip, Starting macro

    Sleep, 500
    Gosub, alignment
    Gosub, equipRecallWrench
    ToolTip 

    Sleep, 500

        actionQueue.Push("buyGearSeed")
        gearAutoActive := true
        SetTimer, AutoBuyGearSeed, 300000  

        actionQueue.Push("buyEggShop")
        eggAutoActive := true
        SetTimer, AutoBuyEggShop, 1800000 



    while (started) {
        if ( actionQueue.Length() ) {
            ToolTip  
            next := actionQueue.RemoveAt(1)
            Gosub, % next
            Sleep, 500
        } else {
            ToolTip, Waiting... 
            Sleep, 500
        }
    }
Return

; ========== BUY ROUTINES ==========

buyGearSeed:
    currentSection := "buyGearSeed"
    if (selectedSeedItems.Length())
        Gosub, seedShopPath
    if (selectedGearItems.Length())
        Gosub, gearShopPath
Return

buyEggShop:
    currentSection := "buyEggShop"
if (EggBuyAll) {
    Gosub, EggShopPath
} 
Return

AutoBuyGearSeed:
    actionQueue.Push("buyGearSeed")
Return

AutoBuyEggShop:
    actionQueue.Push("buyEggShop")
Return

alignment:
    Sleep, 200
    Send, {i down}
    Sleep, 1200
    Send, {i up}
    Sleep, 200
    Send, {o down}
    Sleep, 700
    Send, {o up}
    Sleep, 200
Return

equipRecallWrench:
    Sleep, 200
    SafeClick(256,53)
    Sleep, 500
    SafeClick(1139,662)
    Sleep, 50
    Send, {r}
    Sleep, 50
    Send, {e}
    Sleep, 50
    Send, {c}
    Sleep, 50
    Send, {a}
    Sleep, 50
    Send, {l}
    Sleep, 50
    Send, {l}
    Sleep, 500
SafeDrag(665, 711, 740, 1000)
Sleep, 500
    SafeClick(1000,500)
    Sleep, 200
Return

DoubleClick:
    Sleep, 300
    SafeClick(960,130)
    Sleep, 300
    SafeClick(950,140)
    Sleep, 300
Return


SafeClick(x, y){
    CoordMode, Mouse, Screen
    MouseMove, x, y, 20
    MouseClick, Left, x, y
}

SafeDrag(x1, y1, x2, y2, speed:=20){
    CoordMode, Mouse, Screen
    MouseClickDrag, Left, x1, y1, x2, y2, speed
}



EggShopPath:
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 500
    SafeClick(1250, 141)
    Sleep, 500
    Send, {d down}
    Sleep, 18000
    Send, {d up}
    Sleep, 500
    Send, {i down}
    Sleep, 300
    Send, {i up}
    Sleep, 500
    Send, {e}
    Sleep, 500
;1st egg
    SafeClick(900,680)
    Sleep, 300
    SafeClick(1305,365)
    Sleep, 200
    Send, {s down}
    Sleep, 220
    Send, {s up}
    Sleep, 500
    Send, {e}
    Sleep, 500
;2nd egg
    SafeClick(900,680)
    Sleep, 300
    SafeClick(1305,365)
    Sleep, 200
    Send, {w down}
    Sleep, 450
    Send, {w up}
    Sleep, 500
    Send, {e}
    Sleep, 500
;3rd egg
    SafeClick(900,680)
    Sleep, 300
    SafeClick(1305,365)
    Sleep, 500
    SafeClick(1000,150)
    Sleep, 500
    Gosub, alignment
    Sleep, 200
Return

seedShopPath:
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 500
    SafeClick(675, 130)
    Sleep, 500
    Send {e}
    Sleep, 2000
    SafeClick(1305, 351)
    Sleep, 300
  PixelSearch, px, py, 80, 50, 1900, 900, 0xFFCC00, 0, Fast RGB
    if (!ErrorLevel) {
    Sleep, 300
    Send, {WheelUp 40}
    Sleep, 300
    for index, item in selectedSeedItems {
        label := StrReplace(item, " ", "")
        Gosub, %label%
        Sleep, 300
    }
    }
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
    SafeClick(1000,150)
    Sleep, 500
Return


gearShopPath:
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 500
    Send {2}
    Sleep, 500
    SafeClick(1100, 450)
    Sleep, 1000
    Send {e}
    Sleep, 1500
    SafeClick(1100, 450)
    Sleep, 200
    SafeClick(1100, 500)
    Sleep, 200
    SafeClick(1050, 510)
    Sleep, 2000
    SafeClick(1305, 351)
    Sleep, 300
  PixelSearch, px, py, 80, 50, 1900, 900, 0xFFCC00, 0, Fast RGB
    if (!ErrorLevel) {
    Sleep, 300
    Send, {WheelUp 40}
    Sleep, 300
    for index, item in selectedGearItems {
        label := StrReplace(item, " ", "")
        Gosub, %label%
        Sleep, 300
    }
    }
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
    SafeClick(1000,150)
    Sleep, 500
Return

; ========== ITEM CALLBACKS ==========
CarrotSeed:
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
    Loop, 25 {
        SafeClick(750, 630)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 300
Return
StrawberrySeed:
    Sleep, 500
    SafeClick(750, 750)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 640)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 300
return
BlueberrySeed:
    Sleep, 500
    Send, {WheelDown 3}
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 650)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
OrangeTulip:
    Sleep, 500
    Send, {WheelDown 3}
    Sleep, 500
    SafeClick(750, 800)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 650)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
TomatoSeed:
    Sleep, 500
    Send, {WheelDown 4}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 680)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
CornSeed:
    Sleep, 500
    Send, {WheelDown 5}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 690)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
DaffodilSeed:
    Sleep, 500
    Send, {WheelDown 7}
    Sleep, 500
    SafeClick(750, 840)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 700)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
WatermelonSeed:
    Sleep, 500
    Send, {WheelDown 9}
    Sleep, 500
    SafeClick(750, 830)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 700)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
PumpkinSeed:
    Sleep, 500
    Send, {WheelDown 12}
    Sleep, 500
    SafeClick(750, 670)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 720)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
AppleSeed:
    Sleep, 500
    Send, {WheelDown 15}
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 730)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
BambooSeed:
    Sleep, 500
    Send, {WheelDown 15}
    Sleep, 500
    SafeClick(750, 700)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 730)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
CoconutSeed:
    Sleep, 500
    Send, {WheelDown 16}
    Sleep, 500
    SafeClick(750, 800)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 750)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 550)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
CactusSeed:
    Sleep, 500
    Send, {WheelDown 18}
    Sleep, 500
    SafeClick(750, 800)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 750)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 550)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
DragonFruitSeed:
    Sleep, 500
    Send, {WheelDown 21}
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 770)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 550)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
MangoSeed:
    Sleep, 500
    Send, {WheelDown 21}
    Sleep, 500
    SafeClick(750, 800)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 780)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
GrapeSeed:
    Sleep, 500
    Send, {WheelDown 24}
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 800)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
MushroomSeed:
    Sleep, 500
    Send, {WheelDown 24}
    Sleep, 500
    SafeClick(750, 820)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 820)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
PepperSeed:
    Sleep, 500
    Send, {WheelDown 27}
    Sleep, 500
    SafeClick(750, 820)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 820)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
CacaoSeed:
    Sleep, 500
    Send, {WheelDown 30}
    Sleep, 500
    SafeClick(750, 820)
    Sleep, 500
    Loop, 25
    {
        SafeClick(750, 820)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return


WateringCan: 
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 630)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
return
Trowel:
    Sleep, 500
    SafeClick(750, 750)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 640)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
RecallWrench:
    Sleep, 500
    Send, {WheelDown 3}
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 650)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
BasicSprinkler:
    Sleep, 500
    Send, {WheelDown 3}
    Sleep, 500
    SafeClick(750, 800)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 650)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
AdvancedSprinkler:
    Sleep, 500
    Send, {WheelDown 4}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 680)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
GodlySprinkler:
    Sleep, 500
    Send, {WheelDown 5}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 690)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
LightningRod:
    Sleep, 500
    Send, {WheelDown 7}
    Sleep, 500
    SafeClick(750, 840)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 700)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
MasterSprinkler:
      Sleep, 500
    Send, {WheelDown 9}
    Sleep, 500
    SafeClick(750, 830)
    Sleep, 500
    Loop, 10
    {
        SafeClick(750, 700)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Send, {WheelUp 40}
    Sleep, 500
return
FavoriteTool:
    Sleep, 500
    Send, {WheelDown 10}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 600
    Loop, 5 {
        SafeClick(750, 500)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 600)
    Sleep, 500
Return

; ========== HOTKEYS & INCLUDE ==========

SaveSettings:
    Gui, Submit, NoHide
IniWrite, %userName%, %settingsFile%, Main, RobloxUser


    ; — now write them out —
    IniWrite, % (EggBuyAll ? 1 : 0), %settingsFile%, Egg, BuyAll

    Loop, % gearItems.Length()
        IniWrite, % (GearItem%A_Index% ? 1 : 0), %settingsFile%, Gear, Item%A_Index%

    Loop, % seedItems.Length()
        IniWrite, % (SeedItem%A_Index% ? 1 : 0), %settingsFile%, Seed, Item%A_Index%
Return

; ─── temp 
/*
F4::
    actionQueue.Push("seedShopPath")
    actionQueue.Push("slot" slotChoice "gearShopPath")
Return

F3::
    ; actionQueue.Push("sell")
    actionQueue.Push("slot" slotChoice "EggShopPath")
Return
*/

; ─── common STOP/RELOAD routine ───────────────────────────────────────────────
StopMacro(terminate := 1) {
    Gui, Submit, NoHide
    Sleep, 50
    started := false
    Gosub, SaveSettings
    Gui, Destroy
    if (terminate)
        ExitApp
}


; ─── hook window close [×] and Esc key ────────────────────────────────────────
GuiClose:
GuiEscape:
    StopMacro(1)
    return

; ─── your GUI “Exit Macro (F7)” button ──────────────────────────────────────
Quit:
    StopMacro(1)
    return

; ─── F7 hotkey now cleanly reloads ───────────────────────────────────────────
F7::
    StopMacro(1)  ; prepare for reload, but don’t ExitApp
    Reload        ; AutoHotkey’s built‑in single‑step restart
    return

; ─── F5 still starts your scan ───────────────────────────────────────────────
F5::Gosub, StartScan

; ─── ensure you still include Vis2 and other directives ─────────────────────
#MaxThreadsPerHotkey, 2
#Include %A_ScriptDir%\lib\Vis2.ahk
