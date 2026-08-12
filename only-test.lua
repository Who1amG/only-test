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
    MobileHideBtn = true
}

local function saveCfg()
    if writefile then
        local st = {}
        for k, v in pairs(cfg) do
            if type(v) ~= "boolean" or k == "TransparentUI" or k == "EnableBackground" then
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
    end
end

if getgenv().WALLSCRIPTS_CLEANUP then
    pcall(getgenv().WALLSCRIPTS_CLEANUP)
end

getgenv().WALLSCRIPTS_CLEANUP = function()
    if pg:FindFirstChild(gn) then
        pg[gn]:Destroy()
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
        Parent =
            pg
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
    Image = "rbxassetid://138989964445964",
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

cST(tM, "Main")
cST(tM, "Miscellaneous")
cST(tM, "Money")

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

    local list = C("Frame",
        {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            ClipsDescendants = true,
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
        local tgtSize = open and (#opts * 26) or 0
        ts:Create(list, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, 0, 0, tgtSize) }):Play()
    end

    for i, opt in ipairs(opts) do
        local ob = C("TextButton",
            {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BackgroundTransparency = 1,
                Text =
                    opt,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment =
                    Enum.TextXAlignment.Left,
                Parent = list
            })
        C("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = ob })
        ob.MouseEnter:Connect(function()
            ts:Create(ob, TweenInfo.new(0.1),
                { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        end)
        ob.MouseLeave:Connect(function()
            ts:Create(ob, TweenInfo.new(0.1),
                { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) }):Play()
        end)
        ob.MouseButton1Click:Connect(function()
            idx = i
            open = false
            upd()
            if cb then cb(idx) end
        end)
    end

    bg.MouseButton1Click:Connect(function()
        open = not open
        upd()
    end)
end

local function HxC(h) return Color3.fromHex(h) end
local function CxH(c) return c:ToHex() end

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
        mBtn.Image = "rbxassetid://10734898355" 
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
