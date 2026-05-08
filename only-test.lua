local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local useSmoothDrag = true
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

getgenv()._CEN_SLD_ACTIVE = false
getgenv()._CEN_PKR_ACTIVE = false

local PG = LP:WaitForChild("PlayerGui")

if PG:FindFirstChild("FluxUI") then PG.FluxUI:Destroy() end

-- Cleanup old ESP
if _G.ESP_LOOP then
    _G.ESP_LOOP:Disconnect(); _G.ESP_LOOP = nil
end
if _G.ESP_CACHE then
    for _, e in pairs(_G.ESP_CACHE) do
        pcall(function() e.FRM:Destroy() end)
        if e.CHAM then pcall(function() e.CHAM:Destroy() end) end
        if e.TCHAM then pcall(function() e.TCHAM:Destroy() end) end
    end
    _G.ESP_CACHE = nil
end

local toggleKey = Enum.KeyCode.RightShift
local uiConfigPath = "UI_Config.json"

local function SaveUI()
    local data = { key = toggleKey.Name, smooth = useSmoothDrag }
    if writefile then writefile(uiConfigPath, game:GetService("HttpService"):JSONEncode(data)) end
end

local function LoadUI()
    if isfile and isfile(uiConfigPath) then
        local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(uiConfigPath)) end)
        if ok and data.key then
            toggleKey = Enum.KeyCode[data.key]
            useSmoothDrag = data.smooth
        end
    end
end
LoadUI()

local function Tw(obj, t, es, ed, goals)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t, Enum.EasingStyle[es or "Quad"], Enum.EasingDirection[ed or "Out"]), goals)
    tween:Play()
    return tween
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(60, 60, 72)
    s.Thickness = th or 1
    s.Parent = p
    return s
end

local function NewFrame(parent, size, pos, color, trans)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or Color3.fromRGB(26, 26, 32)
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function NewLabel(parent, txt, sz, col, bold, xa, ya)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.TextColor3 = col or Color3.fromRGB(210, 212, 220)
    l.TextSize = sz or 13
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.Text = txt or ""
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextYAlignment = ya or Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function NewBtn(parent, size, pos, color, trans)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3 = color or Color3.fromRGB(36, 36, 46)
    b.BackgroundTransparency = trans or 0
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = ""
    b.Parent = parent
    return b
end

local function NewScroll(parent, size, pos, color, trans)
    local f = Instance.new("ScrollingFrame")
    f.Size = size or UDim2.new(1, 0, 1, 0)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or Color3.fromRGB(20, 20, 26)
    f.BackgroundTransparency = trans or 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Color3.fromRGB(238, 240, 255)
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Parent = parent
    return f
end

local function MakeDraggable(area, target)
    target = target or area
    local dragStart, startPos
    local dragging = false

    area.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            task.wait() -- Small wait to let slider flags set
            if getgenv()._CEN_SLD_ACTIVE or getgenv()._CEN_PKR_ACTIVE then return end
            
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if getgenv()._CEN_SLD_ACTIVE or getgenv()._CEN_PKR_ACTIVE then 
                dragging = false 
                return 
            end
            local delta = input.Position - dragStart
            local ease = useSmoothDrag and 0.15 or 0
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
            if ease > 0 then
                Tw(target, ease, "Quad", "Out", { Position = targetPos })
            else
                target.Position = targetPos
            end
        end
    end)
end

local BG               = Color3.fromRGB(20, 20, 26)
local SIDEBAR          = Color3.fromRGB(15, 15, 20)
local PANEL            = Color3.fromRGB(26, 26, 34)
local STROKE           = Color3.fromRGB(50, 50, 62)
local STROKE2          = Color3.fromRGB(65, 65, 80)
local TEXT             = Color3.fromRGB(208, 210, 220)
local DIM              = Color3.fromRGB(110, 112, 130)
local ACCENT           = Color3.fromRGB(238, 240, 255)
local SLBG             = Color3.fromRGB(42, 42, 54)
local SLFILL           = Color3.fromRGB(200, 204, 238)

-- Global Picker State
local PICKER_OPEN      = false
local PICKER_CALLBACK  = nil
local PICKER_GUI       = nil
local PICKER_MAIN      = nil

-- State Variables
local useNotifications = true
local useWatermark     = false
local curW             = 900
local curH             = 530
local SIDE_W           = 220
local GAP              = 8

local SG               = Instance.new("ScreenGui")
SG.Name                = "FluxUI"
SG.ResetOnSpawn        = false
SG.IgnoreGuiInset      = true
SG.ZIndexBehavior      = Enum.ZIndexBehavior.Sibling
SG.Parent              = PG

local Root             = NewFrame(SG,
    UDim2.new(0, curW, 0, curH),
    UDim2.new(0.5, -curW / 2, 0.5, -curH / 2),
    Color3.fromRGB(0, 0, 0), 1
)
Root.BorderSizePixel   = 0
Corner(Root, 10)
MakeDraggable(Root) -- Re-enabled global drag with smart filtering

local SnowHolder                  = Instance.new("Frame")
SnowHolder.Name                   = "SnowHolder"
SnowHolder.Size                   = UDim2.new(1, 0, 1, 0)
SnowHolder.BackgroundTransparency = 1
SnowHolder.ZIndex                 = 10
SnowHolder.Parent                 = Root

local Sidebar                     = NewFrame(Root,
    UDim2.new(0, SIDE_W, 1, 0),
    UDim2.new(0, 0, 0, 0),
    SIDEBAR
)
Corner(Sidebar, 10)
-- MakeDraggable(Sidebar, Root) -- Redundant now
Stroke(Sidebar, STROKE2, 1.2)
local sideGrad = Instance.new("UIGradient")
sideGrad.Rotation = 90
sideGrad.Color = ColorSequence.new(Color3.fromRGB(15, 15, 20), Color3.fromRGB(15, 15, 20))
sideGrad.Enabled = false
sideGrad.Parent = Sidebar

local RightBox = NewFrame(Root,
    UDim2.new(1, -(SIDE_W + GAP), 1, 0),
    UDim2.new(0, SIDE_W + GAP, 0, 0),
    BG
)
Corner(RightBox, 10)
Stroke(RightBox, STROKE2, 1.2)
RightBox.ClipsDescendants = true
local rightGrad = Instance.new("UIGradient")
rightGrad.Rotation = 90

-- ══════════════════ NOTIFICATION SYSTEM ══════════════════
local NotifySG = Instance.new("ScreenGui")
NotifySG.Name = "FluxNotify"
NotifySG.IgnoreGuiInset = true
NotifySG.DisplayOrder = 100
NotifySG.Parent = PG

local NotifyHolder = Instance.new("Frame")
NotifyHolder.Size = UDim2.new(0, 250, 1, -20)
NotifyHolder.Position = UDim2.new(1, -260, 0, 40)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Parent = NotifySG

local NotifyList = Instance.new("UIListLayout")
NotifyList.VerticalAlignment = Enum.VerticalAlignment.Top
NotifyList.Padding = UDim.new(0, 8)
NotifyList.Parent = NotifyHolder

local activeNotifs = {}

local function NOTIFY(title, msg, dur)
    if not useNotifications then return end
    dur = dur or 3

    local n = NewFrame(NotifyHolder, UDim2.new(1, 0, 0, 65), nil, Color3.fromRGB(24, 24, 30))
    n.ClipsDescendants = true
    Corner(n, 8)
    Stroke(n, STROKE2, 1)

    local tLbl = NewLabel(n, title, 13, ACCENT, true)
    tLbl.Position = UDim2.new(0, 12, 0, 8)
    tLbl.Size = UDim2.new(1, -24, 0, 18)

    local mLbl = NewLabel(n, msg, 11, TEXT)
    mLbl.Position = UDim2.new(0, 12, 0, 26)
    mLbl.Size = UDim2.new(1, -24, 0, 18)
    mLbl.TextWrapped = true

    local barBG = NewFrame(n, UDim2.new(1, -24, 0, 3), UDim2.new(0, 12, 1, -10), Color3.fromRGB(40, 40, 50))
    Corner(barBG, 2)
    local bar = NewFrame(barBG, UDim2.new(1, 0, 1, 0), nil, ACCENT)
    Corner(bar, 2)

    activeNotifs[n] = { t = tLbl, b = bar }

    -- Animation
    n.Position = UDim2.new(1.5, 0, 0, 0)
    Tw(n, 0.4, "Quart", "Out", { Position = UDim2.new(0, 0, 0, 0) })
    local barTween = Tw(bar, dur, "Linear", "Out", { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(math.max(0, dur - 0.3), function()
        Tw(n, 0.3, "Quart", "In", { Position = UDim2.new(1.5, 0, 0, 0) })
        task.delay(0.35, function()
            activeNotifs[n] = nil
            if n then n:Destroy() end
        end)
    end)
end

-- ══════════════════ WATERMARK SYSTEM ══════════════════
local Watermark = NewFrame(NotifySG, UDim2.new(0, 230, 0, 30), UDim2.new(0, 50, 0, 50), Color3.fromRGB(24, 24, 30))
Watermark.Visible = false
Corner(Watermark, 6)
Stroke(Watermark, STROKE2, 1)

local wmIcon = Instance.new("ImageLabel")
wmIcon.BackgroundTransparency = 1
wmIcon.Size = UDim2.new(0, 18, 0, 18)
wmIcon.Position = UDim2.new(0, 8, 0.5, -9)
wmIcon.Image = "rbxassetid://6034287525"
wmIcon.ImageColor3 = ACCENT
wmIcon.Parent = Watermark

local wmLbl = NewLabel(Watermark, "Wh01 - 0 fps - 0 ping", 11, TEXT)
wmLbl.Position = UDim2.new(0, 32, 0, 0)
wmLbl.Size = UDim2.new(1, -75, 1, 0)
wmLbl.TextXAlignment = Enum.TextXAlignment.Left

local wmBadge = NewFrame(Watermark, UDim2.new(0, 38, 0, 18), UDim2.new(1, -44, 0.5, -9), Color3.fromRGB(45, 45, 55))
Corner(wmBadge, 4)
local wmBadgeLbl = NewLabel(wmBadge, "User", 10, TEXT, true, Enum.TextXAlignment.Center)
wmBadgeLbl.Size = UDim2.new(1, 0, 1, 0)

MakeDraggable(Watermark)

local frames = 0
local fps = 0
local lastFPS = tick()
game:GetService("RunService").RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastFPS >= 1 then
        fps = frames
        frames = 0
        lastFPS = tick()
    end
    if useWatermark and Watermark.Visible then
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        wmLbl.Text = string.format("Wh01 - %d fps - %d ping", fps, ping)
    end
end)
rightGrad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(20, 20, 26))
rightGrad.Enabled = false
rightGrad.Parent = RightBox

local Shadow = Instance.new("ImageLabel")
Shadow.BackgroundTransparency = 1
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 3)
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.35
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = Root

local LogoLbl = Instance.new("ImageLabel")
LogoLbl.Name = "Logo"
LogoLbl.BackgroundTransparency = 1
LogoLbl.Size = UDim2.new(0.2, 42, 0, 42)
LogoLbl.Position = UDim2.new(0.5, -45, 0.01, 10)
LogoLbl.Image = "rbxassetid://115851224962601"
LogoLbl.Parent = Sidebar

local LogoSep = NewFrame(Sidebar, UDim2.new(1, -24, 0, 1), UDim2.new(0, 12, 0, 66), STROKE)

local NavHolder = NewFrame(Sidebar,
    UDim2.new(1, 0, 1, -110),
    UDim2.new(0, 0, 0, 76),
    SIDEBAR, 1
)

local NavPad = Instance.new("UIPadding")
NavPad.PaddingLeft = UDim.new(0, 8)
NavPad.PaddingRight = UDim.new(0, 8)
NavPad.PaddingTop = UDim.new(0, 6)
NavPad.Parent = NavHolder

local NavList = Instance.new("UIListLayout")
NavList.SortOrder = Enum.SortOrder.LayoutOrder
NavList.Padding = UDim.new(0, 3)
NavList.Parent = NavHolder

local NAV_DATA = {
    { name = "Main",     icon = "135031929601625", active = true },
    { name = "Combat",   icon = "124577101938161", active = false },
    { name = "Visuals",  icon = "94346865873525",  active = false },
    { name = "Config",   icon = "138953556540282", active = false },
    { name = "Settings", icon = "133365821659023", active = false },
}

local currentNav = nil
local navPages = {}

local function MakeNav(data, idx)
    local btn = NewBtn(NavHolder,
        UDim2.new(1, 0, 0, 38),
        UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(30, 30, 38), -- Dark pill background
        data.active and 0 or 1
    )
    btn.LayoutOrder = idx
    Corner(btn, 19) -- Full pill shape

    local dot = NewFrame(btn, UDim2.new(0, 8, 0, 8), UDim2.new(1, -20, 0.5, -4),
        data.active and ACCENT or Color3.new(1, 1, 1))
    dot.Visible = data.active
    Corner(dot, 4)

    local sym = Instance.new("ImageLabel")
    sym.BackgroundTransparency = 1
    sym.Size = UDim2.new(0, 20, 0, 20)
    sym.Position = UDim2.new(0, 16, 0.5, -10)
    sym.Image = "rbxassetid://" .. data.icon
    sym.ImageColor3 = data.active and Color3.new(1, 1, 1) or DIM
    sym.Parent = btn

    local lbl = NewLabel(btn, data.name, 13, data.active and Color3.new(1, 1, 1) or DIM, data.active)
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.Position = UDim2.new(0, 48, 0, 0)

    -- Create Category Page
    local catPage = NewFrame(RightBox, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    catPage.Visible = data.active
    navPages[data.name] = catPage

    local ref = { btn = btn, sym = sym, lbl = lbl, dot = dot, name = data.name, page = catPage }
    if data.active then currentNav = ref end

    btn.MouseButton1Click:Connect(function()
        if currentNav == ref then return end
        if currentNav then
            Tw(currentNav.btn, 0.13, "Quad", "Out", { BackgroundTransparency = 1 })
            currentNav.sym.ImageColor3 = DIM
            currentNav.lbl.TextColor3 = DIM
            currentNav.lbl.Font = Enum.Font.Gotham
            currentNav.dot.Visible = false
            currentNav.page.Visible = false
        end
        Tw(btn, 0.13, "Quad", "Out", { BackgroundTransparency = 0 })
        sym.ImageColor3 = ACCENT
        lbl.TextColor3 = ACCENT
        lbl.Font = Enum.Font.GothamBold
        dot.BackgroundColor3 = ACCENT
        dot.Visible = true
        catPage.Visible = true
        currentNav = ref
    end)

    btn.MouseEnter:Connect(function()
        if not (currentNav and currentNav.btn == btn) then
            Tw(btn, 0.09, "Quad", "Out", { BackgroundTransparency = 0.8, BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
        end
    end)
    btn.MouseLeave:Connect(function()
        if not (currentNav and currentNav.btn == btn) then
            Tw(btn, 0.09, "Quad", "Out", { BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(30, 30, 38) })
        end
    end)
end

for i, v in ipairs(NAV_DATA) do MakeNav(v, i) end

local FootSep = NewFrame(Sidebar, UDim2.new(1, -24, 0, 1), UDim2.new(0, 12, 1, -58), STROKE)

local UserCard = NewBtn(Sidebar, UDim2.new(1, -16, 0, 44), UDim2.new(0, 8, 1, -52), BG, 1)
Corner(UserCard, 8)

local pfp = Instance.new("ImageLabel")
pfp.Size = UDim2.new(0, 32, 0, 32)
pfp.Position = UDim2.new(0, 8, 0.5, -16)
pfp.BackgroundTransparency = 1
pfp.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
Corner(pfp, 16)
pfp.Parent = UserCard

local uLbl = NewLabel(UserCard, "••••••••••", 13, TEXT, true)
uLbl.Size = UDim2.new(1, -52, 1, 0)
uLbl.Position = UDim2.new(0, 48, 0, 0)

local censored = true
UserCard.MouseButton1Click:Connect(function()
    censored = not censored
    uLbl.Text = censored and "••••••••••" or LP.Name:lower()
end)

-- ══════════════════ CATEGORY CONTENT: MAIN ══════════════════
do
    local MainPage = navPages["Main"]
    local welcome = NewLabel(MainPage, "Welcome to VulFounder", 18, TEXT, true, Enum.TextXAlignment.Center)
    welcome.Size = UDim2.new(1, 0, 0, 100)
    welcome.Position = UDim2.new(0, 0, 0.4, -50)
end

-- ══════════════════ CATEGORY CONTENT: COMBAT ══════════════════
local CombatPage = navPages["Combat"]
local TAB_H = 44
local TabBar = NewFrame(CombatPage, UDim2.new(1, 0, 0, TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
-- MakeDraggable(TabBar, Root)

local UserLbl = NewLabel(TabBar, LP.Name:lower(), 12, DIM, false, Enum.TextXAlignment.Right)
UserLbl.Size = UDim2.new(0, 120, 1, 0)
UserLbl.Position = UDim2.new(1, -130, 0, 0)

local TabSep = NewFrame(CombatPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, TAB_H), STROKE)

local ContentRow = NewFrame(CombatPage,
    UDim2.new(1, -20, 1, -(TAB_H + 3 + 20)),
    UDim2.new(0, 10, 0, TAB_H + 3 + 10),
    BG, 1
)

local TABS = { "Aimbot", "Silent Aim", "Trigger Bot" }
local tabPages = {}
local activeTabIdx = 1
local tabBtns = {}
local tabLines = {}

local tx = 18
for i, name in ipairs(TABS) do
    local tw2 = 82
    local tb = NewBtn(TabBar, UDim2.new(0, tw2, 1, 0), UDim2.new(0, tx, 0, 0), BG, 1)
    local tl = NewLabel(tb, name, 13, i == 1 and ACCENT or DIM, i == 1)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Center

    local ul = NewFrame(CombatPage, UDim2.new(0, tw2, 0, 2), UDim2.new(0, tx, 0, TAB_H - 2), ACCENT)
    ul.Visible = i == 1
    Corner(ul, 1)

    -- Create Page Container
    local page = NewFrame(ContentRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    page.Visible = (i == 1)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.FillDirection = Enum.FillDirection.Horizontal
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page

    tabPages[i] = page
    tabBtns[i] = { btn = tb, lbl = tl }
    tabLines[i] = ul
    tx = tx + tw2 + 14

    tb.MouseButton1Click:Connect(function()
        if activeTabIdx == i then return end

        -- Hide Old
        tabBtns[activeTabIdx].lbl.TextColor3 = DIM
        tabBtns[activeTabIdx].lbl.Font = Enum.Font.Gotham
        tabLines[activeTabIdx].Visible = false
        tabPages[activeTabIdx].Visible = false

        -- Show New
        activeTabIdx = i
        tl.TextColor3 = ACCENT
        tl.Font = Enum.Font.GothamBold
        ul.Visible = true
        page.Visible = true
    end)
end

-- Content for Aimbot Tab (Page 1)
local AimbotPage = tabPages[1]

local LeftPanel = NewFrame(AimbotPage, UDim2.new(0.54, -5, 0, 270), UDim2.new(0, 0, 0, 0), PANEL)
LeftPanel.LayoutOrder = 1
Corner(LeftPanel, 8)
Stroke(LeftPanel, STROKE, 1)

local LPTitle = NewLabel(LeftPanel, "Aimbot", 13, TEXT, true)
LPTitle.Name = "SectionTitle"
LPTitle.Size = UDim2.new(1, 0, 0, 30)
LPTitle.Position = UDim2.new(0, 0, 0, 0)
LPTitle.TextXAlignment = Enum.TextXAlignment.Center

local CheckHolder = NewFrame(LeftPanel, UDim2.new(1, -16, 0, 180), UDim2.new(0, 8, 0, 42), PANEL, 1)
local CheckList = Instance.new("UIListLayout")
CheckList.SortOrder = Enum.SortOrder.LayoutOrder
CheckList.Padding = UDim.new(0, 2)
CheckList.Parent = CheckHolder

local CHECKS = {
    { label = "Aimbot",          badge = "None" },
    { label = "Draw Fov",        badge = nil },
    { label = "Visible Check",   badge = nil },
    { label = "Ignore Peds",     badge = nil },
    { label = "Humanize Aimbot", badge = nil },
}

for i, data in ipairs(CHECKS) do
    local row = NewBtn(CheckHolder, UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), Color3.fromRGB(32, 32, 42), 1)
    row.LayoutOrder = i
    Corner(row, 5)

    local checked = false
    local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
    Corner(cbBg, 3)
    Stroke(cbBg, STROKE2, 1)

    local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
    cbCheck.Size = UDim2.new(1, 0, 1, 0)
    cbCheck.Visible = false

    local rowLbl = NewLabel(row, data.label, 13, TEXT)
    rowLbl.Size = UDim2.new(1, -80, 1, 0)
    rowLbl.Position = UDim2.new(0, 32, 0, 0)

    local function ToggleState(state)
        checked = (state ~= nil) and state or not checked
        cbCheck.Visible = checked
        Tw(cbBg, 0.1, "Quad", "Out", {
            BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
        })
        NOTIFY(data.label, checked and "Enabled" or "Disabled", 2)
    end

    if data.badge then
        local badge = NewBtn(row, UDim2.new(0, 44, 0, 20), UDim2.new(1, -52, 0.5, -10), Color3.fromRGB(40, 40, 54))
        Corner(badge, 4)
        Stroke(badge, STROKE2, 1)
        local bLbl = NewLabel(badge, data.badge, 11, DIM, false, Enum.TextXAlignment.Center)
        bLbl.Size = UDim2.new(1, 0, 1, 0)

        if UIS.KeyboardEnabled and not UIS.TouchEnabled then
            local binding = false
            local boundKey = nil

            badge.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                bLbl.Text = "..."
                bLbl.TextColor3 = ACCENT

                local conn
                conn = UIS.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        boundKey = inp.KeyCode
                        bLbl.Text = boundKey.Name:sub(1, 4)
                        bLbl.TextColor3 = DIM
                        binding = false
                        conn:Disconnect()
                    end
                end)
            end)

            UIS.InputBegan:Connect(function(inp, gp)
                if gp or binding or not boundKey then return end
                if inp.KeyCode == boundKey then
                    ToggleState()
                end
            end)
        end
    end

    row.MouseButton1Click:Connect(function() ToggleState() end)
    row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
    row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)
end

-- Dropdown
local DdFrame = NewFrame(LeftPanel, UDim2.new(1, -16, 0, 32), UDim2.new(0, 8, 0, 226), Color3.fromRGB(32, 32, 44))
Corner(DdFrame, 6)
Stroke(DdFrame, STROKE2, 1)

local DdSelLbl = NewLabel(DdFrame, "Head", 13, TEXT)
DdSelLbl.Size = UDim2.new(1, -36, 1, 0)
DdSelLbl.Position = UDim2.new(0, 12, 0, 0)

local DdArrow = Instance.new("ImageLabel")
DdArrow.Name = "Arrow"
DdArrow.BackgroundTransparency = 1
DdArrow.Size = UDim2.new(0, 14, 0, 14)
DdArrow.Position = UDim2.new(1, -26, 0.5, -7)
DdArrow.Image = "rbxassetid://6034818372"
DdArrow.ImageColor3 = DIM
DdArrow.Parent = DdFrame

local DD_OPTIONS = { "Head", "Chest", "Neck", "Pelvis", "Legs" }
local ddOpen = false
local ddPopH = #DD_OPTIONS * 28

local DdPopup = NewFrame(LeftPanel,
    UDim2.new(DdFrame.Size.X.Scale, DdFrame.Size.X.Offset, 0, 0),
    UDim2.new(DdFrame.Position.X.Scale, DdFrame.Position.X.Offset, 0, 226 + 34),
    Color3.fromRGB(28, 28, 38)
)
DdPopup.ZIndex = 50
DdPopup.Visible = false
DdPopup.ClipsDescendants = true
Corner(DdPopup, 6)
Stroke(DdPopup, STROKE2, 1)

local DdList = Instance.new("UIListLayout")
DdList.SortOrder = Enum.SortOrder.LayoutOrder
DdList.Parent = DdPopup

for i, opt in ipairs(DD_OPTIONS) do
    local ob = NewBtn(DdPopup, UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 0), Color3.fromRGB(34, 34, 46), 1)
    ob.LayoutOrder = i
    ob.ZIndex = 51
    Corner(ob, 4)
    local ol = NewLabel(ob, opt, 12, TEXT)
    ol.Size = UDim2.new(1, -16, 1, 0)
    ol.Position = UDim2.new(0, 12, 0, 0)
    ol.ZIndex = 52
    ob.MouseEnter:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 0.35 }) end)
    ob.MouseLeave:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)
    ob.MouseButton1Click:Connect(function()
        DdSelLbl.Text = opt
        ddOpen = false
        Tw(DdPopup, 0.12, "Quad", "Out", { Size = UDim2.new(DdFrame.Size.X.Scale, DdFrame.Size.X.Offset, 0, 0) })
        task.delay(0.13, function() DdPopup.Visible = false end)
        Tw(DdArrow, 0.12, "Quad", "Out", { Rotation = 0 })
    end)
end

local DdBtn = NewBtn(DdFrame, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
DdBtn.ZIndex = 5

DdBtn.MouseButton1Click:Connect(function()
    ddOpen = not ddOpen
    if ddOpen then
        DdPopup.Size = UDim2.new(DdFrame.Size.X.Scale, DdFrame.Size.X.Offset, 0, 0)
        DdPopup.Visible = true
        Tw(DdPopup, 0.15, "Quad", "Out", { Size = UDim2.new(DdFrame.Size.X.Scale, DdFrame.Size.X.Offset, 0, ddPopH) })
        Tw(DdArrow, 0.15, "Quad", "Out", { Rotation = 180 })
    else
        Tw(DdPopup, 0.12, "Quad", "Out", { Size = UDim2.new(DdFrame.Size.X.Scale, DdFrame.Size.X.Offset, 0, 0) })
        task.delay(0.13, function() DdPopup.Visible = false end)
        Tw(DdArrow, 0.12, "Quad", "Out", { Rotation = 0 })
    end
end)

local RightPanel = NewFrame(AimbotPage, UDim2.new(0.46, -5, 0, 270), UDim2.new(0, 0, 0, 0), PANEL)
RightPanel.LayoutOrder = 2
Corner(RightPanel, 8)
Stroke(RightPanel, STROKE, 1)

local RPTitle = NewLabel(RightPanel, "Options", 13, TEXT, true)
RPTitle.Name = "SectionTitle"
RPTitle.Size = UDim2.new(1, 0, 0, 30)
RPTitle.Position = UDim2.new(0, 0, 0, 0)
RPTitle.TextXAlignment = Enum.TextXAlignment.Center

local SliderHolder = NewFrame(RightPanel, UDim2.new(1, -20, 1, -48), UDim2.new(0, 10, 0, 44), PANEL, 1)
local SliderListLayout = Instance.new("UIListLayout")
SliderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SliderListLayout.Padding = UDim.new(0, 6)
SliderListLayout.Parent = SliderHolder

local SLIDERS = {
    { label = "FOV",      min = 0,   max = 360, val = 12.4 },
    { label = "Distance", min = 0,   max = 500, val = 50.0 },
    { label = "Smooth X", min = 0.1, max = 10,  val = 1.0 },
    { label = "Smooth Y", min = 0.1, max = 10,  val = 1.0 },
}

local activeSliders = {}

local accentFills = {} -- slider fill bars, recolored on theme change
for i, data in ipairs(SLIDERS) do
    local row = NewFrame(SliderHolder, UDim2.new(1, 0, 0, 52), UDim2.new(0, 0, 0, 0), PANEL, 1)
    row.LayoutOrder = i

    local topRow = NewFrame(row, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), PANEL, 1)
    local sLbl = NewLabel(topRow, data.label, 12, TEXT)
    sLbl.Size = UDim2.new(0.6, 0, 1, 0)

    local valLbl = NewLabel(topRow, string.format("%.1f", data.val), 12, TEXT, false, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.4, 0, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)

    local track = NewFrame(row, UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 0, 26), SLBG)
    Corner(track, 3)

    local pct = (data.val - data.min) / (data.max - data.min)
    local fill = NewFrame(track, UDim2.new(pct, 0, 1, 0), UDim2.new(0, 0, 0, 0), SLFILL)
    Corner(fill, 3)
    accentFills[#accentFills + 1] = fill

    local knob = NewFrame(track, UDim2.new(0, 15, 0, 15), UDim2.new(pct, -7, 0.5, -7), Color3.fromRGB(228, 230, 255))
    Corner(knob, 8)
    Stroke(knob, Color3.fromRGB(170, 174, 210), 1.5)

    local dragging = false

    local function DoUpdate(inputX)
        local ap = track.AbsolutePosition.X
        local as = track.AbsoluteSize.X
        local rel = math.clamp((inputX - ap) / as, 0, 1)
        local nv = math.floor((data.min + rel * (data.max - data.min)) * 10 + 0.5) / 10
        valLbl.Text = string.format("%.1f", nv)
        Tw(fill, 0.04, "Linear", "Out", { Size = UDim2.new(rel, 0, 1, 0) })
        Tw(knob, 0.04, "Linear", "Out", { Position = UDim2.new(rel, -7, 0.5, -7) })
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            getgenv()._CEN_SLD_ACTIVE = true
            DoUpdate(inp.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            DoUpdate(inp.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                getgenv()._CEN_SLD_ACTIVE = false
            end
        end
    end)
end

local function SETUP_COLOR_PICKER()
    if PICKER_GUI then return end
    PICKER_GUI = Instance.new("ScreenGui", PG)
    PICKER_GUI.Name = "DrkPicker"
    PICKER_GUI.DisplayOrder = 100
    PICKER_GUI.IgnoreGuiInset = true

    PICKER_MAIN = NewFrame(PICKER_GUI, UDim2.new(0, 200, 0, 220), nil, Color3.fromRGB(30, 30, 40))
    PICKER_MAIN.Visible = false
    PICKER_MAIN.Active = true
    Corner(PICKER_MAIN, 10)
    Stroke(PICKER_MAIN, STROKE, 1)

    local sv = NewFrame(PICKER_MAIN, UDim2.new(1, -20, 0, 150), UDim2.new(0, 10, 0, 10), Color3.fromHSV(0, 1, 1))
    sv.Active = true
    Corner(sv, 6)

    local white = NewFrame(sv, UDim2.new(1, 0, 1, 0), nil, Color3.new(1, 1, 1))
    Corner(white, 6)
    local wg = Instance.new("UIGradient", white)
    wg.Transparency = NumberSequence.new(0, 1)

    local black = NewFrame(sv, UDim2.new(1, 0, 1, 0), nil, Color3.new(0, 0, 0))
    Corner(black, 6)
    local bg = Instance.new("UIGradient", black)
    bg.Rotation = 90
    bg.Transparency = NumberSequence.new(1, 0)

    local cursor = NewFrame(sv, UDim2.new(0, 10, 0, 10), UDim2.new(1, -5, 0, -5), Color3.new(1, 1, 1))
    Corner(cursor, 10)
    Stroke(cursor, Color3.new(0, 0, 0), 2)

    local hue = NewFrame(PICKER_MAIN, UDim2.new(1, -20, 0, 12), UDim2.new(0, 10, 0, 170), Color3.new(1, 1, 1))
    hue.Active = true
    Corner(hue, 6)
    local hg = Instance.new("UIGradient", hue)
    hg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })

    local hcursor = NewFrame(hue, UDim2.new(0, 4, 1, 4), UDim2.new(0, 0, 0.5, -2), Color3.new(1, 1, 1))
    Corner(hcursor, 2)
    Stroke(hcursor, Color3.new(0, 0, 0), 1)

    local ch, cs, cv = 0, 1, 1
    local function Update()
        local c = Color3.fromHSV(ch, cs, cv)
        sv.BackgroundColor3 = Color3.fromHSV(ch, 1, 1)
        cursor.Position = UDim2.new(cs, -5, 1 - cv, -5)
        hcursor.Position = UDim2.new(ch, -2, 0.5, -9)
        if PICKER_CALLBACK then PICKER_CALLBACK(c) end
    end

    local function HandleInput(obj, cb)
        local d = false
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = true;
                getgenv()._CEN_PKR_ACTIVE = true
                cb(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                cb(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = false;
                getgenv()._CEN_PKR_ACTIVE = false
            end
        end)
    end

    HandleInput(sv, function(i)
        local x = math.clamp((i.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
        local y = math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        cs, cv = x, 1 - y
        Update()
    end)
    HandleInput(hue, function(i)
        ch = math.clamp((i.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
        Update()
    end)

    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and PICKER_MAIN.Visible then
            local mp = UIS:GetMouseLocation()
            local p = PICKER_MAIN.AbsolutePosition
            local s = PICKER_MAIN.AbsoluteSize
            if mp.X < p.X or mp.X > p.X + s.X or mp.Y < p.Y + 36 or mp.Y > p.Y + s.Y + 36 then
                PICKER_MAIN.Visible = false
                PICKER_OPEN = false
            end
        end
    end)

    _G.OpenPicker = function(cur, pos, cb)
        ch, cs, cv = cur:ToHSV()
        PICKER_CALLBACK = cb
        PICKER_MAIN.Position = UDim2.new(0, pos.X - 210, 0, pos.Y - 50)
        PICKER_MAIN.Visible = true
        PICKER_OPEN = true
        Update()
    end
end
SETUP_COLOR_PICKER()

-- ══════════════════ CATEGORY CONTENT: OTHERS ══════════════════
for _, name in ipairs({ "Config" }) do
    local p = navPages[name]
    if p then
        local l = NewLabel(p, name .. " page coming soon...", 14, DIM, false, Enum.TextXAlignment.Center)
        l.Size = UDim2.new(1, 0, 1, 0)
    end
end


-- Draggable already handled at initialization


-- Resize Logic
do
    local Handle = NewBtn(Root, UDim2.new(0, 24, 0, 24), UDim2.new(1, 0, 1, 0), Color3.new(1, 1, 1), 1)
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.ZIndex = 200

    local hIcon = Instance.new("Frame")
    hIcon.Size = UDim2.new(0, 12, 0, 12)
    hIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    hIcon.BackgroundTransparency = 1
    hIcon.ZIndex = 201
    hIcon.Parent = Handle

    local clipper = Instance.new("Frame")
    clipper.Name = "Clipper"
    clipper.Size = UDim2.new(0, 14, 0, 14)
    clipper.Position = UDim2.new(0.5, -7, 0.5, -7)
    clipper.BackgroundTransparency = 1
    clipper.ClipsDescendants = true
    clipper.ZIndex = 201
    clipper.Parent = Handle

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 24, 0, 24)
    circle.Position = UDim2.new(1, -24, 1, -24)
    circle.BackgroundTransparency = 1
    circle.ZIndex = 202
    circle.Parent = clipper

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Transparency = 0.8
    stroke.Parent = circle
    Corner(circle, 12)

    local resizing = false
    local rStart = nil
    local rW, rH = 0, 0

    Handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            rStart = inp.Position
            rW = Root.AbsoluteSize.X
            rH = Root.AbsoluteSize.Y
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - rStart
            curW = math.clamp(rW + d.X, 620, 1100)
            curH = math.clamp(rH + d.Y, 380, 700)
            Tw(Root, 0.04, "Linear", "Out", { Size = UDim2.new(0, curW, 0, curH) })
        end
    end)

    Handle.MouseEnter:Connect(function() Tw(stroke, 0.09, "Quad", "Out", { Transparency = 0 }) end)
    Handle.MouseLeave:Connect(function()
        if not resizing then
            Tw(stroke, 0.09, "Quad", "Out", { Transparency = 0.8 })
        end
    end)
end

-- ══ UI THEME SYSTEM ══
-- Forward declarations so applyUITheme can reference these (populated later in Settings section)

local stLines = {}
local stBtns = {}
local activeStIdx = 1

local vsLines = {}
local vsBtns = {}
local activeVsIdx = 1

local UI_THEMES = {
    ["Default"]     = { accent = Color3.fromRGB(238, 240, 255), side = Color3.fromRGB(15, 15, 20), bg = Color3.fromRGB(20, 20, 26), gradBot = nil },
    ["Dark Blue"]   = { accent = Color3.fromRGB(100, 190, 255), side = Color3.fromRGB(12, 12, 20), bg = Color3.fromRGB(14, 16, 26), gradBot = Color3.fromRGB(50, 140, 255) },
    ["Dark Purple"] = { accent = Color3.fromRGB(210, 130, 255), side = Color3.fromRGB(16, 10, 24), bg = Color3.fromRGB(18, 12, 30), gradBot = Color3.fromRGB(180, 50, 240) },
    ["Dark White"]  = { accent = Color3.fromRGB(230, 235, 255), side = Color3.fromRGB(18, 18, 25), bg = Color3.fromRGB(22, 22, 30), gradBot = Color3.fromRGB(255, 255, 255) },
}
local currentUITheme = "Default"

local function applyUITheme(name)
    local t = UI_THEMES[name]
    if not t then return end
    currentUITheme = name
    ACCENT = t.accent

    -- Smooth Blend Transition (Cinematic Fade)
    local dur = 1.2
    local ease = "Exponential"

    Tw(Sidebar, dur, ease, "Out", { BackgroundColor3 = t.side })
    Tw(RightBox, dur, ease, "Out", { BackgroundColor3 = t.bg })

    if t.gradBot then
        local sideSeq     = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.side),
            ColorSequenceKeypoint.new(0.4, t.side:Lerp(t.gradBot, 0.35)),
            ColorSequenceKeypoint.new(1, t.gradBot)
        })
        local rightSeq    = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.bg),
            ColorSequenceKeypoint.new(0.4, t.bg:Lerp(t.gradBot, 0.35)),
            ColorSequenceKeypoint.new(1, t.gradBot)
        })
        sideGrad.Color    = sideSeq
        rightGrad.Color   = rightSeq
        sideGrad.Enabled  = true
        rightGrad.Enabled = true
    else
        sideGrad.Enabled  = false
        rightGrad.Enabled = false
    end

    if currentNav then
        Tw(currentNav.sym, dur, ease, "Out", { ImageColor3 = t.accent })
        Tw(currentNav.lbl, dur, ease, "Out", { TextColor3 = t.accent })
        Tw(currentNav.dot, dur, ease, "Out", { BackgroundColor3 = t.accent })
    end

    for _, f in ipairs(accentFills) do Tw(f, dur, ease, "Out", { BackgroundColor3 = t.accent }) end

    for _, v in ipairs(SG:GetDescendants()) do
        if v:IsA("TextLabel") and v.Name == "SectionTitle" then
            Tw(v, dur, ease, "Out", { TextColor3 = t.accent })
        end
    end

    for _, ul in ipairs(tabLines) do Tw(ul, dur, ease, "Out", { BackgroundColor3 = t.accent }) end
    if tabBtns[activeTabIdx] then Tw(tabBtns[activeTabIdx].lbl, dur, ease, "Out", { TextColor3 = t.accent }) end
    if stBtns[activeStIdx] then Tw(stBtns[activeStIdx].lbl, dur, ease, "Out", { TextColor3 = t.accent }) end
    for _, ul in ipairs(vsLines) do Tw(ul, dur, ease, "Out", { BackgroundColor3 = t.accent }) end
    if vsBtns[activeVsIdx] then Tw(vsBtns[activeVsIdx].lbl, dur, ease, "Out", { TextColor3 = t.accent }) end

    for _, v in ipairs(SG:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "✓" then
            Tw(v, dur, ease, "Out", { TextColor3 = t.accent })
        end
    end
    -- Notifications
    for _, dat in pairs(activeNotifs) do
        Tw(dat.t, dur, ease, "Out", { TextColor3 = t.accent })
        Tw(dat.b, dur, ease, "Out", { BackgroundColor3 = t.accent })
    end
    -- Watermark
    Tw(wmIcon, dur, ease, "Out", { ImageColor3 = t.accent })
end

-- ══════════════════ CATEGORY CONTENT: VISUALS ══════════════════
local VisualsPage = navPages["Visuals"]
local VS_TAB_H = 44
local VS_TabBar = NewFrame(VisualsPage, UDim2.new(1, 0, 0, VS_TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
-- MakeDraggable(VS_TabBar, Root)
local VS_TabSep = NewFrame(VisualsPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, VS_TAB_H), STROKE)
local VS_Content = NewFrame(VisualsPage, UDim2.new(1, -20, 1, -(VS_TAB_H + 20)), UDim2.new(0, 10, 0, VS_TAB_H + 10), BG,
    1)

local VS_TABS = { "Player Visuals", "World Visuals" }
local vsPages = {}

local vs_x = 18
for i, name in ipairs(VS_TABS) do
    local tw = (i == 1 and 110 or 110)
    local tb = NewBtn(VS_TabBar, UDim2.new(0, tw, 1, 0), UDim2.new(0, vs_x, 0, 0), BG, 1)
    local tl = NewLabel(tb, name, 13, i == 1 and ACCENT or DIM, i == 1)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Center

    local ul = NewFrame(VisualsPage, UDim2.new(0, tw, 0, 2), UDim2.new(0, vs_x, 0, VS_TAB_H - 2), ACCENT)
    ul.Visible = i == 1
    Corner(ul, 1)

    local page = NewScroll(VS_Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    page.Visible = (i == 1)

    vsPages[i] = page
    vsBtns[i] = { btn = tb, lbl = tl }
    vsLines[i] = ul
    vs_x = vs_x + tw + 14

    tb.MouseButton1Click:Connect(function()
        if activeVsIdx == i then return end
        vsBtns[activeVsIdx].lbl.TextColor3 = DIM
        vsBtns[activeVsIdx].lbl.Font = Enum.Font.Gotham
        vsLines[activeVsIdx].Visible = false
        vsPages[activeVsIdx].Visible = false

        activeVsIdx = i
        tl.TextColor3 = ACCENT
        tl.Font = Enum.Font.GothamBold
        ul.Visible = true
        page.Visible = true
    end)
end

-- Player Visuals Content
do
    local espPage = vsPages[1]
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.Parent = NewFrame(espPage, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), BG, 1)

    local function AddESPSetting(parent, label, default, colorCount, hasKeybind, callback, defaultColors)
        local row = NewBtn(parent, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
        row.LayoutOrder = #parent:GetChildren()
        Corner(row, 5)

        local checked = default
        local curBind = nil
        local waiting = false
        local colorBtns = {}

        local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
        Corner(cbBg, 3)
        Stroke(cbBg, STROKE2, 1)

        local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
        cbCheck.Size = UDim2.new(1, 0, 1, 0)
        cbCheck.Visible = checked

        local lbl = NewLabel(row, label, 13, TEXT)
        lbl.Position = UDim2.new(0, 32, 0, 0)
        lbl.Size = UDim2.new(1, -150, 1, 0)

        local function updateUI()
            cbCheck.Visible = checked
            Tw(cbBg, 0.1, "Quad", "Out", {
                BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
            })
        end

        local function ToggleState(state)
            checked = (state ~= nil) and state or not checked
            updateUI()
            local clrs = {}
            for _, b in ipairs(colorBtns) do table.insert(clrs, b.BackgroundColor3) end
            if callback then callback(checked, clrs, curBind) end
        end

        if colorCount and colorCount > 0 then
            local offset = -30
            for i = 1, colorCount do
                local defClr = (defaultColors and defaultColors[i]) or Color3.new(1, 1, 1)
                local cBtn = NewBtn(row, UDim2.new(0, 24, 0, 24), UDim2.new(1, offset, 0.5, -12), defClr)
                Corner(cBtn, 4)
                Stroke(cBtn, Color3.new(1, 1, 1), 1).Transparency = 0.5
                table.insert(colorBtns, cBtn)

                cBtn.MouseButton1Click:Connect(function()
                    if _G.OpenPicker then
                        _G.OpenPicker(cBtn.BackgroundColor3, cBtn.AbsolutePosition, function(c)
                            cBtn.BackgroundColor3 = c
                            local clrs = {}
                            for _, b in ipairs(colorBtns) do table.insert(clrs, b.BackgroundColor3) end
                            if callback then callback(checked, clrs) end
                        end)
                    end
                end)
                offset = offset - 28
            end
        end

        if hasKeybind then
            local badge = NewBtn(row, UDim2.new(0, 44, 0, 20), UDim2.new(1, -52, 0.5, -10), Color3.fromRGB(40, 40, 54))
            Corner(badge, 4)
            Stroke(badge, STROKE2, 1)
            local bLbl = NewLabel(badge, "None", 11, DIM, false, Enum.TextXAlignment.Center)
            bLbl.Size = UDim2.new(1, 0, 1, 0)

            badge.MouseButton1Click:Connect(function()
                if waiting then return end
                waiting = true
                bLbl.Text = "..."
                bLbl.TextColor3 = ACCENT
                local conn
                conn = UIS.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        curBind = inp.KeyCode
                        bLbl.Text = curBind.Name:sub(1, 4)
                        bLbl.TextColor3 = DIM
                        waiting = false
                        conn:Disconnect()
                    end
                end)
            end)

            UIS.InputBegan:Connect(function(inp, gp)
                if gp or waiting or not curBind then return end
                if inp.KeyCode == curBind then ToggleState() end
            end)
        end

        updateUI()
        row.MouseButton1Click:Connect(function() ToggleState() end)
        row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
        row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)

        return row
    end

    local espCard = NewFrame(espPage, UDim2.new(0.46, 0, 0, 480), UDim2.new(0.02, 0, 0, 10), PANEL)
    Corner(espCard, 8)
    Stroke(espCard, STROKE, 1)

    local espTitle = NewLabel(espCard, "ESP Options", 12, TEXT, true)
    espTitle.Name = "SectionTitle"
    espTitle.Size = UDim2.new(1, 0, 0, 30)
    espTitle.TextXAlignment = Enum.TextXAlignment.Center

    local espContent = NewFrame(espCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
    local espList = Instance.new("UIListLayout")
    espList.Padding = UDim.new(0, 2)
    espList.Parent = espContent

    -- ESP Config Placeholder
    _G.ESP_CFG = {
        Enabled = false,
        Names = false,
        DisplayNames = false,
        Tools = false,
        Distance = false,
        HealthBar = false,
        HealthText = false,
        Skeleton = false,
        Chams = false,
        Snaplines = false,
        OffScreen = false,
        HealthColor1 = Color3.fromRGB(255, 0, 0),
        HealthColor2 = Color3.fromRGB(0, 255, 0),
        FontSize = 11,
        FontName = "GothamBold",
        MaxDistance = 500
    }

    AddESPSetting(espContent, "Enabled", false, 0, true,
        function(v, c, k)
            _G.ESP_CFG.Enabled = v; if k then _G.ESP_CFG.Keybind = k end
        end)
    AddESPSetting(espContent, "Player Names", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Names = v; if c then _G.ESP_CFG.NameColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Display Names", false, 0, false, function(v) _G.ESP_CFG.DisplayNames = v end)
    AddESPSetting(espContent, "Equipped Tool", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Tools = v; if c then _G.ESP_CFG.ToolColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Distance", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Distance = v; if c then _G.ESP_CFG.DistColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Health Bars", false, 2, false,
        function(v, c)
            _G.ESP_CFG.HealthBar = v; if c then
                _G.ESP_CFG.HealthColor1 = c[1]; _G.ESP_CFG.HealthColor2 = c[2]
            end
        end, { Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0) })
    AddESPSetting(espContent, "Health Text", false, 0, false, function(v) _G.ESP_CFG.HealthText = v end)
    AddESPSetting(espContent, "Skeleton", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Skeleton = v; if c then _G.ESP_CFG.SkelColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Chams", false, 2, false,
        function(v, c)
            _G.ESP_CFG.Chams = v; if c then
                _G.ESP_CFG.ChamColor1 = c[1]; _G.ESP_CFG.ChamColor2 = c[2]
            end
        end, { Color3.new(1, 1, 1), Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Tool Chams", false, 2, false,
        function(v, c)
            _G.ESP_CFG.ToolChams = v; if c then
                _G.ESP_CFG.ToolChamColor1 = c[1]; _G.ESP_CFG.ToolChamColor2 = c[2]
            end
        end, { Color3.new(1, 1, 1), Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Snaplines", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Snaplines = v; if c then _G.ESP_CFG.SnapColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Off-Screen Lines", false, 0, false, function(v) _G.ESP_CFG.OffScreen = v end)

    -- New Visual Settings Card
    local vsCard = NewFrame(espPage, UDim2.new(0.46, 0, 0, 260), UDim2.new(0.50, 0, 0, 10), PANEL)
    Corner(vsCard, 8)
    Stroke(vsCard, STROKE, 1)

    local vsTitle = NewLabel(vsCard, "Player Visual Settings", 12, TEXT, true)
    vsTitle.Name = "SectionTitle"
    vsTitle.Size = UDim2.new(1, 0, 0, 30)
    vsTitle.TextXAlignment = Enum.TextXAlignment.Center

    local vsContent = NewFrame(vsCard, UDim2.new(1, -20, 1, -44), UDim2.new(0, 10, 0, 36), BG, 1)
    local vsList = Instance.new("UIListLayout", vsContent)
    vsList.Padding = UDim.new(0, 8)

    -- Font Dropdown
    local fontRow = NewFrame(vsContent, UDim2.new(1, 0, 0, 32), nil, Color3.fromRGB(32, 32, 44))
    Corner(fontRow, 6)
    Stroke(fontRow, STROKE2, 1)
    local fontSel = NewLabel(fontRow, "Text Font: GothamBold", 11, TEXT)
    fontSel.Position = UDim2.new(0, 10, 0, 0)
    fontSel.Size = UDim2.new(1, -30, 1, 0)
    local fontArr = Instance.new("ImageLabel", fontRow)
    fontArr.Size = UDim2.new(0, 12, 0, 12)
    fontArr.Position = UDim2.new(1, -22, 0.5, -6)
    fontArr.BackgroundTransparency = 1
    fontArr.Image = "rbxassetid://6034818372"
    fontArr.ImageColor3 = DIM

    local FONT_OPTS = { "GothamBold", "Gotham", "Code", "Roboto", "Arcade", "SciFi" }
    local fontOpen = false
    local fontPop = NewFrame(vsCard, UDim2.new(1, -20, 0, 0), UDim2.new(0, 10, 0, 36 + 36), Color3.fromRGB(28, 28, 38))
    fontPop.ZIndex = 100
    fontPop.ClipsDescendants = true
    fontPop.Visible = false
    Corner(fontPop, 6)
    Stroke(fontPop, STROKE2, 1)
    local fontPList = Instance.new("UIListLayout", fontPop)

    for _, f in ipairs(FONT_OPTS) do
        local b = NewBtn(fontPop, UDim2.new(1, 0, 0, 26), nil, BG, 1)
        b.ZIndex = 101
        local l = NewLabel(b, f, 11, TEXT)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.ZIndex = 102
        b.MouseButton1Click:Connect(function()
            fontSel.Text = "Text Font: " .. f
            _G.ESP_CFG.FontName = f
            fontOpen = false
            Tw(fontPop, 0.15, "Quad", "Out", { Size = UDim2.new(1, -20, 0, 0) })
            task.delay(0.16, function() fontPop.Visible = false end)
            Tw(fontArr, 0.15, "Quad", "Out", { Rotation = 0 })
        end)
    end

    local fontBtn = NewBtn(fontRow, UDim2.new(1, 0, 1, 0), nil, BG, 1)
    fontBtn.MouseButton1Click:Connect(function()
        fontOpen = not fontOpen
        if fontOpen then
            fontPop.Size = UDim2.new(1, -20, 0, 0)
            fontPop.Visible = true
            Tw(fontPop, 0.18, "Quad", "Out", { Size = UDim2.new(1, -20, 0, #FONT_OPTS * 26) })
            Tw(fontArr, 0.18, "Quad", "Out", { Rotation = 180 })
        else
            Tw(fontPop, 0.15, "Quad", "Out", { Size = UDim2.new(1, -20, 0, 0) })
            task.delay(0.16, function() fontPop.Visible = false end)
            Tw(fontArr, 0.15, "Quad", "Out", { Rotation = 0 })
        end
    end)

    -- Size Slider
    local function AddVSSlider(parent, label, min, max, default, suffix, callback)
        local row = NewFrame(parent, UDim2.new(1, 0, 0, 42), nil, BG, 1)
        local top = NewFrame(row, UDim2.new(1, 0, 0, 16), nil, BG, 1)
        NewLabel(top, label, 11, TEXT).Size = UDim2.new(0.6, 0, 1, 0)
        local valL = NewLabel(top, tostring(default) .. (suffix or ""), 11, ACCENT, false, Enum.TextXAlignment.Right)
        valL.Size = UDim2.new(0.4, 0, 1, 0)
        valL.Position = UDim2.new(0.6, 0, 0, 0)

        local track = NewFrame(row, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 24), Color3.fromRGB(45, 45, 55))
        Corner(track, 2)
        local fill = NewFrame(track, UDim2.new((default - min) / (max - min), 0, 1, 0), nil, ACCENT)
        Corner(fill, 2)
        accentFills[#accentFills + 1] = fill
        local knob = NewFrame(track, UDim2.new(0, 12, 0, 12), UDim2.new((default - min) / (max - min), -6, 0.5, -6),
            Color3.new(1, 1, 1))
        Corner(knob, 6)

        local dragging = false
        local function update(inputX)
            local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + rel * (max - min))
            valL.Text = tostring(val) .. (suffix or "")
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
            callback(val)
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                getgenv()._CEN_SLD_ACTIVE = true
                dragging = true; update(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                getgenv()._CEN_SLD_ACTIVE = false
            end
        end)
    end

    AddVSSlider(vsContent, "Text Size", 8, 24, 11, "", function(v) _G.ESP_CFG.FontSize = v end)
    AddVSSlider(vsContent, "Max Render Distance", 50, 2000, 500, "st", function(v) _G.ESP_CFG.MaxDistance = v end)
end

-- [ ESP ENGINE ]
local ESP_HOLDER = Instance.new("ScreenGui")
ESP_HOLDER.Name = "ESP_HOLDER"
ESP_HOLDER.IgnoreGuiInset = true
ESP_HOLDER.DisplayOrder = -1100
pcall(function() ESP_HOLDER.Parent = game:GetService("CoreGui") end)
if not ESP_HOLDER.Parent then ESP_HOLDER.Parent = PG end

local CACHE = {}
local R15_BONES = {
    { "Head",         "UpperTorso" }, { "UpperTorso", "LowerTorso" }, { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" }, { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" }, { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg",  "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" }, { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" }
}
local R6_BONES = {
    { "Head",  "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
    { "Torso", "Left Leg" }, { "Torso", "Right Leg" }
}
if _G.ESP_CACHE then
    for _, obj in pairs(_G.ESP_CACHE) do
        if obj.FRM then obj.FRM:Destroy() end
        if obj.CHAM then obj.CHAM:Destroy() end
        if obj.TCHAM then obj.TCHAM:Destroy() end
    end
end
local CACHE = {}
_G.ESP_CACHE = CACHE

local function MK_ESP(p)
    local E = {
        FRM = Instance.new("Frame", ESP_HOLDER),
        NAME = NewLabel(nil, "", 10, Color3.new(1, 1, 1), true, Enum.TextXAlignment.Center),
        DIST = NewLabel(nil, "", 9, Color3.new(1, 1, 1), false, Enum.TextXAlignment.Center),
        WEAP = NewLabel(nil, "", 9, Color3.new(1, 1, 1), false, Enum.TextXAlignment.Center),
        BAR_BG = Instance.new("Frame"),
        BAR_FL = Instance.new("Frame"),
        BAR_GRAD = Instance.new("UIGradient"),
        HEALTH_TXT = NewLabel(nil, "", 9, Color3.new(1, 1, 1), false, Enum.TextXAlignment.Center),
        SLINE = Instance.new("Frame"),
        SKEL = {}
    }
    E.SLINE.Parent = E.FRM
    E.FRM.BackgroundTransparency = 1
    E.FRM.Size = UDim2.new(1, 0, 1, 0)

    E.SLINE.BorderSizePixel = 0
    E.SLINE.ZIndex = -1
    E.SLINE.AnchorPoint = Vector2.new(0.5, 0.5)

    E.NAME.Parent = E.FRM
    E.DIST.Parent = E.FRM
    E.WEAP.Parent = E.FRM
    E.BAR_BG.Parent = E.FRM
    E.BAR_FL.Parent = E.BAR_BG
    E.BAR_GRAD.Parent = E.BAR_FL
    E.HEALTH_TXT.Parent = E.FRM

    E.BAR_BG.BackgroundColor3 = Color3.new(0, 0, 0)
    E.BAR_BG.BackgroundTransparency = 0.5
    E.BAR_BG.BorderSizePixel = 0
    E.BAR_FL.BorderSizePixel = 0
    E.BAR_GRAD.Rotation = 90

    for i = 1, 15 do
        local seg = Instance.new("Frame", E.FRM)
        seg.BorderSizePixel = 0
        seg.Visible = false
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        E.SKEL[i] = seg
    end

    CACHE[p] = E
    return E
end

local function UPD_ESP()
    local cam = workspace.CurrentCamera
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local E = CACHE[p] or MK_ESP(p)
            local C = p.Character

            if C and C:FindFirstChild("HumanoidRootPart") and C:FindFirstChildOfClass("Humanoid") then
                local H = C.HumanoidRootPart
                local HUM = C:FindFirstChildOfClass("Humanoid")
                local pos, vis = cam:WorldToViewportPoint(H.Position)
                local dist = (cam.CFrame.Position - H.Position).Magnitude
                local isAlive = HUM.Health > 0

                if _G.ESP_CFG.Enabled and isAlive then
                    E.FRM.Visible = vis or _G.ESP_CFG.OffScreen

                    if E.FRM.Visible then
                        local s_y = (H.Size.Y * 2.5 * cam.ViewportSize.Y) / (pos.Z * 2)
                        local s_x = s_y * 0.65
                        local x, y = pos.X - s_x / 2, pos.Y - s_y / 2

                        -- Chams
                        if _G.ESP_CFG.Chams then
                            if not E.CHAM or E.CHAM.Parent ~= C then
                                if E.CHAM then E.CHAM:Destroy() end
                                E.CHAM = Instance.new("Highlight", C)
                                E.CHAM.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            end
                            E.CHAM.FillColor = _G.ESP_CFG.ChamColor1 or Color3.new(1, 1, 1)
                            E.CHAM.OutlineColor = _G.ESP_CFG.ChamColor2 or Color3.new(1, 1, 1)
                        elseif E.CHAM then
                            E.CHAM:Destroy(); E.CHAM = nil
                        end

                        -- Tool Chams (from UICompleta)
                        local tool = C:FindFirstChildOfClass("Tool")
                        if _G.ESP_CFG.ToolChams and tool then
                            if not E.TCHAM or E.TCHAM.Parent ~= tool then
                                if E.TCHAM then E.TCHAM:Destroy() end
                                E.TCHAM = Instance.new("Highlight", tool)
                                E.TCHAM.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            end
                            E.TCHAM.FillColor = _G.ESP_CFG.ToolChamColor1 or Color3.new(1, 1, 1)
                            E.TCHAM.OutlineColor = _G.ESP_CFG.ToolChamColor2 or Color3.new(1, 1, 1)
                        elseif E.TCHAM then
                            E.TCHAM:Destroy(); E.TCHAM = nil
                        end

                        if vis then
                            -- Names
                            E.NAME.Visible = _G.ESP_CFG.Names and dist <= _G.ESP_CFG.MaxDistance
                            if E.NAME.Visible then
                                E.NAME.Text = _G.ESP_CFG.DisplayNames and p.DisplayName or p.Name
                                E.NAME.Position = UDim2.new(0, x, 0, y - 16)
                                E.NAME.Size = UDim2.new(0, s_x, 0, 14)
                                E.NAME.TextColor3 = _G.ESP_CFG.NameColor or Color3.new(1, 1, 1)
                                E.NAME.Font = Enum.Font[_G.ESP_CFG.FontName or "GothamBold"]
                                E.NAME.TextSize = _G.ESP_CFG.FontSize or 11
                            end

                            -- Health Bar
                            local hp_per = math.clamp(HUM.Health / HUM.MaxHealth, 0, 1)
                            E.BAR_BG.Visible = _G.ESP_CFG.HealthBar and dist <= _G.ESP_CFG.MaxDistance
                            if E.BAR_BG.Visible then
                                E.BAR_BG.Position = UDim2.new(0, x - 6, 0, y)
                                E.BAR_BG.Size = UDim2.new(0, 3, 0, s_y)
                                E.BAR_FL.Size = UDim2.new(1, 0, hp_per, 0)
                                E.BAR_FL.Position = UDim2.new(0, 0, 1 - hp_per, 0)
                                E.BAR_GRAD.Color = ColorSequence.new(
                                    _G.ESP_CFG.HealthColor1 or Color3.fromRGB(255, 0, 0),
                                    _G.ESP_CFG.HealthColor2 or Color3.fromRGB(0, 255, 0))
                            end

                            -- Health Text
                            E.HEALTH_TXT.Visible = _G.ESP_CFG.HealthText and dist <= _G.ESP_CFG.MaxDistance
                            if E.HEALTH_TXT.Visible then
                                E.HEALTH_TXT.Text = math.floor(HUM.Health)
                                E.HEALTH_TXT.Position = UDim2.new(0, x - 40, 0, y + s_y * (1 - hp_per) - 6)
                                E.HEALTH_TXT.Size = UDim2.new(0, 30, 0, 12)
                                E.HEALTH_TXT.Font = Enum.Font[_G.ESP_CFG.FontName or "GothamBold"]
                                E.HEALTH_TXT.TextSize = _G.ESP_CFG.FontSize or 11
                            end

                            -- Distance
                            E.DIST.Visible = _G.ESP_CFG.Distance and dist <= _G.ESP_CFG.MaxDistance
                            if E.DIST.Visible then
                                E.DIST.Text = math.floor(dist) .. "m"
                                E.DIST.Position = UDim2.new(0, x, 0, y + s_y + 2)
                                E.DIST.Size = UDim2.new(0, s_x, 0, 12)
                                E.DIST.TextColor3 = _G.ESP_CFG.DistColor or Color3.new(1, 1, 1)
                                E.DIST.Font = Enum.Font[_G.ESP_CFG.FontName or "GothamBold"]
                                E.DIST.TextSize = _G.ESP_CFG.FontSize or 11
                            end

                            -- Tool Text
                            E.WEAP.Visible = _G.ESP_CFG.Tools and dist <= _G.ESP_CFG.MaxDistance
                            if E.WEAP.Visible then
                                E.WEAP.Text = tool and tool.Name or "None"
                                E.WEAP.Position = UDim2.new(0, x, 0, y + s_y + (E.DIST.Visible and 14 or 2))
                                E.WEAP.Size = UDim2.new(0, s_x, 0, 12)
                                E.WEAP.TextColor3 = _G.ESP_CFG.ToolColor or Color3.new(1, 1, 1)
                                E.WEAP.Font = Enum.Font[_G.ESP_CFG.FontName or "GothamBold"]
                                E.WEAP.TextSize = _G.ESP_CFG.FontSize or 11
                            end

                            -- Skeleton
                            local bones = HUM.RigType == Enum.HumanoidRigType.R15 and R15_BONES or R6_BONES
                            for i, bone in ipairs(bones) do
                                local seg = E.SKEL[i]
                                if seg then
                                    seg.Visible = _G.ESP_CFG.Skeleton
                                    if seg.Visible then
                                        local b1, b2 = C:FindFirstChild(bone[1]), C:FindFirstChild(bone[2])
                                        if b1 and b2 then
                                            local v1 = cam:WorldToViewportPoint(b1.Position)
                                            local v2 = cam:WorldToViewportPoint(b2.Position)
                                            local d = Vector2.new(v2.X - v1.X, v2.Y - v1.Y)
                                            seg.Size = UDim2.new(0, d.Magnitude, 0, 1)
                                            seg.Position = UDim2.new(0, (v1.X + v2.X) / 2, 0, (v1.Y + p2.Y) / 2) -- Wait, p2.Y? typo fixed
                                            seg.Position = UDim2.new(0, (v1.X + v2.X) / 2, 0, (v1.Y + v2.Y) / 2)
                                            seg.Rotation = math.deg(math.atan2(d.Y, d.X))
                                            seg.BackgroundColor3 = _G.ESP_CFG.SkelColor or Color3.new(1, 1, 1)
                                        else
                                            seg.Visible = false
                                        end
                                    end
                                end
                            end
                        else
                            -- Off-Screen lines & elements hide
                            E.NAME.Visible = false; E.BAR_BG.Visible = false; E.HEALTH_TXT.Visible = false; E.DIST.Visible = false; E.WEAP.Visible = false
                            for _, s in ipairs(E.SKEL) do s.Visible = false end
                        end

                        -- Snaplines & OffScreen (from UICompleta)
                        if E.SLINE then
                            if _G.ESP_CFG.Snaplines and (vis or _G.ESP_CFG.OffScreen) then
                                local start_pos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y) -- Bottom center
                                local target_2d = Vector2.new(pos.X, pos.Y)

                                if not vis then
                                    local center = cam.ViewportSize / 2
                                    local dir = (target_2d - center).Unit
                                    if pos.Z < 0 then dir = -dir end
                                    local padding = 20
                                    target_2d = Vector2.new(
                                        math.clamp(center.X + (dir.X * 10000), padding, cam.ViewportSize.X - padding),
                                        math.clamp(center.Y + (dir.Y * 10000), padding, cam.ViewportSize.Y - padding)
                                    )
                                end

                                local diff = target_2d - start_pos
                                local mag = diff.Magnitude
                                E.SLINE.Visible = true
                                E.SLINE.Size = UDim2.new(0, 1, 0, mag)
                                E.SLINE.Position = UDim2.new(0, start_pos.X + (diff.X / 2), 0, start_pos.Y + (diff.Y / 2))
                                E.SLINE.Rotation = math.deg(math.atan2(diff.Y, diff.X)) - 90
                                E.SLINE.BackgroundColor3 = _G.ESP_CFG.SnapColor or Color3.new(1, 1, 1)
                            else
                                E.SLINE.Visible = false
                            end
                        end
                    end
                else
                    E.FRM.Visible = false
                    if E.CHAM then
                        E.CHAM:Destroy(); E.CHAM = nil
                    end
                    if E.TCHAM then
                        E.TCHAM:Destroy(); E.TCHAM = nil
                    end
                end
            else
                E.FRM.Visible = false
                if E.CHAM then
                    E.CHAM:Destroy(); E.CHAM = nil
                end
                if E.TCHAM then
                    E.TCHAM:Destroy(); E.TCHAM = nil
                end
            end
        end
    end
end

_G.ESP_LOOP = RunService.RenderStepped:Connect(UPD_ESP)

Players.PlayerRemoving:Connect(function(p)
    if CACHE[p] then
        pcall(function()
            CACHE[p].FRM:Destroy()
            if CACHE[p].CHAM then CACHE[p].CHAM:Destroy() end
            if CACHE[p].TCHAM then CACHE[p].TCHAM:Destroy() end
        end)
        CACHE[p] = nil
    end
end)

-- ══════════════════ CATEGORY CONTENT: SETTINGS ══════════════════
local SettingsPage = navPages["Settings"]
local ST_TAB_H = 44
local ST_TabBar = NewFrame(SettingsPage, UDim2.new(1, 0, 0, ST_TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
-- MakeDraggable(ST_TabBar, Root)

local ST_TabSep = NewFrame(SettingsPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, ST_TAB_H), STROKE)

local ST_Content = NewFrame(SettingsPage,
    UDim2.new(1, -20, 1, -(ST_TAB_H + 20)),
    UDim2.new(0, 10, 0, ST_TAB_H + 10),
    BG, 1
)

local ST_TABS = { "UI Settings", "Server" }
local stPages = {}
-- stBtns, stLines, activeStIdx declared above (near theme system)


local st_x = 18
for i, name in ipairs(ST_TABS) do
    local tw = (i == 1 and 90 or 60)
    local tb = NewBtn(ST_TabBar, UDim2.new(0, tw, 1, 0), UDim2.new(0, st_x, 0, 0), BG, 1)
    local tl = NewLabel(tb, name, 13, i == 1 and ACCENT or DIM, i == 1)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Center

    local ul = NewFrame(SettingsPage, UDim2.new(0, tw, 0, 2), UDim2.new(0, st_x, 0, ST_TAB_H - 2), ACCENT)
    ul.Visible = i == 1
    Corner(ul, 1)

    local page = NewFrame(ST_Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    page.Visible = (i == 1)

    stPages[i] = page
    stBtns[i] = { btn = tb, lbl = tl }
    stLines[i] = ul
    st_x = st_x + tw + 14

    tb.MouseButton1Click:Connect(function()
        if activeStIdx == i then return end
        stBtns[activeStIdx].lbl.TextColor3 = DIM
        stBtns[activeStIdx].lbl.Font = Enum.Font.Gotham
        stLines[activeStIdx].Visible = false
        stPages[activeStIdx].Visible = false

        activeStIdx = i
        tl.TextColor3 = ACCENT
        tl.Font = Enum.Font.GothamBold
        ul.Visible = true
        page.Visible = true
    end)
end

-- UI Settings Content
do
    local uiPage = stPages[1]

    local function AddCardKeybind(parent, label, default, callback)
        local row = NewBtn(parent, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), BG, 1)
        local lbl = NewLabel(row, label, 10, TEXT)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.Size = UDim2.new(1, -74, 1, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextScaled = true
        local fit = Instance.new("UITextSizeConstraint")
        fit.MaxTextSize = 11
        fit.MinTextSize = 8
        fit.Parent = lbl

        local box = NewFrame(row, UDim2.new(0, 60, 0, 20), UDim2.new(1, -68, 0.5, -10), Color3.fromRGB(45, 45, 55))
        Corner(box, 4)
        Stroke(box, STROKE2, 1)

        local bindLbl = NewLabel(box, default.Name, 10, TEXT, false, Enum.TextXAlignment.Center)
        bindLbl.Size = UDim2.new(1, 0, 1, 0)

        local waiting = false
        row.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting = true
            bindLbl.Text = "..."
            Tw(box, 0.2, "Quad", "Out", { BackgroundColor3 = ACCENT })
            bindLbl.TextColor3 = Color3.new(1, 1, 1)

            local connection
            connection = UIS.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    waiting = false
                    bindLbl.Text = inp.KeyCode.Name
                    Tw(box, 0.2, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                    bindLbl.TextColor3 = TEXT
                    callback(inp.KeyCode)
                    connection:Disconnect()
                end
            end)
        end)
        return row
    end

    local prefHeight = UIS.KeyboardEnabled and 255 or 225
    local prefCard = NewFrame(uiPage, UDim2.new(0.46, 0, 0, prefHeight), UDim2.new(0.02, 0, 0, 10), PANEL)
    Corner(prefCard, 8)
    Stroke(prefCard, STROKE, 1)

    local uiTitle = NewLabel(prefCard, "UI Preferences", 13, TEXT, true)
    uiTitle.Name = "SectionTitle"
    uiTitle.Size = UDim2.new(1, 0, 0, 30)
    uiTitle.Position = UDim2.new(0, 0, 0, 0)
    uiTitle.TextXAlignment = Enum.TextXAlignment.Center

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.Parent = NewFrame(prefCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)

    local function AddSetting(label, default, callback)
        local row = NewBtn(list.Parent, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
        Corner(row, 5)

        local checked = default
        local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
        Corner(cbBg, 3)
        Stroke(cbBg, STROKE2, 1)

        local check = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
        check.Size = UDim2.new(1, 0, 1, 0)
        check.Visible = checked

        local lbl = NewLabel(row, label, 13, TEXT)
        lbl.Position = UDim2.new(0, 32, 0, 0)
        lbl.Size = UDim2.new(1, -32, 1, 0)

        local function updateUI()
            check.Visible = checked
            Tw(cbBg, 0.1, "Quad", "Out", {
                BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
            })
        end

        row.MouseButton1Click:Connect(function()
            checked = not checked
            updateUI()
            NOTIFY(label, checked and "Enabled" or "Disabled", 2)
            callback(checked)
        end)
        row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
        row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)

        updateUI()
        return row
    end

    AddSetting("UI Shadow", true, function(v)
        if Tw then Tw(Shadow, 0.25, "Quad", "Out", { ImageTransparency = v and 0.35 or 1 }) end
    end)
    AddSetting("Smooth Drag", useSmoothDrag, function(v)
        useSmoothDrag = v
        SaveUI()
    end)
    AddSetting("Enable Notifications", true, function(v)
        useNotifications = v
    end)
    AddSetting("Enable Watermark", false, function(v)
        useWatermark = v
        Watermark.Visible = v
    end)

    if UIS.KeyboardEnabled then
        AddCardKeybind(list.Parent, "Set Custom Keybind", toggleKey, function(k)
            toggleKey = k
            SaveUI()
        end)
    end

    -- UI Color Theme Dropdown
    local themeRow = NewFrame(list.Parent, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), BG, 1)
    local themeBtn = NewBtn(themeRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(36, 36, 48))
    Corner(themeBtn, 4)
    Stroke(themeBtn, STROKE2, 1)
    local themeLbl = NewLabel(themeBtn, "UI Color: Default", 11, TEXT)
    themeLbl.Position = UDim2.new(0, 8, 0, 0)
    themeLbl.Size = UDim2.new(1, -28, 1, 0)
    local themeArrow = Instance.new("ImageLabel")
    themeArrow.BackgroundTransparency = 1
    themeArrow.Size = UDim2.new(0, 12, 0, 12)
    themeArrow.Position = UDim2.new(1, -18, 0.5, -6)
    themeArrow.Image = "rbxassetid://6034818372"
    themeArrow.ImageColor3 = DIM
    themeArrow.Parent = themeBtn

    local THEME_OPTIONS = { "Default", "Dark Blue", "Dark Purple", "Dark White" }
    local themeDropOpen = false
    local themeDropH = #THEME_OPTIONS * 26

    local themeDropPanel = NewFrame(Root, UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(28, 28, 38))
    themeDropPanel.ZIndex = 200
    themeDropPanel.Visible = false
    themeDropPanel.ClipsDescendants = true
    Corner(themeDropPanel, 6)
    Stroke(themeDropPanel, STROKE2, 1)
    local themeDropList = Instance.new("UIListLayout")
    themeDropList.SortOrder = Enum.SortOrder.LayoutOrder
    themeDropList.Parent = themeDropPanel

    local function closeThemeDrop()
        themeDropOpen = false
        Tw(themeDropPanel, 0.12, "Quad", "Out", { Size = UDim2.new(0, themeDropPanel.AbsoluteSize.X, 0, 0) })
        task.delay(0.13, function() themeDropPanel.Visible = false end)
        Tw(themeArrow, 0.12, "Quad", "Out", { Rotation = 0 })
    end

    for i, opt in ipairs(THEME_OPTIONS) do
        local ob = NewBtn(themeDropPanel, UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 0), Color3.fromRGB(32, 32, 44), 1)
        ob.LayoutOrder = i
        ob.ZIndex = 201
        Corner(ob, 4)
        local ol = NewLabel(ob, opt, 11, TEXT)
        ol.Size = UDim2.new(1, -12, 1, 0)
        ol.Position = UDim2.new(0, 10, 0, 0)
        ol.ZIndex = 202
        ob.MouseEnter:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 0.35 }) end)
        ob.MouseLeave:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)
        ob.MouseButton1Click:Connect(function()
            themeLbl.Text = "UI Color: " .. opt
            closeThemeDrop()
            applyUITheme(opt)
            NOTIFY("Theme System", "Switched to " .. opt, 2.5)
        end)
    end

    themeBtn.MouseButton1Click:Connect(function()
        themeDropOpen = not themeDropOpen
        if themeDropOpen then
            local relX = themeBtn.AbsolutePosition.X - Root.AbsolutePosition.X
            local relY = themeBtn.AbsolutePosition.Y - Root.AbsolutePosition.Y + themeBtn.AbsoluteSize.Y + 2
            local dropW = themeBtn.AbsoluteSize.X
            themeDropPanel.Size = UDim2.new(0, dropW, 0, 0)
            themeDropPanel.Position = UDim2.new(0, relX, 0, relY)
            themeDropPanel.Visible = true
            Tw(themeDropPanel, 0.15, "Quad", "Out", { Size = UDim2.new(0, dropW, 0, themeDropH) })
            Tw(themeArrow, 0.15, "Quad", "Out", { Rotation = 180 })
        else
            closeThemeDrop()
        end
    end)

    UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if not themeDropOpen then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local mx, my = inp.Position.X, inp.Position.Y
        local function hit(f)
            return mx >= f.AbsolutePosition.X and mx <= f.AbsolutePosition.X + f.AbsoluteSize.X
                and my >= f.AbsolutePosition.Y and my <= f.AbsolutePosition.Y + f.AbsoluteSize.Y
        end
        if not hit(themeDropPanel) and not hit(themeBtn) then closeThemeDrop() end
    end)

    -- Background Settings Card
    local bgCard = NewFrame(uiPage, UDim2.new(0.46, 0, 0, 160), UDim2.new(0.50, 0, 0, 10), PANEL)
    Corner(bgCard, 8)
    Stroke(bgCard, STROKE, 1)

    local bgTitle = NewLabel(bgCard, "Background Settings", 13, TEXT, true)
    bgTitle.Name = "SectionTitle"
    bgTitle.Size = UDim2.new(1, 0, 0, 30)
    bgTitle.Position = UDim2.new(0, 0, 0, 0)
    bgTitle.TextXAlignment = Enum.TextXAlignment.Center

    local bgList = Instance.new("UIListLayout")
    bgList.Padding = UDim.new(0, 4)
    bgList.SortOrder = Enum.SortOrder.LayoutOrder
    bgList.Parent = NewFrame(bgCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)

    local function AddCardSetting(parent, label, default, callback)
        local row = NewBtn(parent, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
        Corner(row, 5)

        local checked = default
        local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
        Corner(cbBg, 3)
        Stroke(cbBg, STROKE2, 1)

        local check = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
        check.Size = UDim2.new(1, 0, 1, 0)
        check.Visible = checked

        local lbl = NewLabel(row, label, 13, TEXT)
        lbl.Position = UDim2.new(0, 32, 0, 0)
        lbl.Size = UDim2.new(1, -32, 1, 0)

        local function updateUI()
            check.Visible = checked
            Tw(cbBg, 0.1, "Quad", "Out", {
                BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
            })
        end

        row.MouseButton1Click:Connect(function()
            checked = not checked
            updateUI()
            NOTIFY(label, checked and "Enabled" or "Disabled", 2)
            callback(checked)
        end)
        row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
        row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)

        updateUI()
        return row
    end

    local function AddCardSlider(parent, label, min, max, default, callback)
        local row = NewFrame(parent, UDim2.new(1, 0, 0, 44), UDim2.new(0, 0, 0, 0), PANEL, 1)
        local top = NewFrame(row, UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 0), PANEL, 1)
        local l = NewLabel(top, label, 11, TEXT)
        l.Size = UDim2.new(0.6, 0, 1, 0)
        local vLbl = NewLabel(top, tostring(default), 11, TEXT, false, Enum.TextXAlignment.Right)
        vLbl.Size = UDim2.new(0.4, 0, 1, 0)
        vLbl.Position = UDim2.new(0.6, 0, 0, 0)

        local track = NewBtn(row, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 22), SLBG, 0)
        Corner(track, 2)
        local fill = NewFrame(track, UDim2.new((default - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), SLFILL)
        Corner(fill, 2)
        accentFills[#accentFills + 1] = fill
        local knob = NewFrame(track, UDim2.new(0, 12, 0, 12), UDim2.new((default - min) / (max - min), -6, 0.5, -6),
            Color3.new(1, 1, 1))
        Corner(knob, 6)

        local dragging = false
        local function Update(inputX)
            local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + rel * (max - min))
            vLbl.Text = tostring(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
            callback(val)
        end

        track.MouseButton1Down:Connect(function()
            dragging = true
        end)

        UIS.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                Update(inp.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                NOTIFY(label, "Set to " .. vLbl.Text, 1.5)
            end
        end)
        return row
    end

    local function AddGlass(parent)
        parent.ClipsDescendants = true
        local g = Instance.new("ImageLabel")
        g.Name = "GlassLayer"
        g.Size = UDim2.new(1, 0, 1, 0)
        g.BackgroundTransparency = 1
        g.Image = "rbxassetid://10881905308" -- Glassmorphism texture
        g.ImageTransparency = 1
        g.ScaleType = Enum.ScaleType.Slice
        g.SliceCenter = Rect.new(49, 49, 450, 450)
        g.SliceScale = 0.15
        g.ZIndex = 0
        g.Parent = parent
        return g
    end

    Sidebar.ClipsDescendants = true
    RightBox.ClipsDescendants = true
    local gSide = AddGlass(Sidebar)
    local gRight = AddGlass(RightBox)

    local blurActive = false
    local blurVal = 0

    local function UpdateBlur()
        local strength = blurVal / 100
        local glassTarget = blurActive and (1 - strength * 0.6) or 1

        Tw(gSide, 0.1, "Linear", "Out", { ImageTransparency = glassTarget, ImageColor3 = Color3.new(0, 0, 0) })
        Tw(gRight, 0.1, "Linear", "Out", { ImageTransparency = glassTarget, ImageColor3 = Color3.new(0, 0, 0) })

        local panelTrans = blurActive and (strength * 0.7) or 0
        Tw(Root, 0.1, "Linear", "Out", { BackgroundTransparency = 1 }) -- Keep Root transparent to avoid black box
        Tw(Sidebar, 0.1, "Linear", "Out", { BackgroundTransparency = panelTrans })
        Tw(RightBox, 0.1, "Linear", "Out", { BackgroundTransparency = panelTrans })
    end

    AddCardSetting(bgList.Parent, "Enable Transparency", false, function(v)
        blurActive = v
        UpdateBlur()
    end).LayoutOrder = 1

    AddCardSlider(bgList.Parent, "Transparency", 0, 100, 0, function(v)
        blurVal = v
        UpdateBlur()
    end).LayoutOrder = 3

    local snowActive = false
    local flakes = {}

    local function CreateFlake()
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, math.random(2, 3), 0, math.random(2, 3))
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        f.BackgroundTransparency = 1 -- Start invisible
        f.BorderSizePixel = 0
        Corner(f, 10)
        f.Parent = SnowHolder
        return f
    end

    local function RunSnow()
        task.spawn(function()
            while snowActive do
                local f = CreateFlake()
                local startX = 0.05 + (math.random() * 0.9)
                f.Position = UDim2.new(startX, 0, 0, 0) -- Start at the very top edge

                local duration = math.random(4, 7)
                local drift = (math.random() - 0.5) * 0.1
                local targetTrans = math.random(3, 6) / 10

                -- Fade in at the start
                Tw(f, 0.5, "Linear", "Out", { BackgroundTransparency = targetTrans })

                -- Fall animation
                f:TweenPosition(
                    UDim2.new(startX + drift, 0, 0.98, 0),
                    Enum.EasingDirection.In,
                    Enum.EasingStyle.Linear,
                    duration,
                    true,
                    function()
                        -- Fade out at the bottom
                        local t = Tw(f, 0.4, "Linear", "Out", { BackgroundTransparency = 1 })
                        task.wait(0.4)
                        f:Destroy()
                    end
                )
                task.wait(0.25)
            end
        end)
    end

    AddCardSetting(bgList.Parent, "Enable Snow", false, function(v)
        snowActive = v
        if v then RunSnow() end
    end).LayoutOrder = 2

    -- Panic Button Card
    local panicCard = NewFrame(uiPage, UDim2.new(0.46, 0, 0, 80), UDim2.new(0.50, 0, 0, 180), PANEL)
    Corner(panicCard, 8)
    Stroke(panicCard, STROKE, 1)

    local panicTitle = NewLabel(panicCard, "Emergency Shutdown", 12, TEXT, true)
    panicTitle.Name = "SectionTitle"
    panicTitle.Size = UDim2.new(1, 0, 0, 30)
    panicTitle.TextXAlignment = Enum.TextXAlignment.Center

    local unloadBtn = NewBtn(panicCard, UDim2.new(1, -16, 0, 36), UDim2.new(0, 8, 0, 34), Color3.fromRGB(36, 36, 48))
    Corner(unloadBtn, 6)
    Stroke(unloadBtn, STROKE2, 1)
    local unloadLbl = NewLabel(unloadBtn, "CLOSE UI & STOP ALL", 11, TEXT, true, Enum.TextXAlignment.Center)
    unloadLbl.Size = UDim2.new(1, 0, 1, 0)

    unloadBtn.MouseButton1Click:Connect(function()
        snowActive = false
        useWatermark = false
        useNotifications = false
        SG:Destroy()
        NotifySG:Destroy()
        if _G.UnloadScript then _G.UnloadScript() end
    end)
end

-- Server Content
do
    local srvPage = stPages[2]

    -- Card 1: Server Hop Options
    local hopCard = NewFrame(srvPage, UDim2.new(0.46, 0, 0, 180), UDim2.new(0.02, 0, 0, 10), PANEL)
    Corner(hopCard, 8)
    Stroke(hopCard, STROKE, 1)

    local hopTitle = NewLabel(hopCard, "Server Hop Options", 12, TEXT, true)
    hopTitle.Name = "SectionTitle"
    hopTitle.Size = UDim2.new(1, 0, 0, 30)
    hopTitle.TextXAlignment = Enum.TextXAlignment.Center

    local hopList = Instance.new("UIListLayout")
    hopList.Padding = UDim.new(0, 4)
    hopList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hopList.Parent = NewFrame(hopCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)

    local function SrvBtn(parent, txt, callback)
        local b = NewBtn(parent, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 0), Color3.fromRGB(36, 36, 48))
        Corner(b, 6)
        Stroke(b, STROKE2, 1)
        local l = NewLabel(b, txt, 11, TEXT, false, Enum.TextXAlignment.Center)
        l.Size = UDim2.new(1, 0, 1, 0)
        b.MouseButton1Click:Connect(function()
            NOTIFY("Server System", "Executing: " .. txt, 2)
            callback()
        end)
        b.MouseEnter:Connect(function() Tw(b, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) }) end)
        b.MouseLeave:Connect(function() Tw(b, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) }) end)
    end

    local function Hop(low)
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local url = "https://games.roblox.com/v1/games/" ..
            game.PlaceId .. "/servers/Public?sortOrder=" .. (low and "Asc" or "Desc") .. "&limit=100"
        local ok, Servers = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
        if ok and Servers and Servers.data then
            for _, s in pairs(Servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    break
                end
            end
        end
    end

    SrvBtn(hopList.Parent, "Rejoin Server", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)

    SrvBtn(hopList.Parent, "Standard Server Hop", function()
        Hop(false)
    end)

    SrvBtn(hopList.Parent, "Low Player Hop", function()
        Hop(true)
    end)

    -- Card 2: Server Information
    local infoCard = NewFrame(srvPage, UDim2.new(0.46, 0, 0, 180), UDim2.new(0.50, 0, 0, 10), PANEL)
    Corner(infoCard, 8)
    Stroke(infoCard, STROKE, 1)

    local infoTitle = NewLabel(infoCard, "Server Information", 12, TEXT, true)
    infoTitle.Name = "SectionTitle"
    infoTitle.Size = UDim2.new(1, 0, 0, 30)
    infoTitle.TextXAlignment = Enum.TextXAlignment.Center

    local infoContent = NewFrame(infoCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
    local infoList = Instance.new("UIListLayout")
    infoList.Padding = UDim.new(0, 2)
    infoList.Parent = infoContent

    local function InfoRow(label, initial, ratio)
        ratio = ratio or 0.4
        local row = NewFrame(infoContent, UDim2.new(1, 0, 0, 22), nil, BG, 1)
        row.ClipsDescendants = true
        local l = NewLabel(row, label .. ":", 11, DIM)
        l.Size = UDim2.new(ratio, 0, 1, 0)
        local v = NewLabel(row, initial, 10, TEXT, false, Enum.TextXAlignment.Right)
        v.Size = UDim2.new(1 - ratio, 0, 1, 0)
        v.Position = UDim2.new(ratio, 0, 0, 0)
        v.TextScaled = true
        v.TextTruncate = Enum.TextTruncate.AtEnd
        local fit = Instance.new("UITextSizeConstraint")
        fit.MaxTextSize = 10
        fit.MinTextSize = 7
        fit.Parent = v
        return v
    end

    local jobIdVal = InfoRow("JobId", game.JobId, 0.2)
    local playersVal = InfoRow("Players",
        #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers)
    local pingVal = InfoRow("Ping", "0ms")
    local uptimeVal = InfoRow("Time in Server", "0s")

    -- Copy JobId Button
    local copyBtn = NewBtn(infoContent, UDim2.new(1, 0, 0, 28), nil, Color3.fromRGB(40, 40, 52))
    Corner(copyBtn, 6)
    local copyLbl = NewLabel(copyBtn, "Copy JobId", 11, TEXT, true, Enum.TextXAlignment.Center)
    copyLbl.Size = UDim2.new(1, 0, 1, 0)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(game.JobId)
            NOTIFY("Server Info", "JobId copied to clipboard!", 2)
        end
    end)

    -- Real-time Updates
    task.spawn(function()
        while task.wait(1) and infoCard.Parent do
            playersVal.Text = #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            pingVal.Text = ping .. "ms"

            local t = math.floor(workspace.DistributedGameTime)
            local h = math.floor(t / 3600)
            local m = math.floor((t % 3600) / 60)
            local s = t % 60
            uptimeVal.Text = string.format("%02dh %02dm %02ds", h, m, s)
        end
    end)
end

-- Entrance Animation
Root.Size = UDim2.new(0, curW, 0, 0)
Tw(Root, 0.28, "Back", "Out", { Size = UDim2.new(0, curW, 0, curH) })

-- Visibility Toggle
local uiVis = true
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == toggleKey then
        uiVis = not uiVis
        if uiVis then
            Root.Visible = true
            Tw(Root, 0.35, "Back", "Out", { Position = UDim2.new(0.5, -curW / 2, 0.5, -curH / 2) })
        else
            Tw(Root, 0.25, "Quad", "In", { Position = UDim2.new(0.5, -curW / 2, -1.1, 0) })
            task.delay(0.26, function() if not uiVis then Root.Visible = false end end)
        end
    end
end)
NOTIFY("WH01AM", "SCRIPT LOADED!", 4)
