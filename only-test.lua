-- [ SVC ]
local ENV = { S = setmetatable({}, { __index = function(_, k) return game:GetService(k) end }) }
ENV.P, ENV.T, ENV.U, ENV.C, ENV.RS, ENV.RC = ENV.S.Players, ENV.S.TweenService, ENV.S.UserInputService, ENV.S.CoreGui,
    ENV.S.RunService, ENV.S.ReplicatedStorage
local PLRS, TS, UIS, CORE, RS, RS_CAR = ENV.P, ENV.T, ENV.U, ENV.C, ENV.RS, ENV.RC
local LPLR = PLRS.LocalPlayer

-- [ DETECCIÓN DE EJECUTOR Y COMPATIBILIDAD ]
local executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown"
local isUnsupported = string.find(executor, "Solara") or string.find(executor, "Xeno")

local useFireMethod = false
local testPrompt = Instance.new("ProximityPrompt")
testPrompt.Parent = workspace
local s_det, _ = pcall(function() fireproximityprompt(testPrompt) end)
useFireMethod = s_det
testPrompt:Destroy()

-- [ SINGLETON ]
if _G.CENTRAL_LOADED then
    local OLD = CORE:FindFirstChild("CEN_V2") or LPLR.PlayerGui:FindFirstChild("CEN_V2")
    if OLD then
        warn("Already Loaded!"); return
    else
        _G.CENTRAL_LOADED = false
    end
end
-- [ GLOBAL CFG ]
_G.CENTRAL_LOADED = true
_G.EXE = {
    FARM_RUNNING = false,
    FARM_THREAD = nil,
    BYPASS_CARS_ON = false,
    TP_METHOD = "Classic",
    TP_SPEED = 450,
    GUN_MODS = {
        RapidFire = false,
        InfAmmo = false,
        NoRecoil = false,
        FastReload = false,
        FireRate = 0.05,
        SpeedBypass = false,
        FlySpeed = 50,
        WalkBypassSpeed = 50,
        CarFly = false,
        CarFlySpeed = 150
    }
}

-- [ CFRAME WALK (Movement 1) ]
task.spawn(function()
    local speedBypassConnection
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

    while task.wait(0.5) do
        if _G.EXE.GUN_MODS.SpeedBypass then
            if not speedBypassConnection then
                speedBypassConnection = RS.Heartbeat:Connect(function(dt)
                    local char = LPLR.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and char:FindFirstChild("Humanoid")
                    if not hrp or not humanoid then return end

                    humanoid.AutoRotate = false
                    local speed = _G.EXE.GUN_MODS.WalkBypassSpeed
                    local moveDir
                    local camera = workspace.CurrentCamera

                    if isMobile then
                        local move = humanoid.MoveDirection
                        if move.Magnitude > 0 then
                            local camMove = camera.CFrame:VectorToWorldSpace(move)
                            moveDir = Vector3.new(camMove.X, 0, camMove.Z).Unit
                        end
                    else
                        local camCF = camera.CFrame
                        local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

                        local inputDir = Vector3.new(
                            (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) -
                            (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                            0,
                            (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0) -
                            (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                        )

                        if inputDir.Magnitude > 0 then
                            moveDir = (right * inputDir.X) + (look * inputDir.Z)
                        end
                    end

                    if moveDir and moveDir.Magnitude > 0 then
                        local newPos = hrp.Position + (moveDir * speed * dt)
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = { char }
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0),
                            Vector3.new(0, -25, 0), rayParams)
                        if result then
                            newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
                        end
                        hrp.CFrame = CFrame.new(newPos, newPos + moveDir)
                        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    end

                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = false
                        end
                    end
                end)
            end
        else
            if speedBypassConnection then
                speedBypassConnection:Disconnect()
                speedBypassConnection = nil
                local char = LPLR.Character
                local humanoid = char and char:FindFirstChild("Humanoid")
                if humanoid then humanoid.AutoRotate = true end
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then
                            if p.Name == "Head" or p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "LowerTorso" or p.Name == "HumanoidRootPart" then
                                p.CanCollide = true
                            else
                                p.CanCollide = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- [ DIRECT TP ]

local TP_ENV = { SP_PT = nil, SP_PS = nil }

local function BYPASS_TP(targetPos)
    local plr = game:GetService("Players").LocalPlayer
    local char = plr and plr.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum and hum.SeatPart then
            hum.Sit = false
            task.wait(0.05)
        end

        if hrp then
            local goal = targetPos + Vector3.new(0, 3, 0)
            -- Tween Teleport removed (Classic only)
            hrp.CFrame = CFrame.new(goal)
        end
    end
end

-- ── PROMPT HOLD global (Mobile Compatibility) ─────────────────────────
local function FORCE_HOLD(prompt)
    if not prompt then return end
    -- Prioritize engine simulation over fireproximityprompt for anti-cheat/NYC compatibility
    local success = pcall(function()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1) or 0.2)
        prompt:InputHoldEnd()
    end)
    -- Fallback ONLY if simulation fails
    if not success and fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    end
end


-- ── CAMERA FOCUS UTILITY ─────────────────────────────────────────────
local function FOCUS_CAMERA(targetPart)
    if not targetPart then return nil, nil, nil end

    local cam = workspace.CurrentCamera
    local oldType = cam.CameraType
    local oldCF = cam.CFrame

    -- Focus ANTES de cualquier operación
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPart.Position)

    return cam, oldType, oldCF
end

local function RESTORE_CAMERA(cam, oldType, oldCF)
    if not cam then return end
    cam.CFrame = oldCF
    cam.CameraType = oldType
end

-- ── GET TARGET PART FROM PROMPT ─────────────────────────────────────
local function GET_PROMPT_PART(prompt)
    if not prompt then return nil end
    if prompt.Parent:IsA("BasePart") then
        return prompt.Parent
    end
    return prompt.Parent:FindFirstChildWhichIsA("BasePart")
end

-- ── UNIFIED HOLD (con focus opcional) ────────────────────────────────
local function FORCE_HOLD(prompt, useFocus)
    if not prompt then return false end

    -- Prioritize native fireproximityprompt if available (no focus/hold simulation needed)
    if fireproximityprompt then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end

    -- Fallback: Hold simulation with optional camera focus
    local target = useFocus and GET_PROMPT_PART(prompt) or nil
    local cam, oldType, oldCF

    if target then
        cam, oldType, oldCF = FOCUS_CAMERA(target)
        task.wait(0.05)
    end

    local success = false
    success = pcall(function()
        prompt:InputHoldBegin()
        local duration = prompt.HoldDuration or 0
        if duration > 0 then
            task.wait(duration + 0.05)
        end
        prompt:InputHoldEnd()
    end)

    if target then
        RESTORE_CAMERA(cam, oldType, oldCF)
    end

    return success
end

-- ── WEAPON FIRE (siempre con focus) ──────────────────────────────────
local function FORCE_FIRE_WEAPON(prompt)
    -- Weapon fire SIEMPRE necesita focus en la mayoría de juegos
    return FORCE_HOLD(prompt, true)
end

local Services = setmetatable({}, { __index = function(s, k) return game:GetService(k) end })
local HttpService = Services.HttpService

local Fonts = {}
local function RegisterFont(Name, Weight, Style, AssetUrl)
    local dir = "CEN_V2_ASSETS"
    if not isfolder(dir) then makefolder(dir) end
    if not isfolder(dir .. "/fonts") then makefolder(dir .. "/fonts") end
    if not isfolder(dir .. "/assets") then makefolder(dir .. "/assets") end

    local assetPath = dir .. "/assets/" .. Name .. ".ttf"
    if not isfile(assetPath) then
        writefile(assetPath, game:HttpGet(AssetUrl))
    end

    local fontData = {
        name = Name,
        faces = { {
            name = "Normal",
            weight = Weight,
            style = Style,
            assetId = getcustomasset(assetPath)
        } }
    }

    local fontPath = dir .. "/fonts/" .. Name .. ".font"
    writefile(fontPath, HttpService:JSONEncode(fontData))
    return Font.new(getcustomasset(fontPath))
end

task.spawn(function()
    Fonts["Plex"] = RegisterFont("Plex", 400, "Normal",
        "https://github.com/KingVonOBlockJoyce/OctoHook-UI/raw/refs/heads/main/fs-tahoma-8px%20(3).ttf")
end)

local CFG                    = {
    KEY = Enum.KeyCode.LeftControl,
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

-- [ PERSISTENCE SYSTEM ]
-- [ UI THEMES ]
local UI_REGISTERED_ELEMENTS = {} -- tabla de todos los elementos vivos para repintar

local UI_THEMES              = {
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

local CurThemeName           = "Default"
local CurFontName            = "GothamBold"
local CurBGId                = CFG.IMG
local CurBGTrans             = 0.8

local function SAVE_CONFIG()
    local data = {
        CustomBG = CurBGId,
        BG_Trans = CurBGTrans,
        Keybind  = tostring(CFG.KEY)
    }
    pcall(function()
        writefile("NYH_Config.json", HttpService:JSONEncode(data))
    end)
end

local function LOAD_CONFIG()
    if isfile("NYH_Config.json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("NYH_Config.json"))
        end)
        if success and data then
            if data.CustomBG then
                CurBGId = data.CustomBG; CFG.IMG = data.CustomBG
            end
            if data.BG_Trans then
                CurBGTrans = data.BG_Trans
            end
            if data.Keybind then
                pcall(function()
                    local k = data.Keybind:gsub("Enum.KeyCode.", "")
                    CFG.KEY = Enum.KeyCode[k]
                end)
            end
        end
    end
end



LOAD_CONFIG()

-- Compara dos Color3 con tolerancia
local function COL_MATCH(a, b, tol)
    tol = tol or 0.06
    return math.abs(a.R - b.R) < tol and math.abs(a.G - b.G) < tol and math.abs(a.B - b.B) < tol
end

local function APPLY_THEME(themeName)
    local t = UI_THEMES[themeName]
    if not t then return end

    CurThemeName = themeName
    SAVE_CONFIG()

    local oldACC  = CFG.COL.ACC
    local oldBG   = CFG.COL.BG
    local oldGRY  = CFG.COL.GRY
    local oldBTN  = CFG.COL.BTN

    CFG.COL.ACC   = t.ACC
    CFG.COL.BG    = t.BG
    CFG.COL.GRY   = t.GRY
    -- Derive BTN color: BG slightly lighter for button contrast
    local r, g, b = t.BG.R, t.BG.G, t.BG.B
    CFG.COL.BTN   = Color3.new(math.min(r + 0.08, 1), math.min(g + 0.08, 1), math.min(b + 0.1, 1))

    local roots   = { game:GetService("CoreGui"), game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") }
    for _, root in ipairs(roots) do
        local scr = root and root:FindFirstChild("CEN_V2")
        if scr then
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
end



-- Aplica una fuente a todos los TextLabel/TextButton/TextBox del UI
local function APPLY_FONT_UI(enumFont)
    local root = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    local scr  = root and root:FindFirstChild("CEN_V2")
    if not scr then return end
    for _, obj in ipairs(scr:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.Font = enumFont
        end
    end
end

local function REG(obj, prop, col)
    table.insert(UI_REGISTERED_ELEMENTS, { obj = obj, prop = prop, col = col })
end

-- [ ESP CFG ]
local ESP_CFG = {
    Enabled    = false,
    MaxDist    = 500,
    Boxes      = { Enabled = false, Color = Color3.new(1, 1, 1), Animated = false },
    Corners    = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Filled     = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0), Alpha = 0.25 },
    Names      = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Health     = { Enabled = false, Bar = false, Text = false, Dynamic = false, Color1 = Color3.fromRGB(0, 255, 0), Color2 = Color3.fromRGB(255, 0, 0) },
    Weapons    = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Dist       = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Chams      = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0), Thermal = false },
    ToolCharms = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0) },
    FontSize   = 12,
    Font       = Enum.Font.GothamBold
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
local PICKER_DATA = { OPEN = false, CALLBACK = nil, COLOR = Color3.new(1, 1, 1), ALPHA = 0 }
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
    SG.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
    SG.Transparency = NumberSequence.new(0, 1)

    local V_GRAD = Instance.new("Frame", SV_HOLDER)
    V_GRAD.Size = UDim2.new(1, 0, 1, 0)
    V_GRAD.BackgroundTransparency = 0
    RND(V_GRAD, 8)
    local VG = Instance.new("UIGradient", V_GRAD)
    VG.Rotation = 90
    VG.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
    VG.Transparency = NumberSequence.new(1, 0)

    local CURSOR = Instance.new("Frame", SV_HOLDER)
    CURSOR.Size = UDim2.new(0, 10, 0, 10)
    CURSOR.AnchorPoint = Vector2.new(0.5, 0.5)
    CURSOR.BackgroundColor3 = Color3.new(1, 1, 1)
    CURSOR.ZIndex = 5
    RND(CURSOR, 10)
    STR(CURSOR, Color3.new(0, 0, 0), 2)

    -- Hue Slider
    local HUE_BAR = Instance.new("Frame", MAIN)
    HUE_BAR.Size = UDim2.new(1, -20, 0, 12)
    HUE_BAR.Position = UDim2.new(0, 10, 0, 170)
    HUE_BAR.Active = true
    RND(HUE_BAR, 6)
    local HG = Instance.new("UIGradient", HUE_BAR)
    HG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })

    local HUE_CURSOR = Instance.new("Frame", HUE_BAR)
    HUE_CURSOR.Size = UDim2.new(0, 4, 1, 4)
    HUE_CURSOR.Position = UDim2.new(0, 0, 0.5, 0)
    HUE_CURSOR.AnchorPoint = Vector2.new(0.5, 0.5)
    HUE_CURSOR.BackgroundColor3 = Color3.new(1, 1, 1)
    RND(HUE_CURSOR, 2)
    STR(HUE_CURSOR, Color3.new(0, 0, 0), 1)

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
    ALP_CURSOR.BackgroundColor3 = Color3.new(1, 1, 1)
    RND(ALP_CURSOR, 2)
    STR(ALP_CURSOR, Color3.new(0, 0, 0), 1)

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
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; cb(i)
            end
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
        _G.CENTRAL_NOTIFS_REF.DisplayOrder = 2147483647
        _G.CENTRAL_NOTIFS_REF.IgnoreGuiInset = true
    end
    local N_GUI = _G.CENTRAL_NOTIFS_REF

    local HOLDER = N_GUI:FindFirstChild("HOLDER")
    if not HOLDER then
        HOLDER = Instance.new("Frame", N_GUI)
        HOLDER.Name = "HOLDER"
        HOLDER.Size = UDim2.new(0, 240, 1, -40)
        HOLDER.Position = UDim2.new(1, -20, 0, 20)
        HOLDER.AnchorPoint = Vector2.new(1, 0)
        HOLDER.BackgroundTransparency = 1

        local LAY = Instance.new("UIListLayout", HOLDER)
        LAY.SortOrder = Enum.SortOrder.LayoutOrder
        LAY.Padding = UDim.new(0, 10)
        LAY.VerticalAlignment = Enum.VerticalAlignment.Top
    end

    -- [ PREMIUM NOTIF FRAME ]
    local FRM = Instance.new("Frame", HOLDER)
    FRM.Size = UDim2.new(1, 0, 0, 52)
    FRM.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    FRM.BackgroundTransparency = 1
    FRM.BorderSizePixel = 0
    FRM.ClipsDescendants = true
    RND(FRM, 8)

    local GRD = Instance.new("UIGradient", FRM)
    GRD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
    })
    GRD.Rotation = 45

    local ST = STR(FRM, CFG.COL.ACC, 1)
    ST.Transparency = 1

    local BG = Instance.new("ImageLabel", FRM)
    BG.Name = "BG"
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.BackgroundTransparency = 1
    BG.Image = CurBGId
    BG.ImageTransparency = 1
    BG.ScaleType = Enum.ScaleType.Crop
    BG.ZIndex = FRM.ZIndex
    RND(BG, 8)

    local _NF = Enum.Font.GothamBold
    local _NM = Enum.Font.Gotham

    local T = Instance.new("TextLabel", FRM)
    T.Text = TITLE
    T.Size = UDim2.new(1, -30, 0, 15)
    T.Position = UDim2.new(0, 12, 0, 6)
    T.BackgroundTransparency = 1
    T.TextColor3 = CFG.COL.ACC
    T.Font = _NF
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.TextTransparency = 1
    T.ZIndex = BG.ZIndex + 1

    local M = Instance.new("TextLabel", FRM)
    M.Text = MSG
    M.Size = UDim2.new(1, -30, 0, 20)
    M.Position = UDim2.new(0, 12, 0, 20)
    M.BackgroundTransparency = 1
    M.TextColor3 = Color3.new(1, 1, 1)
    M.Font = _NM
    M.TextSize = 11
    M.TextWrapped = true
    M.TextXAlignment = Enum.TextXAlignment.Left
    M.TextYAlignment = Enum.TextYAlignment.Top
    M.TextTransparency = 1
    M.ZIndex = BG.ZIndex + 1

    -- Progress Bar
    local BAR_BG = Instance.new("Frame", FRM)
    BAR_BG.Size = UDim2.new(1, -24, 0, 2)
    BAR_BG.Position = UDim2.new(0, 12, 1, -6)
    BAR_BG.BackgroundColor3 = Color3.new(0, 0, 0)
    BAR_BG.BackgroundTransparency = 1
    BAR_BG.BorderSizePixel = 0
    BAR_BG.ZIndex = BG.ZIndex + 1

    local BAR = Instance.new("Frame", BAR_BG)
    BAR.Size = UDim2.new(1, 0, 1, 0)
    BAR.BackgroundColor3 = CFG.COL.ACC
    BAR.BorderSizePixel = 0
    BAR.BackgroundTransparency = 1
    BAR.ZIndex = BG.ZIndex + 2

    FRM.Position = UDim2.new(1.5, 0, 0, 0)
    TWN(FRM, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.1 }, 0.5)
    TWN(BG, { ImageTransparency = math.clamp(CurBGTrans + 0.1, 0.4, 0.95) }, 0.5)
    TWN(ST, { Transparency = 0.7 }, 0.5)
    TWN(T, { TextTransparency = 0 }, 0.5)
    TWN(M, { TextTransparency = 0 }, 0.5)
    TWN(BAR_BG, { BackgroundTransparency = 0.5 }, 0.5)
    TWN(BAR, { BackgroundTransparency = 0 }, 0.5)

    local BT = TS:Create(BAR, TweenInfo.new(TIME or 5, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
    BT:Play()

    task.delay(TIME or 5, function()
        TWN(FRM, { Position = UDim2.new(1.5, 0, 0, 0), BackgroundTransparency = 1 }, 0.5)
        TWN(BG, { ImageTransparency = 1 }, 0.5)
        TWN(T, { TextTransparency = 1 }, 0.5)
        TWN(M, { TextTransparency = 1 }, 0.5)
        TWN(BAR, { BackgroundTransparency = 1 }, 0.5)
        TWN(BAR_BG, { BackgroundTransparency = 1 }, 0.5)
        TWN(ST, { Transparency = 1 }, 0.5)
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

    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    BTN.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)

    local STR_OBJ = STR(BTN, CFG.COL.ACC, 1.2)
    STR_OBJ.Transparency = 0.8
    STR_OBJ.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local GRAD = Instance.new("UIGradient", BTN)
    GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
    })
    GRAD.Rotation = 45
    GRAD.Transparency = NumberSequence.new(0.5)

    BTN.MouseEnter:Connect(function()
        TWN(BTN, { BackgroundTransparency = 0.7, BackgroundColor3 = CFG.COL.ACC }, 0.2)
        TWN(STR_OBJ, { Transparency = 0.5 }, 0.2)
    end)
    BTN.MouseLeave:Connect(function()
        TWN(BTN, { BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG }, 0.2)
        TWN(STR_OBJ, { Transparency = 0.8 }, 0.2)
    end)

    BTN.MouseButton1Click:Connect(function()
        TWN(BTN, { BackgroundTransparency = 0.4, TextSize = 12 }, 0.1)
        task.wait(0.1)
        TWN(BTN, { BackgroundTransparency = 0.7, TextSize = 13 }, 0.1)
        if CB then CB(BTN) end
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

    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)

    local INP_STR = STR(FRM, CFG.COL.ACC, 1.2)
    INP_STR.Transparency = 0.85
    INP_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local INP_GRAD = Instance.new("UIGradient", FRM)
    INP_GRAD.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
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
    STR(FRM, CFG.COL.ACC, 1.2)

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
    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)
    FRM.ClipsDescendants = true
    FRM.ZIndex = 5
    RND(FRM, 8)
    STR(FRM, CFG.COL.ACC, 1.2)

    local prefix = TTL:match("(.-):")
    local initial_val = TTL:match(":%s*(.*)") or TTL

    local BTN = Instance.new("TextButton", FRM)
    BTN.Size = UDim2.new(1, 0, 0, 35)
    BTN.BackgroundTransparency = 1
    BTN.Text = "  " .. (prefix and (prefix .. ": " .. initial_val) or TTL)
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
    SCR.ScrollBarImageTransparency = 1 -- Hide the scrollbar image to remove the blue line
    SCR.ZIndex = 6
    SCR.BorderSizePixel = 0            -- Ensure no border is visible

    local LAY = Instance.new("UIListLayout", SCR)
    LAY.SortOrder = Enum.SortOrder.LayoutOrder

    local OPEN = false
    local LIST = {}

    local function ADD_ITEM(self, text, val)
        local is_red = text:find("^!!")
        local t_norm = is_red and text:gsub("!!", "") or text
        local is_sep = t_norm:find("^—") or t_norm:find("^%-")
        local ITM = Instance.new("TextButton", SCR)
        ITM.Name = is_sep and "Separator" or "DropItem"
        ITM.Size = UDim2.new(1, 0, 0, is_sep and 25 or 30)
        ITM.BackgroundTransparency = 1
        ITM.Text = is_sep and t_norm or "  " .. t_norm
        ITM.TextColor3 = is_red and Color3.fromRGB(230, 40, 40) or (is_sep and CFG.COL.GRY or CFG.COL.TXT)
        ITM.Font = is_sep and Enum.Font.GothamBold or Enum.Font.Gotham
        ITM.TextSize = is_sep and 11 or 13
        ITM.TextXAlignment = is_sep and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        ITM.ZIndex = 7
        ITM.AutoButtonColor = not is_sep

        if not is_sep then
            ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
            ITM.MouseLeave:Connect(function()
                TWN(ITM,
                    { TextColor3 = is_red and Color3.fromRGB(230, 40, 40) or CFG.COL.TXT }, 0.1)
            end)
            ITM.MouseButton1Click:Connect(function()
                BTN.Text = "  " .. (prefix and (prefix .. ": ") or "") .. t_norm
                OPEN = false
                TWN(FRM, { Size = UDim2.new(1, -10, 0, 35) })
                TWN(ICO, { Rotation = 0 })
                if CB then CB(val or t_norm) end
            end)
        end
        SCR.CanvasSize = UDim2.new(0, 0, 0, LAY.AbsoluteContentSize.Y)
        return ITM
    end

    local function RFSH(LST)
        for _, C in pairs(SCR:GetChildren()) do
            if C.Name == "DropItem" then C:Destroy() end
        end
        for _, P in pairs(LST) do
            ADD_ITEM(nil, P)
        end
    end

    BTN.MouseButton1Click:Connect(function()
        OPEN = not OPEN
        if OPEN then
            local items = 0
            for _, c in ipairs(SCR:GetChildren()) do
                if c.Name == "DropItem" then items = items + 1 end
            end
            local h = math.min(items * 30, 150)
            TWN(FRM, { Size = UDim2.new(1, -10, 0, 35 + h) })
            TWN(SCR, { Size = UDim2.new(1, 0, 0, h) })
            TWN(ICO, { Rotation = 180 })
        else
            TWN(FRM, { Size = UDim2.new(1, -10, 0, 35) })
            TWN(ICO, { Rotation = 0 })
        end
    end)

    return { FRM = FRM, ADD = ADD_ITEM, REFRESH = RFSH }
end

local function ADD_TGL(PAG, TXT, DEF, CB)
    local TGL = { VAL = DEF or false }

    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)
    RND(FRM, 8)
    STR(FRM, CFG.COL.ACC, 1.2)

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
        TWN(BTN, { BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
        TWN(IND, { Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
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
    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)

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
        KB_BOX.TextColor3 = Color3.new(1, 1, 1)
        KB_BOX.Font = Enum.Font.GothamBold
        KB_BOX.TextSize = 10
        KB_BOX.TextScaled = true
        Instance.new("UITextSizeConstraint", KB_BOX).MaxTextSize = 10
        KB_BOX.ZIndex = 6
        KB_BOX.AutoButtonColor = false
        RND(KB_BOX, 8)

        local KB_STR = STR(KB_BOX, CFG.COL.ACC, 1.2)
        KB_STR.Transparency = 0.8
        KB_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local KB_GRAD = Instance.new("UIGradient", KB_BOX)
        KB_GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
        })
        KB_GRAD.Rotation = 45
        KB_GRAD.Transparency = NumberSequence.new(0.5)

        KB_BOX.MouseEnter:Connect(function()
            TWN(KB_BOX,
                { BackgroundTransparency = 0.6, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0, 0, 0) },
                0.2)
            TWN(KB_STR, { Transparency = 0.4 }, 0.2)
        end)
        KB_BOX.MouseLeave:Connect(function()
            TWN(KB_BOX,
                { BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG, TextColor3 = Color3.new(1, 1, 1) },
                0.2)
            TWN(KB_STR, { Transparency = 0.8 }, 0.2)
        end)

        KB_BOX.MouseButton1Click:Connect(function()
            if KB_LISTENING then return end
            KB_LISTENING = true
            KB_BOX.Text = "..."
            KB_BOX.TextColor3 = CFG.COL.YEL
            TWN(KB_BOX, { BackgroundColor3 = Color3.fromRGB(50, 45, 20), BackgroundTransparency = 0.5, TextSize = 8 },
                0.1)

            local conn
            conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                KB_LISTENING = false

                if inp.KeyCode == Enum.KeyCode.Escape then
                    TGL.KB = nil
                    KB_BOX.Text = "—"
                    KB_BOX.TextColor3 = Color3.new(1, 1, 1)
                    TWN(KB_BOX, { BackgroundColor3 = CFG.COL.BTN }, 0.1)
                    return
                end

                TGL.KB = inp.KeyCode
                local name = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")
                KB_BOX.Text = name
                KB_BOX.TextColor3 = Color3.new(1, 1, 1)
                TWN(KB_BOX, { BackgroundColor3 = CFG.COL.BG, BackgroundTransparency = 0.82, TextSize = 10 }, 0.1)
            end)
        end)

        local bind_conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
            if gpe or KB_LISTENING or TGL.KB == nil then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == TGL.KB then
                BTN.BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY -- toggle state
                TGL.VAL = not TGL.VAL
                TWN(BTN, { BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
                TWN(IND, { Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
                if CB then CB(TGL.VAL, TGL.KB) end
            end
        end)
        table.insert(_G.CEN_BINDS, bind_conn)
    end

    local function UPD(dont_callback)
        TWN(BTN, { BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
        TWN(IND, { Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
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
    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)
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
    STR(FRM, CFG.COL.ACC, 1.2)

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
    STR(BTN, Color3.new(1, 1, 1), 1).Transparency = 0.5

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
    E.OUT.Color = Color3.new(1, 1, 1)
    E.OUT.Thickness = 1.5

    local function MK_C(parent)
        local f = Instance.new("Frame", parent)
        f.BorderSizePixel = 0
        STR(f, Color3.new(0, 0, 0), 1).Transparency = 0.5
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
    E.NAME.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.NAME, ESP_CFG.FontSize)
    E.NAME.TextStrokeTransparency = 0.5
    E.NAME.TextYAlignment = Enum.TextYAlignment.Bottom

    E.DIST.Parent = E.FRM
    E.DIST.BackgroundTransparency = 1
    E.DIST.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.DIST, ESP_CFG.FontSize - 1)
    E.DIST.TextStrokeTransparency = 0.5
    E.DIST.TextYAlignment = Enum.TextYAlignment.Top

    E.WEAP.Parent = E.FRM
    E.WEAP.BackgroundTransparency = 1
    E.WEAP.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.WEAP, ESP_CFG.FontSize - 1)
    E.WEAP.TextStrokeTransparency = 0.5
    E.WEAP.TextYAlignment = Enum.TextYAlignment.Top

    E.BAR_BG.Parent = E.FRM
    E.BAR_BG.BackgroundColor3 = Color3.new(0, 0, 0)
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
    E.HEALTH_TXT.TextColor3 = Color3.new(1, 1, 1)
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
            -- Buscar el char tanto en workspace (juego custom) como en p.Character (estándar)
            local C = workspace:FindFirstChild(p.Name) or p.Character

            -- Dynamic cleanup if character is missing
            if not C or not C:FindFirstChild("HumanoidRootPart") then
                if E.CHAM then
                    E.CHAM:Destroy(); E.CHAM = nil
                end
                E.FRM.Visible = false
                return
            end

            local H         = C:FindFirstChild("HumanoidRootPart")
            local HUM       = C:FindFirstChildOfClass("Humanoid")

            -- Obtener salud: primero el NumberValue custom, luego Humanoid.Health
            local healthVal = C:FindFirstChild("Health")
            local curHP, maxHP
            if healthVal and healthVal:IsA("NumberValue") then
                curHP = healthVal.Value
                maxHP = 100 -- valor por defecto para el juego custom
                -- Intentar leer maxHealth del Humanoid si existe
                if HUM then maxHP = HUM.MaxHealth > 0 and HUM.MaxHealth or 100 end
            elseif HUM then
                curHP = HUM.Health
                maxHP = HUM.MaxHealth > 0 and HUM.MaxHealth or 100
            else
                curHP = 0
                maxHP = 100
            end
            local isAlive = curHP > 0

            -- Chams Logic (Highly Optimized Caching)
            if C and isAlive then
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
                if E.CHAM then
                    E.CHAM:Destroy(); E.CHAM = nil
                end
            end

            -- 2D Visuals Logic
            if ESP_CFG.Enabled and H and isAlive then
                local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(H.Position)
                local dist = (workspace.CurrentCamera.CFrame.Position - H.Position).Magnitude

                if vis and dist <= ESP_CFG.MaxDist then
                    E.FRM.Visible = true

                    local s_y = (H.Size.Y * 2 * workspace.CurrentCamera.ViewportSize.Y) / (pos.Z * 2)
                    local s_x = s_y * 0.75
                    local x, y = pos.X - s_x / 2, pos.Y - s_y / 2

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
                        E.CORNERS[3].Position = UDim2.new(0, x + s_x - len, 0, y); E.CORNERS[3].Size = UDim2.new(0, len,
                            0, thk)
                        E.CORNERS[4].Position = UDim2.new(0, x + s_x - thk, 0, y); E.CORNERS[4].Size = UDim2.new(0, thk,
                            0, len)
                        -- Bottom Left
                        E.CORNERS[5].Position = UDim2.new(0, x, 0, y + s_y - thk); E.CORNERS[5].Size = UDim2.new(0, len,
                            0, thk)
                        E.CORNERS[6].Position = UDim2.new(0, x, 0, y + s_y - len); E.CORNERS[6].Size = UDim2.new(0, thk,
                            0, len)
                        -- Bottom Right
                        E.CORNERS[7].Position = UDim2.new(0, x + s_x - len, 0, y + s_y - thk); E.CORNERS[7].Size = UDim2
                            .new(0, len, 0, thk)
                        E.CORNERS[8].Position = UDim2.new(0, x + s_x - thk, 0, y + s_y - len); E.CORNERS[8].Size = UDim2
                            .new(0, thk, 0, len)
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

                    -- Health (usando curHP/maxHP que soportan tanto custom como estándar)
                    local hp_per = math.clamp(curHP / math.max(maxHP, 1), 0, 1)
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
                    E.HEALTH_TXT.Position = UDim2.new(0, x - 40, 0, y + s_y * (1 - hp_per) - 10)
                    E.HEALTH_TXT.Size = UDim2.new(0, 30, 0, 12)
                    E.HEALTH_TXT.Text = math.floor(curHP)
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
                    E.DIST.Position = UDim2.new(0, x - 50, 0,
                        y + s_y + (ESP_CFG.Weapons.Enabled and ESP_CFG.FontSize + 2 or 2))
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
    local Players            = game:GetService("Players")
    local RunService         = game:GetService("RunService")
    local LocalPlayer        = Players.LocalPlayer

    --====================================================
    -- SETTINGS
    --====================================================
    local TRANSPARENCY_MIN   = 0.18
    local TRANSPARENCY_MAX   = 0.42
    local ANIM_SPEED         = 2.4
    local USE_HIGHLIGHT      = true
    local ONLY_WHEN_EQUIPPED = true
    local ONLY_HANDLE        = false

    --====================================================
    -- STATE
    --====================================================
    local trackedTools       = {}
    local partCache          = {}
    local highlightCache     = {}
    local isEnabledCache     = false

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


-- [ SILENT AIM / AIMLOCK — COMPATIBLE CON PERSONAJES CUSTOM ]
-- Este juego guarda los chars en workspace[p.Name] en vez de p.Character normal.
-- También usa un NumberValue "Health" separado en lugar de Humanoid.Health.
local Mouse  = LPLR:GetMouse()
local Camera = workspace.CurrentCamera

local function GET_CHAR(p)
    local wsChar = workspace:FindFirstChild(p.Name)
    if wsChar and wsChar:FindFirstChild("HumanoidRootPart") then
        return wsChar
    end
    return p.Character
end

local function IS_ALIVE(char)
    if not char then return false end
    local healthVal = char:FindFirstChild("Health")
    if healthVal and healthVal:IsA("NumberValue") then
        return healthVal.Value > 0
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health > 0
    end
    return false
end

local function GET_TARGET_PART(char, partName)
    if not char then return nil end
    local part = char:FindFirstChild(partName or "HumanoidRootPart")
    if part and part:IsA("BasePart") then return part end
    local fallbacks = { "HumanoidRootPart", "Head", "UpperTorso", "LowerTorso" }
    for _, name in ipairs(fallbacks) do
        local fb = char:FindFirstChild(name)
        if fb and fb:IsA("BasePart") then return fb end
    end
    return nil
end


-- [ SILENT AIM MODULE HOOKING — DISABLED FOR COMPATIBILITY ]
--[[
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
--]]

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
        TWN(B, { BackgroundTransparency = 0.6, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0, 0, 0) }, 0.2)
        TWN(B_STR, { Transparency = 0.4 }, 0.2)
    end)
    B.MouseLeave:Connect(function()
        TWN(B, { BackgroundTransparency = 0.8, BackgroundColor3 = CFG.COL.BG, TextColor3 = CFG.COL.ACC }, 0.2)
        TWN(B_STR, { Transparency = 0.7 }, 0.2)
    end)

    B.MouseButton1Click:Connect(function()
        TWN(B, { TextSize = 10 }, 0.1)
        task.wait(0.1)
        TWN(B, { TextSize = 11 }, 0.1)
        if CB then CB() end
    end)

    return CRD
end

local function ADD_ESP_ROW(PAG, TXT, DEF_TGL, CB_TGL, CLRS)
    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 30)
    FRM.BackgroundTransparency = 1
    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)

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
            TWN(BTN, { BackgroundColor3 = val and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
            TWN(IND, { Position = val and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) }, 0.2)
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
SCR.DisplayOrder = 1000 -- Functional level, crosshair will be higher
SCR.IgnoreGuiInset = true
-- SCR parent moved to bottom of BUILD_NYH_UI for performance


-- Aggressively raise ANY other GUI found in PlayerGui
local PG = LPLR:WaitForChild("PlayerGui", 5) or LPLR.PlayerGui
local function RAISE_HUD(gui)
    if not gui:IsA("ScreenGui") or gui == _G.CENTRAL_GUI or gui == _G.CENTRAL_NOTIFS_REF then return end
    local n = gui.Name:lower()

    if n == "cen_v2" or n:find("esp_holder") or n:find("picker") or n:find("notif") or n:find("espholder") then return end

    if n == "gungui" or n:find("crosshair") or n:find("reticle") then
        gui.DisplayOrder = 2147483647
    elseif gui.DisplayOrder < 100 then
        gui.DisplayOrder = 100
    end
end

for _, g in ipairs(PG:GetChildren()) do RAISE_HUD(g) end
PG.ChildAdded:Connect(function(g)
    task.wait()
    RAISE_HUD(g)
end)

-- Reduced check frequency (every 10s) just in case some GUIs ignore ChildAdded
task.spawn(function()
    while task.wait(10) do
        for _, g in ipairs(PG:GetChildren()) do RAISE_HUD(g) end
    end
end)

local function BUILD_NYH_UI()
    -- Progressive Loading: Show UI foundation immediately
    SCR.Parent = PG

    local SM_REF = game:GetService("ReplicatedStorage"):WaitForChild("StoreMenus", 10)
    if not SM_REF then
        warn("[NYH] StoreMenus not found, using fallback tables")
        SM_REF = {
            ["Ling Enterprises"] = { Ammo = {}, Misc = {}, Pistols = {}, SMGs = {} },
            ["Ling Heavy"] = { Rifles = {} },
            Deli = { Consumables = {}, Misc = {} },
            ["Issac's Stock"] = { Attachments = { Beam = {}, Switch = {} }, Misc = {} }
        }
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
                TWN(PILL, { BackgroundColor3 = CFG.COL.ACC }, T)
                TWN(KNOB, { Position = UDim2.new(0, 23, 0.5, -9) }, T)
            else
                TWN(PILL, { BackgroundColor3 = CFG.COL.GRY }, T)
                TWN(KNOB, { Position = UDim2.new(0, 3, 0.5, -9) }, T)
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

    -- [FARM SERVICES REMOVED]

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

    -- [ UI FOOTER ]
    local FOOTER = Instance.new("Frame", MAIN)
    FOOTER.Name = "FOOTER"
    FOOTER.Size = UDim2.new(1, -20, 0, 25)
    FOOTER.Position = UDim2.new(0, 10, 1, -30)
    FOOTER.BackgroundTransparency = 1
    FOOTER.ZIndex = 50

    local F_LEFT = Instance.new("Frame", FOOTER)
    F_LEFT.Size = UDim2.new(0.5, 0, 1, 0)
    F_LEFT.BackgroundTransparency = 1
    local FL_LAY = Instance.new("UIListLayout", F_LEFT)
    FL_LAY.FillDirection = Enum.FillDirection.Horizontal
    FL_LAY.VerticalAlignment = Enum.VerticalAlignment.Center
    FL_LAY.Padding = UDim.new(0, 8)

    local DOT = Instance.new("Frame", F_LEFT)
    DOT.Size = UDim2.new(0, 8, 0, 8)
    DOT.BackgroundColor3 = (useFireMethod and not isUnsupported) and Color3.fromRGB(0, 255, 120) or
        Color3.fromRGB(255, 120, 0)
    RND(DOT, 10)
    STR(DOT, DOT.BackgroundColor3, 1).Transparency = 0.5

    local E_LBL = Instance.new("TextLabel", F_LEFT)
    E_LBL.Size = UDim2.new(1, -20, 1, 0)
    E_LBL.BackgroundTransparency = 1
    E_LBL.Text = executor
    E_LBL.TextColor3 = CFG.COL.GRY
    E_LBL.Font = Enum.Font.GothamMedium
    E_LBL.TextSize = 11
    E_LBL.TextXAlignment = Enum.TextXAlignment.Left

    local F_BRAND = Instance.new("TextLabel", FOOTER)
    F_BRAND.Size = UDim2.new(1, 0, 1, 0)
    F_BRAND.Position = UDim2.new(0, 0, 0, 0)
    F_BRAND.BackgroundTransparency = 1
    F_BRAND.Text = "fight for ny | WH01AM"
    F_BRAND.TextColor3 = Color3.fromRGB(80, 80, 95)
    F_BRAND.Font = Enum.Font.GothamMedium
    F_BRAND.TextSize = 10
    F_BRAND.TextXAlignment = Enum.TextXAlignment.Center

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
    DRG.ZIndex = 0     -- Keep behind content
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
    BG.Name = "BG"
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.Image = CFG.IMG
    BG.ScaleType = Enum.ScaleType.Crop
    BG.ImageTransparency = CurBGTrans
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

        BTN.MouseEnter:Connect(function() TWN(OVR, { BackgroundTransparency = 0.8 }, 0.2) end)
        BTN.MouseLeave:Connect(function() TWN(OVR, { BackgroundTransparency = 1 }, 0.2) end)

        return BTN
    end

    local B_CLS = MK_BTN(CFG.COL.RED, UDim2.new(0, 15, 0.5, -7))
    local B_MIN = MK_BTN(CFG.COL.YEL, UDim2.new(0, 35, 0.5, -7))

    do
        local m = Instance.new("TextLabel", BAR)
        m.Name = "MIN_TITLE"
        m.Size = UDim2.new(1, -60, 1, 0)
        m.Position = UDim2.new(0, 60, 0, 0)
        m.BackgroundTransparency = 1
        m.Text = "  Fight for NY 💎"
        m.TextColor3 = CFG.COL.TXT
        m.Font = Enum.Font.GothamBold
        m.TextSize = 13
        m.TextXAlignment = Enum.TextXAlignment.Left
        m.TextTransparency = 1
    end

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
        if _G.EXE.FARM_THREAD ~= nil then
            pcall(task.cancel, _G.EXE.FARM_THREAD)
            _G.EXE.FARM_THREAD = nil
        end

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
                    local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("VehicleSeat") or
                        veh:FindFirstChildWhichIsA("BasePart")
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
        MIN_DEB    = true

        IS_MIN     = not IS_MIN
        local TCON = MAIN:FindFirstChild("TABS")
        local PCON = MAIN:FindFirstChild("PGS")
        local RSZ  = MAIN:FindFirstChild("RSZ_HANDLE")
        local FOOT = MAIN:FindFirstChild("FOOTER")

        if IS_MIN then
            OLD_SZ = MAIN.Size
            if TCON then TCON.Visible = false end
            if PCON then PCON.Visible = false end
            if RSZ then RSZ.Visible = false end
            if FOOT then FOOT.Visible = false end

            -- Hide Stop Modal if it exists
            local m = MAIN:FindFirstChild("StopModal")
            local b = MAIN:FindFirstChild("StopBackdrop")
            if m then m.Visible = false end
            if b then b.Visible = false end

            TWN(MAIN, { Size = UDim2.new(0, 220, 0, 40), BackgroundTransparency = 0.2 })
            task.wait(0.35)
            local mTitle = BAR:FindFirstChild("MIN_TITLE")
            if mTitle then
                mTitle.TextTransparency = 0
                mTitle.MaxVisibleGraphemes = 0
                task.spawn(function()
                    for i = 1, #mTitle.Text do
                        if not IS_MIN then break end
                        mTitle.MaxVisibleGraphemes = i
                        task.wait(0.04)
                    end
                end)
            end
        else
            local mTitle = BAR:FindFirstChild("MIN_TITLE")
            if mTitle then
                mTitle.TextTransparency = 1
            end
            TWN(MAIN, { Size = OLD_SZ, BackgroundTransparency = 0.1 })
            task.wait(0.35)
            if TCON then TCON.Visible = true end
            if PCON then PCON.Visible = true end
            if RSZ then RSZ.Visible = true end
            if FOOT then FOOT.Visible = true end
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

        local TSC                  = Instance.new("UITextSizeConstraint", BTN)
        TSC.MaxTextSize            = 12
        TSC.MinTextSize            = 8

        local PAG                  = Instance.new("ScrollingFrame", PCON)
        PAG.Size                   = UDim2.new(1, 0, 1, 0)
        PAG.BackgroundTransparency = 1
        PAG.BorderSizePixel        = 0
        PAG.Visible                = false
        PAG.ScrollBarThickness     = 2
        PAG.ScrollBarImageColor3   = CFG.COL.ACC
        PAG.AutomaticCanvasSize    = Enum.AutomaticSize.Y

        local LST                  = Instance.new("UIListLayout", PAG)
        LST.Padding                = UDim.new(0, 8)
        LST.HorizontalAlignment    = Enum.HorizontalAlignment.Center
        LST.SortOrder              = Enum.SortOrder.LayoutOrder

        local PAD                  = Instance.new("UIPadding", PAG)
        PAD.PaddingTop             = UDim.new(0, 5)
        PAD.PaddingLeft            = UDim.new(0, 5)
        PAD.PaddingRight           = UDim.new(0, 5)
        PAD.PaddingBottom          = UDim.new(0, 5)

        BTN.MouseButton1Click:Connect(function()
            if CUR_BTN == BTN then return end

            if CUR_BTN then
                TWN(CUR_BTN, { TextColor3 = CFG.COL.GRY, BackgroundTransparency = 1 })
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
            TWN(PAG, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)
        end)

        return PAG, BTN
    end

    -- [ TABS ]
    local P_HOM, B_HOM = MK_TAB("HOME")
    local P_FRM, B_FRM = MK_TAB("FARM")
    local P_VIS, B_VIS = MK_TAB("VISUAL")
    local P_MSC, B_MSC = MK_TAB("MISC")
    local P_SET, B_SET = MK_TAB("CONFIG")
    -- ============================================================
    -- ============================================================
    local function MK_CARD(parent, title, icon)
        local C = Instance.new("Frame", parent)
        C.Size = UDim2.new(1, 0, 0, 0)
        C.AutomaticSize = Enum.AutomaticSize.Y
        C.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        C.BackgroundTransparency = 0.3
        RND(C, 12)
        STR(C, CFG.COL.ACC, 1).Transparency = 0.8
        local PL = Instance.new("UIListLayout", C)
        PL.Padding = UDim.new(0, 5)
        PL.SortOrder = Enum.SortOrder.LayoutOrder
        C:SetAttribute("NextOrder", 0)
        local PAD = Instance.new("UIPadding", C)
        PAD.PaddingTop, PAD.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
        PAD.PaddingLeft, PAD.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)

        local H = Instance.new("Frame", C)
        H.Size = UDim2.new(1, 0, 0, 35)
        H.BackgroundTransparency = 1
        local HI = Instance.new("ImageLabel", H)
        HI.Size = UDim2.new(0, 28, 0, 28)
        HI.Position = UDim2.new(0, 0, 0.5, -14)
        HI.BackgroundTransparency = 1
        HI.Image = icon or "rbxassetid://10747373176"
        HI.ImageColor3 = CFG.COL.ACC
        local HT = Instance.new("TextLabel", H)
        HT.Size = UDim2.new(1, -34, 1, 0)
        HT.Position = UDim2.new(0, 34, 0, 0)
        HT.BackgroundTransparency = 1
        HT.Text = title
        HT.TextColor3 = Color3.new(1, 1, 1)
        HT.Font = Enum.Font.GothamBold
        HT.TextSize = 16
        HT.TextXAlignment = Enum.TextXAlignment.Left

        return C
    end

    local function SETUP_TELEPORTS()
        local TL, TR = ADD_SPLIT(P_HOM)
        TL.Parent.Size = UDim2.new(1, -10, 1, -10)
        TL.Parent.Position = UDim2.new(0, 5, 0, 5)

        local LL = Instance.new("UIListLayout", TL)
        LL.Padding = UDim.new(0, 10)
        LL.SortOrder = Enum.SortOrder.LayoutOrder

        local RL = Instance.new("UIListLayout", TR)
        RL.Padding = UDim.new(0, 10)
        RL.SortOrder = Enum.SortOrder.LayoutOrder

        local C_TP = MK_CARD(TL, "Teleportation", "rbxassetid://10734950309")

        local T_LOCS = {
            ["👕Clothes Store"] = Vector3.new(230.20, 175.19, 901.51),
            ["🧪Lab"] = Vector3.new(316.86, 176.42, 1263.51),
            ["🚗Car Dealer"] = Vector3.new(-615.37, 176.52, 1057.21),
            ["🏦Bank"] = Vector3.new(-87.27, 176.54, 1065.10),
            ["🏢Penthouse"] = Vector3.new(-224.03, 176.55, 1092.41),
            ["🍬Candy"] = Vector3.new(-1274.97, 124.38, -192.58),
            ["🌷Personal Grow"] = Vector3.new(-899.27, 107.23, -538.66),
            ["🖋️Tattoos"] = Vector3.new(216.84, 157.97, -350.63),
            ["🍗Chicken"] = Vector3.new(620.98, 157.96, -127.97),
            ["🧼Laundromat"] = Vector3.new(355.27, 176.52, 521.20),
            ["🌱Plants"] = Vector3.new(20.19, 176.34, 807.75),
            ["🔫Guns"] = Vector3.new(-275.04, 166.19, 657.18),
            ["💇‍♂️Chop Shop"] = Vector3.new(-663.33, 176.52, 612.57),
            ["💳Cards"] = Vector3.new(-237.66, 164.88, -119.46),
            ["💎Jewelry"] = Vector3.new(13.50, 157.94, -120.88),
            ["🏪Store"] = Vector3.new(118.07, 176.58, 170.14),
            ["📦Box job"] = Vector3.new(141.91, 175.88, 193.58)
        }

        local L_LIST = {}
        for k in pairs(T_LOCS) do table.insert(L_LIST, k) end
        table.sort(L_LIST)

        local D_LOC = ADD_DRP(C_TP, "Select Location", function(v)
            local pos = T_LOCS[v]
            if pos and LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") then
                LPLR.Character.HumanoidRootPart.CFrame = CFrame.new(pos) * CFrame.new(0, 3, 0)
                NOTIFY("Teleport", "Arrived at " .. v, 2)
            end
        end)
        D_LOC.REFRESH(L_LIST)

        local D_PLR = ADD_DRP(C_TP, "Teleport to Player", function(v)
            local target = game:GetService("Players"):FindFirstChild(v)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LPLR.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                NOTIFY("Teleport", "Teleported to " .. v, 2)
            else
                NOTIFY("Teleport", "Player " .. v .. " not found or dead!", 3)
            end
        end)

        local function UPD_PLR_LIST()
            local p_list = {}
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= LPLR then
                    table.insert(p_list, p.Name)
                end
            end
            table.sort(p_list)
            D_PLR.REFRESH(p_list)
        end

        game:GetService("Players").PlayerAdded:Connect(UPD_PLR_LIST)
        game:GetService("Players").PlayerRemoving:Connect(UPD_PLR_LIST)
        UPD_PLR_LIST()

        -- [ STORE ITEMS CARD ]
        local C_STORE = MK_CARD(TL, "Store items", "rbxassetid://99896558829728")

        local STORE_ITEMS = {
            -- Ammo
            ["Light Ammo"] = SM_REF["Ling Enterprises"].Ammo
                ["Light Ammo (30 Rounds)"],
            ["Medium Ammo"] = SM_REF["Ling Enterprises"].Ammo
                ["Medium Ammo (30 Rounds)"],
            ["Heavy Ammo"] = SM_REF["Ling Enterprises"].Ammo
                ["Heavy Ammo (30 Rounds)"],
            -- Deli
            ["Cola"] = SM_REF.Deli.Consumables.Cola,
            ["Big Gulp"] = SM_REF.Deli.Consumables["Big Gulp"],
            ["Gloves"] = SM_REF.Deli.Misc.Gloves,
            ["Mask"] = SM_REF.Deli.Misc.Mask,
            ["Vial"] = SM_REF.Deli.Misc.Vial,
            ["Wound Spray"] = SM_REF.Deli.Misc["Wound Spray"],
            ["Plant Juice"] = SM_REF.Deli.Misc["Plant Juice"],
            ["+25 Armor"] = SM_REF["Ling Enterprises"].Misc["+25 Armor"],
            ["Seed"] = SM_REF["Ling Enterprises"].Misc.Seed
        }

        local SelectedItem = nil
        local SelectedQty = 1

        local D_ITEM = ADD_DRP(C_STORE, "Choose Item", function(v)
            SelectedItem = v
        end)
        local i_list = {
            "Light Ammo", "Medium Ammo", "Heavy Ammo",
            "— DELI ITEMS —",
            "Cola", "Big Gulp", "Gloves", "Mask", "Vial", "Wound Spray", "Plant Juice", "+25 Armor", "Seed"
        }
        D_ITEM.REFRESH(i_list)

        local D_QTY = ADD_DRP(C_STORE, "Qty: 1", function(v)
            SelectedQty = tonumber(v)
        end)
        local q_list = {}
        for i = 1, 20 do table.insert(q_list, tostring(i)) end
        D_QTY.REFRESH(q_list)

        ADD_BTN(C_STORE, "Purchase", function()
            if not SelectedItem then return NOTIFY("Error", "Select an item first!", 3) end
            local item = STORE_ITEMS[SelectedItem]
            if not item then return end

            local remote = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
            NOTIFY("Store", "Purchasing " .. SelectedQty .. "x " .. SelectedItem .. "...", 3)

            task.spawn(function()
                for i = 1, SelectedQty do
                    remote:InvokeServer(item)
                    task.wait(0.2)
                end
                NOTIFY("Store", "Purchase complete!", 3)
            end)
        end)

        -- [ GUNS CARD ]
        local C_GUNS = MK_CARD(TR, "Guns", "rbxassetid://140547169969789")

        local GUNS_DATA = {
            -- Free (Ling Enterprises)
            ["Deagle"] = SM_REF["Ling Enterprises"].Pistols.Deagle,
            ["GX4"] = SM_REF["Ling Enterprises"].Pistols.GX4,
            ["Glock 19"] = SM_REF["Ling Enterprises"].Pistols["Glock 19"],
            ["Glock 19 Ext"] = SM_REF["Ling Enterprises"].Pistols
                ["Glock 19 Ext"],
            ["Glock 20"] = SM_REF["Ling Enterprises"].Pistols["Glock 20"],
            ["Glock 20 Frostbite"] = SM_REF["Ling Enterprises"].Pistols
                ["Glock 20 Frostbite"],
            ["Glock 20 Hellcat"] = SM_REF["Ling Enterprises"].Pistols
                ["Glock 20 Hellcat"],
            ["Glock 20 Vector"] = SM_REF["Ling Enterprises"].Pistols
                ["Glock 20 Vector"],
            ["Glock 26"] = SM_REF["Ling Enterprises"].Pistols["Glock 26"],
            ["Glock 26 Drum"] = SM_REF["Ling Enterprises"].Pistols
                ["Glock 26 Drum"],
            ["Golden Eagle"] = SM_REF["Ling Enterprises"].Pistols
                ["Golden Eagle"],
            ["Hellcat Blood Trigger"] = SM_REF["Ling Enterprises"].Pistols
                ["Hellcat Blood Trigger"],
            ["Issac's Glock 19"] = SM_REF["Ling Enterprises"].Pistols
                ["Issac's Glock 19"],
            ["M1911"] = SM_REF["Ling Enterprises"].Pistols.M1911,
            ["M9"] = SM_REF["Ling Enterprises"].Pistols.M9,
            ["MPA30DMG"] = SM_REF["Ling Enterprises"].Pistols.MPA30DMG,
            ["P2000"] = SM_REF["Ling Enterprises"].Pistols.P2000,
            ["PPK"] = SM_REF["Ling Enterprises"].Pistols.PPK,
            ["Px4 Compact"] = SM_REF["Ling Enterprises"].Pistols["Px4 Compact"],
            ["Zombie Glock"] = SM_REF["Ling Enterprises"].Pistols
                ["Zombie Glock"],
            ["Bloodsport Vector"] = SM_REF["Ling Enterprises"].SMGs
                ["Bloodsport Vector"],
            ["Issac's MAC-10"] = SM_REF["Ling Enterprises"].SMGs
                ["Issac's MAC-10"],
            ["KRISS Vector"] = SM_REF["Ling Enterprises"].SMGs["KRISS Vector"],
            ["MAC-10"] = SM_REF["Ling Enterprises"].SMGs["MAC-10"],
            ["MAC-11"] = SM_REF["Ling Enterprises"].SMGs["MAC-11"],
            ["MP7A1"] = SM_REF["Ling Enterprises"].SMGs.MP7A1,
            ["MP9"] = SM_REF["Ling Enterprises"].SMGs.MP9,
            ["Micro Uzi"] = SM_REF["Ling Enterprises"].SMGs["Micro Uzi"],
            ["Skorpion"] = SM_REF["Ling Enterprises"].SMGs.Skorpion,
            ["TEC-9"] = SM_REF["Ling Enterprises"].SMGs["TEC-9"],

            -- Game Pass (Ling Heavy)
            ["AR-15 Pistol"] = SM_REF["Ling Heavy"].Rifles["AR-15 Pistol"],
            ["AR-15 Snowfall"] = SM_REF["Ling Heavy"].Rifles["AR-15 Snowfall"],
            ["Banana Draco"] = SM_REF["Ling Heavy"].Rifles["Banana Draco"],
            ["Banshee"] = SM_REF["Ling Heavy"].Rifles.Banshee,
            ["Honey Badger"] = SM_REF["Ling Heavy"].Rifles["Honey Badger"],
            ["Lil Jeff's Draco"] = SM_REF["Ling Heavy"].Rifles
                ["Lil Jeff's Draco"],
            ["Micro ARP"] = SM_REF["Ling Heavy"].Rifles["Micro ARP"],
            ["Micro Draco"] = SM_REF["Ling Heavy"].Rifles["Micro Draco"],
            ["Redwood Draco"] = SM_REF["Ling Heavy"].Rifles["Redwood Draco"],
            ["Skeleton ARP"] = SM_REF["Ling Heavy"].Rifles["Skeleton ARP"],
            ["Storm ARP"] = SM_REF["Ling Heavy"].Rifles["Storm ARP"],
        }

        local ATTACH_DATA = {
            ["Beam (Red)"] = SM_REF["Issac's Stock"].Attachments.Beam
                ["Beam (Red)"],
            ["Beam (Blue)"] = SM_REF["Issac's Stock"].Attachments.Beam
                ["Beam (Blue)"],
            ["Beam (Gang)"] = SM_REF["Issac's Stock"].Attachments.Beam
                ["Beam (Gang)"],
            ["Beam (Green)"] = SM_REF["Issac's Stock"].Attachments.Beam
                ["Beam (Green)"],
            ["Beam (Purple)"] = SM_REF["Issac's Stock"].Attachments.Beam
                ["Beam (Purple)"],
            ["Beam (Yellow)"] = SM_REF["Issac's Stock"].Attachments.Beam
                ["Beam (Yellow)"],
            ["Binary Trigger"] = SM_REF["Issac's Stock"].Attachments
                ["Binary Trigger"],
            ["Flash Hider"] = SM_REF["Issac's Stock"].Attachments
                ["Flash Hider"],
            ["Suppressor"] = SM_REF["Issac's Stock"].Attachments.Suppressor,
            ["Swift Link"] = SM_REF["Issac's Stock"].Attachments["Swift Link"],
            ["Switch (Blue)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Blue)"],
            ["Switch (Default)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Default)"],
            ["Switch (Gang)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Gang)"],
            ["Switch (Green)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Green)"],
            ["Switch (Purple)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Purple)"],
            ["Switch (Red)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Red)"],
            ["Switch (Yellow)"] = SM_REF["Issac's Stock"].Attachments.Switch
                ["Switch (Yellow)"],
        }

        local g_list = {
            "Deagle", "GX4", "Glock 19", "Glock 19 Ext", "Glock 20", "Glock 20 Frostbite", "Glock 20 Hellcat",
            "Glock 20 Vector",
            "Glock 26", "Glock 26 Drum", "Golden Eagle", "Hellcat Blood Trigger", "Issac's Glock 19", "M1911", "M9",
            "MPA30DMG", "P2000", "PPK", "Px4 Compact", "Zombie Glock", "Bloodsport Vector", "Issac's MAC-10",
            "KRISS Vector",
            "MAC-10", "MAC-11", "MP7A1", "MP9", "Micro Uzi", "Skorpion", "TEC-9",
            "!!— GAME PASS —",
            "!!AR-15 Pistol", "!!AR-15 Snowfall", "!!Banana Draco", "!!Banshee", "!!Honey Badger", "!!Lil Jeff's Draco",
            "!!Micro ARP", "!!Micro Draco", "!!Redwood Draco", "!!Skeleton ARP", "!!Storm ARP"
        }

        local a_list = {}
        for k in pairs(ATTACH_DATA) do table.insert(a_list, k) end
        table.sort(a_list)

        local D_GUN = ADD_DRP(C_GUNS, "Select Gun", function(v)
            local item = GUNS_DATA[v]
            if item then
                NOTIFY("Guns", "Purchasing " .. v .. "...", 3)
                game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase:InvokeServer(item)
                NOTIFY("Guns", v .. " purchased!", 2)
            end
        end)
        D_GUN.REFRESH(g_list)

        local D_ATTACH = ADD_DRP(C_GUNS, "Select Attachment", function(v)
            local item = ATTACH_DATA[v]
            if item then
                NOTIFY("Attachments", "Purchasing " .. v .. "...", 3)
                game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase:InvokeServer(item)
                NOTIFY("Attachments", v .. " purchased!", 2)
            end
        end)
        D_ATTACH.REFRESH(a_list)

        -- [ BED FARM LOGIC ]
        local BedToggled = false
        local BedStopping = false
        local soundCache = {} -- [Sound] = originalVolume
        local initialCF = nil
        local farmStartTime = 0
        local minFarmDuration = 17
        local repLabel = nil
        local levelUpText = nil
        local totalGained = 0
        local repAtStart = 0
        local repConn = nil
        local lastRepValue = 0
        local levelUpDetected = false

        -- Stats Reference
        local stats = game:GetService("ReplicatedStorage"):WaitForChild("PlayerData"):WaitForChild(LPLR.Name)
            :WaitForChild("Statistics")
        local repValue = stats:WaitForChild("Reputation")

        local function muteSounds(mute)
            local SS = game:GetService("SoundService")
            local PG = LPLR:WaitForChild("PlayerGui")

            -- Combine all relevant sound parents
            local parents = { workspace, SS, PG }

            if mute then
                for _, parent in ipairs(parents) do
                    for _, s in pairs(parent:GetDescendants()) do
                        if s:IsA("Sound") and s.Volume > 0 then
                            if not soundCache[s] then
                                soundCache[s] = s.Volume
                            end
                            s.Volume = 0
                        end
                    end
                end
            else
                for s, vol in pairs(soundCache) do
                    if s and s.Parent then
                        pcall(function() s.Volume = vol end)
                    end
                end
                soundCache = {}
            end
        end

        local function startNotifKiller()
            local HUD = LPLR.PlayerGui:WaitForChild("HUD", 5)
            local notifications = HUD and HUD:WaitForChild("Group"):WaitForChild("Notifications")
            if not notifications then return end

            local function getKillParent(obj)
                local cur = obj
                for _ = 1, 6 do
                    if not cur then break end
                    if cur.Parent == notifications then return cur end
                    cur = cur.Parent
                end
                return nil
            end
            local function tryDelete(obj)
                if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
                local txt = tostring(obj.Text):upper()
                if string.find(txt, "20 POINTS", 1, true) and string.find(txt, "200 REPUTATION", 1, true) and string.find(txt, "FOR SLEEPING", 1, true) then
                    local target = getKillParent(obj)
                    if target and target.Parent then target:Destroy() end
                end
            end
            for _, v in ipairs(notifications:GetDescendants()) do tryDelete(v) end
            notifications.DescendantAdded:Connect(function(v)
                task.wait()
                tryDelete(v)
            end)
        end

        local function removeScreen()
            for _, v in pairs(CORE:GetChildren()) do
                if v.Name == "FarmScreen" then v:Destroy() end
            end
        end

        local function getCleanRep()
            local rep = tostring(repValue.Value)
            return tonumber(rep:sub(2)) or 0
        end

        local function REJOIN()
            local ts = game:GetService("TeleportService")
            ts:Teleport(game.PlaceId, LPLR)
        end

        local function updateRepLabel()
            if repLabel then
                local currentRep = getCleanRep()
                local delta = currentRep - lastRepValue

                if delta < -50 then
                    delta = currentRep
                end

                if delta > 0 then
                    totalGained = totalGained + delta
                    if lastRepValue > 80 and currentRep < 30 and not levelUpDetected then
                        levelUpDetected = true
                        if levelUpText then
                            levelUpText.Visible = true
                            levelUpText.TextTransparency = 0
                            task.spawn(function()
                                for i = 1, 30 do
                                    levelUpText.Position = levelUpText.Position + UDim2.new(0, 0, -0.02, 0)
                                    levelUpText.TextTransparency = levelUpText.TextTransparency + 0.033
                                    task.wait(0.02)
                                end
                                levelUpText.Visible = false
                                levelUpText.Position = UDim2.new(0.5, -200, 0.2, 0)
                            end)
                        end
                        levelUpDetected = false
                    end
                end

                lastRepValue = currentRep
                repLabel.Text = "+" .. tostring(totalGained) .. " REP"

                -- AUTO REJOIN CHECK
                if _G.TARGET_REP and _G.TARGET_REP > 0 and totalGained >= _G.TARGET_REP then
                    REJOIN()
                end
            end
        end

        local function makeScreen(imageId)
            removeScreen()
            repLabel = nil
            local function MK_SCREEN(name, order)
                local sg = Instance.new("ScreenGui", CORE)
                sg.Name = "FarmScreen"
                sg.DisplayOrder = order
                sg.ResetOnSpawn = false
                sg.IgnoreGuiInset = true
                return sg
            end

            local black1 = MK_SCREEN("Black1", 2147483644)
            local f1 = Instance.new("Frame", black1)
            f1.Size = UDim2.new(1, 0, 1, 0)
            f1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            f1.BorderSizePixel = 0

            local black2 = MK_SCREEN("Black2", 2147483645)
            local f2 = Instance.new("Frame", black2)
            f2.Size = UDim2.new(1, 0, 1, 0)
            f2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            f2.BorderSizePixel = 0

            local imgSg = MK_SCREEN("Image", 2147483646)
            local img = Instance.new("ImageLabel", imgSg)
            img.Size = UDim2.new(1, 0, 1, 0)
            img.Image = "rbxassetid://" .. imageId
            img.BackgroundTransparency = 1

            if imageId == "72647550241860" then
                local repSg = MK_SCREEN("Rep", 2147483647)
                local frame = Instance.new("Frame", repSg)
                frame.Size = UDim2.new(0, 350, 0, 120)
                frame.Position = UDim2.new(0.5, -175, 0.5, -60)
                frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
                frame.BackgroundTransparency = 0.1
                RND(frame, 15)
                STR(frame, Color3.fromRGB(100, 200, 255), 2)

                local grad = Instance.new("UIGradient", frame)
                grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)) })
                grad.Rotation = 45

                repLabel = Instance.new("TextLabel", frame)
                repLabel.Size = UDim2.new(1, -20, 0.6, 0)
                repLabel.Position = UDim2.new(0, 10, 0.05, 0)
                repLabel.BackgroundTransparency = 1
                repLabel.Text = "+0 REP"
                repLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
                repLabel.Font = Enum.Font.GothamBold
                repLabel.TextSize = 48
                repLabel.TextStrokeTransparency = 0.5

                local sub = Instance.new("TextLabel", frame)
                sub.Size = UDim2.new(1, -20, 0.35, 0)
                sub.Position = UDim2.new(0, 10, 0.62, 0)
                sub.BackgroundTransparency = 1
                sub.Text = "WIN REP🔝"
                sub.TextColor3 = Color3.fromRGB(150, 200, 255)
                sub.Font = Enum.Font.GothamSemibold
                sub.TextSize = 16

                levelUpText = Instance.new("TextLabel", repSg)
                levelUpText.Name = "LevelUpText"
                levelUpText.Size = UDim2.new(0, 400, 0, 80)
                levelUpText.Position = UDim2.new(0.5, -200, 0.2, 0)
                levelUpText.BackgroundTransparency = 1
                levelUpText.Text = "⬆️ LEVEL UP ⬆️"
                levelUpText.TextColor3 = Color3.fromRGB(255, 215, 0)
                levelUpText.Font = Enum.Font.GothamBold
                levelUpText.TextSize = 60
                levelUpText.Visible = false
                levelUpText.ZIndex = 1001

                if repConn then repConn:Disconnect() end
                repConn = repValue:GetPropertyChangedSignal("Value"):Connect(updateRepLabel)
            end
        end

        local function pressW()
            local vu = game:GetService("VirtualUser")
            task.spawn(function()
                for _ = 1, 5 do
                    vu:CaptureController()
                    vu:SetKeyDown("w")
                    task.wait(0.05)
                    vu:SetKeyUp("w")
                    task.wait(0.05)
                end
            end)
        end

        local function resetCamera()
            local re = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
            local camEv = re and re:FindFirstChild("CameraEvent")
            if camEv then pcall(function() firesignal(camEv.OnClientEvent, "Reset") end) end
        end

        local function doFarm()
            if not workspace:FindFirstChild("Beds") then return false end
            local beds = workspace.Beds:GetChildren()
            local valid = {}
            for _, b in pairs(beds) do
                if b:FindFirstChild("Interact") and b.Interact:FindFirstChild("ProximityPrompt") then
                    table.insert(valid,
                        b)
                end
            end
            if #valid == 0 then return false end
            local chosen = valid[math.random(1, #valid)]
            local prompt = chosen.Interact.ProximityPrompt
            local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end

            hrp.CFrame = chosen.Interact.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)

            if useFireMethod then
                for _ = 1, 2000 do
                    if not BedToggled then break end
                    task.spawn(function() pcall(function() fireproximityprompt(prompt) end) end)
                end
            else
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 5
                for _ = 1, 2000 do
                    if not BedToggled then break end
                    task.spawn(function()
                        pcall(function()
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            prompt:InputHoldEnd()
                        end)
                    end)
                end
            end
            return true
        end

        local function stopFarm(bt)
            BedToggled = false
            BedStopping = true

            NOTIFY("System", "Espere a que termine de recibir el nivel...", 5)

            -- Wait for reputation to stop changing (4 seconds idle)
            local lastRepChange = tick()
            local conn
            conn = repValue.Changed:Connect(function()
                lastRepChange = tick()
            end)

            repeat task.wait(0.5) until tick() - lastRepChange > 4 or not BedStopping
            if conn then conn:Disconnect() end

            if repConn then
                repConn:Disconnect(); repConn = nil
            end
            resetCamera()
            pressW()
            task.wait(10)
            if LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") and initialCF then
                LPLR.Character.HumanoidRootPart.CFrame = initialCF
            end
            removeScreen()
            muteSounds(false)

            BedStopping = false
        end

        local function startFarm()
            -- [ STRICT BLOCKING ]
            if string.find(executor, "Xeno") then
                NOTIFY("Blocked", "Xeno is not supported for this user velocity", 7)
                return
            end

            if string.find(executor, "Solara") then
                NOTIFY("Blocked", "Solara is not supported for this user velocity", 7)
                return
            end

            if not useFireMethod then
                NOTIFY("Blocked", "Your executor does not support fireproximityprompt", 7)
                return
            end

            BedToggled = true
            farmStartTime = tick()
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            initialCF = hrp.CFrame
            muteSounds(true)

            -- Dynamic listener for new sounds
            local SS = game:GetService("SoundService")
            local PG = LPLR:WaitForChild("PlayerGui")
            local function autoMute(v)
                if BedToggled and v:IsA("Sound") then
                    if not soundCache[v] then
                        soundCache[v] = v.Volume
                    end
                    v.Volume = 0
                end
            end

            local con1 = workspace.DescendantAdded:Connect(autoMute)
            local con2 = SS.DescendantAdded:Connect(autoMute)
            local con3 = PG.DescendantAdded:Connect(autoMute)

            task.spawn(function()
                repeat task.wait(0.5) until not BedToggled
                con1:Disconnect()
                con2:Disconnect()
                con3:Disconnect()
            end)

            startNotifKiller()
            lastRepValue = getCleanRep()
            repAtStart = lastRepValue
            levelUpDetected = false
            makeScreen("72647550241860")
            task.wait(2)
            while BedToggled do
                doFarm()
                task.wait(1)
            end
        end

        -- [ ACTIONS CARD ]
        local C_ACTIONS = MK_CARD(TR, "Actions", "rbxassetid://87411082578223")

        _G.TARGET_REP = 20000
        ADD_SLD(C_ACTIONS, "Target Rep", 20000, 15000000, 20000, function(v)
            _G.TARGET_REP = v
        end)

        local L_GEN_BTN = ADD_BTN(C_ACTIONS, "Level gen: OFF", function(bt)
            if BedStopping then return end
            if not BedToggled then
                bt.Text = "Level gen: ON"
                TWN(bt, { BackgroundColor3 = Color3.fromRGB(0, 180, 80) }, 0.2)
                task.spawn(startFarm)
            else
                if _G.TARGET_REP and _G.TARGET_REP > 0 then
                    NOTIFY("SYSTEM",
                        "The farm will automatically rejoin\nonce you have reached the selected level.\nPlease wait.", 5)
                    return
                end

                local elapsed = tick() - farmStartTime
                if elapsed < minFarmDuration then
                    local rem = math.ceil(minFarmDuration - elapsed)
                    local oldT = bt.Text
                    bt.Text = "WAIT " .. rem .. "s"
                    TWN(bt, { BackgroundColor3 = Color3.fromRGB(150, 50, 50) }, 0.2)
                    task.wait(1)
                    bt.Text = oldT
                    TWN(bt, { BackgroundColor3 = Color3.fromRGB(0, 180, 80) }, 0.2)
                else
                    bt.Text = "Level gen: OFF"
                    TWN(bt, { BackgroundColor3 = CFG.COL.BG }, 0.2)
                    task.spawn(stopFarm, bt)
                end
            end
        end)
    end
    task.spawn(SETUP_TELEPORTS)

    local function SETUP_FARMS()
        local FL, FR = ADD_SPLIT(P_FRM)
        FL.Parent.Size = UDim2.new(1, -10, 1, -10)
        FL.Parent.Position = UDim2.new(0, 5, 0, 5)

        local LL = Instance.new("UIListLayout", FL)
        LL.Padding = UDim.new(0, 10)
        LL.SortOrder = Enum.SortOrder.LayoutOrder

        local RL = Instance.new("UIListLayout", FR)
        RL.Padding = UDim.new(0, 10)
        RL.SortOrder = Enum.SortOrder.LayoutOrder

        local C1 = MK_CARD(FL, "Plant farm", "rbxassetid://126174660032876")

        -- Farming Variables
        local SelectedQuantity = 1
        local FarmEnabled = false

        local function GET_POT_STATUS(pot)
            if not pot then return "NIL" end
            local prompt = pot:FindFirstChild("Interact") and pot.Interact:FindFirstChildOfClass("ProximityPrompt") or
                pot:FindFirstChild("Pot") and pot.Pot:FindFirstChild("Interact") and
                pot.Pot.Interact:FindFirstChildOfClass("ProximityPrompt")
            if not prompt or not prompt.Enabled then return "BUSY" end

            local text = prompt.ActionText:upper()
            if text:find("HARVEST") then
                return "READY", prompt
            elseif text:find("WATER") then
                return "WATER", prompt
            elseif text:find("PLANT") then
                return "EMPTY", prompt
            end

            return "BUSY", prompt
        end

        local function GET_CASH()
            local cashVal = 99999 -- Default to high to avoid blocking if HUD fails
            pcall(function()
                local label = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Group.HotBar.Cash.CashNumber
                local text = label.Text:gsub("[^%d%.-]", "")
                local n = tonumber(text)
                if n then cashVal = n end
            end)
            return cashVal
        end

        local function USE_PLANT_JUICE()
            local player = game:GetService("Players").LocalPlayer
            local backpack = player:WaitForChild("Backpack")
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                return false
            end

            local currentJuice = backpack:FindFirstChild("Plant Juice") or char:FindFirstChild("Plant Juice")

            -- Check if we need to buy one
            local needsBuying = false
            if not currentJuice then
                needsBuying = true
            else
                local uses = tonumber((currentJuice.ToolTip or ""):match("%d+")) or 0
                if uses <= 0 then
                    needsBuying = true
                end
            end

            -- Buy if needed
            if needsBuying then
                NOTIFY("Farm", "Buying Plant Juice...", 2)
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
                    local juiceItem = SM_REF["Issac's Stock"].Misc
                        ["Plant Juice"]
                    remote:InvokeServer(juiceItem)
                end)

                currentJuice = nil
                for _ = 1, 20 do
                    task.wait(0.25)
                    char = player.Character or player.CharacterAdded:Wait()
                    currentJuice = backpack:FindFirstChild("Plant Juice") or char:FindFirstChild("Plant Juice")
                    if currentJuice then
                        break
                    end
                end
            end

            if not currentJuice then
                NOTIFY("Farm", "Plant Juice not found!", 2)
                return false
            end

            -- Proper equip flow (as verified)
            hum:EquipTool(currentJuice)
            task.wait(1)

            char = player.Character or player.CharacterAdded:Wait()
            local equipped = char:FindFirstChild("Plant Juice")

            if equipped and equipped:FindFirstChild("ClickEvent") then
                equipped.ClickEvent:FireServer(true)
                task.wait(0.2)
                -- Return to backpack after use
                equipped.Parent = backpack
                return true
            end

            NOTIFY("Farm", "Failed to equip/use Plant Juice!", 2)
            return false
        end

        local CURRENT_FARM_MODE = "Simple"
        local function DO_FARM_LOOP()
            local to_plant = SelectedQuantity
            local to_harvest = SelectedQuantity
            local my_pots = {} -- Track only pots we planted in

            -- 1. Buy seeds
            NOTIFY("Farm", "Buying " .. to_plant .. " seeds...", 3)
            pcall(function()
                local remote = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
                local seed = game:GetService("ReplicatedStorage").StoreMenus["Issac's Stock"].Misc.Seed
                for i = 1, to_plant do
                    if not FarmEnabled then break end
                    remote:InvokeServer(seed)
                    task.wait(0.3)
                end
            end)

            -- 2. Farming Loop
            while FarmEnabled and (to_plant > 0 or to_harvest > 0) do
                local player = game.Players.LocalPlayer
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    local container = workspace:FindFirstChild("BerryPots")
                    if container then
                        local children = container:GetChildren()
                        local potRefs = {
                            { idx = 23 }, { direct = "Pot" }, { idx = 19 }, { idx = 17 },
                            { idx = 21 }, { idx = 20 }, { idx = 22 }, { idx = 18 }
                        }

                        -- 1. PLANTING PHASE
                        if to_plant > 0 then
                            NOTIFY("Farm", "Scanning " .. #potRefs .. " pots for planting...", 2)
                            for _, data in ipairs(potRefs) do
                                if not FarmEnabled or to_plant <= 0 then break end
                                if not (char:FindFirstChild("Seed") or player.Backpack:FindFirstChild("Seed")) then break end

                                local pot = data.idx and children[data.idx] or container:FindFirstChild(data.direct)
                                if pot then
                                    if not my_pots[pot] then
                                        local status, prompt = GET_POT_STATUS(pot)
                                        if status == "EMPTY" then
                                            NOTIFY("Farm", "Empty pot found! Teleporting...", 1.5)
                                            BYPASS_TP(pot:GetPivot().Position)
                                            task.wait(0.3)

                                            -- Step 1: Plant
                                            fireproximityprompt(prompt)
                                            NOTIFY("Farm", "Planting seed...", 1)

                                            -- Step 2: Wait for it to become "WATER THE SOIL"
                                            local s1 = tick()
                                            local watered = false
                                            repeat
                                                task.wait(0.1)
                                                local currentStatus = GET_POT_STATUS(pot)
                                                if currentStatus == "WATER" then
                                                    watered = true
                                                end
                                            until watered or not FarmEnabled or tick() - s1 > 4

                                            if FarmEnabled and watered then
                                                local _, p2 = GET_POT_STATUS(pot)
                                                fireproximityprompt(p2)
                                                NOTIFY("Farm", "Watered!", 1)

                                                if CURRENT_FARM_MODE == "Simple + Plant Juice" then
                                                    task.wait(0.2)
                                                    if USE_PLANT_JUICE() then
                                                        NOTIFY("Farm", "Plant Juice applied!", 1.5)
                                                    end
                                                end

                                                my_pots[pot] = true
                                                to_plant = to_plant - 1

                                                -- Wait 5.6 seconds before moving to next pot
                                                task.wait(5.6)
                                            end
                                        end
                                    end
                                else
                                    NOTIFY("Farm Debug", "Pot not found! Index: " .. tostring(data.idx or "N/A"), 2)
                                end
                            end
                        end

                        -- 2. HARVESTING PHASE (Only check OUR pots)
                        if to_harvest > 0 then
                            for pot, is_mine in pairs(my_pots) do
                                if not FarmEnabled or to_harvest <= 0 then break end
                                if is_mine then
                                    local status, prompt = GET_POT_STATUS(pot)
                                    if status == "READY" then
                                        NOTIFY("Farm", "Pot ready! Harvesting...", 1.5)
                                        BYPASS_TP(pot:GetPivot().Position)
                                        task.wait(0.3)
                                        fireproximityprompt(prompt)
                                        NOTIFY("Farm", "Harvested! (" .. to_harvest .. " left)", 1.5)

                                        my_pots[pot] = nil -- Done with this pot
                                        to_harvest = to_harvest - 1
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    else
                        NOTIFY("Farm Debug", "CONTAINER 'BerryPots' NOT FOUND IN WORKSPACE!", 5)
                        task.wait(1)
                    end
                else
                    task.wait(1)
                end
                task.wait(1)
            end

            NOTIFY("Farm", "Session finished!", 3)
            FarmEnabled = false
            -- Note: Toggle UI state will reset if user refreshes or we find a way to update it.
        end

        ADD_TGL(C1, "Auto Plant", false, function(v)
            FarmEnabled = v
            NOTIFY("Farm", "Auto Plant is now: " .. (v and "ENABLED" or "DISABLED"), 3)
            if v then
                task.spawn(DO_FARM_LOOP)
            end
        end)

        local DRP_OPT = ADD_DRP(C1, "Farm options", function(v)
            SelectedQuantity = tonumber(v) or 1
            NOTIFY("Farm", "Quantity set to: " .. SelectedQuantity, 2)
        end)

        local DRP = ADD_DRP(C1, "Farm Mode: Simple", function(v)
            if v == "Simple + Plant Juice" then
                if GET_CASH() < 10000 then
                    NOTIFY("Farm", "Balance low (<10k)? Proceeding anyway...", 2)
                end
            end
            CURRENT_FARM_MODE = v
            NOTIFY("Farm", "Mode: " .. v .. " Active", 2)
        end)
        DRP.REFRESH({ "Simple", "Simple + Plant Juice" })

        -- Real-time Counting for Pots
        task.spawn(function()
            local potRefs = {
                { idx = 23 }, { direct = "Pot" }, { idx = 19 }, { idx = 17 },
                { idx = 21 }, { idx = 20 }, { idx = 22 }, { idx = 18 }
            }

            local lastCount = -1
            while task.wait(0.5) do
                local currentCount = 0
                local container = workspace:FindFirstChild("BerryPots")

                if container then
                    local children = container:GetChildren()
                    for _, data in ipairs(potRefs) do
                        local pot = data.idx and children[data.idx] or container:FindFirstChild(data.direct)
                        if pot then
                            local s = GET_POT_STATUS(pot)
                            if s == "EMPTY" then
                                currentCount = currentCount + 1
                            end
                        end
                    end
                end

                if currentCount ~= lastCount and DRP_OPT then
                    lastCount = currentCount
                    local potList = {}
                    for i = 1, currentCount do
                        table.insert(potList, tostring(i))
                    end
                    DRP_OPT.REFRESH(potList)
                end
            end
        end)

        ADD_BTN(C1, "Sell Current Item", function()
            local char = game:GetService("Players").LocalPlayer.Character
            if not (char and char:FindFirstChildOfClass("Tool")) then
                NOTIFY("Farm", "Equip something before selling!", 3)
                return
            end

            local Event = game:GetService("ReplicatedStorage").RemoteEvents.PackSell
            task.spawn(function() Event:FireServer("Pookie") end)
            task.spawn(function() Event:FireServer("Dan") end)
            NOTIFY("Farm", "Selling to Pookie and Dan...", 2)
        end)

        -- [[ LUCAS FARM (LITERAL Sellv1.lua) ]]
        local LPLR = game:GetService("Players").LocalPlayer
        local WS = game:GetService("Workspace")
        local RS = game:GetService("ReplicatedStorage")
        local VEHICLE_NAME = "GMC Savana (Pack Courier)"
        local MAX_PRODUCT_LIMIT = 20
        local DRUG_NAMES = {
            "White Fun Flour Pack",
            "Purple Fun Flour Pack",
            "Red Fun Flour Pack",
            "Green Fun Flour Pack"
        }

        local function getVehicleObject()
            local pd = RS:FindFirstChild("PlayerData")
            local pData = pd and pd:FindFirstChild(LPLR.Name)
            local stats = pData and pData:FindFirstChild("Statistics")
            local vehicles = stats and stats:FindFirstChild("Vehicles")
            return vehicles and vehicles:FindFirstChild(VEHICLE_NAME)
        end

        local function getCourierSize()
            local pd = RS:FindFirstChild("PlayerData")
            local pData = pd and pd:FindFirstChild(LPLR.Name)
            local stats = pData and pData:FindFirstChild("Statistics")
            local sizeVal = stats and stats:FindFirstChild("CourierSize")
            return sizeVal and sizeVal.Value or 0
        end

        local function isLucaUnlocked()
            local pd = RS:FindFirstChild("PlayerData")
            local pData = pd and pd:FindFirstChild(LPLR.Name)
            local stats = pData and pData:FindFirstChild("Statistics")
            local lore = stats and stats:FindFirstChild("LoreCharacters")
            local luca = lore and lore:FindFirstChild("Luca")
            local unlocked = luca and luca:FindFirstChild("Unlocked")
            return unlocked and unlocked.Value or false
        end

        local function getOwnCourier()
            local vf = WS:FindFirstChild("Vehicles")
            if not vf then return nil end
            for _, car in pairs(vf:GetChildren()) do
                if car:IsA("Model") and car:GetAttribute("Car_Owner") == LPLR.Name then
                    return car
                end
            end
            return nil
        end

        local function ensureCourierOut()
            local car = getOwnCourier()
            if not car then
                local vObj = getVehicleObject()
                if vObj then
                    NOTIFY("Lucas Farm", "Spawning vehicle... wait 4s", 4)
                    local RF = RS:FindFirstChild("RemoteFunctions")
                    local spawnEvent = RF and RF:FindFirstChild("VehicleSpawn")
                    if spawnEvent then
                        spawnEvent:InvokeServer(vObj)
                        task.wait(4)
                        car = getOwnCourier()
                    end
                end
            end
            return car
        end

        local C_LUCAS = MK_CARD(FL, "Lucas Farm", "rbxassetid://10723343321")

        ADD_BTN(C_LUCAS, "Pack Items", function()
            if not isLucaUnlocked() then
                NOTIFY("Blocked", "You must unlock Luca first.", 5)
                return
            end

            local vObj = getVehicleObject()
            if not vObj then
                NOTIFY("Error", "You don't have the required GMC Savana!", 5)
                return
            end

            local hasItems = false
            for _, item in pairs(LPLR.Backpack:GetChildren()) do
                for _, name in pairs(DRUG_NAMES) do
                    if item.Name == name then
                        hasItems = true; break
                    end
                end
                if hasItems then break end
            end

            if not hasItems then
                NOTIFY("Error", "No products in inventory.", 4)
                return
            end

            local car = ensureCourierOut()
            if not car then
                NOTIFY("Error", "Could not find or spawn the vehicle.", 5)
                return
            end

            if getCourierSize() >= MAX_PRODUCT_LIMIT then
                NOTIFY("Full", "The vehicle is already full (20/20).", 5)
                return
            end

            local courierNode = car:FindFirstChild("Functional") and car.Functional:FindFirstChild("Mass") and
                car.Functional.Mass:FindFirstChild("Courier")
            local prompt = courierNode and courierNode:FindFirstChildOfClass("ProximityPrompt")

            if not prompt then
                NOTIFY("Error", "Loading point (Courier) not found.", 5)
                return
            end

            local count = 0
            local currentSize = getCourierSize()

            for _, item in pairs(LPLR.Backpack:GetChildren()) do
                if currentSize >= MAX_PRODUCT_LIMIT then break end
                local isDrug = false
                for _, name in pairs(DRUG_NAMES) do
                    if item.Name == name then
                        isDrug = true; break
                    end
                end

                if isDrug then
                    local promptPos = prompt.Parent.WorldCFrame
                    LPLR.Character.HumanoidRootPart.CFrame = promptPos * CFrame.new(0, 1.5, 0)
                    task.wait(0.15)
                    LPLR.Character.Humanoid:EquipTool(item)
                    task.wait(0.25)
                    fireproximityprompt(prompt)
                    task.wait(0.1)
                    count = count + 1
                    currentSize = currentSize + 1
                end
            end
            NOTIFY("Lucas Farm", "Stored: " .. count .. " | Cargo: " .. currentSize .. "/20", 3)
        end)

        ADD_BTN(C_LUCAS, "Sell", function()
            if not isLucaUnlocked() then
                NOTIFY("Blocked", "You must unlock Luca first.", 5)
                return
            end

            if getCourierSize() <= 0 then
                NOTIFY("Error", "The vehicle is empty!", 5)
                return
            end

            local packSelling = WS:FindFirstChild("PackSelling")
            local locales = { "the warehouses", "Linden courts", "Spring Creek", "fresh seafood", "the bridge",
                "the central courts", "the deli alley", "the playground", "the railway drop" }
            local luca = nil
            for _, folder_name in pairs(locales) do
                local folder = packSelling and packSelling:FindFirstChild(folder_name)
                if folder and folder:FindFirstChild("Luca") then
                    luca = folder.Luca; break
                end
            end

            if not luca then
                NOTIFY("Error", "Luca not found in any location!", 5)
                return
            end

            local hrp_node = luca:FindFirstChild("HumanoidRootPart") and luca.HumanoidRootPart:FindFirstChild("Node")
            local prompt = hrp_node and hrp_node:FindFirstChildOfClass("ProximityPrompt")
            if not prompt or not prompt.Enabled then
                NOTIFY("Cooldown", "Luca is busy or on Cooldown.", 5)
                return
            end

            local car = ensureCourierOut()
            if not car then
                NOTIFY("Error", "Could not find or spawn the vehicle.", 5)
                return
            end

            car:PivotTo(luca:GetPivot() * CFrame.new(0, 0, 8))
            task.wait(0.5)

            local RS_RE = RS:FindFirstChild("RemoteEvents")
            local event = RS_RE and RS_RE:FindFirstChild("PackSell")
            if event then
                event:FireServer("Luca")
                NOTIFY("Luca Sell", "Sale successful.", 3)
            end
        end)

        local C_BANK = MK_CARD(FR, "Bank farm", "rbxassetid://139426182681638")

        local BankFarmEnabled = false
        local HeistWaitUntil = 0
        local LPLR = game:GetService("Players").LocalPlayer

        local function IS_EQUIPPED(name)
            local char = LPLR.Character or LPLR.CharacterAdded:Wait()
            if name == "Mask" then
                return char:FindFirstChild("MaskAcc") ~= nil
            elseif name == "Gloves" then
                local r = char:FindFirstChild("RightHand")
                local l = char:FindFirstChild("LeftHand")
                return (r and r:FindFirstChild("GloveAppearance") ~= nil) and
                    (l and l:FindFirstChild("GloveAppearance") ~= nil)
            end
            return false
        end

        local function HAS_IN_BAG(name) return LPLR.Backpack:FindFirstChild(name) ~= nil end

        local function BUY_AND_EQUIP_MASK()
            local StorePurchase = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
            local UncleChester = game:GetService("ReplicatedStorage").StoreMenus["Uncle Chester"]["Bank Heist"]
            if not IS_EQUIPPED("Mask") then
                if not HAS_IN_BAG("Mask") then
                    NOTIFY("STORE", "Buying Mask...", 2); StorePurchase:InvokeServer(UncleChester.Mask); task.wait(0.5)
                end
                if HAS_IN_BAG("Mask") then
                    LPLR.Character.Humanoid:EquipTool(LPLR.Backpack.Mask); task.wait(0.3)
                end
                game:GetService("ReplicatedStorage").RemoteEvents.ToggleMask:FireServer()
            end
        end

        local function BUY_AND_EQUIP_GLOVES()
            local StorePurchase = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
            local UncleChester = game:GetService("ReplicatedStorage").StoreMenus["Uncle Chester"]["Bank Heist"]
            if not IS_EQUIPPED("Gloves") then
                if not HAS_IN_BAG("Gloves") then
                    NOTIFY("STORE", "Buying Gloves...", 2); StorePurchase:InvokeServer(UncleChester.Gloves); task.wait(0.5)
                end
                if HAS_IN_BAG("Gloves") then
                    LPLR.Character.Humanoid:EquipTool(LPLR.Backpack.Gloves); task.wait(0.3)
                end
                game:GetService("ReplicatedStorage").RemoteEvents.ToggleGloves:FireServer()
            end
        end

        local currentBankLoopId = 0
        if _G.BankItemsBought == nil then _G.BankItemsBought = false end

        local function get_cd_time()
            local cd = workspace.BankHeist.C4:FindFirstChild("CooldownTag", true)
            local tObj = cd and cd:FindFirstChild("Time", true)
            if tObj then
                if tObj:IsA("IntValue") or tObj:IsA("NumberValue") then
                    return tObj.Value
                elseif tObj:IsA("TextLabel") or tObj:IsA("TextBox") then
                    return tonumber(tObj.Text:match("%d+")) or 0
                end
            end
            return 0
        end

        local function IS_VAULT_OPEN()
            local t = workspace.BankHeist.Tables:GetChildren()[2]
            local interact = t and t:FindFirstChild("Interact")
            local prompt = interact and interact:FindFirstChildOfClass("ProximityPrompt")
            return prompt and prompt.Enabled or false
        end

        -- [[ UTILIDADES DE EQUIPO (MÁSCARA Y GUANTES) ]]
        local function IS_EQUIPPED_MASK()
            if not LPLR.Character then return false end
            for _, obj in ipairs(LPLR.Character:GetChildren()) do
                if obj:IsA("Accessory") and (obj.Name == "MaskAcc" or obj.Name:lower():find("mask")) then
                    return true
                end
            end
            return false
        end

        local function IS_EQUIPPED_GLOVES()
            if not LPLR.Character then return false end
            for _, obj in ipairs(LPLR.Character:GetDescendants()) do
                local name = obj.Name:lower()
                if name:find("glove") or name:find("guante") or name == "GlovesAcc" or (obj:IsA("MeshPart") and name:find("hand") and obj.Parent.Name:lower():find("glove")) then
                    return true
                end
            end
            local rh = LPLR.Character:FindFirstChild("RightHand") or LPLR.Character:FindFirstChild("Right Arm")
            if rh and rh:IsA("BasePart") then
                local c = rh.Color
                if c.r < 0.15 and c.g < 0.15 and c.b < 0.15 then return true end
            end
            return false
        end

        local function PREPARE_MASK()
            if IS_EQUIPPED_MASK() then return true end
            if LPLR.Backpack:FindFirstChild("Mask") == nil then
                local StorePurchase = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
                local MaskItem = game:GetService("ReplicatedStorage").StoreMenus["Uncle Chester"]["Bank Heist"].Mask
                StorePurchase:InvokeServer(MaskItem); task.wait(1.5)
            end
            local tool = LPLR.Backpack:FindFirstChild("Mask")
            if tool then
                LPLR.Character.Humanoid:EquipTool(tool); task.wait(0.5)
                game:GetService("ReplicatedStorage").RemoteEvents.ToggleMask:FireServer(); task.wait(0.5)
            end
            return IS_EQUIPPED_MASK()
        end

        local LAST_GLOVE_TOGGLE = 0
        local function PREPARE_GLOVES()
            if IS_EQUIPPED_GLOVES() then return true end
            if tick() - LAST_GLOVE_TOGGLE < 5 then return false end
            if LPLR.Backpack:FindFirstChild("Gloves") == nil then
                local StorePurchase = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
                local GlovesItem = game:GetService("ReplicatedStorage").StoreMenus["Uncle Chester"]["Bank Heist"].Gloves
                StorePurchase:InvokeServer(GlovesItem); task.wait(1.5)
            end
            local tool = LPLR.Backpack:FindFirstChild("Gloves")
            if tool then
                LPLR.Character.Humanoid:EquipTool(tool); task.wait(0.5)
                game:GetService("ReplicatedStorage").RemoteEvents.ToggleGloves:FireServer()
                LAST_GLOVE_TOGGLE = tick(); task.wait(0.5)
            end
            return IS_EQUIPPED_GLOVES()
        end

        local function CHECK_GEAR_BANK()
            if not IS_EQUIPPED_MASK() then
                if not PREPARE_MASK() then return false end
            end
            if not IS_EQUIPPED_GLOVES() then
                if not PREPARE_GLOVES() then return false end
            end
            return IS_EQUIPPED_MASK() and IS_EQUIPPED_GLOVES()
        end

        -- MONITOR GLOBAL DE COOLDOWN DE VENTA (Funciona sin importar el toggle)
        task.spawn(function()
            local notified = false
            while true do
                if _G.SellCooldownEnd and _G.SellCooldownEnd > tick() then
                    notified = true
                elseif notified and _G.SellCooldownEnd and _G.SellCooldownEnd <= tick() then
                    notified = false
                    NOTIFY("Sell Cooldown", "You can sell now!", 5)
                end
                task.wait(1)
            end
        end)

        local function HAS_GOLD()
            return workspace:FindFirstChild(LPLR.Name) and workspace[LPLR.Name]:FindFirstChild("DuffelGold") ~= nil
        end

        local function DO_BANK_LOOP(myLoopId)
            local roundCount = 0
            while BankFarmEnabled and _G.CURRENT_BANK_LOOP_ID == myLoopId and roundCount < 2 do
                local cd = get_cd_time()
                if cd > 1 then
                    NOTIFY("Bank", "Cooldown: " .. math.floor(cd), 3)
                    task.wait(5)
                elseif _G.SellCooldownEnd and _G.SellCooldownEnd > tick() then
                    -- Esperar si el vendedor de oro está en cooldown
                    local remains = math.floor(_G.SellCooldownEnd - tick())
                    NOTIFY("Sell Cooldown", "Wait to start Round: " .. remains .. "s", 1)
                    task.wait(1)
                else
                    -- COMPRA DE SUMINISTROS (Sólo en Ronda 1 si el banco está activo)
                    if roundCount == 0 then
                        local StorePurchase = game:GetService("ReplicatedStorage").RemoteFunctions.StorePurchase
                        local UncleChester = game:GetService("ReplicatedStorage").StoreMenus["Uncle Chester"]
                            ["Bank Heist"]
                        if LPLR.Backpack:FindFirstChild("Duffel Bag") == nil then
                            StorePurchase:InvokeServer(UncleChester["Duffel Bag"]); task.wait(0.3)
                        end
                        if LPLR.Backpack:FindFirstChild("Explosive Charge") == nil then
                            StorePurchase:InvokeServer(UncleChester["Explosive Charge"]); task.wait(0.3)
                        end
                    end

                    if CHECK_GEAR_BANK() then
                        roundCount = roundCount + 1

                        -- ROUND 1: PLANTAR
                        if roundCount == 1 then
                            LPLR.Character.HumanoidRootPart.CFrame = workspace.BankHeist.C4:GetPivot()
                            task.wait(0.3)
                            local c4_tool = LPLR.Backpack:FindFirstChild("Explosive Charge")
                            if c4_tool then
                                LPLR.Character.Humanoid:EquipTool(c4_tool); task.wait(0.2)
                            end

                            FORCE_HOLD(workspace.BankHeist.C4.Attachment.ProximityPrompt)
                            -- TP INMEDIATO TRAS PLANTAR
                            LPLR.Character.HumanoidRootPart.CFrame = workspace.BankHeist.Tables:GetChildren()[2]
                                .Interact:GetPivot() * CFrame.new(0, 0, 3)
                            task.wait(6.30)
                        else
                            -- ROUND 2: TP DIRECTO
                            LPLR.Character.HumanoidRootPart.CFrame = workspace.BankHeist.Tables:GetChildren()[2]
                                .Interact:GetPivot() * CFrame.new(0, 0, 3)
                            task.wait(1)
                        end

                        -- SELECCION DE MESA
                        local tableA = workspace.BankHeist.Tables:GetChildren()[2]
                        local tableB = workspace.BankHeist.Tables.Table

                        local function is_valid(t)
                            if not t then return false end
                            local p = t.Interact:FindFirstChildOfClass("ProximityPrompt")
                            return p ~= nil -- Solo verificamos que exista, el spam se encargará del resto
                        end

                        local function get_gold(t)
                            local rem = nil
                            if t.Name == "Table" then
                                rem = t.GoldBottom.Remaining
                            else
                                rem = t.GoldTop.Remaining
                            end
                            if rem:IsA("IntValue") or rem:IsA("NumberValue") then
                                return rem.Value
                            end
                            return tonumber(rem.Text:match("%d+")) or 0
                        end

                        local targetTable = nil
                        if is_valid(tableA) and get_gold(tableA) >= 10 then
                            targetTable = tableA
                        elseif is_valid(tableB) and get_gold(tableB) >= 10 then
                            targetTable = tableB
                        elseif is_valid(tableA) then
                            targetTable = tableA
                        elseif is_valid(tableB) then
                            targetTable = tableB
                        end

                        if targetTable then
                            LPLR.Character.HumanoidRootPart.CFrame = targetTable.Interact:GetPivot()
                            task.wait(0.2)
                            local prompt = targetTable.Interact:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                for _ = 1, 11 do
                                    task.spawn(function()
                                        pcall(function()
                                            fireproximityprompt(prompt)
                                        end)
                                    end)
                                end
                                task.wait(0.5)
                            end
                        end

                        -- VENDER (Solo si tiene oro)
                        if HAS_GOLD() then
                            local sellNode = workspace.Jewellery.Jewellery.Node

                            -- ESPERA SI HAY COOLDOWN DE VENTA (Detectado por Hook)
                            while _G.SellCooldownEnd and _G.SellCooldownEnd > tick() and BankFarmEnabled do
                                local remains = math.floor(_G.SellCooldownEnd - tick())
                                NOTIFY("Sell Cooldown", "Wait: " .. remains .. "s", 1)
                                task.wait(1)
                            end

                            LPLR.Character.HumanoidRootPart.CFrame = sellNode:GetPivot()
                            task.wait(0.5)
                            fireproximityprompt(sellNode.SellPrompt)
                            task.wait(0.5) -- Espera breve para capturar notificaciones

                            -- SI TRAS EL INTENTO DE VENTA SE ACTIVA EL COOLDOWN, ESPERAR AQUÍ
                            if _G.SellCooldownEnd and _G.SellCooldownEnd > tick() then
                                while _G.SellCooldownEnd > tick() and BankFarmEnabled do
                                    local remains = math.floor(_G.SellCooldownEnd - tick())
                                    NOTIFY("Sell Cooldown", "Wait (Failed): " .. remains .. "s", 1)
                                    task.wait(1)
                                end
                                -- Reintento de venta tras esperar
                                if HAS_GOLD() then
                                    fireproximityprompt(sellNode.SellPrompt)
                                    task.wait(1)
                                end
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            BankFarmEnabled = false
            NOTIFY("Bank", "Farm Finished (2 Rounds)", 5)
        end


        local function HOOK_NOTIFS()
            local Event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("Notification")
            if not _G.BANK_NOTIF_HOOK_ID then _G.BANK_NOTIF_HOOK_ID = 0 end
            local my_id = _G.BANK_NOTIF_HOOK_ID + 1
            _G.BANK_NOTIF_HOOK_ID = my_id

            Event.OnClientEvent:Connect(function(...)
                if _G.BANK_NOTIF_HOOK_ID ~= my_id then return end
                local args = { ... }
                local msg = tostring(args[2] or ""):lower()

                if msg:find("buy gold bars") then
                    local s = tonumber(msg:match("%d+"))
                    if s then _G.SellCooldownEnd = tick() + s + 1 end
                elseif msg:find("seconds") then
                    -- Cooldown del banco
                    local s = tonumber(msg:match("%d+"))
                    if s then HeistWaitUntil = tick() + s + 2 end
                end
            end)
        end

        ADD_TGL(C_BANK, "Auto Bank Heist", false, function(v)
            BankFarmEnabled = v
            if v then
                _G.CURRENT_BANK_LOOP_ID = (_G.CURRENT_BANK_LOOP_ID or 0) + 1
                HeistWaitUntil = 0
                CHECK_GEAR_BANK() -- MONITOREO DE EQUIPO
                NOTIFY("Bank", "System Enabled!", 2)
                task.spawn(HOOK_NOTIFS)
                task.spawn(function() DO_BANK_LOOP(_G.CURRENT_BANK_LOOP_ID) end)
            else
                NOTIFY("Bank", "System Disabled", 2)
            end
        end)

        ADD_BTN(C_BANK, "Buy & Equip Mask", function()
            task.spawn(BUY_AND_EQUIP_MASK)
        end)

        ADD_BTN(C_BANK, "Buy & Equip Gloves", function()
            task.spawn(BUY_AND_EQUIP_GLOVES)
        end)

        -- ── EXTRAS CARD ────────────────────────────────────────────────────────────
        local C_EXTRAS = MK_CARD(FR, "Extras", "rbxassetid://10723343321")
        local DumpFarmEnabled = false
        local BoxFarmEnabled = false
        local TrapRobEnabled = false

        -- [[ LOGICA DUMP FARMS (SINCRO EXACTA) ]]
        local ATM_COOLDOWNS = {}        -- [Object] = LastUsedTime
        local GLOBAL_COOLDOWN_UNTIL = 0
        local FRAUD_COOLDOWN_TIME = 235 -- 3m 50s
        local LAST_ATM_USED = nil
        local LAST_ERROR_RECEIVED = nil

        local function TELEPORT(targetPos)
            if LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") then
                LPLR.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                task.wait(0.15)
            end
        end

        local function BURST_INTERACT(prompt)
            if not prompt then return end
            for _ = 1, 5 do
                task.spawn(function() pcall(function() fireproximityprompt(prompt) end) end)
            end
        end

        local function HAS_ITEM(name)
            return LPLR.Backpack:FindFirstChild(name) ~= nil or
                (LPLR.Character and LPLR.Character:FindFirstChild(name) ~= nil)
        end

        local function GET_ANY_DUMP()
            return LPLR.Backpack:FindFirstChild("Dump (High)") or LPLR.Backpack:FindFirstChild("Dump (Mid)") or
                LPLR.Backpack:FindFirstChild("Dump (Low)") or
                (LPLR.Character and (LPLR.Character:FindFirstChild("Dump (High)") or LPLR.Character:FindFirstChild("Dump (Mid)") or LPLR.Character:FindFirstChild("Dump (Low)")))
        end

        local function PARSE_TIME(text)
            local m = text:match("(%d+)m")
            local s = text:match("(%d+)s")
            local total = 0
            if m then total = total + (tonumber(m) * 60) end
            if s then total = total + tonumber(s) end
            if total == 0 then total = tonumber(text:match("%d+")) or 0 end
            return total
        end

        local function DO_DUMP_LOOP()
            local RS_STORE = game:GetService("ReplicatedStorage")
            local StorePurchase = RS_STORE.RemoteFunctions.StorePurchase
            local UncleMisc = RS_STORE.StoreMenus["Uncle Chester"].Misc
            NOTIFY("Dump Farm", "Exact system synchronized.", 3)
            while DumpFarmEnabled do
                local hasDump = GET_ANY_DUMP()
                if tick() < GLOBAL_COOLDOWN_UNTIL and not hasDump then
                    local wait_secs = math.ceil(GLOBAL_COOLDOWN_UNTIL - tick())
                    if tick() % 15 < 1 then NOTIFY("Dump Farm", "Global cooldown: " .. wait_secs .. "s", 3) end
                    task.wait(2)
                else
                    if not hasDump then
                        if not HAS_IN_BAG("Blank Card") then
                            NOTIFY("Dump Farm", "Buying Blank Card...", 2)
                            StorePurchase:InvokeServer(UncleMisc["Blank Card"]); task.wait(0.5)
                        end
                        local track = workspace.CardFraud.Track1s:FindFirstChild("Track1") or
                            workspace.CardFraud.Track1s:GetChildren()[3]
                        local interact = track and track:FindFirstChild("Interact")
                        if interact then
                            NOTIFY("Dump Farm", "Cloning on Track1...", 2)
                            LPLR.Character.HumanoidRootPart.CFrame = interact:GetPivot() * CFrame.new(0, 3, 0)
                            task.wait(0.5)
                            local card = LPLR.Backpack:FindFirstChild("Blank Card")
                            if card then LPLR.Character.Humanoid:EquipTool(card) end
                            task.wait(0.2)
                            fireproximityprompt(interact:FindFirstChildOfClass("ProximityPrompt") or interact)
                            local startWait = tick()
                            while not GET_ANY_DUMP() and tick() - startWait < 5 do task.wait(0.5) end
                        end
                        hasDump = GET_ANY_DUMP()
                    end
                    if hasDump then
                        NOTIFY("Dump Farm", "Searching for available ATM...", 2)
                        local atms = workspace.CardFraud.ATMs:GetChildren()
                        local finished = false
                        for _, atm in ipairs(atms) do
                            if finished or not DumpFarmEnabled then break end
                            local interact = atm:FindFirstChild("Interact")
                            if interact then
                                if tick() > (ATM_COOLDOWNS[atm] or 0) then
                                    LAST_ATM_USED = atm; LAST_ERROR_RECEIVED = nil
                                    LPLR.Character.HumanoidRootPart.CFrame = interact:GetPivot() * CFrame.new(0, 2, 0)
                                    task.wait(0.5)
                                    LPLR.Character.Humanoid:EquipTool(hasDump)
                                    task.wait(0.2)
                                    fireproximityprompt(interact:FindFirstChildOfClass("ProximityPrompt") or interact)
                                    task.wait(2.5)
                                    if LAST_ERROR_RECEIVED == "recently" then
                                        NOTIFY("Dump Farm", "ATM busy, skipping...", 2)
                                    elseif LAST_ERROR_RECEIVED == "drained" then
                                        NOTIFY("Dump Farm", "Mental exhaustion detected.", 3); finished = true
                                    else
                                        NOTIFY("Dump Farm", "Success! Starting wait.", 3)
                                        GLOBAL_COOLDOWN_UNTIL = tick() + FRAUD_COOLDOWN_TIME; finished = true
                                    end
                                end
                            end
                        end
                        if not finished and not LAST_ERROR_RECEIVED then task.wait(5) end
                    end
                end
                task.wait(1)
            end
            NOTIFY("Dump Farm", "System disabled.", 3)
        end

        local function HOOK_NOTIFS()
            local Event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("Notification")
            if not _G.GLOBAL_NOTIF_HOOKED then
                _G.GLOBAL_NOTIF_HOOKED = true
                Event.OnClientEvent:Connect(function(...)
                    local args = { ... }
                    local type, msg = args[1], tostring(args[2] or "")
                    local low_msg = msg:lower()
                    if type == "error" and low_msg:find("buy gold bars") then
                        local secs = tonumber(msg:match("%d+"))
                        if secs then HeistWaitUntil = tick() + secs + 5 end
                    end
                    if type == "error" then
                        if low_msg:find("recently used") then
                            LAST_ERROR_RECEIVED = "recently"
                            if LAST_ATM_USED then
                                local secs = PARSE_TIME(msg)
                                ATM_COOLDOWNS[LAST_ATM_USED] = tick() + (secs > 0 and secs or 138)
                            end
                        elseif low_msg:find("mentally drained") then
                            LAST_ERROR_RECEIVED = "drained"
                            local secs = PARSE_TIME(msg)
                            GLOBAL_COOLDOWN_UNTIL = tick() + (secs > 0 and secs or FRAUD_COOLDOWN_TIME)
                        end
                    end
                end)
            end
        end

        local function DO_BOX_LOOP()
            NOTIFY("Box Farm", "Starting Box Stacker...", 3)
            while BoxFarmEnabled do
                pcall(function()
                    local b = workspace.BoxStocker.Box.Node
                    LPLR.Character.HumanoidRootPart.CFrame = b:GetPivot() * CFrame.new(0, 2, 0)
                    task.wait(1.1); fireproximityprompt(b.ProximityPrompt); task.wait(1.1)
                    local p = workspace.BoxStocker.Pallet.Node
                    LPLR.Character.HumanoidRootPart.CFrame = p:GetPivot() * CFrame.new(0, 2, 0)
                    task.wait(1.1); fireproximityprompt(p.ProximityPrompt); task.wait(1.1)
                end)
                task.wait(0.1)
            end
            NOTIFY("Box Farm", "Box Stacker disabled.", 3)
        end

        local function DO_TRAP_LOOP()
            NOTIFY("Trap House", "Starting advanced monitoring...", 3)
            local lastWatchNotify = 0

            local function GetActiveStashes()
                local folder = workspace:FindFirstChild("TrapHouse") and workspace.TrapHouse:FindFirstChild("Stashes")
                if not folder then return {} end
                local active = {}
                for _, item in ipairs(folder:GetChildren()) do
                    local interact = item:FindFirstChild("Interact")
                    local prompt = interact and interact:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and prompt.Enabled then table.insert(active, prompt) end
                end
                return active
            end

            while TrapRobEnabled do
                pcall(function()
                    local active = GetActiveStashes()
                    if #active > 0 then
                        local rPos = LPLR.Character and LPLR.Character:GetPivot()
                        NOTIFY("Trap House", "Stashes detected! Preparing...", 2)

                        if not PREPARE_MASK() then
                            NOTIFY("Trap House", "Error preparing mask. Retrying...", 3)
                            return
                        end

                        for _, p in ipairs(active) do
                            if not TrapRobEnabled then break end
                            TELEPORT(p.Parent.Position)
                            BURST_INTERACT(p)
                            task.wait(0.4)
                        end

                        -- Verification loop
                        repeat
                            if not TrapRobEnabled then break end
                            task.wait(0.5)
                            local remaining = GetActiveStashes()
                            if #remaining > 0 then
                                local p = remaining[1]
                                TELEPORT(p.Parent.Position)
                                BURST_INTERACT(p)
                                task.wait(0.4)
                            end
                        until #GetActiveStashes() == 0 or not TrapRobEnabled

                        if rPos and TrapRobEnabled then
                            TELEPORT(rPos.Position)
                            NOTIFY("Trap House", "Round finished. Area clear.", 3)
                        end
                    else
                        if tick() - lastWatchNotify > 20 then
                            NOTIFY("Trap House", "Monitoring...", 3)
                            lastWatchNotify = tick()
                        end
                    end
                end)
                task.wait(1)
            end
            NOTIFY("Trap House", "Monitoring disabled.", 3)
        end

        ADD_TGL(C_EXTRAS, "Dump Farms", false, function(v)
            DumpFarmEnabled = v
            if v then
                task.spawn(HOOK_NOTIFS); task.spawn(DO_DUMP_LOOP)
            end
        end)

        ADD_TGL(C_EXTRAS, "Box farm", false, function(v)
            BoxFarmEnabled = v
            if v then task.spawn(DO_BOX_LOOP) end
        end)

        ADD_TGL(C_EXTRAS, "Auto trap Rob", false, function(v)
            TrapRobEnabled = v
            if v then task.spawn(DO_TRAP_LOOP) end
        end)
    end


    task.spawn(SETUP_FARMS)

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

        local C1 = MK_CARD(VL, "Player Visuals", "rbxassetid://10747373176")
        ADD_ESP_ROW(C1, "Enabled", ESP_CFG.Enabled, function(v) ESP_CFG.Enabled = v end)
        ADD_ESP_ROW(C1, "Bounding Boxes", ESP_CFG.Boxes.Enabled, function(v) ESP_CFG.Boxes.Enabled = v end,
            { { VAL = ESP_CFG.Boxes.Color, CB = function(c) ESP_CFG.Boxes.Color = c end } })
        ADD_ESP_ROW(C1, "Corner Boxes", ESP_CFG.Corners.Enabled, function(v) ESP_CFG.Corners.Enabled = v end,
            { { VAL = ESP_CFG.Corners.Color, CB = function(c) ESP_CFG.Corners.Color = c end } })
        ADD_ESP_ROW(C1, "Filled Boxes", ESP_CFG.Filled.Enabled, function(v) ESP_CFG.Filled.Enabled = v end, {
            { VAL = ESP_CFG.Filled.Color1, CB = function(c) ESP_CFG.Filled.Color1 = c end },
            { VAL = ESP_CFG.Filled.Color2, CB = function(c) ESP_CFG.Filled.Color2 = c end }
        })
        ADD_ESP_ROW(C1, "Names", ESP_CFG.Names.Enabled, function(v) ESP_CFG.Names.Enabled = v end,
            { { VAL = ESP_CFG.Names.Color, CB = function(c) ESP_CFG.Names.Color = c end } })
        ADD_ESP_ROW(C1, "Health Bars", ESP_CFG.Health.Bar, function(v) ESP_CFG.Health.Bar = v end, {
            { VAL = ESP_CFG.Health.Color1, CB = function(c) ESP_CFG.Health.Color1 = c end },
            { VAL = ESP_CFG.Health.Color2, CB = function(c) ESP_CFG.Health.Color2 = c end }
        })
        ADD_ESP_ROW(C1, "Health Text", ESP_CFG.Health.Text, function(v) ESP_CFG.Health.Text = v end)
        ADD_ESP_ROW(C1, "Weapons", ESP_CFG.Weapons.Enabled, function(v) ESP_CFG.Weapons.Enabled = v end,
            { { VAL = ESP_CFG.Weapons.Color, CB = function(c) ESP_CFG.Weapons.Color = c end } })
        ADD_ESP_ROW(C1, "Distance", ESP_CFG.Dist.Enabled, function(v) ESP_CFG.Dist.Enabled = v end,
            { { VAL = ESP_CFG.Dist.Color, CB = function(c) ESP_CFG.Dist.Color = c end } })
        ADD_ESP_ROW(C1, "Chams", ESP_CFG.Chams.Enabled, function(v) ESP_CFG.Chams.Enabled = v end, {
            { VAL = ESP_CFG.Chams.Color1, CB = function(c) ESP_CFG.Chams.Color1 = c end },
            { VAL = ESP_CFG.Chams.Color2, CB = function(c) ESP_CFG.Chams.Color2 = c end }
        })
        ADD_ESP_ROW(C1, "Tool Charms", ESP_CFG.ToolCharms.Enabled, function(v) ESP_CFG.ToolCharms.Enabled = v end, {
            { VAL = ESP_CFG.ToolCharms.Color1, CB = function(c) ESP_CFG.ToolCharms.Color1 = c end },
            { VAL = ESP_CFG.ToolCharms.Color2, CB = function(c) ESP_CFG.ToolCharms.Color2 = c end }
        })


        local C2 = MK_CARD(VR, "Player Visual Settings", "rbxassetid://10734950309")
        ADD_ESP_ROW(C2, "Animated Boxes", ESP_CFG.Boxes.Animated, function(v) ESP_CFG.Boxes.Animated = v end)
        ADD_ESP_ROW(C2, "Dynamic Health Text", ESP_CFG.Health.Dynamic, function(v) ESP_CFG.Health.Dynamic = v end)
        ADD_ESP_ROW(C2, "Thermal Chams", ESP_CFG.Chams.Thermal, function(v) ESP_CFG.Chams.Thermal = v end)

        local F_DRP = ADD_DRP(C2, "Text Font", function(v)
            local f          = Fonts[v] or Enum.Font[v]
            -- Fonts[v] returns a Font object (new system), Enum.Font[v] returns EnumItem
            -- For .Font property we need EnumItem; for .FontFace we need Font object
            -- Store both for safe use in UPD_ESP
            ESP_CFG.Font     = (typeof(f) == "EnumItem") and f or Enum.Font.GothamBold
            ESP_CFG.FontFace = (typeof(f) == "Font") and f or nil
        end)
        F_DRP.REFRESH({ "GothamBold", "Gotham", "Code", "Roboto", "Arcade", "SciFi" })

        ADD_SLD(C2, "Text Size", 8, 24, ESP_CFG.FontSize, function(v) ESP_CFG.FontSize = v end)
        ADD_SLD(C2, "Max Render Distance", 100, 5000, ESP_CFG.MaxDist, function(v) ESP_CFG.MaxDist = v end, "st")

        ADD_TGL(C2, "Fullbright", false, function(v)
            game:GetService("Lighting").Brightness = v and 2 or 1
            game:GetService("Lighting").OutdoorAmbient = v and Color3.new(1, 1, 1) or Color3.fromRGB(127, 127, 127)
        end)
    end
    task.spawn(SETUP_VISUALS)

    local function SETUP_MISC()
        local ML, MR = ADD_SPLIT(P_MSC)
        ML.Parent.Size = UDim2.new(1, -10, 1, -10)
        ML.Parent.Position = UDim2.new(0, 5, 0, 5)

        local LL = Instance.new("UIListLayout", ML)
        LL.Padding = UDim.new(0, 10)
        LL.SortOrder = Enum.SortOrder.LayoutOrder

        local RL = Instance.new("UIListLayout", MR)
        RL.Padding = UDim.new(0, 10)
        RL.SortOrder = Enum.SortOrder.LayoutOrder

        local C_MOV = MK_CARD(ML, "Movements", "rbxassetid://10747062456")

        ADD_TGL(C_MOV, "WalkSpeed", false, function(v)
            _G.EXE.GUN_MODS.SpeedBypass = v
        end)
        ADD_SLD(C_MOV, "Speed Value", 0, 1000, _G.EXE.GUN_MODS.WalkBypassSpeed, function(v)
            _G.EXE.GUN_MODS.WalkBypassSpeed = v
        end)
        local flyConnection
        local flyPos
        ADD_TGL(C_MOV, "Player Fly", false, function(v)
            local char = LPLR.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not root or not humanoid then return end

            if v then
                flyPos = root.Position
                humanoid.PlatformStand = true

                flyConnection = RS.Heartbeat:Connect(function()
                    local cam = workspace.CurrentCamera
                    local cf = cam.CFrame.Rotation
                    local speed = _G.EXE.GUN_MODS.FlySpeed
                    local dir = cf:VectorToObjectSpace(humanoid.MoveDirection * speed)

                    local direction
                    if dir.Magnitude == 0 then
                        direction = Vector3.new(0, 0, 0)
                    else
                        direction = cf:VectorToWorldSpace(
                            Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude
                        )
                    end

                    flyPos = flyPos + direction
                    root.CFrame = CFrame.new(
                        flyPos,
                        cam.CFrame.Position + (flyPos - cam.CFrame.Position) * 2
                    )

                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            else
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                humanoid.PlatformStand = false
                if LPLR.Character then
                    for _, p in ipairs(LPLR.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end
            end
        end)
        ADD_SLD(C_MOV, "Fly Speed", 0, 1000, _G.EXE.GUN_MODS.FlySpeed, function(v)
            _G.EXE.GUN_MODS.FlySpeed = v
        end)
        local infStaminaActive = false
        ADD_TGL(C_MOV, "Inf Stamina", false, function(v)
            infStaminaActive = v
            if v then
                task.spawn(function()
                    while infStaminaActive do
                        pcall(function()
                            local path = game:GetService("ReplicatedStorage").PlayerData[game.Players.LocalPlayer.Name]
                            .Server
                            if path:FindFirstChild("ActiveStamina") then
                                path.ActiveStamina.Value = 999999999 -- Límite seguro (bajo los 2.14 billones de 32 bits)
                            end
                            if path:FindFirstChild("Stamina") then
                                path.Stamina.Value = 999999999
                            end
                            if path:FindFirstChild("MaxStamina") then
                                path.MaxStamina.Value = 999999999
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
            end
        end)
        local isCarFlying = false
        local currentVehicle = nil
        local flyBV, flyBG, flyAttachment
        local welderFolder = nil
        local carFlyConnection

        local function setCarWelds(val, vehicle)
            if not vehicle then return end
            if val then
                if welderFolder then welderFolder:Destroy() end
                welderFolder = Instance.new("Folder")
                welderFolder.Name = "FlyWelders"
                welderFolder.Parent = vehicle
                local functional = vehicle:FindFirstChild("Functional")
                local mass = functional and functional:FindFirstChild("Mass") or vehicle.PrimaryPart or
                vehicle:FindFirstChildOfClass("BasePart")
                if not mass then return end
                local wheels = functional and functional:FindFirstChild("Wheels")
                if wheels then
                    for _, wheel in pairs(wheels:GetChildren()) do
                        if wheel:IsA("BasePart") then
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = wheel
                            weld.Part1 = mass
                            weld.Parent = welderFolder
                        end
                    end
                end
            else
                if welderFolder then
                    welderFolder:Destroy()
                    welderFolder = nil
                end
            end
        end

        local function setCarNoclip(val, vehicle)
            if vehicle then
                for _, v in pairs(vehicle:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = not val
                        v.CanTouch = not val
                        v.CanQuery = not val
                    end
                end
            end
            local char = LPLR.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if val then
                            p.CanCollide = false
                            p.CanTouch = false
                            p.CanQuery = false
                        else
                            -- Fix para evitar el bug de la baseplate (el del WalkSpeed)
                            if p.Name == "Head" or p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "LowerTorso" or p.Name == "HumanoidRootPart" then
                                p.CanCollide = true
                            else
                                p.CanCollide = false
                            end
                            p.CanTouch = true
                            p.CanQuery = true
                        end
                    end
                end
            end
        end

        local function cleanupCarFly()
            isCarFlying = false
            if carFlyConnection then
                carFlyConnection:Disconnect()
                carFlyConnection = nil
            end
            setCarWelds(false, currentVehicle)
            setCarNoclip(false, currentVehicle)
            if flyBV then
                flyBV:Destroy()
                flyBV = nil
            end
            if flyBG then
                flyBG:Destroy()
                flyBG = nil
            end
            if flyAttachment then
                flyAttachment:Destroy()
                flyAttachment = nil
            end
            currentVehicle = nil
        end

        local function get_vic()
            local char = LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            if seat and seat:IsA("VehicleSeat") then
                return seat:FindFirstAncestorOfClass("Model"), seat
            end
            return nil, nil
        end

        local CarFlyTgl = nil
        if UIS.KeyboardEnabled then
            CarFlyTgl = ADD_TGL(C_MOV, "Car Fly", false, function(v)
                if v then
                    local model, seat = get_vic()
                    if not model then
                        NOTIFY("Car Fly", "Siéntate en el conductor primero.", 3)
                        if CarFlyTgl then CarFlyTgl:SET(false) end
                        return
                    end

                    isCarFlying = true
                    currentVehicle = model
                    setCarWelds(true, model)
                    setCarNoclip(true, model)

                    local root = model.PrimaryPart or seat or model:FindFirstChildOfClass("BasePart")
                    flyAttachment = Instance.new("Attachment")
                    flyAttachment.Name = "CarFlyNode"
                    flyAttachment.Parent = root

                    flyBV = Instance.new("LinearVelocity")
                    flyBV.Attachment0 = flyAttachment
                    flyBV.MaxForce = math.huge
                    flyBV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                    flyBV.VectorVelocity = Vector3.new(0, 0, 0)
                    flyBV.RelativeTo = Enum.ActuatorRelativeTo.World
                    flyBV.Parent = root

                    flyBG = Instance.new("AngularVelocity")
                    flyBG.Attachment0 = flyAttachment
                    flyBG.MaxTorque = math.huge
                    flyBG.AngularVelocity = Vector3.new(0, 0, 0)
                    flyBG.RelativeTo = Enum.ActuatorRelativeTo.World
                    flyBG.Parent = root

                    carFlyConnection = RS.Heartbeat:Connect(function(dt)
                        if not isCarFlying or not currentVehicle then return end

                        local char = LPLR.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local seat = hum and hum.SeatPart

                        if not seat or not seat:IsDescendantOf(currentVehicle) then
                            if CarFlyTgl then CarFlyTgl:SET(false) end
                            cleanupCarFly()
                            return
                        end

                        -- MANTENIMIENTO NOCLIP (Vehículo y Personaje)
                        for _, p in pairs(currentVehicle:GetDescendants()) do
                            if p:IsA("BasePart") and (p.CanCollide or p.CanTouch or p.CanQuery) then
                                p.CanCollide = false
                                p.CanTouch = false
                                p.CanQuery = false
                            end
                        end
                        for _, p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then
                                p.CanCollide = false
                            end
                        end

                        if not flyBV or not flyBG then return end

                        local cam = workspace.CurrentCamera
                        local speed = _G.EXE.GUN_MODS.CarFlySpeed or 100
                        local rotSpeed = 3
                        local finalVelocity = Vector3.new(0, 0, 0)
                        local finalAngularVelocity = Vector3.new(0, 0, 0)

                        if UIS:IsKeyDown(Enum.KeyCode.W) then
                            finalVelocity = finalVelocity + (cam.CFrame.LookVector * speed)
                        elseif UIS:IsKeyDown(Enum.KeyCode.S) then
                            finalVelocity = finalVelocity - (cam.CFrame.LookVector * speed)
                        end

                        if UIS:IsKeyDown(Enum.KeyCode.D) then
                            finalAngularVelocity = finalAngularVelocity + Vector3.new(0, -rotSpeed, 0)
                        elseif UIS:IsKeyDown(Enum.KeyCode.A) then
                            finalAngularVelocity = finalAngularVelocity + Vector3.new(0, rotSpeed, 0)
                        end

                        if UIS:IsKeyDown(Enum.KeyCode.E) then
                            finalVelocity = finalVelocity + Vector3.new(0, speed, 0)
                        elseif UIS:IsKeyDown(Enum.KeyCode.Q) then
                            finalVelocity = finalVelocity + Vector3.new(0, -speed, 0)
                        end

                        if UIS:IsKeyDown(Enum.KeyCode.Space) then
                            finalVelocity = Vector3.new(0, 0, 0)
                            finalAngularVelocity = Vector3.new(0, 0, 0)
                        end

                        flyBV.VectorVelocity = finalVelocity
                        flyBG.AngularVelocity = finalAngularVelocity
                    end)
                else
                    cleanupCarFly()
                end
            end)

            ADD_SLD(C_MOV, "Car Fly Speed", 0, 1000, _G.EXE.GUN_MODS.CarFlySpeed, function(v)
                _G.EXE.GUN_MODS.CarFlySpeed = v
            end)
        end
        ADD_TGL(C_MOV, "Movement 5", false, function(v) end)

        local C_TOL = MK_CARD(MR, "Car Spawner", "rbxassetid://10734950309")
        local function get_vic()
            local char = LPLR.Character
            if not char then return nil end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                return hum.SeatPart:FindFirstAncestorOfClass("Model")
            end
            local vf = workspace:FindFirstChild("Vehicles")
            if vf then
                for _, car in pairs(vf:GetChildren()) do
                    if car:IsA("Model") and car:GetAttribute("Car_Owner") == LPLR.Name then
                        return car
                    end
                end
                local cl, md = nil, 50
                for _, car in pairs(vf:GetChildren()) do
                    if car:IsA("Model") then
                        local r = car.PrimaryPart or car:FindFirstChildOfClass("BasePart")
                        if r then
                            local d = (char.PrimaryPart.Position - r.Position).Magnitude
                            if d < md then
                                md = d; cl = car
                            end
                        end
                    end
                end
                return cl
            end
            return nil
        end

        local function do_tp_to_car()
            local car = get_vic()
            if car and LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") then
                -- Buscamos el asiento o la masa para precisión total
                local targetPart = car:FindFirstChildOfClass("VehicleSeat")
                    or (car:FindFirstChild("Functional") and car.Functional:FindFirstChild("Mass"))
                    or car.PrimaryPart
                    or car:FindFirstChildOfClass("BasePart")

                if targetPart then
                    LPLR.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                    NOTIFY("Car Tools", "Teleported to " .. car.Name, 2)
                else
                    NOTIFY("Car Tools", "Could not find a valid part to TP!", 3)
                end
            end
        end

        local D_TOL = ADD_DRP(C_TOL, "Car Tools", function(v)
            if v == "tp to car" then
                do_tp_to_car()
            elseif v == "fix car" then
                local car = get_vic()
                if not car then
                    NOTIFY("Car Tools", "No vehicle found!", 2)
                    return
                end

                local functional = car:FindFirstChild("Functional")
                local root = functional and functional:FindFirstChild("Mass") or car.PrimaryPart or
                    car:FindFirstChildOfClass("BasePart")
                if root then
                    car:PivotTo(car:GetPivot() + Vector3.new(0, 10, 0))
                    local att = Instance.new("Attachment", root)
                    local gyro = Instance.new("AlignOrientation", root)
                    gyro.Attachment0 = att
                    gyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
                    gyro.MaxTorque = math.huge
                    gyro.Responsiveness = 200
                    local _, yRot, _ = car:GetPivot():ToEulerAnglesYXZ()
                    gyro.CFrame = CFrame.Angles(0, yRot, 0)
                    for _, v in pairs(car:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Anchored = false
                            v.AssemblyLinearVelocity = Vector3.new(0, -1, 0)
                        end
                    end
                    task.wait(0.5)
                    gyro:Destroy()
                    att:Destroy()
                    NOTIFY("Car Tools", "Vehicle fixed!", 2)
                end
            end
        end)
        D_TOL.REFRESH({ "tp to car", "fix car" })

        local currentCars = {}
        local function refresh_car_list(dropdown)
            local data = game:GetService("ReplicatedStorage"):FindFirstChild("PlayerData")
            local pData = data and data:FindFirstChild(LPLR.Name)
            local stats = pData and pData:FindFirstChild("Statistics")
            local vehicles = stats and stats:FindFirstChild("Vehicles")

            if vehicles then
                currentCars = {}
                local names = {}
                for _, car in pairs(vehicles:GetChildren()) do
                    currentCars[car.Name] = car
                    table.insert(names, car.Name)
                end
                table.sort(names)
                dropdown.REFRESH(names)
            end
        end

        local D_MYC = ADD_DRP(C_TOL, "My Cars", function(v)
            local obj = currentCars[v]
            if obj then
                local RF = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions")
                local spawnEvent = RF and RF:FindFirstChild("VehicleSpawn")
                if spawnEvent then
                    spawnEvent:InvokeServer(obj)
                    NOTIFY("Car Spawner", "Invocando: " .. v, 3)
                end
            end
        end)

        -- Monitor real-time changes
        task.spawn(function()
            local data = game:GetService("ReplicatedStorage"):WaitForChild("PlayerData", 10)
            local pData = data and data:WaitForChild(LPLR.Name, 10)
            local stats = pData and pData:WaitForChild("Statistics", 10)
            local vFolder = stats and stats:WaitForChild("Vehicles", 10)

            if vFolder then
                refresh_car_list(D_MYC)
                vFolder.ChildAdded:Connect(function() refresh_car_list(D_MYC) end)
                vFolder.ChildRemoved:Connect(function() refresh_car_list(D_MYC) end)
            end
        end)
    end
    task.spawn(SETUP_MISC)

    -- ============================================================
    --  CONFIG → SETTINGS & FEEDBACK
    -- ============================================================
    local function SETUP_CONFIG()
        local CL, CR               = ADD_SPLIT(P_SET)

        -- Fix column sizes & add vertical list layouts (same as SETUP_VISUALS)
        CL.Parent.Size             = UDim2.new(1, -10, 1, -10)
        CL.Parent.Position         = UDim2.new(0, 5, 0, 5)
        CL.Size                    = UDim2.new(0.5, -2, 1, 0)
        CL.AutomaticSize           = Enum.AutomaticSize.Y

        local CL_LAY               = Instance.new("UIListLayout", CL)
        CL_LAY.Padding             = UDim.new(0, 10)
        CL_LAY.SortOrder           = Enum.SortOrder.LayoutOrder
        CL_LAY.HorizontalAlignment = Enum.HorizontalAlignment.Center

        CR.Size                    = UDim2.new(0.5, -2, 1, 0)
        CR.AutomaticSize           = Enum.AutomaticSize.Y

        local CR_LAY               = Instance.new("UIListLayout", CR)
        CR_LAY.Padding             = UDim.new(0, 10)
        CR_LAY.SortOrder           = Enum.SortOrder.LayoutOrder
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
            H.Name = "Header"
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

        -- Teleport Bypass selection logic
        local function MK_SET_DRP(label, order, options, callback)
            local WRAP = Instance.new("Frame", TP_CARD_SET)
            WRAP.Size = UDim2.new(1, 0, 0, 35)
            WRAP.BackgroundTransparency = 1
            WRAP.BorderSizePixel = 0
            WRAP.ClipsDescendants = false
            WRAP.ZIndex = 25 - order
            WRAP.LayoutOrder = order

            local FRM = Instance.new("Frame", WRAP)
            FRM.Size = UDim2.new(1, 0, 0, 35)
            FRM.BackgroundColor3 = CFG.COL.BG
            FRM.BackgroundTransparency = 0.4
            FRM.BorderSizePixel = 0
            FRM.ClipsDescendants = true
            FRM.ZIndex = 25 - order
            RND(FRM, 8); STR(FRM, CFG.COL.GRY, 1)

            local BTN = Instance.new("TextButton", FRM)
            BTN.Size = UDim2.new(1, 0, 0, 35)
            BTN.BackgroundTransparency = 1
            BTN.Text = "  " .. label .. ": " .. _G.EXE.TP_METHOD
            BTN.TextColor3 = CFG.COL.TXT
            BTN.Font = Enum.Font.GothamBold
            BTN.TextSize = 13
            BTN.TextXAlignment = Enum.TextXAlignment.Left
            BTN.ZIndex = 26 - order

            local ICO = Instance.new("ImageLabel", BTN)
            ICO.Size = UDim2.new(0, 16, 0, 16)
            ICO.Position = UDim2.new(1, -24, 0.5, -8)
            ICO.BackgroundTransparency = 1
            ICO.Image = "rbxassetid://6031091004"
            ICO.ImageColor3 = CFG.COL.ACC
            ICO.ZIndex = 27 - order

            local drpH = #options * 28
            local SCR = Instance.new("ScrollingFrame", FRM)
            SCR.Size = UDim2.new(1, 0, 0, drpH)
            SCR.Position = UDim2.new(0, 0, 0, 35)
            SCR.BackgroundTransparency = 1
            SCR.BorderSizePixel = 0
            SCR.ScrollBarThickness = 2
            SCR.ZIndex = 27 - order

            local LAY = Instance.new("UIListLayout", SCR)

            local open = false
            BTN.MouseButton1Click:Connect(function()
                open = not open
                TWN(FRM, { Size = UDim2.new(1, 0, 0, open and (35 + drpH) or 35) })
                TWN(WRAP, { Size = UDim2.new(1, 0, 0, open and (35 + drpH) or 35) })
                TWN(ICO, { Rotation = open and 180 or 0 })
            end)

            for i, opt in ipairs(options) do
                local ITM = Instance.new("TextButton", SCR)
                ITM.Size = UDim2.new(1, 0, 0, 28)
                ITM.BackgroundTransparency = 1
                ITM.Text = "  " .. opt
                ITM.TextColor3 = CFG.COL.TXT
                ITM.Font = Enum.Font.Gotham
                ITM.TextSize = 12
                ITM.TextXAlignment = Enum.TextXAlignment.Left
                ITM.LayoutOrder = i

                ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
                ITM.MouseLeave:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.TXT }, 0.1) end)
                ITM.MouseButton1Click:Connect(function()
                    BTN.Text = "  " .. label .. ": " .. opt
                    open = false
                    TWN(FRM, { Size = UDim2.new(1, 0, 0, 35) })
                    TWN(WRAP, { Size = UDim2.new(1, 0, 0, 35) })
                    TWN(ICO, { Rotation = 0 })
                    callback(opt)
                end)
            end
        end

        -- ── TELEPORT BYPASS METHODS CARD ───────────────────────
        local TP_CARD_SET = Instance.new("Frame", CR)
        TP_CARD_SET.Size = UDim2.new(1, 0, 0, 0)
        TP_CARD_SET.AutomaticSize = Enum.AutomaticSize.Y
        TP_CARD_SET.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        TP_CARD_SET.BackgroundTransparency = 0.2
        TP_CARD_SET.BorderSizePixel = 0
        TP_CARD_SET.LayoutOrder = 2
        RND(TP_CARD_SET, 12)
        STR(TP_CARD_SET, CFG.COL.ACC, 1).Transparency = 0.75

        local TP_LAY                                  = Instance.new("UIListLayout", TP_CARD_SET)
        TP_LAY.SortOrder                              = Enum.SortOrder.LayoutOrder
        TP_LAY.Padding                                = UDim.new(0, 10)

        local TP_PAD                                  = Instance.new("UIPadding", TP_CARD_SET)
        TP_PAD.PaddingTop                             = UDim.new(0, 12)
        TP_PAD.PaddingBottom                          = UDim.new(0, 14)
        TP_PAD.PaddingLeft                            = UDim.new(0, 12)
        TP_PAD.PaddingRight                           = UDim.new(0, 12)

        -- Header
        local TP_HDR                                  = Instance.new("Frame", TP_CARD_SET)
        TP_HDR.Size                                   = UDim2.new(1, 0, 0, 35)
        TP_HDR.BackgroundTransparency                 = 1
        TP_HDR.LayoutOrder                            = 0

        local TP_ICN                                  = Instance.new("ImageLabel", TP_HDR)
        TP_ICN.Size                                   = UDim2.new(0, 32, 0, 32)
        TP_ICN.Position                               = UDim2.new(0, 0, 0.5, -16)
        TP_ICN.BackgroundTransparency                 = 1
        TP_ICN.Image                                  = "rbxassetid://102084991489439"
        TP_ICN.ImageColor3                            = CFG.COL.ACC

        local TP_TTL                                  = Instance.new("TextLabel", TP_HDR)
        TP_TTL.Size                                   = UDim2.new(1, -40, 1, 0)
        TP_TTL.Position                               = UDim2.new(0, 40, 0, 0)
        TP_TTL.BackgroundTransparency                 = 1
        TP_TTL.Text                                   = "Bypass Method"
        TP_TTL.TextColor3                             = CFG.COL.TXT
        TP_TTL.Font                                   = Enum.Font.GothamBold
        TP_TTL.TextSize                               = 18
        TP_TTL.TextXAlignment                         = Enum.TextXAlignment.Left

        local TP_DIV                                  = Instance.new("Frame", TP_CARD_SET)
        TP_DIV.Size                                   = UDim2.new(1, 0, 0, 1)
        TP_DIV.BackgroundColor3                       = CFG.COL.ACC
        TP_DIV.BackgroundTransparency                 = 0.85
        TP_DIV.BorderSizePixel                        = 0
        TP_DIV.LayoutOrder                            = 1

        -- Teleport Bypass selection logic
        local function MK_SET_DRP(label, order, options, callback)
            local WRAP = Instance.new("Frame", TP_CARD_SET)
            WRAP.Size = UDim2.new(1, 0, 0, 35)
            WRAP.BackgroundTransparency = 1
            WRAP.BorderSizePixel = 0
            WRAP.ClipsDescendants = false
            WRAP.ZIndex = 25 - order
            WRAP.LayoutOrder = order

            local FRM = Instance.new("Frame", WRAP)
            FRM.Size = UDim2.new(1, 0, 0, 35)
            FRM.BackgroundColor3 = CFG.COL.BG
            FRM.BackgroundTransparency = 0.4
            FRM.BorderSizePixel = 0
            FRM.ClipsDescendants = true
            FRM.ZIndex = 25 - order
            RND(FRM, 8); STR(FRM, CFG.COL.ACC, 1.2)

            local BTN = Instance.new("TextButton", FRM)
            BTN.Size = UDim2.new(1, 0, 0, 35)
            BTN.BackgroundTransparency = 1
            BTN.Text = "  " .. label .. ": " .. _G.EXE.TP_METHOD
            BTN.TextColor3 = CFG.COL.TXT
            BTN.Font = Enum.Font.GothamBold
            BTN.TextSize = 13
            BTN.TextXAlignment = Enum.TextXAlignment.Left
            BTN.ZIndex = 26 - order

            local ICO = Instance.new("ImageLabel", BTN)
            ICO.Size = UDim2.new(0, 16, 0, 16)
            ICO.Position = UDim2.new(1, -24, 0.5, -8)
            ICO.BackgroundTransparency = 1
            ICO.Image = "rbxassetid://6031091004"
            ICO.ImageColor3 = CFG.COL.ACC
            ICO.ZIndex = 27 - order

            local drpH = #options * 28
            local SCR = Instance.new("ScrollingFrame", FRM)
            SCR.Size = UDim2.new(1, 0, 0, drpH)
            SCR.Position = UDim2.new(0, 0, 0, 35)
            SCR.BackgroundTransparency = 1
            SCR.BorderSizePixel = 0
            SCR.ScrollBarThickness = 2
            SCR.ZIndex = 27 - order

            local LAY = Instance.new("UIListLayout", SCR)

            local open = false
            BTN.MouseButton1Click:Connect(function()
                open = not open
                TWN(FRM, { Size = UDim2.new(1, 0, 0, open and (35 + drpH) or 35) })
                TWN(WRAP, { Size = UDim2.new(1, 0, 0, open and (35 + drpH) or 35) })
                TWN(ICO, { Rotation = open and 180 or 0 })
            end)

            for i, opt in ipairs(options) do
                local ITM = Instance.new("TextButton", SCR)
                ITM.Size = UDim2.new(1, 0, 0, 28)
                ITM.BackgroundTransparency = 1
                ITM.Text = "  " .. opt
                ITM.TextColor3 = CFG.COL.TXT
                ITM.Font = Enum.Font.Gotham
                ITM.TextSize = 12
                ITM.TextXAlignment = Enum.TextXAlignment.Left
                ITM.LayoutOrder = i

                ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
                ITM.MouseLeave:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.TXT }, 0.1) end)
                ITM.MouseButton1Click:Connect(function()
                    BTN.Text = "  " .. label .. ": " .. opt
                    open = false
                    TWN(FRM, { Size = UDim2.new(1, 0, 0, 35) })
                    TWN(WRAP, { Size = UDim2.new(1, 0, 0, 35) })
                    TWN(ICO, { Rotation = 0 })
                    callback(opt)
                end)
            end
        end


        -- Teleport Bypass selection logic removed (Classic only)


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

        local TH_LAY                              = Instance.new("UIListLayout", TH_CARD)
        TH_LAY.SortOrder                          = Enum.SortOrder.LayoutOrder
        TH_LAY.Padding                            = UDim.new(0, 10)

        local TH_PAD                              = Instance.new("UIPadding", TH_CARD)
        TH_PAD.PaddingTop                         = UDim.new(0, 12)
        TH_PAD.PaddingBottom                      = UDim.new(0, 14)
        TH_PAD.PaddingLeft                        = UDim.new(0, 12)
        TH_PAD.PaddingRight                       = UDim.new(0, 12)

        -- Header
        local TH_HDR                              = Instance.new("Frame", TH_CARD)
        TH_HDR.Size                               = UDim2.new(1, 0, 0, 35)
        TH_HDR.BackgroundTransparency             = 1
        TH_HDR.LayoutOrder                        = 0

        local TH_ICN                              = Instance.new("ImageLabel", TH_HDR)
        TH_ICN.Size                               = UDim2.new(0, 32, 0, 32)
        TH_ICN.Position                           = UDim2.new(0, 0, 0.5, -16)
        TH_ICN.BackgroundTransparency             = 1
        TH_ICN.Image                              = "rbxassetid://77077610158107"
        TH_ICN.ImageColor3                        = CFG.COL.ACC

        local TH_TTL                              = Instance.new("TextLabel", TH_HDR)
        TH_TTL.Size                               = UDim2.new(1, -40, 1, 0)
        TH_TTL.Position                           = UDim2.new(0, 40, 0, 0)
        TH_TTL.BackgroundTransparency             = 1
        TH_TTL.Text                               = "Theme / Text"
        TH_TTL.TextColor3                         = CFG.COL.TXT
        TH_TTL.Font                               = Enum.Font.GothamBold
        TH_TTL.TextSize                           = 18
        TH_TTL.TextXAlignment                     = Enum.TextXAlignment.Left

        local TH_DIV                              = Instance.new("Frame", TH_CARD)
        TH_DIV.Size                               = UDim2.new(1, 0, 0, 1)
        TH_DIV.BackgroundColor3                   = CFG.COL.ACC
        TH_DIV.BackgroundTransparency             = 0.85
        TH_DIV.BorderSizePixel                    = 0
        TH_DIV.LayoutOrder                        = 1

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
            STR(FRM, CFG.COL.ACC, 1.2)

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
                TWN(FRM, { Size = UDim2.new(1, 0, 0, 35) })
                TWN(WRAP, { Size = UDim2.new(1, 0, 0, 35) })
                TWN(ICO, { Rotation = 0 })
            end
            local function OPEN(H)
                if H then DRP_H = H end
                IS_OPEN = true
                TWN(FRM, { Size = UDim2.new(1, 0, 0, 35 + DRP_H) })
                TWN(WRAP, { Size = UDim2.new(1, 0, 0, 35 + DRP_H) })
                TWN(ICO, { Rotation = 180 })
            end

            BTN.MouseButton1Click:Connect(function()
                if IS_OPEN then CLOSE() else OPEN() end
            end)

            return { FRM = FRM, WRAP = WRAP, BTN = BTN, ICO = ICO, SCR = SCR, LAY = LAY, CLOSE = CLOSE, OPEN = OPEN }
        end

        -- ── DROPDOWN 1: UI Theme ─────────────────────────────────
        local THEME_LIST = {
            { name = "Default", icon = "🔴" },
            { name = "Snow White", icon = "❄️" },
            { name = "Sky Blue", icon = "🌊" },
            { name = "Void Black", icon = "🌑" },
            { name = "Coffee", icon = "☕" },
            { name = "Gold", icon = "✨" },
        }
        local D_THEME = MK_TH_DRP("UI Theme", 2)
        local thH = #THEME_LIST * 30
        D_THEME.SCR.Size = UDim2.new(1, 0, 0, thH)
        D_THEME.OPEN(thH)
        D_THEME.CLOSE()

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
            ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
            ITM.MouseLeave:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.TXT }, 0.1) end)
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
        D_FONT.OPEN(fH)
        D_FONT.CLOSE()

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
            ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
            ITM.MouseLeave:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.TXT }, 0.1) end)
            ITM.MouseButton1Click:Connect(function()
                D_FONT.BTN.Text = "  " .. f.name
                D_FONT.CLOSE()
                -- Aplicar fuente al UI completo
                APPLY_FONT_UI(f.font)
                -- Actualizar ESP font (usa Enum.Font directamente)
                CurFontName = f.name
                SAVE_CONFIG()
                ESP_CFG.Font = f.font
                NOTIFY("Font", f.name .. " applied!", 3)
            end)
        end

        -- ── CUSTOM BACKGROUND CARD ─────────────────────────────
        local BG_CARD = MK_CARD(CR, "Custom Interface", "rbxassetid://10734950309")
        BG_CARD.LayoutOrder = 4

        local BG_PREVIEW = Instance.new("ImageLabel", BG_CARD)
        BG_PREVIEW.Size = UDim2.new(1, -10, 0, 60)
        BG_PREVIEW.BackgroundColor3 = CFG.COL.BG
        BG_PREVIEW.BackgroundTransparency = 0.5
        BG_PREVIEW.Image = CurBGId
        BG_PREVIEW.ScaleType = Enum.ScaleType.Crop
        BG_PREVIEW.LayoutOrder = 2
        RND(BG_PREVIEW, 8)
        STR(BG_PREVIEW, CFG.COL.ACC, 1).Transparency = 0.7

        local BG_INP = ADD_INP(BG_CARD, "Enter Image ID (e.g. 88638598959470)", CurBGId, function(v)
            if v and v ~= "" then
                local finalId = v
                if tonumber(v) then finalId = "rbxassetid://" .. v end
                CurBGId = finalId
                CFG.IMG = finalId
                BG_PREVIEW.Image = finalId
                pcall(function()
                    if MAIN:FindFirstChild("BG") then
                        MAIN.BG.Image = finalId
                    end
                end)
                SAVE_CONFIG()
                NOTIFY("Interface", "Background updated!", 3)
            end
        end)
        BG_INP.Parent.LayoutOrder = 3

        local function SET_TRANS(v)
            CurBGTrans = v
            pcall(function()
                if MAIN:FindFirstChild("BG") then
                    MAIN.BG.ImageTransparency = v
                end
            end)
            SAVE_CONFIG()
        end

        local TRANS_SLD = ADD_SLD(BG_CARD, "Interface Transparency", 0, 100, (CurBGTrans * 100), function(v)
            SET_TRANS(v / 100)
        end)
        TRANS_SLD.LayoutOrder = 4

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
                embeds = { {
                    title = "💬 New Script Feedback",
                    description = "```\n" .. msg .. "\n```",
                    color = 0x32A852,
                    fields = {
                        { name = "Username", value = LPLR.Name,             inline = true },
                        { name = "User ID",  value = tostring(LPLR.UserId), inline = true }
                    },
                    footer = { text = "WH01AM Feedback" },
                    timestamp = DateTime.now():ToIsoDate()
                } }
            }

            task.spawn(function()
                local success, respond = pcall(function()
                    return req({
                        Url =
                        "https://discord.com/api/webhooks/1481433215398056087/5yiYW_g6HGoAcxig9zy0YQYX1Ciu3H_5AehQxZk_j0NxnrcWU8Uf7ev5-XmerOix7JGa",
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = game:GetService("HttpService"):JSONEncode(payload)
                    })
                end)

                if success and respond and (respond.StatusCode == 200 or respond.StatusCode == 204) then
                    NOTIFY("Success", "Thanks for your feedback! Sent to discord.", 4)
                    FDBK_TXT.Text = ""
                else
                    NOTIFY("Error",
                        "Failed to send feedback. Status: " .. tostring(respond and respond.StatusCode or "Unknown"), 5)
                end
                task.wait(5)
                DEBOUNCE = false
            end)
        end)

        -- ── EXTRAS & SERVER UTILITIES CARD ──────────────────────
        local EXTRAS_CARD = MK_CARD(CL, "Extras", "rbxassetid://106507089706013")
        EXTRAS_CARD.LayoutOrder = 10
        local E_HDR = EXTRAS_CARD:FindFirstChild("Header")

        -- Integrated Menu Bind in Header
        local BIND_WRAP = Instance.new("Frame", E_HDR)
        BIND_WRAP.Size = UDim2.new(0, 130, 1, 0)
        BIND_WRAP.Position = UDim2.new(1, -135, 0, 0)
        BIND_WRAP.BackgroundTransparency = 1

        local BIND_LBL = Instance.new("TextLabel", BIND_WRAP)
        BIND_LBL.Size = UDim2.new(0, 80, 1, 0)
        BIND_LBL.BackgroundTransparency = 1
        BIND_LBL.Text = "Menu Bind"
        BIND_LBL.TextColor3 = CFG.COL.ACC
        BIND_LBL.Font = Enum.Font.GothamBold
        BIND_LBL.TextSize = 10
        BIND_LBL.TextXAlignment = Enum.TextXAlignment.Right

        local KB_BOX = Instance.new("TextButton", BIND_WRAP)
        KB_BOX.Size = UDim2.new(0, 42, 0, 22)
        KB_BOX.Position = UDim2.new(1, -45, 0.5, -11)
        KB_BOX.BackgroundColor3 = CFG.COL.BG
        KB_BOX.BackgroundTransparency = 0.82
        KB_BOX.BorderSizePixel = 0
        KB_BOX.Text = tostring(CFG.KEY.Name):gsub("Enum.KeyCode.", "")
        KB_BOX.TextColor3 = Color3.new(1, 1, 1)
        KB_BOX.Font = Enum.Font.GothamBold
        KB_BOX.TextSize = 9
        KB_BOX.TextScaled = true
        local KB_TSC = Instance.new("UITextSizeConstraint", KB_BOX)
        KB_TSC.MaxTextSize = 9
        KB_TSC.MinTextSize = 6
        KB_BOX.AutoButtonColor = false
        RND(KB_BOX, 8)

        local KB_STR = STR(KB_BOX, CFG.COL.ACC, 1.2)
        KB_STR.Transparency = 0.8
        KB_STR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local KB_GRAD = Instance.new("UIGradient", KB_BOX)
        KB_GRAD.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
        })
        KB_GRAD.Rotation = 45
        KB_GRAD.Transparency = NumberSequence.new(0.5)

        local KB_LISTENING = false
        KB_BOX.MouseEnter:Connect(function()
            TWN(KB_BOX,
                { BackgroundTransparency = 0.65, BackgroundColor3 = CFG.COL.ACC, TextColor3 = Color3.new(0, 0, 0) },
                0.2)
            TWN(KB_STR, { Transparency = 0.45 }, 0.2)
        end)
        KB_BOX.MouseLeave:Connect(function()
            TWN(KB_BOX,
                { BackgroundTransparency = 0.82, BackgroundColor3 = CFG.COL.BG, TextColor3 = Color3.new(1, 1, 1) },
                0.2)
            TWN(KB_STR, { Transparency = 0.8 }, 0.2)
        end)

        KB_BOX.MouseButton1Click:Connect(function()
            if KB_LISTENING then return end
            KB_LISTENING = true
            KB_BOX.Text = "..."
            KB_BOX.TextColor3 = CFG.COL.YEL
            TWN(KB_BOX, { BackgroundColor3 = Color3.fromRGB(50, 45, 20), BackgroundTransparency = 0.5 }, 0.1)

            local conn
            conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                KB_LISTENING = false

                if inp.KeyCode ~= Enum.KeyCode.Escape then
                    CFG.KEY = inp.KeyCode
                    local name = tostring(inp.KeyCode.Name)
                    KB_BOX.Text = name
                    SAVE_CONFIG()
                else
                    KB_BOX.Text = tostring(CFG.KEY.Name)
                end
                KB_BOX.TextColor3 = Color3.new(1, 1, 1)
                TWN(KB_BOX, { BackgroundColor3 = CFG.COL.BG, BackgroundTransparency = 0.82 }, 0.1)
            end)
        end)

        -- Server Utilities
        local function ServerHop()
            local x = {}
            for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data) do
                if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
                    x[#x + 1] = v.id
                end
            end
            if #x > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
            else
                NOTIFY("Server Hop", "No servers found!", 3)
            end
        end

        local function JoinLowest()
            local servers = {}
            local res = game:HttpGet("https://games.roblox.com/v1/games/" ..
                game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local data = game:GetService("HttpService"):JSONDecode(res).data
            for _, v in ipairs(data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v)
                end
            end
            table.sort(servers, function(a, b) return a.playing < b.playing end)
            if #servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[1].id)
            else
                NOTIFY("Server", "No other servers found!", 3)
            end
        end

        ADD_BTN(EXTRAS_CARD, "Join Lowest Server", JoinLowest)
        ADD_BTN(EXTRAS_CARD, "Server Hop", ServerHop)
        ADD_BTN(EXTRAS_CARD, "Rejoin", function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LPLR)
        end)
    end
    task.spawn(SETUP_CONFIG)

    -- Startup state
    task.spawn(function()
        CUR_BTN = B_HOM
        CUR_PAG = P_HOM
        TWN(B_HOM, {
            TextColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0,
            BackgroundColor3 = CFG.COL.ACC
        })
        P_HOM.Visible = true


        -- [ RESIZE HANDLE ]
        do
            local RS_S = { ON = false, ST = nil, SZ = nil, IP = nil }
            local RSZ = Instance.new("TextButton", MAIN)
            RSZ.Name = "RSZ_HANDLE"
            RSZ.Size = UDim2.new(0, 28, 0, 28)
            RSZ.Position = UDim2.new(1, -28, 1, -28)
            RSZ.BackgroundTransparency = 1
            RSZ.Text = ""
            RSZ.ZIndex = 11
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
                    if c:IsA("TextLabel") then TWN(c, { TextTransparency = 0 }, 0.15) end
                end
            end)
            RSZ.MouseLeave:Connect(function()
                for i, c in ipairs(RSZ:GetChildren()) do
                    if c:IsA("TextLabel") then TWN(c, { TextTransparency = i * 0.25 }, 0.2) end
                end
            end)

            RSZ.InputBegan:Connect(function(I)
                if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
                    RS_S.ON = true; RS_S.ST = I.Position; RS_S.SZ = MAIN.AbsoluteSize; RS_S.IP = I
                    I.Changed:Connect(function() if I.UserInputState == Enum.UserInputState.End then RS_S.ON = false end end)
                end
            end)
            UIS.InputChanged:Connect(function(I)
                local IS_M = I.UserInputType == Enum.UserInputType.MouseMovement
                local IS_T = I.UserInputType == Enum.UserInputType.Touch
                if RS_S.ON and (IS_M or (IS_T and I == RS_S.IP)) then
                    local DEL = I.Position - RS_S.ST
                    MAIN.Size = UDim2.new(0, math.max(450, RS_S.SZ.X + DEL.X), 0, math.max(300, RS_S.SZ.Y + DEL.Y))
                end
            end)
        end

        -- [ KEYBOARD TOGGLE (RightCtrl) ]
        UIS.InputBegan:Connect(function(I, G)
            if not G and I.KeyCode == CFG.KEY then
                MAIN.Visible = not MAIN.Visible
            end
        end)

        -- [ MOBILE SUPPORT ]
        do
            if UIS.TouchEnabled then
                local MB_S = { ON = false, ST = nil, PS = nil, IP = nil }
                MAIN.AnchorPoint = Vector2.new(0.5, 0.5)
                MAIN.Position = UDim2.new(0.5, 0, 0.5, 0)
                MAIN.Size = UDim2.new(0.6, 0, 0.5, 0)

                local MTOG = Instance.new("ImageButton", SCR)
                MTOG.Name, MTOG.Size, MTOG.Position = "MTOG", UDim2.new(0, 50, 0, 50), UDim2.new(1, -70, 0.2, 0)
                MTOG.BackgroundColor3, MTOG.BackgroundTransparency, MTOG.Image = CFG.COL.BG, 0.2, CFG.IMG
                MTOG.ImageColor3, MTOG.ZIndex = CFG.COL.ACC, 100
                RND(MTOG, 25); STR(MTOG, CFG.COL.ACC, 2)

                MTOG.MouseButton1Click:Connect(function() MAIN.Visible = not MAIN.Visible end)
                MTOG.InputBegan:Connect(function(I)
                    if I.UserInputType == Enum.UserInputType.Touch or I.UserInputType == Enum.UserInputType.MouseButton1 then
                        MB_S.ON, MB_S.ST, MB_S.PS, MB_S.IP = true, I.Position, MTOG.Position, I
                        I.Changed:Connect(function() if I.UserInputState == Enum.UserInputState.End then MB_S.ON = false end end)
                    end
                end)
                UIS.InputChanged:Connect(function(I)
                    local IS_M = I.UserInputType == Enum.UserInputType.MouseMovement
                    local IS_T = I.UserInputType == Enum.UserInputType.Touch
                    if MB_S.ON and (IS_M or (IS_T and I == MB_S.IP)) then
                        local DEL = I.Position - MB_S.ST
                        MTOG.Position = UDim2.new(MB_S.PS.X.Scale, MB_S.PS.X.Offset + DEL.X, MB_S.PS.Y.Scale,
                            MB_S.PS.Y.Offset + DEL.Y)
                    end
                end)
            end
        end

        -- [ APPLY SAVED SETTINGS ]
        APPLY_FONT_UI(Enum.Font[CurFontName] or Enum.Font.GothamBold)
        pcall(function()
            if MAIN:FindFirstChild("BG") then
                MAIN.BG.ImageTransparency = CurBGTrans
            end
        end)
    end) -- end global init spawn

    NOTIFY("UI", "Framework Loaded!", 4)
end
BUILD_NYH_UI()
