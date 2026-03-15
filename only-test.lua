-- [ SVC ]
local PLRS = game:GetService("Players")
local TS   = game:GetService("TweenService")
local UIS  = game:GetService("UserInputService")
local CORE = game:GetService("CoreGui")
local RS   = game:GetService("RunService")

-- [ SINGLETON ]
if _G.CENTRAL_LOADED then
    local OLD = CORE:FindFirstChild("CEN_V2") or PLRS.LocalPlayer.PlayerGui:FindFirstChild("CEN_V2")
    if OLD then
        warn("Script is  Already Loaded!")
        return
    else
        _G.CENTRAL_LOADED = false
    end
end
_G.CENTRAL_LOADED = true
_G.CENTRAL_NOTIFS_REF = nil
_G.EXE = {
    FARM_RUNNING = false, FARM_THREAD = nil,
    CC_RUNNING   = false, CC_THREAD   = nil,
    CF_RUNNING   = false, CF_THREAD   = nil,
    WH_RUNNING   = false, WH_THREAD   = nil,
    BF_RUNNING   = false, BF_THREAD   = nil,
    FLY_ON = false, SPD_ON = false, JMP_ON = false, CF_ON = false
}

-- [ LOC ]
local LPLR = PLRS.LocalPlayer

-- [ BYPASS TP — Multi-method system ]
-- Active method: "classic" | "stepped" | "scooter"
local TP_METHOD  = "classic"  -- default
local _SPAWN_PT  = nil
local _SPAWN_POS = nil

local function _TP_GET_SPAWN()
    if not _SPAWN_PT then
        _SPAWN_PT  = workspace.spawn_Assets.Points["Trinity Ave. Plaza"]
        _SPAWN_POS = _SPAWN_PT.Position
    end
end

local function _TP_WAIT_STABLE()
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    
    local stableFrames = 0
    local lastPos = hrp.Position

    while stableFrames < 10 do
        RS.Heartbeat:Wait()
        char = LPLR.Character or LPLR.CharacterAdded:Wait()
        hrp  = char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        
        local pos = hrp.Position
        if (pos - lastPos).Magnitude < 0.1 then
            stableFrames = stableFrames + 1
        else
            stableFrames = 0
        end
        lastPos = pos
    end
end

-- ── MÉTODO 1: Classic — mejorado con stability y snap (12 loops) ────
local function TP_CLASSIC(targetPos)
    _TP_GET_SPAWN()
    game:GetService("ReplicatedStorage").Remotes.Spawn:FireServer(_SPAWN_PT)
    
    _TP_WAIT_STABLE()
    
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for i = 1, 12 do
        hrp.CFrame = CFrame.new(targetPos)
        RS.Heartbeat:Wait()
    end
end

-- ── MÉTODO 2: Stepped — pasos de 70 studs con Heartbeat sync ─────────
local function TP_STEPPED(targetPos)
    local function getHRP()
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    end

    local hrp = getHRP()
    if not hrp then return end

    -- Inicia siempre el proceso de stepped (seguridad máxima)
    _TP_GET_SPAWN()
    game:GetService("ReplicatedStorage").Remotes.Spawn:FireServer(_SPAWN_PT)

    _TP_WAIT_STABLE()
    hrp = getHRP()

    -- Chunks de TP de 70 studs
    local STEP = 70
    local maxIter = 80

    while maxIter > 0 do
        maxIter = maxIter - 1
        hrp = getHRP()
        local current = hrp.Position
        local remaining = (targetPos - current).Magnitude

        if remaining < 5 then break end

        local dir = (targetPos - current).Unit
        local nextPos = current + dir * math.min(STEP, remaining)

        hrp.CFrame = CFrame.new(nextPos)
        RS.Heartbeat:Wait()
        hrp.CFrame = CFrame.new(nextPos)
        RS.Heartbeat:Wait()
    end

    -- Final snap (6 loops para asegurar posición final)
    hrp = getHRP()
    for i = 1, 6 do
        if hrp then
            hrp.CFrame = CFrame.new(targetPos)
            RS.Heartbeat:Wait()
        end
    end
end

-- ── MÉTODO 3: Scooter — (en investigación, por ahora usa Stepped) ─────
local function TP_SCOOTER(targetPos)
    -- TODO: scooter-based bypass (mounts a vehicle for server-trusted movement)
    -- Por ahora redirige a Stepped
    TP_STEPPED(targetPos)
end

-- ── MÉTODO 4: Nearby — para distancias cortas (< 50 studs) ──────────
local function TP_NEARBY(targetPos)
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    local startPos = hrp.Position
    local dist = (targetPos - startPos).Magnitude

    _TP_GET_SPAWN()
    game:GetService("ReplicatedStorage").Remotes.Spawn:FireServer(_SPAWN_PT)

    local waited = 0
    repeat
        task.wait(0.05)
        waited += 0.05
        char = LPLR.Character or LPLR.CharacterAdded:Wait()
        hrp  = char:WaitForChild("HumanoidRootPart")
    until (hrp.Position - _SPAWN_POS).Magnitude < 50 or waited > 3

    hrp.CFrame = CFrame.new(targetPos)
end

-- ── DISPATCHER global ─────────────────────────────────────────────────
local function BYPASS_TP(targetPos)
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local dist = (targetPos - hrp.Position).Magnitude
        if dist < 50 then
            TP_NEARBY(targetPos)
            return
        end
    end

    if TP_METHOD == "classic" then
        TP_CLASSIC(targetPos)
    elseif TP_METHOD == "scooter" then
        TP_SCOOTER(targetPos)
    else
        TP_STEPPED(targetPos)
    end
end

-- [ CFG ]
local Services = setmetatable({}, { __index = function(s, k) return game:GetService(k) end })
local HttpService = Services.HttpService

local Fonts = {}
local function RegisterFont(Name, Weight, Style, AssetUrl)
    local dir = "CEN_V2_ASSETS"
    if not isfolder(dir) then makefolder(dir) end
    if not isfolder(dir.."/fonts") then makefolder(dir.."/fonts") end
    if not isfolder(dir.."/assets") then makefolder(dir.."/assets") end
    
    local assetPath = dir.."/assets/"..Name..".ttf"
    if not isfile(assetPath) then
        writefile(assetPath, game:HttpGet(AssetUrl))
    end
    
    local fontData = {
        name = Name,
        faces = {{
            name = "Normal",
            weight = Weight,
            style = Style,
            assetId = getcustomasset(assetPath)
        }}
    }
    
    local fontPath = dir.."/fonts/"..Name..".font"
    writefile(fontPath, HttpService:JSONEncode(fontData))
    return Font.new(getcustomasset(fontPath))
end

task.spawn(function()
    Fonts["Plex"] = RegisterFont("Plex", 400, "Normal", "https://github.com/KingVonOBlockJoyce/OctoHook-UI/raw/refs/heads/main/fs-tahoma-8px%20(3).ttf")
end)

local CFG = {
    KEY = Enum.KeyCode.RightControl,
    IMG = "rbxassetid://108458500083995",
    COL = {
        BG  = Color3.fromRGB(15, 15, 20),
        ACC = Color3.fromRGB(255, 120, 120),
        TXT = Color3.fromRGB(240, 240, 240),
        GRY = Color3.fromRGB(80, 80, 90),
        RED = Color3.fromRGB(255, 95, 87),
        YEL = Color3.fromRGB(255, 189, 46),
        GRN = Color3.fromRGB(39, 201, 63),
        BTN = Color3.fromRGB(30, 30, 40)
    },
    SPD = 0.3
}

-- [ UI THEMES ]
local UI_REGISTERED_ELEMENTS = {} -- tabla de todos los elementos vivos para repintar

local UI_THEMES = {
    ["Default"] = {
        ACC = Color3.fromRGB(255, 120, 120),
        BG  = Color3.fromRGB(15, 15, 20),
        GRY = Color3.fromRGB(80, 80, 90),
        BTN = Color3.fromRGB(30, 30, 40),
    },
    ["Snow White"] = {
        ACC = Color3.fromRGB(220, 220, 235),
        BG  = Color3.fromRGB(18, 18, 24),
        GRY = Color3.fromRGB(130, 130, 145),
    },
    ["Sky Blue"] = {
        ACC = Color3.fromRGB(80, 170, 255),
        BG  = Color3.fromRGB(10, 18, 30),
        GRY = Color3.fromRGB(70, 100, 130),
    },
    ["Void Black"] = {
        ACC = Color3.fromRGB(200, 200, 200),
        BG  = Color3.fromRGB(5, 5, 8),
        GRY = Color3.fromRGB(60, 60, 70),
    },
    ["Coffee"] = {
        ACC = Color3.fromRGB(185, 130, 90),
        BG  = Color3.fromRGB(20, 14, 10),
        GRY = Color3.fromRGB(100, 75, 55),
    },
    ["Gold"] = {
        ACC = Color3.fromRGB(220, 175, 40),
        BG  = Color3.fromRGB(18, 15, 5),
        GRY = Color3.fromRGB(110, 90, 30),
    },
}

-- Compara dos Color3 con tolerancia
local function COL_MATCH(a, b, tol)
    tol = tol or 0.06
    return math.abs(a.R-b.R) < tol and math.abs(a.G-b.G) < tol and math.abs(a.B-b.B) < tol
end

local function APPLY_THEME(themeName)
    local t = UI_THEMES[themeName]
    if not t then return end

    local oldACC = CFG.COL.ACC
    local oldBG  = CFG.COL.BG
    local oldGRY = CFG.COL.GRY
    local oldBTN = CFG.COL.BTN

    CFG.COL.ACC = t.ACC
    CFG.COL.BG  = t.BG
    CFG.COL.GRY = t.GRY
    -- Derive BTN color: BG slightly lighter for button contrast
    local r,g,b = t.BG.R, t.BG.G, t.BG.B
    CFG.COL.BTN = Color3.new(math.min(r+0.08,1), math.min(g+0.08,1), math.min(b+0.1,1))

    local roots = {game:GetService("CoreGui"), game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")}
    for _, root in ipairs(roots) do
        local scr = root and root:FindFirstChild("CEN_V2")
        if not scr then continue end

        for _, obj in ipairs(scr:GetDescendants()) do
            pcall(function()
                -- Specific tag check (Name based) for 100% reliability
                if obj.Name == "CEN_ACCENT_TEXT" then
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then obj.TextColor3 = t.ACC end
                    return -- priority match
                end

                -- BackgroundColor3
                if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
                    local bc = obj.BackgroundColor3
                    if COL_MATCH(bc, oldBG) then
                        obj.BackgroundColor3 = t.BG
                    elseif COL_MATCH(bc, oldACC) then
                        obj.BackgroundColor3 = t.ACC
                    elseif COL_MATCH(bc, oldGRY) then
                        obj.BackgroundColor3 = t.GRY
                    elseif oldBTN and COL_MATCH(bc, oldBTN) then
                        obj.BackgroundColor3 = t.BTN
                    end
                end
                -- TextColor3
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local tc = obj.TextColor3
                    if COL_MATCH(tc, oldACC) then
                        obj.TextColor3 = t.ACC
                    elseif COL_MATCH(tc, oldGRY) then
                        obj.TextColor3 = t.GRY
                    end
                end
                -- ImageColor3
                if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    local ic = obj.ImageColor3
                    if COL_MATCH(ic, oldACC) then
                        obj.ImageColor3 = t.ACC
                    elseif COL_MATCH(ic, oldGRY) then
                        obj.ImageColor3 = t.GRY
                    end
                end
                -- UIStroke
                if obj:IsA("UIStroke") then
                    local sc = obj.Color
                    if COL_MATCH(sc, oldACC) then
                        obj.Color = t.ACC
                    elseif COL_MATCH(sc, oldGRY) then
                        obj.Color = t.GRY
                    end
                end
                -- ScrollBarImageColor3
                if obj:IsA("ScrollingFrame") then
                    local sb = obj.ScrollBarImageColor3
                    if COL_MATCH(sb, oldACC) then
                        obj.ScrollBarImageColor3 = t.ACC
                    end
                end
            end)
        end
    end
end

-- Aplica una fuente a todos los TextLabel/TextButton/TextBox del UI
local function APPLY_FONT_UI(enumFont)
    local root = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    local scr  = root and root:FindFirstChild("CEN_V2")
    if not scr then return end
    for _, obj in ipairs(scr:GetDescendants()) do
        pcall(function()
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                obj.Font = enumFont
            end
        end)
    end
end

local function REG(obj, prop, col)
    table.insert(UI_REGISTERED_ELEMENTS, { obj = obj, prop = prop, col = col })
end

-- [ ESP CFG ]
local ESP_CFG = {
    Enabled = false,
    MaxDist = 500,
    Boxes   = { Enabled = false, Color = Color3.new(1,1,1), Animated = false },
    Corners = { Enabled = false, Color = Color3.new(1,1,1) },
    Filled  = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0,0,0), Alpha = 0.25 },
    Names   = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Health  = { Enabled = false, Bar = false, Text = false, Dynamic = false, Color1 = Color3.fromRGB(0, 255, 0), Color2 = Color3.fromRGB(255, 0, 0) },
    Weapons = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Dist    = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Chams   = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0,0,0), Thermal = false },
    ToolCharms = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0,0,0) },
    FontSize = 12,
    Font = Enum.Font.GothamBold,
    SilentAim = {
        Enabled = false,
        Keybind = nil,
    },
    Snapline = {
        Enabled = false,
        Color = Color3.fromRGB(245, 160, 55),
        Thickness = 1
    }
}

-- [ HELPERS ]
local function TWN(OBJ, PRP, TIM)
    local INF = TweenInfo.new(TIM or CFG.SPD, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TS:Create(OBJ, INF, PRP):Play()
end

local function RND(OBJ, RAD)
    local CRN = Instance.new("UICorner", OBJ)
    CRN.CornerRadius = UDim.new(0, RAD or 12)
    return CRN
end

local function RAND_STR(l)
    l = l or math.random(12, 20)
    local s = ""
    for _ = 1, l do
        s = s .. string.char(math.random(97, 122)) -- a-z
    end
    return s
end

local function STR(OBJ, COL, THK)
    local BRD = Instance.new("UIStroke", OBJ)
    BRD.Color = COL or CFG.COL.ACC
    BRD.Thickness = THK or 1
    BRD.Transparency = 0.8
    return BRD
end

-- [ ADVANCED COLOR PICKER ]
local PICKER_DATA = { OPEN = false, CALLBACK = nil, COLOR = Color3.new(1,1,1), ALPHA = 0 }
local function SETUP_COLOR_PICKER()
    local GUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
    GUI.Name = RAND_STR()
    GUI.DisplayOrder = -900 -- Above menu but below game HUD
    GUI.IgnoreGuiInset = true

    local MAIN = Instance.new("Frame", GUI)
    MAIN.Size = UDim2.new(0, 200, 0, 240)
    MAIN.BackgroundColor3 = CFG.COL.BG
    MAIN.Visible = false
    MAIN.Active = true
    RND(MAIN, 12)
    STR(MAIN, CFG.COL.ACC, 1)

    local function MK_DRAG(parent, size, pos)
        local f = Instance.new("Frame", parent)
        f.Size = size
        f.Position = pos
        f.BackgroundTransparency = 1
        return f
    end

    -- SV Square
    local SV_HOLDER = Instance.new("Frame", MAIN)
    SV_HOLDER.Size = UDim2.new(1, -20, 0, 150)
    SV_HOLDER.Position = UDim2.new(0, 10, 0, 10)
    SV_HOLDER.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    SV_HOLDER.Active = true
    RND(SV_HOLDER, 8)

    local S_GRAD = Instance.new("Frame", SV_HOLDER)
    S_GRAD.Size = UDim2.new(1, 0, 1, 0)
    S_GRAD.BackgroundTransparency = 0
    RND(S_GRAD, 8)
    local SG = Instance.new("UIGradient", S_GRAD)
    SG.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
    SG.Transparency = NumberSequence.new(0, 1)

    local V_GRAD = Instance.new("Frame", SV_HOLDER)
    V_GRAD.Size = UDim2.new(1, 0, 1, 0)
    V_GRAD.BackgroundTransparency = 0
    RND(V_GRAD, 8)
    local VG = Instance.new("UIGradient", V_GRAD)
    VG.Rotation = 90
    VG.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
    VG.Transparency = NumberSequence.new(1, 0)

    local CURSOR = Instance.new("Frame", SV_HOLDER)
    CURSOR.Size = UDim2.new(0, 10, 0, 10)
    CURSOR.AnchorPoint = Vector2.new(0.5, 0.5)
    CURSOR.BackgroundColor3 = Color3.new(1,1,1)
    CURSOR.ZIndex = 5
    RND(CURSOR, 10)
    STR(CURSOR, Color3.new(0,0,0), 2)

    -- Hue Slider
    local HUE_BAR = Instance.new("Frame", MAIN)
    HUE_BAR.Size = UDim2.new(1, -20, 0, 12)
    HUE_BAR.Position = UDim2.new(0, 10, 0, 170)
    HUE_BAR.Active = true
    RND(HUE_BAR, 6)
    local HG = Instance.new("UIGradient", HUE_BAR)
    HG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
        ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16,1,1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
        ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66,1,1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
    })

    local HUE_CURSOR = Instance.new("Frame", HUE_BAR)
    HUE_CURSOR.Size = UDim2.new(0, 4, 1, 4)
    HUE_CURSOR.Position = UDim2.new(0, 0, 0.5, 0)
    HUE_CURSOR.AnchorPoint = Vector2.new(0.5, 0.5)
    HUE_CURSOR.BackgroundColor3 = Color3.new(1,1,1)
    RND(HUE_CURSOR, 2)
    STR(HUE_CURSOR, Color3.new(0,0,0), 1)

    -- Alpha Slider
    local ALP_BAR = Instance.new("Frame", MAIN)
    ALP_BAR.Size = UDim2.new(1, -20, 0, 12)
    ALP_BAR.Position = UDim2.new(0, 10, 0, 190)
    ALP_BAR.Active = true
    RND(ALP_BAR, 6)

    local ALP_CHK = Instance.new("ImageLabel", ALP_BAR)
    ALP_CHK.Size = UDim2.new(1, 0, 1, 0)
    ALP_CHK.BackgroundTransparency = 1
    ALP_CHK.Image = "rbxassetid://18274452449"
    ALP_CHK.ScaleType = Enum.ScaleType.Tile
    ALP_CHK.TileSize = UDim2.new(0, 6, 0, 6)
    RND(ALP_CHK, 6)

    local ALP_GRAD = Instance.new("Frame", ALP_BAR)
    ALP_GRAD.Size = UDim2.new(1, 0, 1, 0)
    ALP_GRAD.BackgroundTransparency = 0
    RND(ALP_GRAD, 6)
    local AG = Instance.new("UIGradient", ALP_GRAD)

    local ALP_CURSOR = Instance.new("Frame", ALP_BAR)
    ALP_CURSOR.Size = UDim2.new(0, 4, 1, 4)
    ALP_CURSOR.Position = UDim2.new(1, 0, 0.5, 0)
    ALP_CURSOR.AnchorPoint = Vector2.new(0.5, 0.5)
    ALP_CURSOR.BackgroundColor3 = Color3.new(1,1,1)
    RND(ALP_CURSOR, 2)
    STR(ALP_CURSOR, Color3.new(0,0,0), 1)

    -- Logic
    local h, s, v, a = 0, 1, 1, 0
    local function UPD()
        local clr = Color3.fromHSV(h, s, v)
        SV_HOLDER.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        CURSOR.Position = UDim2.new(s, 0, 1 - v, 0)
        HUE_CURSOR.Position = UDim2.new(h, 0, 0.5, 0)
        ALP_CURSOR.Position = UDim2.new(1 - a, 0, 0.5, 0)
        AG.Color = ColorSequence.new(clr, clr)
        AG.Transparency = NumberSequence.new(0, 1)
        
        if PICKER_DATA.CALLBACK then
            PICKER_DATA.CALLBACK(clr, a)
        end
    end

    local function HANDLE_INPUT(obj, cb)
        local drag = false
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; cb(i) end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then cb(i) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
        end)
    end

    HANDLE_INPUT(SV_HOLDER, function(i)
        local px = math.clamp((i.Position.X - SV_HOLDER.AbsolutePosition.X) / SV_HOLDER.AbsoluteSize.X, 0, 1)
        local py = math.clamp((i.Position.Y - SV_HOLDER.AbsolutePosition.Y) / SV_HOLDER.AbsoluteSize.Y, 0, 1)
        s, v = px, 1 - py
        UPD()
    end)

    HANDLE_INPUT(HUE_BAR, function(i)
        h = math.clamp((i.Position.X - HUE_BAR.AbsolutePosition.X) / HUE_BAR.AbsoluteSize.X, 0, 1)
        UPD()
    end)

    HANDLE_INPUT(ALP_BAR, function(i)
        a = 1 - math.clamp((i.Position.X - ALP_BAR.AbsolutePosition.X) / ALP_BAR.AbsoluteSize.X, 0, 1)
        UPD()
    end)

    -- Close on click outside
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and MAIN.Visible then
            local mp = UIS:GetMouseLocation()
            local x1, y1 = MAIN.AbsolutePosition.X, MAIN.AbsolutePosition.Y
            local x2, y2 = x1 + MAIN.AbsoluteSize.X, y1 + MAIN.AbsoluteSize.Y
            if mp.X < x1 or mp.X > x2 or mp.Y < y1 + 36 or mp.Y > y2 + 36 then -- offset for gui inset
                MAIN.Visible = false
            end
        end
    end)

    function PICKER_DATA:OPEN_PICKER(start_clr, start_alpha, pos, cb)
        self.CALLBACK = cb
        h, s, v = start_clr:ToHSV()
        a = start_alpha or 0
        MAIN.Position = UDim2.new(0, pos.X - 210, 0, pos.Y - 50)
        MAIN.Visible = true
        UPD()
    end
end
SETUP_COLOR_PICKER()

-- [ NOTIFY ]
local function NOTIFY(TITLE, MSG, TIME)
    if not _G.CENTRAL_NOTIFS_REF or not _G.CENTRAL_NOTIFS_REF.Parent then
        _G.CENTRAL_NOTIFS_REF = Instance.new("ScreenGui")
        _G.CENTRAL_NOTIFS_REF.Name = RAND_STR()
        _G.CENTRAL_NOTIFS_REF.Parent = game:GetService("CoreGui")
        _G.CENTRAL_NOTIFS_REF.ResetOnSpawn = false
        _G.CENTRAL_NOTIFS_REF.DisplayOrder = 10000
        _G.CENTRAL_NOTIFS_REF.IgnoreGuiInset = true
    end
    local N_GUI = _G.CENTRAL_NOTIFS_REF

    local HOLDER = N_GUI:FindFirstChild("HOLDER")
    if not HOLDER then
        HOLDER = Instance.new("Frame", N_GUI)
        HOLDER.Name = "HOLDER"
        HOLDER.Size = UDim2.new(0, 250, 1, -40)
        HOLDER.Position = UDim2.new(1, -20, 0, 20)
        HOLDER.AnchorPoint = Vector2.new(1, 0)
        HOLDER.BackgroundTransparency = 1

        local LAY = Instance.new("UIListLayout", HOLDER)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder
        LAY.Padding = UDim.new(0, 10)
        LAY.VerticalAlignment = Enum.VerticalAlignment.Top
    end

    local FRM = Instance.new("Frame", HOLDER)
    FRM.Size = UDim2.new(1, 0, 0, 60)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.1
    FRM.BorderSizePixel = 0
    RND(FRM, 10)
    STR(FRM, CFG.COL.ACC, 1)

    local BG = Instance.new("ImageLabel", FRM)
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.Image = CFG.IMG
    BG.ImageTransparency = 0.8
    BG.ScaleType = Enum.ScaleType.Crop
    BG.BackgroundTransparency = 1
    RND(BG, 10)

    local _NF = (typeof(ESP_CFG and ESP_CFG.Font) == "EnumItem") and ESP_CFG.Font or Enum.Font.GothamBold
    local _NM = (typeof(ESP_CFG and ESP_CFG.Font) == "EnumItem") and ESP_CFG.Font or Enum.Font.Gotham

    local T = Instance.new("TextLabel", FRM)
    T.Text = TITLE
    T.Size = UDim2.new(1, -20, 0, 20)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.TextColor3 = CFG.COL.ACC
    T.Font = _NF
    T.TextSize = 14
    T.TextXAlignment = Enum.TextXAlignment.Left

    local M = Instance.new("TextLabel", FRM)
    M.Text = MSG
    M.Size = UDim2.new(1, -20, 0, 30)
    M.Position = UDim2.new(0, 10, 0, 25)
    M.BackgroundTransparency = 1
    M.TextColor3 = CFG.COL.TXT
    M.Font = _NM
    M.TextSize = 12
    M.TextWrapped = true
    M.TextXAlignment = Enum.TextXAlignment.Left
    M.TextYAlignment = Enum.TextYAlignment.Top

    FRM.Position = UDim2.new(1.2, 0, 0, 0)
    TWN(FRM, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)

    task.delay(TIME or 5, function()
        TWN(FRM, {BackgroundTransparency = 1}, 0.5)
        TWN(T,   {TextTransparency = 1}, 0.5)
        TWN(M,   {TextTransparency = 1}, 0.5)
        task.wait(0.5)
        FRM:Destroy()
    end)
end

-- [ UI ELEMENT BUILDERS ]
local function ADD_LBL(PAG, TXT)
    local LBL = Instance.new("TextLabel", PAG)
    LBL.Size = UDim2.new(1, -10, 0, 25)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.ACC
    LBL.Font = Enum.Font.GothamBold
    LBL.TextSize = 14
    LBL.TextXAlignment = Enum.TextXAlignment.Left
    LBL.TextWrapped = true
    LBL.ZIndex = 15
    return LBL
end

local function ADD_BTN(PAG, TXT, CB)
    local BTN = Instance.new("TextButton", PAG)
    BTN.Size = UDim2.new(1, -10, 0, 35)
    BTN.BackgroundColor3 = CFG.COL.BG
    BTN.BackgroundTransparency = 0.82
    BTN.Text = TXT
    BTN.TextColor3 = CFG.COL.TXT
    BTN.Font = Enum.Font.GothamBold
    BTN.TextSize = 13
    BTN.AutoButtonColor = false
    RND(BTN, 10)
    
    local STR_OBJ = STR(BTN, CFG.COL.ACC, 1.2)
    STR_OBJ.Transparency = 0.8
    STR_OBJ.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local GRAD = Instance.new("UIGradient", BTN)
    GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
    })
    GRAD.Rotation = 45
    GRAD.Transparency = NumberSequence.new(0.5)

    BTN.MouseEnter:Connect(function()
        TWN(BTN, {BackgroundTransparency = 0.7, BackgroundColor3 = CFG.COL.ACC}, 0.2)
        TWN(STR_OBJ, {Transparency = 0.5}, 0.2)
    end)
    BTN.MouseLeave:Connect(function()
        TWN(BTN, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG}, 0.2)
        TWN(STR_OBJ, {Transparency = 0.8}, 0.2)
    end)

    BTN.MouseButton1Click:Connect(function()
        TWN(BTN, {BackgroundTransparency = 0.4, TextSize = 12}, 0.1)
        task.wait(0.1)
        TWN(BTN, {BackgroundTransparency = 0.7, TextSize = 13}, 0.1)
        if CB then CB() end
    end)
    return BTN
end

local function ADD_INP(PAG, PH, DEF, CB)
    local FRM = Instance.new("TextButton", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.82
    FRM.Text = ""
    FRM.AutoButtonColor = false
    FRM.Active = true
    RND(FRM, 10)
    
    local INP_STR = STR(FRM, CFG.COL.ACC, 1.2)
    INP_STR.Transparency = 0.85
    INP_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local INP_GRAD = Instance.new("UIGradient", FRM)
    INP_GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
    })
    INP_GRAD.Rotation = 45
    INP_GRAD.Transparency = NumberSequence.new(0.5)

    local BOX = Instance.new("TextBox", FRM)
    BOX.Size = UDim2.new(1, -20, 1, 0)
    BOX.Position = UDim2.new(0, 10, 0, 0)
    BOX.BackgroundTransparency = 1
    BOX.Text = DEF or ""
    BOX.PlaceholderText = PH
    BOX.TextColor3 = CFG.COL.TXT
    BOX.PlaceholderColor3 = CFG.COL.GRY
    BOX.Font = Enum.Font.Gotham
    BOX.TextSize = 14
    BOX.TextXAlignment = Enum.TextXAlignment.Left

    BOX.FocusLost:Connect(function()
        if CB then CB(BOX.Text, BOX) end
    end)
    return BOX
end

local function ADD_TEXTAREA(PAG, PH, DEF, HEIGHT, CB)
    local FRM = Instance.new("TextButton", PAG)
    FRM.Size = UDim2.new(1, -10, 0, HEIGHT or 100)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    FRM.Text = ""
    FRM.AutoButtonColor = false
    FRM.Active = true
    RND(FRM, 8)
    STR(FRM, CFG.COL.GRY, 1)

    local BOX = Instance.new("TextBox", FRM)
    BOX.Size = UDim2.new(1, -20, 1, -10)
    BOX.Position = UDim2.new(0, 10, 0, 5)
    BOX.BackgroundTransparency = 1
    BOX.Text = DEF or ""
    BOX.PlaceholderText = PH
    BOX.TextColor3 = CFG.COL.TXT
    BOX.PlaceholderColor3 = CFG.COL.GRY
    BOX.Font = Enum.Font.Gotham
    BOX.TextSize = 13
    BOX.TextXAlignment = Enum.TextXAlignment.Left
    BOX.TextYAlignment = Enum.TextYAlignment.Top
    BOX.TextWrapped = true
    BOX.MultiLine = true
    BOX.ClearTextOnFocus = false

    BOX.FocusLost:Connect(function()
        if CB then CB(BOX.Text, BOX) end
    end)
    return BOX
end

local function ADD_DRP(PAG, TTL, CB)
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    FRM.ClipsDescendants = true
    FRM.ZIndex = 5
    RND(FRM, 8)
    STR(FRM, CFG.COL.GRY, 1)

    local BTN = Instance.new("TextButton", FRM)
    BTN.Size = UDim2.new(1, 0, 0, 35)
    BTN.BackgroundTransparency = 1
    BTN.Text = "  " .. TTL
    BTN.TextColor3 = CFG.COL.TXT
    BTN.Font = Enum.Font.GothamBold
    BTN.TextSize = 14
    BTN.TextXAlignment = Enum.TextXAlignment.Left
    BTN.ZIndex = 6

    local ICO = Instance.new("ImageLabel", BTN)
    ICO.Size = UDim2.new(0, 20, 0, 20)
    ICO.Position = UDim2.new(1, -30, 0.5, -10)
    ICO.BackgroundTransparency = 1
    ICO.Image = "rbxassetid://6031091004"
    ICO.ImageColor3 = CFG.COL.ACC

    local SCR = Instance.new("ScrollingFrame", FRM)
    SCR.Size = UDim2.new(1, 0, 0, 150)
    SCR.Position = UDim2.new(0, 0, 0, 35)
    SCR.BackgroundTransparency = 1
    SCR.ScrollBarThickness = 2
    SCR.ScrollBarImageColor3 = CFG.COL.ACC
    SCR.ZIndex = 6

    local LAY = Instance.new("UIListLayout", SCR)
    LAY.SortOrder = Enum.SortOrder.LayoutOrder

    local OPEN = false

    local function RFSH(LST)
        for _, C in pairs(SCR:GetChildren()) do
            if C:IsA("TextButton") then C:Destroy() end
        end
        for _, P in pairs(LST) do
            local ITM = Instance.new("TextButton", SCR)
            ITM.Size = UDim2.new(1, 0, 0, 30)
            ITM.BackgroundTransparency = 1
            ITM.Text = "  " .. P
            ITM.TextColor3 = CFG.COL.GRY
            ITM.Font = Enum.Font.Gotham
            ITM.TextSize = 13
            ITM.TextXAlignment = Enum.TextXAlignment.Left
            ITM.ZIndex = 7

            ITM.MouseEnter:Connect(function()
                TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
            end)
            ITM.MouseLeave:Connect(function()
                TWN(ITM, {TextColor3 = CFG.COL.GRY}, 0.1)
            end)
            ITM.MouseButton1Click:Connect(function()
                BTN.Text = "  " .. P
                OPEN = false
                TWN(FRM, {Size = UDim2.new(1, -10, 0, 35)})
                TWN(ICO, {Rotation = 0})
                if CB then CB(P) end
            end)
        end
        SCR.CanvasSize = UDim2.new(0, 0, 0, LAY.AbsoluteContentSize.Y)
    end

    BTN.MouseButton1Click:Connect(function()
        OPEN = not OPEN
        if OPEN then
            TWN(FRM, {Size = UDim2.new(1, -10, 0, 185)})
            TWN(ICO, {Rotation = 180})
        else
            TWN(FRM, {Size = UDim2.new(1, -10, 0, 35)})
            TWN(ICO, {Rotation = 0})
        end
    end)

    return {REFRESH = RFSH}
end

local function ADD_TGL(PAG, TXT, DEF, CB)
    local TGL = { VAL = DEF or false }
    
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    RND(FRM, 8)
    STR(FRM, CFG.COL.GRY, 1)

    local LBL = Instance.new("TextLabel", FRM)
    LBL.Size = UDim2.new(1, -50, 1, 0)
    LBL.Position = UDim2.new(0, 10, 0, 0)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.TXT
    LBL.Font = Enum.Font.GothamBold
    LBL.TextSize = 13
    LBL.TextXAlignment = Enum.TextXAlignment.Left

    local BTN = Instance.new("TextButton", FRM)
    BTN.Size = UDim2.new(0, 35, 0, 18)
    BTN.Position = UDim2.new(1, -45, 0.5, -9)
    BTN.BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY
    BTN.Text = ""
    RND(BTN, 10)

    local IND = Instance.new("Frame", BTN)
    IND.Size = UDim2.new(0, 14, 0, 14)
    IND.Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    IND.BackgroundColor3 = Color3.new(1, 1, 1)
    RND(IND, 10)

    local function UPD(dont_callback)
        TWN(BTN, {BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY}, 0.2)
        TWN(IND, {Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
        if CB and not dont_callback then CB(TGL.VAL) end
    end

    BTN.MouseButton1Click:Connect(function()
        TGL.VAL = not TGL.VAL
        UPD()
    end)

    function TGL:SET(v)
        self.VAL = v
        UPD(true)
    end

    return TGL
end

local function ADD_TGL_KB(PAG, TXT, DEF, DEF_KB, CB)
    local TGL = { VAL = DEF or false, KB = DEF_KB }
    local IS_PC = not game:GetService("UserInputService").TouchEnabled
    _G.CEN_BINDS = _G.CEN_BINDS or {}

    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 30)
    FRM.BackgroundTransparency = 1

    local LBL = Instance.new("TextLabel", FRM)
    LBL.Size = UDim2.new(1, -85, 1, 0)
    LBL.Position = UDim2.new(0, 5, 0, 0)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.TXT
    LBL.Font = Enum.Font.GothamMedium
    LBL.TextSize = 13
    LBL.TextXAlignment = Enum.TextXAlignment.Left

    local BTN = Instance.new("TextButton", FRM)
    BTN.Size = UDim2.new(0, 35, 0, 18)
    BTN.Position = UDim2.new(1, -35, 0.5, -9)
    BTN.BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY
    BTN.Text = ""
    RND(BTN, 10)

    local IND = Instance.new("Frame", BTN)
    IND.Size = UDim2.new(0, 14, 0, 14)
    IND.Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    IND.BackgroundColor3 = Color3.new(1, 1, 1)
    RND(IND, 10)

    local KB_LISTENING = false
    if IS_PC then
        local KB_BOX = Instance.new("TextButton", FRM)
        KB_BOX.Size = UDim2.new(0, 32, 0, 20)
        KB_BOX.Position = UDim2.new(1, -75, 0.5, -10)
        KB_BOX.BackgroundColor3 = CFG.COL.BG
        KB_BOX.BackgroundTransparency = 0.82
        KB_BOX.BorderSizePixel = 0
        KB_BOX.Text = TGL.KB and tostring(TGL.KB):gsub("Enum.KeyCode.", "") or "—"
        KB_BOX.TextColor3 = CFG.COL.GRY
        KB_BOX.Font = Enum.Font.GothamBold
        KB_BOX.TextSize = 10
        KB_BOX.ZIndex = 6
        KB_BOX.AutoButtonColor = false
        RND(KB_BOX, 8)
        
        local KB_STR = STR(KB_BOX, CFG.COL.ACC, 1.2)
        KB_STR.Transparency = 0.8
        KB_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local KB_GRAD = Instance.new("UIGradient", KB_BOX)
        KB_GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
        })
        KB_GRAD.Rotation = 45
        KB_GRAD.Transparency = NumberSequence.new(0.5)

        KB_BOX.MouseEnter:Connect(function()
            TWN(KB_BOX, {BackgroundTransparency = 0.6, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0,0,0)}, 0.2)
            TWN(KB_STR, {Transparency = 0.4}, 0.2)
        end)
        KB_BOX.MouseLeave:Connect(function()
            TWN(KB_BOX, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG, TextColor3 = CFG.COL.GRY}, 0.2)
            TWN(KB_STR, {Transparency = 0.8}, 0.2)
        end)

        KB_BOX.MouseButton1Click:Connect(function()
            if KB_LISTENING then return end
            KB_LISTENING = true
            KB_BOX.Text = "..."
            KB_BOX.TextColor3 = CFG.COL.YEL
            TWN(KB_BOX, {BackgroundColor3 = Color3.fromRGB(50, 45, 20), BackgroundTransparency = 0.5, TextSize = 8}, 0.1)

            local conn
            conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                KB_LISTENING = false

                if inp.KeyCode == Enum.KeyCode.Escape then
                    TGL.KB = nil
                    KB_BOX.Text = "—"
                    KB_BOX.TextColor3 = CFG.COL.GRY
                    TWN(KB_BOX, {BackgroundColor3 = CFG.COL.BTN}, 0.1)
                    return
                end

                TGL.KB = inp.KeyCode
                local name = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")
                if #name > 4 then name = name:sub(1,4) end
                KB_BOX.Text = name
                KB_BOX.TextColor3 = CFG.COL.TXT
                TWN(KB_BOX, {BackgroundColor3 = CFG.COL.BG, BackgroundTransparency = 0.82, TextSize = 10}, 0.1)
            end)
        end)

        local bind_conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
            if gpe or KB_LISTENING or TGL.KB == nil then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == TGL.KB then
                BTN.BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY -- toggle state
                TGL.VAL = not TGL.VAL
                TWN(BTN, {BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY}, 0.2)
                TWN(IND, {Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                if CB then CB(TGL.VAL, TGL.KB) end
            end
        end)
        table.insert(_G.CEN_BINDS, bind_conn)
    end

    local function UPD(dont_callback)
        TWN(BTN, {BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY}, 0.2)
        TWN(IND, {Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
        if CB and not dont_callback then CB(TGL.VAL, TGL.KB) end
    end

    BTN.MouseButton1Click:Connect(function()
        TGL.VAL = not TGL.VAL
        UPD()
    end)
    function TGL:SET(v)
        self.VAL = v
        UPD(true)
    end
    return TGL
end

local function ADD_SLD(PAG, TXT, MIN, MAX, DEF, CB, SFX)
    local SLD = { VAL = DEF or MIN }
    local suffix = SFX or ""
    
    local FRM = Instance.new("TextButton", PAG)
    FRM.Name = TXT .. "_Slider"
    FRM.Size = UDim2.new(1, -10, 0, 45)
    FRM.BackgroundTransparency = 1
    FRM.Text = ""
    FRM.AutoButtonColor = false
    FRM.Active = true

    local LBL = Instance.new("TextLabel", FRM)
    LBL.Size = UDim2.new(1, -60, 0, 20)
    LBL.Position = UDim2.new(0, 5, 0, 5)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.TXT
    LBL.Font = Enum.Font.GothamMedium
    LBL.TextSize = 13
    LBL.TextXAlignment = Enum.TextXAlignment.Left

    local VAL_LBL = Instance.new("TextLabel", FRM)
    VAL_LBL.Size = UDim2.new(0, 60, 0, 20)
    VAL_LBL.Position = UDim2.new(1, -65, 0, 5)
    VAL_LBL.BackgroundTransparency = 1
    VAL_LBL.Text = tostring(SLD.VAL) .. suffix
    VAL_LBL.TextColor3 = CFG.COL.ACC
    VAL_LBL.Font = Enum.Font.GothamBold
    VAL_LBL.TextSize = 12
    VAL_LBL.TextXAlignment = Enum.TextXAlignment.Right

    local BAR_BG = Instance.new("Frame", FRM)
    BAR_BG.Size = UDim2.new(1, -10, 0, 6)
    BAR_BG.Position = UDim2.new(0, 5, 0, 32)
    BAR_BG.BackgroundColor3 = CFG.COL.GRY
    BAR_BG.BackgroundTransparency = 0.5
    BAR_BG.Active = true -- Block input from background
    RND(BAR_BG, 3)

    local FILL = Instance.new("Frame", BAR_BG)
    FILL.Size = UDim2.new(math.clamp((SLD.VAL - MIN) / (MAX - MIN), 0, 1), 0, 1, 0)
    FILL.BackgroundColor3 = CFG.COL.ACC
    FILL.BorderSizePixel = 0
    RND(FILL, 3)

    local KNOB = Instance.new("Frame", BAR_BG)
    KNOB.Size = UDim2.new(0, 12, 0, 12)
    KNOB.AnchorPoint = Vector2.new(0.5, 0.5)
    KNOB.Position = UDim2.new(math.clamp((SLD.VAL - MIN) / (MAX - MIN), 0, 1), 0, 0.5, 0)
    KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
    KNOB.BorderSizePixel = 0
    KNOB.ZIndex = 5
    RND(KNOB, 100)
    STR(KNOB, CFG.COL.ACC, 1)

    local function UPD(input, dont_callback)
        local pos
        if typeof(input) == "number" then
            pos = math.clamp((input - MIN) / (MAX - MIN), 0, 1)
        else
            pos = math.clamp((input.Position.X - BAR_BG.AbsolutePosition.X) / BAR_BG.AbsoluteSize.X, 0, 1)
        end
        
        SLD.VAL = math.floor(MIN + (MAX - MIN) * pos)
        FILL.Size = UDim2.new(pos, 0, 1, 0)
        KNOB.Position = UDim2.new(pos, 0, 0.5, 0)
        VAL_LBL.Text = tostring(SLD.VAL) .. suffix
        if CB and not dont_callback then CB(SLD.VAL) end
    end

    local DRAG = false
    FRM.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            getgenv()._CEN_SLD_ACTIVE = true -- LOCK GLOBAL DRAG
            DRAG = true
            UPD(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if DRAG and input.UserInputType == Enum.UserInputType.MouseMovement then
            UPD(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            getgenv()._CEN_SLD_ACTIVE = false -- UNLOCK GLOBAL DRAG
            DRAG = false
        end
    end)

    function SLD:SET(v)
        self.VAL = v
        UPD(v, true)
    end

    return SLD
end

local function ADD_CLR(PAG, TXT, DEF, CB)
    local CLR = { VAL = DEF or Color3.new(1, 1, 1), ALPHA = 0 }
    
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    RND(FRM, 8)
    STR(FRM, CFG.COL.GRY, 1)

    local LBL = Instance.new("TextLabel", FRM)
    LBL.Size = UDim2.new(1, -50, 1, 0)
    LBL.Position = UDim2.new(0, 10, 0, 0)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.TXT
    LBL.Font = Enum.Font.GothamBold
    LBL.TextSize = 13
    LBL.TextXAlignment = Enum.TextXAlignment.Left

    local BTN = Instance.new("TextButton", FRM)
    BTN.Size = UDim2.new(0, 24, 0, 24)
    BTN.Position = UDim2.new(1, -34, 0.5, -12)
    BTN.BackgroundColor3 = CLR.VAL
    BTN.Text = ""
    RND(BTN, 6)
    STR(BTN, Color3.new(1,1,1), 1).Transparency = 0.5

    BTN.MouseButton1Click:Connect(function()
        PICKER_DATA:OPEN_PICKER(CLR.VAL, CLR.ALPHA, BTN.AbsolutePosition, function(new_clr, new_alpha)
            CLR.VAL = new_clr
            CLR.ALPHA = new_alpha
            BTN.BackgroundColor3 = new_clr
            if CB then CB(new_clr, new_alpha) end
        end)
    end)

    return CLR
end

-- [ ESP ENGINE ]
local ESP_HOLDER = Instance.new("ScreenGui")
ESP_HOLDER.Name = "ESP_HOLDER"
ESP_HOLDER.IgnoreGuiInset = true
ESP_HOLDER.DisplayOrder = -1100
ESP_HOLDER.Parent = game:GetService("CoreGui")

local CACHE = {}

local function MK_ESP(p)
    local E = {
        FRM = Instance.new("Frame", ESP_HOLDER),
        BOX = Instance.new("Frame"),
        BOX_GRAD = Instance.new("UIGradient"),
        OUT = Instance.new("UIStroke"),
        NAME = Instance.new("TextLabel"),
        DIST = Instance.new("TextLabel"),
        WEAP = Instance.new("TextLabel"),
        BAR_BG = Instance.new("Frame"),
        BAR_FL = Instance.new("Frame"),
        BAR_GRAD = Instance.new("UIGradient"),
        HEALTH_TXT = Instance.new("TextLabel"),
        CORNERS = {},
        CHAM = nil
    }
    
    E.FRM.BackgroundTransparency = 1
    E.FRM.Size = UDim2.new(1, 0, 1, 0)
    E.FRM.ZIndex = 0
    
    E.BOX.Parent = E.FRM
    E.BOX.BackgroundTransparency = 1
    E.BOX.BorderSizePixel = 0
    
    E.BOX_GRAD.Parent = E.BOX
    E.BOX_GRAD.Enabled = false
    
    E.OUT.Parent = E.BOX
    E.OUT.Color = Color3.new(1,1,1)
    E.OUT.Thickness = 1.5
    
    local function MK_C(parent)
        local f = Instance.new("Frame", parent)
        f.BorderSizePixel = 0
        STR(f, Color3.new(0,0,0), 1).Transparency = 0.5
        return f
    end

    for i = 1, 8 do
        E.CORNERS[i] = MK_C(E.FRM)
    end
    
    local function _SAFE_FONT(lbl, sz)
        if typeof(ESP_CFG.Font) == "Font" then
            lbl.FontFace = ESP_CFG.Font
        else
            lbl.Font = (typeof(ESP_CFG.Font) == "EnumItem") and ESP_CFG.Font or Enum.Font.GothamBold
        end
        lbl.TextSize = sz or ESP_CFG.FontSize
    end

    E.NAME.Parent = E.FRM
    E.NAME.BackgroundTransparency = 1
    E.NAME.TextColor3 = Color3.new(1,1,1)
    _SAFE_FONT(E.NAME, ESP_CFG.FontSize)
    E.NAME.TextStrokeTransparency = 0.5
    E.NAME.TextYAlignment = Enum.TextYAlignment.Bottom
    
    E.DIST.Parent = E.FRM
    E.DIST.BackgroundTransparency = 1
    E.DIST.TextColor3 = Color3.new(1,1,1)
    _SAFE_FONT(E.DIST, ESP_CFG.FontSize - 1)
    E.DIST.TextStrokeTransparency = 0.5
    E.DIST.TextYAlignment = Enum.TextYAlignment.Top

    E.WEAP.Parent = E.FRM
    E.WEAP.BackgroundTransparency = 1
    E.WEAP.TextColor3 = Color3.new(1,1,1)
    _SAFE_FONT(E.WEAP, ESP_CFG.FontSize - 1)
    E.WEAP.TextStrokeTransparency = 0.5
    E.WEAP.TextYAlignment = Enum.TextYAlignment.Top
    
    E.BAR_BG.Parent = E.FRM
    E.BAR_BG.BackgroundColor3 = Color3.new(0,0,0)
    E.BAR_BG.BackgroundTransparency = 0.5
    E.BAR_BG.BorderSizePixel = 0

    E.BAR_FL.Parent = E.BAR_BG
    E.BAR_FL.BackgroundColor3 = Color3.new(1, 1, 1)
    E.BAR_FL.BorderSizePixel = 0
    
    E.BAR_GRAD.Parent = E.BAR_FL
    E.BAR_GRAD.Rotation = 90
    E.BAR_GRAD.Enabled = false

    E.HEALTH_TXT.Parent = E.FRM
    E.HEALTH_TXT.BackgroundTransparency = 1
    E.HEALTH_TXT.TextColor3 = Color3.new(1,1,1)
    _SAFE_FONT(E.HEALTH_TXT, ESP_CFG.FontSize - 1)
    E.HEALTH_TXT.TextStrokeTransparency = 0.5
    E.HEALTH_TXT.TextStrokeTransparency = 0.5
    E.HEALTH_TXT.TextXAlignment = Enum.TextXAlignment.Center
    
    CACHE[p] = E
    return E
end

local function UPD_ESP()
    for _, p in pairs(PLRS:GetPlayers()) do
        pcall(function()
            if p == LPLR then return end
            local E = CACHE[p] or MK_ESP(p)
            local C = p.Character
            
            -- Dynamic cleanup if character is missing
            if not C then
                 if E.CHAM then E.CHAM:Destroy(); E.CHAM = nil end
                 E.FRM.Visible = false
                 return
            end

            local H = C:FindFirstChild("HumanoidRootPart")
            local HUM = C:FindFirstChildOfClass("Humanoid")
            
            -- Chams Logic (Highly Optimized Caching)
            if C and HUM and HUM.Health > 0 then
                if ESP_CFG.Chams.Enabled then
                    if not E.CHAM or E.CHAM.Parent ~= C then
                        if E.CHAM then pcall(function() E.CHAM:Destroy() end) end
                        E.CHAM = Instance.new("Highlight")
                        E.CHAM.Name = "CEN_CHAM"
                        E.CHAM.Adornee = C
                        E.CHAM.Parent = C
                        E.CHAM.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    
                    E.CHAM.FillColor = ESP_CFG.Chams.Color1
                    E.CHAM.OutlineColor = ESP_CFG.Chams.Color2
                    E.CHAM.OutlineTransparency = 0
                    
                    if ESP_CFG.Chams.Thermal then
                        E.CHAM.FillTransparency = 0.6 + math.sin(tick() * 5) * 0.3
                    else
                        E.CHAM.FillTransparency = 0.5
                    end
                elseif E.CHAM then
                    E.CHAM:Destroy()
                    E.CHAM = nil
                end
            else
                if E.CHAM then E.CHAM:Destroy(); E.CHAM = nil end
            end

            -- 2D Visuals Logic
            if ESP_CFG.Enabled and H and HUM and HUM.Health > 0 then
                local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(H.Position)
                local dist = (workspace.CurrentCamera.CFrame.Position - H.Position).Magnitude
                
                if vis and dist <= ESP_CFG.MaxDist then
                    E.FRM.Visible = true
                    
                    local s_y = (H.Size.Y * 2 * workspace.CurrentCamera.ViewportSize.Y) / (pos.Z * 2)
                    local s_x = s_y * 0.75
                    local x, y = pos.X - s_x/2, pos.Y - s_y/2
                    
                    -- Bounding & Corner Boxes
                    local box_en = ESP_CFG.Boxes.Enabled
                    local corn_en = ESP_CFG.Corners.Enabled
                    local fill_en = ESP_CFG.Filled.Enabled
                    
                    E.BOX.Visible = (box_en or fill_en)
                    E.BOX.Position = UDim2.new(0, x, 0, y)
                    E.BOX.Size = UDim2.new(0, s_x, 0, s_y)
                    
                    E.OUT.Enabled = box_en and not corn_en
                    E.OUT.Color = ESP_CFG.Boxes.Color
                    
                    E.BOX.BackgroundTransparency = fill_en and (1 - ESP_CFG.Filled.Alpha) or 1
                    E.BOX_GRAD.Enabled = fill_en
                    E.BOX_GRAD.Color = ColorSequence.new(ESP_CFG.Filled.Color1, ESP_CFG.Filled.Color2)
                    
                    if ESP_CFG.Boxes.Animated and (fill_en or box_en) then
                        E.BOX_GRAD.Rotation = (tick() * 100) % 360
                    end

                    -- Corners
                    for i = 1, 8 do E.CORNERS[i].Visible = corn_en end
                    if corn_en then
                        local clr = ESP_CFG.Corners.Color
                        local thk = 1.5
                        local len = s_x / 4
                        -- Top Left
                        E.CORNERS[1].Position = UDim2.new(0, x, 0, y); E.CORNERS[1].Size = UDim2.new(0, len, 0, thk)
                        E.CORNERS[2].Position = UDim2.new(0, x, 0, y); E.CORNERS[2].Size = UDim2.new(0, thk, 0, len)
                        -- Top Right
                        E.CORNERS[3].Position = UDim2.new(0, x + s_x - len, 0, y); E.CORNERS[3].Size = UDim2.new(0, len, 0, thk)
                        E.CORNERS[4].Position = UDim2.new(0, x + s_x - thk, 0, y); E.CORNERS[4].Size = UDim2.new(0, thk, 0, len)
                        -- Bottom Left
                        E.CORNERS[5].Position = UDim2.new(0, x, 0, y + s_y - thk); E.CORNERS[5].Size = UDim2.new(0, len, 0, thk)
                        E.CORNERS[6].Position = UDim2.new(0, x, 0, y + s_y - len); E.CORNERS[6].Size = UDim2.new(0, thk, 0, len)
                        -- Bottom Right
                        E.CORNERS[7].Position = UDim2.new(0, x + s_x - len, 0, y + s_y - thk); E.CORNERS[7].Size = UDim2.new(0, len, 0, thk)
                        E.CORNERS[8].Position = UDim2.new(0, x + s_x - thk, 0, y + s_y - len); E.CORNERS[8].Size = UDim2.new(0, thk, 0, len)
                        for i = 1, 8 do E.CORNERS[i].BackgroundColor3 = clr end
                    end
                    
                    local function SET_F(lbl, sz)
                        if typeof(ESP_CFG.Font) == "Font" then
                            lbl.FontFace = ESP_CFG.Font
                        else
                            lbl.Font = ESP_CFG.Font
                        end
                        lbl.TextSize = sz or ESP_CFG.FontSize
                    end

                    -- Name
                    E.NAME.Visible = ESP_CFG.Names.Enabled
                    E.NAME.Position = UDim2.new(0, x - 50, 0, y - (ESP_CFG.FontSize + 4))
                    E.NAME.Size = UDim2.new(0, s_x + 100, 0, ESP_CFG.FontSize)
                    E.NAME.Text = p.Name
                    E.NAME.TextColor3 = ESP_CFG.Names.Color
                    SET_F(E.NAME)

                    -- Health
                    local hp_per = math.clamp(HUM.Health / HUM.MaxHealth, 0, 1)
                    E.BAR_BG.Visible = ESP_CFG.Health.Bar
                    E.BAR_BG.Position = UDim2.new(0, x - 6, 0, y)
                    E.BAR_BG.Size = UDim2.new(0, 3, 0, s_y)
                    E.BAR_FL.Size = UDim2.new(1, 0, hp_per, 0)
                    E.BAR_FL.Position = UDim2.new(0, 0, 1 - hp_per, 0)
                    
                    if ESP_CFG.Health.Dynamic then
                        E.BAR_FL.BackgroundColor3 = Color3.fromHSV(hp_per * 0.35, 1, 1)
                        E.BAR_GRAD.Enabled = false
                    elseif ESP_CFG.Health.Bar then
                        E.BAR_FL.BackgroundColor3 = Color3.new(1, 1, 1)
                        E.BAR_GRAD.Enabled = true
                        E.BAR_GRAD.Transparency = NumberSequence.new(0)
                        E.BAR_GRAD.Color = ColorSequence.new(ESP_CFG.Health.Color1, ESP_CFG.Health.Color2)
                    else
                        E.BAR_GRAD.Enabled = false
                    end

                    E.HEALTH_TXT.Visible = ESP_CFG.Health.Text
                    E.HEALTH_TXT.Position = UDim2.new(0, x - 40, 0, y + s_y * (1-hp_per) - 10)
                    E.HEALTH_TXT.Size = UDim2.new(0, 30, 0, 12)
                    E.HEALTH_TXT.Text = math.floor(HUM.Health)
                    SET_F(E.HEALTH_TXT, ESP_CFG.FontSize - 1)
                    
                    -- Weapon & Dist
                    E.WEAP.Visible = ESP_CFG.Weapons.Enabled
                    local tool = C:FindFirstChildOfClass("Tool")
                    E.WEAP.Text = tool and tool.Name or "None"
                    E.WEAP.Position = UDim2.new(0, x - 50, 0, y + s_y + 2)
                    E.WEAP.Size = UDim2.new(0, s_x + 100, 0, ESP_CFG.FontSize)
                    E.WEAP.TextColor3 = ESP_CFG.Weapons.Color
                    SET_F(E.WEAP, ESP_CFG.FontSize - 1)

                    E.DIST.Visible = ESP_CFG.Dist.Enabled
                    E.DIST.Position = UDim2.new(0, x - 50, 0, y + s_y + (ESP_CFG.Weapons.Enabled and ESP_CFG.FontSize + 2 or 2))
                    E.DIST.Size = UDim2.new(0, s_x + 100, 0, ESP_CFG.FontSize)
                    E.DIST.Text = math.floor(dist) .. "st"
                    E.DIST.TextColor3 = ESP_CFG.Dist.Color
                    SET_F(E.DIST, ESP_CFG.FontSize - 1)
                else
                    E.FRM.Visible = false
                end
            else
                if E then 
                    E.FRM.Visible = false 
                end
            end
        end)
    end
end

RS.RenderStepped:Connect(UPD_ESP)

PLRS.PlayerRemoving:Connect(function(p)
    if CACHE[p] then
        CACHE[p].FRM:Destroy()
        CACHE[p] = nil
    end
end)

-- [ TOOL CHARMS ]
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    --====================================================
    -- SETTINGS
    --====================================================
    local TRANSPARENCY_MIN   = 0.18
    local TRANSPARENCY_MAX   = 0.42
    local ANIM_SPEED         = 2.4
    local USE_HIGHLIGHT      = true
    local ONLY_WHEN_EQUIPPED = true
    local ONLY_HANDLE = false

    --====================================================
    -- STATE
    --====================================================
    local trackedTools = {}
    local partCache = {}
    local highlightCache = {}
    local isEnabledCache = false

    --====================================================
    -- HELPERS
    --====================================================
    local function isToolEquipped(tool)
        return tool and tool.Parent == LocalPlayer.Character
    end

    local function isValidToolPart(obj)
        if not obj:IsA("BasePart") then
            return false
        end
        if ONLY_HANDLE then
            return obj.Name == "Handle"
        end
        return true
    end

    local function getParts(tool)
        local parts = {}
        for _, obj in ipairs(tool:GetDescendants()) do
            if isValidToolPart(obj) then
                table.insert(parts, obj)
            end
        end
        return parts
    end

    local function rememberOriginal(part)
        if partCache[part] then
            return
        end
        partCache[part] = {
            Material = part.Material,
            Color = part.Color,
            LocalTransparencyModifier = part.LocalTransparencyModifier,
        }
    end

    local function restorePart(part)
        local old = partCache[part]
        if not old or not part or not part.Parent then
            return
        end
        part.Material = old.Material
        part.Color = old.Color
        part.LocalTransparencyModifier = old.LocalTransparencyModifier
        partCache[part] = nil
    end

    local function removeHighlight(tool)
        local h = highlightCache[tool]
        if h then
            h:Destroy()
            highlightCache[tool] = nil
        end
    end
    
    local function restoreTool(tool)
        for _, part in ipairs(getParts(tool)) do
            restorePart(part)
        end
        removeHighlight(tool)
    end

    local function createHighlight(tool)
        if not USE_HIGHLIGHT then
            return
        end
        local existing = highlightCache[tool]
        if existing and existing.Parent then
            return
        end
        local h = Instance.new("Highlight")
        h.Name = "_ToolCharmHighlight"
        h.DepthMode = Enum.HighlightDepthMode.Occluded
        h.FillColor = ESP_CFG.ToolCharms.Color1
        h.FillTransparency = 0.78
        h.OutlineColor = ESP_CFG.ToolCharms.Color2
        h.OutlineTransparency = 0.2
        h.Parent = tool
        highlightCache[tool] = h
    end

    local function applyVisual(part, t)
        if not part or not part.Parent then
            return
        end
        rememberOriginal(part)
        local wave = (math.sin(t * ANIM_SPEED) + 1) * 0.5
        local wave2 = (math.sin((t * ANIM_SPEED * 1.7) + 1.3) + 1) * 0.5
        local transparency = TRANSPARENCY_MIN + (TRANSPARENCY_MAX - TRANSPARENCY_MIN) * wave
        local color = ESP_CFG.ToolCharms.Color1:Lerp(ESP_CFG.ToolCharms.Color2, wave2)
        part.Material = Enum.Material.ForceField
        part.Color = color
        part.LocalTransparencyModifier = transparency
    end

    local function setupTool(tool)
        if not tool:IsA("Tool") or trackedTools[tool] then
            return
        end
        trackedTools[tool] = true
        tool.AncestryChanged:Connect(function(_, parent)
            if not parent then
                restoreTool(tool)
                trackedTools[tool] = nil
            end
        end)
        tool.DescendantAdded:Connect(function(obj)
            if isValidToolPart(obj) then
                rememberOriginal(obj)
            end
        end)
        tool.Unequipped:Connect(function()
            if ONLY_WHEN_EQUIPPED then
                restoreTool(tool)
            end
        end)
    end

    local function hookCharacter(character)
        for _, obj in ipairs(character:GetChildren()) do
            if obj:IsA("Tool") then
                setupTool(obj)
            end
        end
        character.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                setupTool(obj)
            end
        end)
    end

    local function hookBackpack()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        for _, obj in ipairs(backpack:GetChildren()) do
            if obj:IsA("Tool") then
                setupTool(obj)
            end
        end
        backpack.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                setupTool(obj)
            end
        end)
    end

    --====================================================
    -- START
    --====================================================
    if LocalPlayer.Character then
        hookCharacter(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(hookCharacter)
    hookBackpack()

    RunService.RenderStepped:Connect(function()
        if not ESP_CFG.ToolCharms.Enabled then
            if isEnabledCache then -- only restore if it was just disabled
                for tool in pairs(trackedTools) do
                    if tool and tool.Parent then
                        restoreTool(tool)
                    end
                end
                isEnabledCache = false
            end
            return
        end
        isEnabledCache = true

        local character = LocalPlayer.Character
        if not character then
            return
        end
        local now = tick()
        for tool in pairs(trackedTools) do
            if tool and tool.Parent then
                local shouldShow = true
                if ONLY_WHEN_EQUIPPED then
                    shouldShow = isToolEquipped(tool)
                end
                if shouldShow then
                    createHighlight(tool)
                    for _, part in ipairs(getParts(tool)) do
                        applyVisual(part, now)
                    end
                    local h = highlightCache[tool]
                    if h then
                        local glow = (math.sin(now * ANIM_SPEED * 1.5) + 1) * 0.5
                        h.FillColor = ESP_CFG.ToolCharms.Color1:Lerp(ESP_CFG.ToolCharms.Color2, glow)
                        h.OutlineColor = ESP_CFG.ToolCharms.Color2:Lerp(ESP_CFG.ToolCharms.Color1, glow)
                        h.FillTransparency = 0.78 + (glow * 0.08)
                        h.OutlineTransparency = 0.14 + (glow * 0.12)
                    end
                else
                    restoreTool(tool)
                end
            end
        end
    end)
end


-- [ SILENT AIM TRACKING & VISUALS ]
local SilentTarget = nil
local Mouse = LPLR:GetMouse()
local Camera = workspace.CurrentCamera

local SILENT_SNAP_OUT = Drawing.new("Line")
SILENT_SNAP_OUT.Visible = false
SILENT_SNAP_OUT.Color = Color3.new(0, 0, 0)
SILENT_SNAP_OUT.Thickness = 3
SILENT_SNAP_OUT.Transparency = 1
pcall(function() SILENT_SNAP_OUT.ZIndex = 1 end)

local SILENT_SNAP = Drawing.new("Line")
SILENT_SNAP.Visible = false
SILENT_SNAP.Color = Color3.new(1, 1, 1)
SILENT_SNAP.Thickness = 1
SILENT_SNAP.Transparency = 1
pcall(function() SILENT_SNAP.ZIndex = 2 end)

local function GetClosestPlayerToMouseSilent()
    if not ESP_CFG.SilentAim.Enabled then return nil end
    if ESP_CFG.SilentAim.Keybind and not UIS:IsKeyDown(ESP_CFG.SilentAim.Keybind) then return nil end
    
    local closest_player = nil
    local shortest_distance = 9e9
    local mouse_pos = UIS:GetMouseLocation()

    for _, p in ipairs(PLRS:GetPlayers()) do
        if p == LPLR then continue end
        local char = p.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")

        if hrp and hum and head and hum.Health > 0 then
            -- Distance Check vs LPLR
            local l_hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if l_hrp then
                local dist_3d = (hrp.Position - l_hrp.Position).Magnitude
                if dist_3d > ESP_CFG.MaxDist then continue end
            end

            local screen_pos, on_screen = Camera:WorldToViewportPoint(head.Position)
            if on_screen then
                local magnitude = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).Magnitude
                if magnitude < shortest_distance then
                    closest_player = p
                    shortest_distance = magnitude
                end
            end
        end
    end
    
    return closest_player
end

local function UPD_SILENT_AIM()
    SilentTarget = GetClosestPlayerToMouseSilent()

    if SilentTarget and SilentTarget.Character and SilentTarget.Character:FindFirstChild("Head") and ESP_CFG.SilentAim.Enabled and ESP_CFG.Snapline.Enabled then
        local head = SilentTarget.Character:FindFirstChild("Head")
        local screen_pos, on_screen = Camera:WorldToViewportPoint(head.Position)
        
        if on_screen and (not ESP_CFG.SilentAim.Keybind or UIS:IsKeyDown(ESP_CFG.SilentAim.Keybind)) then
            local mouse_pos = UIS:GetMouseLocation()
            
            SILENT_SNAP.Visible = true
            SILENT_SNAP.From = mouse_pos
            SILENT_SNAP.To = Vector2.new(screen_pos.X, screen_pos.Y)
            SILENT_SNAP.Color = ESP_CFG.Snapline.Color
            SILENT_SNAP.Thickness = ESP_CFG.Snapline.Thickness
            
            SILENT_SNAP_OUT.Visible = true
            SILENT_SNAP_OUT.From = mouse_pos
            SILENT_SNAP_OUT.To = Vector2.new(screen_pos.X, screen_pos.Y)
            SILENT_SNAP_OUT.Thickness = ESP_CFG.Snapline.Thickness + 2
        else
            SILENT_SNAP.Visible = false
            SILENT_SNAP_OUT.Visible = false
        end
    else
        SILENT_SNAP.Visible = false
        SILENT_SNAP_OUT.Visible = false
    end
end

RS.RenderStepped:Connect(UPD_SILENT_AIM)

-- [ SILENT AIM MODULE HOOKING ]
local ok, PH = pcall(require, game:GetService("ReplicatedStorage").Modules.ProjectileHandler)
if ok and PH then
    local originalSimulate = PH.SimulateProjectile

    PH.SimulateProjectile = function(self, gun, handle, settings, directions, firePoint, muzzle, vfx, visualize)
        -- Si está habilitado, tenemos un Target, la tecla está pulsada (si la hay) y es tabla directions
        if ESP_CFG.SilentAim.Enabled and SilentTarget and typeof(directions) == "table" and (not ESP_CFG.SilentAim.Keybind or UIS:IsKeyDown(ESP_CFG.SilentAim.Keybind)) then
            local targetChar = SilentTarget.Character
            local part = targetChar and (
                targetChar:FindFirstChild("Head") or
                targetChar:FindFirstChild("HumanoidRootPart")
            )
            
            if part then
                local origin
                if firePoint then
                    pcall(function()
                        if firePoint:IsA("Attachment") then
                            origin = firePoint.WorldPosition
                        elseif firePoint:IsA("BasePart") then
                            origin = firePoint.Position
                        end
                    end)
                end
                origin = origin or Camera.CFrame.Position

                local newDir = (part.Position - origin).Unit
                for i = 1, #directions do
                    directions[i] = newDir
                end
            end
        end

        return originalSimulate(self, gun, handle, settings, directions, firePoint, muzzle, vfx, visualize)
    end
else
    warn("[SilentAim] No se pudo requerir ProjectileHandler. El juego podría no estar usándolo.")
end

-- [ WORLD VISUALS ]
-- Logic handled via UI Toggles directly

local function ADD_CRD(PAG, TIT, DES, CB)
    local CRD = Instance.new("Frame", PAG)
    CRD.BackgroundColor3 = CFG.COL.BG
    CRD.BackgroundTransparency = 0.6
    RND(CRD, 10)
    STR(CRD, CFG.COL.ACC, 1).Transparency = 0.8

    local T = Instance.new("TextLabel", CRD)
    T.Text = TIT
    T.Size = UDim2.new(1, -10, 0, 20)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.TextColor3 = CFG.COL.ACC
    T.Font = Enum.Font.GothamBold
    T.TextSize = 14
    T.TextXAlignment = Enum.TextXAlignment.Left

    local D = Instance.new("TextLabel", CRD)
    D.Text = DES
    D.Size = UDim2.new(1, -10, 0, 40)
    D.Position = UDim2.new(0, 10, 0, 25)
    D.BackgroundTransparency = 1
    D.TextColor3 = CFG.COL.TXT
    D.Font = Enum.Font.Gotham
    D.TextSize = 11
    D.TextWrapped = true
    D.TextXAlignment = Enum.TextXAlignment.Left
    D.TextYAlignment = Enum.TextYAlignment.Top

    local B = Instance.new("TextButton", CRD)
    B.Text = TIT:find("BUY") and "PURCHASE" or "ACTIVATE"
    B.Size = UDim2.new(1, -20, 0, 25)
    B.Position = UDim2.new(0, 10, 1, -30)
    B.BackgroundColor3 = CFG.COL.BG
    B.BackgroundTransparency = 0.8
    B.TextColor3 = CFG.COL.ACC
    B.Font = Enum.Font.GothamBold
    B.TextSize = 11
    B.AutoButtonColor = false
    RND(B, 8)
    
    local B_STR = STR(B, CFG.COL.ACC, 1.2)
    B_STR.Transparency = 0.7

    B.MouseEnter:Connect(function()
        TWN(B, {BackgroundTransparency = 0.6, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0, 0, 0)}, 0.2)
        TWN(B_STR, {Transparency = 0.4}, 0.2)
    end)
    B.MouseLeave:Connect(function()
        TWN(B, {BackgroundTransparency = 0.8, BackgroundColor3 = CFG.COL.BG, TextColor3 = CFG.COL.ACC}, 0.2)
        TWN(B_STR, {Transparency = 0.7}, 0.2)
    end)

    B.MouseButton1Click:Connect(function()
        TWN(B, {TextSize = 10}, 0.1)
        task.wait(0.1)
        TWN(B, {TextSize = 11}, 0.1)
        if CB then CB() end
    end)

    return CRD
end

local function ADD_ESP_ROW(PAG, TXT, DEF_TGL, CB_TGL, CLRS)
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 30)
    FRM.BackgroundTransparency = 1
    
    local LBL = Instance.new("TextLabel", FRM)
    LBL.Size = UDim2.new(1, -70, 1, 0)
    LBL.Position = UDim2.new(0, 5, 0, 0)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.TXT
    LBL.Font = Enum.Font.GothamMedium
    LBL.TextSize = 13
    LBL.TextXAlignment = Enum.TextXAlignment.Left

    local RIGHT = Instance.new("Frame", FRM)
    RIGHT.Size = UDim2.new(0, 100, 1, 0)
    RIGHT.Position = UDim2.new(1, -100, 0, 0)
    RIGHT.BackgroundTransparency = 1
    local RL = Instance.new("UIListLayout", RIGHT)
    RL.FillDirection = Enum.FillDirection.Horizontal
    RL.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RL.VerticalAlignment = Enum.VerticalAlignment.Center
    RL.Padding = UDim.new(0, 8)

    if CLRS then
        for i, color_data in ipairs(CLRS) do
            local current_c = color_data
            local CBUT = Instance.new("TextButton", RIGHT)
            CBUT.Size = UDim2.new(0, 18, 0, 18)
            CBUT.BackgroundColor3 = current_c.VAL
            CBUT.Text = ""
            RND(CBUT, 5)
            STR(CBUT, CFG.COL.ACC, 1.2).Transparency = 0.7
            CBUT.MouseButton1Click:Connect(function()
                local mp = UIS:GetMouseLocation()
                PICKER_DATA:OPEN_PICKER(current_c.VAL, 0, mp, function(nc, na)
                    current_c.VAL = nc
                    CBUT.BackgroundColor3 = nc
                    if current_c.CB then current_c.CB(nc, na) end
                end)
            end)
        end
    end

    if CB_TGL then
        local BTN = Instance.new("TextButton", RIGHT)
        BTN.Size = UDim2.new(0, 32, 0, 16)
        BTN.BackgroundColor3 = DEF_TGL and CFG.COL.ACC or CFG.COL.GRY
        BTN.Text = ""
        RND(BTN, 8)
        local IND = Instance.new("Frame", BTN)
        IND.Size = UDim2.new(0, 12, 0, 12)
        IND.Position = DEF_TGL and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        IND.BackgroundColor3 = Color3.new(1, 1, 1)
        RND(IND, 6)
        local val = DEF_TGL
        BTN.MouseButton1Click:Connect(function()
            val = not val
            TWN(BTN, {BackgroundColor3 = val and CFG.COL.ACC or CFG.COL.GRY}, 0.2)
            TWN(IND, {Position = val and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
            if CB_TGL then CB_TGL(val) end
        end)
    end
end

local function ADD_SPLIT(PAG)
    local ROW = Instance.new("Frame", PAG)
    ROW.Size = UDim2.new(1, -10, 0, 35)
    ROW.BackgroundTransparency = 1

    local L = Instance.new("Frame", ROW)
    L.Size = UDim2.new(0.5, -2, 1, 0)
    L.Position = UDim2.new(0, 0, 0, 0)
    L.BackgroundTransparency = 1

    local R = Instance.new("Frame", ROW)
    R.Size = UDim2.new(0.5, -2, 1, 0)
    R.Position = UDim2.new(0.5, 2, 0, 0)
    R.BackgroundTransparency = 1

    return L, R, ROW
end

-- [ GUI ROOT ]
local SCR = Instance.new("ScreenGui")
_G.CENTRAL_GUI = SCR
SCR.Name = "CEN_V2"
SCR.ResetOnSpawn = false
SCR.DisplayOrder = 1000  -- Functional level, crosshair will be higher
SCR.IgnoreGuiInset = true
SCR.Parent = LPLR:WaitForChild("PlayerGui")

-- Aggressively raise ANY other GUI found in PlayerGui
local PG = LPLR:WaitForChild("PlayerGui")
local function RAISE_HUD(gui)
    if not gui:IsA("ScreenGui") or gui == _G.CENTRAL_GUI or gui == _G.CENTRAL_NOTIFS_REF then return end
    local n = gui.Name:lower()
    
    -- Filter out our own GUIs
    if n == "cen_v2" or n:find("esp_holder") or n:find("picker") or n:find("notif") or n:find("espholder") then return end
    
    -- Force specific target GUIs to the top
    if n == "gungui" or n:find("crosshair") or n:find("reticle") then
        gui.DisplayOrder = 2147483647
    elseif gui.DisplayOrder < 100 then
        gui.DisplayOrder = 100 -- Standard HUDs stay below our UI (1000)
    end
end

for _, g in ipairs(PG:GetChildren()) do RAISE_HUD(g) end
PG.ChildAdded:Connect(function(g) task.wait() RAISE_HUD(g) end)

task.spawn(function()
    while task.wait(1) do
        for _, g in ipairs(PG:GetChildren()) do
             RAISE_HUD(g)
        end
    end
end)

-- [ MAIN WINDOW ]
local MAIN = Instance.new("Frame", SCR)
MAIN.Name = "WIN"
MAIN.Size = UDim2.new(0, 700, 0, 565)
MAIN.Position = UDim2.new(0.5, -350, 0.5, -282)
MAIN.BackgroundColor3 = CFG.COL.BG
MAIN.BackgroundTransparency = 0.1
MAIN.BorderSizePixel = 0
MAIN.ClipsDescendants = true
RND(MAIN, 16)
STR(MAIN, CFG.COL.ACC, 1.5)
 
local MODAL = Instance.new("TextButton", MAIN)
MODAL.Size = UDim2.new(0, 1, 0, 1)
MODAL.BackgroundTransparency = 1
MODAL.Text = ""
MODAL.Modal = true

-- [ WINDOW DRAG LAYER ]
local DRG = Instance.new("Frame", MAIN)
DRG.Name = "DragLayer"
DRG.Size = UDim2.new(1, 0, 1, 0)
DRG.BackgroundTransparency = 1
DRG.ZIndex = 0 -- Keep behind content
DRG.Active = false -- Don't block, just listen

local DG_ON, DG_STR, DG_POS, DG_INP
DRG.InputBegan:Connect(function(I)
    if getgenv()._CEN_SLD_ACTIVE then return end -- Block if slider is active
    if (I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch) then
        DG_ON  = true
        DG_STR = I.Position
        DG_POS = MAIN.Position
        DG_INP = I
        I.Changed:Connect(function()
            if I.UserInputState == Enum.UserInputState.End then DG_ON = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(I)
    local IS_MOUSE = I.UserInputType == Enum.UserInputType.MouseMovement
    local IS_TOUCH = I.UserInputType == Enum.UserInputType.Touch
    if DG_ON and (IS_MOUSE or (IS_TOUCH and I == DG_INP)) then
        local DEL = I.Position - DG_STR
        MAIN.Position = UDim2.new(
            DG_POS.X.Scale, DG_POS.X.Offset + DEL.X,
            DG_POS.Y.Scale, DG_POS.Y.Offset + DEL.Y
        )
    end
end)

-- [ BACKGROUND IMAGE ]
local BG = Instance.new("ImageLabel", MAIN)
BG.Size = UDim2.new(1, 0, 1, 0)
BG.Image = CFG.IMG
BG.ScaleType = Enum.ScaleType.Crop
BG.ImageTransparency = 0.8
BG.BackgroundTransparency = 1
BG.ZIndex = -1 -- Furthest back
RND(BG, 16)

-- [ TITLE BAR / TRAFFIC LIGHTS ]
local BAR = Instance.new("Frame", MAIN)
BAR.Name = "BAR"
BAR.Size = UDim2.new(1, 0, 0, 40)
BAR.BackgroundTransparency = 1
BAR.ZIndex = 20

local function MK_BTN(COL, POS)
    local BTN = Instance.new("TextButton", BAR)
    BTN.Size = UDim2.new(0, 14, 0, 14)
    BTN.Position = POS
    BTN.BackgroundColor3 = COL
    BTN.Text = ""
    BTN.AutoButtonColor = false
    BTN.ZIndex = 21
    RND(BTN, 10)

    local OVR = Instance.new("Frame", BTN)
    OVR.Size = UDim2.new(1, 0, 1, 0)
    OVR.BackgroundColor3 = Color3.new(1, 1, 1)
    OVR.BackgroundTransparency = 1
    RND(OVR, 10)

    BTN.MouseEnter:Connect(function() TWN(OVR, {BackgroundTransparency = 0.8}, 0.2) end)
    BTN.MouseLeave:Connect(function() TWN(OVR, {BackgroundTransparency = 1}, 0.2) end)

    return BTN
end

local B_CLS = MK_BTN(CFG.COL.RED, UDim2.new(0, 15, 0.5, -7))
local B_MIN = MK_BTN(CFG.COL.YEL, UDim2.new(0, 35, 0.5, -7))

-- Weapon mods state — declared here so close handler can access it
local WM      = { INF_AMMO = false, NO_RECOIL = false, RAPID_FIRE = false }
local WM_RATE = 0.01

-- Movement state — declared here so close handler can access it
_G.EXE.FLY_ON = false
_G.EXE.SPD_ON = false
_G.EXE.JMP_ON = false

-- [ PANIC BUTTON / TOTAL BLACKOUT ]
local function PANIC()
    -- 1. Stop all Auto Farm threads immediately
    for k, v in pairs(_G.EXE) do
        if k:find("_RUNNING") or k:find("_ON") then
            _G.EXE[k] = false
        elseif k:find("_THREAD") and v then
            pcall(task.cancel, v)
            _G.EXE[k] = nil
        end
    end
    
    -- Legacy locals support (if any still exist)
    if _G.EXE.FARM_RUNNING ~= nil then _G.EXE.FARM_RUNNING = false end
    if _G.EXE.FARM_THREAD  ~= nil then pcall(task.cancel, _G.EXE.FARM_THREAD)  _G.EXE.FARM_THREAD  = nil end

    -- Stop Burger Farm
    if _G.BF_STOP then pcall(_G.BF_STOP) end

    -- 2. Disable Visuals / ESP
    if ESP_CFG then
        ESP_CFG.Enabled = false
        if ESP_CFG.SilentAim then ESP_CFG.SilentAim.Enabled = false end
    end

    -- 3. Reset Lighting (Fullbright)
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 1
        lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end)

    -- 4. Clean Character Movement / Speed
    pcall(function()
        local char = LPLR.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        -- Reset Speed
        if hum then hum.WalkSpeed = 16 end
        
        -- Stop Fly
        if hrp then
            local bv = hrp:FindFirstChildOfClass("BodyVelocity")
            local bg = hrp:FindFirstChildOfClass("BodyGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            hrp.Anchored = false
            if hum then hum.PlatformStand = false end
        end
        
        -- Car Fly cleanup
        if hum and hum.SeatPart then
            local veh = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
            if veh then
                local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("VehicleSeat") or veh:FindFirstChildWhichIsA("BasePart")
                if root then
                    local bv = root:FindFirstChildOfClass("BodyVelocity")
                    local bg = root:FindFirstChildOfClass("BodyGyro")
                    if bv then bv:Destroy() end
                    if bg then bg:Destroy() end
                end
            end
        end
    end)

    -- 5. Turn off Weapon Mods
    if WM then
        WM.INF_AMMO   = false
        WM.NO_RECOIL  = false
        WM.RAPID_FIRE = false
    end

    -- 6. Disconnect Keybinds
    if _G.CEN_BINDS then
        for _, c in ipairs(_G.CEN_BINDS) do
            if c then pcall(function() c:Disconnect() end) end
        end
        _G.CEN_BINDS = nil
    end

    _G.CENTRAL_LOADED = false
end

-- Close
B_CLS.MouseButton1Click:Connect(function()
    PANIC()
    SCR:Destroy()
end)

-- Minimize
local IS_MIN  = false
local MIN_DEB = false
local OLD_SZ  = UDim2.new(0, 0, 0, 0)

B_MIN.MouseButton1Click:Connect(function()
    if MIN_DEB then return end
    MIN_DEB = true

    IS_MIN = not IS_MIN
    local TCON = MAIN:FindFirstChild("TABS")
    local PCON = MAIN:FindFirstChild("PGS")
    local RSZ  = MAIN:FindFirstChild("RSZ_HANDLE")

    if IS_MIN then
        OLD_SZ = MAIN.Size
        if TCON then TCON.Visible = false end
        if PCON then PCON.Visible = false end
        if RSZ  then RSZ.Visible  = false end
        TWN(MAIN, {Size = UDim2.new(0, 220, 0, 40), BackgroundTransparency = 0.2})
        task.wait(0.35)
    else
        TWN(MAIN, {Size = OLD_SZ, BackgroundTransparency = 0.1})
        task.wait(0.35)
        if TCON then TCON.Visible = true end
        if PCON then PCON.Visible = true end
        if RSZ  then RSZ.Visible  = true end
    end

    task.wait(0.1)
    MIN_DEB = false
end)

-- [ TAB BAR ]
local TCON = Instance.new("Frame", MAIN)
TCON.Name = "TABS"
TCON.Size = UDim2.new(1, -140, 0, 35)
TCON.Position = UDim2.new(0.5, 0, 0, 10)
TCON.AnchorPoint = Vector2.new(0.5, 0)
TCON.BackgroundColor3 = CFG.COL.BG
TCON.BackgroundTransparency = 0.4
TCON.ZIndex = 10
RND(TCON, 20)
STR(TCON, CFG.COL.ACC, 1).Transparency = 0.8

local TLAY = Instance.new("UIListLayout", TCON)
TLAY.FillDirection = Enum.FillDirection.Horizontal
TLAY.HorizontalAlignment = Enum.HorizontalAlignment.Center
TLAY.VerticalAlignment = Enum.VerticalAlignment.Center
TLAY.Padding = UDim.new(0.02, 0)

-- [ PAGE CONTAINER ]
local PCON = Instance.new("Frame", MAIN)
PCON.Name = "PGS"
PCON.Size = UDim2.new(1, -20, 1, -60)
PCON.Position = UDim2.new(0, 10, 0, 55)
PCON.BackgroundTransparency = 1
PCON.ClipsDescendants = true
PCON.ZIndex = 5

local CUR_BTN = nil
local CUR_PAG = nil

local function MK_TAB(TXT)
    local BTN = Instance.new("TextButton", TCON)
    BTN.Size = UDim2.new(0.18, 0, 0.8, 0)
    BTN.BackgroundTransparency = 1
    BTN.Text = TXT
    BTN.TextColor3 = CFG.COL.GRY
    BTN.Font = Enum.Font.GothamBold
    BTN.TextScaled = true
    BTN.TextWrapped = true
    RND(BTN, 12)

    local TSC = Instance.new("UITextSizeConstraint", BTN)
    TSC.MaxTextSize = 12
    TSC.MinTextSize = 8

    local PAG = Instance.new("ScrollingFrame", PCON)
    PAG.Size = UDim2.new(1, 0, 1, 0)
    PAG.BackgroundTransparency = 1
    PAG.BorderSizePixel = 0
    PAG.Visible = false
    PAG.ScrollBarThickness = 2
    PAG.ScrollBarImageColor3 = CFG.COL.ACC
    PAG.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local LST = Instance.new("UIListLayout", PAG)
    LST.Padding = UDim.new(0, 8)
    LST.HorizontalAlignment = Enum.HorizontalAlignment.Center
    LST.SortOrder = Enum.SortOrder.LayoutOrder

    local PAD = Instance.new("UIPadding", PAG)
    PAD.PaddingTop    = UDim.new(0, 5)
    PAD.PaddingLeft   = UDim.new(0, 5)
    PAD.PaddingRight  = UDim.new(0, 5)
    PAD.PaddingBottom = UDim.new(0, 5)

    BTN.MouseButton1Click:Connect(function()
        if CUR_BTN == BTN then return end

        if CUR_BTN then
            TWN(CUR_BTN, {TextColor3 = CFG.COL.GRY, BackgroundTransparency = 1})
        end
        if CUR_PAG then
            CUR_PAG.Visible = false
        end

        CUR_BTN = BTN
        CUR_PAG = PAG

        TWN(BTN, {
            TextColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0,
            BackgroundColor3 = CFG.COL.ACC
        })
        PAG.Visible = true
        PAG.Position = UDim2.new(0, 10, 0, 0)
        TWN(PAG, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    end)

    return PAG, BTN
end

-- [ TABS ]
local P_HOM, B_HOM = MK_TAB("HOME")
local P_FRM, B_FRM = MK_TAB("FARM")
local P_VIS, B_VIS = MK_TAB("VISUAL")
local P_MSC, B_MSC = MK_TAB("MISC")
local P_SET, B_SET = MK_TAB("CONFIG")

-- Two-column row wrapper for FARM cards
-- Usage: local COL_L, COL_R = FARM_ROW()
-- Each card goes into COL_L or COL_R
local function FARM_ROW()
    local ROW = Instance.new("Frame", P_FRM)
    ROW.Size = UDim2.new(1, -10, 0, 0)
    ROW.AutomaticSize = Enum.AutomaticSize.Y
    ROW.BackgroundTransparency = 1
    ROW.BorderSizePixel = 0

    local L = Instance.new("Frame", ROW)
    L.Size = UDim2.new(0.5, -5, 0, 0)
    L.Position = UDim2.new(0, 0, 0, 0)
    L.AutomaticSize = Enum.AutomaticSize.Y
    L.BackgroundTransparency = 1
    L.BorderSizePixel = 0
    local LL = Instance.new("UIListLayout", L)
    LL.SortOrder = Enum.SortOrder.LayoutOrder
    LL.Padding = UDim.new(0, 8)

    local R = Instance.new("Frame", ROW)
    R.Size = UDim2.new(0.5, -5, 0, 0)
    R.Position = UDim2.new(0.5, 5, 0, 0)
    R.AutomaticSize = Enum.AutomaticSize.Y
    R.BackgroundTransparency = 1
    R.BorderSizePixel = 0
    local RL = Instance.new("UIListLayout", R)
    RL.SortOrder = Enum.SortOrder.LayoutOrder
    RL.Padding = UDim.new(0, 8)

    return L, R
end

-- ============================================================
--  PUEDES AÑADIR TU CONTENIDO AQUÍ DENTRO DE CADA PÁGINA:
--
--  ADD_LBL(P_HOM, "Texto de ejemplo")
--  ADD_BTN(P_HOM, "Botón", function() end)
--  ADD_INP(P_HOM, "Placeholder", "default", function(val) end)
--  ADD_DRP(P_HOM, "Dropdown", function(val) end)
--  ADD_CRD(P_HOM, "Título", "Descripción", function() end)
--  ADD_SPLIT(P_HOM) → devuelve L, R, ROW para dos columnas
-- ============================================================

-- ============================================================
--  HOME → TELEPORTS CARD  (half width, left side)
-- ============================================================
local LEFT_COL   -- forward declare so STORE_CARD can use it
local RIGHT_COL  -- forward declare so ACTIONS_CARD can use it
;(function()  -- register isolation: MISC right col
    local TP_LOCS = {
        { name = "🏴BLACK MARKET",   pos = Vector3.new(72.36,    38.57,  1092.94) },
        { name = "🍪BISCUITZ",       pos = Vector3.new(-311.33,  18.23,   179.82) },
        { name = "💳CARDS",          pos = Vector3.new(-330.12,  29.89,    31.50) },
        { name = "🏚️TRAP 1",         pos = Vector3.new(-79.15,   -6.40,  -278.94) },
        { name = "🏚️TRAP 2",         pos = Vector3.new(-310.97,  17.51,   333.10) },
        { name = "🏚️TRAP 3",         pos = Vector3.new(-123.23,   3.65,   807.66) },
        { name = "🏚️TRAP 4",         pos = Vector3.new(-1329.99,  3.80,  1382.98) },
        { name = "🎭MASK",           pos = Vector3.new(5.83,      4.20,   990.94) },
        { name = "🏠APT 1",          pos = Vector3.new(-64.50,   4.21,   275.71) },
        { name = "🏠APT 2",          pos = Vector3.new(-647.27,   5.43,  1243.49) },
        { name = "🏠APT 3",          pos = Vector3.new(153.25,    7.60,  1275.29) },
        { name = "🏠APT 4",          pos = Vector3.new(-954.08,   4.16,   939.26) },
        { name = "🏠APT 5",          pos = Vector3.new(358.61,    9.11,     7.91) },
        { name = "🏚️TRAP",           pos = Vector3.new(214.26,    4.10,  -121.55) },
        { name = "🎬CINEMA",         pos = Vector3.new(35.89,     4.30,  -129.71) },
        { name = "🎒SAKS",           pos = Vector3.new(59.02,     4.35,  -196.83) },
        { name = "🔫GUN SHOP 1",     pos = Vector3.new(3.74,      5.10,   -78.26) },
        { name = "🔫GUN SHOP 2",     pos = Vector3.new(-794.38,   5.08,  1501.85) },
        { name = "🥖DELI 1",         pos = Vector3.new(-411.77,   4.85,   444.61) },
        { name = "🥖DELI 2",         pos = Vector3.new(-49.31,    4.23,   -81.65) },
        { name = "🥖DELI 3",         pos = Vector3.new(-147.28,   4.35,  1196.95) },
        { name = "🥖DELI 4",         pos = Vector3.new(-931.42,   4.14,   639.29) },
        { name = "🏥HOSPITAL",       pos = Vector3.new(-138.34, 13.77, 933.28) },
        { name = "🖋️TATTOOS",        pos = Vector3.new(-72.88,    4.20,  -149.49) },
        { name = "🧼LAUNDROMAT",     pos = Vector3.new(-66.29,    4.30,  -192.87) },
        { name = "🏎️CAR DEALER",     pos = Vector3.new(-258.01,   4.60,   677.74) },
        { name = "🔧CHOP SHOP",      pos = Vector3.new(-427.63,   3.65,   624.76) },
        { name = "🔫GUN MODS",       pos = Vector3.new(-670.75,   4.36,   456.31) },
        { name = "🔪MELEE",          pos = Vector3.new(-122.12,  -16.44,  508.69) },
        { name = "📦WAREHOUSE",      pos = Vector3.new(-1179.00,  3.80,  1341.17) },
    }

    -- Outer row so card only takes left half
    local TP_ROW = Instance.new("Frame", P_HOM)
    TP_ROW.Size = UDim2.new(1, -10, 0, 0)
    TP_ROW.AutomaticSize = Enum.AutomaticSize.Y
    TP_ROW.BackgroundTransparency = 1
    TP_ROW.BorderSizePixel = 0
    TP_ROW.LayoutOrder = 1

    -- Left column — holds TP_CARD + STORE_CARD stacked
    LEFT_COL = Instance.new("Frame", TP_ROW)
    LEFT_COL.Size = UDim2.new(0.5, -5, 0, 0)
    LEFT_COL.Position = UDim2.new(0, 0, 0, 0)
    LEFT_COL.AutomaticSize = Enum.AutomaticSize.Y
    LEFT_COL.BackgroundTransparency = 1
    LEFT_COL.BorderSizePixel = 0

    local LEFT_LAY = Instance.new("UIListLayout", LEFT_COL)
    LEFT_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    LEFT_LAY.Padding = UDim.new(0, 8)

    -- Card — full width of LEFT_COL
    local TP_CARD = Instance.new("Frame", LEFT_COL)
    TP_CARD.Size = UDim2.new(1, 0, 0, 0)
    TP_CARD.LayoutOrder = 1
    TP_CARD.AutomaticSize = Enum.AutomaticSize.Y
    TP_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    TP_CARD.BackgroundTransparency = 0.2
    TP_CARD.BorderSizePixel = 0
    RND(TP_CARD, 12)
    STR(TP_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local TP_LAY = Instance.new("UIListLayout", TP_CARD)
    TP_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    TP_LAY.Padding = UDim.new(0, 8)

    local TP_PAD = Instance.new("UIPadding", TP_CARD)
    TP_PAD.PaddingTop    = UDim.new(0, 12)
    TP_PAD.PaddingBottom = UDim.new(0, 14)
    TP_PAD.PaddingLeft   = UDim.new(0, 12)
    TP_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local TP_HDR = Instance.new("Frame", TP_CARD)
    TP_HDR.Size = UDim2.new(1, 0, 0, 35)
    TP_HDR.BackgroundTransparency = 1
    TP_HDR.BorderSizePixel = 0
    TP_HDR.LayoutOrder = 0

    local TP_ICO = Instance.new("ImageLabel", TP_HDR)
    TP_ICO.Size = UDim2.new(0, 32, 0, 32)
    TP_ICO.Position = UDim2.new(0, 0, 0.5, -16)
    TP_ICO.BackgroundTransparency = 1
    TP_ICO.Image = "rbxassetid://102084991489439"
    TP_ICO.ImageColor3 = CFG.COL.ACC

    local TP_TITLE = Instance.new("TextLabel", TP_HDR)
    TP_TITLE.Size = UDim2.new(1, -40, 1, 0)
    TP_TITLE.Position = UDim2.new(0, 40, 0, 0)
    TP_TITLE.BackgroundTransparency = 1
    TP_TITLE.Text = "Teleports"
    TP_TITLE.TextColor3 = CFG.COL.TXT
    TP_TITLE.Font = Enum.Font.GothamBold
    TP_TITLE.TextSize = 20
    TP_TITLE.TextXAlignment = Enum.TextXAlignment.Left

    -- Divider
    local TP_DIV = Instance.new("Frame", TP_CARD)
    TP_DIV.Size = UDim2.new(1, 0, 0, 1)
    TP_DIV.BackgroundColor3 = CFG.COL.ACC
    TP_DIV.BackgroundTransparency = 0.85
    TP_DIV.BorderSizePixel = 0
    TP_DIV.LayoutOrder = 1

    -- TP bypass
    local function DO_TP(pos)
        BYPASS_TP(pos)
    end

    -- ── Dropdown ─────────────────────────────────────────
    local TP_WRAP = Instance.new("Frame", TP_CARD)
    TP_WRAP.Size = UDim2.new(1, 0, 0, 35)
    TP_WRAP.BackgroundTransparency = 1
    TP_WRAP.BorderSizePixel = 0
    TP_WRAP.ClipsDescendants = false
    TP_WRAP.LayoutOrder = 2

    local TP_FRM = Instance.new("Frame", TP_WRAP)
    TP_FRM.Size = UDim2.new(1, 0, 0, 35)
    TP_FRM.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    TP_FRM.BackgroundTransparency = 0.3
    TP_FRM.BorderSizePixel = 0
    TP_FRM.ClipsDescendants = true
    TP_FRM.ZIndex = 10
    RND(TP_FRM, 8)
    STR(TP_FRM, CFG.COL.ACC, 1)

    local TP_BTN = Instance.new("TextButton", TP_FRM)
    TP_BTN.Size = UDim2.new(1, 0, 0, 35)
    TP_BTN.BackgroundTransparency = 1
    TP_BTN.Text = "  Select Location..."
    TP_BTN.TextColor3 = CFG.COL.GRY
    TP_BTN.Font = Enum.Font.GothamBold
    TP_BTN.TextSize = 14
    TP_BTN.TextXAlignment = Enum.TextXAlignment.Left
    TP_BTN.ZIndex = 11

    local TP_ICO2 = Instance.new("ImageLabel", TP_BTN)
    TP_ICO2.Size = UDim2.new(0, 16, 0, 16)
    TP_ICO2.Position = UDim2.new(1, -24, 0.5, -8)
    TP_ICO2.BackgroundTransparency = 1
    TP_ICO2.Image = "rbxassetid://6031091004"
    TP_ICO2.ImageColor3 = CFG.COL.ACC
    TP_ICO2.ZIndex = 12

    local TP_DRP_H = math.min(#TP_LOCS * 28, 196)
    local TP_SCR = Instance.new("ScrollingFrame", TP_FRM)
    TP_SCR.Size = UDim2.new(1, 0, 0, TP_DRP_H)
    TP_SCR.Position = UDim2.new(0, 0, 0, 35)
    TP_SCR.BackgroundTransparency = 1
    TP_SCR.BorderSizePixel = 0
    TP_SCR.ScrollBarThickness = 2
    TP_SCR.ScrollBarImageColor3 = CFG.COL.ACC
    TP_SCR.CanvasSize = UDim2.new(0, 0, 0, 0)
    TP_SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TP_SCR.ZIndex = 12

    local TP_SLAY2 = Instance.new("UIListLayout", TP_SCR)
    TP_SLAY2.SortOrder = Enum.SortOrder.LayoutOrder

    local TP_IS_OPEN = false
    local function TP_CLOSE()
        TP_IS_OPEN = false
        TWN(TP_FRM,  {Size = UDim2.new(1, 0, 0, 35)})
        TWN(TP_WRAP, {Size = UDim2.new(1, 0, 0, 35)})
        TWN(TP_ICO2, {Rotation = 0})
    end
    local function TP_OPEN()
        TP_IS_OPEN = true
        TWN(TP_FRM,  {Size = UDim2.new(1, 0, 0, 35 + TP_DRP_H)})
        TWN(TP_WRAP, {Size = UDim2.new(1, 0, 0, 35 + TP_DRP_H)})
        TWN(TP_ICO2, {Rotation = 180})
    end

    TP_BTN.MouseButton1Click:Connect(function()
        if TP_IS_OPEN then TP_CLOSE() else TP_OPEN() end
    end)

    for i, loc in ipairs(TP_LOCS) do
        local ITM = Instance.new("TextButton", TP_SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. loc.name
        ITM.TextColor3 = CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.LayoutOrder = i
        ITM.ZIndex = 13

        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.MouseButton1Click:Connect(function()
            TP_BTN.Text = "  " .. loc.name
            TP_BTN.TextColor3 = CFG.COL.TXT
            TP_CLOSE()
            DO_TP(loc.pos)
            NOTIFY("Teleport", "→ " .. loc.name, 3)
        end)
    end
    TP_SCR.CanvasSize = UDim2.new(0, 0, 0, TP_SLAY2.AbsoluteContentSize.Y)

    -- ── RIGHT COLUMN (Guns + future cards) ───────────────
    RIGHT_COL = Instance.new("Frame", TP_ROW)
    RIGHT_COL.Size = UDim2.new(0.5, -5, 0, 0)
    RIGHT_COL.Position = UDim2.new(0.5, 5, 0, 0)
    RIGHT_COL.AutomaticSize = Enum.AutomaticSize.Y
    RIGHT_COL.BackgroundTransparency = 1
    RIGHT_COL.BorderSizePixel = 0

    local RIGHT_LAY = Instance.new("UIListLayout", RIGHT_COL)
    RIGHT_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    RIGHT_LAY.Padding = UDim.new(0, 8)

    -- ── GUNS CARD ─────────────────────────────────────────
    local GUN_CARD = Instance.new("Frame", RIGHT_COL)
    GUN_CARD.Size = UDim2.new(1, 0, 0, 0)
    GUN_CARD.AutomaticSize = Enum.AutomaticSize.Y
    GUN_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    GUN_CARD.BackgroundTransparency = 0.2
    GUN_CARD.BorderSizePixel = 0
    GUN_CARD.LayoutOrder = 1
    RND(GUN_CARD, 12)
    STR(GUN_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local GUN_LAY = Instance.new("UIListLayout", GUN_CARD)
    GUN_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    GUN_LAY.Padding = UDim.new(0, 8)

    local GUN_PAD = Instance.new("UIPadding", GUN_CARD)
    GUN_PAD.PaddingTop    = UDim.new(0, 12)
    GUN_PAD.PaddingBottom = UDim.new(0, 14)
    GUN_PAD.PaddingLeft   = UDim.new(0, 12)
    GUN_PAD.PaddingRight  = UDim.new(0, 12)

    local GUN_HDR = Instance.new("Frame", GUN_CARD)
    GUN_HDR.Size = UDim2.new(1, 0, 0, 35)
    GUN_HDR.BackgroundTransparency = 1
    GUN_HDR.BorderSizePixel = 0
    GUN_HDR.LayoutOrder = 0

    local GUN_ICO = Instance.new("ImageLabel", GUN_HDR)
    GUN_ICO.Size = UDim2.new(0, 32, 0, 32)
    GUN_ICO.Position = UDim2.new(0, 0, 0.5, -16)
    GUN_ICO.BackgroundTransparency = 1
    GUN_ICO.Image = "rbxassetid://133604745657365"
    GUN_ICO.ImageColor3 = CFG.COL.ACC

    local GUN_TITLE = Instance.new("TextLabel", GUN_HDR)
    GUN_TITLE.Size = UDim2.new(1, -40, 1, 0)
    GUN_TITLE.Position = UDim2.new(0, 40, 0, 0)
    GUN_TITLE.BackgroundTransparency = 1
    GUN_TITLE.Text = "Guns"
    GUN_TITLE.TextColor3 = CFG.COL.TXT
    GUN_TITLE.Font = Enum.Font.GothamBold
    GUN_TITLE.TextSize = 20
    GUN_TITLE.TextXAlignment = Enum.TextXAlignment.Left

    local GUN_DIV = Instance.new("Frame", GUN_CARD)
    GUN_DIV.Size = UDim2.new(1, 0, 0, 1)
    GUN_DIV.BackgroundColor3 = CFG.COL.ACC
    GUN_DIV.BackgroundTransparency = 0.85
    GUN_DIV.BorderSizePixel = 0
    GUN_DIV.LayoutOrder = 1

    local GUNS = {
        { name = "Glock 19x $5,700",      key = "Glock19x"      },
        { name = "Glock 17 $4,750",       key = "Glock17"        },
        { name = "Glock 20 $13,700",       key = "Glock20"        },
        { name = "Glock 21 $9,800",       key = "Glock21"        },
        { name = "Glock 22 $7,400",       key = "Glock22"        },
        { name = "Glock 23 $6,650",       key = "Glock23"        },
        { name = "Glock 26 $3,250",       key = "Glock26"        },
        { name = "Glock 43 $3,600",       key = "Glock43"        },
        { name = "Springfield XD $9,000", key = "SpringfieldXD"  },
        { name = "Taurus G2C $2,500",     key = "Taurus G2C"     },
        { name = "Taurus PT24 $3,400",    key = "Taurus PT24"    },
        { name = "Glock 18c $5,250",      key = "Glock18c"       },
        { name = "G19 Gen5 $6,200",       key = "G19 Gen5"       },
        { name = "FNX-45 $9,500",         key = "FNX-45"         },
        -- GAMEPASS --
        { name = "G17 P80 Mod $14,500",    key = "G17 P80 Mod",   gp = true },
        { name = "G21 Grip $16,000",       key = "G21 Grip",      gp = true },
        { name = "G22 Ethika $12,500",     key = "G22 Ethika",    gp = true },
        { name = "G23 Gen5 $8,700",       key = "G23 Gen5",      gp = true },
        { name = "G23 Vect $8,600",       key = "G23Vect",       gp = true },
        { name = "G26 Vect $6,250",       key = "G26Vect",       gp = true },
        { name = "G27 Drum $13,200",       key = "G27Drum",       gp = true },
        { name = "G27 Red $8,000",        key = "G27Red",        gp = true },
        { name = "G40 Vect $18,500",       key = "G40Vect",       gp = true },
        { name = "G43 Pink $4,000",       key = "G43Pink",       gp = true },
        { name = "G43x Mod $8,500",       key = "G43x Mod",      gp = true },
    }

    -- ── Dropdown factory (local to GUN_CARD) ─────────────
    local function MK_GUN_DRP(label, order)
        local WRAP = Instance.new("Frame", GUN_CARD)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.BorderSizePixel = 0
        WRAP.ClipsDescendants = false
        WRAP.ZIndex = 20 - order
        WRAP.LayoutOrder = order

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = CFG.COL.BG
        FRM.BackgroundTransparency = 0.4
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 20 - order
        RND(FRM, 8)
        STR(FRM, CFG.COL.GRY, 1)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. label
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 21 - order

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 16, 0, 16)
        ICO.Position = UDim2.new(1, -24, 0.5, -8)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 22 - order

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 22 - order
        SCR.CanvasSize = UDim2.new(0,0,0,0)
        SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H = 0

        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN(H)
            if H then DRP_H = H end
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, SCR=SCR, LAY=LAY, CLOSE=CLOSE, OPEN=OPEN }
    end

    -- ── Dropdown 1: Buy Gun ───────────────────────────────
    local D_GUN = MK_GUN_DRP("Select Gun", 2)
    local D_GUN_H = math.min(#GUNS * 30 + 6, 180)
    D_GUN.SCR.Size = UDim2.new(1, 0, 0, D_GUN_H)
    D_GUN.OPEN(D_GUN_H) D_GUN.CLOSE()

    local foundGP = false
    for i, gun in ipairs(GUNS) do
        if gun.gp and not foundGP then
            foundGP = true
            -- Gamepass separator
            local SEP = Instance.new("TextLabel", D_GUN.SCR)
            SEP.Size = UDim2.new(1, 0, 0, 22)
            SEP.BackgroundTransparency = 1
            SEP.Text = "  — GAMEPASS —"
            SEP.TextColor3 = CFG.COL.RED
            SEP.Font = Enum.Font.GothamBold
            SEP.TextSize = 10
            SEP.TextXAlignment = Enum.TextXAlignment.Left
            SEP.LayoutOrder = i
        end
        local ITM = Instance.new("TextButton", D_GUN.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. gun.name
        ITM.TextColor3 = gun.gp and CFG.COL.RED or CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 23
        ITM.LayoutOrder = i + (gun.gp and 100 or 0)
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = gun.gp and CFG.COL.RED or CFG.COL.TXT}, 0.1)
        end)
        ITM.MouseButton1Click:Connect(function()
            D_GUN.BTN.Text = "  " .. gun.name
            D_GUN.CLOSE()
            local ok, err = pcall(function()
                -- Save current position
                local char = LPLR.Character or LPLR.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                local savedCF = hrp.CFrame

                -- Get this gun's exact world position
                local gunModel = workspace.Shops.Guns[gun.key]
                local gunPos = gunModel:GetPivot().Position

                -- TP directly on top of the gun (within 5 studs)
                BYPASS_TP(gunPos + Vector3.new(0, 3, 0))
                char = LPLR.Character or LPLR.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")
                task.wait(0.3)

                -- Buy
                fireproximityprompt(gunModel.Info.ProximityPrompt)
                task.wait(0.5)

                -- TP back
                BYPASS_TP(savedCF.Position)
                char = LPLR.Character or LPLR.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")
            end)
            if ok then NOTIFY("Guns", "✓ " .. gun.name .. " bought!", 3)
            else NOTIFY("Guns", "Error: " .. tostring(err), 4) end
        end)
    end
    D_GUN.SCR.CanvasSize = UDim2.new(0,0,0,D_GUN.LAY.AbsoluteContentSize.Y)

    -- ── Dropdown 2: Gun Mods (applies to equipped gun) ───
    local D_GUN2 = MK_GUN_DRP("Gun Mods", 3)
    local MOD_H = 7 * 30
    D_GUN2.SCR.Size = UDim2.new(1, 0, 0, MOD_H)
    D_GUN2.OPEN(MOD_H) D_GUN2.CLOSE()

    local MODS = {
        { name = "Beam",         type = "Beam",     key = "Beam"     },
        { name = "Switch",       type = "Switch",   key = "Switch"   },
        { name = "Drum Mag",     type = "Magazine", key = "Drum"     },
        { name = "Extended Mag", type = "Magazine", key = "Extended" },
        { name = "Standard Mag", type = "Magazine", key = "Standard" },
    }

    for i, mod in ipairs(MODS) do
        local ITM = Instance.new("TextButton", D_GUN2.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. mod.name
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 23
        ITM.LayoutOrder = i
        ITM.MouseButton1Click:Connect(function()
            D_GUN2.BTN.Text = "  " .. mod.name
            D_GUN2.CLOSE()

            -- Get currently equipped/held gun
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            local tool = char:FindFirstChildOfClass("Tool")
                      or LPLR.Backpack:FindFirstChildOfClass("Tool")

            if not tool then
                NOTIFY("Gun Mods", "No gun equipped!", 4)
                return
            end

            local ok, err = pcall(function()
                -- Save current position
                char = LPLR.Character or LPLR.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                local savedCF = hrp.CFrame

                -- TP to Gun Mods shop
                BYPASS_TP(Vector3.new(-670.75, 4.36, 456.31))
                char = LPLR.Character or LPLR.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")

                -- Re-grab tool reference after TP (still in backpack/char)
                tool = char:FindFirstChildOfClass("Tool")
                    or LPLR.Backpack:FindFirstChildOfClass("Tool")

                -- Buy mod
                game:GetService("ReplicatedStorage").Remotes.PurchaseMod:FireServer(
                    tool, mod.key, mod.type
                )
                task.wait(0.5)

                -- TP back
                BYPASS_TP(savedCF.Position)
                char = LPLR.Character or LPLR.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")
            end)
            if ok then
                NOTIFY("Gun Mods", mod.name .. " applied to " .. tool.Name, 3)
            else
                NOTIFY("Gun Mods", "Error: " .. tostring(err), 4)
            end
        end)
    end
    D_GUN2.SCR.CanvasSize = UDim2.new(0, 0, 0, D_GUN2.LAY.AbsoluteContentSize.Y)

    -- ── Separator + Switch Filament (3D Printer) ─────────
    local SF_SEP = Instance.new("TextLabel", D_GUN2.SCR)
    SF_SEP.Size = UDim2.new(1, 0, 0, 20)
    SF_SEP.BackgroundTransparency = 1
    SF_SEP.Text = "  — 3D PRINTER —"
    SF_SEP.TextColor3 = CFG.COL.ACC
    SF_SEP.Font = Enum.Font.GothamBold
    SF_SEP.TextSize = 10
    SF_SEP.TextXAlignment = Enum.TextXAlignment.Left
    SF_SEP.ZIndex = 23
    SF_SEP.LayoutOrder = #MODS + 1

    local SF_BTN = Instance.new("TextButton", D_GUN2.SCR)
    SF_BTN.Size = UDim2.new(1, 0, 0, 28)
    SF_BTN.BackgroundTransparency = 1
    SF_BTN.Text = "  Switch Filament"
    SF_BTN.TextColor3 = CFG.COL.ACC
    SF_BTN.Font = Enum.Font.Gotham
    SF_BTN.TextSize = 12
    SF_BTN.TextXAlignment = Enum.TextXAlignment.Left
    SF_BTN.ZIndex = 23
    SF_BTN.LayoutOrder = #MODS + 2

    SF_BTN.MouseButton1Click:Connect(function()
        D_GUN2.BTN.Text = "  Switch Filament"
        D_GUN2.CLOSE()

        task.spawn(function()
            local ok, err = pcall(function()
                local char = LPLR.Character or LPLR.CharacterAdded:Wait()
                local hrp  = char:WaitForChild("HumanoidRootPart")
                local savedCF = hrp.CFrame
                local hum = char:WaitForChild("Humanoid")

                -- Check if player has Switch Filament in hand or backpack
                local filament = char:FindFirstChild("Switch Filament")
                              or LPLR.Backpack:FindFirstChild("Switch Filament")
                if not filament then
                    NOTIFY("3D Printer", "❌ You need 'Switch Filament' in hand or backpack!", 5)
                    return
                end

                -- Equip if in backpack
                if filament.Parent == LPLR.Backpack then
                    hum:EquipTool(filament)
                    task.wait(0.3)
                end

                -- TP to 3D Printer
                BYPASS_TP(Vector3.new(-192.09, 3.85, 827.97))
                task.wait(0.1)

                -- Fire proximity prompt
                local prompt = workspace.Shops["3D_Printers"].SwitchPrinter.Prox.ProximityPrompt
                fireproximityprompt(prompt)
                task.wait(0.2)

                -- TP back immediately to a safe waiting spot
                local SAFE_SPOTS = {
                    Vector3.new(-275.74, -33.67, 457.49),
                    Vector3.new(-217.56, -30.69, 471.43),
                }
                BYPASS_TP(SAFE_SPOTS[math.random(1, #SAFE_SPOTS)])

                -- Notify and then watch backpack precisely
                NOTIFY("3D Printer", "⏳ Wait for the SWITCH to appear in your inventory!", 6)

                task.spawn(function()
                    local conn
                    conn = LPLR.Backpack.ChildAdded:Connect(function(item)
                        if item.Name == "Switch" then
                            conn:Disconnect()
                            -- TP back to original position
                            BYPASS_TP(savedCF.Position)
                            NOTIFY("3D Printer", "✅ SWITCH is now in your inventory!", 5)
                        end
                    end)
                    task.delay(60, function()
                        pcall(function() conn:Disconnect() end)
                    end)
                end)
            end)

            if not ok then
                NOTIFY("3D Printer", "❌ " .. tostring(err), 5)
            end
        end)
    end)

    -- Update canvas for new items
    D_GUN2.SCR.CanvasSize = UDim2.new(0, 0, 0, D_GUN2.LAY.AbsoluteContentSize.Y)

    -- ── WEAPON MODS (Inf Ammo / No Recoil / Rapid Fire) ──────
    -- State (upvalues declared above)

    local function WM_APPLY()
        local char = LPLR.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local setting = tool:FindFirstChild("Setting")
        if not setting then return end
        for _, m in pairs(setting:GetChildren()) do
            if m:IsA("ModuleScript") then
                local ok, mod = pcall(require, m)
                if ok and type(mod) == "table" then
                    -- INF AMMO
                    if WM.INF_AMMO then
                        if mod.LimitedAmmoEnabled ~= nil then mod.LimitedAmmoEnabled = false end
                        if mod.AmmoPerMag  then mod.AmmoPerMag  = math.huge end
                        if mod.MaxAmmo     then mod.MaxAmmo     = math.huge end
                        if mod.Ammo        then mod.Ammo        = math.huge end
                    end
                    -- NO RECOIL
                    if WM.NO_RECOIL then
                        if mod.Recoil then mod.Recoil = 0 end
                        if mod.AngleX_Min ~= nil then
                            mod.AngleX_Min=0; mod.AngleX_Max=0
                            mod.AngleY_Min=0; mod.AngleY_Max=0
                            mod.AngleZ_Min=0; mod.AngleZ_Max=0
                        end
                    end
                    -- RAPID FIRE
                    if WM.RAPID_FIRE then
                        if mod.Auto                 ~= nil then mod.Auto                 = true      end
                        if mod.AutoFire             ~= nil then mod.AutoFire             = true      end
                        if mod.SelectiveFireEnabled ~= nil then mod.SelectiveFireEnabled = true      end
                        if mod.CanAuto              ~= nil then mod.CanAuto              = true      end
                        if mod.BurstFire            ~= nil then mod.BurstFire            = false     end
                        if mod.FireModes ~= nil then
                            for i = 1, #mod.FireModes do mod.FireModes[i] = true end
                        end
                        if mod.FireRate      then mod.FireRate      = WM_RATE end
                        if mod.ShotCooldown  then mod.ShotCooldown  = WM_RATE end
                        if mod.FireDelay     then mod.FireDelay      = WM_RATE end
                        if mod.SemiFireDelay then mod.SemiFireDelay  = WM_RATE end
                        if mod.ShotInterval  then mod.ShotInterval   = WM_RATE end
                        if mod.FireCooldown  then mod.FireCooldown   = WM_RATE end
                        if mod.NextShot      then mod.NextShot       = 0       end
                        if mod.RPM           then mod.RPM            = 9999    end
                        if mod.FireRates  then for i=1,#mod.FireRates  do mod.FireRates[i]  = WM_RATE end end
                        if mod.BurstRates then for i=1,#mod.BurstRates do mod.BurstRates[i] = 0       end end
                    end
                end
            end
        end
    end

    -- Patch loop every 0.1s
    local WM_T = 0
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        local any = WM.INF_AMMO or WM.NO_RECOIL or WM.RAPID_FIRE
        if not any then return end
        WM_T = WM_T + dt
        if WM_T < 0.1 then return end
        WM_T = 0
        WM_APPLY()
    end)

    -- ── Dropdown wrapper ─────────────────────────────────────
    local WM_WRAP = Instance.new("Frame", GUN_CARD)
    WM_WRAP.Size = UDim2.new(1, 0, 0, 35)
    WM_WRAP.BackgroundTransparency = 1
    WM_WRAP.BorderSizePixel = 0
    WM_WRAP.ClipsDescendants = false
    WM_WRAP.ZIndex = 14
    WM_WRAP.LayoutOrder = 4

    local WM_FRM = Instance.new("Frame", WM_WRAP)
    WM_FRM.Size = UDim2.new(1, 0, 0, 35)
    WM_FRM.BackgroundColor3 = CFG.COL.BG
    WM_FRM.BackgroundTransparency = 0.4
    WM_FRM.BorderSizePixel = 0
    WM_FRM.ClipsDescendants = true
    WM_FRM.ZIndex = 14
    RND(WM_FRM, 8)
    STR(WM_FRM, CFG.COL.ACC, 1)

    local WM_BTN = Instance.new("TextButton", WM_FRM)
    WM_BTN.Size = UDim2.new(1, 0, 0, 35)
    WM_BTN.BackgroundTransparency = 1
    WM_BTN.Text = "  Weapon Mods"
    WM_BTN.TextColor3 = CFG.COL.ACC
    WM_BTN.Font = Enum.Font.GothamBold
    WM_BTN.TextSize = 13
    WM_BTN.TextXAlignment = Enum.TextXAlignment.Left
    WM_BTN.ZIndex = 15

    local WM_ICO = Instance.new("ImageLabel", WM_BTN)
    WM_ICO.Size = UDim2.new(0, 16, 0, 16)
    WM_ICO.Position = UDim2.new(1, -24, 0.5, -8)
    WM_ICO.BackgroundTransparency = 1
    WM_ICO.Image = "rbxassetid://6031091004"
    WM_ICO.ImageColor3 = CFG.COL.ACC
    WM_ICO.ZIndex = 16

    -- Inner content frame
    local WM_BODY = Instance.new("Frame", WM_FRM)
    WM_BODY.Position = UDim2.new(0, 0, 0, 35)
    WM_BODY.BackgroundTransparency = 1
    WM_BODY.BorderSizePixel = 0
    WM_BODY.Size = UDim2.new(1, 0, 0, 0)
    WM_BODY.AutomaticSize = Enum.AutomaticSize.Y
    WM_BODY.ZIndex = 15

    local WM_BLAY = Instance.new("UIListLayout", WM_BODY)
    WM_BLAY.SortOrder = Enum.SortOrder.LayoutOrder
    WM_BLAY.Padding = UDim.new(0, 6)

    local WM_BPAD = Instance.new("UIPadding", WM_BODY)
    WM_BPAD.PaddingTop    = UDim.new(0, 8)
    WM_BPAD.PaddingBottom = UDim.new(0, 10)
    WM_BPAD.PaddingLeft   = UDim.new(0, 4)
    WM_BPAD.PaddingRight  = UDim.new(0, 4)

    -- Toggle builder (inline)
    local function WM_MK_TOG(label, key, order)
        local ROW = Instance.new("Frame", WM_BODY)
        ROW.Size = UDim2.new(1, 0, 0, 32)
        ROW.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        ROW.BackgroundTransparency = 0.2
        ROW.BorderSizePixel = 0
        ROW.LayoutOrder = order
        ROW.ZIndex = 15
        RND(ROW, 7)

        local LBL = Instance.new("TextLabel", ROW)
        LBL.Size = UDim2.new(1, -55, 1, 0)
        LBL.Position = UDim2.new(0, 10, 0, 0)
        LBL.BackgroundTransparency = 1
        LBL.Text = label
        LBL.TextColor3 = CFG.COL.TXT
        LBL.Font = Enum.Font.Gotham
        LBL.TextSize = 12
        LBL.TextXAlignment = Enum.TextXAlignment.Left
        LBL.ZIndex = 16

        local PILL = Instance.new("Frame", ROW)
        PILL.Size = UDim2.new(0, 38, 0, 20)
        PILL.Position = UDim2.new(1, -46, 0.5, -10)
        PILL.BackgroundColor3 = CFG.COL.GRY
        PILL.BorderSizePixel = 0
        PILL.ZIndex = 16
        RND(PILL, 10)

        local KNOB = Instance.new("Frame", PILL)
        KNOB.Size = UDim2.new(0, 16, 0, 16)
        KNOB.Position = UDim2.new(0, 2, 0.5, -8)
        KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
        KNOB.BorderSizePixel = 0
        KNOB.ZIndex = 17
        RND(KNOB, 8)

        local CLK = Instance.new("TextButton", ROW)
        CLK.Size = UDim2.new(1, 0, 1, 0)
        CLK.BackgroundTransparency = 1
        CLK.Text = ""
        CLK.ZIndex = 18
        CLK.MouseButton1Click:Connect(function()
            WM[key] = not WM[key]
            if WM[key] then
                TWN(PILL, {BackgroundColor3 = CFG.COL.ACC})
                TWN(KNOB, {Position = UDim2.new(1, -18, 0.5, -8)})
                WM_APPLY()
            else
                TWN(PILL, {BackgroundColor3 = CFG.COL.GRY})
                TWN(KNOB, {Position = UDim2.new(0, 2, 0.5, -8)})
            end
        end)
    end

    -- Slider builder (inline, compact)
    local function WM_MK_SLIDER(label, minV, maxV, defV, onChange, order)
        local ROW = Instance.new("Frame", WM_BODY)
        ROW.Size = UDim2.new(1, 0, 0, 44)
        ROW.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        ROW.BackgroundTransparency = 0.2
        ROW.BorderSizePixel = 0
        ROW.LayoutOrder = order
        ROW.ZIndex = 15
        RND(ROW, 7)

        local LBL = Instance.new("TextLabel", ROW)
        LBL.Size = UDim2.new(0.6, 0, 0, 20)
        LBL.Position = UDim2.new(0, 10, 0, 4)
        LBL.BackgroundTransparency = 1
        LBL.Text = label
        LBL.TextColor3 = CFG.COL.TXT
        LBL.Font = Enum.Font.Gotham
        LBL.TextSize = 11
        LBL.TextXAlignment = Enum.TextXAlignment.Left
        LBL.ZIndex = 16

        local VAL_LBL = Instance.new("TextLabel", ROW)
        VAL_LBL.Size = UDim2.new(0.35, 0, 0, 20)
        VAL_LBL.Position = UDim2.new(0.6, 0, 0, 4)
        VAL_LBL.BackgroundTransparency = 1
        VAL_LBL.Text = tostring(defV)
        VAL_LBL.TextColor3 = CFG.COL.ACC
        VAL_LBL.Font = Enum.Font.GothamBold
        VAL_LBL.TextSize = 11
        VAL_LBL.TextXAlignment = Enum.TextXAlignment.Right
        VAL_LBL.ZIndex = 16

        local TRACK = Instance.new("Frame", ROW)
        TRACK.Size = UDim2.new(1, -20, 0, 5)
        TRACK.Position = UDim2.new(0, 10, 0, 30)
        TRACK.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TRACK.BorderSizePixel = 0
        TRACK.ZIndex = 16
        RND(TRACK, 3)

        local FILL = Instance.new("Frame", TRACK)
        FILL.Size = UDim2.new((defV - minV) / (maxV - minV), 0, 1, 0)
        FILL.BackgroundColor3 = CFG.COL.ACC
        FILL.BorderSizePixel = 0
        FILL.ZIndex = 17
        RND(FILL, 3)

        local THUMB = Instance.new("TextButton", TRACK)
        THUMB.Size = UDim2.new(0, 14, 0, 14)
        THUMB.Position = UDim2.new((defV - minV) / (maxV - minV), -7, 0.5, -7)
        THUMB.BackgroundColor3 = Color3.new(1, 1, 1)
        THUMB.BorderSizePixel = 0
        THUMB.Text = ""
        THUMB.ZIndex = 18
        RND(THUMB, 7)

        local dragging = false
        THUMB.MouseButton1Down:Connect(function() dragging = true end)
        game:GetService("UserInputService").InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        game:GetService("RunService").Heartbeat:Connect(function()
            if not dragging then return end
            local rx = math.clamp((game:GetService("UserInputService"):GetMouseLocation().X - TRACK.AbsolutePosition.X) / TRACK.AbsoluteSize.X, 0, 1)
            local val = math.floor(minV + rx * (maxV - minV))
            FILL.Size = UDim2.new(rx, 0, 1, 0)
            THUMB.Position = UDim2.new(rx, -7, 0.5, -7)
            VAL_LBL.Text = tostring(val)
            if onChange then onChange(val) end
        end)
    end

    WM_MK_TOG("Inf Ammo",   "INF_AMMO",   1)
    WM_MK_TOG("No Recoil",  "NO_RECOIL",  2)
    WM_MK_TOG("Rapid Fire", "RAPID_FIRE", 3)
    WM_MK_SLIDER("Fire Rate (ms)", 1, 500, 10, function(v)
        WM_RATE = v / 1000
    end, 4)

    -- Open/close logic
    local WM_OPEN = false
    local function WM_CALC_H()
        return WM_BPAD.PaddingTop.Offset
             + WM_BPAD.PaddingBottom.Offset
             + WM_BLAY.AbsoluteContentSize.Y
    end

    WM_BTN.MouseButton1Click:Connect(function()
        WM_OPEN = not WM_OPEN
        if WM_OPEN then
            -- need a frame to let AutomaticSize compute
            task.wait()
            local h = WM_CALC_H()
            TWN(WM_FRM,  {Size = UDim2.new(1, 0, 0, 35 + h)})
            TWN(WM_WRAP, {Size = UDim2.new(1, 0, 0, 35 + h)})
            TWN(WM_ICO,  {Rotation = 180})
        else
            TWN(WM_FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WM_WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WM_ICO,  {Rotation = 0})
        end
    end)
end)()

-- ── ACTIONS CARD (right col, below Guns) ──────────────────────
;(function()  -- register isolation: actions card
    local ACT_CARD = Instance.new("Frame", RIGHT_COL)
    ACT_CARD.Size = UDim2.new(1, 0, 0, 0)
    ACT_CARD.AutomaticSize = Enum.AutomaticSize.Y
    ACT_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    ACT_CARD.BackgroundTransparency = 0.2
    ACT_CARD.BorderSizePixel = 0
    ACT_CARD.LayoutOrder = 2
    RND(ACT_CARD, 12)
    STR(ACT_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local AC_LAY = Instance.new("UIListLayout", ACT_CARD)
    AC_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    AC_LAY.Padding = UDim.new(0, 8)

    local AC_PAD = Instance.new("UIPadding", ACT_CARD)
    AC_PAD.PaddingTop    = UDim.new(0, 10)
    AC_PAD.PaddingBottom = UDim.new(0, 12)
    AC_PAD.PaddingLeft   = UDim.new(0, 12)
    AC_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local AC_HDR = Instance.new("Frame", ACT_CARD)
    AC_HDR.Size = UDim2.new(1, 0, 0, 28)
    AC_HDR.BackgroundTransparency = 1
    AC_HDR.LayoutOrder = 0

    local AC_ICN = Instance.new("ImageLabel", AC_HDR)
    AC_ICN.Size = UDim2.new(0, 24, 0, 24)
    AC_ICN.Position = UDim2.new(0, 0, 0.5, -12)
    AC_ICN.BackgroundTransparency = 1
    AC_ICN.Image = "rbxassetid://87411082578223"
    AC_ICN.ImageColor3 = CFG.COL.ACC

    local AC_TTL = Instance.new("TextLabel", AC_HDR)
    AC_TTL.Size = UDim2.new(1, -34, 1, 0)
    AC_TTL.Position = UDim2.new(0, 32, 0, 0)
    AC_TTL.BackgroundTransparency = 1
    AC_TTL.Text = "Actions"
    AC_TTL.TextColor3 = CFG.COL.TXT
    AC_TTL.Font = Enum.Font.GothamBold
    AC_TTL.TextSize = 15
    AC_TTL.TextXAlignment = Enum.TextXAlignment.Left

    local AC_DIV = Instance.new("Frame", ACT_CARD)
    AC_DIV.Size = UDim2.new(1, 0, 0, 1)
    AC_DIV.BackgroundColor3 = CFG.COL.ACC
    AC_DIV.BackgroundTransparency = 0.85
    AC_DIV.BorderSizePixel = 0
    AC_DIV.LayoutOrder = 1

    -- Button factory
    local function MK_ACT_BTN(txt, order, cb)
        local BTN = Instance.new("TextButton", ACT_CARD)
        BTN.Size = UDim2.new(1, 0, 0, 34)
        BTN.BackgroundColor3 = CFG.COL.BG
        BTN.BackgroundTransparency = 0.82
        BTN.BorderSizePixel = 0
        BTN.Text = txt
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 13
        BTN.LayoutOrder = order
        BTN.AutoButtonColor = false
        RND(BTN, 10)
        
        local STR_OBJ = STR(BTN, CFG.COL.ACC, 1.2)
        STR_OBJ.Transparency = 0.8
        STR_OBJ.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local GRAD = Instance.new("UIGradient", BTN)
        GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
        })
        GRAD.Rotation = 45
        GRAD.Transparency = NumberSequence.new(0.5)

        BTN.MouseEnter:Connect(function()
            TWN(BTN, {BackgroundTransparency = 0.7, BackgroundColor3 = CFG.COL.ACC}, 0.2)
            TWN(STR_OBJ, {Transparency = 0.5}, 0.2)
        end)
        BTN.MouseLeave:Connect(function()
            TWN(BTN, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG}, 0.2)
            TWN(STR_OBJ, {Transparency = 0.8}, 0.2)
        end)

        BTN.MouseButton1Click:Connect(function()
            TWN(BTN, {BackgroundTransparency = 0.4, TextSize = 12}, 0.1)
            task.wait(0.1)
            TWN(BTN, {BackgroundTransparency = 0.7, TextSize = 13}, 0.1)
            cb()
        end)
        return BTN
    end

    -- ── INF MONEY — based on server uptime ───────────────
    local IM_READY    = false
    local IM_QUEUED   = false
    local IM_REQUIRED = 360  -- 6 minutes in seconds

    -- Countdown label between the two buttons
    local IM_LBL = Instance.new("TextLabel", ACT_CARD)
    IM_LBL.Size = UDim2.new(1, 0, 0, 18)
    IM_LBL.BackgroundTransparency = 1
    IM_LBL.TextColor3 = CFG.COL.GRY
    IM_LBL.Font = Enum.Font.Gotham
    IM_LBL.TextSize = 10
    IM_LBL.TextXAlignment = Enum.TextXAlignment.Center
    IM_LBL.LayoutOrder = 25

    -- Helper: run the fullscreen + event (no text)
    local function IM_DO_FULLSCREEN()
        task.spawn(function()
            local _sounds = {}
            local _muted = true
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("Sound") then _sounds[v] = v.Volume; v.Volume = 0 end
            end
            local _muteConn = game.DescendantAdded:Connect(function(v)
                if _muted and v:IsA("Sound") then _sounds[v] = v.Volume; v.Volume = 0 end
            end)

            local SG = Instance.new("ScreenGui", LPLR.PlayerGui)
            SG.Name = "IM_OVERLAY"
            SG.IgnoreGuiInset = true
            SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            SG.DisplayOrder = 2147483647
            SG.ResetOnSpawn = false

            local BG = Instance.new("ImageLabel", SG)
            BG.Size = UDim2.new(1, 0, 1, 0)
            BG.BackgroundColor3 = Color3.new(0, 0, 0)
            BG.BackgroundTransparency = 0
            BG.BorderSizePixel = 0
            BG.Image = "rbxassetid://108458500083995"
            BG.ImageTransparency = 0
            BG.ScaleType = Enum.ScaleType.Crop
            BG.ZIndex = 1

            local TINT = Instance.new("Frame", SG)
            TINT.Size = UDim2.new(1, 0, 1, 0)
            TINT.BackgroundColor3 = Color3.new(0, 0, 0)
            TINT.BackgroundTransparency = 0.45
            TINT.BorderSizePixel = 0
            TINT.ZIndex = 2

            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Claim_Reward:InvokeServer("$500", 500000000)
            end)

            task.wait(6)

            _muted = false
            _muteConn:Disconnect()
            for sound, vol in pairs(_sounds) do
                if sound and sound.Parent then sound.Volume = vol end
            end

            TWN(BG,   {ImageTransparency = 1}, 0.5)
            TWN(TINT, {BackgroundTransparency = 1}, 0.5)
            task.wait(0.6)
            SG:Destroy()
        end)
    end

    -- Countdown loop using server uptime
    task.spawn(function()
        while true do
            task.wait(0.5)
            local elapsed = workspace.DistributedGameTime
            local remaining = IM_REQUIRED - elapsed

            if remaining <= 0 then
                if not IM_READY then
                    IM_READY = true
                    IM_LBL.Text = "✅  Inf Money is ready!"
                    IM_LBL.TextColor3 = Color3.fromRGB(100, 255, 130)
                    if IM_QUEUED then
                        IM_DO_FULLSCREEN()
                    end
                end
                break
            else
                local mins = math.floor(remaining / 60)
                local secs = math.floor(remaining % 60)
                IM_LBL.Text = string.format("⏳  %d:%02d before Inf Money is ready", mins, secs)
            end
        end
    end)

    MK_ACT_BTN("Inf Money", 2, function()
        if IM_READY then
            IM_DO_FULLSCREEN()
        else
            local remaining = math.max(0, IM_REQUIRED - workspace.DistributedGameTime)
            local mins = math.floor(remaining / 60)
            local secs = math.floor(remaining % 60)
            NOTIFY("Inf Money", string.format("⏳ %d:%02d remaining. Will auto-run when ready!", mins, secs), 5)
            IM_QUEUED = true
        end
    end)

    -- ── ROLLBACK DUPE ────────────────────────────────────
    MK_ACT_BTN("Rollback Dupe", 4, function()
        task.spawn(function()
            -- 1. Mute all sounds for duration of screen
            local _sounds = {}
            local _muted = true
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("Sound") then
                    _sounds[v] = v.Volume
                    v.Volume = 0
                end
            end
            local _muteConn = game.DescendantAdded:Connect(function(v)
                if _muted and v:IsA("Sound") then
                    _sounds[v] = v.Volume
                    v.Volume = 0
                end
            end)

            -- 2. Fullscreen overlay
            local SG = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
            SG.Name = "RB_OVERLAY"
            SG.IgnoreGuiInset = true
            SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            SG.DisplayOrder = 2147483647
            SG.ResetOnSpawn = false

            local BG = Instance.new("ImageLabel", SG)
            BG.Size = UDim2.new(1, 0, 1, 0)
            BG.BackgroundColor3 = Color3.new(0, 0, 0)
            BG.BackgroundTransparency = 0
            BG.BorderSizePixel = 0
            BG.Image = "rbxassetid://108458500083995"
            BG.ImageTransparency = 0
            BG.ScaleType = Enum.ScaleType.Crop
            BG.ZIndex = 1

            -- Dark tint over image
            local TINT = Instance.new("Frame", SG)
            TINT.Size = UDim2.new(1, 0, 1, 0)
            TINT.BackgroundColor3 = Color3.new(0, 0, 0)
            TINT.BackgroundTransparency = 0.45
            TINT.BorderSizePixel = 0
            TINT.ZIndex = 2

            -- 3. Intro text (animated)
            local TXT1 = Instance.new("TextLabel", SG)
            TXT1.Size = UDim2.new(0.85, 0, 0, 120)
            TXT1.Position = UDim2.new(0.075, 0, 0.5, -60)
            TXT1.BackgroundTransparency = 1
            TXT1.Text = "THIS OPTION WILL ALLOW YOU TO BUY THINGS WITHOUT LOSING MONEY.\nYOU CAN ALSO DUPLICATE WEAPONS, ETC.\nFOR THIS YOU NEED AN ALT ACCOUNT OR A FRIEND."
            TXT1.TextColor3 = Color3.new(1, 1, 1)
            TXT1.Font = Enum.Font.GothamBold
            TXT1.TextSize = 22
            TXT1.TextWrapped = true
            TXT1.TextTransparency = 1
            TXT1.ZIndex = 3
            TXT1.TextXAlignment = Enum.TextXAlignment.Center

            -- Fade in text
            TWN(TXT1, {TextTransparency = 0}, 0.6)
            task.wait(2.5)

            -- 4. Fire the event
            local ok, err = pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Crosshair:FireServer("\xFF", 6)
            end)

            -- 5. Swap text
            TWN(TXT1, {TextTransparency = 1}, 0.3)
            task.wait(0.35)

            TXT1.Text = "YOU CAN NOW START SPENDING MONEY.\nWHEN YOU REJOIN OR CHANGE SERVERS, YOU WILL HAVE THE SAME AMOUNT OF MONEY AS BEFORE.\n\nGO SPEND IT ALL — IT WILL BE ROLLED BACK!"
            TXT1.TextColor3 = Color3.fromRGB(100, 255, 130)
            TWN(TXT1, {TextTransparency = 0}, 0.5)

            if not ok then
                NOTIFY("Rollback", "Event error: " .. tostring(err), 5)
            end

            -- 6. Wait 6s then restore sounds, fade out and destroy
            task.wait(6)

            -- Restore sounds
            _muted = false
            _muteConn:Disconnect()
            for sound, vol in pairs(_sounds) do
                if sound and sound.Parent then
                    sound.Volume = vol
                end
            end

            TWN(TXT1, {TextTransparency = 1}, 0.4)
            TWN(BG,   {ImageTransparency = 1}, 0.5)
            TWN(TINT, {BackgroundTransparency = 1}, 0.5)
            task.wait(0.6)
            SG:Destroy()
        end)
    end)
end)()

-- ── STORE ITEMS CARD (left col, below TP_CARD) ────────────────
do
    local STORE_CARD = Instance.new("Frame", LEFT_COL)
    STORE_CARD.Size = UDim2.new(1, 0, 0, 0)
    STORE_CARD.AutomaticSize = Enum.AutomaticSize.Y
    STORE_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    STORE_CARD.BackgroundTransparency = 0.2
    STORE_CARD.BorderSizePixel = 0
    STORE_CARD.LayoutOrder = 2
    RND(STORE_CARD, 12)
    STR(STORE_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local SC_LAY = Instance.new("UIListLayout", STORE_CARD)
    SC_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    SC_LAY.Padding = UDim.new(0, 10)

    local SC_PAD = Instance.new("UIPadding", STORE_CARD)
    SC_PAD.PaddingTop    = UDim.new(0, 10)
    SC_PAD.PaddingBottom = UDim.new(0, 12)
    SC_PAD.PaddingLeft   = UDim.new(0, 12)
    SC_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local SC_HDR = Instance.new("Frame", STORE_CARD)
    SC_HDR.Size = UDim2.new(1, 0, 0, 28)
    SC_HDR.BackgroundTransparency = 1
    SC_HDR.LayoutOrder = 0

    local SC_ICN = Instance.new("ImageLabel", SC_HDR)
    SC_ICN.Size = UDim2.new(0, 24, 0, 24)
    SC_ICN.Position = UDim2.new(0, 0, 0.5, -12)
    SC_ICN.BackgroundTransparency = 1
    SC_ICN.Image = "rbxassetid://126863867828820"
    SC_ICN.ImageColor3 = CFG.COL.ACC

    local SC_TTL = Instance.new("TextLabel", SC_HDR)
    SC_TTL.Size = UDim2.new(1, -34, 1, 0)
    SC_TTL.Position = UDim2.new(0, 32, 0, 0)
    SC_TTL.BackgroundTransparency = 1
    SC_TTL.Text = "Store Items"
    SC_TTL.TextColor3 = CFG.COL.TXT
    SC_TTL.Font = Enum.Font.GothamBold
    SC_TTL.TextSize = 15
    SC_TTL.TextXAlignment = Enum.TextXAlignment.Left

    -- Divider
    local SC_DIV = Instance.new("Frame", STORE_CARD)
    SC_DIV.Size = UDim2.new(1, 0, 0, 1)
    SC_DIV.BackgroundColor3 = CFG.COL.ACC
    SC_DIV.BackgroundTransparency = 0.85
    SC_DIV.BorderSizePixel = 0
    SC_DIV.LayoutOrder = 1

    -- Dropdown factory (same style as guns)
    local function MK_STORE_DRP(label, order)
        local WRAP = Instance.new("Frame", STORE_CARD)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.BorderSizePixel = 0
        WRAP.ClipsDescendants = false
        WRAP.ZIndex = 20 - order
        WRAP.LayoutOrder = order

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = CFG.COL.BG
        FRM.BackgroundTransparency = 0.4
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 20 - order
        RND(FRM, 8)
        STR(FRM, CFG.COL.GRY, 1)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. label
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 21 - order

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 16, 0, 16)
        ICO.Position = UDim2.new(1, -24, 0.5, -8)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 22 - order

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 22 - order
        SCR.CanvasSize = UDim2.new(0,0,0,0)
        SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H = 0

        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN(H)
            if H then DRP_H = H end
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, SCR=SCR, LAY=LAY, CLOSE=CLOSE, OPEN=OPEN }
    end

    -- Products list
    local STORE_PRODUCTS = {
        "Burrito", "Sub Sandwhich", "Chopped Cheese", "Coke",
        "Dasani Water", "Dice", "Faygo Creme Soda",
        "Faygo Rasberry Blueberry", "Flamin' Hot Cheetos",
        "Grape Kool-Aid", "Hog Fruit Barrel", "Hotdog",
        "Limon Flamin' Hot Cheetos", "Orange Snapple",
        "Pain Killers", "Ranch Flamin' Hot Cheetos"
    }

    -- Deli locations to TP to (pick closest / rotate)
    local STORE_DELIS = {
        { pos = Vector3.new(-49.31,  4.23,  -81.65),  npc = "Gdog"  },  -- Deli 2
        { pos = Vector3.new(-147.28, 4.35, 1196.95),  npc = "Leeky" },  -- Deli 3
        { pos = Vector3.new(-931.42, 4.14,  639.29),  npc = "Jenn"  },  -- Deli 4
    }

    local ST_SELECTED = ""
    local ST_AMOUNT   = 1
    local ST_IS_3D    = false
    local ST_IS_AMMO  = false

    -- Dropdown 1: Items
    local D_ST1 = MK_STORE_DRP("Choose Item", 2)
    local D_ST1_H = math.min(#STORE_PRODUCTS * 28, 180)
    D_ST1.SCR.Size = UDim2.new(1, 0, 0, D_ST1_H)
    D_ST1.OPEN(D_ST1_H) D_ST1.CLOSE()

    -- ── AMMO (first item) ────────────────────────────────────
    local ITM_AMMO = Instance.new("TextButton", D_ST1.SCR)
    ITM_AMMO.Size = UDim2.new(1, 0, 0, 28)
    ITM_AMMO.BackgroundTransparency = 1
    ITM_AMMO.Text = "  Ammo"
    ITM_AMMO.TextColor3 = CFG.COL.YEL
    ITM_AMMO.Font = Enum.Font.GothamBold
    ITM_AMMO.TextSize = 12
    ITM_AMMO.TextXAlignment = Enum.TextXAlignment.Left
    ITM_AMMO.ZIndex = 23
    ITM_AMMO.LayoutOrder = 0
    ITM_AMMO.MouseButton1Click:Connect(function()
        ST_SELECTED = "Ammo"
        ST_IS_AMMO  = true
        ST_IS_3D    = false
        D_ST1.BTN.Text = "  Ammo"
        D_ST1.CLOSE()
    end)

    -- Separator between Ammo and deli items
    local ST_SEP_AMMO = Instance.new("TextLabel", D_ST1.SCR)
    ST_SEP_AMMO.Size = UDim2.new(1, 0, 0, 18)
    ST_SEP_AMMO.BackgroundTransparency = 1
    ST_SEP_AMMO.Text = "  — DELI ITEMS —"
    ST_SEP_AMMO.TextColor3 = CFG.COL.GRY
    ST_SEP_AMMO.Font = Enum.Font.GothamBold
    ST_SEP_AMMO.TextSize = 10
    ST_SEP_AMMO.TextXAlignment = Enum.TextXAlignment.Left
    ST_SEP_AMMO.ZIndex = 23
    ST_SEP_AMMO.LayoutOrder = 1

    for i, prod in ipairs(STORE_PRODUCTS) do
        local ITM = Instance.new("TextButton", D_ST1.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. prod
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 23
        ITM.LayoutOrder = i + 1  -- offset by 2 (0=Ammo, 1=sep, 2+=deli)
        ITM.MouseButton1Click:Connect(function()
            ST_SELECTED = prod
            ST_IS_3D   = false
            ST_IS_AMMO = false
            D_ST1.BTN.Text = "  " .. prod
            D_ST1.CLOSE()
        end)
    end

    -- Separator
    local ST_SEP = Instance.new("TextLabel", D_ST1.SCR)
    ST_SEP.Size = UDim2.new(1, 0, 0, 20)
    ST_SEP.BackgroundTransparency = 1
    ST_SEP.Text = "  — 3D PRINTERS —"
    ST_SEP.TextColor3 = CFG.COL.ACC
    ST_SEP.Font = Enum.Font.GothamBold
    ST_SEP.TextSize = 10
    ST_SEP.TextXAlignment = Enum.TextXAlignment.Left
    ST_SEP.ZIndex = 23
    ST_SEP.LayoutOrder = #STORE_PRODUCTS + 2

    -- 3D Printer Switch item
    local ITM_3D = Instance.new("TextButton", D_ST1.SCR)
    ITM_3D.Size = UDim2.new(1, 0, 0, 28)
    ITM_3D.BackgroundTransparency = 1
    ITM_3D.Text = "  3D Printer Switch"
    ITM_3D.TextColor3 = CFG.COL.ACC
    ITM_3D.Font = Enum.Font.Gotham
    ITM_3D.TextSize = 12
    ITM_3D.TextXAlignment = Enum.TextXAlignment.Left
    ITM_3D.ZIndex = 23
    ITM_3D.LayoutOrder = #STORE_PRODUCTS + 3
    ITM_3D.MouseButton1Click:Connect(function()
        ST_SELECTED = "3D Printer Switch"
        ST_IS_3D   = true
        ST_IS_AMMO = false
        D_ST1.BTN.Text = "  3D Printer Switch"
        D_ST1.CLOSE()
    end)

    D_ST1.SCR.CanvasSize = UDim2.new(0, 0, 0, D_ST1.LAY.AbsoluteContentSize.Y)

    -- Dropdown 2: Quantity
    local STORE_QTYS = {1, 2, 3, 4, 5, 10, 15, 20}
    local D_ST2 = MK_STORE_DRP("Qty: 1", 3)
    local D_ST2_H = math.min(#STORE_QTYS * 28, 180)
    D_ST2.SCR.Size = UDim2.new(1, 0, 0, D_ST2_H)
    D_ST2.OPEN(D_ST2_H) D_ST2.CLOSE()

    for i, qty in ipairs(STORE_QTYS) do
        local ITM = Instance.new("TextButton", D_ST2.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  x" .. qty
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 23
        ITM.LayoutOrder = i
        ITM.MouseButton1Click:Connect(function()
            ST_AMOUNT = qty
            D_ST2.BTN.Text = "  Qty: " .. qty
            D_ST2.CLOSE()
        end)
    end
    D_ST2.SCR.CanvasSize = UDim2.new(0, 0, 0, D_ST2.LAY.AbsoluteContentSize.Y)

    -- Buy button
    local SC_BUY = Instance.new("TextButton", STORE_CARD)
    SC_BUY.Name = "CEN_ACCENT_TEXT"
    SC_BUY.Size = UDim2.new(1, 0, 0, 34)
    SC_BUY.BackgroundColor3 = CFG.COL.BG
    SC_BUY.BackgroundTransparency = 0.82
    SC_BUY.BorderSizePixel = 0
    SC_BUY.Text = "Purchase"
    SC_BUY.TextColor3 = CFG.COL.ACC
    SC_BUY.Font = Enum.Font.GothamBold
    SC_BUY.TextSize = 13
    SC_BUY.LayoutOrder = 4
    SC_BUY.AutoButtonColor = false
    RND(SC_BUY, 10)

    local BUY_STR = STR(SC_BUY, CFG.COL.ACC, 1.2)
    BUY_STR.Transparency = 0.8
    BUY_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local BUY_GRAD = Instance.new("UIGradient", SC_BUY)
    BUY_GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
    })
    BUY_GRAD.Rotation = 45
    BUY_GRAD.Transparency = NumberSequence.new(0.5)

    SC_BUY.MouseEnter:Connect(function()
        TWN(SC_BUY, {BackgroundTransparency = 0.65, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0,0,0)}, 0.2)
        TWN(BUY_STR, {Transparency = 0.5}, 0.2)
    end)
    SC_BUY.MouseLeave:Connect(function()
        TWN(SC_BUY, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG, TextColor3 = CFG.COL.ACC}, 0.2)
        TWN(BUY_STR, {Transparency = 0.8}, 0.2)
    end)

    SC_BUY.MouseButton1Click:Connect(function()
        if ST_SELECTED == "" then
            NOTIFY("Store", "⚠️ Select an item first!", 3)
            return
        end
        local item = ST_SELECTED
        local qty  = ST_AMOUNT

        TWN(SC_BUY, {BackgroundTransparency = 0.4, TextSize = 12}, 0.1)
        task.wait(0.1)
        TWN(SC_BUY, {BackgroundTransparency = 0.65, TextSize = 13}, 0.1)

        task.spawn(function()
            -- Check weapon before anything else
            if ST_IS_AMMO then
                local char = LPLR.Character or LPLR.CharacterAdded:Wait()
                if not char:FindFirstChildOfClass("Tool") then
                    NOTIFY("Store", "⚠️ Equip a weapon first!", 4)
                    return
                end
            end
            local ok, err = pcall(function()
                -- Save position
                local char = LPLR.Character or LPLR.CharacterAdded:Wait()
                local hrp  = char:WaitForChild("HumanoidRootPart")
                local savedCF = hrp.CFrame

                if ST_IS_AMMO then
                    -- ── Ammo from crates ──────────────────────────
                    local ammoContainer = workspace.Map.Interactables.Turf_Stuff.Ammunition
                    local ammoContainer = workspace.Map.Interactables.Turf_Stuff.Ammunition
                    local crates = {}
                    for _, v in ipairs(ammoContainer:GetChildren()) do
                        if v:IsA("MeshPart") then
                            local pp = v:FindFirstChildOfClass("ProximityPrompt")
                            if pp then table.insert(crates, {obj=v, pp=pp}) end
                        end
                    end
                    if #crates == 0 then error("No ammo crates found!") end
                    -- Elegir UN crate al azar y quedarse ahí toda la compra
                    local crate = crates[math.random(1, #crates)]
                    BYPASS_TP(crate.obj.Position + Vector3.new(0, 3, 0))
                    task.wait(0.1)
                    for i = 1, qty do
                        -- Bypass antes de cada compra para resetear cooldown del servidor
                        BYPASS_TP(crate.obj.Position + Vector3.new(0, 3, 0))
                        task.wait(0.1)
                        fireproximityprompt(crate.pp)
                        task.wait(0.4)
                    end
                elseif ST_IS_3D then
                    -- ── 3D Printer Switch ──────────────────────────
                    local printer = workspace.Shops["3D_Printers"].SwitchPrinter
                    local prompt  = printer.Prox.ProximityPrompt

                    BYPASS_TP(Vector3.new(-192.09, 3.85, 827.97))
                    task.wait(0.1)

                    for i = 1, qty do
                        fireproximityprompt(prompt)
                        task.wait(0.6)
                    end
                else
                    -- ── Regular deli item ──────────────────────────
                    local deli = STORE_DELIS[math.random(1, #STORE_DELIS)]
                    BYPASS_TP(deli.pos)
                    task.wait(0.1)

                    local npc = workspace.NPCs:FindFirstChild(deli.npc)
                    if not npc then error(deli.npc .. " NPC not found") end

                    for i = 1, qty do
                        game:GetService("ReplicatedStorage").Remotes.Purchase:FireServer(item, npc)
                        task.wait(0.6)
                    end
                end

                -- TP back
                BYPASS_TP(savedCF.Position)
            end)

            if ok then
                local label = ST_IS_AMMO and "Ammo" or item
                NOTIFY("Store", "✅ Bought x" .. qty .. " " .. label, 4)
            else
                NOTIFY("Store", "❌ " .. tostring(err), 5)
            end
        end)
    end)
end

-- [ TOGGLE HELPER ]
local function ADD_TOG(PAG, TXT, DEF, CB)
    local ROW = Instance.new("Frame", PAG)
    ROW.Size = UDim2.new(1, -10, 0, 36)
    ROW.BackgroundTransparency = 1

    local LBL = Instance.new("TextLabel", ROW)
    LBL.Size = UDim2.new(1, -60, 1, 0)
    LBL.Position = UDim2.new(0, 0, 0, 0)
    LBL.BackgroundTransparency = 1
    LBL.Text = TXT
    LBL.TextColor3 = CFG.COL.TXT
    LBL.Font = Enum.Font.Gotham
    LBL.TextSize = 13
    LBL.TextXAlignment = Enum.TextXAlignment.Left

    -- Track pill
    local PILL = Instance.new("Frame", ROW)
    PILL.Size = UDim2.new(0, 44, 0, 24)
    PILL.Position = UDim2.new(1, -44, 0.5, -12)
    PILL.BackgroundColor3 = CFG.COL.GRY
    PILL.BorderSizePixel = 0
    RND(PILL, 12)

    -- Knob
    local KNOB = Instance.new("Frame", PILL)
    KNOB.Size = UDim2.new(0, 18, 0, 18)
    KNOB.Position = UDim2.new(0, 3, 0.5, -9)
    KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
    KNOB.BorderSizePixel = 0
    RND(KNOB, 9)

    local STATE = DEF or false

    local function SET(ON, ANIMATE)
        STATE = ON
        local T = ANIMATE ~= false and CFG.SPD or 0
        if ON then
            TWN(PILL,  {BackgroundColor3 = CFG.COL.ACC}, T)
            TWN(KNOB,  {Position = UDim2.new(0, 23, 0.5, -9)}, T)
        else
            TWN(PILL,  {BackgroundColor3 = CFG.COL.GRY}, T)
            TWN(KNOB,  {Position = UDim2.new(0, 3, 0.5, -9)}, T)
        end
        if CB then CB(ON) end
    end

    -- Init without animation
    SET(STATE, false)

    -- Click anywhere on the row
    local CLK = Instance.new("TextButton", ROW)
    CLK.Size = UDim2.new(1, 0, 1, 0)
    CLK.BackgroundTransparency = 1
    CLK.Text = ""
    CLK.ZIndex = 5
    CLK.MouseButton1Click:Connect(function()
        SET(not STATE)
    end)

    return {
        SetState = SET,
        GetState = function() return STATE end
    }
end

-- ============================================================
--  FARM SERVICES & SHARED STATE
-- ============================================================
local RS_F    = game:GetService("ReplicatedStorage")
local RUN_S   = game:GetService("RunService")
local TPS_F   = game:GetService("TeleportService")

local Purchase_R    = RS_F.Remotes.Purchase
local PurchaseSeeds_R = RS_F.Remotes.PurchaseSeeds
local FlowerDropOff_R = RS_F.Remotes.FlowerDropOff
local InquireFarm_R = RS_F.Remotes.inquireFarming

local function _G_EXE_GET(k) return _G.EXE[k] end
local function _G_EXE_SET(k, v) _G.EXE[k] = v end

-- Shared farm config (changed by dropdowns)
local FARM_PLANTA          = "Daisy"   -- default
local MODO_FARM            = "A"       -- default: A or B
local FARM_CONFIG          = 1         -- default: 1=Normal 4pots | 2=Multi-Wave Beta

-- Redirect variables to global EXE table for PANIC support
_G.EXE.FARM_RUNNING         = false     -- stub local
local FARM_STOP_AFTER      = false     -- finish current cycle then stop
_G.EXE.FARM_THREAD          = nil       -- stub local

-- We wrap them in metatable or just direct access? 
-- Direct access in loops is better. I will replace definitions with direct _G.EXE references.

-- ── PLANT DATA (ordered by required level) ─────────────────
local PLANT_DATA = {
    { name = "Daisy",     lvl = 0   },
    { name = "Tulip",     lvl = 8   },
    { name = "Lavender",  lvl = 20  },
    { name = "Sunflower", lvl = 35  },
    { name = "Orchid",    lvl = 55  },
    { name = "Lily",      lvl = 80  },
    { name = "Peony",     lvl = 110 },
    { name = "Jasmine",   lvl = 145 },
    { name = "BlackRose", lvl = 185 },
}

local function GET_TRAPPER_LVL()
    local ok, val = pcall(function()
        return LPLR.Job_Data.TrapperLevel.Value
    end)
    return ok and (val or 0) or 0
end

-- ── POT DATA ────────────────────────────────────────────────
local ZONA_SEGURA = Vector3.new(-222.87, -30.70, 453.41)

local POTS_PRIORITARIOS = {
    { idx=11, pos=Vector3.new(-119.58,  3.65, 821.12) },
    { idx=12, pos=Vector3.new(-125.64,  3.65, 820.89) },
    { idx=13, pos=Vector3.new(-130.70,  3.65, 806.30) },
    { idx=14, pos=Vector3.new(-120.25,  3.65, 827.62) },
}

local TODOS_POTS = {
    { idx=1,  pos=Vector3.new(-72.19,    -6.40,  -277.45) },
    { idx=2,  pos=Vector3.new(-72.28,    -6.40,  -270.88) },
    { idx=3,  pos=Vector3.new(-71.52,    -6.40,  -266.00) },
    { idx=4,  pos=Vector3.new(-75.99,    -6.40,  -283.51) },
    { idx=5,  pos=Vector3.new(-84.66,    -6.40,  -268.98) },
    { idx=6,  pos=Vector3.new(-307.13,   17.51,   327.45) },
    { idx=7,  pos=Vector3.new(-312.26,   17.51,   326.91) },
    { idx=8,  pos=Vector3.new(-317.63,   17.51,   326.32) },
    { idx=9,  pos=Vector3.new(-311.07,   17.51,   346.09) },
    { idx=10, pos=Vector3.new(-306.06,   17.51,   338.15) },
    { idx=11, pos=Vector3.new(-119.58,    3.65,   821.12) },
    { idx=12, pos=Vector3.new(-125.64,    3.65,   820.89) },
    { idx=13, pos=Vector3.new(-130.70,    3.65,   806.30) },
    { idx=14, pos=Vector3.new(-120.25,    3.65,   827.62) },
    { idx=15, pos=Vector3.new(-146.16,   18.86,   820.65) },
    { idx=16, pos=Vector3.new(-153.41,   18.86,   806.17) },
    { idx=17, pos=Vector3.new(-159.27,   18.86,   806.87) },
    { idx=18, pos=Vector3.new(-165.25,   18.86,   806.62) },
    { idx=19, pos=Vector3.new(-1299.55,   3.90,  1362.79) },
    { idx=20, pos=Vector3.new(-1299.48,   3.90,  1356.22) },
    { idx=21, pos=Vector3.new(-1299.62,   3.80,  1371.74) },
    { idx=22, pos=Vector3.new(-1299.41,   3.90,  1399.78) },
    { idx=23, pos=Vector3.new(-1325.13,   3.90,  1356.97) },
    { idx=24, pos=Vector3.new(-1324.14,   3.80,  1365.45) },
    { idx=25, pos=Vector3.new(-1324.90,   3.80,  1372.14) },
    { idx=26, pos=Vector3.new(-1336.36,   3.80,  1373.93) },
    { idx=27, pos=Vector3.new(-1337.48,   3.80,  1385.27) },
    { idx=28, pos=Vector3.new(-1324.65,   3.90,  1398.17) },
}

-- ── FARM HELPERS ────────────────────────────────────────────
local function F_SPAWN(nombre)
    local pt = workspace.spawn_Assets.Points:FindFirstChild(nombre)
                or workspace.spawn_Assets.Points["Trinity Ave. Plaza"]
    local ptPos = pt.Position
    game:GetService("ReplicatedStorage").Remotes.Spawn:FireServer(pt)
    local waited = 0
    repeat
        task.wait(0.05); waited += 0.05
        local c = LPLR.Character or LPLR.CharacterAdded:Wait()
        local h = c:FindFirstChild("HumanoidRootPart")
        if h and (h.Position - ptPos).Magnitude < 60 then break end
    until waited > 3
    return LPLR.Character or LPLR.CharacterAdded:Wait()
end

local function F_TP(_, pos)
    TP_CLASSIC(pos)
    task.wait(0.1)
end

local function F_EQUIP(char, name)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local tool = LPLR.Backpack:FindFirstChild(name)
    if tool and hum then hum:EquipTool(tool) task.wait(0.3) end
end

local function F_COUNT(name)
    local count = 0
    for _, item in ipairs(LPLR.Backpack:GetChildren()) do
        if item.Name == name then count = count + 1 end
    end
    if LPLR.Character then
        for _, item in ipairs(LPLR.Character:GetChildren()) do
            if item.Name == name and item:IsA("Tool") then count = count + 1 end
        end
    end
    return count
end

local function F_CLEAN()
    for _, itemName in ipairs({"EPhone","Fist"}) do
        local found = false
        for _, item in ipairs(LPLR.Backpack:GetChildren()) do
            if item.Name == itemName then
                if found then item:Destroy() else found = true end
            end
        end
    end
end

local function F_WAIT_OFF(prompt, timeout)
    local t = 0
    while prompt.Enabled and t < (timeout or 30) do task.wait(0.1) t = t + 0.1 end
end

local function F_WAIT_ON(prompt, timeout)
    local t = 0
    while not prompt.Enabled and t < (timeout or 120) do task.wait(0.1) t = t + 0.1 end
end

local function F_GET_POT(data)
    return workspace.Jobs.Flower_Growing.Pots:GetChildren()[data.idx]
end

local function F_GET_PROMPT(data)
    local pot = F_GET_POT(data)
    if not pot then return nil end
    local pp = pot:FindFirstChild("ProxPart")
    return pp and pp:FindFirstChild("ProximityPrompt")
end

local function F_POT_FREE(data)
    local pot = F_GET_POT(data)
    if not pot then return false end
    local pp = pot:FindFirstChild("ProxPart")
    if not pp then return false end
    local prompt = pp:FindFirstChild("ProximityPrompt")
    if not prompt or not prompt.Enabled then return false end
    if pot:GetAttribute("Seeds") then return false end
    return true
end

local function F_GO_POT(data)
    local char = F_SPAWN("Trinity Ave. Plaza")
    F_TP(char, data.pos + Vector3.new(0, 3, 2))
    return char
end

local function F_SELECT_POTS()
    local sel, used = {}, {}
    for _, data in ipairs(POTS_PRIORITARIOS) do
        if #sel >= 4 then break end
        if F_POT_FREE(data) then
            table.insert(sel, data)
            used[data.idx] = true
        else
            local bestDist, bestData = math.huge, nil
            for _, fb in ipairs(TODOS_POTS) do
                if not used[fb.idx] and F_POT_FREE(fb) then
                    local d = (fb.pos - data.pos).Magnitude
                    if d < bestDist and d < 600 then bestDist = d bestData = fb end
                end
            end
            if bestData then
                table.insert(sel, bestData)
                used[bestData.idx] = true
            end
        end
    end
    return sel
end

-- Select up to 4 free pots excluding already-used indices (for Mode C waves)
local function F_SELECT_POTS_EXCL(EXCL_MAP)
    local sel, used = {}, {}
    -- Copy exclusion map so we don't mutate caller's table
    for k, v in pairs(EXCL_MAP) do used[k] = v end

    -- Try priority pots first, then fall back to any free pot
    local candidates = {}
    for _, data in ipairs(POTS_PRIORITARIOS) do
        if not used[data.idx] and F_POT_FREE(data) then
            table.insert(candidates, data)
        end
    end
    for _, data in ipairs(TODOS_POTS) do
        if not used[data.idx] and F_POT_FREE(data) then
            -- avoid duplicates already in candidates
            local dup = false
            for _, c in ipairs(candidates) do
                if c.idx == data.idx then dup = true break end
            end
            if not dup then table.insert(candidates, data) end
        end
    end

    for _, data in ipairs(candidates) do
        if #sel >= 4 then break end
        table.insert(sel, data)
        used[data.idx] = true
    end
    return sel
end

-- ── PLANT A WAVE (shared by modes A, B, C) ──────────────────
-- Hold helper para Plant Shovel (igual que BF_HOLD)
local function F_HOLD(prompt)
    if not prompt or not prompt.Enabled then return end
    local dur = prompt.HoldDuration
    if dur and dur > 0 then
        -- Enfocar camara al prompt
        local cam  = workspace.CurrentCamera
        local char = LPLR.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local targetPos = prompt.Parent and prompt.Parent:IsA("BasePart")
            and prompt.Parent.Position
            or (prompt.Parent and prompt.Parent:IsA("Attachment")
            and prompt.Parent.WorldPosition)
            or nil
        if hrp and targetPos then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0), targetPos)
        end
        -- Hacer hold
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(dur + 0.3)
            prompt:InputHoldEnd()
        end)
        -- Restaurar camara
        pcall(function()
            if char then cam.CameraSubject = char:FindFirstChildOfClass("Humanoid") end
            cam.CameraType = Enum.CameraType.Custom
        end)
    else
        fireproximityprompt(prompt)
    end
end

local function F_PLANT_WAVE_A(pots)
    local char
    -- Plantar
    for _, data in ipairs(pots) do
        if not _G.EXE.FARM_RUNNING then return false end
        local prompt = F_GET_PROMPT(data)
        if not prompt then continue end
        if not F_GET_POT(data):GetAttribute("Seeds") and F_COUNT("Seeds") > 0 then
            char = F_GO_POT(data)
            F_EQUIP(char, "Seeds")
            F_HOLD(prompt)
            F_WAIT_OFF(prompt, 10) F_WAIT_ON(prompt, 10) task.wait(0.2)
        end
    end
    -- Regar
    for _, data in ipairs(pots) do
        if not _G.EXE.FARM_RUNNING then return false end
        local prompt = F_GET_PROMPT(data)
        if not prompt then continue end
        char = F_GO_POT(data)
        if not prompt.Enabled then F_WAIT_ON(prompt, 15) end
        F_EQUIP(char, "Watering Can")
        F_HOLD(prompt)
        F_WAIT_OFF(prompt, 30) F_WAIT_ON(prompt, 15) task.wait(0.2)
    end
    -- Fertilizar
    for _, data in ipairs(pots) do
        if not _G.EXE.FARM_RUNNING then return false end
        local prompt = F_GET_PROMPT(data)
        if not prompt or F_COUNT("Fertilizer") <= 0 then continue end
        char = F_GO_POT(data)
        if not prompt.Enabled then F_WAIT_ON(prompt, 15) end
        task.wait(0.5) F_EQUIP(char, "Fertilizer") task.wait(0.3)
        F_HOLD(prompt)
        F_WAIT_OFF(prompt, 30) task.wait(0.3)
    end
    return true
end

local function F_PLANT_WAVE_B(pots)
    local char
    for _, data in ipairs(pots) do
        if not _G.EXE.FARM_RUNNING then return false end
        local prompt = F_GET_PROMPT(data)
        if not prompt then continue end
        char = F_GO_POT(data)
        if not F_GET_POT(data):GetAttribute("Seeds") and F_COUNT("Seeds") > 0 then
            F_EQUIP(char, "Seeds")
            F_HOLD(prompt)
            F_WAIT_OFF(prompt, 10) F_WAIT_ON(prompt, 10) task.wait(0.2)
        end
        if not prompt.Enabled then F_WAIT_ON(prompt, 15) end
        F_EQUIP(char, "Watering Can")
        F_HOLD(prompt)
        F_WAIT_OFF(prompt, 30) F_WAIT_ON(prompt, 15) task.wait(0.2)
        if F_COUNT("Fertilizer") > 0 then
            if not prompt.Enabled then F_WAIT_ON(prompt, 15) end
            task.wait(0.5) F_EQUIP(char, "Fertilizer") task.wait(0.3)
            F_HOLD(prompt)
            F_WAIT_OFF(prompt, 30) task.wait(0.3)
        end
    end
    return true
end

-- ── MAIN FARM CYCLE ─────────────────────────────────────────
local function F_BUY_WAVE()
    local char = F_SPAWN("Trinity Ave. Plaza")
    F_CLEAN()
    char = F_SPAWN("Trinity Ave. Plaza")
    F_TP(char, Vector3.new(-297.10, 18.17, 175.46))
    Purchase_R:FireServer("Watering Can", workspace.NPCs.Mdot) task.wait(1)
    for i = 1, 4 do
        Purchase_R:FireServer("Fertilizer", workspace.NPCs.Mdot) task.wait(1)
    end
    for i = 1, 4 do
        PurchaseSeeds_R:FireServer(FARM_PLANTA) task.wait(1)
    end
    task.wait(0.5)
    F_CLEAN()
    return F_COUNT("Seeds") >= 1 or F_COUNT("Fertilizer") >= 1
end

local function RUN_FARM_CYCLE()

    -- ══════════════════════════════════════════════════════════
    --  CONFIG 2 – BETA: Fill ALL pots in waves of 4
    --  (uses MODO_FARM A or B for planting style per wave)
    -- ══════════════════════════════════════════════════════════
    if FARM_CONFIG == 2 then
        local ALL_PLANTED = {}  -- all pots planted this mega-cycle
        local USED_MAP    = {}  -- indices already used across waves
        local WAVE        = 0

        -- Keep buying + planting until no free pots left
        while _G.EXE.FARM_RUNNING do
            -- Select next batch of 4 free pots (excluding already planted)
            local wave_pots = F_SELECT_POTS_EXCL(USED_MAP)
            if #wave_pots == 0 then
                NOTIFY("Farm Beta", "No more free pots. Total planted: " .. #ALL_PLANTED, 4)
                break
            end

            WAVE = WAVE + 1
            NOTIFY("Farm Beta", "Wave " .. WAVE .. " – buying items...", 3)

            -- Buy items for this wave
            local got = F_BUY_WAVE()
            if not got then
                NOTIFY("Farm Beta", "No items on wave " .. WAVE .. ", stopping.", 4)
                break
            end
            if not _G.EXE.FARM_RUNNING then return false end

            -- Plant this wave using the selected method (A or B)
            NOTIFY("Farm Beta", "Wave " .. WAVE .. " – planting " .. #wave_pots .. " pots to grow...", 3)
            local ok
            if MODO_FARM == "B" then
                ok = F_PLANT_WAVE_B(wave_pots)
            else
                ok = F_PLANT_WAVE_A(wave_pots) -- default A
            end
            if not ok or not _G.EXE.FARM_RUNNING then return false end

            -- Register these pots as used and planted
            for _, data in ipairs(wave_pots) do
                USED_MAP[data.idx] = true
                table.insert(ALL_PLANTED, data)
            end

            NOTIFY("Farm Beta", "Wave " .. WAVE .. " done! Total: " .. #ALL_PLANTED .. " pots.", 4)
        end

        if #ALL_PLANTED == 0 then
            NOTIFY("Farm Beta", "No pots planted.", 4)
            return false
        end

        -- Wait in safe zone for ALL planted pots
        NOTIFY("Farm Beta", "Waiting for " .. #ALL_PLANTED .. " pots to grow...", 5)
        local char = F_SPAWN("Trinity Ave. Plaza")
        F_TP(char, ZONA_SEGURA)
        for _, data in ipairs(ALL_PLANTED) do
            if not _G.EXE.FARM_RUNNING then return false end
            local prompt = F_GET_PROMPT(data)
            if prompt then F_WAIT_ON(prompt, 180) end
        end

        -- Collect ALL planted pots in groups of 4
        NOTIFY("Farm Beta", "Collecting " .. #ALL_PLANTED .. " pots to grow...", 4)
        local hum = (LPLR.Character or LPLR.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() task.wait(0.2) end

        for i = 1, #ALL_PLANTED, 4 do
            if not _G.EXE.FARM_RUNNING then return false end
            -- Collect batch of up to 4
            local batch_end = math.min(i + 3, #ALL_PLANTED)
            for j = i, batch_end do
                local data = ALL_PLANTED[j]
                local prompt = F_GET_PROMPT(data)
                if not prompt then continue end
                char = F_GO_POT(data)
                F_HOLD(prompt) task.wait(0.4)
            end
            -- Deliver this batch
            NOTIFY("Farm Beta", "Delivering batch " .. math.ceil(i/4) .. "...", 3)
            char = F_SPAWN("Trinity Ave. Plaza")
            F_CLEAN()
            F_TP(char, Vector3.new(-296.67, 18.17, 193.37))
            local ok2, res2 = pcall(function() return FlowerDropOff_R:InvokeServer() end)
            if ok2 and res2 then
                NOTIFY("Farm Beta", "✅ Lote " .. math.ceil(i/4) .. " entregado!", 4)
            else
                NOTIFY("Farm Beta", "❌ Failed batch " .. math.ceil(i/4), 4)
            end
        end

        NOTIFY("Farm Beta", "✅ Mega-cycle complete! Restarting...", 5)
        return true
    end

    -- ══════════════════════════════════════════════════════════
    --  CONFIG 1 – Normal cycle (4 pots)
    -- ══════════════════════════════════════════════════════════

    -- 1. Buy items
    local got = F_BUY_WAVE()
    if not got then NOTIFY("Farm", "No items, stopping.", 4) return false end

    -- 2. Select pots
    local char = F_SPAWN("Trinity Ave. Plaza")
    F_CLEAN()
    local pots = F_SELECT_POTS()
    if #pots == 0 then NOTIFY("Farm", "No pots available!", 4) return false end

    -- 3. Farm
    local ok
    if MODO_FARM == "A" then
        ok = F_PLANT_WAVE_A(pots)
    elseif MODO_FARM == "B" then
        ok = F_PLANT_WAVE_B(pots)
    end
    if not ok or not _G.EXE.FARM_RUNNING then return false end

    -- 4. Zona segura → esperar
    NOTIFY("Farm", "Waiting for plants to grow...", 5)
    char = F_SPAWN("Trinity Ave. Plaza")
    F_TP(char, ZONA_SEGURA)
    for _, data in ipairs(pots) do
        if not _G.EXE.FARM_RUNNING then return false end
        local prompt = F_GET_PROMPT(data)
        if prompt then F_WAIT_ON(prompt, 120) end
    end

    -- 5. Collect
    NOTIFY("Farm", "Collecting flowers...", 3)
    local hum = (LPLR.Character or LPLR.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
    if hum then hum:UnequipTools() task.wait(0.2) end
    for _, data in ipairs(pots) do
        if not _G.EXE.FARM_RUNNING then return false end
        local prompt = F_GET_PROMPT(data)
        if not prompt then continue end
        char = F_GO_POT(data)
        F_HOLD(prompt) task.wait(0.4)
    end

    -- 6. Entregar
    NOTIFY("Farm", "Delivering...", 3)
    char = F_SPAWN("Trinity Ave. Plaza")
    F_CLEAN()
    F_TP(char, Vector3.new(-296.67, 18.17, 193.37))
    local ok2, res2 = pcall(function() return FlowerDropOff_R:InvokeServer() end)
    if ok2 and res2 then
        NOTIFY("Farm", "✅ Delivery successful! Restarting cycle...", 4)
    else
        NOTIFY("Farm", "❌ Delivery failed.", 4)
    end

    return true
end

-- ── FARM LOOP ───────────────────────────────────────────────
local FARM_PILL_RESET_CB = nil  -- set by UI to reset toggle pill on stop

local function START_FARM_LOOP()
    _G.EXE.FARM_THREAD = task.spawn(function()
        while _G.EXE.FARM_RUNNING do
            pcall(RUN_FARM_CYCLE)
            -- "Finish then stop" → break after one full cycle
            if FARM_STOP_AFTER then break end
            -- Normal stop mid-cycle check
            if not _G.EXE.FARM_RUNNING then break end
            task.wait(1)
        end
        -- Clean up state
        _G.EXE.FARM_RUNNING    = false
        FARM_STOP_AFTER = false
        _G.EXE.FARM_THREAD     = nil
        NOTIFY("Farm", "Auto Farm stopped.", 3)
        -- Reset pill to grey
        if FARM_PILL_RESET_CB then FARM_PILL_RESET_CB() end
    end)
end

-- ============================================================
--  FARM → PLANT SHOVEL (left) + CARD FARM (right)  – same row
-- ============================================================
local FARM_ROW_L, FARM_ROW_R = FARM_ROW()

-- ── PLANT SHOVEL CARD  (left column) ─────────────────────────
;(function()  -- register isolation: plant shovel card
    local COL_L = FARM_ROW_L

    -- Card wrapper
    local CARD = Instance.new("Frame", COL_L)
    CARD.Size = UDim2.new(1, 0, 0, 0)
    CARD.AutomaticSize = Enum.AutomaticSize.Y
    CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    CARD.BackgroundTransparency = 0.2
    CARD.BorderSizePixel = 0
    RND(CARD, 12)
    STR(CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local CPAD = Instance.new("UIPadding", CARD)
    CPAD.PaddingTop    = UDim.new(0, 10)
    CPAD.PaddingBottom = UDim.new(0, 12)
    CPAD.PaddingLeft   = UDim.new(0, 12)
    CPAD.PaddingRight  = UDim.new(0, 12)

    local CLAY = Instance.new("UIListLayout", CARD)
    CLAY.SortOrder = Enum.SortOrder.LayoutOrder
    CLAY.Padding = UDim.new(0, 10)

    -- ── HEADER ──────────────────────────────────────────────
    local HDR = Instance.new("Frame", CARD)
    HDR.Size = UDim2.new(1, 0, 0, 35)
    HDR.BackgroundTransparency = 1
    HDR.LayoutOrder = 0

    local ICN = Instance.new("ImageLabel", HDR)
    ICN.Size = UDim2.new(0, 32, 0, 32)
    ICN.Position = UDim2.new(0, 0, 0.5, -16)
    ICN.BackgroundTransparency = 1
    ICN.Image = "rbxassetid://93826240341204"
    ICN.ImageColor3 = CFG.COL.ACC

    local HTL = Instance.new("TextLabel", HDR)
    HTL.Size = UDim2.new(1, -40, 1, 0)
    HTL.Position = UDim2.new(0, 40, 0, 0)
    HTL.BackgroundTransparency = 1
    HTL.Text = "Plant Shovel"
    HTL.TextColor3 = CFG.COL.TXT
    HTL.Font = Enum.Font.GothamBold
    HTL.TextSize = 18
    HTL.TextXAlignment = Enum.TextXAlignment.Left

    -- Divider
    local DIV = Instance.new("Frame", CARD)
    DIV.Size = UDim2.new(1, 0, 0, 1)
    DIV.BackgroundColor3 = CFG.COL.ACC
    DIV.BackgroundTransparency = 0.85
    DIV.BorderSizePixel = 0
    DIV.LayoutOrder = 1

    -- ── TOGGLE: AUTO PLANT FARM ─────────────────────────────
    local TOG_ROW = Instance.new("Frame", CARD)
    TOG_ROW.Size = UDim2.new(1, 0, 0, 36)
    TOG_ROW.BackgroundTransparency = 1
    TOG_ROW.LayoutOrder = 2

    local T_LBL = Instance.new("TextLabel", TOG_ROW)
    T_LBL.Size = UDim2.new(1, -60, 1, 0)
    T_LBL.BackgroundTransparency = 1
    T_LBL.Text = "Auto Plant Farm"
    T_LBL.TextColor3 = CFG.COL.TXT
    T_LBL.Font = Enum.Font.Gotham
    T_LBL.TextSize = 14
    T_LBL.TextXAlignment = Enum.TextXAlignment.Left

    local T_PILL = Instance.new("Frame", TOG_ROW)
    T_PILL.Size = UDim2.new(0, 44, 0, 24)
    T_PILL.Position = UDim2.new(1, -44, 0.5, -12)
    T_PILL.BackgroundColor3 = CFG.COL.GRY
    T_PILL.BorderSizePixel = 0
    RND(T_PILL, 12)

    local T_KNOB = Instance.new("Frame", T_PILL)
    T_KNOB.Size = UDim2.new(0, 18, 0, 18)
    T_KNOB.Position = UDim2.new(0, 3, 0.5, -9)
    T_KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
    T_KNOB.BorderSizePixel = 0
    RND(T_KNOB, 9)

    -- ── STOP CONFIRMATION MODAL ─────────────────────────────
    local MODAL = Instance.new("Frame", MAIN)
    MODAL.Name = "StopModal"
    MODAL.Size = UDim2.new(0, 260, 0, 0)
    MODAL.AutomaticSize = Enum.AutomaticSize.Y
    MODAL.AnchorPoint = Vector2.new(0.5, 0.5)
    MODAL.Position = UDim2.new(0.5, 0, 0.5, 0)
    MODAL.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    MODAL.BackgroundTransparency = 0.05
    MODAL.BorderSizePixel = 0
    MODAL.Visible = false
    MODAL.ZIndex = 50
    MODAL.ClipsDescendants = false
    RND(MODAL, 14)
    STR(MODAL, CFG.COL.ACC, 1.5).Transparency = 0.5

    -- Dimmed backdrop
    local BACKDROP = Instance.new("Frame", MAIN)
    BACKDROP.Size = UDim2.new(1, 0, 1, 0)
    BACKDROP.BackgroundColor3 = Color3.new(0, 0, 0)
    BACKDROP.BackgroundTransparency = 0.5
    BACKDROP.BorderSizePixel = 0
    BACKDROP.Visible = false
    BACKDROP.ZIndex = 49

    local MLAY = Instance.new("UIListLayout", MODAL)
    MLAY.SortOrder = Enum.SortOrder.LayoutOrder
    MLAY.Padding = UDim.new(0, 6)
    MLAY.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local MPAD = Instance.new("UIPadding", MODAL)
    MPAD.PaddingTop    = UDim.new(0, 14)
    MPAD.PaddingBottom = UDim.new(0, 14)
    MPAD.PaddingLeft   = UDim.new(0, 14)
    MPAD.PaddingRight  = UDim.new(0, 14)

    local M_TTL = Instance.new("TextLabel", MODAL)
    M_TTL.Size = UDim2.new(1, 0, 0, 20)
    M_TTL.BackgroundTransparency = 1
    M_TTL.Text = "⚠️  Stop Auto Farm"
    M_TTL.TextColor3 = CFG.COL.ACC
    M_TTL.Font = Enum.Font.GothamBold
    M_TTL.TextSize = 14
    M_TTL.TextXAlignment = Enum.TextXAlignment.Center
    M_TTL.ZIndex = 51
    M_TTL.LayoutOrder = 0

    local M_SUB = Instance.new("TextLabel", MODAL)
    M_SUB.Size = UDim2.new(1, 0, 0, 18)
    M_SUB.BackgroundTransparency = 1
    M_SUB.Text = "What do you want to do?"
    M_SUB.TextColor3 = CFG.COL.GRY
    M_SUB.Font = Enum.Font.Gotham
    M_SUB.TextSize = 12
    M_SUB.TextXAlignment = Enum.TextXAlignment.Center
    M_SUB.ZIndex = 51
    M_SUB.LayoutOrder = 1

    local function MK_MODAL_BTN(TXT, COL, LO)
        local B = Instance.new("TextButton", MODAL)
        B.Size = UDim2.new(1, 0, 0, 32)
        B.BackgroundColor3 = COL
        B.BackgroundTransparency = 0.25
        B.BorderSizePixel = 0
        B.Text = TXT
        B.TextColor3 = Color3.new(1, 1, 1)
        B.Font = Enum.Font.GothamBold
        B.TextSize = 12
        B.ZIndex = 51
        B.LayoutOrder = LO
        RND(B, 8)
        B.MouseEnter:Connect(function() TWN(B, {BackgroundTransparency = 0.05}, 0.15) end)
        B.MouseLeave:Connect(function() TWN(B, {BackgroundTransparency = 0.25}, 0.15) end)
        return B
    end

    local function SHOW_MODAL(visible)
        MODAL.Visible    = visible
        BACKDROP.Visible = visible
    end

    local B_FINISH = MK_MODAL_BTN("✅  Finish cycle then stop",  Color3.fromRGB(39, 160, 80), 2)
    local B_STOP   = MK_MODAL_BTN("🛑  Stop immediately",        Color3.fromRGB(200, 60, 60), 3)
    local B_CANCEL = MK_MODAL_BTN("↩️  Cancel  (was an accident)", Color3.fromRGB(50, 50, 70),  4)

    B_FINISH.MouseButton1Click:Connect(function()
        SHOW_MODAL(false)
        -- Keep _G.EXE.FARM_RUNNING = true so mid-cycle checks don't abort early
        -- FARM_STOP_AFTER = true tells the loop to break after this cycle ends
        FARM_STOP_AFTER = true
        _G.EXE.FARM_RUNNING    = true
        TWN(T_PILL, {BackgroundColor3 = CFG.COL.YEL})
        TWN(T_KNOB, {Position = UDim2.new(0, 23, 0.5, -9)})
        NOTIFY("Farm", "Finishing current cycle... will stop after delivery.", 5)
    end)

    B_STOP.MouseButton1Click:Connect(function()
        SHOW_MODAL(false)
        -- Kill the thread instantly
        _G.EXE.FARM_RUNNING    = false
        FARM_STOP_AFTER = false
        if _G.EXE.FARM_THREAD then
            task.cancel(_G.EXE.FARM_THREAD)
            _G.EXE.FARM_THREAD = nil
        end
        TWN(T_PILL, {BackgroundColor3 = CFG.COL.GRY})
        TWN(T_KNOB, {Position = UDim2.new(0, 3, 0.5, -9)})
        NOTIFY("Farm", "Auto Farm stopped immediately.", 3)
    end)

    B_CANCEL.MouseButton1Click:Connect(function()
        SHOW_MODAL(false)
        NOTIFY("Farm", "Resumed. Farm is still running.", 2)
    end)

    -- ── TOGGLE LOGIC ────────────────────────────────────────
    -- Register callback so the loop can reset the pill when it stops naturally
    FARM_PILL_RESET_CB = function()
        TWN(T_PILL, {BackgroundColor3 = CFG.COL.GRY})
        TWN(T_KNOB, {Position = UDim2.new(0, 3, 0.5, -9)})
    end

    local function SET_FARM_TOG(ON)
        if ON then
            _G.EXE.FARM_RUNNING    = true
            FARM_STOP_AFTER = false
            TWN(T_PILL, {BackgroundColor3 = CFG.COL.ACC})
            TWN(T_KNOB, {Position = UDim2.new(0, 23, 0.5, -9)})
            NOTIFY("Farm", "Auto Farm started | Plant: " .. FARM_PLANTA .. " | Mode: " .. MODO_FARM, 4)
            START_FARM_LOOP()
        else
            SHOW_MODAL(true)
        end
    end

    local T_CLK = Instance.new("TextButton", TOG_ROW)
    T_CLK.Size = UDim2.new(1, 0, 1, 0)
    T_CLK.BackgroundTransparency = 1
    T_CLK.Text = ""
    T_CLK.ZIndex = 5
    T_CLK.MouseButton1Click:Connect(function() SET_FARM_TOG(not _G.EXE.FARM_RUNNING) end)

    -- ── DROPDOWN: SELECT PLANTA ─────────────────────────────
    local function MK_DRP(PARENT, DEFAULT_TXT, LO)
        local WRAP = Instance.new("Frame", PARENT)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.ClipsDescendants = false
        WRAP.LayoutOrder = LO

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        FRM.BackgroundTransparency = 0.3
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 10
        RND(FRM, 8)
        STR(FRM, CFG.COL.GRY, 1)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. DEFAULT_TXT
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.Gotham
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 11

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 18, 0, 18)
        ICO.Position = UDim2.new(1, -28, 0.5, -9)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 12

        local SSCR = Instance.new("ScrollingFrame", FRM)
        SSCR.Size = UDim2.new(1, 0, 0, 130)
        SSCR.Position = UDim2.new(0, 0, 0, 35)
        SSCR.BackgroundTransparency = 1
        SSCR.BorderSizePixel = 0
        SSCR.ScrollBarThickness = 2
        SSCR.ScrollBarImageColor3 = CFG.COL.ACC
        SSCR.ZIndex = 12

        local SLAY = Instance.new("UIListLayout", SSCR)
        SLAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN()
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 165)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 165)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, ICO=ICO, SCR=SSCR, LAY=SLAY, CLOSE=CLOSE }
    end

    -- Build SELECT PLANTA dropdown
    local D1 = MK_DRP(CARD, "Daisy  (Lv.0)", 3)

    for _, p in ipairs(PLANT_DATA) do
        local ITM = Instance.new("TextButton", D1.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. p.name .. "  (Lv." .. p.lvl .. ")"
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 13

        local playerLvl = GET_TRAPPER_LVL()
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            local lvl = GET_TRAPPER_LVL()
            TWN(ITM, {TextColor3 = lvl >= p.lvl and CFG.COL.TXT or CFG.COL.RED}, 0.1)
        end)
        if playerLvl >= p.lvl then
            ITM.TextColor3 = CFG.COL.TXT
        else
            ITM.TextColor3 = CFG.COL.GRY -- dim if locked
        end

        ITM.MouseButton1Click:Connect(function()
            local curLvl = GET_TRAPPER_LVL()
            if curLvl < p.lvl then
                NOTIFY("Insufficient Level",
                    p.name .. " requires Lv." .. p.lvl .. ". Your level: " .. curLvl, 5)
                return
            end
            FARM_PLANTA = p.name
            D1.BTN.Text = "  " .. p.name .. "  (Lv." .. p.lvl .. ")"
            D1.CLOSE()
        end)
    end
    D1.SCR.CanvasSize = UDim2.new(0, 0, 0, D1.LAY.AbsoluteContentSize.Y)

    -- ── DROPDOWN: FARM METHOD ───────────────────────────────
    local D2 = MK_DRP(CARD, "Method A – Separated", 4)

    local METHODS = {
        { label = "Method A – Separated", val = "A" },
        { label = "Method B – Per Pot",  val = "B" },
    }
    for _, m in ipairs(METHODS) do
        local ITM = Instance.new("TextButton", D2.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. m.label
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 13
        ITM.MouseButton1Click:Connect(function()
            MODO_FARM = m.val
            D2.BTN.Text = "  " .. m.label
            D2.CLOSE()
        end)
    end
    D2.SCR.CanvasSize = UDim2.new(0, 0, 0, D2.LAY.AbsoluteContentSize.Y)

    -- ── DROPDOWN: FARM CONFIG ────────────────────────────────
    local D3 = MK_DRP(CARD, "Config 1 – Normal (4 Pots)", 5)

    local CONFIGS = {
        { label = "Config 1 – Normal (4 Pots)",          val = 1 },
        { label = "Config 2 – Beta (Multi-Wave) 🧪",   val = 2 },
    }
    for _, c in ipairs(CONFIGS) do
        local ITM = Instance.new("TextButton", D3.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. c.label
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 13
        -- Config 2 shown slightly dimmed to signal beta
        ITM.TextColor3 = (c.val == 2) and Color3.fromRGB(255, 180, 80) or CFG.COL.TXT
        ITM.MouseButton1Click:Connect(function()
            FARM_CONFIG = c.val
            D3.BTN.Text = "  " .. c.label
            D3.CLOSE()
            if c.val == 2 then
                NOTIFY("Farm Config", "⚠️ Beta Mode active. Use with caution.", 5)
            end
        end)
    end
    D3.SCR.CanvasSize = UDim2.new(0, 0, 0, D3.LAY.AbsoluteContentSize.Y)

    -- ── BUTTON: UPDATE BICARBONATE ───────────────────────────
    local ACT_BTN = Instance.new("TextButton", CARD)
    ACT_BTN.Size = UDim2.new(1, 0, 0, 36)
    ACT_BTN.BackgroundColor3 = CFG.COL.BG
    ACT_BTN.BackgroundTransparency = 0.82
    ACT_BTN.BorderSizePixel = 0
    ACT_BTN.Text = "Upgrade Plant Fertilizer"
    ACT_BTN.TextColor3 = CFG.COL.TXT
    ACT_BTN.Font = Enum.Font.GothamBold
    ACT_BTN.TextSize = 13
    ACT_BTN.LayoutOrder = 6
    ACT_BTN.AutoButtonColor = false
    RND(ACT_BTN, 10)

    local BTN_STR = STR(ACT_BTN, CFG.COL.ACC, 1.2)
    BTN_STR.Transparency = 0.8
    BTN_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local BTN_GRAD = Instance.new("UIGradient", ACT_BTN)
    BTN_GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
    })
    BTN_GRAD.Rotation = 45
    BTN_GRAD.Transparency = NumberSequence.new(0.5)

    ACT_BTN.MouseEnter:Connect(function()
        TWN(ACT_BTN, {BackgroundTransparency = 0.7, BackgroundColor3 = CFG.COL.ACC}, 0.2)
        TWN(BTN_STR, {Transparency = 0.5}, 0.2)
    end)
    ACT_BTN.MouseLeave:Connect(function()
        TWN(ACT_BTN, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG}, 0.2)
        TWN(BTN_STR, {Transparency = 0.8}, 0.2)
    end)

    ACT_BTN.MouseButton1Click:Connect(function()
        TWN(ACT_BTN, {BackgroundTransparency = 0.4, TextSize = 12}, 0.1)
        task.wait(0.1)
        TWN(ACT_BTN, {BackgroundTransparency = 0.7, TextSize = 13}, 0.1)

        -- Read level before
        local lvlBefore = 0
        pcall(function()
            lvlBefore = LPLR.Job_Data.Fertilizer.Value
        end)

        -- Fire purchase
        local ok, res = pcall(function()
            return InquireFarm_R:InvokeServer("Purchase", "Fertilizer")
        end)

        -- Read level after
        task.wait(0.5)
        local lvlAfter = 0
        pcall(function()
            lvlAfter = LPLR.Job_Data.Fertilizer.Value
        end)

        if ok and res then
            local diff = lvlAfter - lvlBefore
            if diff > 0 then
                NOTIFY("Bicarbonate", "✅ Purchased! Fertilizer increased +" .. diff .. " (Total: " .. lvlAfter .. ")", 5)
            else
                NOTIFY("Bicarbonate", "✅ Purchased! Fertilizer: " .. lvlAfter, 4)
            end
        else
            NOTIFY("Bicarbonate", "❌ Purchase failed.", 4)
        end
    end)
end)()

-- ── CANDY FARM STATE + LOGIC ─────────────────────────────
-- (Flags now in _G.EXE)
local CC_N_HORNOS = 2  -- default

local RS_CC = game:GetService("ReplicatedStorage")

local CC_HORNOS_IDX = {3,20,10,2,18,17,16,15,14,13,12,11,19,9,8,7,6,5,4}
local CC_SPAWN = workspace.spawn_Assets.Points["Trinity Ave. Plaza"]
local CC_POS_SHOP  = Vector3.new(-411.15,  4.85,  459.43)
local CC_POS_VENTA = Vector3.new(  62.55,  4.10, -153.50)
local CC_ZONA_SEG  = Vector3.new(-222.87, -30.70, 453.41)

local function CC_STOP_CHECK() return not _G.EXE.CC_RUNNING end

local function CC_SPAWN_TP(pos)
    if CC_STOP_CHECK() then return end
    TP_CLASSIC(pos)
    task.wait(0.1)
end

local function CC_EQUIP(name)
    if CC_STOP_CHECK() then return end
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum:UnequipTools() task.wait(0.15)
    local tool = LPLR.Backpack:FindFirstChild(name)
    if tool then hum:EquipTool(tool) task.wait(0.3) end
end

-- Hold helper (igual que BF_HOLD: sujeta el prompt por su HoldDuration)
local function CC_HOLD(prompt)
    if not prompt or not prompt.Enabled then return end
    local dur = prompt.HoldDuration
    if dur and dur > 0 then
        -- Enfocar camara al prompt
        local cam  = workspace.CurrentCamera
        local char = LPLR.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local targetPos = prompt.Parent and prompt.Parent:IsA("BasePart")
            and prompt.Parent.Position
            or (prompt.Parent and prompt.Parent:IsA("Attachment")
            and prompt.Parent.WorldPosition)
            or nil
        if hrp and targetPos then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0), targetPos)
        end
        -- Hacer hold
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(dur + 0.3)
            prompt:InputHoldEnd()
        end)
        -- Restaurar camara
        pcall(function()
            if char then cam.CameraSubject = char:FindFirstChildOfClass("Humanoid") end
            cam.CameraType = Enum.CameraType.Custom
        end)
    else
        fireproximityprompt(prompt)
    end
end

local function CC_COUNT(name)
    local n = 0
    for _, v in ipairs(LPLR.Backpack:GetChildren()) do
        if v.Name == name then n += 1 end
    end
    return n
end

local function CC_GET_PROMPT(idx)
    return workspace.Jobs.Candy_Cooking.Ovens:GetChildren()[idx].proxAtt.ProximityPrompt
end

local function CC_GET_POS(idx)
    return workspace.Jobs.Candy_Cooking.Ovens:GetChildren()[idx].proxAtt.WorldPosition
end

local function CC_FREE_OVENS(n)
    local ovens = workspace.Jobs.Candy_Cooking.Ovens:GetChildren()
    local res, used = {}, {}
    for _, idx in ipairs(CC_HORNOS_IDX) do
        if #res >= n then break end
        local ov = ovens[idx]
        if not ov or used[idx] then continue end
        local ok, pr = pcall(function() return ov.proxAtt.ProximityPrompt end)
        if ok and pr.Enabled and pr.ActionText == "Boil" then
            table.insert(res, idx) used[idx] = true
        end
    end
    return res
end

local function CC_WAIT_PROMPT(idx, txt, timeout)
    local t = 0
    while t < (timeout or 120) do
        if CC_STOP_CHECK() then return false end
        local p = CC_GET_PROMPT(idx)
        if p.Enabled and p.ActionText == txt then return true end
        task.wait(0.2) t += 0.2
    end
    return false
end

local function CC_WAIT_OFF(idx, timeout)
    local t = 0
    while CC_GET_PROMPT(idx).Enabled and t < (timeout or 30) do
        if CC_STOP_CHECK() then return end
        task.wait(0.1) t += 0.1
    end
    task.wait(0.1)
end

local function CC_PUT_GELATIN(idx)
    for _ = 1, 5 do
        if CC_STOP_CHECK() then return false end
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
        local tool = LPLR.Backpack:FindFirstChild("Raw Gelatin")
        if tool and hum then hum:EquipTool(tool) task.wait(0.05) end
        CC_HOLD(CC_GET_PROMPT(idx))
        local t = 0
        while t < 2 do
            task.wait(0.1) t += 0.1
            local p = CC_GET_PROMPT(idx)
            if not p.Enabled or p.ActionText ~= "Place Gelatin" then return true end
        end
        local p = CC_GET_PROMPT(idx)
        if not p.Enabled or p.ActionText ~= "Place Gelatin" then return true end
        task.wait(0.2)
    end
    return false
end

local function CC_DO_CYCLE()
    if CC_STOP_CHECK() then return end

    -- 1. Comprar ingredientes
    local n = CC_N_HORNOS
    if CC_COUNT("Raw Gelatin") < n or CC_COUNT("Seasoning") < n or CC_COUNT("Bi-Carb") < n then
        CC_SPAWN_TP(CC_POS_SHOP)
        task.wait(0.4)
        for i = 1, n do
            if CC_STOP_CHECK() then return end
            RS_CC.Remotes.Purchase:FireServer("Bi-Carb",     workspace.NPCs.Paulie) task.wait(0.7)
            RS_CC.Remotes.Purchase:FireServer("Raw Gelatin", workspace.NPCs.Paulie) task.wait(0.7)
            RS_CC.Remotes.Purchase:FireServer("Seasoning",   workspace.NPCs.Paulie) task.wait(0.7)
        end
        if CC_COUNT("Raw Gelatin") < 1 then
            NOTIFY("Candy Farm", "No ingredients, retrying...", 4)
            return
        end
    end

    -- 2. Buscar hornos
    local ovens = CC_FREE_OVENS(n)
    if #ovens == 0 then
        NOTIFY("Candy Farm", "No free ovens, waiting 5s...", 3)
        task.wait(5) return
    end

    -- 3. Boil
    for _, idx in ipairs(ovens) do
        if CC_STOP_CHECK() then return end
        CC_SPAWN_TP(CC_GET_POS(idx))
        if CC_WAIT_PROMPT(idx, "Boil", 10) then
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:UnequipTools() end
            task.wait(0.15)
            CC_HOLD(CC_GET_PROMPT(idx))
            CC_WAIT_OFF(idx, 10)
        end
    end

    -- Safe zone — wait for water to boil
    CC_SPAWN_TP(CC_ZONA_SEG)
    NOTIFY("Candy Farm", "Waiting for water to boil...", 3)
    for _, idx in ipairs(ovens) do
        if CC_STOP_CHECK() then return end
        CC_WAIT_PROMPT(idx, "Place Gelatin", 180)
    end

    -- 4. Ingredientes
    for _, idx in ipairs(ovens) do
        if CC_STOP_CHECK() then return end
        RS_CC.Remotes.Spawn:FireServer(CC_SPAWN)
        local _ccPos = CC_SPAWN.Position
        local _w = 0
        repeat task.wait(0.05); _w += 0.05
            local _c = LPLR.Character; local _h = _c and _c:FindFirstChild("HumanoidRootPart")
            if _h and (_h.Position - _ccPos).Magnitude < 60 then break end
        until _w > 3
        TP_CLASSIC(CC_GET_POS(idx))
        task.wait(0.2)

        CC_PUT_GELATIN(idx)
        CC_WAIT_PROMPT(idx, "Add Ingredients", 15)
        CC_EQUIP("Seasoning")
        CC_HOLD(CC_GET_PROMPT(idx))
        CC_WAIT_OFF(idx, 5)
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end task.wait(0.1)

        CC_WAIT_PROMPT(idx, "Add Ingredients", 15)
        CC_EQUIP("Bi-Carb")
        CC_HOLD(CC_GET_PROMPT(idx))
        CC_WAIT_OFF(idx, 5)
        if hum then hum:UnequipTools() end task.wait(0.1)
    end

    -- 5. Recoger
    CC_SPAWN_TP(CC_ZONA_SEG)
    NOTIFY("Candy Farm", "Cooking... waiting to collect.", 4)

    local function CC_HAS_GELATIN()
        -- Revisa backpack y equipado
        if LPLR.Backpack:FindFirstChild("Gelatin Brick") then return true end
        local char = LPLR.Character
        if char and char:FindFirstChild("Gelatin Brick") then return true end
        return false
    end

    for _, idx in ipairs(ovens) do
        if CC_STOP_CHECK() then return end
        -- Wait for Collect
        local t = 0
        while t < 180 do
            if CC_STOP_CHECK() then return end
            local p = CC_GET_PROMPT(idx)
            if p.Enabled and p.ActionText == "Collect" then break end
            task.wait(0.2) t += 0.2
        end

        -- Recoger con retry: si no aparece el Gelatin Brick, volver a intentar
        local collected = false
        for attempt = 1, 4 do
            if CC_STOP_CHECK() then return end
            CC_SPAWN_TP(CC_GET_POS(idx))
            CC_WAIT_PROMPT(idx, "Collect", 10)
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:UnequipTools() end task.wait(0.15)
            CC_HOLD(CC_GET_PROMPT(idx))
            CC_WAIT_OFF(idx, 10)
            task.wait(0.3)
            if CC_HAS_GELATIN() then
                collected = true
                break
            end
            -- No se recibio — reintentar de inmediato
            NOTIFY("Candy Farm", "No recibido, reintentando... (" .. attempt .. "/4)", 2)
        end
        if not collected then
            NOTIFY("Candy Farm", "⚠️ Could not pick up oven " .. idx, 3)
        end
    end

    -- 6. Vender
    CC_SPAWN_TP(CC_POS_VENTA)
    task.wait(0.4)
    local ok, res = pcall(function()
        return RS_CC.Remotes.CandyDropOff:InvokeServer(workspace.NPCs.Tony)
    end)
    if ok and res then
        NOTIFY("Candy Farm", "✅ Sold! Restarting...", 4)
    else
        NOTIFY("Candy Farm", "❌ Sale failed, retrying...", 4)
    end
end

local function CC_START()
    _G.EXE.CC_RUNNING = true
    _G.EXE.CC_THREAD = task.spawn(function()
        NOTIFY("Candy Farm", "Started! Ovens: " .. CC_N_HORNOS, 3)
        while _G.EXE.CC_RUNNING do
            local ok, err = pcall(CC_DO_CYCLE)
            if not ok then
                NOTIFY("Candy Farm", "Error: " .. tostring(err), 4)
                task.wait(2)
            end
            if _G.EXE.CC_RUNNING then task.wait(0.5) end
        end
        NOTIFY("Candy Farm", "Stopped.", 3)
    end)
end

local function CC_STOP()
    _G.EXE.CC_RUNNING = false
    if _G.EXE.CC_THREAD then
        task.cancel(_G.EXE.CC_THREAD)
        _G.EXE.CC_THREAD = nil
    end
end

-- ── CANDY FARM UI CARD (left column, below Plant Shovel) ──
;(function()  -- register isolation: candy farm UI
    local CC_CARD = Instance.new("Frame", FARM_ROW_L)
    CC_CARD.Size = UDim2.new(1, 0, 0, 0)
    CC_CARD.AutomaticSize = Enum.AutomaticSize.Y
    CC_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    CC_CARD.BackgroundTransparency = 0.2
    CC_CARD.BorderSizePixel = 0
    CC_CARD.LayoutOrder = 2
    RND(CC_CARD, 12)
    STR(CC_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local CC_LAY = Instance.new("UIListLayout", CC_CARD)
    CC_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    CC_LAY.Padding = UDim.new(0, 10)

    local CC_PAD = Instance.new("UIPadding", CC_CARD)
    CC_PAD.PaddingTop    = UDim.new(0, 10)
    CC_PAD.PaddingBottom = UDim.new(0, 12)
    CC_PAD.PaddingLeft   = UDim.new(0, 12)
    CC_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local CC_HDR = Instance.new("Frame", CC_CARD)
    CC_HDR.Size = UDim2.new(1, 0, 0, 35)
    CC_HDR.BackgroundTransparency = 1
    CC_HDR.LayoutOrder = 0

    local CC_ICN = Instance.new("ImageLabel", CC_HDR)
    CC_ICN.Size = UDim2.new(0, 32, 0, 32)
    CC_ICN.Position = UDim2.new(0, 0, 0.5, -16)
    CC_ICN.BackgroundTransparency = 1
    CC_ICN.Image = "rbxassetid://84180289173085"
    CC_ICN.ImageColor3 = CFG.COL.YEL

    local CC_HTL = Instance.new("TextLabel", CC_HDR)
    CC_HTL.Size = UDim2.new(1, -40, 1, 0)
    CC_HTL.Position = UDim2.new(0, 40, 0, 0)
    CC_HTL.BackgroundTransparency = 1
    CC_HTL.Text = "Candy Farm"
    CC_HTL.TextColor3 = CFG.COL.TXT
    CC_HTL.Font = Enum.Font.GothamBold
    CC_HTL.TextSize = 18
    CC_HTL.TextXAlignment = Enum.TextXAlignment.Left

    -- Divider
    local CC_DIV = Instance.new("Frame", CC_CARD)
    CC_DIV.Size = UDim2.new(1, 0, 0, 1)
    CC_DIV.BackgroundColor3 = CFG.COL.ACC
    CC_DIV.BackgroundTransparency = 0.85
    CC_DIV.BorderSizePixel = 0
    CC_DIV.LayoutOrder = 1

    -- Toggle
    local CC_TOG_ROW = Instance.new("Frame", CC_CARD)
    CC_TOG_ROW.Size = UDim2.new(1, 0, 0, 36)
    CC_TOG_ROW.BackgroundTransparency = 1
    CC_TOG_ROW.LayoutOrder = 2

    local CC_LBL = Instance.new("TextLabel", CC_TOG_ROW)
    CC_LBL.Size = UDim2.new(1, -60, 1, 0)
    CC_LBL.BackgroundTransparency = 1
    CC_LBL.Text = "Auto Candy Farm"
    CC_LBL.TextColor3 = CFG.COL.TXT
    CC_LBL.Font = Enum.Font.Gotham
    CC_LBL.TextSize = 14
    CC_LBL.TextXAlignment = Enum.TextXAlignment.Left

    local CC_PILL = Instance.new("Frame", CC_TOG_ROW)
    CC_PILL.Size = UDim2.new(0, 44, 0, 24)
    CC_PILL.Position = UDim2.new(1, -44, 0.5, -12)
    CC_PILL.BackgroundColor3 = CFG.COL.GRY
    CC_PILL.BorderSizePixel = 0
    RND(CC_PILL, 12)

    local CC_KNOB = Instance.new("Frame", CC_PILL)
    CC_KNOB.Size = UDim2.new(0, 18, 0, 18)
    CC_KNOB.Position = UDim2.new(0, 3, 0.5, -9)
    CC_KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
    CC_KNOB.BorderSizePixel = 0
    RND(CC_KNOB, 9)

    local function SET_CC_TOG(ON)
        if ON then
            _G.EXE.CC_RUNNING = true
            TWN(CC_PILL, {BackgroundColor3 = CFG.COL.YEL})
            TWN(CC_KNOB, {Position = UDim2.new(0, 23, 0.5, -9)})
            CC_START()
        else
            CC_STOP()
            TWN(CC_PILL, {BackgroundColor3 = CFG.COL.GRY})
            TWN(CC_KNOB, {Position = UDim2.new(0, 3, 0.5, -9)})
        end
    end

    local CC_CLK = Instance.new("TextButton", CC_TOG_ROW)
    CC_CLK.Size = UDim2.new(1, 0, 1, 0)
    CC_CLK.BackgroundTransparency = 1
    CC_CLK.Text = ""
    CC_CLK.ZIndex = 5
    CC_CLK.MouseButton1Click:Connect(function()
        SET_CC_TOG(not _G.EXE.CC_RUNNING)
    end)

    -- Dropdown: N_HORNOS
    local CC_DRP_WRAP = Instance.new("Frame", CC_CARD)
    CC_DRP_WRAP.Size = UDim2.new(1, 0, 0, 35)
    CC_DRP_WRAP.BackgroundTransparency = 1
    CC_DRP_WRAP.ClipsDescendants = false
    CC_DRP_WRAP.LayoutOrder = 3

    local CC_DRP_FRM = Instance.new("Frame", CC_DRP_WRAP)
    CC_DRP_FRM.Size = UDim2.new(1, 0, 0, 35)
    CC_DRP_FRM.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    CC_DRP_FRM.BackgroundTransparency = 0.3
    CC_DRP_FRM.BorderSizePixel = 0
    CC_DRP_FRM.ClipsDescendants = true
    CC_DRP_FRM.ZIndex = 10
    RND(CC_DRP_FRM, 8)
    STR(CC_DRP_FRM, CFG.COL.GRY, 1)

    local CC_DRP_BTN = Instance.new("TextButton", CC_DRP_FRM)
    CC_DRP_BTN.Size = UDim2.new(1, 0, 0, 35)
    CC_DRP_BTN.BackgroundTransparency = 1
    CC_DRP_BTN.Text = "  Ovens: 2"
    CC_DRP_BTN.TextColor3 = CFG.COL.TXT
    CC_DRP_BTN.Font = Enum.Font.Gotham
    CC_DRP_BTN.TextSize = 13
    CC_DRP_BTN.TextXAlignment = Enum.TextXAlignment.Left
    CC_DRP_BTN.ZIndex = 11

    local CC_DRP_ICO = Instance.new("ImageLabel", CC_DRP_BTN)
    CC_DRP_ICO.Size = UDim2.new(0, 16, 0, 16)
    CC_DRP_ICO.Position = UDim2.new(1, -24, 0.5, -8)
    CC_DRP_ICO.BackgroundTransparency = 1
    CC_DRP_ICO.Image = "rbxassetid://6031091004"
    CC_DRP_ICO.ImageColor3 = CFG.COL.ACC
    CC_DRP_ICO.ZIndex = 12

    local CC_DRP_SCR = Instance.new("ScrollingFrame", CC_DRP_FRM)
    CC_DRP_SCR.Size = UDim2.new(1, 0, 0, 120)
    CC_DRP_SCR.Position = UDim2.new(0, 0, 0, 35)
    CC_DRP_SCR.BackgroundTransparency = 1
    CC_DRP_SCR.BorderSizePixel = 0
    CC_DRP_SCR.ScrollBarThickness = 2
    CC_DRP_SCR.ScrollBarImageColor3 = CFG.COL.ACC
    CC_DRP_SCR.ZIndex = 12

    local CC_DRP_LAY = Instance.new("UIListLayout", CC_DRP_SCR)
    CC_DRP_LAY.SortOrder = Enum.SortOrder.LayoutOrder

    local CC_DRP_OPEN = false
    local function CC_DRP_CLOSE()
        CC_DRP_OPEN = false
        TWN(CC_DRP_FRM,  {Size = UDim2.new(1, 0, 0, 35)})
        TWN(CC_DRP_WRAP, {Size = UDim2.new(1, 0, 0, 35)})
        TWN(CC_DRP_ICO,  {Rotation = 0})
    end
    local function CC_DRP_DO_OPEN()
        CC_DRP_OPEN = true
        TWN(CC_DRP_FRM,  {Size = UDim2.new(1, 0, 0, 155)})
        TWN(CC_DRP_WRAP, {Size = UDim2.new(1, 0, 0, 155)})
        TWN(CC_DRP_ICO,  {Rotation = 180})
    end

    CC_DRP_BTN.MouseButton1Click:Connect(function()
        if CC_DRP_OPEN then CC_DRP_CLOSE() else CC_DRP_DO_OPEN() end
    end)

    for n = 1, 4 do
        local ITM = Instance.new("TextButton", CC_DRP_SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. n .. " Oven" .. (n > 1 and "s" or "")
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 13
        ITM.LayoutOrder = n
        ITM.MouseButton1Click:Connect(function()
            CC_N_HORNOS = n
            CC_DRP_BTN.Text = "  Ovens: " .. n
            CC_DRP_CLOSE()
        end)
    end
    CC_DRP_SCR.CanvasSize = UDim2.new(0, 0, 0, CC_DRP_LAY.AbsoluteContentSize.Y)
end)()
-- Variables de estado Card Farm hoisted al scope externo para evitar limit-200
local CF_TARJETA  = "Premium Card"
local CF_COSTO    = 2600
local CF_OBJETIVO = 3600
local _CF_COL_R2  = FARM_ROW_R

do
    local COL_R2 = _CF_COL_R2

    -- ── CARD FARM STATE ─────────────────────────────────────
    -- (Flags now in _G.EXE)

    local CF_RIESGO_MAP = {
        [1000] = {0.35, 0.50},
        [2000] = {0.45, 0.60},
        [3000] = {0.50, 0.65},
        [3600] = {0.55, 0.70},
        [4000] = {0.62, 0.78},
        [5000] = {0.68, 0.84},
    }
    local function CF_GET_RIESGO()
        local r = CF_RIESGO_MAP[CF_OBJETIVO]
        return r and r[1] or 0.55, r and r[2] or 0.70
    end

    -- ── SKIMMING REMOTES ────────────────────────────────────
    local CF_RS       = game:GetService("ReplicatedStorage")
    local CF_Purchase = CF_RS.Remotes.Purchase
    local CF_Skim     = CF_RS.Remotes.Skimming
    local CF_PullOut  = CF_Skim.PullOut
    local CF_Update   = CF_Skim.Update

    -- ── HELPERS ─────────────────────────────────────────────
    local function CF_SPAWN(locName)
        local pt = workspace.spawn_Assets.Points:FindFirstChild(locName)
                    or workspace.spawn_Assets.Points["Trinity Ave. Plaza"]
        local ptPos = pt.Position
        CF_RS.Remotes.Spawn:FireServer(pt)
        local w = 0
        repeat task.wait(0.05); w += 0.05
            local c = LPLR.Character; local h = c and c:FindFirstChild("HumanoidRootPart")
            if h and (h.Position - ptPos).Magnitude < 60 then break end
        until w > 3
    end


    local function CF_TP(pos)
        TP_CLASSIC(pos)
        task.wait(0.1)
    end

    local function CF_EQUIP(name)
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local tool = LPLR.Backpack:FindFirstChild(name)
        if tool and hum then hum:EquipTool(tool) task.wait(0.3) end
    end

    local function CF_WALLET()
        local ok, v = pcall(function() return LPLR.Player_Data.Wallet.Value end)
        return ok and v or 0
    end

    -- ── PROMPT TRIGGER ─────────────────────────────────────
    local function TriggerPrompt(prompt)
        if not prompt then return end
        prompt:InputHoldBegin()
        if prompt.HoldDuration > 0 then
            task.wait(prompt.HoldDuration + 0.2)
        else
            task.wait(0.25)
        end
        prompt:InputHoldEnd()
    end

    local function CF_BUY(T2_PILL, T2_KNOB)
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        -- Check backpack or character hand (ya tenemos la card)
        if LPLR.Backpack:FindFirstChild(CF_TARJETA) or char:FindFirstChild(CF_TARJETA) then
            NOTIFY("Card Farm", "Card ya en inventario, skip compra", 2)
            return true
        end

        local w = CF_WALLET()
        if w < CF_COSTO then
            NOTIFY("Card Farm", "Not enough funds! Need $" .. CF_COSTO .. " have $" .. math.floor(w), 5)
            return false
        end

        for attempt = 1, 5 do
            CF_SPAWN("Trinity Ave. Plaza")
            CF_TP(Vector3.new(-329.43, 29.89, 32.39))
            CF_Purchase:FireServer(CF_TARJETA, workspace.NPCs.Douglas)
            
            -- Wait up to 5s for the card to appear
            local t = 0
            while t < 5 and _G.EXE.CF_RUNNING do
                task.wait(0.5); t += 0.5
                char = LPLR.Character or LPLR.CharacterAdded:Wait()
                if LPLR.Backpack:FindFirstChild(CF_TARJETA) or char:FindFirstChild(CF_TARJETA) then
                    NOTIFY("Card Farm", "✅ " .. CF_TARJETA .. " adquirida!", 2)
                    return true
                end
            end
            -- Si no se detectó, reintenta inmediatamente
            task.wait(0.1)
        end

        NOTIFY("Card Farm", "❌ Purchase failed after 5 attempts", 5)
        return false
    end

    local function CF_FIND_ATM()
        for _, atm in ipairs(workspace.Map.ATMs:GetChildren()) do
            local pp = atm:FindFirstChild("ProxPart")
            if pp then
                local pr = pp:FindFirstChild("ProximityPrompt")
                if pr and pr.Enabled then return atm, pr end
            end
        end
        return nil, nil
    end

    local function CF_DO_SKIM(atm, prompt)
        local sal, eme = CF_GET_RIESGO()
        local skimmingStarted = false
        local pp = atm:FindFirstChild("ProxPart")
        if not pp then return false, 0 end

        -- Loop de reintento para el TP e inicio de Skim
        for tp_attempt = 1, 3 do
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            CF_SPAWN("Trinity Ave. Plaza")
            
            -- TP un poco más cerca/directo
            CF_TP(pp.Position + Vector3.new(0, 0, 1.2))
            task.wait(0.5)
            CF_EQUIP(CF_TARJETA)
            task.wait(0.3)

            -- Cámara Scriptable apuntando al ATM para mejor registro
            local cam = workspace.CurrentCamera
            local prevType    = cam.CameraType
            local prevSubject = cam.CameraSubject
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0), pp.Position)

            -- Variable para confirmar inicio real
            local confirmed = false
            local conn
            conn = CF_Update.OnClientEvent:Connect(function() 
                confirmed = true 
                if conn then conn:Disconnect() conn = nil end
            end)

            -- Activar skim con el buffer mejorado
            TriggerPrompt(prompt)
            
            -- Esperar confirmación del servidor o desaparición del prompt (max 2.5s)
            local waitStart = tick()
            while tick() - waitStart < 2.5 and not confirmed and _G.EXE.CF_RUNNING do
                -- Si el prompt se desactiva o desaparece, el inicio es exitoso (feedback del usuario)
                if not prompt.Enabled or not prompt.Parent then
                    confirmed = true
                    break
                end
                task.wait(0.1)
            end

            -- Restaurar cámara
            if conn then conn:Disconnect() conn = nil end
            cam.CameraSubject = char:FindFirstChildOfClass("Humanoid") or LPLR.Character:FindFirstChildOfClass("Humanoid")
            cam.CameraType    = prevType

            if confirmed then
                skimmingStarted = true
                break
            else
                NOTIFY("Card Farm", "Interaction failed, retrying (" .. tp_attempt .. "/3)...", 3)
                task.wait(0.5)
            end
        end

        if not skimmingStarted then
            NOTIFY("Card Farm", "❌ Failed to start skimming after 3 attempts", 5)
            return false, 0
        end

        NOTIFY("Card Farm", "Skimming activo...", 3)

        local sal2, eme2 = CF_GET_RIESGO()
        local active, earned, caught = true, 0, false
        local cu, cb

        cb = CF_Skim.Bust.OnClientEvent:Connect(function()
            if active then
                active = false; caught = true
                cu:Disconnect(); cb:Disconnect()
                NOTIFY("Card Farm", "🚔 Busted! Retrying...", 4)
            end
        end)

        cu = CF_Update.OnClientEvent:Connect(function(dinero, riesgo, tiempo)
            if not active then return end
            earned = dinero
            local col = riesgo >= 0.5 and Color3.fromRGB(245,160,55) or Color3.fromRGB(72,210,140)
            NOTIFY("Card Farm",
                string.format("$%d / $%d  |  %d%% risk  |  %ds left",
                    math.floor(dinero), CF_OBJETIVO,
                    math.floor(riesgo * 100), math.floor(tiempo)), 2)

            if dinero >= CF_OBJETIVO then
                active = false; CF_PullOut:FireServer()
                cu:Disconnect(); cb:Disconnect()
            elseif riesgo >= sal2 and dinero >= CF_COSTO then
                active = false; CF_PullOut:FireServer()
                cu:Disconnect(); cb:Disconnect()
            elseif riesgo >= eme2 then
                active = false; CF_PullOut:FireServer()
                cu:Disconnect(); cb:Disconnect()
            end
        end)

        repeat task.wait(0.1) until not active or not _G.EXE.CF_RUNNING
        task.wait(1)
        return caught, earned
    end

    local function CF_START_LOOP(T2_PILL, T2_KNOB)
        _G.EXE.CF_THREAD = task.spawn(function()
            while _G.EXE.CF_RUNNING do
                if not CF_BUY(T2_PILL, T2_KNOB) then
                    -- Stop and reset toggle visually
                    _G.EXE.CF_RUNNING = false
                    _G.EXE.CF_THREAD = nil
                    TWN(T2_PILL, {BackgroundColor3 = CFG.COL.GRY})
                    TWN(T2_KNOB, {Position = UDim2.new(0, 3, 0.5, -9)})
                    break
                end
                if not _G.EXE.CF_RUNNING then break end

                local atm, pr = CF_FIND_ATM()
                if not atm then
                    NOTIFY("Card Farm", "No ATMs found, waiting 5s...", 4)
                    task.wait(5)
                    continue
                end

                local caught, earned = CF_DO_SKIM(atm, pr)
                if not _G.EXE.CF_RUNNING then break end

                if caught then
                    NOTIFY("Card Farm", "Caught — retrying in 3s...", 4)
                    task.wait(3)
                else
                    NOTIFY("Card Farm", "✅ Earned $" .. math.floor(earned) .. " — restarting cycle...", 4)
                    task.wait(1)
                end
            end
            _G.EXE.CF_RUNNING = false
            _G.EXE.CF_THREAD  = nil
            NOTIFY("Card Farm", "Auto Card Farm stopped.", 3)
            -- Reset toggle visually
            TWN(T2_PILL, {BackgroundColor3 = CFG.COL.GRY})
            TWN(T2_KNOB, {Position = UDim2.new(0, 3, 0.5, -9)})
        end)
    end

end  -- end Card Farm logic block

do  -- Card Farm UI block (split to avoid local register limit)
    local COL_R2 = _CF_COL_R2

    -- ── CARD WRAPPER ────────────────────────────────────────
    local CARD2 = Instance.new("Frame", COL_R2)
    CARD2.Size = UDim2.new(1, 0, 0, 0)
    CARD2.AutomaticSize = Enum.AutomaticSize.Y
    CARD2.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    CARD2.BackgroundTransparency = 0.2
    CARD2.BorderSizePixel = 0
    CARD2.LayoutOrder = 1
    RND(CARD2, 12)
    STR(CARD2, CFG.COL.ACC, 1).Transparency = 0.75

    local CPAD2 = Instance.new("UIPadding", CARD2)
    CPAD2.PaddingTop    = UDim.new(0, 10)
    CPAD2.PaddingBottom = UDim.new(0, 12)
    CPAD2.PaddingLeft   = UDim.new(0, 12)
    CPAD2.PaddingRight  = UDim.new(0, 12)

    local CLAY2 = Instance.new("UIListLayout", CARD2)
    CLAY2.SortOrder = Enum.SortOrder.LayoutOrder
    CLAY2.Padding = UDim.new(0, 10)

    -- ── HEADER ──────────────────────────────────────────────
    local HDR2 = Instance.new("Frame", CARD2)
    HDR2.Size = UDim2.new(1, 0, 0, 28)
    HDR2.BackgroundTransparency = 1
    HDR2.LayoutOrder = 0

    local ICN2 = Instance.new("ImageLabel", HDR2)
    ICN2.Size = UDim2.new(0, 24, 0, 24)
    ICN2.Position = UDim2.new(0, 0, 0.5, -12)
    ICN2.BackgroundTransparency = 1
    ICN2.Image = "rbxassetid://75077271724080"
    ICN2.ImageColor3 = CFG.COL.ACC

    local HTL2 = Instance.new("TextLabel", HDR2)
    HTL2.Size = UDim2.new(1, -34, 1, 0)
    HTL2.Position = UDim2.new(0, 32, 0, 0)
    HTL2.BackgroundTransparency = 1
    HTL2.Text = "Card Farm"
    HTL2.TextColor3 = CFG.COL.TXT
    HTL2.Font = Enum.Font.GothamBold
    HTL2.TextSize = 15
    HTL2.TextXAlignment = Enum.TextXAlignment.Left

    -- Divider
    local DIV2 = Instance.new("Frame", CARD2)
    DIV2.Size = UDim2.new(1, 0, 0, 1)
    DIV2.BackgroundColor3 = CFG.COL.ACC
    DIV2.BackgroundTransparency = 0.85
    DIV2.BorderSizePixel = 0
    DIV2.LayoutOrder = 1

    -- ── TOGGLE ──────────────────────────────────────────────
    local TOG2_ROW = Instance.new("Frame", CARD2)
    TOG2_ROW.Size = UDim2.new(1, 0, 0, 36)
    TOG2_ROW.BackgroundTransparency = 1
    TOG2_ROW.LayoutOrder = 2

    local T2_LBL = Instance.new("TextLabel", TOG2_ROW)
    T2_LBL.Size = UDim2.new(1, -60, 1, 0)
    T2_LBL.BackgroundTransparency = 1
    T2_LBL.Text = "Auto Card Farm"
    T2_LBL.TextColor3 = CFG.COL.TXT
    T2_LBL.Font = Enum.Font.Gotham
    T2_LBL.TextSize = 13
    T2_LBL.TextXAlignment = Enum.TextXAlignment.Left

    local T2_PILL = Instance.new("Frame", TOG2_ROW)
    T2_PILL.Size = UDim2.new(0, 44, 0, 24)
    T2_PILL.Position = UDim2.new(1, -44, 0.5, -12)
    T2_PILL.BackgroundColor3 = CFG.COL.GRY
    T2_PILL.BorderSizePixel = 0
    RND(T2_PILL, 12)

    local T2_KNOB = Instance.new("Frame", T2_PILL)
    T2_KNOB.Size = UDim2.new(0, 18, 0, 18)
    T2_KNOB.Position = UDim2.new(0, 3, 0.5, -9)
    T2_KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
    T2_KNOB.BorderSizePixel = 0
    RND(T2_KNOB, 9)

    local function SET_CF_TOG(ON)
        if ON then
            -- Check funds before even starting
            local w = CF_WALLET()
            if w < CF_COSTO then
                NOTIFY("Card Farm", "Not enough funds! Need $" .. CF_COSTO .. " have $" .. math.floor(w), 5)
                return -- don't turn on
            end
            _G.EXE.CF_RUNNING = true
            TWN(T2_PILL, {BackgroundColor3 = CFG.COL.ACC})
            TWN(T2_KNOB, {Position = UDim2.new(0, 23, 0.5, -9)})
            NOTIFY("Card Farm", "Started | Card: " .. CF_TARJETA .. " | Target: $" .. CF_OBJETIVO, 4)
            CF_START_LOOP(T2_PILL, T2_KNOB)
        else
            -- Stop immediately
            _G.EXE.CF_RUNNING = false
            if _G.EXE.CF_THREAD then task.cancel(_G.EXE.CF_THREAD) _G.EXE.CF_THREAD = nil end
            TWN(T2_PILL, {BackgroundColor3 = CFG.COL.GRY})
            TWN(T2_KNOB, {Position = UDim2.new(0, 3, 0.5, -9)})
            NOTIFY("Card Farm", "Stopped.", 3)
        end
    end

    local T2_CLK = Instance.new("TextButton", TOG2_ROW)
    T2_CLK.Size = UDim2.new(1, 0, 1, 0)
    T2_CLK.BackgroundTransparency = 1
    T2_CLK.Text = ""
    T2_CLK.ZIndex = 5
    T2_CLK.MouseButton1Click:Connect(function() SET_CF_TOG(not _G.EXE.CF_RUNNING) end)

    -- ── INLINE DROPDOWN BUILDER (local to this card) ────────
    local function MK_CF_DRP(DEFAULT_TXT, LO)
        local WRAP = Instance.new("Frame", CARD2)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.ClipsDescendants = false
        WRAP.LayoutOrder = LO

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        FRM.BackgroundTransparency = 0.3
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 10
        RND(FRM, 8)
        STR(FRM, CFG.COL.GRY, 1)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. DEFAULT_TXT
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.Gotham
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 11

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 18, 0, 18)
        ICO.Position = UDim2.new(1, -28, 0.5, -9)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 12

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 12

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H   = 0  -- set externally before first open
        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN(H)
            DRP_H   = H or DRP_H
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, ICO=ICO, SCR=SCR, LAY=LAY, CLOSE=CLOSE, OPEN=OPEN }
    end

    -- ── DROPDOWN 1: SELECT CARD ─────────────────────────────
    local D_CARD = MK_CF_DRP("Premium Card  —  $2,600", 3)
    D_CARD.SCR.Size = UDim2.new(1, 0, 0, 65)
    D_CARD.OPEN(65)  -- pre-load height so first click works
    D_CARD.CLOSE()   -- start closed

    local CARD_OPTIONS = {
        { label = "Premium Card  —  $2,600",  name = "Premium Card",  cost = 2600 },
        { label = "Standard Card  —  $1,200", name = "Standard Card", cost = 1200 },
    }
    for _, c in ipairs(CARD_OPTIONS) do
        local ITM = Instance.new("TextButton", D_CARD.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. c.label
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 13
        ITM.MouseButton1Click:Connect(function()
            CF_TARJETA = c.name
            CF_COSTO   = c.cost
            D_CARD.BTN.Text = "  " .. c.label
            D_CARD.CLOSE()
        end)
    end
    D_CARD.SCR.CanvasSize = UDim2.new(0, 0, 0, D_CARD.LAY.AbsoluteContentSize.Y)

    -- ── DROPDOWN 2: TARGET ──────────────────────────────────
    local D_OBJ = MK_CF_DRP("Target: $3,600", 4)
    D_OBJ.SCR.Size = UDim2.new(1, 0, 0, 185)
    D_OBJ.OPEN(185)
    D_OBJ.CLOSE()

    local OBJ_OPTIONS = {
        { label = "$1,000", val = 1000 },
        { label = "$2,000", val = 2000 },
        { label = "$3,000", val = 3000 },
        { label = "$3,600", val = 3600 },
        { label = "$4,000", val = 4000 },
        { label = "$5,000", val = 5000 },
    }
    for _, o in ipairs(OBJ_OPTIONS) do
        local ITM = Instance.new("TextButton", D_OBJ.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. o.label
        ITM.TextColor3 = CFG.COL.TXT
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 13
        ITM.MouseButton1Click:Connect(function()
            CF_OBJETIVO = o.val
            D_OBJ.BTN.Text = "  Target: " .. o.label
            D_OBJ.CLOSE()
        end)
    end
    D_OBJ.SCR.CanvasSize = UDim2.new(0, 0, 0, D_OBJ.LAY.AbsoluteContentSize.Y)
end

-- ============================================================
--  FARM → JOBS CARD  (Burger / Candy / Mop) – right column
-- ============================================================

-- ── WAREHOUSE BOX FARM STATE + LOGIC ────────────────────
_G.EXE.WH_THREAD  = nil
_G.EXE.WH_RUNNING = false
local RS_WH  = game:GetService("ReplicatedStorage")

local WH_CAM_CONN      = nil
local WH_CAM_PREV_TYPE = nil
local WH_CAM_PREV_SUB  = nil
local function WH_CAM_RESTORE()
    if WH_CAM_CONN then WH_CAM_CONN:Disconnect() WH_CAM_CONN = nil end
    local cam = workspace.CurrentCamera
    cam.CameraType    = WH_CAM_PREV_TYPE or Enum.CameraType.Custom
    cam.CameraSubject = WH_CAM_PREV_SUB  or (LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid"))
end

local function TriggerPrompt(prompt)
    if not prompt then return end
    prompt:InputHoldBegin()
    if prompt.HoldDuration > 0 then
        task.wait(prompt.HoldDuration + 0.2)
    else
        task.wait(0.25)
    end
    prompt:InputHoldEnd()
end

local function WH_STOP_CHECK() return not _G.EXE.WH_RUNNING end

local function WH_TP(pos)
    if WH_STOP_CHECK() then return end
    TP_CLASSIC(pos)
    task.wait(0.1)
end

local function WH_EQUIP(name)
    if WH_STOP_CHECK() then return end
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum:UnequipTools() task.wait(0.2)
    local tool = LPLR.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
    if tool then hum:EquipTool(tool) end
    task.wait(0.35)
end

local function WH_HAS(name)
    if LPLR.Backpack:FindFirstChild(name) then return true end
    local char = LPLR.Character
    return char and char:FindFirstChild(name) ~= nil
end

local function WH_IN_JOB()
    local ok, val = pcall(function() return LPLR.Job_Data.CurrentJob.Value end)
    return ok and val == "Warehouse"
end

local function WH_DO_ONE()
    if WH_STOP_CHECK() then return false end
    if not WH_IN_JOB() then
        WH_TP(Vector3.new(-1180.32, 3.80, 1341.05))
        task.wait(0.4)
        RS_WH.Remotes.JobAction:FireServer("StartJob", "Warehouse")
        task.wait(1)
    end
    if not WH_HAS("Box") then
        WH_TP(Vector3.new(-1183.66, 3.09, 1346.59))
        task.wait(0.3)
        fireproximityprompt(workspace.Jobs.Warehouse_Box.boxProx.ProximityPrompt)
        local wt = 0
        while wt < 8 do
            if WH_STOP_CHECK() then return false end
            if WH_HAS("Box") then break end
            task.wait(0.2) wt += 0.2
        end
        if not WH_HAS("Box") then return false end
    end
    local char = LPLR.Character or LPLR.CharacterAdded:Wait()
    local box  = LPLR.Backpack:FindFirstChild("Box") or char:FindFirstChild("Box")
    if not box then return false end
    local dropVal = box:FindFirstChild("Drop")
    if not dropVal or not dropVal.Value then return false end
    local dropPart = dropVal.Value
    local pp = dropPart:FindFirstChildOfClass("ProximityPrompt")
    if not pp then return false end
    local dropPos = dropPart.Position
    -- Equip first, then TP (no Spawn:FireServer after equip)
    LPLR.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
    task.wait(0.2)
    local tool = LPLR.Backpack:FindFirstChild("Box") or char:FindFirstChild("Box")
    if tool then LPLR.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool) end
    task.wait(0.35)
    -- TP without Spawn bypass (direct CFrame only)
    TP_CLASSIC(dropPos + Vector3.new(0, 0, 2))
    task.wait(0.6)

    -- ── Focus Camera on Delivery ────────────────────────────
    local cam = workspace.CurrentCamera
    local prevType = cam.CameraType
    local prevSub  = cam.CameraSubject
    cam.CameraType = Enum.CameraType.Scriptable
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0), dropPart.Position)
    end

    -- Hold the prompt — retry loop until box leaves inventory
    local deliveryTimer = 0
    local maxDeliveryWait = 11  -- max total seconds to wait
    while _G.EXE.WH_RUNNING and deliveryTimer < maxDeliveryWait do
        if not WH_HAS("Box") then break end  -- success!

        -- Make sure prompt still valid
        local freshPP = dropPart:FindFirstChildOfClass("ProximityPrompt")
        if not freshPP then break end

        -- Re-TP close to drop point so hold doesn't miss
        TP_CLASSIC(dropPos + Vector3.new(0, 0, 1.5))
        task.wait(0.1)

        -- Attempt the full hold
        freshPP:InputHoldBegin()
        local holdTime = math.max(freshPP.HoldDuration, 0)
        local held = 0
        while held < holdTime + 0.15 do
            if not _G.EXE.WH_RUNNING or not WH_HAS("Box") then break end
            task.wait(0.05)
            held += 0.05
        end
        freshPP:InputHoldEnd()

        task.wait(0.3)
        deliveryTimer += (holdTime + 0.3)
    end

    -- Restore Camera
    cam.CameraSubject = LPLR.Character:FindFirstChildOfClass("Humanoid")
    cam.CameraType    = prevType

    return not WH_HAS("Box")
end

local function WH_START()
    local cam = workspace.CurrentCamera
    WH_CAM_PREV_TYPE = cam.CameraType
    WH_CAM_PREV_SUB  = cam.CameraSubject
    _G.EXE.WH_RUNNING = true
    _G.EXE.WH_THREAD = task.spawn(function()
        NOTIFY("Box Farm", "Started!", 3)
        while _G.EXE.WH_RUNNING do
            local ok, err = pcall(WH_DO_ONE)
            if not ok then
                NOTIFY("Box Farm", "Error: " .. tostring(err), 4)
                task.wait(0.5)  -- retry faster
            end
            task.wait(0.3)
        end
        NOTIFY("Box Farm", "Stopped.", 3)
    end)
end

local function WH_STOP()
    _G.EXE.WH_RUNNING = false
    if _G.EXE.WH_THREAD then
        task.cancel(_G.EXE.WH_THREAD)
        _G.EXE.WH_THREAD = nil
    end
    WH_CAM_RESTORE()
end

;(function()  -- register isolation: burger farm logic
    -- ============================================================
    --  BURGER FARM | CEN_V2 Module
    --  Game: 104802908935290
    -- ============================================================

    local LPLR   = game:GetService("Players").LocalPlayer
    local RS     = game:GetService("ReplicatedStorage")
    local UIS    = game:GetService("UserInputService")

    -- ─── CONFIG ────────────────────────────────────────────────
    local BF = {}
    BF.RUNNING = false

    local POS_START     = Vector3.new(-178.45, 4.28, 102.87)
    local POS_FRIDGE    = Vector3.new(-180.27, 4.28, 110.26)

    local BF_OVEN_DEFS = {
        { getPrompt = function() return workspace.Jobs.Jerk_Center.Ovens:GetChildren()[1].proxAtt.ProximityPrompt end, pos = Vector3.new(-179.26, 4.85, 107.01) },
        { getPrompt = function() return workspace.Jobs.Jerk_Center.Ovens:GetChildren()[2].proxAtt.ProximityPrompt end, pos = Vector3.new(-180.04, 4.28, 103.69) },
        { getPrompt = function() return workspace.Jobs.Jerk_Center.Ovens:GetChildren()[3].proxAtt.ProximityPrompt end, pos = Vector3.new(-179.56, 4.28, 107.00) },
    }

    -- ─── BYPASS TP ─────────────────────────────────────────────
    -- Espera a que el spawn point esté listo (fix para cuando te acabas de unir)
    local SPAWN_PT = nil
    local SPAWN_POS = nil

    local function BF_INIT_SPAWN()
        if SPAWN_PT then return end
        local assets = workspace:WaitForChild("spawn_Assets", 10)
        if not assets then warn("[BF] spawn_Assets no encontrado") return end
        local points = assets:WaitForChild("Points", 10)
        if not points then warn("[BF] Points no encontrado") return end
        SPAWN_PT  = points:WaitForChild("Trinity Ave. Plaza", 10)
        if SPAWN_PT then
            SPAWN_POS = SPAWN_PT.Position
        else
            warn("[BF] Trinity Ave. Plaza no encontrado")
        end
    end

    local function BYPASS_TP(pos)
        BF_INIT_SPAWN()
        if not SPAWN_PT then
            warn("[BF] No hay spawn point, TP directo sin bypass")
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            local hrp  = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = CFrame.new(pos)
            return
        end
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        local hrp  = char:WaitForChild("HumanoidRootPart")

        -- Mandar al spawn
        RS.Remotes.Spawn:FireServer(SPAWN_PT)

        -- Esperar a llegar al spawn
        local waited = 0
        repeat
            task.wait(0.05)
            waited += 0.05
            char = LPLR.Character or LPLR.CharacterAdded:Wait()
            hrp  = char:WaitForChild("HumanoidRootPart")
        until (hrp.Position - SPAWN_POS).Magnitude < 50 or waited > 5

        -- Esperar un poco en el spawn para que el servidor registre la posicion
        task.wait(0.3)

        -- TP al destino en loop hasta que se quede (anti-rollback)
        local tpWaited = 0
        repeat
            char = LPLR.Character or LPLR.CharacterAdded:Wait()
            hrp  = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = CFrame.new(pos)
            task.wait(0.1)
            tpWaited += 0.1
            char = LPLR.Character or LPLR.CharacterAdded:Wait()
            hrp  = char:WaitForChild("HumanoidRootPart")
        until (hrp.Position - pos).Magnitude < 5 or tpWaited > 3

    end

    -- ─── HELPERS ───────────────────────────────────────────────
    local function BF_HAS(itemName)
        -- Check backpack
        if LPLR.Backpack:FindFirstChild(itemName) then return true end
        -- Check equipped (character)
        local char = LPLR.Character
        if char and char:FindFirstChild(itemName) then return true end
        return false
    end

    local function BF_GET_ITEM(itemName)
        if LPLR.Backpack:FindFirstChild(itemName) then
            return LPLR.Backpack[itemName]
        end
        local char = LPLR.Character
        if char and char:FindFirstChild(itemName) then
            return char[itemName]
        end
        return nil
    end

    local function BF_EQUIP(itemName)
        local item = LPLR.Backpack:FindFirstChild(itemName)
        if item then
            LPLR.Character.Humanoid:EquipTool(item)
            task.wait(0.3)
        end
    end

    -- ─── CAMERA FOCUS ──────────────────────────────────────────
    local function BF_FOCUS_CAM(targetPos)
        local cam  = workspace.CurrentCamera
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        cam.CameraType = Enum.CameraType.Scriptable
        if hrp then
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0), targetPos)
        end
    end

    local function BF_RESTORE_CAM()
        local cam  = workspace.CurrentCamera
        local char = LPLR.Character
        if char then
            cam.CameraSubject = char:FindFirstChildOfClass("Humanoid")
        end
        cam.CameraType = Enum.CameraType.Custom
    end

    -- ─── PROMPT INTERACTION ────────────────────────────────────
    -- Usa InputHoldBegin/End (metodo confirmado en Potassium)
    local function BF_HOLD(prompt)
        local ok, err = pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.3)
            prompt:InputHoldEnd()
        end)
        if not ok then
            warn("[BF] BF_HOLD error: " .. tostring(err))
        end
    end

    -- TP corto — sin bypass, solo mueve el CFrame (para distancias cercanas)
    local function SHORT_TP(pos)
        local char = LPLR.Character or LPLR.CharacterAdded:Wait()
        local hrp  = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
        task.wait(0.2)
    end

    -- Para prompts que aceptan fireproximityprompt normal (fridge, cooked patty handle)
    local function BF_FIRE(prompt)
        fireproximityprompt(prompt)
    end

    -- ─── NOTIFY LISTENER ───────────────────────────────────────
    local BF_NOTIFY_MSG  = ""
    local BF_OVEN_BUSY   = false  -- true cuando hay una patty en proceso
    local BF_STOVE_BUSY  = false  -- true cuando el horno destino esta en uso por otro jugador

    local function BF_LISTEN_NOTIFY()
        local notifyEvent = RS.Remotes.Notify
        notifyEvent.OnClientEvent:Connect(function(msg)
            BF_NOTIFY_MSG = msg or ""

            -- Detectar patty en proceso (horno ocupado propio)
            if BF_NOTIFY_MSG:find("Finish preparing your current burger") then
                BF_OVEN_BUSY = true
            end
            -- Cuando se recoge la patty cocida, el horno queda libre
            if BF_NOTIFY_MSG:find("successfully cooked") then
                BF_OVEN_BUSY = false
            end
            -- Horno en uso por otro jugador — cambiar de inmediato
            if BF_NOTIFY_MSG:find("Stove is currently in use") then
                BF_STOVE_BUSY = true
            end
        end)
    end

    local function BF_WAIT_NOTIFY(keyword, timeout)
        timeout = timeout or 30
        local elapsed = 0
        repeat
            task.wait(0.2)
            elapsed += 0.2
        until BF_NOTIFY_MSG:find(keyword) or elapsed >= timeout
        BF_NOTIFY_MSG = ""
        return elapsed < timeout
    end

    -- Espera hasta que el horno no esté ocupado (max 90s)
    local function BF_WAIT_IF_BUSY()
        if not BF_OVEN_BUSY then return end
        local elapsed = 0
        repeat
            task.wait(0.5)
            elapsed += 0.5
        until not BF_OVEN_BUSY or elapsed >= 90
        if BF_OVEN_BUSY then
            warn("[BF] Timeout waiting for oven, forcing busy flag reset.")
            BF_OVEN_BUSY = false
        end
    end

    -- ─── JOB CHECK ─────────────────────────────────────────────
    local function BF_IS_ON_JOB()
        local jobData = LPLR:FindFirstChild("Job_Data")
        if jobData then
            local currentJob = jobData:FindFirstChild("CurrentJob")
            if currentJob and currentJob.Value == "JerkChef" then
                return true
            end
        end
        return false
    end

    -- ─── FIND AVAILABLE OVEN ───────────────────────────────────
    -- skipSet: tabla opcional { [def] = true } para saltar hornos que ya fallaron
    local function BF_FIND_OVEN(skipSet)
        for _, def in ipairs(BF_OVEN_DEFS) do
            if skipSet and skipSet[def] then continue end
            local ok, prompt = pcall(def.getPrompt)
            if ok and prompt and prompt.Enabled then
                return def
            end
        end
        -- Si todos están ocupados (raros casos), esperar y reintentar una vez ignorando skip
        task.wait(2)
        for _, def in ipairs(BF_OVEN_DEFS) do
            if skipSet and skipSet[def] then continue end
            local ok, prompt = pcall(def.getPrompt)
            if ok and prompt and prompt.Enabled then
                return def
            end
        end
        return nil
    end

    -- ─── VENDER COOKED PATTY ───────────────────────────────────
    local function BF_SELL_COOKED_PATTY()
        if not BF_HAS("Cooked Patty") then return true end
        BF_EQUIP("Cooked Patty")
        task.wait(0.4)
        local cookedPatty = BF_GET_ITEM("Cooked Patty")
        if cookedPatty and cookedPatty:FindFirstChild("Handle") then
            local handlePrompt = cookedPatty.Handle:FindFirstChild("ProximityPrompt")
            if handlePrompt then
                BF_FIRE(handlePrompt)
                task.wait(1)
                return true
            end
        end
        warn("[BF] Could not sell Cooked Patty.")
        return false
    end

    local BF_FIRST_CYCLE = true

    -- ─── SINGLE PATTY CYCLE ────────────────────────────────────
    local function BF_DO_CYCLE()

        -- 0. Si hay Cooked Patty del ciclo anterior, venderla primero
        BF_SELL_COOKED_PATTY()

        -- 1. Si hay una patty en proceso en el horno, esperar
        BF_WAIT_IF_BUSY()

        -- 2. TP al area del trabajo (solo si no esta ya en el trabajo)
        if BF_FIRST_CYCLE then
            BF_FIRST_CYCLE = false
            if not BF_IS_ON_JOB() then
                BYPASS_TP(POS_START)
                task.wait(0.5)
            else
            end
        end

        -- 3. Start job if not already on it
        if not BF_IS_ON_JOB() then
            RS.Remotes.JobAction:FireServer("StartJob", "JerkChef")
            task.wait(1)
        else
        end

        -- 4. TP a la nevera (SHORT desde aqui en adelante)
        SHORT_TP(POS_FRIDGE)
        task.wait(0.4)

        -- 5. Fire fridge ProximityPrompt to get Patty
        local fridgePrompt = workspace.Jobs.Jerk_Center.ingredientsProx.ProximityPrompt
        BF_FIRE(fridgePrompt)
        task.wait(1)

        -- 6. Verify we have Patty
        if not BF_HAS("Patty") then
            warn("[BF] Did not get Patty from fridge. Aborting cycle.")
            return false
        end

        -- 7-12. Buscar horno, colocar patty y encender — con cambio automatico de horno si falla
        local ovenDef = nil
        local cycleOk = false
        local ovenAttempts = 0
        local ovenSkip = {}  -- hornos a saltar por "Stove in use"

        repeat
            ovenAttempts += 1

            -- Buscar horno disponible (saltando los que devolvieron "Stove in use")
            ovenDef = BF_FIND_OVEN(ovenSkip)
            if not ovenDef then
                warn("[BF] No ovens available. Waiting 3s...")
                task.wait(3)
            else

                -- TP al horno
                SHORT_TP(ovenDef.pos)
                task.wait(0.8)

                -- Equip Patty
                if not BF_HAS("Patty") then
                    warn("[BF] Patty ya no esta en inventario. Abortando ciclo.")
                    return false
                end
                BF_EQUIP("Patty")

                -- Esperar a que el prompt este enabled (max 2s)
                local waitP = 0
                local pReady = nil
                repeat
                    task.wait(0.1)
                    waitP += 0.1
                    local ok, p = pcall(ovenDef.getPrompt)
                    if ok and p and p.Enabled then pReady = p end
                until pReady or waitP >= 2

                if not pReady then
                    warn("[BF] Prompt no disponible en este horno, cambiando...")
                    -- Marcar este horno como no disponible temporalmente saltandolo
                    -- Al llamar BF_FIND_OVEN de nuevo lo saltara porque su prompt esta disabled
                else
                    -- Colocar patty
                    BF_NOTIFY_MSG = ""
                    BF_STOVE_BUSY = false
                    BF_HOLD(pReady)
                    task.wait(0.3)

                    -- Verificar: "Stove in use" detectado inmediatamente = saltar al siguiente
                    if BF_STOVE_BUSY then
                        warn("[BF] Stove en uso, marcando horno y buscando el siguiente...")
                        BF_STOVE_BUSY = false
                        ovenSkip[ovenDef] = true  -- no volver a este horno en este ciclo
                        local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum:UnequipTools() end
                        task.wait(0.2)
                        -- TP inmediato al siguiente horno disponible
                        local nextOven = BF_FIND_OVEN(ovenSkip)
                        if nextOven then
                            SHORT_TP(nextOven.pos)
                            task.wait(0.5)
                        end
                    else
                        -- Verificar con notify normal
                        local placed = BF_WAIT_NOTIFY("Patty has been placed", 5)
                        if not placed then
                            warn("[BF] Horno " .. ovenAttempts .. " no confirmo placement, cambiando de horno...")
                            -- Desequipar para poder reintentar en otro horno
                            local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum:UnequipTools() end
                            task.wait(0.3)
                        else
                            task.wait(1)

                            -- Encender fuego
                            local ok2, p2 = pcall(ovenDef.getPrompt)
                            if ok2 and p2 and p2.Enabled then
                                BF_HOLD(p2)
                                task.wait(0.3)
                                cycleOk = true
                            else
                                warn("[BF] Prompt de encendido no disponible.")
                            end
                        end
                    end
                end
            end
        until cycleOk or ovenAttempts >= 3

        if not cycleOk then
            warn("[BF] Could not complete placement after " .. ovenAttempts .. " attempts.")
            return false
        end

        -- 13. Marcar horno ocupado y esperar coccion
        BF_OVEN_BUSY = true
        BF_NOTIFY_MSG = ""
        BF_RESTORE_CAM()

        local cooked = BF_WAIT_NOTIFY("Patty has finished frying", 90)
        if not cooked then
            warn("[BF] Timeout waiting for cooking. Aborting.")
            BF_OVEN_BUSY = false
            return false
        end
        task.wait(0.5)

        -- 14. TP al horno y recoger — UN SOLO HOLD, sin retry para no romper el trabajo
        SHORT_TP(ovenDef.pos)
        task.wait(0.3)

        BF_NOTIFY_MSG = ""
        local ok3, p3 = pcall(ovenDef.getPrompt)
        if ok3 and p3 and p3.Enabled then
            BF_HOLD(p3)
            task.wait(0.8)
        else
            warn("[BF] Prompt del horno no disponible para recoger.")
            return false
        end

        -- 15. Verificar Cooked Patty
        if not BF_HAS("Cooked Patty") then
            warn("[BF] Cooked Patty no encontrada en inventario.")
            return false
        end
        BF_OVEN_BUSY = false

        -- 16. Vender Cooked Patty
        BF_SELL_COOKED_PATTY()

        BF_RESTORE_CAM()
        return true
    end

    -- ─── MAIN LOOP ─────────────────────────────────────────────
    function BF.START()
        if BF.RUNNING then
            return
        end
        BF.RUNNING = true
        BF_LISTEN_NOTIFY()

        BF._THREAD = task.spawn(function()
            while BF.RUNNING do
                local ok = pcall(BF_DO_CYCLE)
                if not ok then
                    warn("[BF] Cycle error, retrying in 3s...")
                    task.wait(3)
                else
                    task.wait(0.5)
                end
            end
        end)
    end

    function BF.STOP()
        BF.RUNNING = false
        BF_FIRST_CYCLE = true
        -- Cancelar el thread inmediatamente (no esperar al ciclo actual)
        if BF._THREAD then
            pcall(task.cancel, BF._THREAD)
            BF._THREAD = nil
        end
        BF_RESTORE_CAM()
    end

    -- expose to UI card
    _G.BF_START = BF.START
    _G.BF_STOP  = BF.STOP
end)()

-- ── UI CARD ──────────────────────────────────────────────
do
    local JOBS_CARD = Instance.new("Frame", FARM_ROW_R)
    JOBS_CARD.Size = UDim2.new(1, 0, 0, 0)
    JOBS_CARD.AutomaticSize = Enum.AutomaticSize.Y
    JOBS_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    JOBS_CARD.BackgroundTransparency = 0.2
    JOBS_CARD.BorderSizePixel = 0
    JOBS_CARD.LayoutOrder = 2
    RND(JOBS_CARD, 12)
    STR(JOBS_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local JLAY = Instance.new("UIListLayout", JOBS_CARD)
    JLAY.SortOrder = Enum.SortOrder.LayoutOrder
    JLAY.Padding = UDim.new(0, 8)

    local JPAD = Instance.new("UIPadding", JOBS_CARD)
    JPAD.PaddingTop    = UDim.new(0, 12)
    JPAD.PaddingBottom = UDim.new(0, 14)
    JPAD.PaddingLeft   = UDim.new(0, 12)
    JPAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local JHDR = Instance.new("Frame", JOBS_CARD)
    JHDR.Size = UDim2.new(1, 0, 0, 28)
    JHDR.BackgroundTransparency = 1
    JHDR.BorderSizePixel = 0
    JHDR.LayoutOrder = 0

    local JHDR_ICO = Instance.new("ImageLabel", JHDR)
    JHDR_ICO.Size = UDim2.new(0, 28, 0, 28)
    JHDR_ICO.Position = UDim2.new(0, 0, 0, 0)
    JHDR_ICO.BackgroundTransparency = 1
    JHDR_ICO.Image = "rbxassetid://106507089706013"
    JHDR_ICO.ImageColor3 = CFG.COL.ACC

    local JHDR_TXT = Instance.new("TextLabel", JHDR)
    JHDR_TXT.Size = UDim2.new(1, -36, 1, 0)
    JHDR_TXT.Position = UDim2.new(0, 36, 0, 0)
    JHDR_TXT.BackgroundTransparency = 1
    JHDR_TXT.Text = "Extra Jobs"
    JHDR_TXT.TextColor3 = CFG.COL.TXT
    JHDR_TXT.Font = Enum.Font.GothamBold
    JHDR_TXT.TextSize = 18
    JHDR_TXT.TextXAlignment = Enum.TextXAlignment.Left

    -- Divider
    local JDIV = Instance.new("Frame", JOBS_CARD)
    JDIV.Size = UDim2.new(1, 0, 0, 1)
    JDIV.BackgroundColor3 = CFG.COL.ACC
    JDIV.BackgroundTransparency = 0.85
    JDIV.BorderSizePixel = 0
    JDIV.LayoutOrder = 1

    -- Generic toggle builder
    local function MK_JOB_TOG(label, order, onEnable, onDisable)
        local ROW = Instance.new("Frame", JOBS_CARD)
        ROW.Size = UDim2.new(1, 0, 0, 36)
        ROW.BackgroundTransparency = 1
        ROW.BorderSizePixel = 0
        ROW.LayoutOrder = order

        local LBL = Instance.new("TextLabel", ROW)
        LBL.Size = UDim2.new(1, -60, 1, 0)
        LBL.Position = UDim2.new(0, 0, 0, 0)
        LBL.BackgroundTransparency = 1
        LBL.Text = label
        LBL.TextColor3 = CFG.COL.TXT
        LBL.Font = Enum.Font.Gotham
        LBL.TextSize = 14
        LBL.TextXAlignment = Enum.TextXAlignment.Left

        local PILL = Instance.new("Frame", ROW)
        PILL.Size = UDim2.new(0, 46, 0, 26)
        PILL.Position = UDim2.new(1, -46, 0.5, -13)
        PILL.BackgroundColor3 = CFG.COL.GRY
        PILL.BorderSizePixel = 0
        RND(PILL, 13)

        local KNOB = Instance.new("Frame", PILL)
        KNOB.Size = UDim2.new(0, 20, 0, 20)
        KNOB.Position = UDim2.new(0, 3, 0.5, -10)
        KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
        KNOB.BorderSizePixel = 0
        RND(KNOB, 10)

        local IS_ON = false
        local BTN = Instance.new("TextButton", PILL)
        BTN.Size = UDim2.new(1, 0, 1, 0)
        BTN.BackgroundTransparency = 1
        BTN.Text = ""
        BTN.ZIndex = 5

        BTN.MouseButton1Click:Connect(function()
            IS_ON = not IS_ON
            if IS_ON then
                TWN(PILL, {BackgroundColor3 = CFG.COL.GRN})
                TWN(KNOB, {Position = UDim2.new(1, -23, 0.5, -10)})
                if onEnable then onEnable() end
            else
                TWN(PILL, {BackgroundColor3 = CFG.COL.GRY})
                TWN(KNOB, {Position = UDim2.new(0, 3, 0.5, -10)})
                if onDisable then onDisable() end
            end
        end)
    end

    -- Burger Farm toggle — wired to logic
    MK_JOB_TOG("Burger Farm", 2, _G.BF_START, _G.BF_STOP)

    -- Candy Farm / Mop Farm — placeholders for future logic
    MK_JOB_TOG("Box Farm",  3, WH_START, WH_STOP)
    MK_JOB_TOG("Mop Farm",    4, nil, nil)
end

-- ── MISC TAB — MOVEMENT CARD ──────────────────────────────────
local MOV_WRAP, COL_R  -- upvalues for MISC sub-sections
local function SETUP_MOVEMENT()
    local RS2     = game:GetService("ReplicatedStorage")
    local UIS2    = game:GetService("UserInputService")
    local RS_SVC  = game:GetService("RunService")
    local BYPASS_RATE = 1.5

    -- ── State ────────────────────────────────────────────────
    _G.EXE.FLY_ON = false;  local FLY_SPEED  = 25
    _G.EXE.SPD_ON = false;  local SPD_SPEED  = 27

    local _bv, _bg
    local _fly_pill, _fly_knob
    local _spd_pill, _spd_knob

    local function SET_PILL(pill, knob, ON)
        if not pill or not knob then return end
        if ON then
            TWN(pill, {BackgroundColor3 = CFG.COL.ACC})
            TWN(knob, {Position = UDim2.new(0, 23, 0.5, -9)})
        else
            TWN(pill, {BackgroundColor3 = CFG.COL.GRY})
            TWN(knob, {Position = UDim2.new(0, 3, 0.5, -9)})
        end
    end

    -- ── Fly ──────────────────────────────────────────────────
    local function startFly()
        local char = LPLR.Character; if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        hum.PlatformStand = true
        _bv = Instance.new("BodyVelocity")
        _bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        _bv.Velocity = Vector3.new(0,0,0)
        _bv.Parent = hrp
        _bg = Instance.new("BodyGyro")
        _bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        _bg.P = 1e4
        _bg.CFrame = hrp.CFrame
        _bg.Parent = hrp
    end
    local function stopFly()
        if _bv then _bv:Destroy() _bv = nil end
        if _bg then _bg:Destroy() _bg = nil end
        task.spawn(function()
            for _ = 1, 10 do
                local c = LPLR.Character
                if c then
                    local h = c:FindFirstChild("HumanoidRootPart")
                    local hm = c:FindFirstChild("Humanoid")
                    if h then h.Anchored = false end
                    if hm then hm.PlatformStand = false end
                end
                task.wait()
            end
        end)
    end
    local function SET_FLY(ON)
        _G.EXE.FLY_ON = ON
        SET_PILL(_fly_pill, _fly_knob, ON)
        if ON then startFly() else stopFly() end
    end

    -- ── SpeedHack ────────────────────────────────────────────
    local function SET_SPD(ON)
        _G.EXE.SPD_ON = ON
        SET_PILL(_spd_pill, _spd_knob, ON)
        if not ON then
            local c = LPLR.Character
            if c then
                local h = c:FindFirstChild("Humanoid")
                if h then h.WalkSpeed = 16 end
            end
        end
    end


    -- ── Auto-off on death ────────────────────────────────────
    local function hookDeath(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.Died:Connect(function()
            if _G.EXE.FLY_ON then SET_FLY(false) end
            if _G.EXE.SPD_ON then SET_SPD(false) end
        end)
    end
    hookDeath(LPLR.Character)
    LPLR.CharacterAdded:Connect(function(char)
        hookDeath(char)
        -- Re-enable active features after respawn
        task.wait(0.5)
        if _G.EXE.FLY_ON then startFly() end
    end)

    -- ── Fly heartbeat ────────────────────────────────────────
    RS_SVC.Heartbeat:Connect(function()
        if not _G.EXE.FLY_ON then return end
        local c = LPLR.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not hrp or not _bv then return end
        local dir = Vector3.new(0,0,0)
        if UIS2:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS2:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS2:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS2:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS2:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS2:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        _bv.Velocity = dir.Magnitude > 0 and dir.Unit * 25 or Vector3.new(0,0,0)
        _bg.CFrame = cam.CFrame
    end)

    -- ── Bypass loop ──────────────────────────────────────────
    task.spawn(function()
        while true do
            task.wait(BYPASS_RATE)
            local anyOn = _G.EXE.FLY_ON or _G.EXE.SPD_ON
            if anyOn then
                local c = LPLR.Character
                if c then
                    local h = c:FindFirstChild("Humanoid")
                    if h then
                        if _G.EXE.FLY_ON then h.PlatformStand = true end
                        if _G.EXE.SPD_ON then h.WalkSpeed = 27 end
                        if _G.EXE.FLY_ON and not c:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyVelocity") then
                            startFly()
                        end
                    end
                end
            end
        end
    end)

    -- ── CAR FLY ────────────────────────────────────────────
    _G.EXE.CF_ON = false
    local _cf_bv, _cf_bg, _cf_conn
    local _cf_pill, _cf_knob
    local CF_SPEED = 80

    local function CF_GET_VEH()
        local char = LPLR.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local seat = hum.SeatPart
        if not seat then return nil end
        return seat:FindFirstAncestorWhichIsA("Model")
    end

    local function CF_GET_ROOT(v)
        if not v then return nil end
        return v.PrimaryPart
            or v:FindFirstChildWhichIsA("VehicleSeat")
            or v:FindFirstChildWhichIsA("BasePart")
    end

    local function stopCarFly()
        if _cf_conn then _cf_conn:Disconnect() _cf_conn = nil end
        if _cf_bv   then _cf_bv:Destroy()     _cf_bv   = nil end
        if _cf_bg   then _cf_bg:Destroy()     _cf_bg   = nil end
    end

    local function startCarFly()
        local vehicle = CF_GET_VEH()
        if not vehicle then NOTIFY("Car Fly", "No hay vehiculo!", 3) return false end
        local root = CF_GET_ROOT(vehicle)
        if not root then NOTIFY("Car Fly", "Sin PrimaryPart!", 3) return false end
        root.Anchored = false
        _cf_bv = Instance.new("BodyVelocity")
        _cf_bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        _cf_bv.Velocity = Vector3.new(0, 0, 0)
        _cf_bv.Parent   = root
        _cf_bg = Instance.new("BodyGyro")
        _cf_bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        _cf_bg.P = 2e4; _cf_bg.D = 500
        _cf_bg.CFrame = root.CFrame
        _cf_bg.Parent = root
        _cf_conn = RS_SVC.Heartbeat:Connect(function()
            local v2 = CF_GET_VEH()
            if not v2 or not _cf_bv or not _cf_bv.Parent then
                _G.EXE.CF_ON = false
                SET_PILL(_cf_pill, _cf_knob, false)
                stopCarFly() return
            end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if UIS2:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector  end
            if UIS2:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector  end
            if UIS2:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS2:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS2:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0) end
            if UIS2:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            _cf_bv.Velocity = dir.Magnitude > 0 and dir.Unit * CF_SPEED or Vector3.new(0,0,0)
            local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            if flatLook.Magnitude > 0.01 then
                local r2 = CF_GET_ROOT(v2)
                if r2 then
                    _cf_bg.CFrame = CFrame.new(Vector3.new(0,0,0), flatLook) + r2.Position
                end
            end
        end)
        return true
    end

    -- ── UI ───────────────────────────────────────────────────
    MOV_WRAP = Instance.new("Frame", P_MSC)
    MOV_WRAP.Size = UDim2.new(1, -10, 0, 0)
    MOV_WRAP.AutomaticSize = Enum.AutomaticSize.Y
    MOV_WRAP.BackgroundTransparency = 1
    MOV_WRAP.BorderSizePixel = 0
    MOV_WRAP.LayoutOrder = 1

    local MOV_CARD = Instance.new("Frame", MOV_WRAP)
    MOV_CARD.Size = UDim2.new(0.5, -5, 0, 0)
    MOV_CARD.Position = UDim2.new(0, 0, 0, 0)
    MOV_CARD.AnchorPoint = Vector2.new(0, 0)
    MOV_CARD.AutomaticSize = Enum.AutomaticSize.Y
    MOV_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    MOV_CARD.BackgroundTransparency = 0.2
    MOV_CARD.BorderSizePixel = 0
    MOV_CARD.LayoutOrder = 1
    RND(MOV_CARD, 12)
    STR(MOV_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local MC_LAY = Instance.new("UIListLayout", MOV_CARD)
    MC_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    MC_LAY.Padding = UDim.new(0, 10)

    local MC_PAD = Instance.new("UIPadding", MOV_CARD)
    MC_PAD.PaddingTop    = UDim.new(0, 10)
    MC_PAD.PaddingBottom = UDim.new(0, 12)
    MC_PAD.PaddingLeft   = UDim.new(0, 12)
    MC_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local MC_HDR = Instance.new("Frame", MOV_CARD)
    MC_HDR.Size = UDim2.new(1, 0, 0, 28)
    MC_HDR.BackgroundTransparency = 1
    MC_HDR.LayoutOrder = 0

    local MC_ICN = Instance.new("ImageLabel", MC_HDR)
    MC_ICN.Size = UDim2.new(0, 24, 0, 24)
    MC_ICN.Position = UDim2.new(0, 0, 0.5, -12)
    MC_ICN.BackgroundTransparency = 1
    MC_ICN.Image = "rbxassetid://112687695155477"
    MC_ICN.ImageColor3 = CFG.COL.ACC

    local MC_TTL = Instance.new("TextLabel", MC_HDR)
    MC_TTL.Size = UDim2.new(1, -34, 1, 0)
    MC_TTL.Position = UDim2.new(0, 32, 0, 0)
    MC_TTL.BackgroundTransparency = 1
    MC_TTL.Text = "Movement"
    MC_TTL.TextColor3 = CFG.COL.TXT
    MC_TTL.Font = Enum.Font.GothamBold
    MC_TTL.TextSize = 15
    MC_TTL.TextXAlignment = Enum.TextXAlignment.Left

    local MC_DIV = Instance.new("Frame", MOV_CARD)
    MC_DIV.Size = UDim2.new(1, 0, 0, 1)
    MC_DIV.BackgroundColor3 = CFG.COL.ACC
    MC_DIV.BackgroundTransparency = 0.85
    MC_DIV.BorderSizePixel = 0
    MC_DIV.LayoutOrder = 1

    -- ── Row builder (toggle + optional slider) ───────────────
    local IS_PC = not game:GetService("UserInputService").TouchEnabled
    
    _G.CEN_BINDS = _G.CEN_BINDS or {}

    local function MK_MOV_ROW(label, order, onToggle, initVal, minV, maxV, onSlide)
        local SECTION = Instance.new("Frame", MOV_CARD)
        SECTION.Size = UDim2.new(1, 0, 0, 0)
        SECTION.AutomaticSize = Enum.AutomaticSize.Y
        SECTION.BackgroundTransparency = 1
        SECTION.LayoutOrder = order

        local SLAY = Instance.new("UIListLayout", SECTION)
        SLAY.SortOrder = Enum.SortOrder.LayoutOrder
        SLAY.Padding = UDim.new(0, 6)

        -- Toggle row
        local TOG_ROW = Instance.new("Frame", SECTION)
        TOG_ROW.Size = UDim2.new(1, 0, 0, 32)
        TOG_ROW.BackgroundTransparency = 1
        TOG_ROW.LayoutOrder = 0

        local LBL = Instance.new("TextLabel", TOG_ROW)
        LBL.Size = UDim2.new(1, -55, 1, 0)
        LBL.BackgroundTransparency = 1
        LBL.Text = label
        LBL.TextColor3 = CFG.COL.TXT
        LBL.Font = Enum.Font.GothamBold
        LBL.TextSize = 13
        LBL.TextXAlignment = Enum.TextXAlignment.Left

        local PILL = Instance.new("Frame", TOG_ROW)
        PILL.Size = UDim2.new(0, 44, 0, 24)
        PILL.Position = UDim2.new(1, -44, 0.5, -12)
        PILL.BackgroundColor3 = CFG.COL.GRY
        PILL.BorderSizePixel = 0
        RND(PILL, 12)

        local KNOB = Instance.new("Frame", PILL)
        KNOB.Size = UDim2.new(0, 18, 0, 18)
        KNOB.Position = UDim2.new(0, 3, 0.5, -9)
        KNOB.BackgroundColor3 = Color3.new(1,1,1)
        KNOB.BorderSizePixel = 0
        RND(KNOB, 9)

        -- Keybind box (PC only)
        local KB_BOUND = nil  -- current KeyCode
        local KB_LISTENING = false

        if IS_PC then
            local KB_BOX = Instance.new("TextButton", TOG_ROW)
            KB_BOX.Size = UDim2.new(0, 36, 0, 22)
            KB_BOX.Position = UDim2.new(1, -88, 0.5, -11)
            KB_BOX.BackgroundColor3 = CFG.COL.BG
            KB_BOX.BackgroundTransparency = 0.82
            KB_BOX.BorderSizePixel = 0
            KB_BOX.Text = "—"
            KB_BOX.TextColor3 = CFG.COL.GRY
            KB_BOX.Font = Enum.Font.GothamBold
            KB_BOX.TextSize = 10
            KB_BOX.ZIndex = 6
            KB_BOX.AutoButtonColor = false
            RND(KB_BOX, 8)
            
            local KB_STR = STR(KB_BOX, CFG.COL.ACC, 1.2)
            KB_STR.Transparency = 0.8
            KB_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local KB_GRAD = Instance.new("UIGradient", KB_BOX)
            KB_GRAD.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
            })
            KB_GRAD.Rotation = 45
            KB_GRAD.Transparency = NumberSequence.new(0.5)

            KB_BOX.MouseEnter:Connect(function()
                TWN(KB_BOX, {BackgroundTransparency = 0.65, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0,0,0)}, 0.2)
                TWN(KB_STR, {Transparency = 0.45}, 0.2)
            end)
            KB_BOX.MouseLeave:Connect(function()
                TWN(KB_BOX, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG, TextColor3 = CFG.COL.GRY}, 0.2)
                TWN(KB_STR, {Transparency = 0.8}, 0.2)
            end)

            KB_BOX.MouseButton1Click:Connect(function()
                if KB_LISTENING then return end
                KB_LISTENING = true
                KB_BOX.Text = "..."
                KB_BOX.TextColor3 = CFG.COL.YEL
                TWN(KB_BOX, {BackgroundColor3 = Color3.fromRGB(50, 45, 20), BackgroundTransparency = 0.5, TextSize = 8}, 0.1)

                local conn
                conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    conn:Disconnect()
                    KB_LISTENING = false

                    -- ESC = clear binding
                    if inp.KeyCode == Enum.KeyCode.Escape then
                        KB_BOUND = nil
                        KB_BOX.Text = "—"
                        KB_BOX.TextColor3 = CFG.COL.GRY
                        TWN(KB_BOX, {BackgroundColor3 = CFG.COL.BG, BackgroundTransparency = 0.82, TextSize = 10}, 0.1)
                        return
                    end

                    KB_BOUND = inp.KeyCode
                    local name = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")
                    -- Shorten long names
                    if #name > 4 then name = name:sub(1,4) end
                    KB_BOX.Text = name
                    KB_BOX.TextColor3 = CFG.COL.TXT
                    TWN(KB_BOX, {BackgroundColor3 = CFG.COL.BG, BackgroundTransparency = 0.82, TextSize = 10}, 0.1)
                end)
            end)

            -- Listen for keybind press globally
            local bind_conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
                if gpe or KB_LISTENING or KB_BOUND == nil then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == KB_BOUND then
                    onToggle(PILL, KNOB)
                end
            end)
            table.insert(_G.CEN_BINDS, bind_conn)

            -- Shrink label to make room for keybind box
            LBL.Size = UDim2.new(1, -100, 1, 0)
        end

        local CLK = Instance.new("TextButton", TOG_ROW)
        CLK.Size = UDim2.new(1, 0, 1, 0)
        CLK.BackgroundTransparency = 1
        CLK.Text = ""
        CLK.ZIndex = 5
        CLK.MouseButton1Click:Connect(function()
            onToggle(PILL, KNOB)
        end)

        -- Slider (optional)
        if onSlide then
            local SLD_WRAP = Instance.new("Frame", SECTION)
            SLD_WRAP.Size = UDim2.new(1, 0, 0, 28)
            SLD_WRAP.BackgroundTransparency = 1
            SLD_WRAP.LayoutOrder = 1

            local VAL_LBL = Instance.new("TextLabel", SLD_WRAP)
            VAL_LBL.Size = UDim2.new(0, 40, 1, 0)
            VAL_LBL.Position = UDim2.new(1, -40, 0, 0)
            VAL_LBL.BackgroundTransparency = 1
            VAL_LBL.Text = tostring(initVal)
            VAL_LBL.TextColor3 = CFG.COL.ACC
            VAL_LBL.Font = Enum.Font.GothamBold
            VAL_LBL.TextSize = 11
            VAL_LBL.TextXAlignment = Enum.TextXAlignment.Right

            local TRACK = Instance.new("Frame", SLD_WRAP)
            TRACK.Size = UDim2.new(1, -48, 0, 6)
            TRACK.Position = UDim2.new(0, 0, 0.5, -3)
            TRACK.BackgroundColor3 = CFG.COL.BG
            TRACK.BackgroundTransparency = 0.5
            TRACK.BorderSizePixel = 0
            RND(TRACK, 3)
            local TR_STR = STR(TRACK, CFG.COL.ACC, 1)
            TR_STR.Transparency = 0.8
            TR_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local FILL = Instance.new("Frame", TRACK)
            FILL.Size = UDim2.new((initVal - minV) / (maxV - minV), 0, 1, 0)
            FILL.BackgroundColor3 = CFG.COL.ACC
            FILL.BorderSizePixel = 0
            RND(FILL, 3)

            local THUMB = Instance.new("TextButton", TRACK)
            THUMB.Size = UDim2.new(0, 14, 0, 14)
            THUMB.Position = UDim2.new((initVal - minV) / (maxV - minV), -7, 0.5, -7)
            THUMB.BackgroundColor3 = Color3.new(1,1,1)
            THUMB.BorderSizePixel = 0
            THUMB.Text = ""
            THUMB.ZIndex = 6
            RND(THUMB, 10)
            STR(THUMB, CFG.COL.ACC, 1).Transparency = 0.5

            local dragging = false
            THUMB.MouseButton1Down:Connect(function() dragging = true end)
            game:GetService("UserInputService").InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(i)
                if not dragging then return end
                if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                local abs = TRACK.AbsolutePosition
                local sz  = TRACK.AbsoluteSize
                local rx  = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
                local val = math.floor(minV + rx * (maxV - minV))
                FILL.Size = UDim2.new(rx, 0, 1, 0)
                THUMB.Position = UDim2.new(rx, -8, 0.5, -8)
                VAL_LBL.Text = tostring(val)
                onSlide(val)
            end)
        end

        return PILL, KNOB
    end

    -- ── Fly ──────────────────────────────────────────────────
    _fly_pill, _fly_knob = MK_MOV_ROW("Fly", 2,
        function(p, k)
            _G.EXE.FLY_ON = not _G.EXE.FLY_ON
            SET_PILL(p, k, _G.EXE.FLY_ON)
            if _G.EXE.FLY_ON then startFly() else stopFly() end
        end,
        nil, nil, nil, nil
    )

    -- ── Speed Hack ───────────────────────────────────────────
    _spd_pill, _spd_knob = MK_MOV_ROW("Walk Boost", 3,
        function(p, k)
            _G.EXE.SPD_ON = not _G.EXE.SPD_ON
            SET_PILL(p, k, _G.EXE.SPD_ON)
            if not _G.EXE.SPD_ON then
                local c = LPLR.Character
                if c then
                    local h = c:FindFirstChild("Humanoid")
                    if h then h.WalkSpeed = 16 end
                end
            end
        end,
        nil, nil, nil, nil
    )

    -- ── Car Fly ───────────────────────────────────────────
    _cf_pill, _cf_knob = MK_MOV_ROW("Car Fly", 4,
        function(p, k)
            _G.EXE.CF_ON = not _G.EXE.CF_ON
            if _G.EXE.CF_ON then
                local ok = startCarFly()
                if not ok then _G.EXE.CF_ON = false return end
                SET_PILL(p, k, true)
                NOTIFY("Car Fly", "Enabled! WASD+Space", 2)
            else
                stopCarFly()
                SET_PILL(p, k, false)
                NOTIFY("Car Fly", "Disabled", 2)
            end
        end,
        CF_SPEED, 0, 1000,
        function(v) CF_SPEED = v end
    )

end
SETUP_MOVEMENT()

-- ── CAR MODS CARD (right of Movement in MISC) ────────────────
local function SETUP_CAR_MODS()
    local RS_CAR   = game:GetService("ReplicatedStorage")
    local VEH_DATA = LPLR:FindFirstChild("Vehicle_Data")

    local function CAR_GET_VEHICLE()
        return workspace.Vehicles:FindFirstChild(LPLR.Name .. "'s Vehicle")
    end

    -- ── RIGHT COLUMN CONTAINER ────────────────────────────────
    COL_R = Instance.new("Frame", MOV_WRAP)
    COL_R.Size = UDim2.new(0.5, -5, 0, 0)
    COL_R.Position = UDim2.new(0.5, 5, 0, 0)
    COL_R.BackgroundTransparency = 1
    COL_R.AutomaticSize = Enum.AutomaticSize.Y

    local COL_R_LAY = Instance.new("UIListLayout", COL_R)
    COL_R_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    COL_R_LAY.Padding = UDim.new(0, 10)

    -- ── CAR SPAWNER CARD ────────────────────────────────────
    local CAR_CARD = Instance.new("Frame", COL_R)
    CAR_CARD.Size = UDim2.new(1, 0, 0, 0)
    CAR_CARD.AutomaticSize = Enum.AutomaticSize.Y
    CAR_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    CAR_CARD.BackgroundTransparency = 0.2
    CAR_CARD.BorderSizePixel = 0
    CAR_CARD.LayoutOrder = 1
    RND(CAR_CARD, 12)
    STR(CAR_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local CARL_LAY = Instance.new("UIListLayout", CAR_CARD)
    CARL_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    CARL_LAY.Padding = UDim.new(0, 10)

    local CARL_PAD = Instance.new("UIPadding", CAR_CARD)
    CARL_PAD.PaddingTop    = UDim.new(0, 12)
    CARL_PAD.PaddingBottom = UDim.new(0, 14)
    CARL_PAD.PaddingLeft   = UDim.new(0, 12)
    CARL_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local CARL_HDR = Instance.new("Frame", CAR_CARD)
    CARL_HDR.Size = UDim2.new(1, 0, 0, 28)
    CARL_HDR.BackgroundTransparency = 1
    CARL_HDR.LayoutOrder = 0

    local CARL_ICN = Instance.new("ImageLabel", CARL_HDR)
    CARL_ICN.Size = UDim2.new(0, 24, 0, 24)
    CARL_ICN.Position = UDim2.new(0, 0, 0.5, -12)
    CARL_ICN.BackgroundTransparency = 1
    CARL_ICN.Image = "rbxassetid://122122158199543"
    CARL_ICN.ImageColor3 = CFG.COL.ACC

    local CARL_TTL = Instance.new("TextLabel", CARL_HDR)
    CARL_TTL.Size = UDim2.new(1, -36, 1, 0)
    CARL_TTL.Position = UDim2.new(0, 36, 0, 0)
    CARL_TTL.BackgroundTransparency = 1
    CARL_TTL.Text = "Car Spawner"
    CARL_TTL.TextColor3 = CFG.COL.TXT
    CARL_TTL.Font = Enum.Font.GothamBold
    CARL_TTL.TextSize = 15
    CARL_TTL.TextXAlignment = Enum.TextXAlignment.Left

    local CARL_DIV = Instance.new("Frame", CAR_CARD)
    CARL_DIV.Size = UDim2.new(1, 0, 0, 1)
    CARL_DIV.BackgroundColor3 = CFG.COL.ACC
    CARL_DIV.BackgroundTransparency = 0.85
    CARL_DIV.BorderSizePixel = 0
    CARL_DIV.LayoutOrder = 1

    -- ── Dropdown factory ────────────────────────────────────
    local function MK_CAR_DRP(label, order)
        local WRAP = Instance.new("Frame", CAR_CARD)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.BorderSizePixel = 0
        WRAP.ClipsDescendants = false
        WRAP.ZIndex = 20 - order
        WRAP.LayoutOrder = order

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = CFG.COL.BG
        FRM.BackgroundTransparency = 0.82
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 20 - order
        RND(FRM, 10)
        
        local DRP_STR = STR(FRM, CFG.COL.ACC, 1.2)
        DRP_STR.Transparency = 0.8
        DRP_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local DRP_GRAD = Instance.new("UIGradient", FRM)
        DRP_GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
        })
        DRP_GRAD.Rotation = 45
        DRP_GRAD.Transparency = NumberSequence.new(0.5)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. label
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 21 - order

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 16, 0, 16)
        ICO.Position = UDim2.new(1, -24, 0.5, -8)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 22 - order

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 22 - order
        SCR.CanvasSize = UDim2.new(0, 0, 0, 0)
        SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H = 0

        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN(H)
            if H then DRP_H = H end
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, SCR=SCR, LAY=LAY, CLOSE=CLOSE, OPEN=OPEN }
    end

    -- ── DROPDOWN 1: Choose Car (auto-refresh) ───────────────
    local D_CAR = MK_CAR_DRP("Choose Car", 2)

    local function CAR_REBUILD_LIST()
        -- Clear existing items
        for _, c in ipairs(D_CAR.SCR:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local newList = {}
        if VEH_DATA then
            for _, v in ipairs(VEH_DATA:GetChildren()) do
                if v:IsA("BoolValue") and v.Value == true
                and not v.Name:find("Backfire")
                and not v.Name:find("Carbon") then
                    table.insert(newList, v.Name)
                end
            end
        end
        for i, carName in ipairs(newList) do
            local ITM = Instance.new("TextButton", D_CAR.SCR)
            ITM.Size = UDim2.new(1, 0, 0, 28)
            ITM.BackgroundTransparency = 1
            ITM.Text = "  " .. carName
            ITM.TextColor3 = CFG.COL.TXT
            ITM.MouseEnter:Connect(function()
                TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
            end)
            ITM.MouseLeave:Connect(function()
                TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
            end)
            ITM.Font = Enum.Font.Gotham
            ITM.TextSize = 12
            ITM.TextXAlignment = Enum.TextXAlignment.Left
            ITM.ZIndex = 23
            ITM.LayoutOrder = i
            ITM.MouseButton1Click:Connect(function()
                D_CAR.BTN.Text = "  " .. carName
                D_CAR.CLOSE()
                -- Spawn safely
                local spawnRemote = RS_CAR.Remotes:FindFirstChild("Vehicle_Spawn")
                if spawnRemote then
                    local ok, err = pcall(function() spawnRemote:FireServer("Citizen", carName) end)
                    if ok then
                        NOTIFY("CAR", "🚗 Spawning " .. carName .. "!", 3)
                    else
                        warn("[Spawn Error]:", err)
                        NOTIFY("CAR", "❌ Spawn Failed", 3)
                    end
                else
                    NOTIFY("CAR", "❌ Remote not found", 3)
                end
            end)
        end
        local h = math.min(#newList * 28, 180)
        D_CAR.SCR.Size = UDim2.new(1, 0, 0, h)
        D_CAR.SCR.CanvasSize = UDim2.new(0, 0, 0, D_CAR.LAY.AbsoluteContentSize.Y)
        D_CAR.OPEN(h) D_CAR.CLOSE()
    end

    -- Build initial list
    CAR_REBUILD_LIST()

    -- Auto-refresh when VEH_DATA changes (new car purchased)
    if VEH_DATA then
        VEH_DATA.ChildAdded:Connect(function() task.wait(0.2) CAR_REBUILD_LIST() end)
        VEH_DATA.ChildRemoved:Connect(function() task.wait(0.2) CAR_REBUILD_LIST() end)
        for _, v in ipairs(VEH_DATA:GetChildren()) do
            if v:IsA("BoolValue") then
                v.Changed:Connect(function() task.wait(0.2) CAR_REBUILD_LIST() end)
            end
        end
        VEH_DATA.ChildAdded:Connect(function(child)
            task.wait(0.1)
            if child:IsA("BoolValue") then
                child.Changed:Connect(function() task.wait(0.2) CAR_REBUILD_LIST() end)
            end
        end)
    end



    -- ── DROPDOWN 2: Car Tools ────────────────────────────────
    local D_TOOLS = MK_CAR_DRP("Car Tools", 5)
    local TOOLS_LIST = {
        { name = "TP to My Car", action = function()
            local vehicle = CAR_GET_VEHICLE()
            if not vehicle then NOTIFY("Car Tools", "❌ No car spawned!", 3) return end
            local seat = vehicle:FindFirstChildWhichIsA("VehicleSeat")
                      or vehicle:FindFirstChildWhichIsA("Seat")
                      or vehicle.PrimaryPart
            local targetPos = (seat and seat.CFrame or vehicle:GetPivot()).Position + Vector3.new(0, 3, 0)
            BYPASS_TP(targetPos)
            NOTIFY("Car Tools", "✅ TP'd to your car!", 3)
        end },
        { name = "Bring Car", action = function()
            local vehicle = CAR_GET_VEHICLE()
            if not vehicle then NOTIFY("Car Tools", "❌ No car spawned!", 3) return end
            local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                vehicle:PivotTo(hrp.CFrame + hrp.CFrame.LookVector * 10 + Vector3.new(0, 2, 0))
                NOTIFY("Car Tools", "✅ Car brought to you!", 3)
            end
        end },
        { name = "Flip Car", action = function()
            local vehicle = CAR_GET_VEHICLE()
            if not vehicle then NOTIFY("Car Tools", "❌ No car spawned!", 3) return end
            local pivot = vehicle:GetPivot()
            vehicle:PivotTo(CFrame.new(pivot.Position) + Vector3.new(0, 3, 0))
            NOTIFY("Car Tools", "✅ Car flipped!", 3)
        end },
    }

    local TOOLS_H = math.min(#TOOLS_LIST * 28, 180)
    D_TOOLS.SCR.Size = UDim2.new(1, 0, 0, TOOLS_H)
    D_TOOLS.OPEN(TOOLS_H) D_TOOLS.CLOSE()

    for i, tool in ipairs(TOOLS_LIST) do
        local ITM = Instance.new("TextButton", D_TOOLS.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. tool.name
        ITM.TextColor3 = CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 23
        ITM.LayoutOrder = i

        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)
        ITM.MouseButton1Click:Connect(function()
            D_TOOLS.CLOSE()
            tool.action()
        end)
    end
end
SETUP_CAR_MODS()

local function SETUP_CAR_DEALER()
    -- ── CAR DEALER CARD ────────────────────────────────────
    local DEALER_CARD = Instance.new("Frame", COL_R)
    DEALER_CARD.Size = UDim2.new(1, 0, 0, 0)
    DEALER_CARD.AutomaticSize = Enum.AutomaticSize.Y
    DEALER_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    DEALER_CARD.BackgroundTransparency = 0.2
    DEALER_CARD.BorderSizePixel = 0
    DEALER_CARD.LayoutOrder = 2
    RND(DEALER_CARD, 12)
    STR(DEALER_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local DLR_LAY = Instance.new("UIListLayout", DEALER_CARD)
    DLR_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    DLR_LAY.Padding = UDim.new(0, 10)

    local DLR_PAD = Instance.new("UIPadding", DEALER_CARD)
    DLR_PAD.PaddingTop    = UDim.new(0, 12)
    DLR_PAD.PaddingBottom = UDim.new(0, 14)
    DLR_PAD.PaddingLeft   = UDim.new(0, 12)
    DLR_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local DLR_HDR = Instance.new("Frame", DEALER_CARD)
    DLR_HDR.Size = UDim2.new(1, 0, 0, 35)
    DLR_HDR.BackgroundTransparency = 1
    DLR_HDR.LayoutOrder = 0

    local DLR_ICN = Instance.new("ImageLabel", DLR_HDR)
    DLR_ICN.Size = UDim2.new(0, 32, 0, 32)
    DLR_ICN.Position = UDim2.new(0, 0, 0.5, -16)
    DLR_ICN.BackgroundTransparency = 1
    DLR_ICN.Image = "rbxassetid://106507089706013"
    DLR_ICN.ImageColor3 = CFG.COL.ACC

    local DLR_TTL = Instance.new("TextLabel", DLR_HDR)
    DLR_TTL.Size = UDim2.new(1, -40, 1, 0)
    DLR_TTL.Position = UDim2.new(0, 40, 0, 0)
    DLR_TTL.BackgroundTransparency = 1
    DLR_TTL.Text = "Car Dealer"
    DLR_TTL.TextColor3 = CFG.COL.TXT
    DLR_TTL.Font = Enum.Font.GothamBold
    DLR_TTL.TextSize = 18
    DLR_TTL.TextXAlignment = Enum.TextXAlignment.Left

    local DLR_DIV = Instance.new("Frame", DEALER_CARD)
    DLR_DIV.Size = UDim2.new(1, 0, 0, 1)
    DLR_DIV.BackgroundColor3 = CFG.COL.ACC
    DLR_DIV.BackgroundTransparency = 0.85
    DLR_DIV.BorderSizePixel = 0
    DLR_DIV.LayoutOrder = 1

    -- Helper to shorten prices
    local function FMT_P(v)
        if v >= 1000000 then return string.format("%.1fM", v/1000000):gsub("%.0M", "M")
        elseif v >= 1000 then return string.format("%dK", v/1000)
        end
        return tostring(v)
    end

    local CAR_LIST = {
        {"Saleen S281 Extreme", 2235000}, {"Rover Sport 5.0 V8 SC", 290000}, {"Porsche Boxster S 718", 520000},
        {"Mercedes-AMG GLS 63 4MATIC", 945000}, {"Lamborghini Urus", 1500000}, {"Infiniti G37 Sedan", 40000},
        {"Hennessey Venom F5", 5000000}, {"Ford LTD LX", 30000}, {"Dodge Ram SRT-10", 1030000},
        {"Dodge Ram 1500 TRX LHD", 1815000}, {"Dodge Charger SRT Hellcat", 680000}, {"Dodge Challenger SRT Hellcat", 655000},
        {"Chevrolet Suburban", 50000}, {"Cheroke SRT Trackhawk", 765000}, {"Cadilac CT5-V Blackwing", 450000},
        {"Bentley Continental GT", 1650000}, {"BMW M5 CS", 870000}, {"Audi R8 V10 Plus", 1760000},
        {"Ford Mustang GT RTR Spec 3", 735000}, {"Audi RS6 Avant", 1090000}, {"Mercedes G63", 1240000}
    }

    local SEL_CAR, SEL_PRC = nil, 0

    local function MK_DLR_DRP(label, order)
        local WRAP = Instance.new("Frame", DEALER_CARD)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.BorderSizePixel = 0
        WRAP.ClipsDescendants = false
        WRAP.ZIndex = 30 - order
        WRAP.LayoutOrder = order

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = CFG.COL.BG
        FRM.BackgroundTransparency = 0.82
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 30 - order
        RND(FRM, 10)
        
        local DLR_STR = STR(FRM, CFG.COL.ACC, 1.2)
        DLR_STR.Transparency = 0.8
        DLR_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local DLR_GRAD = Instance.new("UIGradient", FRM)
        DLR_GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
        })
        DLR_GRAD.Rotation = 45
        DLR_GRAD.Transparency = NumberSequence.new(0.5)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. label
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 31 - order

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 16, 0, 16)
        ICO.Position = UDim2.new(1, -24, 0.5, -8)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 32 - order

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 32 - order
        SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SCR.CanvasSize = UDim2.new(0,0,0,0)

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H = 180

        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN()
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end
        BTN.MouseButton1Click:Connect(function() if IS_OPEN then CLOSE() else OPEN() end end)
        return { BTN=BTN, SCR=SCR, CLOSE=CLOSE }
    end

    local DLR_DRP = MK_DLR_DRP("Choose Luxury Car", 2)
    DLR_DRP.SCR.Size = UDim2.new(1,0,0,180)

    for i, data in ipairs(CAR_LIST) do
        local name, price = data[1], data[2]
        local ITM = Instance.new("TextButton", DLR_DRP.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = string.format("  %s — %s", name, FMT_P(price))
        ITM.TextColor3 = CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 11
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 33
        ITM.LayoutOrder = i
        
        ITM.MouseEnter:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1)
        end)
        ITM.MouseLeave:Connect(function()
            TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1)
        end)

        ITM.MouseButton1Click:Connect(function()
            SEL_CAR = name; SEL_PRC = price
            DLR_DRP.BTN.Text = "  " .. name .. " (" .. FMT_P(price) .. ")"
            DLR_DRP.CLOSE()
        end)
    end

    local BUY_BTN = Instance.new("TextButton", DEALER_CARD)
    BUY_BTN.Size = UDim2.new(1, 0, 0, 35)
    BUY_BTN.BackgroundColor3 = CFG.COL.BG
    BUY_BTN.BackgroundTransparency = 0.82
    BUY_BTN.BorderSizePixel = 0
    BUY_BTN.Text = "Buy Car"
    BUY_BTN.TextColor3 = CFG.COL.ACC
    BUY_BTN.Font = Enum.Font.GothamBold
    BUY_BTN.TextSize = 14
    BUY_BTN.LayoutOrder = 3
    BUY_BTN.AutoButtonColor = false
    RND(BUY_BTN, 10)

    local BUY_STR = STR(BUY_BTN, CFG.COL.ACC, 1.2)
    BUY_STR.Transparency = 0.8
    BUY_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local BUY_GRAD = Instance.new("UIGradient", BUY_BTN)
    BUY_GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
    })
    BUY_GRAD.Rotation = 45
    BUY_GRAD.Transparency = NumberSequence.new(0.5)

    BUY_BTN.MouseEnter:Connect(function()
        TWN(BUY_BTN, {BackgroundTransparency = 0.65, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0,0,0)}, 0.2)
        TWN(BUY_STR, {Transparency = 0.5}, 0.2)
    end)
    BUY_BTN.MouseLeave:Connect(function()
        TWN(BUY_BTN, {BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG, TextColor3 = CFG.COL.ACC}, 0.2)
        TWN(BUY_STR, {Transparency = 0.8}, 0.2)
    end)

    BUY_BTN.MouseButton1Click:Connect(function()
        if not SEL_CAR then NOTIFY("Dealer", "Select a car first!", 3) return end
        local bank = LPLR.Player_Data.Bank.Value
        if bank < SEL_PRC then NOTIFY("Dealer", "Need $" .. SEL_PRC .. " in Bank", 4) return end
        
        TWN(BUY_BTN, {BackgroundTransparency = 0.4, TextSize = 13}, 0.1)
        task.wait(0.1)
        TWN(BUY_BTN, {BackgroundTransparency = 0.65, TextSize = 14}, 0.1)

        local remote = RS_CAR.Remotes:FindFirstChild("Vehicle_Purchase")
        if not remote then NOTIFY("Dealer", "Remote not found!", 3) return end

        local success, err = pcall(function()
            if remote:IsA("RemoteFunction") then
                return remote:InvokeServer(SEL_CAR)
            else
                -- If somehow it's a RemoteEvent or something else
                local m = remote.InvokeServer or remote.FireServer
                if m then return m(remote, SEL_CAR) end
            end
        end)

        if success then
            NOTIFY("Dealer", "✅ Purchased " .. SEL_CAR .. "!", 3)
        else
            NOTIFY("Dealer", "❌ Error: See Console", 5)
            warn("[Car Dealer Error]:", err)
        end
    end)
end
SETUP_CAR_DEALER()

-- [ DEV CONSOLE CLEANER — one time ]
do
    local _core = game:GetService("CoreGui")
    local _run  = game:GetService("RunService")
    local _done = false
    local _hb
    _hb = _run.Heartbeat:Connect(function()
        local master = _core:FindFirstChild("DevConsoleMaster")
        if not master then return end
        local window = master:FindFirstChild("DevConsoleWindow")
        if not window then return end
        local ui = window:FindFirstChild("DevConsoleUI")
        if not ui then return end
        local mainview = ui:FindFirstChild("MainView")
        if mainview then
            local log = mainview:FindFirstChild("ClientLog")
            if log then
                for _, v in pairs(log:GetDescendants()) do
                    if v:IsA("TextLabel") or v:IsA("ImageLabel") or v:IsA("ImageButton") then
                        v:Destroy()
                    end
                end
                log.DescendantAdded:Connect(function(d)
                    if d:IsA("TextLabel") or d:IsA("ImageLabel") or d:IsA("ImageButton") then
                        d:Destroy()
                    end
                end)
            end
        end
        local topbar = ui:FindFirstChild("TopBar")
        if topbar then
            local live = topbar:FindFirstChild("LiveStatsModule")
            if live then
                local e = live:FindFirstChild("LogErrorCount")
                local w = live:FindFirstChild("LogWarningCount")
                if e then e.Text = "0" end
                if w then w.Text = "0" end
            end
        end
        if not _done then
            _done = true
            _hb:Disconnect()
        end
    end)
end

-- ============================================================
--  VISUALS → ESP & WORLD
-- ============================================================
local function SETUP_VISUALS()
    local VL, VR = ADD_SPLIT(P_VIS)
    VL.Parent.Size = UDim2.new(1, -10, 1, -10)
    VL.Parent.Position = UDim2.new(0, 5, 0, 5)
    
    local LL = Instance.new("UIListLayout", VL)
    LL.Padding = UDim.new(0, 10)
    LL.SortOrder = Enum.SortOrder.LayoutOrder
    
    local RL = Instance.new("UIListLayout", VR)
    RL.Padding = UDim.new(0, 10)
    RL.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function MK_CARD(parent, title, icon)
        local C = Instance.new("Frame", parent)
        C.Size = UDim2.new(1, 0, 0, 0)
        C.AutomaticSize = Enum.AutomaticSize.Y
        C.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        C.BackgroundTransparency = 0.3
        RND(C, 12)
        STR(C, CFG.COL.ACC, 1).Transparency = 0.8
        local PL = Instance.new("UIListLayout", C)
        PL.Padding = UDim.new(0, 2)
        local PAD = Instance.new("UIPadding", C)
        PAD.PaddingTop, PAD.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
        PAD.PaddingLeft, PAD.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)

        local H = Instance.new("Frame", C)
        H.Size = UDim2.new(1, 0, 0, 35)
        H.BackgroundTransparency = 1
        local HI = Instance.new("ImageLabel", H)
        HI.Size = UDim2.new(0, 24, 0, 24)
        HI.Position = UDim2.new(0, 0, 0.5, -12)
        HI.BackgroundTransparency = 1
        HI.Image = icon or "rbxassetid://10747373176" 
        HI.ImageColor3 = Color3.fromRGB(50, 150, 255)
        local HT = Instance.new("TextLabel", H)
        HT.Size = UDim2.new(1, -30, 1, 0)
        HT.Position = UDim2.new(0, 30, 0, 0)
        HT.BackgroundTransparency = 1
        HT.Text = title
        HT.TextColor3 = Color3.new(1, 1, 1)
        HT.Font = Enum.Font.GothamBold
        HT.TextSize = 16
        HT.TextXAlignment = Enum.TextXAlignment.Left

        return C
    end

    local C1 = MK_CARD(VL, "Player Visuals", "rbxassetid://10747373176")
    ADD_ESP_ROW(C1, "Enabled", ESP_CFG.Enabled, function(v) ESP_CFG.Enabled = v end)
    ADD_ESP_ROW(C1, "Bounding Boxes", ESP_CFG.Boxes.Enabled, function(v) ESP_CFG.Boxes.Enabled = v end, {{VAL = ESP_CFG.Boxes.Color, CB = function(c) ESP_CFG.Boxes.Color = c end}})
    ADD_ESP_ROW(C1, "Corner Boxes", ESP_CFG.Corners.Enabled, function(v) ESP_CFG.Corners.Enabled = v end, {{VAL = ESP_CFG.Corners.Color, CB = function(c) ESP_CFG.Corners.Color = c end}})
    ADD_ESP_ROW(C1, "Filled Boxes", ESP_CFG.Filled.Enabled, function(v) ESP_CFG.Filled.Enabled = v end, {
        {VAL = ESP_CFG.Filled.Color1, CB = function(c) ESP_CFG.Filled.Color1 = c end},
        {VAL = ESP_CFG.Filled.Color2, CB = function(c) ESP_CFG.Filled.Color2 = c end}
    })
    ADD_ESP_ROW(C1, "Names", ESP_CFG.Names.Enabled, function(v) ESP_CFG.Names.Enabled = v end, {{VAL = ESP_CFG.Names.Color, CB = function(c) ESP_CFG.Names.Color = c end}})
    ADD_ESP_ROW(C1, "Health Bars", ESP_CFG.Health.Bar, function(v) ESP_CFG.Health.Bar = v end, {
        {VAL = ESP_CFG.Health.Color1, CB = function(c) ESP_CFG.Health.Color1 = c end},
        {VAL = ESP_CFG.Health.Color2, CB = function(c) ESP_CFG.Health.Color2 = c end}
    })
    ADD_ESP_ROW(C1, "Health Text", ESP_CFG.Health.Text, function(v) ESP_CFG.Health.Text = v end)
    ADD_ESP_ROW(C1, "Weapons", ESP_CFG.Weapons.Enabled, function(v) ESP_CFG.Weapons.Enabled = v end, {{VAL = ESP_CFG.Weapons.Color, CB = function(c) ESP_CFG.Weapons.Color = c end}})
    ADD_ESP_ROW(C1, "Distance", ESP_CFG.Dist.Enabled, function(v) ESP_CFG.Dist.Enabled = v end, {{VAL = ESP_CFG.Dist.Color, CB = function(c) ESP_CFG.Dist.Color = c end}})
    ADD_ESP_ROW(C1, "Chams", ESP_CFG.Chams.Enabled, function(v) ESP_CFG.Chams.Enabled = v end, {
        {VAL = ESP_CFG.Chams.Color1, CB = function(c) ESP_CFG.Chams.Color1 = c end},
        {VAL = ESP_CFG.Chams.Color2, CB = function(c) ESP_CFG.Chams.Color2 = c end}
    })
    ADD_ESP_ROW(C1, "Tool Charms", ESP_CFG.ToolCharms.Enabled, function(v) ESP_CFG.ToolCharms.Enabled = v end, {
        {VAL = ESP_CFG.ToolCharms.Color1, CB = function(c) ESP_CFG.ToolCharms.Color1 = c end},
        {VAL = ESP_CFG.ToolCharms.Color2, CB = function(c) ESP_CFG.ToolCharms.Color2 = c end}
    })

    local C3 = MK_CARD(VR, "Silent Aim", "rbxassetid://10747373176")
    ADD_TGL_KB(C3, "Enable", false, nil, function(v, k) ESP_CFG.SilentAim.Enabled = v; ESP_CFG.SilentAim.Keybind = k end)
    ADD_ESP_ROW(C3, "Snapline", ESP_CFG.Snapline.Enabled, function(v) ESP_CFG.Snapline.Enabled = v end, {{VAL = ESP_CFG.Snapline.Color, CB = function(c) ESP_CFG.Snapline.Color = c end}})
    ADD_SLD(C3, "Snapline Thickness", 1, 5, ESP_CFG.Snapline.Thickness, function(v) ESP_CFG.Snapline.Thickness = v end)

    local C2 = MK_CARD(VR, "Player Visual Settings", "rbxassetid://10734950309")
    ADD_ESP_ROW(C2, "Animated Boxes", ESP_CFG.Boxes.Animated, function(v) ESP_CFG.Boxes.Animated = v end)
    ADD_ESP_ROW(C2, "Dynamic Health Text", ESP_CFG.Health.Dynamic, function(v) ESP_CFG.Health.Dynamic = v end)
    ADD_ESP_ROW(C2, "Thermal Chams", ESP_CFG.Chams.Thermal, function(v) ESP_CFG.Chams.Thermal = v end)
    
    local F_DRP = ADD_DRP(C2, "Text Font", function(v) 
        local f = Fonts[v] or Enum.Font[v]
        -- Fonts[v] returns a Font object (new system), Enum.Font[v] returns EnumItem
        -- For .Font property we need EnumItem; for .FontFace we need Font object
        -- Store both for safe use in UPD_ESP
        ESP_CFG.Font     = (typeof(f) == "EnumItem") and f or Enum.Font.GothamBold
        ESP_CFG.FontFace = (typeof(f) == "Font")     and f or nil
    end)
    F_DRP.REFRESH({"GothamBold", "Gotham", "Code", "Roboto", "Arcade", "SciFi"})
    
    ADD_SLD(C2, "Text Size", 8, 24, ESP_CFG.FontSize, function(v) ESP_CFG.FontSize = v end)
    ADD_SLD(C2, "Max Render Distance", 100, 5000, ESP_CFG.MaxDist, function(v) ESP_CFG.MaxDist = v end, "st")
    
    ADD_TGL(C2, "Fullbright", false, function(v) 
        game:GetService("Lighting").Brightness = v and 2 or 1
        game:GetService("Lighting").OutdoorAmbient = v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    end)
end
SETUP_VISUALS()

-- ============================================================
--  CONFIG → SETTINGS & FEEDBACK
-- ============================================================
local function SETUP_CONFIG()
    local CL, CR = ADD_SPLIT(P_SET)

    -- Fix column sizes & add vertical list layouts (same as SETUP_VISUALS)
    CL.Parent.Size     = UDim2.new(1, -10, 1, -10)
    CL.Parent.Position = UDim2.new(0, 5, 0, 5)
    CL.Size = UDim2.new(0.5, -2, 1, 0)
    CL.AutomaticSize = Enum.AutomaticSize.Y

    local CL_LAY = Instance.new("UIListLayout", CL)
    CL_LAY.Padding = UDim.new(0, 10)
    CL_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    CL_LAY.HorizontalAlignment = Enum.HorizontalAlignment.Center

    CR.Size = UDim2.new(0.5, -2, 1, 0)
    CR.AutomaticSize = Enum.AutomaticSize.Y

    local CR_LAY = Instance.new("UIListLayout", CR)
    CR_LAY.Padding = UDim.new(0, 10)
    CR_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    CR_LAY.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function MK_CARD(parent, title, icon)
        local C = Instance.new("Frame", parent)
        C.Size = UDim2.new(1, 0, 0, 0)
        C.AutomaticSize = Enum.AutomaticSize.Y
        C.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        C.BackgroundTransparency = 0.3
        RND(C, 12)
        STR(C, CFG.COL.ACC, 1).Transparency = 0.8
        
        local PL = Instance.new("UIListLayout", C)
        PL.Padding = UDim.new(0, 6)
        
        local PAD = Instance.new("UIPadding", C)
        PAD.PaddingTop, PAD.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
        PAD.PaddingLeft, PAD.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)

        local H = Instance.new("Frame", C)
        H.Size = UDim2.new(1, 0, 0, 35)
        H.BackgroundTransparency = 1
        
        local HI = Instance.new("ImageLabel", H)
        HI.Size = UDim2.new(0, 24, 0, 24)
        HI.Position = UDim2.new(0, 0, 0.5, -12)
        HI.BackgroundTransparency = 1
        HI.Image = icon or "rbxassetid://10747373176" 
        HI.ImageColor3 = CFG.COL.ACC
        
        local HT = Instance.new("TextLabel", H)
        HT.Size = UDim2.new(1, -30, 1, 0)
        HT.Position = UDim2.new(0, 30, 0, 0)
        HT.BackgroundTransparency = 1
        HT.Text = title
        HT.TextColor3 = Color3.new(1, 1, 1)
        HT.Font = Enum.Font.GothamBold
        HT.TextSize = 16
        HT.TextXAlignment = Enum.TextXAlignment.Left

        return C
    end

    -- ── TELEPORT BYPASS METHODS CARD (Dropdown Style) ──────
    local TP_CARD_SET = Instance.new("Frame", CR)
    TP_CARD_SET.Size = UDim2.new(1, 0, 0, 0)
    TP_CARD_SET.AutomaticSize = Enum.AutomaticSize.Y
    TP_CARD_SET.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    TP_CARD_SET.BackgroundTransparency = 0.2
    TP_CARD_SET.BorderSizePixel = 0
    TP_CARD_SET.LayoutOrder = 2
    RND(TP_CARD_SET, 12)
    STR(TP_CARD_SET, CFG.COL.ACC, 1).Transparency = 0.75

    local TP_LAY = Instance.new("UIListLayout", TP_CARD_SET)
    TP_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    TP_LAY.Padding = UDim.new(0, 10)

    local TP_PAD = Instance.new("UIPadding", TP_CARD_SET)
    TP_PAD.PaddingTop    = UDim.new(0, 12)
    TP_PAD.PaddingBottom = UDim.new(0, 14)
    TP_PAD.PaddingLeft   = UDim.new(0, 12)
    TP_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local TP_HDR = Instance.new("Frame", TP_CARD_SET)
    TP_HDR.Size = UDim2.new(1, 0, 0, 35)
    TP_HDR.BackgroundTransparency = 1
    TP_HDR.LayoutOrder = 0

    local TP_ICN = Instance.new("ImageLabel", TP_HDR)
    TP_ICN.Size = UDim2.new(0, 32, 0, 32)
    TP_ICN.Position = UDim2.new(0, 0, 0.5, -16)
    TP_ICN.BackgroundTransparency = 1
    TP_ICN.Image = "rbxassetid://102084991489439"
    TP_ICN.ImageColor3 = CFG.COL.ACC

    local TP_TTL = Instance.new("TextLabel", TP_HDR)
    TP_TTL.Size = UDim2.new(1, -40, 1, 0)
    TP_TTL.Position = UDim2.new(0, 40, 0, 0)
    TP_TTL.BackgroundTransparency = 1
    TP_TTL.Text = "Bypass Method"
    TP_TTL.TextColor3 = CFG.COL.TXT
    TP_TTL.Font = Enum.Font.GothamBold
    TP_TTL.TextSize = 18
    TP_TTL.TextXAlignment = Enum.TextXAlignment.Left

    local TP_DIV = Instance.new("Frame", TP_CARD_SET)
    TP_DIV.Size = UDim2.new(1, 0, 0, 1)
    TP_DIV.BackgroundColor3 = CFG.COL.ACC
    TP_DIV.BackgroundTransparency = 0.85
    TP_DIV.BorderSizePixel = 0
    TP_DIV.LayoutOrder = 1

    -- Dropdown factory for this card
    local function MK_TP_SET_DRP(label, order)
        local WRAP = Instance.new("Frame", TP_CARD_SET)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.BorderSizePixel = 0
        WRAP.ClipsDescendants = false
        WRAP.ZIndex = 20 - order
        WRAP.LayoutOrder = order

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = CFG.COL.BG
        FRM.BackgroundTransparency = 0.82
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 20 - order
        RND(FRM, 10)
        
        local BP_STR = STR(FRM, CFG.COL.ACC, 1.2)
        BP_STR.Transparency = 0.8
        BP_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local BP_GRAD = Instance.new("UIGradient", FRM)
        BP_GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))
        })
        BP_GRAD.Rotation = 45
        BP_GRAD.Transparency = NumberSequence.new(0.5)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. label
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 21 - order

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 16, 0, 16)
        ICO.Position = UDim2.new(1, -24, 0.5, -8)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 22 - order

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 22 - order
        SCR.CanvasSize = UDim2.new(0, 0, 0, 0)
        SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H = 0

        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN(H)
            if H then DRP_H = H end
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, SCR=SCR, LAY=LAY, CLOSE=CLOSE, OPEN=OPEN }
    end

    local METHODS = {
        { name = "Classic", id = "classic" },
        { name = "Stepped", id = "stepped" },
        { name = "Scooter", id = "scooter" }
    }

    local currentName = "Stepped"
    for _, m in ipairs(METHODS) do if m.id == TP_METHOD then currentName = m.name end end
    
    local D_TP = MK_TP_SET_DRP(currentName, 2)
    
    for i, m in ipairs(METHODS) do
        local ITM = Instance.new("TextButton", D_TP.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 28)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. m.name
        ITM.TextColor3 = CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 12
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 23
        ITM.LayoutOrder = i
        
        ITM.MouseEnter:Connect(function() TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1) end)
        ITM.MouseLeave:Connect(function() TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1) end)
        
        ITM.MouseButton1Click:Connect(function()
            TP_METHOD = m.id
            D_TP.BTN.Text = "  " .. m.name
            D_TP.CLOSE()
            NOTIFY("Bypass", "Method set to: " .. m.name, 3)
        end)
    end
    
    local h = #METHODS * 28
    D_TP.SCR.Size = UDim2.new(1, 0, 0, h)
    D_TP.OPEN(h) D_TP.CLOSE()

    -- ── THEME / TEXT CARD ───────────────────────────────────
    local TH_CARD = Instance.new("Frame", CR)
    TH_CARD.Size = UDim2.new(1, 0, 0, 0)
    TH_CARD.AutomaticSize = Enum.AutomaticSize.Y
    TH_CARD.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    TH_CARD.BackgroundTransparency = 0.2
    TH_CARD.BorderSizePixel = 0
    TH_CARD.LayoutOrder = 3
    RND(TH_CARD, 12)
    STR(TH_CARD, CFG.COL.ACC, 1).Transparency = 0.75

    local TH_LAY = Instance.new("UIListLayout", TH_CARD)
    TH_LAY.SortOrder = Enum.SortOrder.LayoutOrder
    TH_LAY.Padding = UDim.new(0, 10)

    local TH_PAD = Instance.new("UIPadding", TH_CARD)
    TH_PAD.PaddingTop    = UDim.new(0, 12)
    TH_PAD.PaddingBottom = UDim.new(0, 14)
    TH_PAD.PaddingLeft   = UDim.new(0, 12)
    TH_PAD.PaddingRight  = UDim.new(0, 12)

    -- Header
    local TH_HDR = Instance.new("Frame", TH_CARD)
    TH_HDR.Size = UDim2.new(1, 0, 0, 35)
    TH_HDR.BackgroundTransparency = 1
    TH_HDR.LayoutOrder = 0

    local TH_ICN = Instance.new("ImageLabel", TH_HDR)
    TH_ICN.Size = UDim2.new(0, 32, 0, 32)
    TH_ICN.Position = UDim2.new(0, 0, 0.5, -16)
    TH_ICN.BackgroundTransparency = 1
    TH_ICN.Image = "rbxassetid://77077610158107"
    TH_ICN.ImageColor3 = CFG.COL.ACC

    local TH_TTL = Instance.new("TextLabel", TH_HDR)
    TH_TTL.Size = UDim2.new(1, -40, 1, 0)
    TH_TTL.Position = UDim2.new(0, 40, 0, 0)
    TH_TTL.BackgroundTransparency = 1
    TH_TTL.Text = "Theme / Text"
    TH_TTL.TextColor3 = CFG.COL.TXT
    TH_TTL.Font = Enum.Font.GothamBold
    TH_TTL.TextSize = 18
    TH_TTL.TextXAlignment = Enum.TextXAlignment.Left

    local TH_DIV = Instance.new("Frame", TH_CARD)
    TH_DIV.Size = UDim2.new(1, 0, 0, 1)
    TH_DIV.BackgroundColor3 = CFG.COL.ACC
    TH_DIV.BackgroundTransparency = 0.85
    TH_DIV.BorderSizePixel = 0
    TH_DIV.LayoutOrder = 1

    -- Dropdown factory reutilizable para esta card
    local function MK_TH_DRP(label, order)
        local WRAP = Instance.new("Frame", TH_CARD)
        WRAP.Size = UDim2.new(1, 0, 0, 35)
        WRAP.BackgroundTransparency = 1
        WRAP.BorderSizePixel = 0
        WRAP.ClipsDescendants = false
        WRAP.ZIndex = 18 - order
        WRAP.LayoutOrder = order

        local FRM = Instance.new("Frame", WRAP)
        FRM.Size = UDim2.new(1, 0, 0, 35)
        FRM.BackgroundColor3 = CFG.COL.BG
        FRM.BackgroundTransparency = 0.4
        FRM.BorderSizePixel = 0
        FRM.ClipsDescendants = true
        FRM.ZIndex = 18 - order
        RND(FRM, 8)
        STR(FRM, CFG.COL.GRY, 1)

        local BTN = Instance.new("TextButton", FRM)
        BTN.Size = UDim2.new(1, 0, 0, 35)
        BTN.BackgroundTransparency = 1
        BTN.Text = "  " .. label
        BTN.TextColor3 = CFG.COL.TXT
        BTN.Font = Enum.Font.GothamBold
        BTN.TextSize = 14
        BTN.TextXAlignment = Enum.TextXAlignment.Left
        BTN.ZIndex = 19 - order

        local ICO = Instance.new("ImageLabel", BTN)
        ICO.Size = UDim2.new(0, 16, 0, 16)
        ICO.Position = UDim2.new(1, -24, 0.5, -8)
        ICO.BackgroundTransparency = 1
        ICO.Image = "rbxassetid://6031091004"
        ICO.ImageColor3 = CFG.COL.ACC
        ICO.ZIndex = 20 - order

        local SCR = Instance.new("ScrollingFrame", FRM)
        SCR.Position = UDim2.new(0, 0, 0, 35)
        SCR.BackgroundTransparency = 1
        SCR.BorderSizePixel = 0
        SCR.ScrollBarThickness = 2
        SCR.ScrollBarImageColor3 = CFG.COL.ACC
        SCR.ZIndex = 20 - order
        SCR.CanvasSize = UDim2.new(0, 0, 0, 0)
        SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local LAY = Instance.new("UIListLayout", SCR)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder

        local IS_OPEN = false
        local DRP_H = 0

        local function CLOSE()
            IS_OPEN = false
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35)})
            TWN(ICO,  {Rotation = 0})
        end
        local function OPEN(H)
            if H then DRP_H = H end
            IS_OPEN = true
            TWN(FRM,  {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(WRAP, {Size = UDim2.new(1, 0, 0, 35 + DRP_H)})
            TWN(ICO,  {Rotation = 180})
        end

        BTN.MouseButton1Click:Connect(function()
            if IS_OPEN then CLOSE() else OPEN() end
        end)

        return { FRM=FRM, WRAP=WRAP, BTN=BTN, ICO=ICO, SCR=SCR, LAY=LAY, CLOSE=CLOSE, OPEN=OPEN }
    end

    -- ── DROPDOWN 1: UI Theme ─────────────────────────────────
    local THEME_LIST = {
        { name = "Default",     icon = "🔴" },
        { name = "Snow White",  icon = "❄️" },
        { name = "Sky Blue",    icon = "🌊" },
        { name = "Void Black",  icon = "🌑" },
        { name = "Coffee",      icon = "☕" },
        { name = "Gold",        icon = "✨" },
    }
    local D_THEME = MK_TH_DRP("UI Theme", 2)
    local thH = #THEME_LIST * 30
    D_THEME.SCR.Size = UDim2.new(1, 0, 0, thH)
    D_THEME.OPEN(thH) D_THEME.CLOSE()

    for i, t in ipairs(THEME_LIST) do
        local ITM = Instance.new("TextButton", D_THEME.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. t.icon .. "  " .. t.name
        ITM.TextColor3 = CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 13
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 21
        ITM.LayoutOrder = i
        ITM.MouseEnter:Connect(function() TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1) end)
        ITM.MouseLeave:Connect(function() TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1) end)
        ITM.MouseButton1Click:Connect(function()
            D_THEME.BTN.Text = "  " .. t.icon .. "  " .. t.name
            D_THEME.CLOSE()
            APPLY_THEME(t.name)
            NOTIFY("Theme", t.name .. " applied!", 3)
        end)
    end

    -- ── DROPDOWN 2: Text Font ────────────────────────────────
    local FONT_LIST = {
        { name = "GothamBold", font = Enum.Font.GothamBold },
        { name = "Gotham",     font = Enum.Font.Gotham },
        { name = "Code",       font = Enum.Font.Code },
        { name = "Roboto",     font = Enum.Font.Roboto },
        { name = "Arcade",     font = Enum.Font.Arcade },
        { name = "SciFi",      font = Enum.Font.SciFi },
    }
    local D_FONT = MK_TH_DRP("Text Font", 3)
    local fH = #FONT_LIST * 30
    D_FONT.SCR.Size = UDim2.new(1, 0, 0, fH)
    D_FONT.OPEN(fH) D_FONT.CLOSE()

    for i, f in ipairs(FONT_LIST) do
        local ITM = Instance.new("TextButton", D_FONT.SCR)
        ITM.Size = UDim2.new(1, 0, 0, 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = "  " .. f.name
        ITM.TextColor3 = CFG.COL.TXT
        ITM.Font = Enum.Font.Gotham
        ITM.TextSize = 13
        ITM.TextXAlignment = Enum.TextXAlignment.Left
        ITM.ZIndex = 21
        ITM.LayoutOrder = i
        ITM.MouseEnter:Connect(function() TWN(ITM, {TextColor3 = CFG.COL.ACC}, 0.1) end)
        ITM.MouseLeave:Connect(function() TWN(ITM, {TextColor3 = CFG.COL.TXT}, 0.1) end)
        ITM.MouseButton1Click:Connect(function()
            D_FONT.BTN.Text = "  " .. f.name
            D_FONT.CLOSE()
            -- Aplicar fuente al UI completo
            APPLY_FONT_UI(f.font)
            -- Actualizar ESP font (usa Enum.Font directamente)
            ESP_CFG.Font = f.font
            NOTIFY("Font", f.name .. " applied!", 3)
        end)
    end

    -- ── SEND FEEDBACK CARD ──────────────────────────────────
    local FDBK_CARD = MK_CARD(CL, "Send Feedback", "rbxassetid://121092009137441")
    
    ADD_LBL(FDBK_CARD, "Found a bug or have a suggestion?")
    
    local FDBK_TXT = ADD_TEXTAREA(FDBK_CARD, "Write your feedback, bug report, or feature request here...", "", 100)
    
    local DEBOUNCE = false
    ADD_BTN(FDBK_CARD, "Send to Discord", function()
        if DEBOUNCE then return NOTIFY("Wait", "Please wait before sending again.", 3) end
        
        local msg = FDBK_TXT.Text
        if not msg or msg == "" then
            return NOTIFY("Error", "Feedback cannot be empty!", 3)
        end
        if string.len(msg) < 10 then
            return NOTIFY("Error", "Feedback must be at least 10 characters.", 3)
        end
        
        local req = request or http_request or (syn and syn.request)
        if not req then
            return NOTIFY("Error", "Your executor does not support sending requests.", 5)
        end

        DEBOUNCE = true
        local payload = {
            embeds = {{
                title = "💬 New Script Feedback",
                description = "```\n" .. msg .. "\n```",
                color = 0x32A852,
                fields = {
                    { name = "Username", value = LPLR.Name, inline = true },
                    { name = "User ID", value = tostring(LPLR.UserId), inline = true }
                },
                footer = { text = "Antigravity generated feedback module" },
                timestamp = DateTime.now():ToIsoDate()
            }}
        }

        task.spawn(function()
            local success, respond = pcall(function()
                return req({
                    Url = "https://discord.com/api/webhooks/1481433215398056087/5yiYW_g6HGoAcxig9zy0YQYX1Ciu3H_5AehQxZk_j0NxnrcWU8Uf7ev5-XmerOix7JGa",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = game:GetService("HttpService"):JSONEncode(payload)
                })
            end)
            
            if success and respond and (respond.StatusCode == 200 or respond.StatusCode == 204) then
                NOTIFY("Success", "Thanks for your feedback! Sent to discord.", 4)
                FDBK_TXT.Text = ""
            else
                NOTIFY("Error", "Failed to send feedback. Status: " .. tostring(respond and respond.StatusCode or "Unknown"), 5)
            end
            task.wait(5)
            DEBOUNCE = false
        end)
    end)
end
SETUP_CONFIG()

-- [ ACTIVATE FIRST TAB ]
do
    CUR_BTN = B_HOM
    CUR_PAG = P_HOM
    TWN(B_HOM, {
        TextColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0,
        BackgroundColor3 = CFG.COL.ACC
    })
    P_HOM.Visible = true
end

-- [ RESIZE HANDLE ]
local RSZ = Instance.new("TextButton", MAIN)
RSZ.Name = "RSZ_HANDLE"
RSZ.Size = UDim2.new(0, 28, 0, 28)
RSZ.Position = UDim2.new(1, -28, 1, -28)
RSZ.BackgroundTransparency = 1
RSZ.Text = ""
RSZ.ZIndex = 10
RSZ.AutoButtonColor = false

-- Three arc lines like ))) rotated 45° into the corner
for i = 1, 3 do
    local ARC = Instance.new("TextLabel", RSZ)
    ARC.Size = UDim2.new(1, 0, 1, 0)
    ARC.BackgroundTransparency = 1
    ARC.Text = ")"
    ARC.TextColor3 = CFG.COL.ACC
    ARC.TextTransparency = i * 0.25
    ARC.Font = Enum.Font.GothamBold
    ARC.TextSize = 10 + i * 4
    ARC.Rotation = 45
    ARC.TextXAlignment = Enum.TextXAlignment.Center
    ARC.TextYAlignment = Enum.TextYAlignment.Center
    ARC.ZIndex = 10
end

RSZ.MouseEnter:Connect(function()
    for _, c in ipairs(RSZ:GetChildren()) do
        if c:IsA("TextLabel") then TWN(c, {TextTransparency = 0}, 0.15) end
    end
end)
RSZ.MouseLeave:Connect(function()
    for i, c in ipairs(RSZ:GetChildren()) do
        if c:IsA("TextLabel") then TWN(c, {TextTransparency = i * 0.25}, 0.2) end
    end
end)

local R_ON, R_STR, R_SIZ, R_INP
RSZ.InputBegan:Connect(function(I)
    if I.UserInputType == Enum.UserInputType.MouseButton1
    or I.UserInputType == Enum.UserInputType.Touch then
        R_ON  = true
        R_STR = I.Position
        R_SIZ = MAIN.AbsoluteSize
        R_INP = I
        I.Changed:Connect(function()
            if I.UserInputState == Enum.UserInputState.End then R_ON = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(I)
    local IS_MOUSE = I.UserInputType == Enum.UserInputType.MouseMovement
    local IS_TOUCH = I.UserInputType == Enum.UserInputType.Touch
    if R_ON and (IS_MOUSE or (IS_TOUCH and I == R_INP)) then
        local DEL = I.Position - R_STR
        local NW_X = math.max(450, R_SIZ.X + DEL.X)
        local NW_Y = math.max(300, R_SIZ.Y + DEL.Y)
        MAIN.Size = UDim2.new(0, NW_X, 0, NW_Y)
    end
end)

-- [ KEYBOARD TOGGLE (RightCtrl) ]
UIS.InputBegan:Connect(function(I, G)
    if not G and I.KeyCode == CFG.KEY then
        MAIN.Visible = not MAIN.Visible
    end
end)

-- [ MOBILE SUPPORT ]
if UIS.TouchEnabled then
    MAIN.AnchorPoint = Vector2.new(0.5, 0.5)
    MAIN.Position    = UDim2.new(0.5, 0, 0.5, 0)
    MAIN.Size        = UDim2.new(0.6, 0, 0.5, 0)

    local MTOG = Instance.new("ImageButton", SCR)
    MTOG.Name = "MTOG"
    MTOG.Size = UDim2.new(0, 50, 0, 50)
    MTOG.Position = UDim2.new(1, -70, 0.2, 0)
    MTOG.BackgroundColor3 = CFG.COL.BG
    MTOG.BackgroundTransparency = 0.2
    MTOG.Image = CFG.IMG
    MTOG.ImageColor3 = CFG.COL.ACC
    MTOG.ZIndex = 100
    RND(MTOG, 25)
    STR(MTOG, CFG.COL.ACC, 2)

    MTOG.MouseButton1Click:Connect(function()
        MAIN.Visible = not MAIN.Visible
    end)

    local M_ON, M_STR, M_POS, M_INP
    MTOG.InputBegan:Connect(function(I)
        if I.UserInputType == Enum.UserInputType.Touch
        or I.UserInputType == Enum.UserInputType.MouseButton1 then
            M_ON  = true
            M_STR = I.Position
            M_POS = MTOG.Position
            M_INP = I
            I.Changed:Connect(function()
                if I.UserInputState == Enum.UserInputState.End then M_ON = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(I)
        local IS_MOUSE = I.UserInputType == Enum.UserInputType.MouseMovement
        local IS_TOUCH = I.UserInputType == Enum.UserInputType.Touch
        if M_ON and (IS_MOUSE or (IS_TOUCH and I == M_INP)) then
            local DEL = I.Position - M_STR
            MTOG.Position = UDim2.new(
                M_POS.X.Scale, M_POS.X.Offset + DEL.X,
                M_POS.Y.Scale, M_POS.Y.Offset + DEL.Y
            )
        end
    end)
end

-- [ DONE ]
NOTIFY("WH01AM", "UI Loaded! RightCtrl to toggle.", 4)
