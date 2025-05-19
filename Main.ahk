; Virage Grow a Garden Macro [Blood Moon Update v2]

#SingleInstance, Force
#NoEnv
SetWorkingDir %A_ScriptDir%
#WinActivateForce
SetMouseDelay, -1 
SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1


settingsFile := A_ScriptDir "\settings.ini"

IniRead, SendDiscord, %settingsFile%, Settings, SendDiscord, 1
IniRead, webhookURL,   %settingsFile%, Settings, WebhookURL


webOptions := {}
webOptions["WebhookEnabled"] := SendDiscord
webOptions["WebhookLink"]    := webhookURL

WebhookPostSimple(content) {
    global webOptions
      if !webOptions.WebhookEnabled || !webOptions.WebhookLink
        return

    json := "{""content"":""" content """}"
    wh := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    wh.Open("POST", webOptions.WebhookLink, false)
    wh.SetRequestHeader("Content-Type", "application/json")
    wh.Send(json)

    if (wh.Status != 204){
        MsgBox, 16, Webhook Error, % "HTTP " wh.Status "`n" wh.ResponseText
}
}



; ======== Global Data & Defaults ========
seedItems   := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Orange Tulip"
               , "Tomato Seed", "Corn Seed", "Daffodil Seed", "Watermelon Seed"
               , "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Coconut Seed"
               , "Cactus Seed", "Dragon Fruit Seed", "Mango Seed", "Grape Seed"          ,"Mushroom Seed", "Pepper Seed", "Cacao Seed", "BeanstalkSeed"]

gearItems   := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
               , "Godly Sprinkler", "Lightning Rod", "Master Sprinkler"]

moonItems   := ["Mysterious Crate", "Night Egg", "Night Seed Pack", "Crimson Vine Seed"
               , "Moon Melon Seed", "Star Caller", "Blood Kiwi", "Blood Hedgehog"
               , "Blood Owl"]

global lastMoonHour := ""  
SetTimer, PushMoonShop, 60000 



; ======== Script State Flags ========
started    := false

IniRead, FirstRun, %settingsFile%, Settings, FirstRun, 1
if (FirstRun)
    Gosub, ShowWelcome
else
    Gosub, ShowGui
return

ShowWelcome:
    Gui, 99: Destroy
    Gui, 99: +AlwaysOnTop -Resize +ToolWindow
    Gui, 99: Margin, 10, 10
    Gui, 99: Add, Picture, x0 y0 w768 h432, %A_ScriptDir%\Images\welcome.png
    Gui, 99: Add, Button, xm y+10 w200 h40 gContinue, Continue
    Gui, 99: Show, w788 h492 Center, Welcome to Virage's Grow a Garden Macro Blood Moon Update v2
return


Continue:
    Gui, 99: Destroy

IniWrite, 0, %settingsFile%, Settings, FirstRun

if (webhookURL = "") {
    msg =
    (
    Would you like to enter your Discord webhook URL now?
    Yes = paste webhook URL & enable Discord notifications
    No  = skip Discord notifications entirely
    )

    MsgBox, 4, Discord Webhook Setup, %msg%
    IfMsgBox, No
        webhookURL := "" 
    else {
        InputBox, webhookURL, Discord Webhook URL, Please paste your Discord webhook URL:
        if ErrorLevel
            ExitApp
    }
    IniWrite, %webhookURL%, %settingsFile%, Settings, WebhookURL
    webOptions["WebhookLink"] := webhookURL
}


    Gosub, ShowGui
return


ShowGui:
    Gui, Destroy
    Gui, +Resize +MinimizeBox +SysMenu
    Gui, Margin, 10, 10

    IniRead, uiColor, %settingsFile%, Settings, UIColor, 202020
    Gui, Color, 0x%uiColor%
    Gui, Font, s10 cWhite, Segoe UI

    IniRead, GearBuyAll, %settingsFile%, Gear, BuyAll, 0
    IniRead, EggBuyAll,  %settingsFile%, Egg,  BuyAll, 0
    IniRead, SeedBuyAll, %settingsFile%, Seed, BuyAll, 0
    IniRead, MoonBuyAll, %settingsFile%, Moon, BuyAll, 0

    ; --- Main Tab Control ---
    Gui, Add, Tab2, x10 y10 w600 h450 vMainTab, Gear|Egg|Seeds|Moon|Donate|Settings

    ; --- Gear Shop Tab ---
    Gui, Tab, Gear
    Gui, Font, s9 cWhite, Segoe UI
    Gui, Add, GroupBox, x20 y40 w560 h300 cWhite, Gear Shop Items
    options := "x40 y70 vGearBuyAll cWhite gSaveSettings " (GearBuyAll ? "Checked" : "")
    Gui, Add, Checkbox, %options%, Buy All Gear
    Loop, % gearItems.Length() {
        IniRead, gVal, %settingsFile%, Gear, Item%A_Index%, 0
        y := 100 + (A_Index - 1) * 25
        options := "x40 y" y " vGearItem" A_Index " cWhite gSaveSettings " (gVal ? "Checked" : "")
        Gui, Add, Checkbox, %options%, % gearItems[A_Index]
    }

    ; --- Egg Shop Tab ---
    Gui, Tab, Egg
    Gui, Font, s9 cWhite, Segoe UI
    Gui, Add, GroupBox, x20 y40 w560 h200 cWhite, Egg Shop
    options := "x40 y70 vEggBuyAll cWhite gSaveSettings " (EggBuyAll ? "Checked" : "")
    Gui, Add, Checkbox, %options%, Buy All Eggs

    ; --- Seed Shop Tab ---
    Gui, Tab, Seeds
    Gui, Font, s9 cWhite, Segoe UI
    Gui, Add, GroupBox, x20 y40 w560 h330 cWhite, Seed Shop Items
    options := "x40 y70 vSeedBuyAll cWhite gSaveSettings " (SeedBuyAll ? "Checked" : "")
    Gui, Add, Checkbox, %options%, Buy All Seeds
    Loop, % seedItems.Length() {
        IniRead, sVal, %settingsFile%, Seed, Item%A_Index%, 0
        col := (A_Index > 10 ? 300 : 40)
        idx := (A_Index > 10 ? A_Index - 10 : A_Index)
        y := 120 + (idx - 1) * 25
        options := "x" col " y" y " vSeedItem" A_Index " cWhite gSaveSettings " (sVal ? "Checked" : "")
        Gui, Add, Checkbox, %options%, % seedItems[A_Index]
    }

    ; --- Moon Shop Tab ---
    Gui, Tab, Moon
    Gui, Font, s9 cWhite, Segoe UI
    Gui, Add, GroupBox, x20 y40 w560 h200 cWhite, Moon Shop Items
    options := "x40 y70 vMoonBuyAll cWhite gSaveSettings " (MoonBuyAll ? "Checked" : "")
    Gui, Add, Checkbox, %options%, Buy All Moon Items
    Loop, % moonItems.Length() {
        IniRead, mVal, %settingsFile%, Moon, Item%A_Index%, 0
        col := (A_Index > 5 ? 300 : 40)
        idx := (A_Index > 5 ? A_Index - 5 : A_Index)
        y := 120 + (idx - 1) * 25
        options := "x" col " y" y " vMoonItem" A_Index " cWhite gSaveSettings " (mVal ? "Checked" : "")
        Gui, Add, Checkbox, %options%, % moonItems[A_Index]
    }

; --- Donate Tab ---
Gui, Tab, Donate
Gui, Font, s9 cWhite, Segoe UI
Gui, Add, Button, x15  y50 w110 h30 gDonate100,    100 Robux
Gui, Add, Button, x135 y50 w110 h30 gDonate500,    500 Robux
Gui, Add, Button, x255 y50 w110 h30 gDonate1000,  1,000 Robux
Gui, Add, Button, x375 y50 w110 h30 gDonate2500,  2,500 Robux
Gui, Add, Button, x495 y50 w110 h30 gDonate10000,10,000 Robux


Gui, Font, s10 cWhite, Segoe UI
Gui, Add, Text, x80 y100 w460 +Center, Top Donators:

; Row 1
Gui, Font, s9 cWhite, Segoe UI
Gui, Add, Picture, x160 y118 w32 h32, %A_ScriptDir%\Images\avatars\KeoniHater666.png
Gui, Add, Text,    x200 y130 w220 h32, KeoniHater666
Gui, Add, Text,    x340 y130 w80  h32 +Right, 2000

; Row 2
Gui, Add, Picture, x160 y162 w32 h32, %A_ScriptDir%\Images\avatars\TheRealXZRpro.png
Gui, Add, Text,    x200 y170 w220 h32, TheRealXZRpro
Gui, Add, Text,    x340 y170 w80  h32 +Right, 100

; Row 3
Gui, Add, Picture, x160 y202 w32 h32, %A_ScriptDir%\Images\avatars\BLXRMAD.png
Gui, Add, Text,    x200 y210 w220 h32, BLXRMAD
Gui, Add, Text,    x340 y210 w80  h32 +Right, 100

; Row 4
Gui, Add, Picture, x160 y242 w32 h32, %A_ScriptDir%\Images\avatars\peanut1268a.png
Gui, Add, Text,    x200 y250 w220 h32, peanut1268a
Gui, Add, Text,    x340 y250 w80  h32 +Right, 100

; Row 5
Gui, Add, Picture, x160 y278 w32 h32, %A_ScriptDir%\Images\avatars\Gurkendippp.png
Gui, Add, Text,    x200 y290 w220 h32, Gurkendippp
Gui, Add, Text,    x340 y290 w80  h32 +Right, 100

; Row 6
Gui, Add, Picture, x160 y318 w32 h32, %A_ScriptDir%\Images\avatars\Freezy_Zer0.png
Gui, Add, Text,    x200 y330 w220 h32, Freezy_Zer0
Gui, Add, Text,    x340 y330 w80  h32 +Right, 100

; Row 7
Gui, Add, Picture, x160 y370 w32 h32
Gui, Add, Text,    x200 y370 w220 h32, NA
Gui, Add, Text,    x340 y370 w80  h32 +Right, 0

; Row 8
Gui, Add, Picture, x160 y410 w32 h32
Gui, Add, Text,    x200 y410 w220 h32, NA
Gui, Add, Text,    x340 y410 w80  h32 +Right, 0



    ; --- Settings Tab ---
    Gui, Tab, Settings
    Gui, Font, s9 cWhite, Segoe UI

    IniRead, SendDiscord, %settingsFile%, Settings, SendDiscord, 1
    IniRead, webhookURL, %settingsFile%, Settings, WebhookURL

options.WebhookImportantOnly := 0   

checkOpts := "x20 y160 vSendDiscord gSaveSettings "
if (SendDiscord)
    checkOpts .= "Checked"
Gui, Add, Checkbox, %checkOpts%, Enable Discord notifications


    Gui, Add, Text, x20 y40, Discord Webhook URL:
    Gui, Add, Edit, x20 y60 w500 vWebhookURL gSaveSettings Background%uiColor% cBlack, %webhookURL%
    Gui, Add, Text, x20 y100, UI Color:
    Gui, Add, Edit, x20 y120 w100 vUIColor gSaveSettings Background%uiColor% cBlack, %uiColor%

    ; --- Action Buttons ---
    Gui, Tab  ; back to main
    Gui, Font, s10 cWhite Bold, Segoe UI
    Gui, Add, Button, x120 y500 w180 h30 gStartScan Background202020, Start Macro (F5)
    Gui, Add, Button, x320 y500 w180 h30 gQuit       Background202020, Exit Macro (F7)

    Gui, Show, w620 h600, Virage Grow a Garden Macro [Blood Moon Update v2]
return

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
    selectedMoonItems := []
    Loop, % moonItems.Length() {
        if (MoonItem%A_Index%)
            selectedMoonItems.Push(moonItems[A_Index])
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
    if (selectedMoonItems.Length()) {
        result .= "Moon Items:`n"
        for _, name in selectedMoonItems
            result .= "  - " name "`n"
    }
    return result
}


; ========== MAIN ENTRY ==========
StartScan:
    Gosub, SaveSettings

    started := true


altIDs := []    
actionQueue := []

if WinExist("Roblox")
    {
        WinActivate   ; activates the last found window (Roblox)
        WinWaitActive, , , 2  ; wait up to 2s for it to become active
    }
    Gui, Submit, NoHide

WinGet, idList, List, ahk_exe RobloxPlayerBeta.exe
if (idList >= 1) {
    mainID := idList1
}
if (idList >= 2) {
    Loop, % idList {
        if (A_Index = 1)
            continue
        altIDs.Push(idList%A_Index%)
    }
}

    Gosub, UpdateSelectedItems
    itemsText := GetSelectedItems()

webhookPostSimple("Macro **started**!")

    ToolTip, Starting macro
    Sleep, 500
    Gosub, alignment
    ToolTip 

    Sleep, 500

        actionQueue.Push("buySeedShop")
        SetTimer, AutoBuySeed, 300000 
        actionQueue.Push("buyGearShop")
        SetTimer, AutoBuyGear, 300000  
        actionQueue.Push("buyEggShop")
        SetTimer, AutoBuyEggShop, 1800000 

 while (started) {
        while (actionQueue.Length()) {
            Tooltip
            next := actionQueue.RemoveAt(1)
            Gosub, % next
            Sleep, 500
        }
        ToolTip, Waiting for new restock
        Sleep, 500
}
Return

; ========== MORE ==========

alignment:
 global mainID, altIDs

    for index, winID in altIDs {
        WinActivate % "ahk_id " winID
        WinWaitActive, ahk_id %winID%,, 2
Loop, 40 {
        Send, {WheelUp}
        Sleep, 20
    }

    Sleep, 500

    Loop, 6 {
        Send, {WheelDown}
        Sleep, 20
    }
    }


    WinActivate % "ahk_id " mainID
Loop, 40 {
        Send, {WheelUp}
        Sleep, 20
    }

    Sleep, 500

    Loop, 6 {
        Send, {WheelDown}
        Sleep, 20
    }
Return

; ========== Donation Handlers ==========

Donate100:
    Run, https://www.roblox.com/game-pass/1197306369/100-Donation
return

Donate500:
    Run, https://www.roblox.com/game-pass/1222540123/500-Donation
return

Donate1000:
    Run, https://www.roblox.com/game-pass/1222262383/1000-Donation
return

Donate2500:
    Run, https://www.roblox.com/game-pass/1222306189/2500-Donation
return

Donate10000:
    Run, https://www.roblox.com/game-pass/1220930414/10-000-Donation
return



; ========== BUY ROUTINES ==========

buySeedShop:
    if (SeedBuyAll) {
        Gosub, seedShopPathAll
        Return  
    }
    if (selectedSeedItems.Length())
        Gosub, seedShopPath
Return

buyGearShop:
    if (GearBuyAll) {
        Gosub, gearShopPathAll
        Return
    }
    if (selectedGearItems.Length())
        Gosub, gearShopPath
Return

buyMoonShop:
    if (MoonBuyAll) {
        Gosub, redMoonPathAll
        Return
    }
    if (selectedMoonItems.Length())
        Gosub, redMoonPath
Return

buyEggShop:
if (EggBuyAll) {
    Gosub, EggShopPath
} 
Return


; ========== COLLECTING LOOP ==========


DoubleClick:
    Sleep, 300
    SafeClick(960,130)
    Sleep, 300
    SafeClick(950,140)
    Sleep, 300
Return

AutoBuySeed:
    actionQueue.Push("buySeedShop")
Return

AutoBuyGear:
    actionQueue.Push("buyGearShop")
Return

AutoBuyEggShop:
    actionQueue.Push("buyEggShop")
Return

PushMoonShop:
    FormatTime, currHour,, HH  ; currHour = “00”–“23”
    FormatTime, currMin,, mm   ; currMin  = “00”–“59”
    if (currMin = "00" && currHour != lastMoonHour) {
        actionQueue.Push("buyMoonShop")
        lastMoonHour := currHour
    }
return


SafeClick(x, y){
    CoordMode, Mouse, Screen
    MouseMove, x, y, 20
    MouseClick, Left, x, y
}

SafeDrag(x1, y1, x2, y2, speed:=20){
    CoordMode, Mouse, Screen
    MouseClickDrag, Left, x1, y1, x2, y2, speed
}



; ========== SHOP‑PATH LABELS ==========

EggShopPath:
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 500
    SafeClick(1250, 141)
    Sleep, 500
    Send, {d down}
    Sleep, 18000
    Send, {d up}
    Sleep, 500
    Send, {e}
    Sleep, 800
    SafeClick(900,680)
    Sleep, 300
    SafeClick(1305,365)
    Sleep, 200
    Send, {s down}
    Sleep, 220
    Send, {s up}
    Sleep, 500
    Send, {e}
    Sleep, 800
    SafeClick(900,680)
    Sleep, 300
    SafeClick(1305,365)
    Sleep, 200
    Send, {w down}
    Sleep, 450
    Send, {w up}
    Sleep, 500
    Send, {e}
    Sleep, 800
    SafeClick(900,680)
    Sleep, 300
    SafeClick(1305,365)
    Sleep, 500
    SafeClick(1000,150)
    Sleep, 500
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
Return

seedShopPathAll:
 global mainID, altIDs

    for index, winID in altIDs {
        WinActivate % "ahk_id " winID
        WinWaitActive, ahk_id %winID%,, 2
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
    Gosub, BuyAllSeed
    Sleep, 500
    }
    SafeClick(1290,260)
    Sleep, 500
    SafeClick(1000,150)
    Sleep, 500
    }


    WinActivate % "ahk_id " mainID
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
    Gosub, BuyAllSeed
    Sleep, 500
    }
    SafeClick(1290,260)
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
Return

gearShopPathAll:
 global mainID, altIDs

    for index, winID in altIDs {
        WinActivate % "ahk_id " winID
        WinWaitActive, ahk_id %winID%,, 2
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
    }
    Gosub, BuyAllGear
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
    }


    WinActivate % "ahk_id " mainID
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
    }
    Gosub, BuyAllGear
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
Return

redMoonPath:
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 500
    SafeClick(675, 130)
    Sleep, 500
    Send, {d down}
    Sleep, 6000
    Send, {d up}
    Sleep, 500
    Send, {w down}
    Sleep, 800
    Send, {w up}
    Sleep, 500
    Send, {d down}
    Sleep, 1500
    Send, {d up}
    Sleep, 500
    Send {e}
    Sleep, 1500
PixelSearch, px, py, 611, 235, 1301, 867, 0xFDFD00, 0, Fast RGB
    if (!ErrorLevel) {
    Sleep, 300
    SafeClick(1305, 351)
    Sleep, 300
    Send, {WheelUp 40}
    Sleep, 300
    for index, item in selectedMoonItems {
        label := StrReplace(item, " ", "")
        Gosub, %label%
        Sleep, 300
    }
    }  
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
Return

redMoonPathAll:
 global mainID, altIDs

    for index, winID in altIDs {
        WinActivate % "ahk_id " winID
        WinWaitActive, ahk_id %winID%,, 2
    Sleep, 500
    SafeClick(675, 130)
    Sleep, 500
    Send, {d down}
    Sleep, 6000
    Send, {d up}
    Sleep, 500
    Send, {w down}
    Sleep, 800
    Send, {w up}
    Sleep, 500
    Send, {d down}
    Sleep, 1500
    Send, {d up}
    Sleep, 500
    Send {e}
    Sleep, 1500
PixelSearch, px, py, 611, 235, 1301, 867, 0xFDFD00, 0, Fast RGB
    if (!ErrorLevel) {
    Sleep, 300
    SafeClick(1305, 351)
    Sleep, 300
    Send, {WheelUp 40}
    Sleep, 300
    Gosub, BuyAllMoon 
    }  
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
    }
    WinActivate % "ahk_id " mainID
    Sleep, 500
    SafeClick(675, 130)
    Sleep, 500
    Send, {d down}
    Sleep, 6000
    Send, {d up}
    Sleep, 500
    Send, {w down}
    Sleep, 800
    Send, {w up}
    Sleep, 500
    Send, {d down}
    Sleep, 1500
    Send, {d up}
    Sleep, 500
    Send {e}
    Sleep, 1500
PixelSearch, px, py, 611, 235, 1301, 867, 0xFDFD00, 0, Fast RGB
    if (!ErrorLevel) {
    Sleep, 300
    SafeClick(1305, 351)
    Sleep, 300
    Send, {WheelUp 40}
    Sleep, 300
    Gosub, BuyAllMoon 
    } 
    Sleep, 500
    SafeClick(1290,260)
    Sleep, 500
Return


; ========== ITEM CALLBACKS ==========

buyAllSeed:
;CarrotSeed
    Sleep, 200
    SafeClick(750, 450)
    Sleep, 200
PixelSearch, px, py, 80, 50, 1900, 900, 0x26EE26, 0, Fast RGB
    if (!ErrorLevel) {
    Sleep, 100

    Sleep, 100
    }
    Loop, 30 {
        SafeClick(750, 630)
        Sleep, 15
    }
;StrawberrySeed
    Sleep, 200
    SafeClick(750, 750)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 640)
        Sleep, 15
    }
;BlueberrySeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;OrangeTulip
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;TomatoSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;CornSeed   
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;DaffodilSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;WatermelonSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 710)
        Sleep, 15
    }
;PumpkinSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 710)
        Sleep, 15
    }
;AppleSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 710)
        Sleep, 15
    }
;BambooSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 710)
        Sleep, 15
    }
;CoconutSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 750)
        Sleep, 15
    }
;CactusSeed:
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 750)
        Sleep, 15
    }
;DragonFruitSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 750)
        Sleep, 15
    }
;MangoSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 800)
        Sleep, 15
    }
;GrapeSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 800)
        Sleep, 15
    }
    Sleep, 300
    SafeClick(700, 600)
;MushroomSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 800)
        Sleep, 15
    }
    Sleep, 300
    SafeClick(700, 600)
;PepperSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 800)
        Sleep, 15
    }
    Sleep, 300
    SafeClick(700, 600)
;CacaoSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 840)
        Sleep, 15
    }
    Sleep, 300
    SafeClick(700, 600)
;BeanstalkSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 840)
        Sleep, 15
    }
return

buyAllGear:
;CarrotSeed
    Sleep, 200
    SafeClick(750, 450)
    Sleep, 200
    Loop, 30 {
        SafeClick(750, 630)
        Sleep, 15
    }
;StrawberrySeed
    Sleep, 200
    SafeClick(750, 750)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 640)
        Sleep, 15
    }
;BlueberrySeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;OrangeTulip
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;TomatoSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;CornSeed   
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;DaffodilSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;WatermelonSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 710)
        Sleep, 15
    }
return

buyAllMoon:
;CarrotSeed
    Sleep, 200
    SafeClick(750, 450)
    Sleep, 200
    Loop, 30 {
        SafeClick(750, 630)
        Sleep, 15
    }
;StrawberrySeed
    Sleep, 200
    SafeClick(750, 750)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 640)
        Sleep, 15
    }
;BlueberrySeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;OrangeTulip
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;TomatoSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;CornSeed   
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 670)
        Sleep, 15
    }
;DaffodilSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        ;SafeClick(750, 670)
        Sleep, 15
    }
;WatermelonSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 710)
        Sleep, 15
    }
;PumpkinSeed
    Sleep, 200
    SafeClick(750, 867)
    Sleep, 200
    Loop, 30
    {
        SafeClick(750, 800)
        Sleep, 15
    }
return

CarrotSeed:
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
    Loop, 30 {
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    Loop, 30
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
    SafeClick(750, 500)
    Sleep, 500
    Loop, 30
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
BeanstalkSeed:
    Sleep, 500
    Send, {WheelDown 30}
    Sleep, 500
    SafeClick(750, 820)
    Sleep, 500
    Loop, 30
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

MysteriousCrate:
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 500
    Loop, 30 {
        SafeClick(750, 630)
        Sleep, 15
    }
    Sleep, 500
    SafeClick(750, 450)
    Sleep, 300
Return
NightEgg:
    Sleep, 500
    SafeClick(750, 750)
    Sleep, 500
    Loop, 30
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
NightSeedPack:
    Sleep, 500
    Send, {WheelDown 3}
    Sleep, 500
    SafeClick(750, 500)
    Sleep, 500
    Loop, 30
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
CrimsonVineSeed:
    Sleep, 500
    Send, {WheelDown 3}
    Sleep, 500
    SafeClick(750, 800)
    Sleep, 500
    Loop, 30
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
MoonMelonSeed:
    Sleep, 500
    Send, {WheelDown 4}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 500
    Loop, 30
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
StarCaller:
    Sleep, 500
    Send, {WheelDown 5}
    Sleep, 500
    SafeClick(750, 850)
    Sleep, 500
    Loop, 30
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
BloodKiwi:
    Sleep, 500
    Send, {WheelDown 7}
    Sleep, 500
    SafeClick(750, 840)
    Sleep, 500
    Loop, 30
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
BloodHedgehog:
    Sleep, 500
    Send, {WheelDown 9}
    Sleep, 500
    SafeClick(750, 830)
    Sleep, 500
    Loop, 30
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
BloodOwl:
    Sleep, 500
    Send, {WheelDown 12}
    Sleep, 500
    SafeClick(750, 670)
    Sleep, 500
    Loop, 30
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


; ========== HOTKEYS & INCLUDE ==========

SaveSettings:
  Gui, Submit, NoHide
  IniWrite, % (SendDiscord ? 1 : 0), %settingsFile%, Settings, SendDiscord
  IniWrite, % webhookURL,            %settingsFile%, Settings, WebhookURL

  webOptions.WebhookEnabled := SendDiscord
  webOptions.WebhookLink    := webhookURL

    IniWrite, %UIColor%,    %settingsFile%, Settings, UIColor

    ; Immediately apply new UI color
    Gui, Color, 0x%UIColor%
    GuiControl, +Background%UIColor% +cBlack, WebhookURL
    GuiControl, +Background%UIColor% +cBlack, UIColor

    ; Save Buy All flags
    IniWrite, % (GearBuyAll ? 1 : 0), %settingsFile%, Gear, BuyAll
    IniWrite, % (EggBuyAll  ? 1 : 0), %settingsFile%, Egg,  BuyAll
    IniWrite, % (SeedBuyAll ? 1 : 0), %settingsFile%, Seed, BuyAll
    IniWrite, % (MoonBuyAll ? 1 : 0), %settingsFile%, Moon, BuyAll

    ; Save individual items
    Loop, % gearItems.Length()
        IniWrite, % (GearItem%A_Index% ? 1 : 0), %settingsFile%, Gear, Item%A_Index%
    Loop, % seedItems.Length()
        IniWrite, % (SeedItem%A_Index% ? 1 : 0), %settingsFile%, Seed, Item%A_Index%
    Loop, % moonItems.Length()
        IniWrite, % (MoonItem%A_Index% ? 1 : 0), %settingsFile%, Moon, Item%A_Index%
return

; ─── temp 

F4::
    actionQueue.Push("seedShopPath")
    actionQueue.Push("gearShopPath")
return

F3::

return

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
webhookPostSimple("Macro **stopped**!")
    StopMacro(1)  ; prepare for reload, but don’t ExitApp
    Reload        ; AutoHotkey’s built‑in single‑step restart
    return

; ─── F5 still starts your scan ───────────────────────────────────────────────
F5::Gosub, StartScan

; ─── ensure you still include other directives ─────────────────────
#MaxThreadsPerHotkey, 2
