local pls = game:GetService("Players")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local hs = game:GetService("HttpService")
local gn = "WallScripts"
local lp = pls.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local cfgFile = "WallScripts_Config.json"
local cfg = {
    TransparentUI = false,
    EnableBackground = true,
    UITransparency = 13,
    BackgroundOpacity = 24,
    BgImageId = "106965170825722",
    MainSizeX = 580,
    MainSizeY = 360,
    UIColor = 1,
    UIFont = 1,
    Vis_Enabled = false,
    Vis_Names = false,
    Vis_NamesColor = "FFFFFF",
    Vis_HealthBars = false,
    Vis_HealthColor = "00FF00",
    Vis_HealthText = false,
    Vis_HealthTextColor = "00FF00",
    Vis_Weapons = false,
    Vis_WeaponsColor = "FFFFFF",
    Vis_Distance = false,
    Vis_DistanceColor = "FFFFFF",
    Vis_Chams = false,
    Vis_ChamsColor = "FF0000",
    Vis_ToolCharms = false,
    Vis_ToolCharmsColor = "FF00FF",
    Vis_Snaplines = false,
    Vis_SnaplinesColor = "FFFFFF",
    Vis_OffScreen = false,
    Vis_Skeleton = false,
    Vis_SkeletonColor = "FFFFFF",
    Vis_TextFont = 1,
    Vis_TextSize = 12,
    Vis_MaxDist = 1000,
    HideUIKey = "RightShift",
    MobileHideBtn = true,

    TeleportLoc = 1,
    TeleportPly = 1,
    StoreItem = 1,
    StoreQty = 1,
    GunItem = 1,
    GunQty = 1,
    Mod_ReloadAmt = 5,

    CarSpeedBoost = false,
    CarSpeed = 100,
    CarInstaBrake = false,
    CarInfGas = false,
    CarTool = 1,
    MyCar = 1,
    DealerCar = 1,
    StealCarIdx = 1,

    WalkSpeedBypass = false,
    WalkSpeedVal = 50,
    PlayerFly = false,
    PlayerFlySpeed = 50,
    InfStamina = false,
    CarFly = false,
    CarFlySpeed = 150,
    ExtrasTargetPlayer = 1,

    RepzMaterial = 1,
    RepzBlank = 1,
    RepzAutoBuy = false,
    RepzAutoPrint = false,
    RepzAutoBuyPrint = false,

    RobberyAuto = false,
    ChickenAuto = false,
    RapAuto = false,
    JailAuto = false,

    SilentAim_Enabled = false,
    SilentAim_Wallbang = false,
    SilentAim_ShowFOV = false,
    SilentAim_FOVColor = "FFFFFF",
    SilentAim_FOVRadius = 150,
    SilentAim_TargetPart = 1
}

local function saveCfg()
    if writefile then
        local st = {}
        for k, v in pairs(cfg) do
            if type(v) ~= "boolean" or k == "TransparentUI" or k == "EnableBackground" or k == "MobileHideBtn" then
                st[k] = v
            end
        end
        pcall(function() writefile(cfgFile, hs:JSONEncode(st)) end)
    end
end

if isfile and isfile(cfgFile) and readfile then
    local s, res = pcall(function() return hs:JSONDecode(readfile(cfgFile)) end)
    if s and type(res) == "table" then
        if res.TransparentUI ~= nil then cfg.TransparentUI = res.TransparentUI end
        if res.EnableBackground ~= nil then cfg.EnableBackground = res.EnableBackground end
        if res.UITransparency ~= nil then cfg.UITransparency = res.UITransparency end
        if res.BackgroundOpacity ~= nil then cfg.BackgroundOpacity = res.BackgroundOpacity end
        if res.BgImageId ~= nil then cfg.BgImageId = res.BgImageId end
        if res.MainSizeX ~= nil then cfg.MainSizeX = res.MainSizeX end
        if res.MainSizeY ~= nil then cfg.MainSizeY = res.MainSizeY end
        if res.UIColor ~= nil then cfg.UIColor = res.UIColor end
        if res.UIFont ~= nil then cfg.UIFont = res.UIFont end

        if res.Vis_Enabled ~= nil then cfg.Vis_Enabled = res.Vis_Enabled end
        if res.Vis_Names ~= nil then cfg.Vis_Names = res.Vis_Names end
        if res.Vis_NamesColor ~= nil then cfg.Vis_NamesColor = res.Vis_NamesColor end
        if res.Vis_HealthBars ~= nil then cfg.Vis_HealthBars = res.Vis_HealthBars end
        if res.Vis_HealthColor ~= nil then cfg.Vis_HealthColor = res.Vis_HealthColor end
        if res.Vis_HealthText ~= nil then cfg.Vis_HealthText = res.Vis_HealthText end
        if res.Vis_HealthTextColor ~= nil then cfg.Vis_HealthTextColor = res.Vis_HealthTextColor end
        if res.Vis_Weapons ~= nil then cfg.Vis_Weapons = res.Vis_Weapons end
        if res.Vis_WeaponsColor ~= nil then cfg.Vis_WeaponsColor = res.Vis_WeaponsColor end
        if res.Vis_Distance ~= nil then cfg.Vis_Distance = res.Vis_Distance end
        if res.Vis_DistanceColor ~= nil then cfg.Vis_DistanceColor = res.Vis_DistanceColor end
        if res.Vis_Chams ~= nil then cfg.Vis_Chams = res.Vis_Chams end
        if res.Vis_ChamsColor ~= nil then cfg.Vis_ChamsColor = res.Vis_ChamsColor end
        if res.Vis_ToolCharms ~= nil then cfg.Vis_ToolCharms = res.Vis_ToolCharms end
        if res.Vis_ToolCharmsColor ~= nil then cfg.Vis_ToolCharmsColor = res.Vis_ToolCharmsColor end
        if res.Vis_Snaplines ~= nil then cfg.Vis_Snaplines = res.Vis_Snaplines end
        if res.Vis_SnaplinesColor ~= nil then cfg.Vis_SnaplinesColor = res.Vis_SnaplinesColor end
        if res.Vis_OffScreen ~= nil then cfg.Vis_OffScreen = res.Vis_OffScreen end
        if res.Vis_Skeleton ~= nil then cfg.Vis_Skeleton = res.Vis_Skeleton end
        if res.Vis_SkeletonColor ~= nil then cfg.Vis_SkeletonColor = res.Vis_SkeletonColor end

        if res.Vis_TextFont ~= nil then cfg.Vis_TextFont = res.Vis_TextFont end
        if res.Vis_TextSize ~= nil then cfg.Vis_TextSize = res.Vis_TextSize end
        if res.Vis_MaxDist ~= nil then cfg.Vis_MaxDist = res.Vis_MaxDist end

        if res.HideUIKey ~= nil then cfg.HideUIKey = res.HideUIKey end
        if res.MobileHideBtn ~= nil then cfg.MobileHideBtn = res.MobileHideBtn end

        if type(res.TeleportLoc) == "number" then cfg.TeleportLoc = res.TeleportLoc else cfg.TeleportLoc = 1 end
        if type(res.TeleportPly) == "number" then cfg.TeleportPly = res.TeleportPly else cfg.TeleportPly = 1 end
        if type(res.StoreItem) == "number" then cfg.StoreItem = res.StoreItem else cfg.StoreItem = 1 end
        if type(res.StoreQty) == "number" then cfg.StoreQty = res.StoreQty else cfg.StoreQty = 1 end
        if type(res.GunItem) == "number" then cfg.GunItem = res.GunItem else cfg.GunItem = 1 end
        if type(res.GunQty) == "number" then cfg.GunQty = res.GunQty else cfg.GunQty = 1 end
        if type(res.Mod_ReloadAmt) == "number" then cfg.Mod_ReloadAmt = res.Mod_ReloadAmt else cfg.Mod_ReloadAmt = 5 end

        if res.CarSpeedBoost ~= nil then cfg.CarSpeedBoost = res.CarSpeedBoost end
        if type(res.CarSpeed) == "number" then cfg.CarSpeed = res.CarSpeed else cfg.CarSpeed = 100 end
        if res.CarInstaBrake ~= nil then cfg.CarInstaBrake = res.CarInstaBrake end
        if res.CarInfGas ~= nil then cfg.CarInfGas = res.CarInfGas end
        if type(res.CarTool) == "number" then cfg.CarTool = res.CarTool else cfg.CarTool = 1 end
        if type(res.MyCar) == "number" then cfg.MyCar = res.MyCar else cfg.MyCar = 1 end
        if type(res.DealerCar) == "number" then cfg.DealerCar = res.DealerCar else cfg.DealerCar = 1 end
        if type(res.StealCarIdx) == "number" then cfg.StealCarIdx = res.StealCarIdx else cfg.StealCarIdx = 1 end

        if res.WalkSpeedBypass ~= nil then cfg.WalkSpeedBypass = res.WalkSpeedBypass end
        if type(res.WalkSpeedVal) == "number" then cfg.WalkSpeedVal = res.WalkSpeedVal else cfg.WalkSpeedVal = 50 end
        if res.PlayerFly ~= nil then cfg.PlayerFly = res.PlayerFly end
        if type(res.PlayerFlySpeed) == "number" then cfg.PlayerFlySpeed = res.PlayerFlySpeed else cfg.PlayerFlySpeed = 50 end
        if res.InfStamina ~= nil then cfg.InfStamina = res.InfStamina end
        if res.CarFly ~= nil then cfg.CarFly = res.CarFly end
        if type(res.CarFlySpeed) == "number" then cfg.CarFlySpeed = res.CarFlySpeed else cfg.CarFlySpeed = 150 end
        if type(res.ExtrasTargetPlayer) == "number" then cfg.ExtrasTargetPlayer = res.ExtrasTargetPlayer else cfg.ExtrasTargetPlayer = 1 end

        if type(res.RepzMaterial) == "number" then cfg.RepzMaterial = res.RepzMaterial else cfg.RepzMaterial = 1 end
        if type(res.RepzBlank) == "number" then cfg.RepzBlank = res.RepzBlank else cfg.RepzBlank = 1 end
        if res.RepzAutoBuy ~= nil then cfg.RepzAutoBuy = res.RepzAutoBuy end
        if res.RepzAutoPrint ~= nil then cfg.RepzAutoPrint = res.RepzAutoPrint end
        if res.RepzAutoBuyPrint ~= nil then cfg.RepzAutoBuyPrint = res.RepzAutoBuyPrint end
        if res.RobberyAuto ~= nil then cfg.RobberyAuto = res.RobberyAuto end
        if res.ChickenAuto ~= nil then cfg.ChickenAuto = res.ChickenAuto end
        if res.RapAuto ~= nil then cfg.RapAuto = res.RapAuto end
        if res.JailAuto ~= nil then cfg.JailAuto = res.JailAuto end

        if res.SilentAim_Enabled ~= nil then cfg.SilentAim_Enabled = res.SilentAim_Enabled end
        if res.SilentAim_Wallbang ~= nil then cfg.SilentAim_Wallbang = res.SilentAim_Wallbang end
        if res.SilentAim_ShowFOV ~= nil then cfg.SilentAim_ShowFOV = res.SilentAim_ShowFOV end
        if res.SilentAim_FOVColor ~= nil then cfg.SilentAim_FOVColor = res.SilentAim_FOVColor end
        if type(res.SilentAim_FOVRadius) == "number" then cfg.SilentAim_FOVRadius = res.SilentAim_FOVRadius else cfg.SilentAim_FOVRadius = 150 end
        if type(res.SilentAim_TargetPart) == "number" then cfg.SilentAim_TargetPart = res.SilentAim_TargetPart else cfg.SilentAim_TargetPart = 1 end
    end
end

if getgenv().WALLSCRIPTS_CLEANUP then
    pcall(getgenv().WALLSCRIPTS_CLEANUP)
end

getgenv().WALLSCRIPTS_CLEANUP = function()
    if pg:FindFirstChild(gn) then
        pg[gn]:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild(gn) then
        game:GetService("CoreGui")[gn]:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("CP_GUI") then
        game:GetService("CoreGui").CP_GUI:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("MOB_HIDE_GUI") then
        game:GetService("CoreGui").MOB_HIDE_GUI:Destroy()
    end
    getgenv().MOB_HIDE_BTN = nil
    getgenv().OPEN_COLOR_PICKER = nil

    local eSys = getgenv().ESP_SYS
    if eSys then
        if eSys.Conn then eSys.Conn:Disconnect() end
        if eSys.Lines then eSys.Lines:Destroy() end
        for p, o in pairs(eSys.Cache) do
            if o.bg then o.bg:Destroy() end
            if o.hl then o.hl:Destroy() end
            if o.sl then o.sl:Destroy() end
        end
        getgenv().ESP_SYS = nil
    end

    if getgenv().CLEANUP_ALL_PHYSICS then
        pcall(getgenv().CLEANUP_ALL_PHYSICS)
    end

    if getgenv().SILENT_AIM_CLEANUP then
        pcall(getgenv().SILENT_AIM_CLEANUP)
    end

    if getgenv().FARM_STATE then
        getgenv().FARM_STATE.Active = false
    end
end
local function C(cls, prp)
    local ins = Instance.new(cls)
    for k, v in pairs(prp) do
        ins[k] = v
    end
    return ins
end

local gui = C("ScreenGui",
    {
        Name = gn,
        ResetOnSpawn = false,
        DisplayOrder = 2147483647,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = game:GetService("CoreGui")
    })
local mn = C("Frame", {
    Name = "MainFrame",
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Active = true,
    ClipsDescendants = true,
    Parent = gui
})
C("UICorner", { CornerRadius = UDim.new(0, 10), Parent = mn })

local bI = C("ImageLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ImageTransparency = 0.76,
    Image = "rbxassetid://" .. cfg.BgImageId,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 1,
    Visible = false,
    Parent = mn
})
C("UICorner", { CornerRadius = UDim.new(0, 10), Parent = bI })

local isM = uis.TouchEnabled and not uis.MouseEnabled
if not (isfile and isfile(cfgFile)) and isM then
    cfg.MainSizeX = 400
    cfg.MainSizeY = 250
end
mn.Size = UDim2.new(0, cfg.MainSizeX, 0, cfg.MainSizeY)

C("UISizeConstraint", {
    MaxSize = Vector2.new(1000, 700),
    MinSize = isM and Vector2.new(350, 200) or Vector2.new(500, 320),
    Parent = mn
})

local isR = false

local function mkD(ui)
    local drg, di, srt, pos
    ui.InputBegan:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not isR then
            drg = true
            srt = i.Position
            pos = ui.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    drg = false
                end
            end)
        end
    end)
    ui.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            di = i
        end
    end)
    uis.InputChanged:Connect(function(i)
        if i == di and drg and not isR then
            local dlt = i.Position - srt
            local tgt = UDim2.new(pos.X.Scale, pos.X.Offset + dlt.X, pos.Y.Scale, pos.Y.Offset + dlt.Y)
            ts:Create(ui, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = tgt }):Play()
        end
    end)
end

mkD(mn)

local cb = C("ImageButton", {
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -15, 0, 15),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Image = "rbxassetid://116542333255880",
    BorderSizePixel = 0,
    ZIndex = 20,
    Parent = mn
})
cb.MouseEnter:Connect(function()
    ts:Create(cb, TweenInfo.new(0.15),
        { Size = UDim2.new(0, 22, 0, 22), ImageColor3 = Color3.fromRGB(255, 80, 80) }):Play()
end)
cb.MouseLeave:Connect(function()
    ts:Create(cb, TweenInfo.new(0.15),
        { Size = UDim2.new(0, 18, 0, 18), ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
end)
cb.MouseButton1Click:Connect(function()
    if getgenv().WALLSCRIPTS_CLEANUP then
        pcall(getgenv().WALLSCRIPTS_CLEANUP)
    else
        gui:Destroy()
    end
end)

local rsz = C("ImageButton", {
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(1, -6, 1, -6),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Image = "rbxassetid://122145100036018",
    BorderSizePixel = 0,
    ZIndex = 20,
    Active = true,
    Parent = mn
})
local rsi = {}

rsz.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        isR = true
        rsi.srt = i.Position
        rsi.sz = mn.AbsoluteSize
    end
end)
uis.InputChanged:Connect(function(i)
    if isR and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local dlt = i.Position - rsi.srt
        mn.Size = UDim2.new(0, rsi.sz.X + dlt.X, 0, rsi.sz.Y + dlt.Y)
    end
end)
uis.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if isR then
            cfg.MainSizeX = mn.Size.X.Offset
            cfg.MainSizeY = mn.Size.Y.Offset
            saveCfg()
        end
        isR = false
    end
end)

local sb = C("Frame",
    {
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent =
            mn
    })
C("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sb })
C("Frame",
    {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent =
            mn
    })

local lgo = C("ImageLabel", {
    Size = UDim2.new(1, 10, 0, 55),
    Position = UDim2.new(0, -5, 0, -2),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Image = "rbxassetid://125884722057852",
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 3,
    Parent = sb
})

local tc = C("Frame",
    { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3, Parent = sb })
C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = tc })
C("UIPadding", { PaddingTop = UDim.new(0, 50), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = tc })

local ct = C("Frame",
    {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent =
            mn
    })

local cY = Color3.fromRGB(255, 200, 0)
local cB = Color3.fromRGB(100, 90, 200)
local cI = Color3.fromRGB(150, 150, 150)
local bA = Color3.fromRGB(25, 25, 25)
local dG = Color3.fromRGB(18, 18, 18)

local st = { aT = nil, aS = {} }
local cds = {}
local dds = {}

if not getgenv().OPEN_COLOR_PICKER then
    local cpGui = Instance.new("ScreenGui")
    cpGui.Name = "CP_GUI"
    cpGui.ResetOnSpawn = false
    cpGui.DisplayOrder = 2147483647
    cpGui.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", cpGui)
    main.Size = UDim2.new(0, 160, 0, 190)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.Visible = false
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
    local uis = Instance.new("UIStroke", main)
    uis.Color = Color3.fromRGB(40, 40, 40)
    uis.Thickness = 1

    local sv = Instance.new("Frame", main)
    sv.Size = UDim2.new(1, -16, 0, 110)
    sv.Position = UDim2.new(0, 8, 0, 8)
    sv.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    sv.Active = true
    Instance.new("UICorner", sv).CornerRadius = UDim.new(0, 4)

    local sg = Instance.new("Frame", sv)
    sg.Size = UDim2.new(1, 0, 1, 0)
    sg.BackgroundTransparency = 0
    Instance.new("UICorner", sg).CornerRadius = UDim.new(0, 4)
    local sgrad = Instance.new("UIGradient", sg)
    sgrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
    sgrad.Transparency = NumberSequence.new(0, 1)

    local vg = Instance.new("Frame", sv)
    vg.Size = UDim2.new(1, 0, 1, 0)
    vg.BackgroundTransparency = 0
    Instance.new("UICorner", vg).CornerRadius = UDim.new(0, 4)
    local vgrad = Instance.new("UIGradient", vg)
    vgrad.Rotation = 90
    vgrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
    vgrad.Transparency = NumberSequence.new(1, 0)

    local curs = Instance.new("Frame", sv)
    curs.Size = UDim2.new(0, 10, 0, 10)
    curs.AnchorPoint = Vector2.new(0.5, 0.5)
    curs.BackgroundColor3 = Color3.new(1, 1, 1)
    curs.ZIndex = 5
    Instance.new("UICorner", curs).CornerRadius = UDim.new(1, 0)
    local cursStr = Instance.new("UIStroke", curs)
    cursStr.Color = Color3.new(0, 0, 0)
    cursStr.Thickness = 1

    local hue = Instance.new("Frame", main)
    hue.Size = UDim2.new(1, -16, 0, 10)
    hue.Position = UDim2.new(0, 8, 0, 126)
    hue.Active = true
    Instance.new("UICorner", hue).CornerRadius = UDim.new(0, 4)
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

    local hueCurs = Instance.new("Frame", hue)
    hueCurs.Size = UDim2.new(0, 4, 1, 4)
    hueCurs.Position = UDim2.new(0, 0, 0.5, 0)
    hueCurs.AnchorPoint = Vector2.new(0.5, 0.5)
    hueCurs.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", hueCurs).CornerRadius = UDim.new(0, 2)
    Instance.new("UIStroke", hueCurs).Color = Color3.new(0, 0, 0)

    local h, s, v = 0, 1, 1
    local curCb = nil

    local function upd()
        local clr = Color3.fromHSV(h, s, v)
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        curs.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCurs.Position = UDim2.new(h, 0, 0.5, 0)
        if curCb then curCb(clr) end
    end

    local function dragInput(obj, cb)
        local d = false
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = true; cb(i)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(i)
            if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                cb(i)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = false
            end
        end)
    end

    dragInput(sv, function(i)
        local px = math.clamp((i.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
        local py = math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        s, v = px, 1 - py
        upd()
    end)

    dragInput(hue, function(i)
        h = math.clamp((i.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
        upd()
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and main.Visible then
            local mp = game:GetService("UserInputService"):GetMouseLocation()
            local px, py = mp.X, mp.Y
            if i.UserInputType == Enum.UserInputType.Touch then px, py = i.Position.X, i.Position.Y end
            local x1, y1 = main.AbsolutePosition.X, main.AbsolutePosition.Y
            if px < x1 or px > x1 + main.AbsoluteSize.X or py < y1 + 36 or py > y1 + main.AbsoluteSize.Y + 36 then
                main.Visible = false
            end
        end
    end)

    getgenv().OPEN_COLOR_PICKER = function(start_clr, _, pos, cb)
        curCb = cb
        h, s, v = start_clr:ToHSV()
        main.Position = UDim2.new(0, pos.X, 0, pos.Y)
        main.Visible = true
        upd()
    end
end
local function cT(nm, id)
    local bt = C("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = bA,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = tc
    })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = bt })

    local ind = C("Frame", {
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 5, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = cY,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = bt
    })
    C("UICorner", { CornerRadius = UDim.new(0, 2), Parent = ind })

    local ic = C("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "rbxassetid://" .. id,
        ImageColor3 = cI,
        Parent = bt
    })

    local lb = C("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = nm,
        TextColor3 = cI,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bt
    })

    local pge = C("Frame",
        { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, Parent = ct })
    local sbt = C("Frame",
        { Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pge })
    C("UIListLayout",
        {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder =
                Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = sbt
        })
    C("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 20), Parent = sbt })
    local sbc = C("Frame",
        {
            Size = UDim2.new(1, 0, 1, -45),
            Position = UDim2.new(0, 0, 0, 45),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent =
                pge
        })

    bt.MouseButton1Click:Connect(function()
        if st.aT then
            ts:Create(st.aT.bt, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
            ts:Create(st.aT.ind, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
            ts:Create(st.aT.ic, TweenInfo.new(0.2), { ImageColor3 = cI }):Play()
            ts:Create(st.aT.lb, TweenInfo.new(0.2), { TextColor3 = cI }):Play()
            st.aT.pge.Visible = false
        end

        ts:Create(bt, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
        ts:Create(ind, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
        ts:Create(ic, TweenInfo.new(0.2), { ImageColor3 = cY }):Play()
        ts:Create(lb, TweenInfo.new(0.2), { TextColor3 = cY }):Play()

        pge.Visible = true
        st.aT = { bt = bt, ind = ind, ic = ic, lb = lb, pge = pge }
    end)

    return { pge = pge, sbt = sbt, sbc = sbc, bt = bt, ind = ind, ic = ic, lb = lb }
end

local function cST(ptb, nm)
    local bt = C("TextButton", {
        Size = UDim2.new(0, 0, 0, 26),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(20, 110, 210),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = nm,
        TextColor3 = cI,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = ptb.sbt
    })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = bt })
    C("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = bt })

    local sP = C("ScrollingFrame",
        {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 =
                Color3.fromRGB(60, 60, 60),
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            AutomaticCanvasSize = Enum
                .AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = ptb.sbc
        })
    C("UIPadding",
        {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim
                .new(0, 2),
            Parent = sP
        })

    local rw = C("Frame",
        {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent =
                sP
        })
    C("UIListLayout",
        {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent =
                rw
        })

    local lC = C("Frame",
        {
            Size = UDim2.new(0.5, -8, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum
                .AutomaticSize.Y,
            Parent = rw
        })
    local rC = C("Frame",
        {
            Size = UDim2.new(0.5, -8, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum
                .AutomaticSize.Y,
            Parent = rw
        })

    C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = lC })
    C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = rC })

    bt.MouseButton1Click:Connect(function()
        if st.aS[ptb.pge] then
            ts:Create(st.aS[ptb.pge].bt, TweenInfo.new(0.15), { BackgroundTransparency = 1, TextColor3 = cI }):Play()
            st.aS[ptb.pge].sP.Visible = false
        end
        ts:Create(bt, TweenInfo.new(0.15), { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255) })
            :Play()
        sP.Visible = true
        st.aS[ptb.pge] = { bt = bt, sP = sP }
    end)

    if not st.aS[ptb.pge] then
        bt.BackgroundTransparency = 0
        bt.TextColor3 = Color3.fromRGB(255, 255, 255)
        sP.Visible = true
        st.aS[ptb.pge] = { bt = bt, sP = sP }
    end

    return { l = lC, r = rC }
end

local function cCd(pr, nm)
    local cd = C("Frame",
        {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = dG,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent =
                pr,
            ClipsDescendants = true
        })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cd })
    C("UIStroke", { Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = cd })
    C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = cd })
    table.insert(cds, cd)

    local hd = C("TextButton",
        { Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Parent = cd })
    local hl = C("TextLabel",
        {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text =
                nm,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment =
                Enum.TextXAlignment.Center,
            Parent = hd
        })

    local cc = C("Frame",
        {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum
                .AutomaticSize.Y,
            Parent = cd
        })
    C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = cc })
    C("UIPadding",
        {
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight =
                UDim.new(0, 15),
            Parent = cc
        })

    return cc
end

local function cKb(pr, nm, df, cb)
    local kb = C("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pr })
    local tl = C("TextLabel",
        {
            Size = UDim2.new(1, -80, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = nm,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = kb
        })
    local btn = C("TextButton",
        {
            Size = UDim2.new(0, 70, 0, 18),
            Position = UDim2.new(1, 0, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Text = df or "None",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = kb
        })
    C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })

    local conn
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        if conn then conn:Disconnect() end
        conn = uis.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                local k = i.KeyCode.Name
                btn.Text = k
                if cb then cb(i.KeyCode) end
                conn:Disconnect()
                conn = nil
            end
        end)
    end)
end

local function cTg(pr, nm, df, cb, cdf, ccb)
    local tg = C("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pr })
    local on = df or false
    local tC = on and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(100, 100, 100)
    local tl = C("TextLabel",
        {
            Size = UDim2.new(1, -70, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = nm,
            TextColor3 = tC,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = tg
        })

    local bg = C("TextButton",
        {
            Size = UDim2.new(0, 32, 0, 18),
            Position = UDim2.new(1, 0, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = on and cY or Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Text = "",
            Parent = tg
        })
    C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bg })
    local kn = C("Frame",
        {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, on and 16 or 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = bg
        })
    C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = kn })

    bg.MouseButton1Click:Connect(function()
        on = not on
        ts:Create(bg, TweenInfo.new(0.2), { BackgroundColor3 = on and cY or Color3.fromRGB(40, 40, 40) }):Play()
        ts:Create(kn, TweenInfo.new(0.2), { Position = UDim2.new(0, on and 16 or 2, 0.5, 0) }):Play()
        ts:Create(tl, TweenInfo.new(0.2),
            { TextColor3 = on and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(100, 100, 100) }):Play()
        if cb then cb(on) end
    end)

    if cdf and ccb then
        local cpBtn = C("TextButton",
            {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -40, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = cdf,
                BorderSizePixel = 0,
                Text = "",
                Parent = tg
            })
        C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = cpBtn })
        C("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = cpBtn })

        cpBtn.MouseButton1Click:Connect(function()
            if getgenv().OPEN_COLOR_PICKER then
                getgenv().OPEN_COLOR_PICKER(cpBtn.BackgroundColor3, 0, cpBtn.AbsolutePosition + Vector2.new(20, 0),
                    function(nc)
                        cpBtn.BackgroundColor3 = nc
                        ccb(nc)
                    end)
            end
        end)
    end
end

local function cIm(pr, id)
    local im = C("ImageLabel",
        {
            Size = UDim2.new(1, 0, 0, 75),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            Image = id ~= "" and
                "rbxassetid://" .. id or "",
            ScaleType = Enum.ScaleType.Crop,
            BorderSizePixel = 0,
            Parent = pr
        })
    C("UICorner", { CornerRadius = UDim.new(0, 6), Parent = im })
    C("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Parent = im })
    return im
end

local function cTb(pr, pl, txt, cb)
    local tb = C("TextBox",
        {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            TextColor3 = Color3.fromRGB(200,
                200, 200),
            PlaceholderText = pl,
            PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment =
                Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
            Parent = pr
        })
    tb.Text = txt or ""
    C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = tb })
    C("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Parent = tb })
    C("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = tb })
    tb.FocusLost:Connect(function() cb(tb.Text, tb) end)
    return tb
end

local function cBtn(pr, nm, cb)
    local btn = C("TextButton",
        {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Text = nm,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BorderSizePixel = 0,
            Parent = pr
        })
    C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
    C("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = btn })

    btn.MouseEnter:Connect(function()
        ts:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        ts:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        ts:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
        task.delay(0.1, function()
            ts:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
        end)
        if cb then cb(btn) end
    end)
    return btn
end

local function cSl(pr, nm, mnV, mxV, df, cb)
    local sf = C("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pr })
    local tl = C("TextLabel",
        {
            Size = UDim2.new(1, -35, 0, 15),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = nm,
            TextColor3 = Color3
                .fromRGB(150, 150, 150),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent =
                sf
        })
    local vl = C("TextLabel",
        {
            Size = UDim2.new(0, 30, 0, 15),
            Position = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text =
                tostring(df),
            TextColor3 = Color3.fromRGB(230, 230, 230),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment =
                Enum.TextXAlignment.Right,
            Parent = sf
        })

    local bg = C("Frame",
        {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Parent =
                sf
        })
    C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bg })
    local fl = C("Frame",
        { Size = UDim2.new((df - mnV) / (mxV - mnV), 0, 1, 0), BackgroundColor3 = cY, BorderSizePixel = 0, Parent = bg })
    C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fl })
    local kn = C("Frame",
        {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 =
                Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = fl
        })
    C("UICorner", { CornerRadius = UDim.new(1, 0), Parent = kn })

    local hb = C("TextButton",
        {
            Size = UDim2.new(1, 0, 0, 36),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Text =
            "",
            ZIndex = 10,
            Parent = bg
        })

    local dr = false
    local function up(i)
        local p = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        fl.Size = UDim2.new(0, math.floor(bg.AbsoluteSize.X * p), 1, 0)
        local v = math.floor(mnV + ((mxV - mnV) * p))
        vl.Text = tostring(v)
        cb(v)
    end
    hb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true; up(i)
        end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
    uis.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            up(i)
        end
    end)
end

local tM = cT("Main", "107529018959397")
local tC = cT("Misc", "82832715289752")
local tF = cT("Farm", "117936339122649")
local tB = cT("Combat", "132655560258806")
local tS = cT("Config", "115052390034117")

local smM = cST(tM, "Main")
local lM = smM.l
local rM = smM.r

if not getgenv().EXE then getgenv().EXE = { GUN_MODS = {} } end

getgenv().W_ML = {
    LOCATIONS = {
        ["🏘️Apartments"] = Vector3.new(-1665.98, 4.60, -299.28),
        ["💈Barber Shop"] = Vector3.new(-1468.55, 4.80, -66.79),
        ["🔫BlackMarket"] = Vector3.new(-1010.57, 5.28, 160.24),
        ["📦Box Job"] = Vector3.new(248, 5, -344),
        ["🐔Chicken Shop"] = Vector3.new(-897.63, 4.79, -1569.57),
        ["👕Clothes Shop"] = Vector3.new(-1481.19, 4.80, -1760.46),
        ["🛒Convenience Store"] = Vector3.new(85, 5, -321),
        ["🚗Dealer"] = Vector3.new(-230.78, 4.83, -411.38),
        ["🥪Deli"] = Vector3.new(-1004.40, 4.83, -671.72),
        ["👗Female Clothing"] = Vector3.new(-335.85, 4.80, -752.62),
        ["🏪Gun Store"] = Vector3.new(-1254.09, 4.91, -1086.93),
        ["🍔Ham"] = Vector3.new(-1476.70, 4.80, -867.19),
        ["🔧HardWare Store"] = Vector3.new(92.37, 4.85, -1926.36),
        ["💍Jewelry"] = Vector3.new(-302.70, 4.80, 649.07),
        ["💰Pawn Shop"] = Vector3.new(-1151.66, 4.80, 644.32),
        ["👟Shoe Store"] = Vector3.new(175, 5, 125),
        ["🎤Studio"] = Vector3.new(-70.84, 4.80, 2114.73),
        ["💉Tattoo"] = Vector3.new(-1090.62, 4.80, -517.11)
    },
    AMMO_LIST = { "5.56 Mag", "7.62 Mag", "9mm Extended", "9mm Mag", "Drum Mag", "Flavor Packet", "Water Gallon" },
    AMMO_QTY_LIST = { "1", "2", "3", "5", "10" },
    GUN_LIST = {
        "ARPistol $7300", "Draco $5600", "Draco Drum $10000", "G17 $1500", "G19 Clear EXT $4300",
        "G22 DB $3200", "G43X Beam $3000", "Tec-9 $4599", "Springfield Hellcat $3500"
    },
    GUN_QTY_LIST = { "1", "2", "3", "5" },
    lastTPTime = 0,
    TP_COOLDOWN = 4,

    getMyPropertyPosition = function()
        local CS = game:GetService("CollectionService")
        for _, apt in ipairs(CS:GetTagged("Apt")) do
            if apt:GetAttribute("Owner") == lp.Name then
                local p = apt:FindFirstChild("Door") or apt:FindFirstChild("BuyPart") or apt.PrimaryPart
                if p then return p.Position end
                return apt:GetPivot().Position
            end
        end

        local aptFolders = {
            workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("BrokeAPTS"),
            workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("Houses")
        }
        for _, folder in ipairs(aptFolders) do
            if folder then
                for _, apt in ipairs(folder:GetChildren()) do
                    if apt:GetAttribute("Owner") == lp.Name then
                        local p = apt:FindFirstChild("Door") or apt:FindFirstChild("BuyPart") or apt.PrimaryPart
                        if p then return p.Position end
                        return apt:GetPivot().Position
                    end
                end
            end
        end
        return nil
    end,

    BYPASS_TP = function(target)
        local targetPos = typeof(target) == "CFrame" and target.Position or target
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local att = hrp and hrp:FindFirstChild("RootAttachment")

        if not (hrp and att) then return end

        hrp.Anchored = false
        if hum and hum.SeatPart then
            hum.Sit = false
            task.wait(0.1)
        end

        local origCollide = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                origCollide[p] = p.CanCollide
                p.CanCollide = false
            end
        end

        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = att
        lv.MaxForce = math.huge
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity = Vector3.zero
        lv.Parent = hrp

        local noclipConn
        noclipConn = game:GetService("RunService").Stepped:Connect(function()
            if not char or not char.Parent then
                noclipConn:Disconnect()
                return
            end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)

        local arrived = false
        local startTime = tick()
        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function()
            if not hrp or not hrp.Parent or (tick() - startTime > 35) then
                conn:Disconnect()
                noclipConn:Disconnect()
                pcall(function() lv:Destroy() end)
                arrived = true
                return
            end

            local remaining = targetPos - hrp.Position
            local dist = remaining.Magnitude

            if dist <= 5 then
                lv.VectorVelocity = Vector3.zero
                conn:Disconnect()
                pcall(function() lv:Destroy() end)
                arrived = true
                task.delay(1, function()
                    noclipConn:Disconnect()
                    for p, state in pairs(origCollide) do
                        pcall(function() p.CanCollide = state end)
                    end
                end)
                return
            end

            local speed = math.clamp(dist * 3, 20, 200)
            lv.VectorVelocity = remaining.Unit * speed
        end)

        while not arrived do task.wait(0.05) end
    end
}

local smSA = cST(tB, "Silent Aim")
local smV = cST(tB, "Visuals")

-- Visuals tab setup moved below to prevent 'nil' function call errors

local smU = cST(tS, "Ui settings")
local c4 = cCd(smU.l, "Background Image")
local c5 = cCd(smU.r, "Extras")

local uiThemes = {
    { mn = Color3.fromRGB(20, 20, 20), sb = Color3.fromRGB(15, 15, 15), cd = Color3.fromRGB(18, 18, 18), dd = Color3.fromRGB(25, 25, 25) },
    { mn = Color3.fromRGB(15, 20, 30), sb = Color3.fromRGB(10, 15, 25), cd = Color3.fromRGB(12, 18, 28), dd = Color3.fromRGB(20, 25, 35) },
    { mn = Color3.fromRGB(35, 31, 15), sb = Color3.fromRGB(25, 22, 10), cd = Color3.fromRGB(30, 26, 12), dd = Color3.fromRGB(45, 40, 20) },
    { mn = Color3.fromRGB(15, 30, 20), sb = Color3.fromRGB(10, 25, 15), cd = Color3.fromRGB(12, 28, 18), dd = Color3.fromRGB(20, 35, 25) },
    { mn = Color3.fromRGB(34, 28, 24), sb = Color3.fromRGB(28, 22, 18), cd = Color3.fromRGB(30, 24, 20), dd = Color3.fromRGB(42, 34, 30) }
}
local uiFonts = {
    Enum.Font.GothamBold,
    Enum.Font.Arcade,
    Enum.Font.SciFi,
    Enum.Font.Code
}

local function uThm(tIdx, nF)
    if tIdx then
        local th = uiThemes[tIdx]
        mn.BackgroundColor3 = th.mn
        sb.BackgroundColor3 = th.sb
        for _, c in ipairs(cds) do
            c.BackgroundColor3 = th.cd
        end
        for _, d in ipairs(dds) do
            d.BackgroundColor3 = th.dd
        end
    end
    if nF then
        for _, obj in ipairs(mn:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
                obj.Font = nF
            end
        end
    end
end

local function cDd(pr, nm, opts, df, cb)
    local dd = C("Frame",
        {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum
                .AutomaticSize.Y,
            Parent = pr
        })
    C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = dd })

    local top = C("Frame",
        { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = dd })
    local tl = C("TextLabel",
        {
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = nm,
            TextColor3 = Color3.fromRGB(150, 150,
                150),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = top
        })

    local bg = C("TextButton",
        {
            Size = UDim2.new(0.5, 0, 0, 24),
            Position = UDim2.new(1, 0, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 =
                Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ClipsDescendants = true,
            Text = "",
            Parent = top
        })
    C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = bg })
    C("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = bg })

    local sTxt = C("TextLabel",
        {
            Size = UDim2.new(1, -25, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = opts[df] or
                opts[1],
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment =
                Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = bg
        })
    local arr = C("TextLabel",
        {
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -24, 0, 0),
            BackgroundTransparency = 1,
            Text = "v",
            TextColor3 =
                Color3.fromRGB(150, 150, 150),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Parent = bg
        })

    local list = C("ScrollingFrame",
        {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, #opts * 26),
            Parent =
                dd
        })
    C("UICorner", { CornerRadius = UDim.new(0, 4), Parent = list })
    local lstStrk = C("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Enabled = false, Parent = list })
    local ll = C("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
    table.insert(dds, list)

    local open = false
    local idx = df

    local function upd()
        sTxt.Text = opts[idx]
        arr.Rotation = open and 180 or 0
        lstStrk.Enabled = open
        list.ScrollBarThickness = open and 2 or 0
        local tgtSize = open and math.min(#opts * 26, 130) or 0
        ts:Create(list, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, 0, 0, tgtSize) }):Play()
    end

    local function REFRESH(newOpts)
        local oldVal = opts[idx]
        opts = newOpts
        local newIdx = 1
        for i, v in ipairs(opts) do
            if v == oldVal then
                newIdx = i; break
            end
        end
        idx = newIdx

        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, opt in ipairs(opts) do
            local ob = C("TextButton",
                {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BackgroundTransparency = 1,
                    Text = opt,
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    AutoButtonColor = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = list
                })
            C("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = ob })
            ob.MouseEnter:Connect(function()
                ts:Create(ob, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            end)
            ob.MouseLeave:Connect(function()
                ts:Create(ob, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(150, 150, 150) }):Play()
            end)
            ob.MouseButton1Click:Connect(function()
                idx = i
                open = false
                upd()
                if cb then cb(idx) end
            end)
        end
        list.CanvasSize = UDim2.new(0, 0, 0, #opts * 26)
        upd()
    end

    REFRESH(opts)

    bg.MouseButton1Click:Connect(function()
        open = not open
        upd()
    end)

    return { REFRESH = REFRESH }
end

local function HxC(h) return Color3.fromHex(h) end
local function CxH(c) return c:ToHex() end

local cTP = cCd(lM, "Teleports")

local function getLocList()
    local list = {}
    for name, _ in pairs(getgenv().W_ML.LOCATIONS) do table.insert(list, name) end
    table.sort(list)
    table.insert(list, 1, "My Property")
    table.insert(list, 2, "🏍️Surrons")
    table.insert(list, 3, "🏧Nearest ATM")
    return list
end

local LOC_LIST = getLocList()

cDd(cTP, "Select Location", LOC_LIST, cfg.TeleportLoc, function(v)
    cfg.TeleportLoc = v; saveCfg()
end)

cBtn(cTP, "Teleport to Location", function()
    local v = LOC_LIST[cfg.TeleportLoc]
    local ML = getgenv().W_ML
    local timeSinceLast = tick() - ML.lastTPTime
    if timeSinceLast < ML.TP_COOLDOWN then return end

    local targetPos = nil
    if v == "My Property" then
        targetPos = ML.getMyPropertyPosition()
    elseif v == "🏍️Surrons" then
        local surronsFolder = workspace:FindFirstChild("Purchases") and workspace.Purchases:FindFirstChild("Surrons")
        local firstSurron = surronsFolder and surronsFolder:GetChildren()[1]
        if firstSurron then
            targetPos = firstSurron:IsA("Model") and firstSurron:GetPivot().Position or
                (firstSurron:IsA("BasePart") and firstSurron.Position)
        end
    elseif v == "🏧Nearest ATM" or v == "🏧Random ATM" then
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local atmsFolder = workspace:FindFirstChild("ATMS")
            local allATMs = atmsFolder and atmsFolder:GetChildren() or {}
            local closestATM = nil
            local minDistance = math.huge
            for _, atm in ipairs(allATMs) do
                local base = atm:FindFirstChild("Base")
                if base then
                    local prompt = base:FindFirstChild("Prompt")
                    local pos = (prompt and (prompt:IsA("BasePart") and prompt.Position or prompt:IsA("Attachment") and prompt.WorldPosition)) or
                        base.Position
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestATM = pos
                    end
                end
            end
            targetPos = closestATM
        end
    else
        targetPos = ML.LOCATIONS[v]
    end

    if targetPos then
        ML.BYPASS_TP(targetPos)
        ML.lastTPTime = tick()
    end
end)

local PLY_LIST = { "Loading..." }
local ddPly = cDd(cTP, "Select Player", PLY_LIST, cfg.TeleportPly, function(v)
    cfg.TeleportPly = v; saveCfg()
end)

cBtn(cTP, "Teleport to Player", function()
    local ML = getgenv().W_ML
    local timeSinceLast = tick() - ML.lastTPTime
    if timeSinceLast < ML.TP_COOLDOWN then return end

    local pName = PLY_LIST[cfg.TeleportPly]
    if not pName or pName == "Loading..." or pName == "None" then return end

    local p = game.Players:FindFirstChild(pName)
    local root = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        ML.BYPASS_TP(root.Position)
        ML.lastTPTime = tick()
    end
end)

task.spawn(function()
    while task.wait(5) do
        local list = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p.Name) end
        end
        table.sort(list)
        if #list == 0 then table.insert(list, "None") end
        PLY_LIST = list
        if ddPly and ddPly.REFRESH then ddPly.REFRESH(list) end
    end
end)

local cGM = cCd(lM, "Gun Mods")
cTg(cGM, "Auto Reload", getgenv().EXE.GUN_MODS.AutoReload, function(v)
    getgenv().EXE.GUN_MODS.AutoReload = v
end)
cSl(cGM, "Reload Ammo Count", 1, 30, cfg.Mod_ReloadAmt, function(v)
    cfg.Mod_ReloadAmt = v
    getgenv().EXE.GUN_MODS.ReloadThreshold = v
    saveCfg()
end)
cTg(cGM, "No Recoil & Spread", getgenv().EXE.GUN_MODS.NoRecoil, function(v)
    getgenv().EXE.GUN_MODS.NoRecoil = v
end)
cTg(cGM, "Rapid Fire", getgenv().EXE.GUN_MODS.RapidFire, function(v)
    getgenv().EXE.GUN_MODS.RapidFire = v
end)

local cSI = cCd(rM, "Store Items")
cDd(cSI, "Select Item", getgenv().W_ML.AMMO_LIST, cfg.StoreItem, function(v)
    cfg.StoreItem = v; saveCfg()
end)
cDd(cSI, "Select Quantity", getgenv().W_ML.AMMO_QTY_LIST, cfg.StoreQty, function(v)
    cfg.StoreQty = v; saveCfg()
end)
cBtn(cSI, "Purchase Item", function()
    local item = getgenv().W_ML.AMMO_LIST[cfg.StoreItem]
    local qty = tonumber(getgenv().W_ML.AMMO_QTY_LIST[cfg.StoreQty]) or 1
    if not item then return end
    pcall(function()
        if item == "Flavor Packet" or item == "Water Gallon" then
            local E = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net
                ["RE/Convenience"]
            for i = 1, qty do
                E:FireServer("PurchasePablo", { name = item, category = "Items" }); if i < qty then task.wait(0.5) end
            end
        else
            local E = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net
                ["RE/GunShop"]
            for i = 1, qty do
                E:FireServer("Purchase", { name = item, category = "Ammo" }); if i < qty then task.wait(0.5) end
            end
        end
    end)
end)

local cGS = cCd(rM, "Guns Store")
cDd(cGS, "Select Gun", getgenv().W_ML.GUN_LIST, cfg.GunItem, function(v)
    cfg.GunItem = v; saveCfg()
end)
cDd(cGS, "Select Quantity", getgenv().W_ML.GUN_QTY_LIST, cfg.GunQty, function(v)
    cfg.GunQty = v; saveCfg()
end)
cBtn(cGS, "Purchase Gun", function()
    local gunStr = getgenv().W_ML.GUN_LIST[cfg.GunItem]
    local qty = tonumber(getgenv().W_ML.GUN_QTY_LIST[cfg.GunQty]) or 1
    if not gunStr then return end
    local gun = string.match(gunStr, "^(.-) %$") or gunStr
    pcall(function()
        local E = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net["RE/GunShop"]
        for i = 1, qty do
            E:FireServer("Purchase", { name = gun, category = "Gun" }); if i < qty then task.wait(0.5) end
        end
    end)
end)

local function getPlayerCash()
    local amountLabel = lp.PlayerGui:FindFirstChild("HUD")
        and lp.PlayerGui.HUD:FindFirstChild("Economy")
        and lp.PlayerGui.HUD.Economy:FindFirstChild("Cash")
        and lp.PlayerGui.HUD.Economy.Cash:FindFirstChild("Amount")
    if amountLabel and amountLabel:IsA("TextLabel") then
        local cleanText = amountLabel.Text:gsub("[^%d]", "")
        return tonumber(cleanText) or 0
    end
    return 0
end

local function get_owned_vehicles()
    local names = {}
    pcall(function()
        local data = game:GetService("ReplicatedStorage"):FindFirstChild("PlayerData")
        local pData = data and data:FindFirstChild(lp.Name)
        local stats = pData and pData:FindFirstChild("Statistics")
        local vFolder = stats and stats:FindFirstChild("Vehicles")
        if vFolder then
            for _, v in pairs(vFolder:GetChildren()) do
                if not table.find(names, v.Name) then table.insert(names, v.Name) end
            end
        end
    end)
    pcall(function()
        local Replion = require(game:GetService("ReplicatedStorage").Modules.Packages.Replion)
        local dataReplion = Replion.Client:GetReplion("Data")
        if dataReplion then
            local slot = lp:GetAttribute("Slot")
            local carsDict = dataReplion:Get({ "PlayerSlots", tonumber(slot), "PlayerCharacter", "Cars" })
            if carsDict then
                for carName, _ in pairs(carsDict) do
                    if not table.find(names, carName) then table.insert(names, carName) end
                end
            end
        end
    end)
    return names
end

local smC = cST(tC, "Vehicles")

local cCM = cCd(smC.l, "Car Mods")
cTg(cCM, "Car Speed Boost", cfg.CarSpeedBoost, function(v)
    cfg.CarSpeedBoost = v; saveCfg()
end)
cSl(cCM, "Car Speed", 0, 300, cfg.CarSpeed, function(v)
    cfg.CarSpeed = v; saveCfg()
end)
cTg(cCM, "Instant Brake", cfg.CarInstaBrake, function(v)
    cfg.CarInstaBrake = v; saveCfg()
end)
cTg(cCM, "Infinite Gas", cfg.CarInfGas, function(v)
    cfg.CarInfGas = v; saveCfg()
end)

task.spawn(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        pcall(function()
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(lp.Name) or lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                local seat = hum.SeatPart
                if cfg.CarSpeedBoost and seat.Throttle > 0 then
                    local speed = cfg.CarSpeed or 100
                    seat.AssemblyLinearVelocity = seat.CFrame.LookVector * speed
                end
                if cfg.CarInstaBrake and seat.Throttle < 0 then
                    seat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    seat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
                if cfg.CarInfGas then
                    seat.Parent:SetAttribute("Gas", 100)
                end
            end
        end)
    end)
end)

local cCSp = cCd(smC.l, "Car Spawner")
local C_TOOLS_LIST = { "Despawn Car", "TP to Car" }
cDd(cCSp, "Car Tools", C_TOOLS_LIST, cfg.CarTool, function(v)
    cfg.CarTool = v; saveCfg()
    local action = C_TOOLS_LIST[v]
    if action == "Despawn Car" then
        local RF = game:GetService("ReplicatedStorage").Modules.Packages["_Index"]["sleitnick_net@0.2.0"].net
            ["RF/CarSpawn"]
        if RF then pcall(function() RF:InvokeServer("Despawn") end) end
    elseif action == "TP to Car" then
        local car = workspace:FindFirstChild("Cars") and workspace.Cars:FindFirstChild(lp.Name .. "'s Car")
        local seat = car and
            (car:FindFirstChildWhichIsA("VehicleSeat") or car:FindFirstChildWhichIsA("Seat") or car.PrimaryPart)
        if seat then getgenv().W_ML.BYPASS_TP(seat.Position + Vector3.new(0, 3, 0)) end
    end
end)

local MY_CARS_LIST = { "Loading..." }
local ddMyCar = cDd(cCSp, "My Cars", MY_CARS_LIST, cfg.MyCar, function(v)
    cfg.MyCar = v; saveCfg()
    local carName = MY_CARS_LIST[v]
    if not carName or carName == "Loading..." or carName == "None" then return end
    local RF = game:GetService("ReplicatedStorage").Modules.Packages["_Index"]["sleitnick_net@0.2.0"].net["RF/CarSpawn"]
    if RF then pcall(function() RF:InvokeServer("Valet", carName) end) end
end)

task.spawn(function()
    task.wait(2)
    local function refresh_dropdown()
        local cars = get_owned_vehicles()
        if #cars == 0 then table.insert(cars, "None") end
        MY_CARS_LIST = cars
        if ddMyCar and ddMyCar.REFRESH then ddMyCar.REFRESH(cars) end
    end
    refresh_dropdown()
    pcall(function()
        local data = game:GetService("ReplicatedStorage"):WaitForChild("PlayerData", 5)
        local pData = data and data:WaitForChild(lp.Name, 5)
        local stats = pData and pData:WaitForChild("Statistics", 5)
        local vFolder = stats and stats:WaitForChild("Vehicles", 5)
        if vFolder then
            vFolder.ChildAdded:Connect(refresh_dropdown)
            vFolder.ChildRemoved:Connect(refresh_dropdown)
        end
    end)
end)

local cCDl = cCd(smC.r, "Car Dealer")
local DEALER_CARS = {
    "Civic $12k", "Crown Vic $7k", "Dodge Challenger 120k", "GLE $185k",
    "Lamborghini Huracan 2,2m", "M5 $200k", "TRX $50k", "Trackhawk $25ok"
}
local CAR_PRICES = {
    ["Civic $12k"] = { name = "Civic", price = 12000 },
    ["Crown Vic $7k"] = { name = "Crown Vic", price = 7000 },
    ["Dodge Challenger 120k"] = { name = "Dodge Challenger", price = 120000 },
    ["GLE $185k"] = { name = "GLE", price = 185000 },
    ["Lamborghini Huracan 2,2m"] = { name = "Lamborghini Huracan", price = 2200000 },
    ["M5 $200k"] = { name = "M5", price = 200000 },
    ["TRX $50k"] = { name = "TRX", price = 50000 },
    ["Trackhawk $25ok"] = { name = "Trackhawk", price = 250000 }
}
cDd(cCDl, "Select Vehicle", DEALER_CARS, cfg.DealerCar, function(v)
    cfg.DealerCar = v; saveCfg()
end)
cBtn(cCDl, "Purchase Vehicle", function()
    local selectedStr = DEALER_CARS[cfg.DealerCar]
    local info = CAR_PRICES[selectedStr]
    if not info then return end

    local carName = info.name
    local carPrice = info.price
    if getPlayerCash() < carPrice then return end

    local Event = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net
        ["RE/CarPurchase"]
    if Event then
        pcall(function()
            local carModel = workspace.Debris:FindFirstChild(carName)
            local tempModel = nil
            if not carModel then
                local modelTemplate = game:GetService("ReplicatedStorage").Assets.CarModels:FindFirstChild(carName)
                if modelTemplate then
                    tempModel = modelTemplate:Clone()
                    tempModel.Name = carName
                    tempModel.Parent = workspace.Debris
                    carModel = tempModel
                end
            end
            if carModel then
                Event:FireServer("Purchase", { Car = carModel, Name = carName })
                if tempModel then task.delay(1.5, function() pcall(function() tempModel:Destroy() end) end) end
            end
        end)
    end
end)

local cBLC = cCd(smC.r, "Bypass Locked Cars")
local STEAL_CARS_LIST = { "Loading..." }
local STEAL_CARS_REFS = {}

local ddSteal = cDd(cBLC, "Select Car", STEAL_CARS_LIST, cfg.StealCarIdx, function(v)
    cfg.StealCarIdx = v; saveCfg()
end)

cBtn(cBLC, "Steal Selected Car", function()
    local targetVehicle = STEAL_CARS_REFS[cfg.StealCarIdx] or STEAL_CARS_REFS[1]
    if not targetVehicle then return end

    local targetSeat = targetVehicle:FindFirstChild("DriveSeat") or
        targetVehicle:FindFirstChildOfClass("VehicleSeat", true)
    if not targetSeat or targetSeat.Occupant then return end

    local charFolder = workspace:FindFirstChild("Characters")
    local myModel = (charFolder and charFolder:FindFirstChild(lp.Name)) or lp.Character or
        workspace:FindFirstChild(lp.Name)
    local hum = myModel and myModel:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    pcall(function()
        if targetVehicle:GetAttribute("Locked") then
            targetVehicle:SetAttribute("Locked", false)
        end
    end)
    targetSeat:Sit(hum)
end)

task.spawn(function()
    while task.wait(2) do
        local list = {}
        local refs = {}
        local carsFolder = workspace:FindFirstChild("Cars")
        if carsFolder then
            local charFolder = workspace:FindFirstChild("Characters")
            local myModel = (charFolder and charFolder:FindFirstChild(lp.Name)) or lp.Character or
                workspace:FindFirstChild(lp.Name)
            local myRoot = myModel and myModel:FindFirstChild("HumanoidRootPart")

            for _, veh in ipairs(carsFolder:GetChildren()) do
                local seatObj = veh:FindFirstChild("DriveSeat") or veh:FindFirstChildOfClass("VehicleSeat", true)
                if seatObj and not seatObj.Occupant then
                    local carType = veh:GetAttribute("CarType") or veh.Name
                    local owner = veh:GetAttribute("Owner") or "Unowned"
                    local dist = myRoot and math.floor((seatObj.Position - myRoot.Position).Magnitude) or 0
                    local displayName = string.format("%s (%s) [%dm]", tostring(carType), tostring(owner), dist)
                    table.insert(list, displayName)
                    table.insert(refs, veh)
                end
            end
        end
        if #list == 0 then
            table.insert(list, "No Available Cars")
        end
        STEAL_CARS_LIST = list
        STEAL_CARS_REFS = refs
        if ddSteal and ddSteal.REFRESH then ddSteal.REFRESH(list) end
    end
end)

local smU = cST(tC, "Utilities")

local cMov = cCd(smU.l, "Movement")

local speedConn = nil
local speedAttachment = nil
local speedVelocity = nil

local function CLEANUP_SPEED()
    if speedConn then
        speedConn:Disconnect(); speedConn = nil
    end
    pcall(function()
        if speedVelocity then
            speedVelocity:Destroy(); speedVelocity = nil
        end
        if speedAttachment then
            speedAttachment:Destroy(); speedAttachment = nil
        end
        local char = lp.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, child in ipairs(hrp:GetChildren()) do
                    if child.Name == "SpeedBypassVelocity" or child.Name == "SpeedBypassAttachment" then
                        child:Destroy()
                    end
                end
            end
        end
    end)
end

local function APPLY_SPEED_BOOST()
    CLEANUP_SPEED()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    speedAttachment = Instance.new("Attachment")
    speedAttachment.Name = "SpeedBypassAttachment"
    speedAttachment.Parent = root

    speedVelocity = Instance.new("LinearVelocity")
    speedVelocity.Name = "SpeedBypassVelocity"
    speedVelocity.Attachment0 = speedAttachment
    speedVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    speedVelocity.MaxAxesForce = Vector3.new(25000, 0, 25000)
    speedVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    speedVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    speedVelocity.Parent = root

    speedConn = game:GetService("RunService").Heartbeat:Connect(function()
        local c2 = lp.Character
        local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
        if not r2 or not h2 or not speedVelocity then
            CLEANUP_SPEED(); return
        end

        local moveDir = h2.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local target = cfg.WalkSpeedVal or 50
            local targetSpeed = 20 + (target / 100) * (28 - 20)
            speedVelocity.VectorVelocity = Vector3.new(moveDir.X * targetSpeed, 0, moveDir.Z * targetSpeed)
        else
            speedVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

cTg(cMov, "WalkSpeed Bypass", cfg.WalkSpeedBypass, function(v)
    cfg.WalkSpeedBypass = v; saveCfg()
    if v then APPLY_SPEED_BOOST() else CLEANUP_SPEED() end
end)
cSl(cMov, "WalkSpeed Value", 0, 100, cfg.WalkSpeedVal, function(v)
    cfg.WalkSpeedVal = v; saveCfg()
end)

local flyConnection = nil
local flyPos = Vector3.zero

local function CLEANUP_FLY()
    if flyConnection then
        flyConnection:Disconnect(); flyConnection = nil
    end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    pcall(function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "BypassFlyPlatform" then obj:Destroy() end
        end
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child.Name == "BypassFlyPlatform" then child:Destroy() end
            end
        end
    end)
end

cTg(cMov, "Player Fly", cfg.PlayerFly, function(v)
    cfg.PlayerFly = v; saveCfg()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    if v then
        CLEANUP_FLY()
        flyPos = root.Position
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

        local flyPlatform = Instance.new("Part")
        flyPlatform.Name = "BypassFlyPlatform"
        flyPlatform.Size = Vector3.new(6, 1, 6)
        flyPlatform.Transparency = 1
        flyPlatform.Anchored = true
        flyPlatform.CanCollide = true
        flyPlatform.Material = Enum.Material.Glass
        flyPlatform.CFrame = root.CFrame * CFrame.new(0, -3.1, 0)
        flyPlatform.Parent = workspace

        flyConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
            local c2 = lp.Character
            local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
            local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
            if not r2 or not r2.Parent or not h2 or not flyPlatform.Parent then
                CLEANUP_FLY(); return
            end

            h2.PlatformStand = false
            h2:ChangeState(Enum.HumanoidStateType.Swimming)

            local cam = workspace.CurrentCamera
            local cf = cam.CFrame
            local speedVal = cfg.PlayerFlySpeed or 50
            local speed = (speedVal / 100) * 19.8

            local UIS2 = game:GetService("UserInputService")
            local moveDir = Vector3.new(0, 0, 0)

            if UIS2:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cf.LookVector end
            if UIS2:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cf.LookVector end
            if UIS2:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cf.RightVector end
            if UIS2:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cf.RightVector end

            local vertical = 0
            if UIS2:IsKeyDown(Enum.KeyCode.Space) then
                vertical = 1
            elseif UIS2:IsKeyDown(Enum.KeyCode.LeftShift) then
                vertical = -1
            end

            local velocity = Vector3.new(0, 0, 0)
            if moveDir.Magnitude > 0 then velocity = moveDir.Unit * speed end
            if vertical ~= 0 then velocity = velocity + Vector3.new(0, vertical * speed, 0) end

            flyPos = flyPos + (velocity * dt)
            local targetPos = flyPos - Vector3.new(0, 3.1, 0)

            flyPlatform.CFrame = CFrame.new(targetPos)
            r2.CFrame = CFrame.new(flyPos, cam.CFrame.Position + (flyPos - cam.CFrame.Position) * 2)
        end)
    else
        CLEANUP_FLY()
    end
end)
cSl(cMov, "Player Fly Speed", 0, 100, cfg.PlayerFlySpeed, function(v)
    cfg.PlayerFlySpeed = v; saveCfg()
end)

local staminaConn = nil
local originalStaminaLoss = nil
local originalStaminaGain = nil
local originalStaminaCD = nil
local staminaCfgTable = nil
local staminaStateTable = nil

local function FIND_STAMINA_TABLES()
    if staminaCfgTable and staminaStateTable then return staminaCfgTable, staminaStateTable end
    local gc = (type(getgc) == "function" and getgc)
    if not gc then return nil, nil end

    local success, tbls = pcall(function() return gc(true) end)
    if not success then success, tbls = pcall(function() return gc() end) end
    if not success or not tbls then return nil, nil end

    for _, v in ipairs(tbls) do
        if type(v) == "table" then
            if rawget(v, "STAMINA_LOSS_RATE") ~= nil and rawget(v, "STAMINA_GAIN_RATE") ~= nil then staminaCfgTable = v end
            if rawget(v, "Stamina") ~= nil and rawget(v, "IsVaulting") ~= nil then staminaStateTable = v end
        end
        if staminaCfgTable and staminaStateTable then break end
    end
    return staminaCfgTable, staminaStateTable
end

local function APPLY_INF_STAMINA()
    local sCfg, state = FIND_STAMINA_TABLES()
    if sCfg then
        if originalStaminaLoss == nil then originalStaminaLoss = sCfg.STAMINA_LOSS_RATE end
        if originalStaminaGain == nil then originalStaminaGain = sCfg.STAMINA_GAIN_RATE end
        if originalStaminaCD == nil then originalStaminaCD = sCfg.STAMINA_CD_TIME end
        sCfg.STAMINA_LOSS_RATE = 0
        sCfg.STAMINA_GAIN_RATE = 9999
        sCfg.STAMINA_CD_TIME = 0
    end
    if staminaConn then
        staminaConn:Disconnect(); staminaConn = nil
    end
    staminaConn = game:GetService("RunService").Heartbeat:Connect(function()
        local _, s = FIND_STAMINA_TABLES()
        if s then s.Stamina = 100 end
    end)
end

local function CLEANUP_STAMINA()
    if staminaConn then
        staminaConn:Disconnect(); staminaConn = nil
    end
    local sCfg, _ = FIND_STAMINA_TABLES()
    if sCfg then
        if originalStaminaLoss ~= nil then sCfg.STAMINA_LOSS_RATE = originalStaminaLoss end
        if originalStaminaGain ~= nil then sCfg.STAMINA_GAIN_RATE = originalStaminaGain end
        if originalStaminaCD ~= nil then sCfg.STAMINA_CD_TIME = originalStaminaCD end
    end
end

cTg(cMov, "Inf Stamina", cfg.InfStamina, function(v)
    cfg.InfStamina = v; saveCfg()
    if v then APPLY_INF_STAMINA() else CLEANUP_STAMINA() end
end)

local carFlyConnection = nil
local originalCollisions = {}
local currentVehicle = nil
local isCarFlying = false

local function get_vic()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil, nil end
    local seat = hum.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        local vehicle = seat:FindFirstAncestorWhichIsA("Model") or seat.Parent
        return vehicle, seat
    end
    return nil, nil
end

local function cleanupCarFly()
    if carFlyConnection then
        carFlyConnection:Disconnect(); carFlyConnection = nil
    end
    pcall(function()
        if currentVehicle then
            for _, p in ipairs(currentVehicle:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    if originalCollisions[p] ~= nil then p.CanCollide = originalCollisions[p] end
                end
            end
        end
    end)
    originalCollisions = {}
    currentVehicle = nil
    isCarFlying = false
end

local function startCarFly()
    cleanupCarFly()
    local vehicle, seat = get_vic()
    if not vehicle or not seat then return end

    currentVehicle = vehicle
    isCarFlying = true
    local cFlyPos = seat.Position

    for _, p in ipairs(vehicle:GetDescendants()) do
        if p:IsA("BasePart") then
            originalCollisions[p] = p.CanCollide
            p.Anchored = true
            if p ~= seat then p.CanCollide = false end
        end
    end

    carFlyConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
        if not isCarFlying or not vehicle.Parent or not seat.Parent then
            cleanupCarFly(); return
        end

        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.SeatPart ~= seat then
            cleanupCarFly(); return
        end

        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        local speed = cfg.CarFlySpeed or 150
        local UIS2 = game:GetService("UserInputService")
        local moveDir = Vector3.new(0, 0, 0)

        if UIS2:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cf.LookVector end
        if UIS2:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cf.LookVector end
        if UIS2:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cf.RightVector end
        if UIS2:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cf.RightVector end

        local vertical = 0
        if UIS2:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UIS2:IsKeyDown(Enum.KeyCode.LeftShift) then
            vertical = -1
        end

        local velocity = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then velocity = moveDir.Unit * speed end
        if vertical ~= 0 then velocity = velocity + Vector3.new(0, vertical * speed, 0) end

        cFlyPos = cFlyPos + (velocity * dt)
        vehicle:PivotTo(CFrame.new(cFlyPos, cam.CFrame.Position + (cFlyPos - cam.CFrame.Position) * 2))
    end)
end

getgenv().CLEANUP_ALL_PHYSICS = function()
    pcall(CLEANUP_SPEED)
    pcall(CLEANUP_FLY)
    pcall(CLEANUP_STAMINA)
    pcall(cleanupCarFly)
end

cTg(cMov, "Car Fly", cfg.CarFly, function(v)
    cfg.CarFly = v; saveCfg()
    if v then startCarFly() else cleanupCarFly() end
end)
cSl(cMov, "Car Fly Speed", 0, 1000, cfg.CarFlySpeed, function(v)
    cfg.CarFlySpeed = v; saveCfg()
end)

local cExt = cCd(smU.r, "Extras")
local EXTRAS_PLAYERS_LIST = { "Loading..." }
local ddExtras = cDd(cExt, "Target Player", EXTRAS_PLAYERS_LIST, cfg.ExtrasTargetPlayer, function(v)
    cfg.ExtrasTargetPlayer = v; saveCfg()
end)

task.spawn(function()
    while task.wait(5) do
        local list = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p.Name) end
        end
        table.sort(list)
        if #list == 0 then table.insert(list, "None") end
        EXTRAS_PLAYERS_LIST = list
        if ddExtras and ddExtras.REFRESH then ddExtras.REFRESH(list) end
    end
end)

local sndAmt = "0"
cTb(cExt, "Enter amount (e.g. 5000)", "", function(v, tbObj)
    local clean = v:gsub("[^%d]", "")
    sndAmt = clean
    tbObj.Text = clean
end)

cBtn(cExt, "Deposit ATM", function()
    local amount = tonumber(sndAmt) or 0
    if amount <= 0 then return end
    local atmRE = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net["RE/ATM"]
    if atmRE then pcall(function() atmRE:FireServer("Deposit", amount) end) end
end)

cBtn(cExt, "Withdraw ATM", function()
    local amount = tonumber(sndAmt) or 0
    if amount <= 0 then return end
    local atmRE = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net["RE/ATM"]
    if atmRE then pcall(function() atmRE:FireServer("Withdraw", amount) end) end
end)

cBtn(cExt, "Send Money", function()
    local selectedStr = EXTRAS_PLAYERS_LIST[cfg.ExtrasTargetPlayer]
    if not selectedStr or selectedStr == "None" or selectedStr == "Loading..." then return end
    local targetPlayer = game:GetService("Players"):FindFirstChild(selectedStr)
    local amount = tonumber(sndAmt) or 0
    if not targetPlayer or amount <= 0 then return end

    local Event = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net["RE/VicePay"]
    if Event then
        pcall(function() Event:FireServer("Send", targetPlayer, amount) end)
    end
end)


-- Dependencies
local RS = game:GetService("RunService")
local PLRS = game:GetService("Players")
local SPEED = 200
local THRESHOLD = 5

local function safeParent(inst, parent)
    if not inst or not parent then return end
    pcall(function() inst.Parent = parent end)
end

local function NOTIFY() end

local function FORCE_HOLD(prompt)
    if not prompt then return end
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait((prompt.HoldDuration and prompt.HoldDuration > 0) and (prompt.HoldDuration + 0.1) or 0.2)
        prompt:InputHoldEnd()
    end)
end

local function WH01AM_TP(target, timeout)
    timeout         = timeout or 35
    local targetPos = typeof(target) == "CFrame" and target.Position or target

    local plr       = PLRS.LocalPlayer
    local char      = workspace:FindFirstChild(plr.Name) or (plr and plr.Character)
    local hrp       = char and char:FindFirstChild("HumanoidRootPart")
    local hum       = char and char:FindFirstChildOfClass("Humanoid")
    local att       = hrp and hrp:FindFirstChild("RootAttachment")

    if not (hrp and att) then return end

    hrp.Anchored = false

    if hum and hum.SeatPart then
        hum.Sit = false
        task.wait(0.1)
    end

    local origCollide = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            origCollide[p] = p.CanCollide
            p.CanCollide = false
        end
    end

    local lv                  = Instance.new("LinearVelocity")
    lv.Attachment0            = att
    lv.MaxForce               = math.huge
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity         = Vector3.zero
    lv.Parent                 = hrp

    local noclipConn
    noclipConn                = RS.Stepped:Connect(function()
        if not char or not char.Parent then
            noclipConn:Disconnect()
            return
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end)

    local arrived             = false
    local startTime           = tick()

    local conn
    conn                      = RS.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent or (tick() - startTime > timeout) then
            conn:Disconnect()
            noclipConn:Disconnect()
            pcall(function() lv:Destroy() end)
            arrived = true
            return
        end

        local remaining = targetPos - hrp.Position
        local dist = remaining.Magnitude

        if dist <= THRESHOLD then
            lv.VectorVelocity = Vector3.zero
            conn:Disconnect()
            pcall(function() lv:Destroy() end)
            arrived = true

            task.delay(1, function()
                noclipConn:Disconnect()
                for p, state in pairs(origCollide) do
                    pcall(function() p.CanCollide = state end)
                end
            end)

            return
        end

        local speed = math.clamp(dist * 3, 20, SPEED)
        lv.VectorVelocity = remaining.Unit * speed
    end)

    while not arrived do
        task.wait(0.05)
    end
end

local function BYPASS_TP(targetPos)
    WH01AM_TP(targetPos)
end


-- Farm logic
local smF_F = cST(tF, "Farms")
local smF_J = cST(tF, "Jail")
getgenv().FARM_STATE = { Active = true }

local function SETUP_FARMS()
    local LPLR = game:GetService("Players").LocalPlayer
    local function safeGet(root, path)
        local current = root
        for _, name in ipairs(path) do
            if not current then return nil end
            current = current:FindFirstChild(name)
        end
        return current
    end

    local function getPromptPosition(prompt)
        if not prompt then return nil end
        pcall(function()
            prompt.MaxActivationDistance = 25
            prompt.RequiresLineOfSight = false
        end)
        local parent = prompt.Parent
        if not parent then return nil end
        if parent:IsA("BasePart") then
            return parent.Position
        elseif parent:IsA("Attachment") then
            return parent.WorldPosition
        elseif parent:IsA("Model") then
            return parent:GetPivot().Position
        end
        local part = parent:FindFirstChildWhichIsA("BasePart", true)
        if part then return part.Position end
        if parent:IsA("PVInstance") then return parent:GetPivot().Position end
        return nil
    end

    local function triggerPrompt(prompt)
        if not prompt then return end
        pcall(function()
            prompt.MaxActivationDistance = 25
            prompt.RequiresLineOfSight = false
        end)
        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
        else
            FORCE_HOLD(prompt)
        end
    end

    local function forceAnchor()
        pcall(function()
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                workspace:FindFirstChild(LPLR.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = true end
        end)
    end

    local function isRobberyLoot(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local nameLower = tool.Name:lower()
        if tool.Name == "Drill" or tool.Name == "Phone" or tool.Name == "Fists" then
            return false
        end
        if nameLower:find("key") then
            return false
        end
        if tool:FindFirstChildOfClass("LocalScript", true) or tool:FindFirstChildOfClass("Script", true) or tool:FindFirstChildOfClass("ModuleScript", true) then
            return false
        end
        local weaponPatterns = {
            "ARPistol", "Draco", "G17", "G22 DB", "G43X Beam", "Tec-9", "Draco Drum", "G19 Clear EXT",
            "Springfield Hellcat"
        }
        for _, pat in ipairs(weaponPatterns) do
            if nameLower:find(pat) then
                return false
            end
        end
        if nameLower:match("rep") then
            return false
        end
        return true
    end

    local function forceUnequipAllTools()
        pcall(function()
            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
            local backpack = LPLR.Backpack
            if char and backpack then
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("Tool") then
                        child.Parent = backpack
                    end
                end
            end
        end)
    end

    local function tpClassic(pos)
        WH01AM_TP(pos)
    end
    local cRepz = cCd(smF_F.l, "Repz Farm")

    getgenv().FARM_STATE.selectedMaterial = nil
    getgenv().FARM_STATE.selectedBlank = nil
    getgenv().FARM_STATE.purchaseQty = 1

    getgenv().FARM_STATE.lastNotificationTime = nil
    getgenv().FARM_STATE.autoPrintActive = false
    getgenv().FARM_STATE.autoPrintThread = nil

    local function getMyPlacedPrinters()
        local serverPlacements = workspace:FindFirstChild("Placements") and
            workspace.Placements:FindFirstChild("Server")
        if not serverPlacements then return {} end
        local printers = {}
        for _, v in ipairs(serverPlacements:GetChildren()) do
            if v.Name == "Screen Printer" and v:GetAttribute("Owner") == LPLR.Name then
                local handle = v:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    table.insert(printers, { model = v, prompt = prompt })
                end
            end
        end
        return printers
    end

    local function startPrintingSequence()
        local backpack = LPLR.Backpack
        local char = LPLR.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end

        local placedPrinters = getMyPlacedPrinters()


        for _, printer in ipairs(placedPrinters) do
            local prompt = printer.prompt
            if prompt.ActionText == "Collect Rep" then
                NOTIFY("Repz Farm", "Printer has ready reps. Collecting...", 3)
                local startCollect = tick()
                while prompt.Enabled and prompt.Parent and tick() - startCollect < 5 do
                    FORCE_HOLD(prompt)
                    task.wait(0.25)
                end
                task.wait(0.5)
                return true
            end
        end


        for _, printer in ipairs(placedPrinters) do
            local prompt = printer.prompt
            if prompt.ActionText == "Place Clothing (Shirt/Pants)" then
                local blankTool = backpack:FindFirstChild("Shirt Blank") or char:FindFirstChild("Shirt Blank") or
                    backpack:FindFirstChild("Pants Blank") or char:FindFirstChild("Pants Blank")

                if not blankTool then
                    if not getgenv().FARM_STATE.lastNotificationTime or tick() - getgenv().FARM_STATE.lastNotificationTime > 15 then
                        NOTIFY("Repz Farm", "Missing: Shirt/Pants Blank!", 5)
                        getgenv().FARM_STATE.lastNotificationTime = tick()
                    end
                    return false
                end

                NOTIFY("Repz Farm", "Loading blank (" .. blankTool.Name .. ")...", 3)
                if blankTool.Parent == LPLR.Backpack then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(blankTool)
                    task.wait(0.25)
                end

                local startLoad = tick()
                while blankTool.Parent == char and tick() - startLoad < 5 do
                    FORCE_HOLD(prompt)
                    task.wait(0.25)
                end

                pcall(function() hum:UnequipTools() end)
                task.wait(0.25)
                return true
            end
        end


        for _, printer in ipairs(placedPrinters) do
            local prompt = printer.prompt
            if prompt.ActionText == "Place Print" then
                local printTool = backpack:FindFirstChild("Basic Print") or char:FindFirstChild("Basic Print") or
                    backpack:FindFirstChild("Premium Print") or char:FindFirstChild("Premium Print") or
                    backpack:FindFirstChild("Designer Print") or char:FindFirstChild("Designer Print")

                if not printTool then
                    if not getgenv().FARM_STATE.lastNotificationTime or tick() - getgenv().FARM_STATE.lastNotificationTime > 15 then
                        NOTIFY("Repz Farm", "Missing: Print Material!", 5)
                        getgenv().FARM_STATE.lastNotificationTime = tick()
                    end
                    return false
                end

                NOTIFY("Repz Farm", "Applying print design (" .. printTool.Name .. ")...", 3)
                if printTool.Parent == LPLR.Backpack then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(printTool)
                    task.wait(0.25)
                end

                local startPrint = tick()
                while printTool.Parent == char and tick() - startPrint < 5 do
                    FORCE_HOLD(prompt)
                    task.wait(0.25)
                end

                pcall(function() hum:UnequipTools() end)
                task.wait(0.25)
                return true
            end
        end


        local printerTool = backpack:FindFirstChild("Screen Printer") or char:FindFirstChild("Screen Printer")
        if not printerTool and getnilinstances then
            for _, obj in ipairs(getnilinstances()) do
                if obj.Name == "Screen Printer" and obj:IsA("Tool") then
                    printerTool = obj
                    break
                end
            end
        end

        if printerTool then
            local blankTool = backpack:FindFirstChild("Shirt Blank") or char:FindFirstChild("Shirt Blank") or
                backpack:FindFirstChild("Pants Blank") or char:FindFirstChild("Pants Blank")

            local printTool = backpack:FindFirstChild("Basic Print") or char:FindFirstChild("Basic Print") or
                backpack:FindFirstChild("Premium Print") or char:FindFirstChild("Premium Print") or
                backpack:FindFirstChild("Designer Print") or char:FindFirstChild("Designer Print")

            if blankTool and printTool then
                NOTIFY("Repz Farm", "Equipping Screen Printer tool...", 3)
                if printerTool.Parent == LPLR.Backpack then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(printerTool)
                    task.wait(0.25)
                end

                NOTIFY("Repz Farm", "Placing new Screen Printer...", 3)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return false end
                local offsetOffset = #placedPrinters * 3.5
                local placeCF = hrp.CFrame * CFrame.new(offsetOffset, -2.5, -4.5)
                local Event = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"]
                    .net["RF/InvokePlacement"]

                pcall(function()
                    Event:InvokeServer("Place", printerTool, placeCF, false)
                end)
                task.wait(0.5)

                pcall(function() hum:UnequipTools() end)
                task.wait(0.25)
                return true
            end
        end


        local blankTool = backpack:FindFirstChild("Shirt Blank") or char:FindFirstChild("Shirt Blank") or
            backpack:FindFirstChild("Pants Blank") or char:FindFirstChild("Pants Blank")

        local printTool = backpack:FindFirstChild("Basic Print") or char:FindFirstChild("Basic Print") or
            backpack:FindFirstChild("Premium Print") or char:FindFirstChild("Premium Print") or
            backpack:FindFirstChild("Designer Print") or char:FindFirstChild("Designer Print")

        if not blankTool or not printTool then
            local missing = {}
            if not blankTool then table.insert(missing, "Shirt/Pants Blank") end
            if not printTool then table.insert(missing, "Print Material") end
            if not getgenv().FARM_STATE.lastNotificationTime or tick() - getgenv().FARM_STATE.lastNotificationTime > 15 then
                NOTIFY("Repz Farm", "Missing: " .. table.concat(missing, ", "), 5)
                getgenv().FARM_STATE.lastNotificationTime = tick()
            end
            return false
        end


        if not getgenv().FARM_STATE.lastNotificationTime or tick() - getgenv().FARM_STATE.lastNotificationTime > 10 then
            NOTIFY("Repz Farm", "All printers busy. Waiting for printing to complete...", 3)
            getgenv().FARM_STATE.lastNotificationTime = tick()
        end
        task.wait(1)
        return true
    end

    local D_MATERIAL = cDd(cRepz, "Select Material", { "Option 1" }, 1, function(v)
        getgenv().FARM_STATE.selectedMaterial = v:match("^(.-)%s*%$") or v
    end)
    D_MATERIAL.REFRESH({
        "Basic Print $50",
        "Premium Print $250",
        "Designer Print $500"
    })

    local D_BLANK = cDd(cRepz, "Select Blank", { "Option 1" }, 1, function(v)
        getgenv().FARM_STATE.selectedBlank = v:match("^(.-)%s*%$") or v
    end)
    D_BLANK.REFRESH({
        "Shirt Blank $200",
        "Pants Blank $400"
    })

    local D_QTY = cDd(cRepz, "Qty: 1", { "Option 1" }, 1, function(v)
        getgenv().FARM_STATE.purchaseQty = tonumber(v) or 1
    end)
    D_QTY.REFRESH({ "1", "2", "3", "4" })

    local function getMyPropertyModel()
        local CS = game:GetService("CollectionService")
        for _, apt in ipairs(CS:GetTagged("Apt")) do
            if apt:GetAttribute("Owner") == LPLR.Name then
                return apt
            end
        end

        local aptFolders = {
            workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("BrokeAPTS"),
            workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("Houses")
        }
        for _, folder in ipairs(aptFolders) do
            if folder then
                for _, apt in ipairs(folder:GetChildren()) do
                    if apt:GetAttribute("Owner") == LPLR.Name then
                        return apt
                    end

                    local found = false
                    pcall(function()
                        local buyPart = apt:FindFirstChild("BuyPart")
                        local userLabel = buyPart and buyPart:FindFirstChild("UI")
                            and buyPart.UI:FindFirstChild("Owned")
                            and buyPart.UI.Owned:FindFirstChild("Frame")
                            and buyPart.UI.Owned.Frame:FindFirstChild("User")
                        if userLabel and userLabel:IsA("TextLabel") then
                            if userLabel.Text == LPLR.Name or userLabel.Text == LPLR.DisplayName then
                                found = true
                            end
                        end
                    end)
                    if found then return apt end
                end
            end
        end
        return nil
    end

    local function forceAnchor()
        pcall(function()
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                workspace:FindFirstChild(LPLR.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = true end
        end)
    end

    local function getPromptPosition(prompt)
        if not prompt then return nil end
        local parent = prompt.Parent
        if parent:IsA("BasePart") then
            return parent.Position
        elseif parent:IsA("Attachment") then
            return parent.WorldPosition
        end
        return parent:GetPivot().Position
    end

    local function triggerPrompt(prompt)
        if not prompt then return end
        pcall(function()
            prompt.MaxActivationDistance = 10
            prompt.RequiresLineOfSight = false
        end)
        task.wait(0.02)

        pcall(function()
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                workspace:FindFirstChild(LPLR.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end)
        task.wait(0.25) -- Wait 0.25s for replication before triggering prompt

        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
            task.wait(0.05)
            pcall(fireproximityprompt, prompt)
        else
            pcall(function()
                prompt:InputHoldBegin()
                local duration = prompt.HoldDuration or 0
                if duration > 0 then
                    task.wait(duration + 0.05)
                end
                prompt:InputHoldEnd()
            end)
        end

        task.wait(0.1)
        forceAnchor()
    end

    local autoPrintTgl, autoBuyPrintTgl
    getgenv().FARM_STATE.autoBuyPrintActive = false
    getgenv().FARM_STATE.autoBuyPrintThread = nil

    local function hasAnyRepzTools()
        local backpack = LPLR.Backpack
        local char = LPLR.Character
        local toolNames = {
            "Screen Printer",
            "Shirt Blank",
            "Pants Blank",
            "Basic Print",
            "Premium Print",
            "Designer Print"
        }
        for _, name in ipairs(toolNames) do
            if backpack:FindFirstChild(name) or char:FindFirstChild(name) then
                return true
            end
        end
        return false
    end

    autoPrintTgl = cTg(cRepz, "Auto Print & Collect", cfg.RepzAutoPrint or false, function(v)
        getgenv().FARM_STATE.autoPrintActive = v
        if getgenv().FARM_STATE.autoPrintThread then
            task.cancel(getgenv().FARM_STATE.autoPrintThread)
            getgenv().FARM_STATE.autoPrintThread = nil
        end

        if getgenv().FARM_STATE.autoPrintActive then
            if autoBuyPrintTgl and getgenv().FARM_STATE.autoBuyPrintActive then
                autoBuyPrintTgl:SET(false, true)
            end

            getgenv().FARM_STATE.autoPrintThread = task.spawn(function()
                while getgenv().FARM_STATE.autoPrintActive do
                    local success = startPrintingSequence()
                    if not success then
                        task.wait(3)
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end)

    autoBuyPrintTgl = cTg(cRepz, "Auto Buy, Print & Collect", cfg.RepzAutoBuyPrint or false, function(v)
        getgenv().FARM_STATE.autoBuyPrintActive = v
        if getgenv().FARM_STATE.autoBuyPrintThread then
            task.cancel(getgenv().FARM_STATE.autoBuyPrintThread)
            getgenv().FARM_STATE.autoBuyPrintThread = nil
        end

        if getgenv().FARM_STATE.autoBuyPrintActive then
            if autoPrintTgl and getgenv().FARM_STATE.autoPrintActive then
                autoPrintTgl:SET(false, true)
            end

            getgenv().FARM_STATE.autoBuyPrintThread = task.spawn(function()
                while getgenv().FARM_STATE.autoBuyPrintActive do
                    -- 1. Check property
                    local myApt = getMyPropertyModel()
                    if not myApt then
                        NOTIFY("Repz Farm", "Error: You must own a property first!", 4)
                        task.wait(5)
                    else
                        local deliveryPromptModel = myApt:FindFirstChild("DeliveryPrompt")
                        local prompt = deliveryPromptModel and deliveryPromptModel:FindFirstChild("ProximityPrompt")
                        if not prompt then
                            NOTIFY("Repz Farm", "Error: DeliveryPrompt not found!", 4)
                            task.wait(5)
                        elseif not getgenv().FARM_STATE.selectedMaterial or not getgenv().FARM_STATE.selectedBlank then
                            -- 2. Verify selections
                            NOTIFY("Repz Farm", "Error: Select Material & Blank first!", 4)
                            task.wait(5)
                        else
                            -- 3. Calculate cost and adjust quantity
                            local matPrice = (getgenv().FARM_STATE.selectedMaterial == "Basic Print" and 50) or
                                (getgenv().FARM_STATE.selectedMaterial == "Premium Print" and 250) or
                                (getgenv().FARM_STATE.selectedMaterial == "Designer Print" and 500) or 0
                            local blankPrice = (getgenv().FARM_STATE.selectedBlank == "Shirt Blank" and 200) or
                                (getgenv().FARM_STATE.selectedBlank == "Pants Blank" and 400) or 0
                            local machinePrice = 1300
                            local costPerUnit = matPrice + blankPrice + machinePrice

                            local currentCash = getPlayerCash()
                            if currentCash < costPerUnit then
                                NOTIFY("Repz Farm",
                                    string.format("Waiting for cash... Need $%d, you have $%d", costPerUnit,
                                        currentCash), 5)
                                task.wait(5)
                            else
                                local maxAffordable = math.floor(currentCash / costPerUnit)
                                local targetQty = getgenv().FARM_STATE.purchaseQty
                                if targetQty > maxAffordable then
                                    NOTIFY("Repz Farm",
                                        string.format("Adjusting batch size from %d to %d due to cash", targetQty,
                                            maxAffordable), 4)
                                    targetQty = maxAffordable
                                end

                                -- 4. Buy batch
                                local Event = game:GetService("ReplicatedStorage").Modules.Packages._Index
                                    ["sleitnick_net@0.2.0"].net["RE/Repz"]
                                if not Event then
                                    NOTIFY("Repz Farm", "Error: RE/Repz not found!", 5)
                                    task.wait(5)
                                else
                                    local loopSuccess = true
                                    for i = 1, targetQty do
                                        if not getgenv().FARM_STATE.autoBuyPrintActive then
                                            loopSuccess = false; break
                                        end

                                        NOTIFY("Repz Farm", string.format("Buying item #%d of %d...", i, targetQty),
                                            3)
                                        pcall(function()
                                            Event:FireServer("PurchaseMaterial",
                                                getgenv().FARM_STATE.selectedMaterial)
                                        end)
                                        task.wait(1)
                                        pcall(function()
                                            Event:FireServer("PurchaseBlank",
                                                getgenv().FARM_STATE.selectedBlank)
                                        end)
                                        task.wait(1)
                                        pcall(function() Event:FireServer("PurchaseMachine", "Screen Printer") end)
                                        task.wait(1)

                                        -- Wait for delivery while performing printing tasks in the background
                                        local startWait = tick()
                                        while tick() - startWait < 59 do
                                            if not getgenv().FARM_STATE.autoBuyPrintActive then
                                                loopSuccess = false; break
                                            end

                                            local elapsed = math.floor(tick() - startWait)
                                            local secRemaining = 59 - elapsed
                                            if secRemaining < 1 then break end

                                            NOTIFY("Repz Farm",
                                                string.format("Waiting for delivery... %d seconds remaining",
                                                    secRemaining), 1)

                                            local didAction = startPrintingSequence()
                                            if not didAction then
                                                task.wait(1)
                                            else
                                                task.wait(0.2)
                                            end
                                        end

                                        if not getgenv().FARM_STATE.autoBuyPrintActive then
                                            loopSuccess = false; break
                                        end

                                        -- Claim delivery
                                        local char = LPLR.Character
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            local startPos = hrp.Position
                                            NOTIFY("Repz Farm", "Claiming delivery...", 3)

                                            BYPASS_TP(deliveryPromptModel.Position)

                                            task.wait(0.2)

                                            local startClaim = tick()
                                            while prompt.Enabled and prompt.Parent and (tick() - startClaim < 8) and getgenv().FARM_STATE.autoBuyPrintActive do
                                                FORCE_HOLD(prompt)
                                                task.wait(0.3)
                                            end
                                            task.wait(0.5)

                                            NOTIFY("Repz Farm", "Returning to start position...", 3)
                                            BYPASS_TP(startPos)
                                            task.wait(0.5)
                                        end
                                    end

                                    if loopSuccess and getgenv().FARM_STATE.autoBuyPrintActive then
                                        -- 5. Loop printing until completely done
                                        NOTIFY("Repz Farm", "Starting printing sequence...", 3)
                                        while getgenv().FARM_STATE.autoBuyPrintActive do
                                            local hasTools = hasAnyRepzTools()
                                            local placed = getMyPlacedPrinters()
                                            if not hasTools and #placed == 0 then
                                                NOTIFY("Repz Farm", "Batch printing complete!", 4)
                                                break
                                            end

                                            startPrintingSequence()
                                            task.wait(1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)



    cBtn(cRepz, "Purchase Batch", function()
        if not getgenv().FARM_STATE.selectedMaterial then
            NOTIFY("Repz Farm", "Please select a Material first!", 3)
            return
        end
        if not getgenv().FARM_STATE.selectedBlank then
            NOTIFY("Repz Farm", "Please select a Blank first!", 3)
            return
        end


        local myApt = getMyPropertyModel()
        if not myApt then
            NOTIFY("Repz Farm", "You must own a property/apartment first!", 4)
            return
        end


        local matPrice = (getgenv().FARM_STATE.selectedMaterial == "Basic Print" and 50) or
            (getgenv().FARM_STATE.selectedMaterial == "Premium Print" and 250) or
            (getgenv().FARM_STATE.selectedMaterial == "Designer Print" and 500) or 0
        local blankPrice = (getgenv().FARM_STATE.selectedBlank == "Shirt Blank" and 200) or
            (getgenv().FARM_STATE.selectedBlank == "Pants Blank" and 400) or 0
        local machinePrice = 1300
        local costPerUnit = matPrice + blankPrice + machinePrice

        local currentCash = getPlayerCash()
        if currentCash < costPerUnit then
            NOTIFY("Repz Farm",
                string.format("Error: You need at least $%d for 1 item! (You have $%d)", costPerUnit, currentCash), 5)
            return
        end

        local maxAffordable = math.floor(currentCash / costPerUnit)
        if getgenv().FARM_STATE.purchaseQty > maxAffordable then
            NOTIFY("Repz Farm",
                string.format("Adjusted Qty from %d to %d due to insufficient cash ($%d needed)",
                    getgenv().FARM_STATE.purchaseQty,
                    maxAffordable, costPerUnit * getgenv().FARM_STATE.purchaseQty), 5)
            getgenv().FARM_STATE.purchaseQty = maxAffordable
        end

        NOTIFY("Repz Farm",
            string.format("Starting batch purchase of x%d items ($%d)...", getgenv().FARM_STATE.purchaseQty,
                costPerUnit * getgenv().FARM_STATE.purchaseQty), 4)

        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"].net
                ["RE/Repz"]
            if not Event then
                NOTIFY("Repz Farm", "Error: RE/Repz Event not found!", 3)
                return
            end

            local deliveryPromptModel = myApt:FindFirstChild("DeliveryPrompt")
            local prompt = deliveryPromptModel and deliveryPromptModel:FindFirstChild("ProximityPrompt")

            if not prompt then
                NOTIFY("Repz Farm", "Error: DeliveryPrompt not found in your property!", 4)
                return
            end

            for i = 1, getgenv().FARM_STATE.purchaseQty do
                NOTIFY("Repz Farm", "Buying item #" .. i .. " of " .. getgenv().FARM_STATE.purchaseQty .. "...", 3)


                pcall(function()
                    Event:FireServer("PurchaseMaterial", getgenv().FARM_STATE.selectedMaterial)
                end)
                task.wait(1)


                pcall(function()
                    Event:FireServer("PurchaseBlank", getgenv().FARM_STATE.selectedBlank)
                end)
                task.wait(1)


                pcall(function()
                    Event:FireServer("PurchaseMachine", "Screen Printer")
                end)
                task.wait(1)


                for sec = 59, 1, -1 do
                    NOTIFY("Repz Farm", string.format("Waiting for deliveries... %d seconds remaining", sec), 1)
                    task.wait(1)
                end


                local char = LPLR.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local startPos = hrp.Position
                    NOTIFY("Repz Farm", "Teleporting to claim all deliveries...", 3)

                    BYPASS_TP(deliveryPromptModel.Position)

                    task.wait(0.2)


                    local startClaim = tick()
                    while prompt.Enabled and prompt.Parent and (tick() - startClaim < 8) do
                        FORCE_HOLD(prompt)
                        task.wait(0.3)
                    end
                    task.wait(0.5)


                    NOTIFY("Repz Farm", "Returning to starting position...", 3)
                    BYPASS_TP(startPos)
                    task.wait(0.5)
                end
            end

            NOTIFY("Repz Farm", "Batch purchase completed successfully!", 4)
        end)
    end)

    cBtn(cRepz, "Collect Reps", function()
        local serverPlacements = workspace:FindFirstChild("Placements") and
            workspace.Placements:FindFirstChild("Server")
        if not serverPlacements then
            NOTIFY("Repz Farm", "Error: Placements.Server folder not found!", 3)
            return
        end

        local myPrinters = {}
        for _, v in ipairs(serverPlacements:GetChildren()) do
            if v.Name == "Screen Printer" and v:GetAttribute("Owner") == LPLR.Name then
                for _, desc in ipairs(v:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.ActionText == "Collect Rep" and desc.Enabled then
                        table.insert(myPrinters, { model = v, prompt = desc })
                    end
                end
            end
        end

        if #myPrinters == 0 then
            NOTIFY("Repz Farm", "No reps ready to collect!", 3)
            return
        end

        NOTIFY("Repz Farm", "Found " .. #myPrinters .. " ready printers. Starting collection...", 4)

        task.spawn(function()
            local char = LPLR.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local startPos = hrp.Position

            for idx, printerData in ipairs(myPrinters) do
                local prompt = printerData.prompt

                if prompt and prompt.Parent and prompt.Enabled then
                    NOTIFY("Repz Farm", "Collecting from printer #" .. idx .. "...", 3)

                    BYPASS_TP(prompt.Parent.Position)

                    task.wait(0.2)

                    if prompt and prompt.Parent and prompt.Enabled then
                        FORCE_HOLD(prompt)
                        task.wait(0.2)
                    end
                end
            end


            NOTIFY("Repz Farm", "Returning to starting position...", 4)
            BYPASS_TP(startPos)
        end)
    end)

    cBtn(cRepz, "Sell Reps", function()
        -- 1. Check if we have any Rep tools first
        local hasReps = false
        for _, tool in ipairs(LPLR.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                hasReps = true
                break
            end
        end
        if not hasReps then
            for _, tool in ipairs(LPLR.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                    hasReps = true
                    break
                end
            end
        end

        if not hasReps then
            NOTIFY("Repz Farm", "Error: You don't have any reps to sell in your inventory!", 4)
            return
        end

        -- 2. Find buyers
        local function findBuyer(name)
            local npcFolder = workspace:FindFirstChild("NPC")
            local rigsFolder = workspace:FindFirstChild("Rigs")

            local obj = npcFolder and npcFolder:FindFirstChild(name)
                or rigsFolder and rigsFolder:FindFirstChild(name)
                or workspace:FindFirstChild(name)
            return obj
        end

        local function findAnyPrompt(model)
            if not model then return nil end
            if model:IsA("ProximityPrompt") then return model end
            local p = model:FindFirstChildOfClass("ProximityPrompt")
            if p then return p end
            for _, desc in ipairs(model:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    return desc
                end
            end
            return nil
        end

        local foundBuyers = {}
        local buyerNames = {
            "RepsBuyer", "RepsBuyer2", "RepsBuyer3", "RepsBuyer4",
            "RepsBuyer5", "RepsBuyer6", "RepsBuyer7"
        }
        for _, name in ipairs(buyerNames) do
            local bObj = findBuyer(name)
            if bObj then
                table.insert(foundBuyers, bObj)
            end
        end

        if #foundBuyers == 0 then
            local folders = { workspace:FindFirstChild("NPC"), workspace:FindFirstChild("Rigs"), workspace }
            for _, folder in ipairs(folders) do
                if folder then
                    for _, child in ipairs(folder:GetChildren()) do
                        if child.Name:match("Buyer") or child.Name:match("Rep") then
                            table.insert(foundBuyers, child)
                        end
                    end
                end
            end
        end

        if #foundBuyers == 0 then
            NOTIFY("Repz Farm", "Error: Could not find any Reps Buyer NPC in the workspace!", 4)
            return
        end

        -- Pick a random buyer
        local chosenBuyer = foundBuyers[math.random(1, #foundBuyers)]
        local prompt = findAnyPrompt(chosenBuyer)
        if not prompt then
            NOTIFY("Repz Farm", "Error: No prompt found on the chosen buyer NPC!", 4)
            return
        end

        NOTIFY("Repz Farm", "Chosen buyer: " .. chosenBuyer.Name .. ". Starting sale...", 4)

        task.spawn(function()
            local char = LPLR.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local startPos = hrp.Position
            local targetPos = getPromptPosition(prompt) or chosenBuyer:GetPivot().Position

            -- Teleport to buyer
            BYPASS_TP(targetPos)
            task.wait(0.3)

            -- Keep selling until no Rep tools are left
            local selling = true
            while selling do
                local repTool = nil
                for _, tool in ipairs(LPLR.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                        repTool = tool
                        break
                    end
                end
                if not repTool then
                    for _, tool in ipairs(LPLR.Character:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                            repTool = tool
                            break
                        end
                    end
                end

                if not repTool then
                    selling = false
                    break
                end

                -- Equip the tool
                local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(repTool)
                    task.wait(0.2)
                end

                -- Trigger the prompt
                triggerPrompt(prompt)
                task.wait(0.3)
            end

            -- Teleport back
            NOTIFY("Repz Farm", "All repz sold! Returning to start position...", 4)
            BYPASS_TP(startPos)
        end)
    end) -- JAIL CLEAN FARM

    local function safeGet(root, path)
        local current = root
        for _, name in ipairs(path) do
            if not current then return nil end
            current = current:FindFirstChild(name)
        end
        return current
    end

    local function waitForPath(root, path, timeout)
        local start = tick()
        timeout = timeout or 5
        while tick() - start < timeout do
            local obj = safeGet(root, path)
            if obj then return obj end
            task.wait(0.2)
        end
        return nil
    end

    local cRob = cCd(smF_F.r, "House Robbery Farm")

    local houseRobActive = false
    local houseRobThread = nil

    local currentPlate = nil
    local function cleanupPlate()
        if currentPlate then
            pcall(function() currentPlate:Destroy() end)
            currentPlate = nil
        end
        pcall(function()
            local old = workspace:FindFirstChild("TempRobberyPlate")
            if old then old:Destroy() end
        end)
    end

    local function createPlate(targetPos)
        cleanupPlate()
        pcall(function()
            local plate = Instance.new("Part")
            plate.Name = "TempRobberyPlate"
            plate.Size = Vector3.new(10, 1, 10)
            plate.Position = targetPos - Vector3.new(0, 3.5, 0)
            plate.Material = Enum.Material.Asphalt
            plate.Transparency = 1
            plate.Anchored = true
            plate.CanCollide = true
            plate.Parent = workspace
            currentPlate = plate
        end)
    end



    local function tpClassic(pos)
        WH01AM_TP(pos)
    end

    local function getRoomFolder(houseName)
        return safeGet(workspace, { "HouseRobberies", "Rooms", houseName })
    end

    local function findPrompt(parent, name)
        if not parent then return nil end
        local child = parent:FindFirstChild(name)
        if child then
            if child:IsA("ProximityPrompt") then return child end
            local p = child:FindFirstChildOfClass("ProximityPrompt") or child:FindFirstChild("ProximityPrompt")
            if p then return p end
        end
        for _, desc in ipairs(parent:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and (desc.Name == name or desc.Parent.Name == name) then
                return desc
            end
        end
        return nil
    end
    local function exitHouseBeforeSelling(house)
        if not house then return true end

        local transitionFired = false
        local conn
        pcall(function()
            local event = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"]
                .net["RE/Transition"]
            conn = event.OnClientEvent:Connect(function()
                transitionFired = true
            end)
        end)

        local attempt = 0
        while houseRobActive do
            attempt = attempt + 1

            local room = getRoomFolder(house.Name)
            local leavePrompt = room and findPrompt(room, "Leave")

            -- If room folder or leave prompt is gone, character is already outside!
            if not room or not leavePrompt or not leavePrompt.Parent then
                if conn then pcall(function() conn:Disconnect() end) end
                task.wait(1.5)
                return true
            end

            local leavePos = getPromptPosition(leavePrompt)
            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            -- Check if transition fired or character is far from leavePos (>80 studs)
            if transitionFired or (hrp and leavePos and (hrp.Position - leavePos).Magnitude > 80) then
                if conn then pcall(function() conn:Disconnect() end) end
                task.wait(1.5)
                return true
            end

            -- Re-teleport to door every 5 attempts to fight rubberband/stuck
            if leavePos and (attempt % 5 == 1) then
                tpClassic(leavePos)
                task.wait(0.15)
            end

            -- Ensure character is unanchored for door transition
            pcall(function()
                if hrp then hrp.Anchored = false end
            end)

            -- Continuously trigger Leave prompt until outside
            triggerPrompt(leavePrompt)
            task.wait(0.3)
        end

        if conn then pcall(function() conn:Disconnect() end) end
        return true
    end


    local function sellInventory(npcPrompt)
        if not npcPrompt then return end
        local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local toolsToSell = {}
        for _, child in ipairs(LPLR.Backpack:GetChildren()) do
            if isRobberyLoot(child) then
                table.insert(toolsToSell, child)
            end
        end
        for _, child in ipairs(LPLR.Character:GetChildren()) do
            if isRobberyLoot(child) then
                table.insert(toolsToSell, child)
            end
        end

        if #toolsToSell == 0 then return end

        -- Teleport to Pawn NPC using the improved tpClassic
        local npcPos = getPromptPosition(npcPrompt) or Vector3.new(-1151, 5, 654)
        tpClassic(npcPos)
        task.wait(0.2)

        for _, tool in ipairs(toolsToSell) do
            if tool.Parent == LPLR.Backpack then
                hum:EquipTool(tool)
                task.wait(0.15)
            end

            triggerPrompt(npcPrompt)
            task.wait(0.15)
        end
    end

    local blacklist = {}

    local houseRobToggle
    houseRobToggle = cTg(cRob, "House Robbery Farm", cfg.RobberyAuto or false, function(v)
        houseRobActive = v
        if houseRobThread then
            task.cancel(houseRobThread)
            houseRobThread = nil
        end


        if not v then
            cleanupPlate()
            pcall(function()
                local charFolder = workspace:FindFirstChild("Characters")
                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                    workspace:FindFirstChild(LPLR.Name)
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Anchored = false
                        end
                    end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Sit = false end
                end
            end)
            NOTIFY("House Robbery", "Farm disabled. Character released.", 3)
        end

        if houseRobActive then
            houseRobThread = task.spawn(function()
                pcall(function()
                    local charFolder = workspace:FindFirstChild("Characters")
                    local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                        workspace:FindFirstChild(LPLR.Name)
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Anchored = false end
                end)

                while houseRobActive do
                    local stepSuccess, err = pcall(function()
                        local availableHouse = nil
                        local housesFolder = safeGet(workspace, { "HouseRobberies", "Houses" })
                        if housesFolder then
                            for _, house in ipairs(housesFolder:GetChildren()) do
                                if not blacklist[house.Name] or (tick() - blacklist[house.Name] > 60) then
                                    local robPrompt = findPrompt(house, "RobPrompt")
                                    local enterPrompt = findPrompt(house, "Enter")
                                    if robPrompt and enterPrompt then
                                        if robPrompt.Enabled and not enterPrompt.Enabled then
                                            availableHouse = house
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        if not availableHouse then
                            cleanupPlate()
                            pcall(function()
                                local charFolder = workspace:FindFirstChild("Characters")
                                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                                    workspace:FindFirstChild(LPLR.Name)
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.Anchored = false end
                            end)
                            NOTIFY("House Robbery", "Waiting for available house...", 5)
                            task.wait(5)
                            return
                        end

                        local drill = LPLR.Backpack:FindFirstChild("Drill") or
                            (LPLR.Character and LPLR.Character:FindFirstChild("Drill"))
                        if not drill then
                            NOTIFY("House Robbery", "Drill not found. Purchasing...", 3)
                            local HardwareEvent = game:GetService("ReplicatedStorage").Modules.Packages._Index
                                ["sleitnick_net@0.2.0"].net["RE/Hardware"]
                            if HardwareEvent then
                                HardwareEvent:FireServer("Purchase", { name = "Drill", category = "Tools" })

                                local startWaitDrill = tick()
                                while not drill and (tick() - startWaitDrill < 6) do
                                    drill = LPLR.Backpack:FindFirstChild("Drill") or
                                        (LPLR.Character and LPLR.Character:FindFirstChild("Drill"))
                                    task.wait(0.1)
                                end
                            end
                        end

                        if not drill then
                            NOTIFY("House Robbery", "Error: Failed to obtain Drill!", 4)
                            task.wait(3)
                            return
                        end


                        local enterPrompt = findPrompt(availableHouse, "Enter")
                        local robPrompt = findPrompt(availableHouse, "RobPrompt")
                        if not enterPrompt or not robPrompt then
                            NOTIFY("House Robbery", "Error: House prompts missing!", 4)
                            return
                        end

                        local doorPos = getPromptPosition(enterPrompt) or getPromptPosition(robPrompt)
                        if not doorPos then
                            NOTIFY("House Robbery", "Error: Could not resolve door position!", 4)
                            return
                        end

                        tpClassic(doorPos)
                        task.wait(0.2)


                        local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
                        if drill.Parent == LPLR.Backpack and hum then
                            hum:EquipTool(drill)
                        end
                        task.wait(0.3)


                        local startWaitUnlock = tick()
                        while robPrompt.Enabled and robPrompt.Parent and tick() - startWaitUnlock < 8 do
                            triggerPrompt(robPrompt)
                            task.wait(0.2)
                        end
                        task.wait(0.2)


                        local leavePrompt = nil
                        local startWaitEnter = tick()
                        while tick() - startWaitEnter < 10 do
                            local room = getRoomFolder(availableHouse.Name)
                            leavePrompt = room and findPrompt(room, "Leave")
                            if leavePrompt then break end

                            if enterPrompt.Enabled then
                                triggerPrompt(enterPrompt)
                            end
                            task.wait(0.25)
                        end

                        if not leavePrompt then
                            NOTIFY("House Robbery", "Error: Failed to confirm room entry!", 4)
                            return
                        end

                        pcall(function()
                            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Anchored = false end
                        end)

                        forceUnequipAllTools()
                        task.wait(0.2)


                        local roomFolder = getRoomFolder(availableHouse.Name)
                        if not roomFolder or not roomFolder:FindFirstChild("Robbable") then
                            NOTIFY("House Robbery", "Error: Room folder or Robbable container not found!", 4)
                            return
                        end



                        local heavyItems = { "TV", "TV2", "Fridge", "Microwave" }

                        -- 1. Grab FIRST heavy item (only 1 heavy item allowed in inventory!)
                        local firstHeavyPrompt = nil
                        for _, itemName in ipairs(heavyItems) do
                            local item = roomFolder.Robbable:FindFirstChild(itemName)
                            local grabPrompt = item and findPrompt(item, "Grab")
                            if grabPrompt and grabPrompt.Enabled then
                                firstHeavyPrompt = grabPrompt
                                break
                            end
                        end

                        if firstHeavyPrompt then
                            forceUnequipAllTools()
                            task.wait(0.05)

                            local grabAttempt = 0
                            while firstHeavyPrompt.Enabled and firstHeavyPrompt.Parent and houseRobActive do
                                grabAttempt = grabAttempt + 1

                                local pos = getPromptPosition(firstHeavyPrompt) or
                                    (firstHeavyPrompt.Parent:IsA("BasePart") and firstHeavyPrompt.Parent.Position or firstHeavyPrompt.Parent:GetPivot().Position)

                                if pos and (grabAttempt % 5 == 1) then
                                    tpClassic(pos)
                                    task.wait(0.1)
                                end

                                pcall(function()
                                    local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                    if hrp then hrp.Anchored = false end
                                end)

                                forceUnequipAllTools()
                                triggerPrompt(firstHeavyPrompt)
                                task.wait(0.15)
                            end

                            forceUnequipAllTools()
                            task.wait(0.05)
                        end

                        -- 2. Grab ALL Light (non-heavy) items in the room
                        for _, child in ipairs(roomFolder.Robbable:GetChildren()) do
                            if not houseRobActive then break end
                            if not table.find(heavyItems, child.Name) then
                                local grabPrompt = findPrompt(child, "Grab")
                                if grabPrompt and grabPrompt.Enabled then
                                    forceUnequipAllTools()
                                    task.wait(0.05)

                                    local grabAttempt = 0
                                    while grabPrompt.Enabled and grabPrompt.Parent and houseRobActive do
                                        grabAttempt = grabAttempt + 1

                                        local pos = getPromptPosition(grabPrompt) or
                                            (child:IsA("BasePart") and child.Position or child:GetPivot().Position)

                                        if pos and (grabAttempt % 5 == 1) then
                                            tpClassic(pos)
                                            task.wait(0.1)
                                        end

                                        pcall(function()
                                            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                            if hrp then hrp.Anchored = false end
                                        end)

                                        forceUnequipAllTools()
                                        triggerPrompt(grabPrompt)
                                        task.wait(0.15)
                                    end

                                    forceUnequipAllTools()
                                    task.wait(0.05)
                                end
                            end
                        end

                        -- 3. Scan for remaining heavy items BEFORE exiting
                        local remainingHeavyNames = {}
                        for _, itemName in ipairs(heavyItems) do
                            local item = roomFolder.Robbable:FindFirstChild(itemName)
                            local grabPrompt = item and findPrompt(item, "Grab")
                            if grabPrompt and grabPrompt.Enabled then
                                table.insert(remainingHeavyNames, itemName)
                            end
                        end

                        -- 4. Exit house & Sell first load (1 heavy + all light items)
                        local exitSuccess = exitHouseBeforeSelling(availableHouse)
                        if not exitSuccess then
                            houseRobActive = false
                            if houseRobToggle then houseRobToggle:SET(false, false) end
                            return
                        end

                        -- Sell at Pawn NPC
                        tpClassic(Vector3.new(-1151, 5, 654))
                        pcall(function()
                            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Anchored = false end
                        end)
                        task.wait(0.3)

                        local npc = safeGet(workspace, { "NPC", "Pawn Npc" })
                        local npcPrompt = npc and
                            (findPrompt(npc, "Prompt") or findPrompt(npc, "ProximityPrompt") or npc:FindFirstChildOfClass("ProximityPrompt"))

                        if npcPrompt then
                            local sellAttempts = 0
                            while sellAttempts < 5 and houseRobActive do
                                local hasTools = false
                                for _, child in ipairs(LPLR.Backpack:GetChildren()) do
                                    if isRobberyLoot(child) then
                                        hasTools = true; break
                                    end
                                end
                                if not hasTools then
                                    for _, child in ipairs(LPLR.Character:GetChildren()) do
                                        if isRobberyLoot(child) then
                                            hasTools = true; break
                                        end
                                    end
                                end

                                if not hasTools then break end

                                sellInventory(npcPrompt)
                                sellAttempts = sellAttempts + 1
                                task.wait(0.3)
                            end
                        end

                        -- 5. Return for remaining heavy items (1 at a time!)
                        for _, heavyName in ipairs(remainingHeavyNames) do
                            if not houseRobActive then break end

                            local enterPrompt = findPrompt(availableHouse, "Enter")
                            if enterPrompt then
                                local doorPos = getPromptPosition(enterPrompt)
                                if doorPos then
                                    tpClassic(doorPos); task.wait(0.2)
                                end

                                local startReEnter = tick()
                                while enterPrompt.Enabled and (tick() - startReEnter < 6) and houseRobActive do
                                    triggerPrompt(enterPrompt)
                                    task.wait(0.3)
                                end

                                local room = getRoomFolder(availableHouse.Name)
                                local leavePrompt = room and findPrompt(room, "Leave")
                                if leavePrompt then
                                    pcall(function()
                                        local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then hrp.Anchored = false end
                                    end)

                                    local freshRoom = getRoomFolder(availableHouse.Name)
                                    local item = freshRoom and freshRoom:FindFirstChild("Robbable") and
                                        freshRoom.Robbable:FindFirstChild(heavyName)
                                    local grabPrompt = item and findPrompt(item, "Grab")

                                    if grabPrompt and grabPrompt.Enabled then
                                        forceUnequipAllTools()
                                        task.wait(0.05)

                                        local grabAttempt = 0
                                        while grabPrompt.Enabled and grabPrompt.Parent and houseRobActive do
                                            grabAttempt = grabAttempt + 1

                                            local pos = getPromptPosition(grabPrompt) or
                                                (item:IsA("BasePart") and item.Position or item:GetPivot().Position)

                                            if pos and (grabAttempt % 5 == 1) then
                                                tpClassic(pos)
                                                task.wait(0.1)
                                            end

                                            pcall(function()
                                                local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                                if hrp then hrp.Anchored = false end
                                            end)

                                            forceUnequipAllTools()
                                            triggerPrompt(grabPrompt)
                                            task.wait(0.15)
                                        end
                                        forceUnequipAllTools()
                                        task.wait(0.05)
                                    end

                                    exitHouseBeforeSelling(availableHouse)

                                    tpClassic(Vector3.new(-1151, 5, 654))
                                    pcall(function()
                                        local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then hrp.Anchored = false end
                                    end)
                                    task.wait(0.3)

                                    if npcPrompt then
                                        local sellAttempts = 0
                                        while sellAttempts < 5 and houseRobActive do
                                            local hasTools = false
                                            for _, child in ipairs(LPLR.Backpack:GetChildren()) do
                                                if isRobberyLoot(child) then
                                                    hasTools = true; break
                                                end
                                            end
                                            if not hasTools then
                                                for _, child in ipairs(LPLR.Character:GetChildren()) do
                                                    if isRobberyLoot(child) then
                                                        hasTools = true; break
                                                    end
                                                end
                                            end
                                            if not hasTools then break end

                                            sellInventory(npcPrompt)
                                            sellAttempts = sellAttempts + 1
                                            task.wait(0.3)
                                        end
                                    end
                                end
                            end
                        end

                        NOTIFY("House Robbery", "House fully cleared! Finished robbery.", 5)
                        blacklist[availableHouse.Name] = tick()
                        task.wait(1)
                    end)

                    if not stepSuccess then
                        NOTIFY("House Robbery", "Error in loop: " .. tostring(err), 5)
                    end
                    task.wait(2)
                end
            end)
        end
    end)

    -- =====================================================
    -- CHICKEN FARM
    -- =====================================================
    do
        local chickenActive   = false
        local chickenThread   = nil
        local minigameConn    = nil

        local FASTFOOD_SHIRT  = "rbxassetid://18344742658"
        local JOB_BOARD_POS   = Vector3.new(-905, 5, -1561)
        local CUT_CHICKEN_POS = Vector3.new(-849, 5, -1568)
        local BOX_DEPOSIT_POS = Vector3.new(-857, 5, -1552)
        local WORK_POS        = Vector3.new(-860, 5, -1554)
        local TARGET_STOCK    = 25
        local COOK_WAIT       = 30 -- seconds between cook prompt fires

        local function safeGet(root, path)
            local current = root
            for _, name in ipairs(path) do
                if not current then return nil end
                current = current:FindFirstChild(name)
            end
            return current
        end

        -- helper: get local character
        local function getChar()
            local charFolder = workspace:FindFirstChild("Characters")
            return (charFolder and charFolder:FindFirstChild(LPLR.Name))
                or LPLR.Character
                or workspace:FindFirstChild(LPLR.Name)
        end

        -- helper: check shirt template
        local function getShirt()
            local char = getChar()
            if not char then return nil end
            local shirt = char:FindFirstChildOfClass("Shirt")
            return shirt and shirt.ShirtTemplate
        end

        -- helper: read stock from BillboardGui TextLabel "Stock: X"
        local function readStock()
            local ok, val = pcall(function()
                local jobAssets  = workspace:FindFirstChild("JobAssets")
                local ffFolder   = jobAssets and jobAssets:FindFirstChild("Fastfood Worker")
                local meatHolder = ffFolder and ffFolder:FindFirstChild("MeatHolder")
                local bbGui      = meatHolder and meatHolder:FindFirstChild("BillboardGui")
                local lbl        = bbGui and bbGui:FindFirstChild("TextLabel")
                return lbl and tonumber(lbl.Text:match("Stock:%s*(%d+)"))
            end)
            return ok and val or nil
        end

        -- helper: check if LocalPlayer has Raw Drumstick in Backpack or Character
        local function hasRawDrumstick()
            local inBackpack = LPLR.Backpack:FindFirstChild("Raw Drumstick")
            local char = getChar()
            local inChar = char and char:FindFirstChild("Raw Drumstick")
            return (inBackpack or inChar) ~= nil
        end

        -- helper: auto click minigame
        local function doMinigameClicks()
            local mouse = LPLR:GetMouse()
            local ok, conns = pcall(getconnections, mouse.Button1Down)
            if not ok or not conns or #conns == 0 then
                return
            end

            local tapGame = nil
            pcall(function()
                tapGame = LPLR.PlayerGui.Minigames.Mainframe.TapGame
            end)

            for i = 1, 40 do
                if not chickenActive then break end
                if tapGame and not tapGame.Visible then break end
                for _, conn in ipairs(conns) do
                    pcall(function() conn:Fire() end)
                end
                task.wait(0.05)
            end
        end

        -- Setup minigame listener via Net package & UI Signal
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local FastfoodRE = nil
            pcall(function()
                FastfoodRE = rs.Modules.Packages._Index["sleitnick_net@0.2.0"].net:FindFirstChild("RE/Fastfood")
            end)
            if FastfoodRE and FastfoodRE.OnClientEvent then
                FastfoodRE.OnClientEvent:Connect(function(msg)
                    if msg == "StartMinigame" and chickenActive then
                        task.spawn(doMinigameClicks)
                    end
                end)
            end

            -- Direct UI Signal fallback
            local tapGame = safeGet(LPLR, { "PlayerGui", "Minigames", "Mainframe", "TapGame" })
            if tapGame then
                tapGame:GetPropertyChangedSignal("Visible"):Connect(function()
                    if tapGame.Visible and chickenActive then
                        task.spawn(doMinigameClicks)
                    end
                end)
            end
        end)

        -- helper: get Raw Chicken proximity prompt
        local function getRawChickenPrompt()
            local ffFolder = workspace:FindFirstChild("JobAssets") and
                workspace.JobAssets:FindFirstChild("Fastfood Worker")
            local chicken  = ffFolder and ffFolder:FindFirstChild("Raw Chicken")
            local handle   = chicken and chicken:FindFirstChild("Handle")
            return handle and
                (handle:FindFirstChildOfClass("ProximityPrompt") or handle:FindFirstChild("ProximityPrompt"))
        end

        -- helper: cut chicken process (teleport to cut pos, prompt loop until Raw Drumstick acquired, then deposit)
        local function cutAndDepositChicken()
            -- 1. Teleport to cut position
            tpClassic(CFrame.new(CUT_CHICKEN_POS))
            task.wait(0.3)

            -- 2. Trigger prompt until Raw Drumstick is received
            local startTime = tick()
            while chickenActive and not hasRawDrumstick() and (tick() - startTime < 15) do
                -- Check if minigame GUI is visible right now
                local tapGame = safeGet(LPLR, { "PlayerGui", "Minigames", "Mainframe", "TapGame" })
                if tapGame and tapGame.Visible then
                    task.spawn(doMinigameClicks)
                    task.wait(0.3)
                end

                local prompt = getRawChickenPrompt()
                if prompt and prompt.Enabled then
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        FORCE_HOLD(prompt)
                    end
                end
                task.wait(0.4)
            end

            -- 3. If drumstick acquired, teleport to deposit box and place it
            if hasRawDrumstick() then
                tpClassic(CFrame.new(BOX_DEPOSIT_POS))
                task.wait(0.3)

                pcall(function()
                    local jobAssets  = workspace:FindFirstChild("JobAssets")
                    local ffFolder   = jobAssets and jobAssets:FindFirstChild("Fastfood Worker")
                    local meatHolder = ffFolder and ffFolder:FindFirstChild("MeatHolder")
                    local prompt     = meatHolder and
                        (meatHolder:FindFirstChildOfClass("ProximityPrompt") or meatHolder:FindFirstChild("ProximityPrompt"))
                    if prompt then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            FORCE_HOLD(prompt)
                        end
                    end
                end)
                task.wait(0.5)
            end
        end

        -- helper: fire Cook Prompt 3x rapid (30s rate-limit handled by caller)
        local function fireCook()
            local prompt = nil
            pcall(function()
                local jobAssets = workspace:FindFirstChild("JobAssets")
                local ffFolder  = jobAssets and jobAssets:FindFirstChild("Fastfood Worker")
                local cookPart  = ffFolder and ffFolder:FindFirstChild("Cook Prompt")
                prompt          = cookPart and
                    (cookPart:FindFirstChildOfClass("ProximityPrompt") or cookPart:FindFirstChild("ProximityPrompt"))
            end)
            if not prompt then return end
            for i = 1, 3 do
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        FORCE_HOLD(prompt)
                    end
                end)
                task.wait(0.1)
            end
        end

        local cChick                       = cCd(smF_F.r, "Chicken Farm")

        local statusLabel                  = Instance.new("TextLabel")
        statusLabel.Name                   = "ChickenStatus"
        statusLabel.Size                   = UDim2.new(1, -10, 0, 18)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text                   = "Status: Idle"
        statusLabel.TextColor3             = Color3.fromRGB(150, 150, 150)
        statusLabel.Font                   = Enum.Font.Gotham
        statusLabel.TextSize               = 11
        statusLabel.TextXAlignment         = Enum.TextXAlignment.Left
        local cur_ord                      = cChick:GetAttribute("NextOrder") or 0
        statusLabel.LayoutOrder            = cur_ord
        cChick:SetAttribute("NextOrder", cur_ord + 1)
        safeParent(statusLabel, cChick)

        local function setStatus(txt, col)
            statusLabel.Text       = "Status: " .. txt
            statusLabel.TextColor3 = col or Color3.fromRGB(150, 150, 150)
        end

        cTg(cChick, "Auto Chicken Farm", cfg.ChickenAuto or false, function(v)
            chickenActive = v

            if not v then
                if chickenThread then
                    task.cancel(chickenThread)
                    chickenThread = nil
                end
                setStatus("Idle")
                NOTIFY("Chicken Farm", "Stopped.", 3)
                return
            end

            NOTIFY("Chicken Farm", "Starting...", 3)

            chickenThread = task.spawn(function()
                -- ── STEP 1: apply for job if not already a Fastfood Worker ──
                setStatus("Checking job...", Color3.fromRGB(200, 200, 200))
                if getShirt() ~= FASTFOOD_SHIRT then
                    setStatus("Going to job board...", Color3.fromRGB(200, 200, 200))
                    NOTIFY("Chicken Farm", "Applying for Fastfood job...", 3)

                    -- Move to Job Board (yielding until arrived)
                    local tpPos = JOB_BOARD_POS
                    pcall(function()
                        local boardFolder = workspace:FindFirstChild("JobBoard") and
                            workspace.JobBoard:FindFirstChild("Fastfood Worker")
                        local board = boardFolder and boardFolder:FindFirstChild("Fastfood Worker")
                        if board then
                            local p = board:IsA("BasePart") and board.Position or board:GetPivot().Position
                            tpPos = p + Vector3.new(0, 3, 0)
                        end
                    end)

                    tpClassic(CFrame.new(tpPos))
                    task.wait(0.5)

                    -- Find ProximityPrompt with retry loop
                    local prompt = nil
                    for attempt = 1, 10 do
                        pcall(function()
                            local boardFolder = workspace:FindFirstChild("JobBoard") and
                                workspace.JobBoard:FindFirstChild("Fastfood Worker")
                            local board = boardFolder and boardFolder:FindFirstChild("Fastfood Worker")
                            if board then
                                prompt = board:FindFirstChildOfClass("ProximityPrompt") or
                                    board:FindFirstChild("ProximityPrompt")
                            end
                        end)
                        if prompt then break end
                        task.wait(0.5)
                    end

                    if prompt then
                        if fireproximityprompt then
                            pcall(fireproximityprompt, prompt)
                        else
                            FORCE_HOLD(prompt)
                        end
                        task.wait(2)
                    end

                    if getShirt() ~= FASTFOOD_SHIRT then
                        setStatus("Failed to get job!", Color3.fromRGB(230, 60, 60))
                        NOTIFY("Chicken Farm", "Could not get Fastfood job!", 4)
                        chickenActive = false
                        return
                    end
                    setStatus("Job acquired!", Color3.fromRGB(80, 200, 80))
                    task.wait(0.5)
                else
                    setStatus("Already Fastfood Worker!", Color3.fromRGB(80, 200, 80))
                    task.wait(0.5)
                end

                -- ── STEP 2: teleport to work area ──
                setStatus("Going to work area...", Color3.fromRGB(200, 200, 200))
                tpClassic(CFrame.new(WORK_POS))
                task.wait(0.5)

                -- ── STEP 3: main loop ──
                while chickenActive do
                    local stock = readStock()
                    if stock == nil then
                        setStatus("Can't read stock!", Color3.fromRGB(230, 60, 60))
                        task.wait(2)
                    elseif stock <= 0 then
                        -- Stock is empty (0), fill the box up to 25
                        local needed = TARGET_STOCK
                        setStatus("Filling box: 0 / " .. TARGET_STOCK, Color3.fromRGB(200, 200, 200))
                        for i = 1, needed do
                            if not chickenActive then break end
                            cutAndDepositChicken()
                            local curS = readStock()
                            if curS and curS >= TARGET_STOCK then break end
                            task.wait(0.1)
                        end
                        task.wait(0.3)
                    else
                        -- Stock still has chicken (> 0), continue cooking!
                        tpClassic(CFrame.new(WORK_POS))
                        task.wait(0.3)

                        setStatus("Firing cook prompt...", Color3.fromRGB(255, 165, 0))
                        fireCook()

                        for i = COOK_WAIT, 1, -1 do
                            if not chickenActive then break end
                            local s = readStock()
                            setStatus(
                                "Cook wait " .. i .. "s | Stock: " .. (s or "?"),
                                Color3.fromRGB(255, 165, 0)
                            )
                            task.wait(1)
                        end
                    end

                    task.wait(0.1)
                end -- while chickenActive

                setStatus("Idle")
            end)
        end)
    end -- CHICKEN FARM

    -- =====================================================
    -- RAP FARM (Auto Rapper)
    -- =====================================================
    do
        local cRap = cCd(smF_F.r, "Rap Farm")

        local rapNote = Instance.new("TextLabel")
        rapNote.Size = UDim2.new(1, -10, 0, 0)
        rapNote.AutomaticSize = Enum.AutomaticSize.Y
        rapNote.BackgroundTransparency = 1
        rapNote.Text =
        "📋 INSTRUCTIONS:\n1. Enable this toggle first.\n2. Go to the Studio location.\n3. Start a recording session.\n4. Select a beat (Killa or T-House).\n5. The script will automatically hit every beat with Perfect timing!"
        rapNote.TextColor3 = Color3.fromRGB(170, 170, 190)
        rapNote.Font = Enum.Font.Gotham
        rapNote.TextSize = 11
        rapNote.TextXAlignment = Enum.TextXAlignment.Left
        rapNote.TextYAlignment = Enum.TextYAlignment.Top
        rapNote.TextWrapped = true
        safeParent(rapNote, cRap)

        getgenv().FARM_STATE.rapActive = false
        local rapConn = nil
        local nodeData = {}
        local childAddedConn = nil
        local childRemovedConn = nil

        local KEYS = {
            [1] = Enum.KeyCode.H,
            [2] = Enum.KeyCode.J,
            [3] = Enum.KeyCode.K,
            [4] = Enum.KeyCode.L,
        }

        local function pressKey(idx)
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, KEYS[idx], false, game)
                vim:SendKeyEvent(false, KEYS[idx], false, game)
            end)
        end

        local function getIntersection(node, target)
            local nPos  = node.AbsolutePosition
            local nSize = node.AbsoluteSize
            local tPos  = target.AbsolutePosition
            local tSize = target.AbsoluteSize

            local ix    = math.max(0, math.min(nPos.X + nSize.X, tPos.X + tSize.X) - math.max(nPos.X, tPos.X))
            local iy    = math.max(0, math.min(nPos.Y + nSize.Y, tPos.Y + tSize.Y) - math.max(nPos.Y, tPos.Y))

            return math.min(ix, iy)
        end

        local function getRating(intersect)
            if intersect > 40 then
                return "Perfect"
            elseif intersect > 15 then
                return "Okay"
            elseif intersect > 5 then
                return "Bad"
            else
                return "Miss"
            end
        end

        local function startAutoRap()
            if rapConn then rapConn:Disconnect() end
            nodeData = {}

            local CS = game:GetService("CollectionService")

            rapConn = RS.Heartbeat:Connect(function()
                if not getgenv().FARM_STATE.rapActive then return end
                local ui = LPLR.PlayerGui:FindFirstChild("RapUI")
                if not ui then return end
                local Game = ui:FindFirstChild("MainFrame") and ui.MainFrame:FindFirstChild("Game")
                if not Game or not Game.Visible then return end
                local BG     = Game:FindFirstChild("BG")
                local Holder = BG and BG:FindFirstChild("Holder")
                if not BG or not Holder then return end

                for _, node in ipairs(BG:GetChildren()) do
                    if node:IsA("ImageLabel") and node.Visible then
                        local okT, tags = pcall(CS.GetTags, CS, node)
                        if okT and tags then
                            local idx = nil
                            for _, tag in ipairs(tags) do
                                local n = tag:match("Node (%d+)")
                                if n then
                                    idx = tonumber(n)
                                    break
                                end
                            end

                            if idx then
                                local id   = tostring(node)
                                local curY = node.AbsolutePosition.Y

                                if not nodeData[id] then
                                    nodeData[id] = { pressed = false, lastY = curY, prevIntersect = 0 }
                                end

                                local data = nodeData[id]

                                if curY < data.lastY - 100 then
                                    data.pressed       = false
                                    data.prevIntersect = 0
                                end
                                data.lastY = curY

                                if not data.pressed then
                                    local target = Holder:FindFirstChild(tostring(idx))
                                    if target then
                                        local dist = (node.AbsolutePosition - target.AbsolutePosition).Magnitude
                                        if dist <= 70 then
                                            local intersect = getIntersection(node, target)
                                            local rating    = getRating(intersect)

                                            local peaked    = intersect < data.prevIntersect and
                                                data.prevIntersect > 15

                                            if rating == "Perfect" or peaked then
                                                data.pressed = true
                                                pressKey(idx)
                                            end

                                            data.prevIntersect = intersect
                                        else
                                            data.prevIntersect = 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        local function stopAutoRap()
            if rapConn then
                rapConn:Disconnect()
                rapConn = nil
            end
            nodeData = {}
        end

        cTg(cRap, "Auto Rapper (Rap Farm)", cfg.RapAuto or false, function(v)
            getgenv().FARM_STATE.rapActive = v
            if v then
                NOTIFY("Rap Farm", "Rap Farm enabled. Waiting for studio record (RapUI)...", 5)

                if childAddedConn then childAddedConn:Disconnect() end
                if childRemovedConn then childRemovedConn:Disconnect() end

                childAddedConn = LPLR.PlayerGui.ChildAdded:Connect(function(child)
                    if child.Name == "RapUI" and getgenv().FARM_STATE.rapActive then
                        NOTIFY("Rap Farm", "Rap minigame detected! Auto Rapper active.", 4)
                        task.wait(1)
                        startAutoRap()
                    end
                end)

                childRemovedConn = LPLR.PlayerGui.ChildRemoved:Connect(function(child)
                    if child.Name == "RapUI" then
                        NOTIFY("Rap Farm", "Rap minigame ended.", 3)
                        stopAutoRap()
                    end
                end)

                if LPLR.PlayerGui:FindFirstChild("RapUI") then
                    NOTIFY("Rap Farm", "Rap minigame detected! Auto Rapper active.", 4)
                    startAutoRap()
                end
            else
                stopAutoRap()
                if childAddedConn then
                    childAddedConn:Disconnect()
                    childAddedConn = nil
                end
                if childRemovedConn then
                    childRemovedConn:Disconnect()
                    childRemovedConn = nil
                end
                NOTIFY("Rap Farm", "Rap Farm disabled.", 3)
            end
        end)
    end



    getgenv().FARM_STATE.jailActive = false
    getgenv().FARM_STATE.jailThread = nil
    local cJail = cCd(smF_J.l, "Jail Clean Farm")

    local function getPrisonModel()
        return safeGet(workspace, { "Map", "Prison", "Intertior", "Structure", "Model" }) or
            safeGet(workspace, { "Map", "Prison", "Interior", "Structure", "Model" })
    end

    local function isNearPrison()
        local charFolder = workspace:FindFirstChild("Characters")
        local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local tablesFolder = safeGet(workspace, { "Map", "Prison", "Intertior", "Tables", "Tables" }) or
            safeGet(workspace, { "Map", "Prison", "Interior", "Tables", "Tables" })
        if tablesFolder then
            for _, child in ipairs(tablesFolder:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    local pos = child:IsA("BasePart") and child.Position or child:GetPivot().Position
                    if (hrp.Position - pos).Magnitude < 1500 then
                        return true
                    end
                end
            end
            if tablesFolder:IsA("Model") or tablesFolder:IsA("BasePart") then
                local pos = tablesFolder:IsA("BasePart") and tablesFolder.Position or
                    tablesFolder:GetPivot().Position
                if (hrp.Position - pos).Magnitude < 1500 then
                    return true
                end
            end
        end

        local prison = getPrisonModel()
        if prison then
            if (hrp.Position - prison:GetPivot().Position).Magnitude < 1500 then
                return true
            end
        end

        local folder = safeGet(workspace, { "CleanWork", "PrisonPuddles" })
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                local pos = child:IsA("BasePart") and child.Position or
                    (child:IsA("Model") and child:GetPivot().Position)
                if pos and (hrp.Position - pos).Magnitude < 1500 then
                    return true
                end
            end
        end

        return false
    end

    local function getAvailablePuddles()
        local folder = safeGet(workspace, { "CleanWork", "PrisonPuddles" })
        if not folder then return {} end

        local puddles = {}
        for _, child in ipairs(folder:GetChildren()) do
            local prompt = child:FindFirstChild("Clean") or child:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                table.insert(puddles, { model = child, prompt = prompt })
            end
        end
        return puddles
    end

    local jailToggle
    jailToggle = cTg(cJail, "Auto Clean Puddles", cfg.JailAuto or false, function(v)
        if v then
            if not isNearPrison() then
                NOTIFY("Jail Farm", "You must be inside the Prison to enable this farm!", 4)
                jailToggle:SET(false, true)
                return false
            end

            getgenv().FARM_STATE.jailActive = true
            getgenv().FARM_STATE.jailThread = task.spawn(function()
                while getgenv().FARM_STATE.jailActive do
                    local stepSuccess, err = pcall(function()
                        if not isNearPrison() then
                            NOTIFY("Jail Farm", "Error: You are not inside the Prison!", 4)
                            getgenv().FARM_STATE.jailActive = false
                            jailToggle:SET(false, true)
                            pcall(function()
                                local charFolder = workspace:FindFirstChild("Characters")
                                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                                    workspace:FindFirstChild(LPLR.Name)
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.Anchored = false end
                            end)
                            return
                        end

                        local puddles = getAvailablePuddles()
                        if #puddles == 0 then
                            NOTIFY("Jail Farm", "No puddles to clean. Waiting...", 4)
                            task.wait(3)
                            return
                        end

                        local charFolder = workspace:FindFirstChild("Characters")
                        local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                            workspace:FindFirstChild(LPLR.Name)
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then
                            task.wait(1)
                            return
                        end

                        local closestPuddle = nil
                        local minDist = 99999
                        for _, puddle in ipairs(puddles) do
                            local pos = getPromptPosition(puddle.prompt)
                            if pos then
                                local dist = (hrp.Position - pos).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    closestPuddle = puddle
                                end
                            end
                        end

                        if closestPuddle then
                            local targetPos = getPromptPosition(closestPuddle.prompt)
                            if targetPos then
                                NOTIFY("Jail Farm", "Cleaning puddle...", 2)
                                tpClassic(targetPos)
                                task.wait(0.2)
                                triggerPrompt(closestPuddle.prompt)

                                -- Wait 10 seconds for the clean animation to finish
                                local startWait = tick()
                                while tick() - startWait < 10 and getgenv().FARM_STATE.jailActive do
                                    task.wait(0.1)
                                end
                            end
                        end
                    end)

                    if not stepSuccess then
                        task.wait(2)
                    end
                    task.wait(0.5)
                end
            end)
        else
            getgenv().FARM_STATE.jailActive = false
            if getgenv().FARM_STATE.jailThread then
                task.cancel(getgenv().FARM_STATE.jailThread)
                getgenv().FARM_STATE.jailThread = nil
            end
            pcall(function()
                local charFolder = workspace:FindFirstChild("Characters")
                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                    workspace:FindFirstChild(LPLR.Name)
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end)
        end
    end)
end


task.spawn(SETUP_FARMS)


-- =====================================================
-- SILENT AIM & COMBAT ENGINE
-- =====================================================
local TARGET_PARTS_LIST = { "Head", "Torso", "HumanoidRootPart" }

getgenv().SilentAim_Enabled = cfg.SilentAim_Enabled
getgenv().SilentAim_Wallbang = cfg.SilentAim_Wallbang
getgenv().SilentAim_ShowFOV = cfg.SilentAim_ShowFOV
getgenv().SilentAim_FOVRadius = cfg.SilentAim_FOVRadius
getgenv().SilentAim_FOVColor = HxC(cfg.SilentAim_FOVColor)
getgenv().SilentAim_TargetPart = TARGET_PARTS_LIST[cfg.SilentAim_TargetPart] or "Head"

local fovCircle = nil
local fovRenderConn = nil

local function getTargetScreenPosition()
    local cam = workspace.CurrentCamera
    if uis.TouchEnabled and cam then
        return cam.ViewportSize / 2
    end
    return uis:GetMouseLocation()
end

pcall(function()
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Visible = false
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 64
        fovCircle.Radius = getgenv().SilentAim_FOVRadius or 150
        fovCircle.Filled = false
        fovCircle.Color = getgenv().SilentAim_FOVColor or Color3.fromRGB(255, 255, 255)

        fovRenderConn = game:GetService("RunService").RenderStepped:Connect(function()
            if fovCircle then
                if getgenv().SilentAim_ShowFOV and getgenv().SilentAim_Enabled then
                    fovCircle.Position = getTargetScreenPosition()
                    fovCircle.Radius = getgenv().SilentAim_FOVRadius or 150
                    fovCircle.Color = getgenv().SilentAim_FOVColor or Color3.fromRGB(255, 255, 255)
                    fovCircle.Visible = true
                else
                    fovCircle.Visible = false
                end
            end
        end)
    end
end)

getgenv().SILENT_AIM_CLEANUP = function()
    getgenv().SilentAim_Enabled = false
    if fovRenderConn then
        fovRenderConn:Disconnect(); fovRenderConn = nil
    end
    if fovCircle then
        pcall(function() fovCircle:Remove() end); fovCircle = nil
    end
end

local function isPartVisible(part, targetCharacter, origin)
    local cam = workspace.CurrentCamera
    local startPos = origin or (cam and cam.CFrame.Position)
    if not startPos or not part then return false end

    local destination = part.Position
    local direction = destination - startPos

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local charFolder = workspace:FindFirstChild("Characters")
    local myChar = charFolder and charFolder:FindFirstChild(lp.Name) or lp.Character or
        workspace:FindFirstChild(lp.Name)

    local filterList = {}
    if myChar then table.insert(filterList, myChar) end
    if targetCharacter then table.insert(filterList, targetCharacter) end

    local debris = workspace:FindFirstChild("Debris")
    if debris then table.insert(filterList, debris) end

    local safezones = workspace:FindFirstChild("Safezones")
    if safezones then table.insert(filterList, safezones) end

    local camZones = workspace:FindFirstChild("CameraZones")
    if camZones then table.insert(filterList, camZones) end

    params.FilterDescendantsInstances = filterList
    params.IgnoreWater = true

    local result = workspace:Raycast(startPos, direction, params)
    if result then
        local hit = result.Instance
        if hit.CanCollide then
            local isPlayerPart = hit:FindFirstAncestorOfClass("Model") and
                hit:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")
            local isCharFolderPart = hit:IsDescendantOf(charFolder or workspace) and
                (hit.Parent:FindFirstChildOfClass("Humanoid") or (hit.Parent.Parent and hit.Parent.Parent:FindFirstChildOfClass("Humanoid")))

            if not isPlayerPart and not isCharFolderPart then
                return false
            end
        end
    end
    return true
end

local function getClosestPlayerToMouse(fovRadius, targetPartName, originOverride)
    local closestPlayer = nil
    local closestPart = nil
    local minDist = fovRadius or 99999

    local mousePos = getTargetScreenPosition()
    local cam = workspace.CurrentCamera

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = nil
            if targetPartName == "Torso" then
                part = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
            else
                part = player.Character:FindFirstChild(targetPartName)
            end

            if part then
                local isAllowed = true
                if not getgenv().SilentAim_Wallbang then
                    isAllowed = isPartVisible(part, player.Character, originOverride or (cam and cam.CFrame.Position))
                end

                if isAllowed then
                    local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestPlayer = player
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPlayer, closestPart
end

getgenv().EXE.CastRayHandler = function(self, oldCastRay, origin, targetPosition, ...)
    if getgenv().SilentAim_Enabled then
        local targetPlayer, targetPart = getClosestPlayerToMouse(getgenv().SilentAim_FOVRadius,
            getgenv().SilentAim_TargetPart, origin)
        if targetPlayer and targetPart then
            local distance = (origin - targetPart.Position).Magnitude
            local mockResult = {
                Position = targetPart.Position,
                Instance = targetPart,
                Normal = Vector3.new(0, 1, 0),
                Material = Enum.Material.SmoothPlastic
            }
            return targetPart.Position, targetPart, distance, mockResult
        end
    end
    return oldCastRay(self, origin, targetPosition, ...)
end

getgenv().EXE.ImpulseXHandler = function(springSelf, oldImpulseX, ...)
    if getgenv().EXE.GUN_MODS and getgenv().EXE.GUN_MODS.NoRecoil then
        return
    end
    return oldImpulseX(springSelf, ...)
end

getgenv().EXE.ImpulseZHandler = function(springSelf, oldImpulseZ, ...)
    if getgenv().EXE.GUN_MODS and getgenv().EXE.GUN_MODS.NoRecoil then
        return
    end
    return oldImpulseZ(springSelf, ...)
end

getgenv().EXE.FireHandler = function(self, oldFire, ...)
    if self.Setting then
        if not self.Setting.OriginalRPM then
            self.Setting.OriginalOriginalRPM = self.Setting.RPM
            self.Setting.OriginalAutomatic = self.Setting.OriginalAutomatic
            self.Setting.OriginalEquipTime = self.Setting.OriginalEquipTime or self.Setting.EquipTime
            self.Setting.OriginalCameraRecoil = self.Setting.OriginalCameraRecoil or self.Setting.CameraRecoil
        end

        if getgenv().EXE.GUN_MODS and getgenv().EXE.GUN_MODS.NoRecoil then
            self.Setting.CameraRecoil = 0
        else
            self.Setting.CameraRecoil = self.Setting.OriginalCameraRecoil
        end

        if getgenv().EXE.GUN_MODS and getgenv().EXE.GUN_MODS.RapidFire then
            self.Setting.RPM = 1200
            self.Setting.Automatic = true
        else
            self.Setting.RPM = self.Setting.OriginalOriginalRPM or self.Setting.RPM
            self.Setting.Automatic = self.Setting.OriginalAutomatic
        end
    end

    if getgenv().EXE.GUN_MODS and getgenv().EXE.GUN_MODS.AutoReload and self.Gun then
        pcall(function()
            local currentAmmo = self.Gun:GetAttribute("Ammo")
            local threshold = getgenv().EXE.GUN_MODS.ReloadThreshold or 5
            if currentAmmo and currentAmmo <= threshold then
                local reloadEvent = game:GetService("ReplicatedStorage").Modules.Packages["_Index"]
                    ["sleitnick_net@0.2.0"].net:FindFirstChild("RE/Reload")
                if reloadEvent then
                    reloadEvent:FireServer()
                end
            end
        end)
    end

    return oldFire(self, ...)
end

getgenv().EXE.ReloadHandler = function(self, oldReload, ...)
    if self.Animations and getgenv().EXE.GUN_MODS and getgenv().EXE.GUN_MODS.AutoReload then
        task.spawn(function()
            local startReload = tick()
            while self.Gun and self.Gun:GetAttribute("IsReloading") and tick() - startReload < 5 do
                pcall(function()
                    local track = self.Animations.Reload or self.OneHandedAnimations.Reload
                    if track and track.IsPlaying then
                        track:AdjustSpeed(100)
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
    return oldReload(self, ...)
end

task.spawn(function()
    while task.wait(2) do
        local success, GunClass = pcall(function()
            return require(game:GetService("ReplicatedStorage").Modules.Utils.GunClass)
        end)
        if success and GunClass then
            if not GunClass.HotReloadable then
                GunClass.HotReloadable = true

                local oldCastRay = GunClass.CastRay
                GunClass.CastRay = function(self, origin, targetPosition, ...)
                    return getgenv().EXE.CastRayHandler(self, oldCastRay, origin, targetPosition, ...)
                end

                local oldFire = GunClass.Fire
                GunClass.Fire = function(self, ...)
                    return getgenv().EXE.FireHandler(self, oldFire, ...)
                end

                local oldReload = GunClass.Reload
                GunClass.Reload = function(self, ...)
                    return getgenv().EXE.ReloadHandler(self, oldReload, ...)
                end

                pcall(function()
                    if GunClass.RecoilSpringX and GunClass.RecoilSpringX.Impulse then
                        local oldImpulseX = GunClass.RecoilSpringX.Impulse
                        GunClass.RecoilSpringX.Impulse = function(springSelf, ...)
                            return getgenv().EXE.ImpulseXHandler(springSelf, oldImpulseX, ...)
                        end
                    end
                    if GunClass.RecoilSpringZ and GunClass.RecoilSpringZ.Impulse then
                        local oldImpulseZ = GunClass.RecoilSpringZ.Impulse
                        GunClass.RecoilSpringZ.Impulse = function(springSelf, ...)
                            return getgenv().EXE.ImpulseZHandler(springSelf, oldImpulseZ, ...)
                        end
                    end
                end)
            end
            break
        end
    end
end)

-- Silent Aim Card
local cSA = cCd(smSA.l, "Silent Aim")
cTg(cSA, "Enable Silent Aim", cfg.SilentAim_Enabled, function(v)
    cfg.SilentAim_Enabled = v
    getgenv().SilentAim_Enabled = v
    saveCfg()
end)

cTg(cSA, "Silent Aim Wallbang", cfg.SilentAim_Wallbang, function(v)
    cfg.SilentAim_Wallbang = v
    getgenv().SilentAim_Wallbang = v
    saveCfg()
end)

cTg(cSA, "Show FOV Circle", cfg.SilentAim_ShowFOV, function(v)
    cfg.SilentAim_ShowFOV = v
    getgenv().SilentAim_ShowFOV = v
    saveCfg()
end, HxC(cfg.SilentAim_FOVColor), function(c)
    cfg.SilentAim_FOVColor = CxH(c)
    getgenv().SilentAim_FOVColor = c
    saveCfg()
end)

cSl(cSA, "FOV Radius", 30, 500, cfg.SilentAim_FOVRadius, function(v)
    cfg.SilentAim_FOVRadius = v
    getgenv().SilentAim_FOVRadius = v
    saveCfg()
end)

cDd(cSA, "Target Part", TARGET_PARTS_LIST, cfg.SilentAim_TargetPart, function(v)
    cfg.SilentAim_TargetPart = v
    getgenv().SilentAim_TargetPart = TARGET_PARTS_LIST[v] or "Head"
    saveCfg()
end)


local c1 = cCd(smV.l, "Player Visuals")
cTg(c1, "Enabled", cfg.Vis_Enabled, function(v)
    cfg.Vis_Enabled = v; saveCfg()
end)
cTg(c1, "Names", cfg.Vis_Names, function(v)
    cfg.Vis_Names = v; saveCfg()
end, HxC(cfg.Vis_NamesColor), function(c)
    cfg.Vis_NamesColor = CxH(c); saveCfg()
end)
cTg(c1, "Health Bars", cfg.Vis_HealthBars, function(v)
    cfg.Vis_HealthBars = v; saveCfg()
end, HxC(cfg.Vis_HealthColor), function(c)
    cfg.Vis_HealthColor = CxH(c); saveCfg()
end)
cTg(c1, "Health Text", cfg.Vis_HealthText, function(v)
    cfg.Vis_HealthText = v; saveCfg()
end, HxC(cfg.Vis_HealthTextColor), function(c)
    cfg.Vis_HealthTextColor = CxH(c); saveCfg()
end)
cTg(c1, "Weapons", cfg.Vis_Weapons, function(v)
    cfg.Vis_Weapons = v; saveCfg()
end, HxC(cfg.Vis_WeaponsColor), function(c)
    cfg.Vis_WeaponsColor = CxH(c); saveCfg()
end)
cTg(c1, "Distance", cfg.Vis_Distance, function(v)
    cfg.Vis_Distance = v; saveCfg()
end, HxC(cfg.Vis_DistanceColor), function(c)
    cfg.Vis_DistanceColor = CxH(c); saveCfg()
end)
cTg(c1, "Chams", cfg.Vis_Chams, function(v)
    cfg.Vis_Chams = v; saveCfg()
end, HxC(cfg.Vis_ChamsColor), function(c)
    cfg.Vis_ChamsColor = CxH(c); saveCfg()
end)
cTg(c1, "Tool Charms", cfg.Vis_ToolCharms, function(v)
    cfg.Vis_ToolCharms = v; saveCfg()
end, HxC(cfg.Vis_ToolCharmsColor), function(c)
    cfg.Vis_ToolCharmsColor = CxH(c); saveCfg()
end)
cTg(c1, "Snaplines", cfg.Vis_Snaplines, function(v)
    cfg.Vis_Snaplines = v; saveCfg()
end, HxC(cfg.Vis_SnaplinesColor), function(c)
    cfg.Vis_SnaplinesColor = CxH(c); saveCfg()
end)
cTg(c1, "Off-Screen Lines", cfg.Vis_OffScreen, function(v)
    cfg.Vis_OffScreen = v; saveCfg()
end)
cTg(c1, "Skeleton", cfg.Vis_Skeleton, function(v)
    cfg.Vis_Skeleton = v; saveCfg()
end, HxC(cfg.Vis_SkeletonColor), function(c)
    cfg.Vis_SkeletonColor = CxH(c); saveCfg()
end)

local c2 = cCd(smV.r, "Player Visual Settings")
cDd(c2, "Text Font", { "Gotham", "GothamBold", "SourceSans", "SourceSansBold", "Code", "Roboto" }, cfg.Vis_TextFont,
    function(v)
        cfg.Vis_TextFont = v; saveCfg()
    end)
cSl(c2, "Text Size", 8, 24, cfg.Vis_TextSize, function(v)
    cfg.Vis_TextSize = v; saveCfg()
end)
cSl(c2, "Max Render Distance", 50, 2000, cfg.Vis_MaxDist, function(v)
    cfg.Vis_MaxDist = v; saveCfg()
end)

local c3 = cCd(smV.r, "Optimizer")
cBtn(c3, "Activate FPS Booster", function(btn)
    btn.Text = "FPS Booster Deployed!"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)

    local function checkFence(inst)
        local cur = inst
        while cur and cur ~= workspace do
            if cur.Name:lower():find("fence") or cur.Name:lower():find("fencing") then return true end
            cur = cur.Parent
        end
        return false
    end

    local SettingsEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
    SettingsEvent = SettingsEvent and SettingsEvent:FindFirstChild("Settings")
    if SettingsEvent then
        SettingsEvent:FireServer("SunRays")
        SettingsEvent:FireServer("Shadows")
        SettingsEvent:FireServer("WeatherEffects")
    end

    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").OutdoorAmbient = Color3.new(1, 1, 1)
    game:GetService("Lighting").GlobalShadows = false

    for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = false
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if checkFence(obj) then
            if obj:IsA("BasePart") then
                if obj.Transparency > 0 then obj.Transparency = 0 end
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
            end
        else
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    end
end)

cDd(c5, "UI Color", { "Default", "Blue", "Yellow", "Green", "Soft Coffee" }, cfg.UIColor, function(v)
    cfg.UIColor = v
    saveCfg()
    uThm(v, nil)
end)
cDd(c5, "UI Font", { "Default", "Arcade", "SciFi", "Code" }, cfg.UIFont, function(v)
    cfg.UIFont = v
    saveCfg()
    uThm(nil, uiFonts[v])
end)

local c6 = cCd(smU.r, "Custom hide bind")
local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

if isMobile then
    cTg(c6, "Mobile Hide Button", cfg.MobileHideBtn, function(v)
        cfg.MobileHideBtn = v
        saveCfg()
        if getgenv().MOB_HIDE_BTN then
            getgenv().MOB_HIDE_BTN.Visible = v
        end
    end)

    if not getgenv().MOB_HIDE_BTN then
        local mGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
        mGui.Name = "MOB_HIDE_GUI"
        mGui.DisplayOrder = 2147483647
        mGui.ResetOnSpawn = false

        local mBtn = Instance.new("ImageButton", mGui)
        mBtn.Size = UDim2.new(0, 45, 0, 45)
        mBtn.Position = UDim2.new(0.5, 0, 0, 20)
        mBtn.AnchorPoint = Vector2.new(0.5, 0)
        mBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mBtn.Image = "rbxassetid://71320419470561"
        Instance.new("UICorner", mBtn).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", mBtn).Color = Color3.fromRGB(200, 200, 200)

        getgenv().MOB_HIDE_BTN = mBtn

        local drag = false
        mBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true
            end
        end)
        uis.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
                mBtn.Position = UDim2.new(0, i.Position.X, 0, i.Position.Y)
            end
        end)
        uis.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = false
            end
        end)

        mBtn.MouseButton1Click:Connect(function()
            gui.Enabled = not gui.Enabled
        end)
    end
    getgenv().MOB_HIDE_BTN.Visible = cfg.MobileHideBtn
else
    cKb(c6, "Hide UI Key", cfg.HideUIKey, function(k)
        cfg.HideUIKey = k.Name
        saveCfg()
    end)

    local kbConn = uis.InputBegan:Connect(function(i, p)
        if not p and i.KeyCode.Name == cfg.HideUIKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    -- Cleanup hook specific for keybind
    local oldC = getgenv().WALLSCRIPTS_CLEANUP
    getgenv().WALLSCRIPTS_CLEANUP = function()
        if kbConn then kbConn:Disconnect() end
        if oldC then oldC() end
    end
end

local tUi = cfg.TransparentUI
local eBg = cfg.EnableBackground
local uTr = cfg.UITransparency
local bOp = cfg.BackgroundOpacity

local function uBg()
    bI.Visible = eBg
    bI.ImageTransparency = 1 - (bOp / 100)

    local tr = tUi and (uTr / 100) or 0
    mn.BackgroundTransparency = tr

    local cTr = tUi and (uTr / 100) or (eBg and 0.45 or 0)
    sb.BackgroundTransparency = cTr
    for _, c in ipairs(cds) do
        c.BackgroundTransparency = cTr
    end
end

uBg()

cTg(c4, "Transparent UI", tUi, function(v)
    tUi = v; cfg.TransparentUI = v; saveCfg(); uBg()
end)
cTg(c4, "Enable Background", eBg, function(v)
    eBg = v; cfg.EnableBackground = v; saveCfg(); uBg()
end)

local pI = cIm(c4, cfg.BgImageId)

cTb(c4, "Roblox ID...", cfg.BgImageId, function(t, tb)
    local id = t:match("%d+")
    if id then
        local asset = "rbxassetid://" .. id
        task.spawn(function()
            local loaded = false
            pcall(function()
                game:GetService("ContentProvider"):PreloadAsync({ asset }, function(cId, status)
                    if status == Enum.AssetFetchStatus.Success then
                        loaded = true
                    end
                end)
            end)
            if loaded then
                cfg.BgImageId = id
                saveCfg()
                pI.Image = asset
                if bI then bI.Image = asset end
                tb.Text = id
            else
                tb.Text = cfg.BgImageId
            end
        end)
    else
        tb.Text = cfg.BgImageId
    end
end)

cSl(c4, "UI Transparency", 0, 100, uTr, function(v)
    uTr = v; cfg.UITransparency = v; saveCfg(); uBg()
end)
cSl(c4, "Background Opacity", 0, 100, bOp, function(v)
    bOp = v; cfg.BackgroundOpacity = v; saveCfg(); uBg()
end)

tS.bt.BackgroundTransparency = 0
tS.ind.BackgroundTransparency = 0
tS.ic.ImageColor3 = cY
tS.lb.TextColor3 = cY
tS.pge.Visible = true
st.aT = tS

if cfg.UIColor ~= 1 then uThm(cfg.UIColor, nil) end
if cfg.UIFont ~= 1 then uThm(nil, uiFonts[cfg.UIFont]) end

-- ESP SYSTEM
if not getgenv().ESP_SYS then
    getgenv().ESP_SYS = {
        Players = game:GetService('Players'),
        RunService = game:GetService('RunService'),
        Camera = workspace.CurrentCamera,
        Cache = {},
        Lines = Instance.new('ScreenGui', game:GetService('CoreGui'))
    }
    getgenv().ESP_SYS.Lines.Name = 'ESP_LINES'
    getgenv().ESP_SYS.Lines.DisplayOrder = 1000
    getgenv().ESP_SYS.Lines.IgnoreGuiInset = true
end
local E = getgenv().ESP_SYS
E.Camera = workspace.CurrentCamera

local function getESP(p)
    if E.Cache[p] then return E.Cache[p] end
    local o = {
        bg = Instance.new('BillboardGui'),
        nm = Instance.new('TextLabel'),
        dst = Instance.new('TextLabel'),
        wp = Instance.new('TextLabel'),
        hpT = Instance.new('TextLabel'),
        hpB = Instance.new('Frame'),
        hpF = Instance.new('Frame'),
        hl = Instance.new('Highlight'),
        sl = Instance.new('Frame', E.Lines)
    }

    o.bg.Name = 'E_BG'
    o.bg.AlwaysOnTop = true
    o.bg.Size = UDim2.new(4, 0, 5.5, 0)
    o.bg.StudsOffset = Vector3.new(0, 0, 0)

    local function mkT(nm, p, s)
        local t = Instance.new('TextLabel', o.bg)
        t.Name = nm
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, 0, 0, 15)
        t.Position = p
        t.Font = Enum.Font.GothamBold
        t.TextSize = s
        t.TextColor3 = Color3.new(1, 1, 1)
        t.TextStrokeTransparency = 0
        t.TextStrokeColor3 = Color3.new(0, 0, 0)
        return t
    end

    o.nm = mkT('Name', UDim2.new(0, 0, -0.15, 0), 12)
    o.dst = mkT('Dist', UDim2.new(0, 0, 1.05, 0), 10)
    o.wp = mkT('Weap', UDim2.new(0, 0, 1.15, 0), 10)

    o.hpB.Parent = o.bg
    o.hpB.BackgroundColor3 = Color3.new(0, 0, 0)
    o.hpB.BorderSizePixel = 0
    o.hpB.Size = UDim2.new(0, 3, 1, 0)
    o.hpB.Position = UDim2.new(-0.05, -3, 0, 0)

    o.hpF.Parent = o.hpB
    o.hpF.BackgroundColor3 = Color3.new(0, 1, 0)
    o.hpF.BorderSizePixel = 0
    o.hpF.Size = UDim2.new(1, 0, 1, 0)
    o.hpF.Position = UDim2.new(0, 0, 0, 0)
    o.hpF.AnchorPoint = Vector2.new(0, 1)

    o.hpT = mkT('HpT', UDim2.new(0, 0, 0, 0), 10)
    o.hpT.Parent = o.hpB
    o.hpT.Position = UDim2.new(1, 2, 0, 0)
    o.hpT.TextXAlignment = Enum.TextXAlignment.Left

    o.hl.FillTransparency = 0.5
    o.hl.OutlineTransparency = 0

    o.sl.BorderSizePixel = 0
    o.sl.AnchorPoint = Vector2.new(0.5, 0.5)

    E.Cache[p] = o
    return o
end

local function clrESP()
    for p, o in pairs(E.Cache) do
        o.bg.Parent = nil
        o.hl.Parent = nil
        o.sl.Visible = false
    end
end

if E.Conn then E.Conn:Disconnect() end
E.Conn = E.RunService.RenderStepped:Connect(function()
    if not cfg.Vis_Enabled then
        clrESP()
        return
    end

    local lp = E.Players.LocalPlayer
    local charL = lp and lp.Character
    local rootL = charL and charL:FindFirstChild('HumanoidRootPart')

    for _, p in ipairs(E.Players:GetPlayers()) do
        if p ~= lp then
            local char = p.Character
            local root = char and char:FindFirstChild('HumanoidRootPart')
            local hum = char and char:FindFirstChild('Humanoid')
            local o = getESP(p)

            if char and root and hum and hum.Health > 0 then
                local dist = rootL and (root.Position - rootL.Position).Magnitude or 0
                if dist <= cfg.Vis_MaxDist then
                    o.bg.Parent = root
                    o.bg.Adornee = root

                    if cfg.Vis_Names then
                        o.nm.Visible = true
                        o.nm.Text = p.Name
                        o.nm.TextColor3 = HxC(cfg.Vis_NamesColor)
                        o.nm.Font = uiFonts[cfg.Vis_TextFont]
                        o.nm.TextSize = cfg.Vis_TextSize
                    else
                        o.nm.Visible = false
                    end

                    if cfg.Vis_HealthBars then
                        o.hpB.Visible = true
                        local pct = hum.Health / hum.MaxHealth
                        o.hpF.Size = UDim2.new(1, 0, pct, 0)
                        o.hpF.Position = UDim2.new(0, 0, 1, 0)
                        o.hpF.BackgroundColor3 = HxC(cfg.Vis_HealthColor)
                    else
                        o.hpB.Visible = false
                    end

                    if cfg.Vis_HealthText then
                        o.hpT.Visible = true
                        o.hpT.Text = math.floor(hum.Health) .. 'hp'
                        o.hpT.TextColor3 = HxC(cfg.Vis_HealthTextColor)
                        local pct = hum.Health / hum.MaxHealth
                        o.hpT.Position = UDim2.new(1, 2, 1 - pct, -7)
                        o.hpT.Font = uiFonts[cfg.Vis_TextFont]
                        o.hpT.TextSize = cfg.Vis_TextSize
                    else
                        o.hpT.Visible = false
                    end

                    if cfg.Vis_Distance then
                        o.dst.Visible = true
                        o.dst.Text = math.floor(dist) .. 'm'
                        o.dst.TextColor3 = HxC(cfg.Vis_DistanceColor)
                        o.dst.Font = uiFonts[cfg.Vis_TextFont]
                        o.dst.TextSize = cfg.Vis_TextSize
                    else
                        o.dst.Visible = false
                    end

                    if cfg.Vis_Weapons then
                        o.wp.Visible = true
                        local t = char:FindFirstChildOfClass('Tool')
                        o.wp.Text = t and t.Name or 'None'
                        o.wp.TextColor3 = HxC(cfg.Vis_WeaponsColor)
                        o.wp.Font = uiFonts[cfg.Vis_TextFont]
                        o.wp.TextSize = cfg.Vis_TextSize
                    else
                        o.wp.Visible = false
                    end

                    if cfg.Vis_Chams then
                        o.hl.Parent = char
                        o.hl.Adornee = char
                        o.hl.FillColor = HxC(cfg.Vis_ChamsColor)
                        o.hl.OutlineColor = HxC(cfg.Vis_ChamsColor)
                    else
                        o.hl.Parent = nil
                    end

                    if cfg.Vis_Snaplines then
                        local v, vis = E.Camera:WorldToViewportPoint(root.Position)
                        if vis then
                            o.sl.Visible = true
                            o.sl.BackgroundColor3 = HxC(cfg.Vis_SnaplinesColor)
                            local origin = Vector2.new(E.Camera.ViewportSize.X / 2, E.Camera.ViewportSize.Y)
                            local target = Vector2.new(v.X, v.Y)
                            local dir = target - origin
                            o.sl.Size = UDim2.new(0, 1, 0, dir.Magnitude)
                            o.sl.Position = UDim2.new(0, origin.X + dir.X / 2, 0, origin.Y + dir.Y / 2)
                            o.sl.Rotation = math.deg(math.atan2(dir.Y, dir.X)) - 90
                        else
                            o.sl.Visible = false
                        end
                    else
                        o.sl.Visible = false
                    end
                else
                    o.bg.Parent = nil
                    o.hl.Parent = nil
                    o.sl.Visible = false
                end
            else
                o.bg.Parent = nil
                o.hl.Parent = nil
                o.sl.Visible = false
            end
        end
    end
end)
