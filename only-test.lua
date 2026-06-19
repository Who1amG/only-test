if not getgenv().BYPASS_LOADED then
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Tagger83/BYPASSs.lua/refs/heads/main/bs.lua"))()
    end)
    if success then
        getgenv().BYPASS_LOADED = true
    else
        warn("Bypass failed to load: " .. tostring(err))
    end
end

-- [ SVC ]
local ENV = { S = setmetatable({}, { __index = function(_, k) return game:GetService(k) end }) }
ENV.P, ENV.T, ENV.U, ENV.C, ENV.RS, ENV.RC = ENV.S.Players, ENV.S.TweenService, ENV.S.UserInputService, ENV.S.CoreGui,
    ENV.S.RunService, ENV.S.ReplicatedStorage
local PLRS, TS, UIS, CORE, RS, RS_CAR = ENV.P, ENV.T, ENV.U, ENV.C, ENV.RS, ENV.RC
local LPLR = PLRS.LocalPlayer
local TARGET_ID = 121567535120062
local MAIN_ID = 121567535120062


local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

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
-- [ SINGLETON ]
if _G.CENTRAL_LOADED then
    local OLD = CORE:FindFirstChild("CEN_V2") or LPLR.PlayerGui:FindFirstChild("CEN_V2")
    if OLD then
        OLD.Enabled = true
        pcall(function()
            if _G.NOTIFY then
                _G.NOTIFY("Security", "Script already running! Restored Visibility.", 3)
            else
                warn("NYH: Already Loaded!")
            end
        end)
        return
    else
        _G.CENTRAL_LOADED = false
    end
end
-- [ GLOBAL CFG ]
_G.CENTRAL_LOADED = true
_G.EXE = _G.EXE or {}
local E = _G.EXE

-- [ NOTIFICATION SUPPRESSION ]
task.spawn(function()
    local rep = game:GetService("ReplicatedStorage")
    local inst = rep:WaitForChild("Instancers", 10)
    local notifScript = inst and inst:WaitForChild("Notification", 10)
    if notifScript then
        local success, Notification = pcall(function()
            return require(notifScript)
        end)
        if success and typeof(Notification) == "table" then
            local oldInit = Notification.Init
            if oldInit then
                Notification.Init = function(self, data, ...)
                    if typeof(data) == "table" and (data.Title == "Robbing" or tostring(data.Title):find("Rob")) then
                        return -- Block robbing notifications
                    end
                    return oldInit(self, data, ...)
                end
            end
        end
    end
end)
E.FARM_RUNNING = (E.FARM_RUNNING ~= nil) and E.FARM_RUNNING or false
E.BYPASS_CARS_ON = (E.BYPASS_CARS_ON ~= nil) and E.BYPASS_CARS_ON or false
E.TP_METHOD = E.TP_METHOD or "Classic"
E.TP_SPEED = E.TP_SPEED or 450
E.ACTIVE_TOGGLES = E.ACTIVE_TOGGLES or {}
E.GUN_MODS = E.GUN_MODS or {
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
E.SECURITY = E.SECURITY or { AdminDetector = false, AutoLeave = false }
E.AUTO_ARMOR = (E.AUTO_ARMOR ~= nil) and E.AUTO_ARMOR or false
E.AUTO_ARMOR_THRESHOLD = E.AUTO_ARMOR_THRESHOLD or 20

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



-- [ ADMIN DETECTOR ]
local STAFF_LIST = {
    [1257073083] = "HighDispersion",
    [491881629]  = "MrFrosty",
    [7821897977] = "RGn",
    [429393318]  = "NixfrmCBK",
    [1462158335] = "Crxcii",
    [5116099657] = "CBKRxRTJ",
    [2520899372] = "Zay_3RS",
    [369304050]  = "KitTakaTeeFrmCBK",
    [101782189]  = "コール",
    [443186070]  = "Jimm",
    [5494980700] = "LLTrapp57",
    [8589713339] = "I0PP3",
    [948985163]  = "khi",
    [7203561836] = "ITSMYFAULT",
    [1748679794] = "WAZE",
    [222638640]  = "landooo",
    [167307509]  = "1301MG MainTap",
    [5090858991] = "trey",
    [33540477]   = "Yuke",
    [1702548443] = "Xlym",
    [99984265]   = "Ishan",
    [1781883503] = "Pulledupinnafuto",
    [8162310250] = "OperationAJ",
    [3106275464] = "wintrs",
    [154943097]  = "tapp",
    [2473529312] = "someone",
    [4775061]    = "angelbaby12",
    [7322940967] = "Glock47DrumBeam",
    [167283473]  = "Valor",
    [169641570]  = "toooher",
    [6219914993] = "VON",
    [7270095233] = "jaywaymoneyway1",
    [193675379]  = "OperationDev"
}

local AdminIDs = {
    [193675379] = "Owner",
    [7270095233] = "Admin",
    [6219914993] = "Admin",
    [169641570] = "Admin",
    [167283473] = "Admin",
    [7322940967] = "Admin",
    [4775061] = "Admin",
    [2473529312] = "Admin",
    [154943097] = "Admin",
    [8162310250] = "Admin",
    [3106275464] = "Analytics",
    [1748679794] = "Tester",
    [443186070] = "Tester",
    [2520899372] = "Tester",
    [429393318] = "Tester",
    [8469523389] = "Tester",
    [1257073083] = "Contributor"
}

-- Mantenemos los antiguos también por si acaso
for id, rank in pairs(STAFF_LIST) do
    if not AdminIDs[id] then
        AdminIDs[id] = rank
    end
end

local function KickPlayer()
    LPLR:Kick("Admin detected! Changing server...")
    task.wait(2)

    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" ..
        tostring(PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"

    local function getServers(c)
        local u = c and (url .. "&cursor=" .. c) or url
        local s, r = pcall(function() return HttpService:JSONDecode(game:HttpGet(u)) end)
        return (s and r and r.data) and r or nil
    end

    local serverToHop, cursor = nil, nil
    while not serverToHop do
        local data = getServers(cursor)
        if data and data.data then
            for _, sv in ipairs(data.data) do
                if type(sv) == "table" and sv.id ~= game.JobId and sv.playing and sv.playing < sv.maxPlayers - 1 then
                    serverToHop = sv.id
                    break
                end
            end
            cursor = data.nextPageCursor
            if not cursor then break end
        else
            break
        end
    end

    if serverToHop then
        TeleportService:TeleportToPlaceInstance(PlaceId, serverToHop, LPLR)
    else
        TeleportService:Teleport(PlaceId, LPLR)
    end
end

local function checkAdmin(player)
    if AdminIDs[player.UserId] then return true end
    if player.UserId == game.CreatorId then return true end

    local s1, rank = pcall(function() return player:GetRankInGroup(35381445) end)
    if s1 and type(rank) == "number" and rank > 0 then return true end

    local s2, inGroup = pcall(function() return player:IsInGroup(1200769) end)
    if s2 and type(inGroup) == "boolean" and inGroup then return true end

    return false
end

local function onAdminDetected(player)
    if not _G.EXE.SECURITY.AdminDetector then return end
    NOTIFY("SECURITY", "ADMIN DETECTED: " .. player.Name .. " (" .. player.UserId .. ")", 15)
    warn("[SECURITY] Admin Detected: " .. player.Name)

    if _G.EXE.SECURITY.AutoLeave then
        task.wait(0.5)
        KickPlayer()
    end
end

task.spawn(function()
    -- Initial Scan
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LPLR and checkAdmin(p) then
            onAdminDetected(p)
        end
    end

    -- Real-time Scan
    game:GetService("Players").PlayerAdded:Connect(function(p)
        if checkAdmin(p) then
            onAdminDetected(p)
        end
    end)
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
local ActiveFont             = Enum.Font.GothamBold -- fuente activa global, usada por NOTIFY y otros
local CurBGId                = CFG.IMG
local CurBGTrans             = 0.8
local CurSidebarTabs         = false
local CurSmoothDrag          = false
local CurSizeX               = 700
local CurSizeY               = 565

local function SAVE_CONFIG()
    local data = {
        CustomBG    = CurBGId,
        BG_Trans    = CurBGTrans,
        Keybind     = tostring(CFG.KEY),
        SidebarTabs = CurSidebarTabs,
        SmoothDrag  = CurSmoothDrag,
        Theme       = CurThemeName,
        Font        = CurFontName,
        SizeX       = CurSizeX,
        SizeY       = CurSizeY
    }
    pcall(function()
        if writefile and HttpService then
            writefile("CTS_Config.json", HttpService:JSONEncode(data))
        end
    end)
end

local function LOAD_CONFIG()
    local has_file = false
    pcall(function()
        if isfile and isfile("CTS_Config.json") then
            has_file = true
        end
    end)
    if has_file then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("CTS_Config.json"))
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
            if data.SidebarTabs ~= nil then
                CurSidebarTabs = data.SidebarTabs
            end
            if data.SmoothDrag ~= nil then
                CurSmoothDrag = data.SmoothDrag
            end
            if data.Theme then
                CurThemeName = data.Theme
            end
            if data.Font then
                CurFontName = data.Font
            end
            if data.SizeX then
                CurSizeX = data.SizeX
            end
            if data.SizeY then
                CurSizeY = data.SizeY
            end
        end
    end
end



local REF_UPDATE_TABS

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
    if REF_UPDATE_TABS then
        REF_UPDATE_TABS()
    end
end



-- Aplica una fuente a todos los TextLabel/TextButton/TextBox del UI
local function APPLY_FONT_UI(enumFont)
    -- Guardar fuente activa para que nuevos elementos (notif, etc.) la usen
    ActiveFont = enumFont
    local root = game:GetService("CoreGui")
    local scr  = root:FindFirstChild("CEN_V2")
    if not scr then
        local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        scr = pg and pg:FindFirstChild("CEN_V2")
    end
    if not scr then return end
    for _, obj in ipairs(scr:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            pcall(function()
                if typeof(enumFont) == "Font" then
                    obj.FontFace = enumFont
                else
                    obj.Font = enumFont
                end
            end)
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
    Names      = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Health     = { Enabled = false, Bar = false, Text = false, Color1 = Color3.fromRGB(0, 255, 0), Color2 = Color3.fromRGB(255, 0, 0) },
    Snaplines  = { Enabled = false, Color = Color3.new(1, 0, 0), Thickness = 1.2, OffScreen = false },
    Skeleton   = { Enabled = false, Color = Color3.new(1, 1, 1), Thickness = 1.2 },
    Weapons    = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Dist       = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Chams      = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0) },
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
    GUI.DisplayOrder = 10000 -- Above everything
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
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; cb(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                cb(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
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
    local isMultiline = MSG:find("\n")
    local frmHeight = isMultiline and 68 or 52
    local msgHeight = isMultiline and 36 or 20

    local FRM = Instance.new("Frame", HOLDER)
    FRM.Size = UDim2.new(1, 0, 0, frmHeight)
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

    local _NF = (typeof(ActiveFont) == "Font") and Enum.Font.GothamBold or (ActiveFont or Enum.Font.GothamBold)
    local _NM = (typeof(ActiveFont) == "Font") and Enum.Font.Gotham or (ActiveFont or Enum.Font.Gotham)

    local T = Instance.new("TextLabel", FRM)
    T.Text = TITLE
    T.Size = UDim2.new(1, -30, 0, 15)
    T.Position = UDim2.new(0, 12, 0, 6)
    T.BackgroundTransparency = 1
    T.TextColor3 = CFG.COL.ACC
    if typeof(ActiveFont) == "Font" then
        T.FontFace = ActiveFont
    else
        T.Font = _NF
    end
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.TextTransparency = 1
    T.ZIndex = BG.ZIndex + 1

    local M = Instance.new("TextLabel", FRM)
    M.Text = MSG
    M.Size = UDim2.new(1, -30, 0, msgHeight)
    M.Position = UDim2.new(0, 12, 0, 20)
    M.BackgroundTransparency = 1
    M.TextColor3 = Color3.new(1, 1, 1)
    if typeof(ActiveFont) == "Font" then
        M.FontFace = ActiveFont
    else
        M.Font = _NM
    end
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

        local ITM = Instance.new("TextButton")
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
        ITM.Parent = SCR

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

    local function RFSH(arg1, arg2)
        local LST = type(arg1) == "table" and (arg1.ADD and arg2 or arg1) or arg1
        if type(LST) ~= "table" then return end

        pcall(function()
            for _, C in pairs(SCR:GetChildren()) do
                if C.Name == "DropItem" then C:Destroy() end
            end
            for _, P in pairs(LST) do
                ADD_ITEM(nil, P)
            end
        end)
    end

    BTN.MouseButton1Click:Connect(function()
        OPEN = not OPEN
        if OPEN then
            local items = 0
            for _, c in ipairs(SCR:GetChildren()) do
                if not c:IsA("UIListLayout") then items = items + 1 end
            end
            local h = math.min(LAY.AbsoluteContentSize.Y, 150)
            TWN(FRM, { Size = UDim2.new(1, -10, 0, 35 + h) })
            TWN(SCR, { Size = UDim2.new(1, 0, 0, h) })
            TWN(ICO, { Rotation = 180 })
        else
            TWN(FRM, { Size = UDim2.new(1, -10, 0, 35) })
            TWN(ICO, { Rotation = 0 })
        end
    end)

    local function ADD_MANY(self, list)
        for _, v in ipairs(list) do
            self:ADD(v, v)
        end
        return self
    end

    local function RESET_TEXT()
        BTN.Text = "  " .. (prefix and (prefix .. ": " .. initial_val) or TTL)
    end

    return { FRM = FRM, SCR = SCR, ADD = ADD_ITEM, REFRESH = RFSH, ADD_MANY = ADD_MANY, RESET = RESET_TEXT }
end

local function ADD_TGL(PAG, TXT, DEF, CB)
    local TGL = { VAL = DEF or false, CB = CB }
    table.insert(_G.EXE.ACTIVE_TOGGLES, TGL)

    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    RND(FRM, 8)
    STR(FRM, CFG.COL.ACC, 1).Transparency = 0.8
    local cur_ord = PAG:GetAttribute("NextOrder") or 0
    FRM.LayoutOrder = cur_ord
    PAG:SetAttribute("NextOrder", cur_ord + 1)

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
        if TGL.CB and not dont_callback then TGL.CB(TGL.VAL) end
    end

    BTN.MouseButton1Click:Connect(function()
        TGL.VAL = not TGL.VAL
        UPD()
    end)

    function TGL:SET(v, run_cb)
        self.VAL = v
        UPD(not run_cb)
    end

    TGL.FRM = FRM
    return TGL
end

local function ADD_TGL_KB(PAG, TXT, DEF, DEF_KB, CB)
    local TGL = { VAL = DEF or false, KB = DEF_KB, CB = CB }
    table.insert(_G.EXE.ACTIVE_TOGGLES, TGL)
    local IS_PC = not IS_MOBILE
    _G.CEN_BINDS = _G.CEN_BINDS or {}

    local FRM = Instance.new("Frame", PAG)
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    RND(FRM, 8)
    STR(FRM, CFG.COL.ACC, 1).Transparency = 0.8
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
                TGL.VAL = not TGL.VAL
                TWN(BTN, { BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
                TWN(IND, { Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
                if TGL.CB then TGL.CB(TGL.VAL, TGL.KB) end
            end
        end)
        table.insert(_G.CEN_BINDS, bind_conn)
    end

    local function UPD(dont_callback)
        TWN(BTN, { BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
        TWN(IND, { Position = TGL.VAL and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
        if TGL.CB and not dont_callback then TGL.CB(TGL.VAL, TGL.KB) end
    end

    BTN.MouseButton1Click:Connect(function()
        TGL.VAL = not TGL.VAL
        UPD()
    end)
    function TGL:SET(v, run_cb)
        self.VAL = v
        UPD(not run_cb)
    end

    return TGL
end

local function ADD_SLD(PAG, TXT, MIN, MAX, DEF, CB, SFX)
    local SLD = { VAL = DEF or MIN }
    local suffix = SFX or ""

    local FRM = Instance.new("TextButton", PAG)
    FRM.Name = TXT .. "_Slider"
    FRM.Size = UDim2.new(1, -10, 0, 40)
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
    local function START_DRAG(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            getgenv()._CEN_SLD_ACTIVE = true -- LOCK GLOBAL DRAG
            DRAG = true
            UPD(input)
        end
    end

    FRM.InputBegan:Connect(START_DRAG)

    UIS.InputChanged:Connect(function(input)
        if DRAG and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UPD(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        FRM        = Instance.new("Frame", ESP_HOLDER),
        NAME       = Instance.new("TextLabel"),
        DIST       = Instance.new("TextLabel"),
        WEAP       = Instance.new("TextLabel"),
        BAR_BG     = Instance.new("Frame"),
        BAR_FL     = Instance.new("Frame"),
        BAR_GRAD   = Instance.new("UIGradient"),
        HEALTH_TXT = Instance.new("TextLabel"),
        SLINE      = Instance.new("Frame"),
        SKEL       = {}
    }
    E.SLINE.Parent = E.FRM

    for i = 1, 15 do
        local seg = Instance.new("Frame", E.FRM)
        seg.BorderSizePixel = 0
        seg.Visible = false
        seg.ZIndex = -2
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        E.SKEL[i] = seg
    end

    E.SLINE.BorderSizePixel = 0
    E.SLINE.ZIndex = -1
    E.SLINE.AnchorPoint = Vector2.new(0.5, 0.5)

    E.FRM.BackgroundTransparency = 1
    E.FRM.Size = UDim2.new(1, 0, 1, 0)
    E.FRM.ZIndex = 0


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
local function UPD_ESP()
    local cam = workspace.CurrentCamera
    local plrs = PLRS:GetPlayers()

    -- Distancia inteligente para priorizar Rayos-X (Evita límite de 31 Highlights del motor)
    table.sort(plrs, function(a, b)
        local ca, cb = a.Character or workspace:FindFirstChild(a.Name), b.Character or workspace:FindFirstChild(b.Name)
        local pa = ca and (ca:FindFirstChild("HumanoidRootPart") or ca:FindFirstChild("UpperTorso"))
        local pb = cb and (cb:FindFirstChild("HumanoidRootPart") or cb:FindFirstChild("UpperTorso"))
        local da = pa and (cam.CFrame.Position - pa.Position).Magnitude or 99999
        local db = pb and (cam.CFrame.Position - pb.Position).Magnitude or 99999
        return da < db
    end)

    local activeHL = 0

    for _, p in ipairs(plrs) do
        pcall(function()
            local isLocalPlayer = (p == LPLR)
            local E = CACHE[p] or MK_ESP(p)

            -- Búsquedas mejoradas NYC (UserId + Name)
            local C = p.Character or workspace:FindFirstChild(p.Name)
            if not C then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and (obj.Name:find(tostring(p.UserId)) or obj.Name:find(p.Name)) then
                        C = obj; break
                    end
                end
            end

            if not C then
                if E.CH_PARTS then
                    for _, v in pairs(E.CH_PARTS) do pcall(function() v:Destroy() end) end; E.CH_PARTS = nil
                end
                E.FRM.Visible = false; return
            end

            local H            = C:FindFirstChild("HumanoidRootPart") or C:FindFirstChild("Torso") or
                C:FindFirstChild("UpperTorso")
            local HUM          = C:FindFirstChildOfClass("Humanoid")

            local curHP, maxHP = 100, 100
            local hv           = C:FindFirstChild("Health")
            if hv and hv:IsA("NumberValue") then
                curHP = hv.Value
            elseif HUM then
                curHP = HUM.Health; maxHP = HUM.MaxHealth
            end

            -- En servidores RP (NYC), la vida nativa a veces se marca en 0 para ocultar la barra de Roblox.
            -- Usamos el "Estado" del humanoide o asumimos que está vivo si sigue mapeado a Character.
            local isAlive = true
            if HUM and HUM:GetState() == Enum.HumanoidStateType.Dead then
                isAlive = false
            end


            -- MOTOR DE CHAMS NYC (Autocamuflaje de Plasma - SOLO LOCALPLAYER)
            if isLocalPlayer then
                if ESP_CFG.Chams.Enabled and isAlive then
                    E_SELF_ORIGINAL_MATS = E_SELF_ORIGINAL_MATS or {}

                    -- Respiración Bicolor para Plasma (Ocupa ambos Color Pickers de la interfaz)
                    local wave = (math.sin(tick() * 3.5) + 1) * 0.5
                    local pulseColor = ESP_CFG.Chams.Color1:Lerp(ESP_CFG.Chams.Color2, wave)

                    -- Limpiamos Ropa 3D y aplicamos Plasma Base
                    for _, obj in ipairs(C:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                            if obj.Name ~= "HumanoidRootPart" and obj.Transparency < 1 and not obj:FindFirstAncestorOfClass("Tool") then
                                local sa = obj:FindFirstChildOfClass("SurfaceAppearance")

                                if not E_SELF_ORIGINAL_MATS[obj] then
                                    E_SELF_ORIGINAL_MATS[obj] = {
                                        Mat = obj.Material,
                                        Col = obj.Color,
                                        SA = sa,
                                        Tr = obj.Transparency
                                    }
                                end

                                if sa then sa.Parent = nil end

                                obj.Material = Enum.Material.ForceField
                                obj.Color = pulseColor
                            end
                        end
                    end
                else
                    if E_SELF_ORIGINAL_MATS then
                        for obj, data in pairs(E_SELF_ORIGINAL_MATS) do
                            pcall(function()
                                if obj and obj.Parent then
                                    obj.Material = data.Mat
                                    obj.Color = data.Col
                                    obj.Transparency = data.Tr
                                    if data.SA and data.SA.Parent ~= obj then
                                        data.SA.Parent = obj
                                    end
                                end
                            end)
                        end
                        E_SELF_ORIGINAL_MATS = nil
                    end
                end
            end



            -- 2D Visuals Logic (Exclusivo para Enemigos)
            if ESP_CFG.Enabled and H and isAlive and not isLocalPlayer then
                local cam = workspace.CurrentCamera
                local pos, vis = cam:WorldToViewportPoint(H.Position)
                local dist = (cam.CFrame.Position - H.Position).Magnitude
                local inDist = dist <= ESP_CFG.MaxDist

                -- Main container visibility
                E.FRM.Visible = inDist

                if vis and inDist then
                    local s_y = (H.Size.Y * 2 * cam.ViewportSize.Y) / (pos.Z * 2)
                    local s_x = s_y * 0.75
                    local x, y = pos.X - s_x / 2, pos.Y - s_y / 2

                    local function SET_F(lbl, sz)
                        if typeof(ESP_CFG.Font) == "Font" then
                            lbl.FontFace = ESP_CFG.Font
                        else
                            lbl.Font = (typeof(ESP_CFG.Font) == "EnumItem") and ESP_CFG.Font or Enum.Font.GothamBold
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
                    local hp_per = math.clamp(curHP / math.max(maxHP, 1), 0, 1)
                    E.BAR_BG.Visible = ESP_CFG.Health.Bar
                    E.BAR_BG.Position = UDim2.new(0, x - 6, 0, y)
                    E.BAR_BG.Size = UDim2.new(0, 3, 0, s_y)
                    E.BAR_FL.Size = UDim2.new(1, 0, hp_per, 0)
                    E.BAR_FL.Position = UDim2.new(0, 0, 1 - hp_per, 0)

                    if ESP_CFG.Health.Bar then
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
                    E.NAME.Visible = false
                    E.BAR_BG.Visible = false
                    E.HEALTH_TXT.Visible = false
                    E.WEAP.Visible = false
                    E.DIST.Visible = false
                end

                -- [ SKELETON ESP ]
                if inDist and ESP_CFG.Skeleton.Enabled and vis then
                    local bones = (C:FindFirstChild("UpperTorso") and R15_BONES) or
                        (C:FindFirstChild("Torso") and R6_BONES)
                    if bones then
                        for i, connection in ipairs(bones) do
                            local p1, p2 = C:FindFirstChild(connection[1]), C:FindFirstChild(connection[2])
                            local seg = E.SKEL[i]
                            if p1 and p2 and seg then
                                local v1, vis1 = cam:WorldToViewportPoint(p1.Position)
                                local v2, vis2 = cam:WorldToViewportPoint(p2.Position)
                                if vis1 or vis2 then
                                    local d = Vector2.new(v2.X - v1.X, v2.Y - v1.Y)
                                    seg.Size = UDim2.new(0, ESP_CFG.Skeleton.Thickness, 0, d.Magnitude)
                                    seg.Position = UDim2.new(0, v1.X + (d.X / 2), 0, v1.Y + (d.Y / 2))
                                    seg.Rotation = math.deg(math.atan2(d.Y, d.X)) - 90
                                    seg.BackgroundColor3 = ESP_CFG.Skeleton.Color
                                    seg.Visible = true
                                else
                                    seg.Visible = false
                                end
                            elseif seg then
                                seg.Visible = false
                            end
                        end
                        -- Hide unused segments
                        for i = #bones + 1, 15 do E.SKEL[i].Visible = false end
                    end
                else
                    for i = 1, 15 do E.SKEL[i].Visible = false end
                end

                -- [ IMPROVED SNAPLINES ]
                if E.SLINE then
                    local SL_CFG = ESP_CFG.Snaplines
                    if SL_CFG.Enabled and (vis or SL_CFG.OffScreen) and inDist then
                        local start_pos = Vector2.new(cam.ViewportSize.X / 2, 0)
                        local target_2d = Vector2.new(pos.X, pos.Y)

                        if not vis then
                            local center = cam.ViewportSize / 2
                            local dir = (target_2d - center).Unit
                            if pos.Z < 0 then dir = -dir end

                            local padding = 15
                            target_2d = Vector2.new(
                                math.clamp(center.X + (dir.X * 10000), padding, cam.ViewportSize.X - padding),
                                math.clamp(center.Y + (dir.Y * 10000), padding, cam.ViewportSize.Y - padding)
                            )
                        end

                        local diff               = target_2d - start_pos
                        local mag                = diff.Magnitude

                        E.SLINE.Visible          = true
                        E.SLINE.Size             = UDim2.new(0, SL_CFG.Thickness, 0, mag)
                        E.SLINE.Position         = UDim2.new(0, start_pos.X + (diff.X / 2), 0, start_pos.Y + (diff.Y / 2))
                        E.SLINE.Rotation         = math.deg(math.atan2(diff.Y, diff.X)) - 90
                        E.SLINE.BackgroundColor3 = SL_CFG.Color
                    else
                        E.SLINE.Visible = false
                    end
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
        return tool and tool.Parent and not tool.Parent:IsA("Backpack")
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
            Transparency = part.Transparency,
            LocalTransparencyModifier = part.LocalTransparencyModifier,
            SA = part:FindFirstChildOfClass("SurfaceAppearance")
        }
    end

    local function restorePart(part)
        local old = partCache[part]
        if not old or not part or not part.Parent then
            partCache[part] = nil
            return
        end
        part.Material = old.Material
        part.Color = old.Color
        part.Transparency = old.Transparency
        part.LocalTransparencyModifier = old.LocalTransparencyModifier
        if old.SA then
            old.SA.Parent = part
        end
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

        -- Ensure SurfaceAppearance doesn't block ForceField
        local sa = part:FindFirstChildOfClass("SurfaceAppearance")
        if sa then
            local data = partCache[part]
            if data then data.SA = sa end -- Cache it if found later
            sa.Parent = nil
        end

        local wave = (math.sin(t * ANIM_SPEED) + 1) * 0.5
        local wave2 = (math.sin((t * ANIM_SPEED * 1.7) + 1.3) + 1) * 0.5
        local transparency = TRANSPARENCY_MIN + (TRANSPARENCY_MAX - TRANSPARENCY_MIN) * wave
        local color = ESP_CFG.ToolCharms.Color1:Lerp(ESP_CFG.ToolCharms.Color2, wave2)

        part.Material = Enum.Material.ForceField
        part.Color = color
        part.Transparency = transparency
        part.LocalTransparencyModifier = 0
    end

    local function setupTool(tool)
        if not tool:IsA("Tool") or trackedTools[tool] then
            return
        end
        trackedTools[tool] = true

        local function _clean()
            restoreTool(tool)
            trackedTools[tool] = nil
        end

        tool.AncestryChanged:Connect(function(_, parent)
            if not parent then _clean() end
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
        if not character then return end
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

    local function handlePlayer(p)
        if not p then return end

        -- Hook existing tools in character
        if p.Character then hookCharacter(p.Character) end
        p.CharacterAdded:Connect(hookCharacter)

        -- Hook backpack
        local function _hookB(backpack)
            for _, obj in ipairs(backpack:GetChildren()) do
                if obj:IsA("Tool") then setupTool(obj) end
            end
            backpack.ChildAdded:Connect(function(obj)
                if obj:IsA("Tool") then setupTool(obj) end
            end)
        end

        local b = p:FindFirstChild("Backpack")
        if b then
            _hookB(b)
        end
        p.ChildAdded:Connect(function(obj)
            if obj:IsA("Backpack") then _hookB(obj) end
        end)
    end

    --====================================================
    -- START
    --====================================================
    for _, p in ipairs(PLRS:GetPlayers()) do
        handlePlayer(p)
    end
    PLRS.PlayerAdded:Connect(handlePlayer)

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
    if partName == "Random" then
        local validParts = {}
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                table.insert(validParts, v)
            end
        end
        if #validParts > 0 then
            return validParts[math.random(1, #validParts)]
        end
    end

    local part = char:FindFirstChild(partName or "Head")
    if part and part:IsA("BasePart") then return part end
    local fallbacks = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
    for _, name in ipairs(fallbacks) do
        local fb = char:FindFirstChild(name)
        if fb and fb:IsA("BasePart") then return fb end
    end
    return nil
end

local function VISIBLE_CHECK(targetPart)
    if not targetPart then return false end

    local camera = workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { camera, LPLR.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    -- Bypass __namecall to avoid infinite recursion
    local result = workspace.Raycast(workspace, origin, direction, params)

    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end

local function GET_SILENT_TARGET()
    local maxDist = _G.EXE.SILENT_AIM.FOV_Radius or 100
    local closestTarget = nil

    local ms = UIS:GetMouseLocation()
    local mousePos = Vector2.new(ms.X, ms.Y)

    local camera = workspace.CurrentCamera
    if not camera then return nil end

    for _, p in ipairs(PLRS:GetPlayers()) do
        if p ~= LPLR then
            local char = GET_CHAR(p)
            if IS_ALIVE(char) then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                        if dist < maxDist then
                            if _G.EXE.SILENT_AIM.WallCheck then
                                local targetPart = GET_TARGET_PART(char, _G.EXE.SILENT_AIM.Hitbox)
                                if VISIBLE_CHECK(targetPart) then
                                    closestTarget = p
                                    maxDist = dist
                                end
                            else
                                closestTarget = p
                                maxDist = dist
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- [ SILENT AIM / RAYCAST HOOKING ]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local method = getnamecallmethod()

    if method == "Raycast" and Self == workspace and _G.EXE and _G.EXE.SILENT_AIM and _G.EXE.SILENT_AIM.Enabled then
        local origin = select(1, ...)
        local oldDirection = select(2, ...)

        if typeof(origin) == "Vector3" and typeof(oldDirection) == "Vector3" then
            local target = GET_SILENT_TARGET()
            if target then
                local targetChar = GET_CHAR(target)
                local targetPart = GET_TARGET_PART(targetChar, _G.EXE.SILENT_AIM.Hitbox)

                if targetPart then
                    -- FastCast compatibility: Instead of bending the micro-ray, we cast a guaranteed hit on the target.
                    local params = select(3, ...)
                    local spoofOrigin = targetPart.Position + Vector3.new(0, 5, 0)
                    local spoofDirection = Vector3.new(0, -10, 0)

                    -- Avoid infinite recursion by bypassing namecall
                    local fakeHit = workspace.Raycast(workspace, spoofOrigin, spoofDirection, params)

                    if fakeHit and fakeHit.Instance:IsDescendantOf(targetChar) then
                        if setnamecallmethod then setnamecallmethod("Raycast") end
                        return fakeHit
                    end

                    -- Fallback if fake hit fails, just bend the ray as a last resort
                    local newDirection = (targetPart.Position - origin).Unit * oldDirection.Magnitude
                    if setnamecallmethod then setnamecallmethod("Raycast") end
                    return OldNamecall(Self, origin, newDirection, params)
                end
            end

            -- Restore method if GET_SILENT_TARGET() changed it and no target was found
            if setnamecallmethod then setnamecallmethod("Raycast") end
        end
    end

    return OldNamecall(Self, ...)
end)




-- [ PREVIOUS MODULE HOOKING REMOVED IN FAVOR OF DIRECT RAYCAST INTERCEPTION ]


-- [ FOV CIRCLE VISUALS ]
local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Thickness = 1
FOV_CIRCLE.Color = Color3.fromRGB(255, 255, 255)
FOV_CIRCLE.Filled = false
FOV_CIRCLE.Transparency = 1

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if _G.EXE and _G.EXE.SILENT_AIM and _G.EXE.SILENT_AIM.Enabled and _G.EXE.SILENT_AIM.ShowFOV then
        local ms = UIS:GetMouseLocation()
        FOV_CIRCLE.Position = Vector2.new(ms.X, ms.Y)
        FOV_CIRCLE.Radius = _G.EXE.SILENT_AIM.FOV_Radius or 100
        FOV_CIRCLE.Visible = true
    else
        FOV_CIRCLE.Visible = false
    end
end)

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
    FRM.Size = UDim2.new(1, -10, 0, 35)
    FRM.BackgroundColor3 = CFG.COL.BG
    FRM.BackgroundTransparency = 0.4
    RND(FRM, 8)
    STR(FRM, CFG.COL.ACC, 1).Transparency = 0.8
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
        local TGL = { VAL = DEF_TGL or false, CB = CB_TGL }
        table.insert(_G.EXE.ACTIVE_TOGGLES, TGL)

        local BTN = Instance.new("TextButton", RIGHT)
        BTN.Size = UDim2.new(0, 32, 0, 16)
        BTN.BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY
        BTN.Text = ""
        RND(BTN, 8)
        local IND = Instance.new("Frame", BTN)
        IND.Size = UDim2.new(0, 12, 0, 12)
        IND.Position = TGL.VAL and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        IND.BackgroundColor3 = Color3.new(1, 1, 1)
        RND(IND, 6)

        local function UPD_UI(dont_cb)
            TWN(BTN, { BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY }, 0.2)
            TWN(IND, { Position = TGL.VAL and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) }, 0.2)
            if TGL.CB and not dont_cb then TGL.CB(TGL.VAL) end
        end

        BTN.MouseButton1Click:Connect(function()
            TGL.VAL = not TGL.VAL
            UPD_UI()
        end)

        function TGL:SET(v, run_cb)
            self.VAL = v
            UPD_UI(not run_cb)
        end
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
SCR.DisplayOrder = 5000
SCR.IgnoreGuiInset = true
SCR.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Kill Switch Connection: Shutdown all active features when UI is destroyed
SCR.Destroying:Connect(function()
    if _G.EXE and _G.EXE.ACTIVE_TOGGLES then
        for _, tgl in ipairs(_G.EXE.ACTIVE_TOGGLES) do
            if tgl.VAL and not tgl.IsSetting then
                pcall(function() tgl:SET(false, true) end) -- Shutdown FORCED with callback running
            end
        end
    end
end)


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
    -- [ SECURITY CHECK ]
    repeat task.wait() until game.PlaceId ~= 0
    local curId = tostring(game.PlaceId)
    local ALLOWED = {
        ["121567535120062"] = true
    }

    if not ALLOWED[curId] then
        LPLR:Kick("Game Lock: Script locked. Please join game " .. TARGET_ID .. ". (Current: " .. curId .. ")")
        return
    end

    -- Progressive Loading: Show UI foundation immediately
    SCR.Parent = CORE


    -- [ TOGGLE HELPER ]
    local function ADD_TOG(PAG, TXT, DEF, CB, SM)
        local TGL = { VAL = DEF or false, CB = CB, IsSetting = SM }
        table.insert(_G.EXE.ACTIVE_TOGGLES, TGL)

        local ROW = Instance.new("Frame", PAG)
        ROW.Size = UDim2.new(1, -10, 0, 36)
        ROW.BackgroundTransparency = 1
        ROW.ZIndex = 8

        local LBL = Instance.new("TextLabel", ROW)
        LBL.Size = UDim2.new(1, -60, 1, 0)
        LBL.Position = UDim2.new(0, 0, 0, 0)
        LBL.BackgroundTransparency = 1
        LBL.Text = TXT
        LBL.TextColor3 = CFG.COL.TXT
        LBL.Font = Enum.Font.Gotham
        LBL.TextSize = 13
        LBL.TextXAlignment = Enum.TextXAlignment.Left
        LBL.ZIndex = 9

        -- Track pill
        local PILL = Instance.new("TextButton", ROW)
        PILL.Size = UDim2.new(0, 32, 0, 16)
        PILL.Position = UDim2.new(1, -38, 0.5, -8)
        PILL.BackgroundColor3 = TGL.VAL and CFG.COL.ACC or CFG.COL.GRY
        PILL.BorderSizePixel = 0
        PILL.Text = ""
        PILL.AutoButtonColor = false
        PILL.ZIndex = 9
        RND(PILL, 12)

        local PILL_STR = Instance.new("UIStroke", PILL)
        PILL_STR.Color = Color3.new(0, 0, 0)
        PILL_STR.Transparency = 0.3
        PILL_STR.Thickness = 1

        -- Knob
        local KNOB = Instance.new("Frame", PILL)
        KNOB.Size = UDim2.new(0, 12, 0, 12)
        KNOB.Position = TGL.VAL and UDim2.new(0, 18, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        KNOB.BackgroundColor3 = Color3.new(1, 1, 1)
        KNOB.BackgroundTransparency = 0
        KNOB.BorderSizePixel = 0
        KNOB.ZIndex = 10
        RND(KNOB, 9)

        local function UPD(dont_callback)
            local T = CFG.SPD or 0.2
            if TGL.VAL then
                TWN(PILL, { BackgroundColor3 = CFG.COL.ACC }, T)
                TWN(KNOB, { Position = UDim2.new(0, 18, 0.5, -6) }, T)
            else
                TWN(PILL, { BackgroundColor3 = CFG.COL.GRY }, T)
                TWN(KNOB, { Position = UDim2.new(0, 2, 0.5, -6) }, T)
            end
            if TGL.CB and not dont_callback then TGL.CB(TGL.VAL) end
        end

        PILL.MouseButton1Click:Connect(function()
            TGL.VAL = not TGL.VAL
            UPD()
        end)

        function TGL:SET(v, run_cb)
            self.VAL = v
            UPD(not run_cb)
        end

        TGL.ROW = ROW
        return TGL
    end

    -- [FARM SERVICES REMOVED]

    -- [ MAIN WINDOW ]
    local MAIN = Instance.new("Frame", SCR)
    MAIN.Name = "WIN"
    local safeSizeX = math.max(450, CurSizeX)
    local safeSizeY = math.max(300, CurSizeY)
    if UIS.TouchEnabled and not isfile("CTS_Config.json") then
        local vp = workspace.CurrentCamera.ViewportSize
        safeSizeX = math.max(450, vp.X * 0.6)
        safeSizeY = math.max(300, vp.Y * 0.6)
    end
    MAIN.Size = UDim2.new(0, safeSizeX, 0, safeSizeY)
    MAIN.Position = UDim2.new(0.5, -safeSizeX / 2, 0.5, -safeSizeY / 2)
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
    F_BRAND.Text = "Central Streets | WH01AM"
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
            local targetPos = UDim2.new(
                DG_POS.X.Scale, DG_POS.X.Offset + DEL.X,
                DG_POS.Y.Scale, DG_POS.Y.Offset + DEL.Y
            )
            if CurSmoothDrag then
                TS:Create(MAIN, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = targetPos
                }):Play()
            else
                MAIN.Position = targetPos
            end
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
    local B_MIN
    if not IS_MOBILE then
        B_MIN = MK_BTN(CFG.COL.YEL, UDim2.new(0, 35, 0.5, -7))
    end

    do
        local m = Instance.new("TextLabel", BAR)
        m.Name = "MIN_TITLE"
        m.Size = UDim2.new(1, -60, 1, 0)
        m.Position = UDim2.new(0, 60, 0, 0)
        m.BackgroundTransparency = 1
        m.Text = " Central Streets 🔫"
        m.TextColor3 = CFG.COL.TXT
        m.Font = Enum.Font.GothamBold
        m.TextSize = 13
        m.TextXAlignment = Enum.TextXAlignment.Left
        m.TextTransparency = 1
    end

    -- Weapon mods state — declared here so close handler can access it
    local WM               = { INF_AMMO = false, NO_RECOIL = false, RAPID_FIRE = false }
    local WM_RATE          = 0.01
    local infStaminaActive = false
    local antiCarHitActive = false
    local antiCarHitConn   = nil

    -- Movement state — declared here so close handler can access it
    _G.EXE.FLY_ON          = false
    _G.EXE.SPD_ON          = false
    _G.EXE.JMP_ON          = false

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

        -- 5. Turn off Weapon Mods & Modern Modules
        if WM then
            WM.INF_AMMO   = false
            WM.NO_RECOIL  = false
            WM.RAPID_FIRE = false
        end
        infStaminaActive = false
        antiCarHitActive = false
        if antiCarHitConn then
            pcall(function() antiCarHitConn:Disconnect() end)
            antiCarHitConn = nil
        end
        if _G.EXE.GUN_MODS then
            for k, _ in pairs(_G.EXE.GUN_MODS) do _G.EXE.GUN_MODS[k] = false end
        end
        if _G.EXE.SECURITY then
            for k, _ in pairs(_G.EXE.SECURITY) do _G.EXE.SECURITY[k] = false end
        end
        if _G.EXE.AS_TGL_OBJ then
            pcall(function() _G.EXE.AS_TGL_OBJ:SET(false, true) end)
        end
        if _G.EXE.FarmEnabled ~= nil then _G.EXE.FarmEnabled = false end

        -- 6. Disconnect Keybinds
        if _G.CEN_BINDS then
            for _, c in ipairs(_G.CEN_BINDS) do
                if c then pcall(function() c:Disconnect() end) end
            end
            _G.CEN_BINDS = nil
        end

        _G.CENTRAL_LOADED = false
    end

    -- [ WEAPON MODS LOOP - OPTIMIZED ]
    local CACHED_GUN_DATA = nil
    local lastScan = 0
    local shotsFired = 0
    LPLR.CharacterAdded:Connect(function()
        CACHED_GUN_DATA = nil; shotsFired = 0
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if WM.INF_AMMO or WM.NO_RECOIL or WM.NO_SPREAD or WM.RAPID_FIRE then
                pcall(function()
                    local char = LPLR.Character
                    local hasTool = char and char:FindFirstChildWhichIsA("Tool")

                    -- ONLY process if player actually has a tool out
                    if not hasTool then
                        CACHED_GUN_DATA = nil
                        shotsFired = 0
                        return
                    end

                    -- Check if cache is still valid (must have _currentGunMetadata and _equippedGun)
                    local valid = CACHED_GUN_DATA and type(CACHED_GUN_DATA) == "table"
                        and rawget(CACHED_GUN_DATA, "_currentGunMetadata")
                        and rawget(CACHED_GUN_DATA, "_equippedGun")

                    if valid then
                        local meta = CACHED_GUN_DATA._currentGunMetadata

                        -- Infinite Ammo (Silent Reload Sync)
                        if WM.INF_AMMO then
                            local maxMag = meta.MagMax or 30
                            local current = meta.InMag or maxMag
                            if current < maxMag then
                                local diff = maxMag - current
                                shotsFired = shotsFired + diff
                                meta.InMag = maxMag
                            end
                            if shotsFired >= 10 then
                                shotsFired = 0
                                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                local rel = remotes and remotes:FindFirstChild("ReloadComplete")
                                if rel then
                                    pcall(function()
                                        local gunName = meta.Name or CACHED_GUN_DATA._equippedGun.Name
                                        if gunName then
                                            rel:FireServer(gunName)
                                        end
                                    end)
                                end
                            end
                        end

                        -- No Recoil
                        if WM.NO_RECOIL and meta.Recoil and type(meta.Recoil) == "table" then
                            meta.Recoil.Magnitude, meta.Recoil.Roughness, meta.Recoil.PositionInfluence = 0, 0, 0
                        end

                        -- No Spread
                        if WM.NO_SPREAD then meta.BulletSpreadValue = 0 end

                        -- Rapid Fire
                        if WM.RAPID_FIRE then
                            meta.FireMode, meta.FireRate = "Auto", 0.08
                        end

                        -- Jam Prevention
                        if meta.JamChance then meta.JamChance = 0 end
                    else
                        -- Cache invalid, scan GC throttled
                        local now = os.clock()
                        if now - lastScan > 1.5 then
                            lastScan = now
                            for _, v in ipairs(getgc(true)) do
                                if type(v) == "table" and rawget(v, "_currentGunMetadata") and rawget(v, "_equippedGun") then
                                    CACHED_GUN_DATA = v
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- [ INFINITE STAMINA LOOP ]
    local CharacterMovement = nil
    task.spawn(function()
        while task.wait(0.3) do
            if infStaminaActive then
                pcall(function()
                    if not CharacterMovement then
                        local framework = game:GetService("ReplicatedStorage"):FindFirstChild("Framework")
                        local client = framework and framework:FindFirstChild("Client")
                        local charMov = client and client:FindFirstChild("CharacterMovement")
                        if charMov then
                            CharacterMovement = require(charMov)
                        end
                    end
                    if CharacterMovement and CharacterMovement.Variables then
                        CharacterMovement.Variables.SprintAmount = 200
                    end
                end)
            end
        end
    end)

    -- [ ANTI CAR HIT LOOP ]
    local cachedCars = {}
    task.spawn(function()
        while task.wait(1) do
            if not _G.CENTRAL_LOADED then break end
            local newCache = {}
            local carsFolder = workspace:FindFirstChild("Cars")
            if carsFolder then
                for _, car in ipairs(carsFolder:GetChildren()) do
                    if car:IsA("Model") then
                        table.insert(newCache, car)
                    end
                end
            end
            cachedCars = newCache
        end
    end)

    antiCarHitConn = RS.Stepped:Connect(function()
        if not _G.CENTRAL_LOADED then
            if antiCarHitConn then antiCarHitConn:Disconnect() end
            return
        end
        if antiCarHitActive then
            local char = LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local myCar = hum and hum.SeatPart and hum.SeatPart:FindFirstAncestorWhichIsA("Model")

            for _, car in ipairs(cachedCars) do
                if car.Parent and car ~= myCar then
                    for _, part in ipairs(car:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.CanTouch = false
                        end
                    end
                end
            end
        end
    end)

    -- Close
    B_CLS.MouseButton1Click:Connect(function()
        PANIC()
        SCR:Destroy()
    end)

    -- Minimize
    local IS_MIN  = false
    local MIN_DEB = false
    local OLD_SZ  = UDim2.new(0, 0, 0, 0)

    if B_MIN then
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
    end

    -- [ TAB BAR ]
    local TCON = Instance.new("ScrollingFrame", MAIN)
    TCON.Name = "TABS"
    TCON.Size = UDim2.new(1, -140, 0, 35)
    TCON.Position = UDim2.new(0.5, 0, 0, 10)
    TCON.AnchorPoint = Vector2.new(0.5, 0)
    TCON.BackgroundColor3 = CFG.COL.BG
    TCON.BackgroundTransparency = 0.4
    TCON.ZIndex = 10
    TCON.BorderSizePixel = 0
    TCON.ScrollBarThickness = 0
    TCON.CanvasSize = UDim2.new(0, 0, 0, 0)
    TCON.AutomaticCanvasSize = Enum.AutomaticSize.X
    TCON.ScrollingDirection = Enum.ScrollingDirection.X
    TCON.ClipsDescendants = true
    RND(TCON, 20)
    STR(TCON, CFG.COL.ACC, 1).Transparency = 0.8

    local TLAY = Instance.new("UIListLayout", TCON)
    TLAY.FillDirection = Enum.FillDirection.Horizontal
    TLAY.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TLAY.VerticalAlignment = Enum.VerticalAlignment.Center
    TLAY.Padding = UDim.new(0, 8)

    -- [ PAGE CONTAINER ]
    local PCON = Instance.new("Frame", MAIN)
    PCON.Name = "PGS"
    PCON.Size = UDim2.new(1, -20, 1, -85) -- Reducido de -60 para no pisar el footer
    PCON.Position = UDim2.new(0, 10, 0, 55)
    PCON.BackgroundTransparency = 1
    PCON.ClipsDescendants = true
    PCON.ZIndex = 5

    local CUR_BTN = nil
    local CUR_PAG = nil

    local function UPDATE_TAB_VISUALS(btn, isActive)
        local isSidebar = CurSidebarTabs
        local lbl1 = btn:FindFirstChild("TitleLabel")
        local lbl2 = btn:FindFirstChild("DescLabel")
        local ind = btn:FindFirstChild("Ind")
        local bstroke = btn:FindFirstChild("BorderStroke")
        local uicorner = btn:FindFirstChildWhichIsA("UICorner")

        if isSidebar then
            btn.Text = ""
            if lbl1 then lbl1.Visible = true end
            if lbl2 then lbl2.Visible = true end
            if bstroke then bstroke.Enabled = true end
            if uicorner then uicorner.CornerRadius = UDim.new(0, 4) end

            if isActive then
                if ind then ind.Visible = true end
                TWN(btn, { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BackgroundTransparency = 0.4 }, 0.15)
                if bstroke then TWN(bstroke, { Transparency = 0 }, 0.15) end
                if lbl1 then TWN(lbl1, { TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15) end
            else
                if ind then ind.Visible = false end
                TWN(btn, { BackgroundTransparency = 1 }, 0.15)
                if bstroke then TWN(bstroke, { Transparency = 1 }, 0.15) end
                if lbl1 then TWN(lbl1, { TextColor3 = Color3.fromRGB(140, 140, 140) }, 0.15) end
            end
        else
            btn.Text = btn:GetAttribute("TabName") or ""
            if lbl1 then lbl1.Visible = false end
            if lbl2 then lbl2.Visible = false end
            if ind then ind.Visible = false end
            if bstroke then bstroke.Enabled = false end
            if uicorner then uicorner.CornerRadius = UDim.new(0, 12) end

            if isActive then
                TWN(btn, {
                    TextColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 0.4,
                    BackgroundColor3 = CFG.COL.ACC
                }, 0.15)
            else
                TWN(btn, {
                    TextColor3 = CFG.COL.GRY,
                    BackgroundTransparency = 1
                }, 0.15)
            end
        end
    end

    REF_UPDATE_TABS = function()
        for _, child in ipairs(TCON:GetChildren()) do
            if child:IsA("TextButton") then
                UPDATE_TAB_VISUALS(child, (CUR_BTN == child))
            end
        end
    end

    local function UPDATE_SIDEBAR_MODE(isOn)
        local tconPadding = TCON:FindFirstChild("TCON_Padding")
        if isOn then
            MAIN.ClipsDescendants = false
            TCON.ScrollingDirection = Enum.ScrollingDirection.Y
            TCON.AutomaticCanvasSize = Enum.AutomaticSize.Y
            TWN(TCON, {
                Size = UDim2.new(0, 160, 1, 0),
                Position = UDim2.new(0, -15, 0, 0),
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromRGB(10, 10, 12)
            })
            TCON.AnchorPoint = Vector2.new(1, 0)
            TLAY.FillDirection = Enum.FillDirection.Vertical
            TLAY.Padding = UDim.new(0, 6)
            TLAY.HorizontalAlignment = Enum.HorizontalAlignment.Center
            TLAY.VerticalAlignment = Enum.VerticalAlignment.Top

            local corner = TCON:FindFirstChildOfClass("UICorner")
            if corner then corner.CornerRadius = UDim.new(0, 12) end

            if not tconPadding then
                tconPadding = Instance.new("UIPadding", TCON)
                tconPadding.Name = "TCON_Padding"
            end
            tconPadding.PaddingTop = UDim.new(0, 12)
            tconPadding.PaddingBottom = UDim.new(0, 12)
            tconPadding.PaddingLeft = UDim.new(0, 8)
            tconPadding.PaddingRight = UDim.new(0, 8)

            TWN(PCON, { Size = UDim2.new(1, -20, 1, -85), Position = UDim2.new(0, 10, 0, 55) })

            for _, child in ipairs(TCON:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(1, 0, 0, 46)
                    local pad = child:FindFirstChild("UIPadding")
                    if pad then pad:Destroy() end
                    UPDATE_TAB_VISUALS(child, (CUR_BTN == child))
                end
            end
        else
            TCON.ScrollingDirection = Enum.ScrollingDirection.X
            TCON.AutomaticCanvasSize = Enum.AutomaticSize.X
            TWN(TCON, {
                Size = UDim2.new(1, -140, 0, 35),
                Position = UDim2.new(0.5, 0, 0, 10),
                BackgroundTransparency = 0.4,
                BackgroundColor3 = CFG.COL.BG
            })
            TCON.AnchorPoint = Vector2.new(0.5, 0)
            TLAY.FillDirection = Enum.FillDirection.Horizontal
            TLAY.Padding = UDim.new(0, 8)
            TLAY.HorizontalAlignment = Enum.HorizontalAlignment.Left
            TLAY.VerticalAlignment = Enum.VerticalAlignment.Center

            local corner = TCON:FindFirstChildOfClass("UICorner")
            if corner then corner.CornerRadius = UDim.new(0, 20) end

            if not tconPadding then
                tconPadding = Instance.new("UIPadding", TCON)
                tconPadding.Name = "TCON_Padding"
            end
            tconPadding.PaddingTop = UDim.new(0, 0)
            tconPadding.PaddingBottom = UDim.new(0, 0)
            tconPadding.PaddingLeft = UDim.new(0, 10)
            tconPadding.PaddingRight = UDim.new(0, 10)

            TWN(PCON, { Size = UDim2.new(1, -20, 1, -85), Position = UDim2.new(0, 10, 0, 55) })

            for _, child in ipairs(TCON:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(0.166, -11, 0.8, 0)
                    local pad = child:FindFirstChild("UIPadding")
                    if pad then pad:Destroy() end
                    UPDATE_TAB_VISUALS(child, (CUR_BTN == child))
                end
            end
            task.delay(0.3, function()
                if not CurSidebarTabs then
                    MAIN.ClipsDescendants = true
                end
            end)
        end
    end

    local function MK_TAB(TXT, SUB)
        local BTN = Instance.new("TextButton", TCON)
        BTN.Size = UDim2.new(0.166, -11, 0.8, 0)
        BTN.BackgroundTransparency = 1
        BTN.Text = TXT
        BTN.TextColor3 = CFG.COL.GRY
        BTN.Font = Enum.Font.GothamBold
        BTN.TextScaled = true
        BTN.TextWrapped = true
        BTN.AutoButtonColor = false
        BTN:SetAttribute("TabName", TXT)
        BTN.ZIndex = 11
        RND(BTN, 12)

        local TSC                   = Instance.new("UITextSizeConstraint", BTN)
        TSC.MaxTextSize             = 12
        TSC.MinTextSize             = 8

        local bstroke               = Instance.new("UIStroke", BTN)
        bstroke.Name                = "BorderStroke"
        bstroke.Color               = Color3.fromRGB(45, 45, 45)
        bstroke.Thickness           = 1
        bstroke.Transparency        = 1
        bstroke.Enabled             = false

        local lbl1                  = Instance.new("TextLabel", BTN)
        lbl1.Name                   = "TitleLabel"
        lbl1.Size                   = UDim2.new(1, -30, 0, 20)
        lbl1.Position               = UDim2.new(0, 16, 0, 6)
        lbl1.BackgroundTransparency = 1
        lbl1.Text                   = TXT
        lbl1.TextColor3             = Color3.fromRGB(140, 140, 140)
        lbl1.Font                   = Enum.Font.GothamBold
        lbl1.TextSize               = 13
        lbl1.TextXAlignment         = Enum.TextXAlignment.Left
        lbl1.Visible                = false
        lbl1.ZIndex                 = 12

        local lbl2                  = Instance.new("TextLabel", BTN)
        lbl2.Name                   = "DescLabel"
        lbl2.Size                   = UDim2.new(1, -30, 0, 14)
        lbl2.Position               = UDim2.new(0, 16, 0, 24)
        lbl2.BackgroundTransparency = 1
        lbl2.Text                   = SUB or ""
        lbl2.TextColor3             = Color3.fromRGB(90, 90, 90)
        lbl2.Font                   = Enum.Font.Gotham
        lbl2.TextSize               = 10
        lbl2.TextXAlignment         = Enum.TextXAlignment.Left
        lbl2.Visible                = false
        lbl2.ZIndex                 = 12

        local ind                   = Instance.new("Frame", BTN)
        ind.Name                    = "Ind"
        ind.Size                    = UDim2.new(0, 3, 0, 22)
        ind.Position                = UDim2.new(1, -3, 0.5, -11)
        ind.BackgroundColor3        = CFG.COL.ACC
        ind.BorderSizePixel         = 0
        ind.Visible                 = false
        ind.ZIndex                  = 12

        local PAG                   = Instance.new("ScrollingFrame", PCON)
        PAG.Size                    = UDim2.new(1, 0, 1, 0)
        PAG.BackgroundTransparency  = 1
        PAG.BorderSizePixel         = 0
        PAG.Visible                 = false
        PAG.ScrollBarThickness      = 2
        PAG.ScrollBarImageColor3    = CFG.COL.ACC
        PAG.AutomaticCanvasSize     = Enum.AutomaticSize.Y
        PAG.ZIndex                  = 6

        local LST                   = Instance.new("UIListLayout", PAG)
        LST.Padding                 = UDim.new(0, 8)
        LST.HorizontalAlignment     = Enum.HorizontalAlignment.Center
        LST.SortOrder               = Enum.SortOrder.LayoutOrder

        local PAD                   = Instance.new("UIPadding", PAG)
        PAD.PaddingTop              = UDim.new(0, 5)
        PAD.PaddingLeft             = UDim.new(0, 5)
        PAD.PaddingRight            = UDim.new(0, 5)
        PAD.PaddingBottom           = UDim.new(0, 20)

        BTN.MouseEnter:Connect(function()
            if CurSidebarTabs and CUR_BTN ~= BTN then
                TWN(lbl1, { TextColor3 = Color3.fromRGB(200, 200, 200) }, 0.12)
            end
        end)

        BTN.MouseLeave:Connect(function()
            if CurSidebarTabs and CUR_BTN ~= BTN then
                TWN(lbl1, { TextColor3 = Color3.fromRGB(140, 140, 140) }, 0.12)
            end
        end)

        BTN.MouseButton1Click:Connect(function()
            if CUR_BTN == BTN then return end

            local prev_btn = CUR_BTN
            CUR_BTN = BTN

            if CUR_PAG then
                CUR_PAG.Visible = false
            end
            CUR_PAG = PAG

            if prev_btn then
                UPDATE_TAB_VISUALS(prev_btn, false)
            end
            UPDATE_TAB_VISUALS(BTN, true)

            PAG.Visible = true
            PAG.Position = UDim2.new(0, 10, 0, 0)
            TWN(PAG, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)
        end)

        return PAG, BTN
    end

    -- [ TABS ]
    local P_HOM, B_HOM = MK_TAB("HOME", "Teleports & Actions")
    local P_FRM, B_FRM = MK_TAB("FARM", "Automated Farms")
    local P_VIS, B_VIS = MK_TAB("VISUAL", "ESP & Silent Aim")
    local P_MSC, B_MSC = MK_TAB("MISC", "Movement & Tools")
    local P_OTH, B_OTH = MK_TAB("OTHERS", "Other Features")
    local P_SET, B_SET = MK_TAB("SETTINGS", "Settings & Themes")
    UPDATE_SIDEBAR_MODE(CurSidebarTabs)
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

        local C_TP = MK_CARD(TL, "Teleportation", "rbxassetid://102084991489439")

        local LOCS = {
            ["🔫 Gun Store 1"] = Vector3.new(-35521.61, 255.27, 197.68),
            ["🔫 Gun Store 2"] = Vector3.new(-55.53, 79.67, -140.54),
            ["🔫 Gun Store 3"] = Vector3.new(-723.45, 63.97, -256.19),
            ["🧊 Ice Box"] = Vector3.new(206.24, 90.44, 143.81),
            ["👕 Clothes Store"] = Vector3.new(112.59, 90.44, -38.02),
            ["✂️ Barber"] = Vector3.new(60.78, 90.36, -49.71),
            ["🛍️ Frank Shop"] = Vector3.new(4.82, 90.69, -61.26),
            ["🛍️ Travis Shop"] = Vector3.new(-63.01, 90.51, -51.03),
            ["👮 Police Station"] = Vector3.new(422.40, 92.33, -83.51),
            ["🔫 Pawn Shop"] = Vector3.new(200.49, 91.04, -34.77),
            ["⛽ Gas Station 1"] = Vector3.new(-31.96, 90.34, 282.72),
            ["⛽ Gas Station 2"] = Vector3.new(-542.33, 49.77, -360.66),
            ["🚗 Car Customization"] = Vector3.new(-163.45, 89.91, -151.01),
            ["🏬 Supply Store"] = Vector3.new(-449.18, 51.17, 397.83),
            ["💣 Black Market"] = Vector3.new(-751, 45, 545),
            ["🧧 HitMan"] = Vector3.new(-1338.14, 49.78, 433.75),
            ["🗑️ Sell Trash"] = Vector3.new(-39, 90, -10),
            ["🏬 Apartments"] = Vector3.new(747.67, 89.74, -376.21),
            ["💰 Bank Supply"] = Vector3.new(998.59, 231.32, -498.92),
            ["🐶 Pet Shop"] = Vector3.new(1254.51, 135.42, -557.29),
            ["🍔 McDonalds"] = Vector3.new(963.17, 129.91, 87.37),
            ["🍟 Sell Fries"] = Vector3.new(815.84, 90.67, 574.74),
            ["🏨 Hotel 1"] = Vector3.new(1000, 259, 441),
            ["🏨 Hotel 2"] = Vector3.new(163.99, 160.88, 439.33),
            ["👟 Shoes Store"] = Vector3.new(-278.27, 89.74, 504.62),
            ["🖨️ Sell Printers Pdt"] = Vector3.new(91.03, 132.07, 531.69),
            ["🛍️ Zay"] = Vector3.new(-603.45, 50.73, 584.89),
            ["🧽 Laundromat"] = Vector3.new(-59, 90, 391),
            ["🚗 Car Dealer"] = Vector3.new(433.44, 89.62, -376.54),
            ["🖋️ Tattoo Shop"] = Vector3.new(983.79, 131.01, -99.94),
            ["🌃 Club"] = Vector3.new(-440.48, 50.59, 179.16),
            ["🌱 Sell Weed"] = Vector3.new(754.89, 228.03, -125.40),
            ["🥖 Chop Shop"] = Vector3.new(237.53, 100.73, 2638.97),
            ["🌱 Grow Job"] = Vector3.new(1532.60, 89.79, 2672.12),
            ["💰 Bank"] = Vector3.new(192.66, 89.62, -175.13),
            ["🎙️ Radar"] = Vector3.new(-35777.34, 17.82, -269.59),
            ["🎒 Backpack"] = Vector3.new(-184.99, 89.89, 276.40),
            ["🛍️ Neo Shop"] = Vector3.new(653.68, 89.84, 243.68),
            ["🔫 Gamepass Guns"] = Vector3.new(-166.85, 105.43, -198.16),
            ["📦 Packaging"] = Vector3.new(-2369.71, 50.57, 653.50),
            ["🥤 Juice Job"] = Vector3.new(-2276.70, 49.72, 1338.95)
        }

        local L_NAMES = {}
        for k, _ in pairs(LOCS) do table.insert(L_NAMES, k) end
        table.sort(L_NAMES)

        local D_LOC
        D_LOC = ADD_DRP(C_TP, "Select Location", function(v)
            local pos = LOCS[v]
            if pos then
                BYPASS_TP(pos)
                NOTIFY("Teleport", "Teleported to " .. v, 2)
            end
            task.delay(1.5, function()
                if D_LOC then D_LOC:RESET() end
            end)
        end)
        D_LOC:REFRESH(L_NAMES)

        local D_PLR
        D_PLR = ADD_DRP(C_TP, "Teleport to Player", function(v)
            local target = game:GetService("Players"):FindFirstChild(v)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LPLR.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                NOTIFY("Teleport", "Teleported to " .. v, 2)
            else
                NOTIFY("Teleport", "Player " .. v .. " not found or dead!", 3)
            end
            task.delay(1.5, function()
                if D_PLR then D_PLR:RESET() end
            end)
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

        local items = {
            "--[ AMMOS ]--",
            "DoubleDrum", "Slugs", "9mm", "5.56", "7.62x39mm", "Bullets", "Drum",
            "--[ STORE ITEMS ]--",
            "Black Balaclava", "Blue Balaclava", "Red Balaclava", "White Balaclava",
            "Drank", "Spraypaint", "Cubes", "B&R Ski", "Blue Ski", "White Pink Ski",
            "Sub", "Chips", "Candy", "Pizza", "Soda", "Water"
        }

        local SelectedItem = nil
        local SelectedQty = 1

        local D_ITEM = ADD_DRP(C_STORE, "Choose Item", function(v)
            if v:find("%-%-%[") then
                SelectedItem = nil
                NOTIFY("Store", "Please select a valid item!", 2)
            else
                SelectedItem = v
            end
        end)
        D_ITEM.REFRESH(items)

        local D_QTY = ADD_DRP(C_STORE, "Qty: 1", function(v)
            SelectedQty = tonumber(v) or 1
        end)
        local q_list = {}
        for i = 1, 20 do table.insert(q_list, tostring(i)) end
        D_QTY.REFRESH(q_list)

        ADD_BTN(C_STORE, "Purchase", function()
            if SelectedItem then
                local Event = game:GetService("ReplicatedStorage").Events.ServerEvent
                Event:FireServer("BuyItemTool", SelectedItem, nil, SelectedQty)
                NOTIFY("Store", "Purchasing " .. SelectedQty .. "x " .. SelectedItem, 2)
            else
                NOTIFY("Store", "Select an item first!", 2)
            end
        end)

        -- [ ROLLBACK DUPE CARD ]
        local C_ROLLBACK = MK_CARD(TL, "Rollback Dupe", "rbxassetid://87411082578223")

        local HAS_ROLLBACK = false
        ADD_BTN(C_ROLLBACK, "Rollback Dupe", function()
            if HAS_ROLLBACK then
                NOTIFY("Rollback", "You can only use Rollback Dupe \n once per server.", 3)
                return
            end
            HAS_ROLLBACK = true

            local Event = game:GetService("ReplicatedStorage").Remotes.SaveSelectedEmote
            Event:FireServer(
                "Pistol",
                "\xFF"
            )
            NOTIFY("Rollback", "Rollback Dupe executed.", 3)
        end)

        local R_LBL = ADD_LBL(C_ROLLBACK,
            "1. Execute Rollback Dupe\n2. Drop or spend money\n3. You can dupe guns too!\n4. If you rejoin and an error happens, just click leave and rejoin")
        R_LBL.Size = UDim2.new(1, -10, 0, 100)
        R_LBL.TextColor3 = Color3.fromRGB(200, 200, 200)
        R_LBL.TextSize = 13
        R_LBL.TextYAlignment = Enum.TextYAlignment.Top

        -- [ GUNS CARD ]
        local C_GUNS = MK_CARD(TR, "Guns", "rbxassetid://140547169969789")

        local SelectedGun = nil
        local g_list = {
            "--[ PISTOLS ]--",
            "Hellcat XD | $7,120", "G24 Competition | $3,750", "G20 Grip SilverBack | $6,799",
            "Kimber 45. Flash | $2,950", "PSA ROCK 5.7 | $2,750", "G41 MOS Kriss | $7,650", "Ruger LCP | $800",
            "G27 Extended | $4,350", "Glock 36 | $3,865", "P80 Mos Beam | $4,950", "SS MR920P | $4,350",
            "P80 Extended | $4,750", "G48 PerformanceTrigger | $4,350", "Engraved Colt .38 Super | $6,850",
            "Canik MC9 Prime | $4,999", "38. Smith&Wesson | $750", "G43X | $3,450", "G22 Compensated | $7,850",
            "FNXBeam | $4,799", "S&W M2.0 Clearmag | $4,355", "Matchmaster 1911 | $3,100", "Springfield Echelon | $3,470",
            "Springfield Hellcat | $6,549", "G19XPSAGrip | $5,350", "Glock-17 | $1,350", "G40VectMag | $4,950",
            "Python | $600", "G31C | $6,499", "Glock19x Extended | $4,450", "G26 | $1,250", "G17Gen5Vect | $3,850",
            "G23Gen4 Extended | $3,650",
            "--[ RIFLES ]--",
            "AR556 GreenTip | $13,500", "308ARP | $9,475", "KelTec Sub2000 | $11,500", "Scoped 762 Micro | $12,150",
            "Vepr 12 Defender | $9,850", "Tan Arp | $8,150", "556Rifle | $10,420", "SIGMCX | $9,250", "AK74 | $9,300",
            "Micro KS47 | $7,350", "223Mini | $8,950", "300BlackOut | $7,350", "Kriss Alpine Gen II | $7,890",
            "M16A2 | $7,500", "BlackMiniDrac | $8,750", "GFR AR10 | $12,899", "ZPAP 762 | $9,500",
            "SLIMEBALL762 | $10,645", "AR-223 | $10,200", "Colt 723 | $12,450", "BCM4 | $12,360", "PLR-16 | $8,500",
            "--[ MELEES ]--",
            "Pocket Knife | $55", "lucille | $1,299", "Kitchen Knife | $85",
            "--[ CUSTOMS ]--",
            "G2C Flash Drum | $8,800", "P320XDrumFlash | $8,215", "G22Drum | $7,515", "FDEPLR100Rnd | $12,550",
            "223 Drum | $13,000", "G27 Drum | $7,650", "50rnd Gen5 | $5,899", "NAK9Drum | $14,600", "G17L Drum | $8,500",
            "G20DrumFlash | $7,549", "PSA ARP 100rnd | $15,500", "100rnd N4 | $14,500", "G19DrumFlash | $8,900",
            "G19Gen5Drum | $7,500", "ARP 100 Rnd | $13,500", "PLR-16Drum | $10,500"
        }

        local D_GUN = ADD_DRP(C_GUNS, "Select Gun", function(v)
            if v:find("%-%-%[") then
                SelectedGun = nil
                NOTIFY("Guns", "Select a valid weapon!", 2)
            else
                SelectedGun = v:split(" | ")[1]
                local Event = game:GetService("ReplicatedStorage").Events.ServerEvent
                Event:FireServer("BuyItemTool", SelectedGun)
                NOTIFY("Guns", "Purchasing " .. SelectedGun, 2)
            end
        end)
        D_GUN.REFRESH(g_list)

        local D_MODS = ADD_DRP(C_GUNS, "Gun Mods")

        local function STYLE_MOD(tgl)
            if tgl and tgl.FRM then
                tgl.FRM.BackgroundTransparency = 1
                tgl.FRM.ZIndex = 10
                local str = tgl.FRM:FindFirstChildOfClass("UIStroke")
                if str then str:Destroy() end

                local lbl = tgl.FRM:FindFirstChildOfClass("TextLabel")
                if lbl then
                    lbl.TextColor3 = Color3.new(1, 1, 1)
                    lbl.ZIndex = 11
                end

                local btn = tgl.FRM:FindFirstChildOfClass("TextButton")
                if btn then
                    btn.ZIndex = 12
                    btn.BackgroundTransparency = 0
                    local ind = btn:FindFirstChildOfClass("Frame")
                    if ind then ind.ZIndex = 13 end
                end
            end
        end

        STYLE_MOD(ADD_TGL(D_MODS.SCR, "Infinite Ammo", WM.INF_AMMO, function(v)
            WM.INF_AMMO = v
            NOTIFY("GUN MODS", "Infinite Ammo: " .. (v and "ON" or "OFF"), 1.5)
        end))
        STYLE_MOD(ADD_TGL(D_MODS.SCR, "No Recoil", WM.NO_RECOIL, function(v)
            WM.NO_RECOIL = v
            NOTIFY("GUN MODS", "No Recoil: " .. (v and "ON" or "OFF"), 1.5)
        end))
        STYLE_MOD(ADD_TGL(D_MODS.SCR, "No Spread", WM.NO_SPREAD, function(v)
            WM.NO_SPREAD = v
            NOTIFY("GUN MODS", "No Spread: " .. (v and "ON" or "OFF"), 1.5)
        end))
        STYLE_MOD(ADD_TGL(D_MODS.SCR, "Rapid Fire", WM.RAPID_FIRE, function(v)
            WM.RAPID_FIRE = v
            NOTIFY("GUN MODS", "Rapid Fire: " .. (v and "ON" or "OFF"), 1.5)
        end))

        -- [ ACTIONS CARD ]
        local C_ACTIONS = MK_CARD(TR, "Actions", "rbxassetid://87411082578223")

        local function REJOIN()
            pcall(function()
                local ts = game:GetService("TeleportService")
                ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LPLR)
            end)
        end

        local GEN_RUNNING = false
        local L_GEN_BTN = ADD_BTN(C_ACTIONS, "Money gen: OFF", function(bt)
            if GEN_RUNNING then return end

            -- Auto Minimize UI
            MAIN.Visible = false
            NOTIFY("GEN", "Money Gen: UI Minimized for farming.", 2)

            local function cleanM(s) return tonumber((s:gsub("%D", ""))) or 0 end
            local curMoneyStr = LPLR.PlayerGui.MainScreen.Profile.CashAmount.Text
            if cleanM(curMoneyStr) >= 5000000 then
                NOTIFY("Money Gen", "You have $5M+. Spend it before using again!", 5)
                return
            end

            GEN_RUNNING = true
            bt.Text = "Money gen: RUNNING"

            local startMoney = cleanM(curMoneyStr)
            local startPos = LPLR.Character.HumanoidRootPart.CFrame

            -- Mute per user request
            local oldVols = {}
            local function mute(v)
                if v:IsA("Sound") and not oldVols[v] then
                    oldVols[v] = v.Volume
                    v.Volume = 0
                end
            end
            local muteConn1 = game.DescendantAdded:Connect(mute)
            for _, v in pairs(game:GetDescendants()) do pcall(mute, v) end

            -- UI Overlay
            local OVR = Instance.new("ScreenGui", CORE)
            OVR.DisplayOrder = 999999
            OVR.IgnoreGuiInset = true

            local BLACK = Instance.new("Frame", OVR)
            BLACK.Size = UDim2.new(1, 0, 1, 0)
            BLACK.BackgroundColor3 = Color3.new(0, 0, 0)
            BLACK.ZIndex = 1

            local IMG = Instance.new("ImageLabel", OVR)
            IMG.Size = UDim2.new(1, 0, 1, 0)
            IMG.Image = "rbxassetid://72647550241860"
            IMG.BackgroundTransparency = 1
            IMG.ZIndex = 2
            IMG.ScaleType = Enum.ScaleType.Crop

            task.wait(1)

            -- Farm Logic (Legacy spam for the crash effect)
            BYPASS_TP(Vector3.new(1, 92, -68))
            task.wait(0.5)

            local Event = game:GetService("ReplicatedStorage").Events.ServerEvent
            Event:FireServer("RobNPC", "Gio's Shop")

            local activated = false
            local sTime = tick()
            while tick() - sTime < 11 do
                pcall(function()
                    local bag = workspace.Map.NPC:FindFirstChild("Gio's Shop")
                    bag = bag and bag:FindFirstChild("BagPosition")
                    bag = bag and bag:FindFirstChild("MoneyBag")
                    local prompt = bag and bag:FindFirstChild("ProximityPrompt")

                    if prompt then
                        activated = true
                        for _ = 1, 3500 do -- Increased spam for the crash
                            task.spawn(function()
                                pcall(fireproximityprompt, prompt)
                            end)
                        end
                    end
                end)
                if activated then break end
                task.wait(0.2)
            end

            if activated then
                NOTIFY("MONEY GEN", "successful. Collecting money...", 4)
                task.wait(8) -- Wait for server to process cash
            else
                NOTIFY("MONEY GEN", "Failed to start money generation!", 4)
            end

            -- Return to start position & cleanup
            BYPASS_TP(startPos.Position)
            LPLR.Character.HumanoidRootPart.CFrame = startPos
            task.wait(2)
            OVR:Destroy()
            if muteConn1 then muteConn1:Disconnect() end
            pcall(function()
                for s, v in pairs(oldVols) do if s.Parent then s.Volume = v end end
            end)
            bt.Text = "Money gen: OFF"
            GEN_RUNNING = false
        end)

        -- [[ SERVER UTILITIES ]]
        local function ServerHop()
            NOTIFY("SERVER", "Hopping to random public server...", 2.5)
            pcall(function()
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
            end)
        end

        local function JoinLowest()
            NOTIFY("SERVER", "Joining lowest player count server...", 2.5)
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

        ADD_BTN(C_ACTIONS, "Server Hop", ServerHop)

        local HAS_CRASHED = false
        ADD_BTN(C_ACTIONS, "Crash Server 💥", function()
            if HAS_CRASHED then
                NOTIFY("Crash", "Crassing in progress...", 3)
                return
            end
            HAS_CRASHED = true

            -- 1. Buy the Cubes
            local Event = game:GetService("ReplicatedStorage").Events.ServerEvent
            Event:FireServer(
                "BuyItemTool",
                "Cubes",
                nil,
                1
            )

            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            -- Wait slightly for the purchase to process and the tool to appear
            task.wait(0.6)

            local function getEvent()
                local tool = LocalPlayer.Backpack:FindFirstChild("Cubes")
                if tool then
                    return tool:FindFirstChild("RemoteEvent")
                end
                return nil
            end

            local remoteEvent = getEvent()

            if not remoteEvent then
                warn("RemoteEvent not found. Make sure you have the object in the backpack.")
                NOTIFY("Crash", "Cubes object not found. Try again.", 3)
                HAS_CRASHED = false -- allow retry
                return
            end

            NOTIFY("Crash", "Crashing server...", 4)

            -- Spam
            for _ = 1, 50000 do
                task.spawn(function()
                    pcall(function()
                        remoteEvent:FireServer()
                    end)
                end)
            end
        end)
    end
    task.spawn(SETUP_TELEPORTS)

    local function SETUP_FARMS()
        local LPLR = game:GetService("Players").LocalPlayer
        local FL, FR = ADD_SPLIT(P_FRM)
        FL.Parent.Size = UDim2.new(1, -10, 1, -10)
        FL.Parent.Position = UDim2.new(0, 5, 0, 5)

        local LL = Instance.new("UIListLayout", FL)
        LL.Padding = UDim.new(0, 10)
        LL.SortOrder = Enum.SortOrder.LayoutOrder

        local RL = Instance.new("UIListLayout", FR)
        RL.Padding = UDim.new(0, 10)
        RL.SortOrder = Enum.SortOrder.LayoutOrder

        -- [[ HELPERS ]]
        local function GET_PRP(folder, text)
            for _, v in ipairs(folder:GetDescendants()) do
                if v:IsA("ProximityPrompt") and (v.ActionText == text or v.ObjectText == text) then return v end
            end
            return nil
        end

        local function GET_TOOL(name)
            local tool = LPLR.Backpack:FindFirstChild(name) or (LPLR.Character and LPLR.Character:FindFirstChild(name))
            if tool then
                tool.Parent = LPLR.Character; return tool
            end
            return nil
        end

        local C1 = MK_CARD(FL, "Plant farm", "rbxassetid://126174660032876")

        -- [[ PLANT FARM DATA ]]
        local SEEDS = {
            ["Blackberry ($1,500)"] = "Blackberry Seed",
            ["Raspberry ($500)"] = "Raspberry Seed",
            ["Strawberry ($6,500)"] = "Strawberry Seed",
            ["Blueberry ($3,000)"] = "Blueberry Seed"
        }

        local PLOT_VECTORS = {
            Vector3.new(1537.79, 105.92, 2766.60), Vector3.new(1541.13, 105.92, 2766.59), Vector3.new(1544.73, 105.92,
            2766.70),
            Vector3.new(1548.26, 105.92, 2766.76), Vector3.new(1551.90, 105.92, 2766.98), Vector3.new(1528.33, 105.92,
            2769.54),
            Vector3.new(1528.12, 105.92, 2773.44), Vector3.new(1530.87, 105.92, 2776.16), Vector3.new(1533.86, 105.92,
            2776.21),
            Vector3.new(1536.92, 105.92, 2776.14), Vector3.new(1540.05, 105.92, 2776.17), Vector3.new(1542.78, 105.92,
            2776.40),
            Vector3.new(1545.60, 105.92, 2776.52), Vector3.new(1548.92, 105.92, 2776.53), Vector3.new(1552.15, 105.92,
            2776.57),
            Vector3.new(1555.72, 105.82, 2776.66), Vector3.new(1556.33, 109.45, 2753.81), Vector3.new(1552.68, 109.45,
            2753.92),
            Vector3.new(1549.34, 109.45, 2754.11), Vector3.new(1545.74, 109.45, 2754.19), Vector3.new(1542.21, 109.45,
            2754.31),
            Vector3.new(1538.56, 109.45, 2754.29), Vector3.new(1561.98, 109.45, 2750.49), Vector3.new(1561.97, 109.45,
            2746.59),
            Vector3.new(1559.09, 109.45, 2744.01), Vector3.new(1556.10, 109.45, 2744.12), Vector3.new(1553.05, 109.45,
            2744.36),
            Vector3.new(1549.92, 109.45, 2744.48), Vector3.new(1547.18, 109.45, 2744.40), Vector3.new(1544.36, 109.45,
            2744.42),
            Vector3.new(1541.05, 109.45, 2744.59), Vector3.new(1537.81, 109.45, 2744.71), Vector3.new(1534.25, 109.35,
            2744.81),
            Vector3.new(1515.81, 107.11, 2676.36), Vector3.new(1515.99, 107.11, 2680.02), Vector3.new(1516.23, 107.11,
            2683.35),
            Vector3.new(1516.38, 107.11, 2686.95), Vector3.new(1516.56, 107.11, 2690.47), Vector3.new(1516.60, 107.11,
            2694.12),
            Vector3.new(1512.40, 107.11, 2670.78), Vector3.new(1508.49, 107.11, 2670.85), Vector3.new(1506.53, 107.11,
            2673.94),
            Vector3.new(1506.50, 107.11, 2676.87), Vector3.new(1506.42, 107.11, 2679.81), Vector3.new(1506.60, 107.11,
            2682.94),
            Vector3.new(1506.57, 107.11, 2685.68), Vector3.new(1506.64, 107.11, 2688.50), Vector3.new(1506.86, 107.11,
            2691.81),
            Vector3.new(1507.04, 107.11, 2695.04), Vector3.new(1507.20, 107.01, 2698.60), Vector3.new(1556.38, 106.08,
            2655.22),
            Vector3.new(1553.03, 106.08, 2656.70), Vector3.new(1550.00, 106.08, 2658.12), Vector3.new(1546.69, 106.08,
            2659.54),
            Vector3.new(1543.47, 106.08, 2660.98), Vector3.new(1540.08, 106.08, 2662.32), Vector3.new(1560.37, 106.08,
            2650.03),
            Vector3.new(1558.90, 106.08, 2646.41), Vector3.new(1555.26, 106.08, 2645.11), Vector3.new(1552.53, 106.08,
            2646.33),
            Vector3.new(1549.79, 106.08, 2647.69), Vector3.new(1546.93, 106.08, 2648.98), Vector3.new(1544.37, 106.08,
            2649.93),
            Vector3.new(1541.76, 106.08, 2651.01), Vector3.new(1538.75, 106.08, 2652.40), Vector3.new(1535.80, 106.08,
            2653.73),
            Vector3.new(1532.53, 105.98, 2655.16), Vector3.new(-807.30, 52.60, -54.58), Vector3.new(-803.92, 52.60,
            -54.58),
            Vector3.new(-800.55, 52.60, -54.58), Vector3.new(-797.26, 52.60, -54.58), Vector3.new(-794.17, 52.60, -54.58),
            Vector3.new(-794.17, 52.60, -49.99), Vector3.new(-794.17, 52.60, -46.59), Vector3.new(1403.73, 141.15, 38.04),
            Vector3.new(1409.71, 141.15, 38.04), Vector3.new(1415.64, 141.15, 38.04), Vector3.new(1421.45, 141.15, 38.04),
            Vector3.new(1397.52, 141.15, 38.04)
        }

        local PLANT_CFG = { SEED = "None", AMOUNT = 1, GROUP = 1 }


        local D_SEEDS = ADD_DRP(C1, "Available Seeds", function(v)
            PLANT_CFG.SEED = SEEDS[v] or "None"
        end)
        local seedLabels = {}
        for k, _ in pairs(SEEDS) do table.insert(seedLabels, k) end
        D_SEEDS.REFRESH(seedLabels)

        local D_AMOUNT = ADD_DRP(C1, "Plant Amount: 1", function(v)
            PLANT_CFG.AMOUNT = tonumber(v) or 1
        end)
        D_AMOUNT.REFRESH({ "1", "2", "3", "4", "5", "6", "7", "8", "9" })

        ADD_BTN(C1, "TP to Plot", function()
            local randIdx = math.random(1, 18)
            BYPASS_TP(PLOT_VECTORS[randIdx])
            NOTIFY("Plant Farm", "Teleported to Plot #" .. randIdx, 2)
        end)

        ADD_BTN(C1, "Buy Selected Seed", function()
            if PLANT_CFG.SEED == "None" then
                NOTIFY("Plant Farm", "Select a seed first!", 3)
                return
            end
            NOTIFY("Plant Farm", "Buying " .. PLANT_CFG.AMOUNT .. " " .. PLANT_CFG.SEED .. "...", 3)
            for i = 1, PLANT_CFG.AMOUNT do
                game:GetService("ReplicatedStorage").Remotes.PurchaseSeed:FireServer(PLANT_CFG.SEED)
                task.wait(0.1)
            end
        end)

        -- ── EXTRAS CARD ────────────────────────────────────────────────────────────
        local C_EXTRAS = MK_CARD(FL, "Extras", "rbxassetid://106507089706013")
        local TRASH_R = false
        local function DO_TRASH()
            local f = workspace:FindFirstChild("Folder", true) and workspace.Folder:FindFirstChild("map", true)
                and workspace.Folder.map:FindFirstChild("TrashBags", true)

            if not f then
                -- Fallback: Search globally for TrashBags if path is broken
                f = workspace:FindFirstChild("TrashBags", true)
            end

            if not f then return end

            local pL = {}
            for _, v in ipairs(f:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    local act = v.ActionText:lower()
                    local obj = v.ObjectText:lower()
                    if act:find("search") or act:find("trash") or act:find("pile") or act:find("bag")
                        or obj:find("trash") or obj:find("bag") then
                        table.insert(pL, v)
                    end
                end
            end

            for _, p in ipairs(pL) do
                if not TRASH_R then return end
                local part = p.Parent
                if part and part:IsA("BasePart") and p.Enabled then
                    BYPASS_TP(part.Position)
                    task.wait(0.5)
                    FORCE_HOLD(p)
                    task.wait(0.2)
                    -- Wait for the bag to disappear or cooldown
                    task.wait(5)
                end
            end
        end
        ADD_TGL(C_EXTRAS, "Trash Farm", false,
            function(v)
                TRASH_R = v; if v then
                    task.spawn(function()
                        while TRASH_R do
                            pcall(DO_TRASH); task.wait(2)
                        end
                    end)
                end
            end)

        local _BOX_FARM = false
        local function DO_BOX_FARM()
            local GS = game:GetService("GuiService")
            local playerGui = LPLR:WaitForChild("PlayerGui")
            local mainScreen = playerGui:WaitForChild("MainScreen")
            local characterChat = mainScreen:WaitForChild("CharacterChat")
            local buttonsFrame = characterChat:WaitForChild("Buttons")

            local function clickButton(targetText)
                for _, child in ipairs(buttonsFrame:GetChildren()) do
                    if child:IsA("Frame") then
                        local label = child:FindFirstChildWhichIsA("TextLabel")
                        local btn = child:FindFirstChildWhichIsA("TextButton")
                        if label and btn and label.Text == targetText then
                            GS.SelectedObject = btn
                            task.wait(0.15)
                            keypress(0x0D)
                            task.wait(0.05)
                            keyrelease(0x0D)
                            return true
                        end
                    end
                end
                return false
            end

            local function clickNPC()
                local npc = game.Workspace.Map.NPC["Tyreek's Shop"]
                local clickDetector = npc:FindFirstChild("ClickDetector")

                if clickDetector then
                    fireclickdetector(clickDetector)
                end
            end

            local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- INICIAR TRABAJO
            BYPASS_TP(Vector3.new(-37, 90, 279))
            task.wait(0.5)
            clickNPC()
            task.wait(1)
            clickButton("Get Job")
            task.wait(1)
            clickButton("Nvm")
            task.wait(1)

            -- BUCLE DE FARM (TRANSPORTAR CAJAS)
            while _BOX_FARM do
                local char = LPLR.Character
                local pBox = workspace.Map.JobModels.GasStation:FindFirstChild("PickBox")
                local dBox = workspace.Map.JobModels.GasStation:FindFirstChild("DropBox")

                if char and char:FindFirstChild("HumanoidRootPart") and pBox and dBox then
                    hrp = char.HumanoidRootPart
                    local hum = char:FindFirstChildOfClass("Humanoid")

                    -- Ir al PickBox
                    BYPASS_TP(pBox.Position + Vector3.new(0, 3, 0))
                    task.wait(0.4)

                    local retries = 0
                    while _BOX_FARM and retries < 10 do
                        if LPLR.Backpack:FindFirstChild("CrateBox") or char:FindFirstChild("CrateBox") then break end
                        BYPASS_TP(pBox.Position + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                        retries = retries + 1
                    end

                    if not _BOX_FARM then break end

                    -- Equipar Caja Segura
                    local bCrate = LPLR.Backpack:FindFirstChild("CrateBox")
                    if bCrate then hum:EquipTool(bCrate) end

                    -- Ir al DropBox y Entregar
                    BYPASS_TP(dBox.Position + Vector3.new(0, 3, 0))
                    task.wait(0.2)

                    while _BOX_FARM and (LPLR.Backpack:FindFirstChild("CrateBox") or char:FindFirstChild("CrateBox")) do
                        local c = LPLR.Backpack:FindFirstChild("CrateBox")
                        if c then hum:EquipTool(c) end
                        BYPASS_TP(dBox.Position + Vector3.new(0, 3, 0))
                        task.wait(0.2)
                    end
                else
                    task.wait(1)
                end
            end

            -- CERRAR TURNO (Bucle apagado)
            hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                BYPASS_TP(Vector3.new(-37, 90, 279))
                task.wait(0.5)
                clickNPC()
                task.wait(1)
                clickButton("End my shift")
                task.wait(0.5)

                GS.SelectedObject = nil
                characterChat.Visible = false
                mainScreen.Visible = false
            end
        end

        ADD_TGL(C_EXTRAS, "Box farm", false, function(v)
            _BOX_FARM = v; if v then task.spawn(DO_BOX_FARM) end
        end)

        --[[
        -- ── CAR BUILDER CARD ─────────────────────────────────────────────────────────
        local C_CARBUILD = MK_CARD(FL, "Car Builder", "rbxassetid://77304301427389")
        local CB_SEL = nil
        local CB_RUN = false

        local CB_CARS = {
            ["Lexus LS400"] = {
                ID = "Lexus",
                UnbuiltPrefix = "UnBuilt Lexus - ",
                FinalName = "Lexus LS400",
                Parts = { "LEXUSWindows", "LEXUSTrunk", "LEXUSRightSideDoors", "LEXUSRearRightWheel", "LEXUSRearRightPanel", "LEXUSRearLeftWheel", "LEXUSRearLeftPanel", "LEXUSRearBumper", "LEXUSHood", "LEXUSFrontRightWheel", "LEXUSFrontLeftWheel", "LEXUSFrontBumper", "LEXUSLeftSideDoors" }
            },
            ["Scat Pack"] = {
                ID = "Scat",
                UnbuiltPrefix = "UnBuilt Scat - ",
                FinalName = "Scat Pack",
                Parts = { "SPTrunk", "SPFrontLeftWheel", "SPFrontRightDoor", "SPRearBumper", "SPFrontBumper", "SPRearRightDoor", "SPRearLeftWheel", "SPFrontRightWheel", "SPHood", "SPWindows", "SPFrontLeftDoor", "SPRearLeftDoor" }
            },
            ["2011 Toyota Camry"] = {
                ID = "Toyota",
                UnbuiltPrefix = "UnBuilt Toyota - ",
                FinalName = "2011 Toyota Camry",
                Parts = { "TOYOTAFrontLeftWheel", "TOYOTAWindows", "TOYOTAFrontRightDoor", "TOYOTARearRightWheel", "TOYOTARearLeftWheel", "TOYOTAFrontRightWheel", "TOYOTARearRightDoor", "TOYOTATrunk", "TOYOTARearBumper", "TOYOTARearLeftDoor", "TOYOTAHood", "TOYOTAFrontBumper", "TOYOTAFrontLeftDoor" }
            }
        }

        -- Exact copies of carBl.lua helpers
        local function CB_TP(pos)
            pcall(function()
                local char = LPLR.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end)
        end

        local function CB_FIRE(p)
            if not p then return end
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(p)
                else
                    p:InputBegan(Enum.UserInputType.MouseButton1); task.wait(0.04); p:InputEnded(Enum.UserInputType
                        .MouseButton1)
                end
            end)
        end

        local function CB_EQUIP(name)
            local tool = LPLR.Backpack:FindFirstChild(name)
            if tool then
                local humanoid = LPLR.Character and LPLR.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:EquipTool(tool); task.wait(0.12); return true
                end
            elseif LPLR.Character and LPLR.Character:FindFirstChild(name) then
                return true
            end
            return false
        end

        local function CB_FIND(text)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and (v.ActionText == text or v.ObjectText == text) then return v end
            end
        end

        local function CB_OCCUPIED()
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name:sub(1, 8) == "UnBuilt " and not v.Name:find(LPLR.Name) then return true end
            end
            return false
        end

        local CB_TGL_OBJ
        CB_TGL_OBJ = ADD_TGL(C_CARBUILD, "Auto Build Farm", false, function(v)
            if v and not CB_SEL then
                NOTIFY("Car Builder", "Please select a vehicle before starting!", 4)
                task.defer(function()
                    CB_RUN = false
                    if CB_TGL_OBJ and CB_TGL_OBJ.SET then
                        CB_TGL_OBJ:SET(false, true)
                    end
                end)
                return
            end
            CB_RUN = v
            if v then
                task.spawn(function()
                    while CB_RUN do
                        -- Workshop guard
                        while CB_RUN and CB_OCCUPIED() do
                            NOTIFY("Car Builder", "Workshop occupied! Waiting...", 5)
                            task.wait(2)
                        end
                        if not CB_RUN then break end

                        local data = CB_CARS[CB_SEL]
                        pcall(function()
                            -- Phase 1: Buy
                            CB_TP(Vector3.new(232, 101, 2688))
                            task.wait(0.6)
                            game:GetService("ReplicatedStorage").SpawnUnbuilt:FireServer(data.ID)
                            task.wait(0.4)
                            game:GetService("ReplicatedStorage").RequestPurchaseAllParts:FireServer(data.ID, data.Parts)
                            task.wait(0.6)

                            -- Phase 2: Workshop
                            CB_TP(Vector3.new(218, 101, 2668))
                            task.wait(0.6)

                            -- Phase 3: Assemble (exact carBl.lua logic)
                            local carModel = workspace:WaitForChild(data.UnbuiltPrefix .. LPLR.Name, 10)
                            if carModel then
                                local pPrompt = carModel:FindFirstChild("Prompt") and
                                    carModel.Prompt:FindFirstChild("ProximityPrompt")
                                    or carModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                                CB_TP(Vector3.new(218, 101, 2668))
                                for _, partName in ipairs(data.Parts) do
                                    if not CB_RUN then break end
                                    if CB_EQUIP(partName) then
                                        CB_FIRE(pPrompt)
                                        task.wait(0.18)
                                    end
                                end
                            end

                            -- Phase 4: Sell (exact carBl.lua logic)
                            local finalCar, dPrompt = nil, nil
                            local timeout = tick() + 15
                            while CB_RUN and tick() < timeout do
                                for _, v in ipairs(workspace:GetChildren()) do
                                    if v.Name == data.FinalName and v:FindFirstChild("DriveSeat") then
                                        dPrompt = v.DriveSeat:FindFirstChild("ProximityPrompt")
                                        if dPrompt then
                                            finalCar = v; break
                                        end
                                    end
                                end
                                if dPrompt then break end
                                task.wait(0.05)
                            end

                            if finalCar and dPrompt then
                                CB_TP(finalCar.DriveSeat.Position)
                                task.wait(0.1)
                                CB_FIRE(dPrompt)
                                task.wait(1.5)

                                local targetSellPos = Vector3.new(530, 93, -415)
                                for _ = 1, 5 do
                                    finalCar:PivotTo(CFrame.new(targetSellPos))
                                    if LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") then
                                        LPLR.Character.HumanoidRootPart.CFrame = CFrame.new(targetSellPos +
                                            Vector3.new(0, 2, 0))
                                    end
                                    task.wait(0.08)
                                end
                                task.wait(0.6)

                                local sellP = CB_FIND("Sell Built Car")
                                if sellP then
                                    CB_TP(sellP.Parent.Position)
                                    CB_FIRE(sellP)
                                    NOTIFY("Car Builder", "Profit collected!", 3)
                                    task.wait(1.5)
                                end
                            end
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end)

        ADD_DRP(C_CARBUILD, "Select Vehicle", function(v) CB_SEL = v end)
            :ADD_MANY({ "Lexus LS400", "Scat Pack", "2011 Toyota Camry" })
        --]]

        local C_BANK = MK_CARD(FR, "Bank farm", "rbxassetid://139426182681638")

        local function RUN_BANK_HEIST()
            local b = workspace.Map.JobModels.Bank.StackOfMoney

            -- Detect if vault is already open (Transparency check)
            local isAlreadyOpen = false
            local anyMoneyAvailable = false

            for _, child in ipairs(b:GetDescendants()) do
                if child.Name == "Money" and child:IsA("MeshPart") then
                    if child.Transparency > 0 then
                        isAlreadyOpen = true     -- Someone already opened it!
                    else
                        anyMoneyAvailable = true -- There is still money left
                    end
                end
            end

            if isAlreadyOpen and not anyMoneyAvailable then
                NOTIFY("Bank Heist", "Bank is empty! Waiting...", 4)
                return
            end

            local Event = game:GetService("ReplicatedStorage").Events.ServerEvent

            if not isAlreadyOpen then
                -- Vault is CLOSED, need to buy gear
                local cashStr = LPLR.PlayerGui.MainScreen.Profile.CashAmount.Text
                local cash = tonumber((cashStr:gsub("%D", ""))) or 0

                if cash < 4600 then
                    NOTIFY("Bank Heist", "Vault closed & not enough cash ($4,600 needed)!", 5)
                    return
                end

                NOTIFY("Bank Heist", "Vault closed. Buying gear...", 3)
                Event:FireServer("BuyItemTool", "DuffelBag", false)
                task.wait(0.3)
                Event:FireServer("BuyItemTool", "SecureEntry", false)
                task.wait(0.5)

                BYPASS_TP(Vector3.new(149, 90, -155))
                task.wait(0.8)

                local backpack = LPLR:FindFirstChild("Backpack")
                local tool = backpack and backpack:FindFirstChild("SecureEntry")
                if tool then
                    LPLR.Character.Humanoid:EquipTool(tool)
                else
                    local charTool = LPLR.Character:FindFirstChild("SecureEntry")
                    if not charTool then
                        NOTIFY("Bank Heist", "Failed to buy/equip SecureEntry!", 4)
                        return
                    end
                end
                task.wait(0.4)
                Event:FireServer("PackBank")
                task.wait(0.8)
            else
                NOTIFY("Bank Heist", "Vault OPEN! Buying DuffelBag & Bypassing entry...", 4)
                Event:FireServer("BuyItemTool", "DuffelBag", false)
                task.wait(0.5)
            end

            -- Step 5: TP to Money Stacks
            BYPASS_TP(Vector3.new(153, 88, -126))
            task.wait(1)

            -- Step 6: Collect Money (Huge randomized list)
            local detectors = {
                b:GetChildren()[2]:GetChildren()[2].ClickDetector,
                b:GetChildren()[2]:GetChildren()[7].ClickDetector,
                b:GetChildren()[2]:GetChildren()[4].ClickDetector,
                b:GetChildren()[2].Money.ClickDetector,
                b.Model:GetChildren()[7].ClickDetector,
                b.Model.Money.ClickDetector,
                b.Model:GetChildren()[4].ClickDetector,
                b.Model:GetChildren()[2].ClickDetector,
                b.Model:GetChildren()[5].ClickDetector,
                b.Model:GetChildren()[6].ClickDetector,
                b.Model:GetChildren()[3].ClickDetector,
                b:GetChildren()[7].Money.ClickDetector,
                b:GetChildren()[7]:GetChildren()[3].ClickDetector,
                b:GetChildren()[7]:GetChildren()[7].ClickDetector,
                b:GetChildren()[7]:GetChildren()[4].ClickDetector,
                b:GetChildren()[7]:GetChildren()[2].ClickDetector,
                b:GetChildren()[7]:GetChildren()[5].ClickDetector,
                b:GetChildren()[7]:GetChildren()[6].ClickDetector,
                b:GetChildren()[5]:GetChildren()[3].ClickDetector,
                b:GetChildren()[5]:GetChildren()[7].ClickDetector,
                b:GetChildren()[5].Money.ClickDetector,
                b:GetChildren()[5]:GetChildren()[4].ClickDetector,
                b:GetChildren()[5]:GetChildren()[2].ClickDetector,
                b:GetChildren()[5]:GetChildren()[5].ClickDetector,
                b:GetChildren()[5]:GetChildren()[6].ClickDetector,
                b:GetChildren()[2]:GetChildren()[3].ClickDetector,
                b:GetChildren()[2]:GetChildren()[5].ClickDetector,
                b:GetChildren()[2]:GetChildren()[6].ClickDetector,
                b:GetChildren()[4]:GetChildren()[3].ClickDetector,
                b:GetChildren()[4]:GetChildren()[7].ClickDetector,
                b:GetChildren()[4].Money.ClickDetector,
                b:GetChildren()[4]:GetChildren()[4].ClickDetector,
                b:GetChildren()[4]:GetChildren()[2].ClickDetector,
                b:GetChildren()[4]:GetChildren()[5].ClickDetector,
                b:GetChildren()[4]:GetChildren()[6].ClickDetector,
                b:GetChildren()[8]:GetChildren()[3].ClickDetector,
                b:GetChildren()[6]:GetChildren()[7].ClickDetector,
                b:GetChildren()[6].Money.ClickDetector,
                b:GetChildren()[6]:GetChildren()[4].ClickDetector,
                b:GetChildren()[6]:GetChildren()[2].ClickDetector,
                b:GetChildren()[6]:GetChildren()[5].ClickDetector,
                b:GetChildren()[6]:GetChildren()[6].ClickDetector,
                b:GetChildren()[6]:GetChildren()[3].ClickDetector,
                b:GetChildren()[3]:GetChildren()[3].ClickDetector,
                b:GetChildren()[3]:GetChildren()[7].ClickDetector,
                b:GetChildren()[3].Money.ClickDetector,
                b:GetChildren()[3]:GetChildren()[4].ClickDetector,
                b:GetChildren()[3]:GetChildren()[2].ClickDetector,
                b:GetChildren()[3]:GetChildren()[5].ClickDetector,
                b:GetChildren()[3]:GetChildren()[6].ClickDetector,
                b:GetChildren()[8]:GetChildren()[7].ClickDetector,
                b:GetChildren()[8].Money.ClickDetector,
                b:GetChildren()[8]:GetChildren()[4].ClickDetector,
                b:GetChildren()[8]:GetChildren()[2].ClickDetector,
                b:GetChildren()[8]:GetChildren()[5].ClickDetector,
                b:GetChildren()[8]:GetChildren()[6].ClickDetector
            }

            local available = {}
            for _, d in ipairs(detectors) do
                -- Check if parent money is still there
                pcall(function()
                    if d and d.Parent and d.Parent.Transparency == 0 then
                        table.insert(available, d)
                    end
                end)
            end

            local count = math.random(10, 11)
            for i = 1, math.min(count, #available) do
                local idx = math.random(1, #available)
                local det = table.remove(available, idx)
                pcall(fireclickdetector, det)
                task.wait(0.15)
            end

            NOTIFY("Bank Heist", "Money collected! Delivering...", 3)
            BYPASS_TP(Vector3.new(980, 231, -493))
            task.wait(2)
            NOTIFY("Bank Heist", "Heist complete!", 5)
        end

        local HEIST_RUNNING = false
        local LAST_HEIST_TICK = 0 -- Persiste aunque apagues el toggle

        ADD_TGL(C_BANK, "Auto Bank Heist", false, function(v)
            HEIST_RUNNING = v
            if HEIST_RUNNING then
                task.spawn(function()
                    while HEIST_RUNNING do
                        local timeSinceLast = tick() - LAST_HEIST_TICK
                        if timeSinceLast < 300 then
                            local remain = math.ceil(300 - timeSinceLast)
                            NOTIFY("Bank Heist", "Persistent cooldown active! Waiting " .. remain .. "s", 5)
                            task.wait(remain)
                        end

                        if not HEIST_RUNNING then break end

                        pcall(RUN_BANK_HEIST)
                        LAST_HEIST_TICK = tick() -- Actualizamos el tiempo global

                        if HEIST_RUNNING then
                            NOTIFY("Bank Heist", "Heist finished! 5 min cooldown started.", 5)
                            -- Countdown Notifications
                            for i = 4, 1, -1 do
                                task.wait(60)
                                if not HEIST_RUNNING then break end
                                NOTIFY("Bank Heist", "Cooldown: " .. i .. " min remaining...", 3)
                            end
                            if HEIST_RUNNING then task.wait(60) end -- final minute
                        end
                    end
                end)
            end
        end)

        ADD_BTN(C_BANK, "Server Hop", ServerHop)

        -- ── CASINO FARM CARD ────────────────────────────────────────────────────────
        local C_CASINO = MK_CARD(FR, "Casino farm", "rbxassetid://123267471411753")

        local function RUN_CASINO_FARM()
            local startPrompt = workspace.SilverBackTeleport.Start:FindFirstChild("ProximityPrompt")
            if startPrompt and startPrompt.ActionText:find("Cooldown") then
                NOTIFY("Casino Farm", "Map Cooldown active (18 mins). Sleeping...", 4)
                return false
            end

            NOTIFY("Casino Farm", "Starting Heist...", 3)
            game:GetService("ReplicatedStorage").Events.ServerEvent:FireServer("BuyItemTool", "CasinoBag", false)
            task.wait(0.5)

            BYPASS_TP(Vector3.new(1324, 130, 390))
            task.wait(0.5)
            if startPrompt then fireproximityprompt(startPrompt) end

            task.wait(7)

            local function LOOT_20()
                BYPASS_TP(Vector3.new(1386, 115, 268))
                task.wait(1)
                local loot = {}
                local miscs = workspace.SilverBackHeist.Robbables.Miscs
                local safes = workspace.SilverBackHeist.Robbables.Safes
                for _, v in ipairs(miscs:GetDescendants()) do
                    if v:IsA("ClickDetector") and (v:IsDescendantOf(miscs.Money)) then table.insert(loot, v) end
                end
                for _, v in ipairs(safes:GetDescendants()) do
                    if v:IsA("ClickDetector") and v.Parent.Name == "Money" then table.insert(loot, v) end
                end
                local count = 0
                for _, cd in ipairs(loot) do
                    if cd and cd.Parent and (not cd.Parent:IsA("BasePart") or cd.Parent.Transparency < 1) then
                        fireclickdetector(cd)
                        count = count + 1
                        task.wait(0.15)
                        if count >= 20 then break end
                    end
                end
                BYPASS_TP(Vector3.new(980, 231, -492))
                task.wait(1)
                local sellPart = workspace.Map.JobModels.Bank.SellModel:FindFirstChild("DistancePart")
                if sellPart then
                    firetouchinterest(LPLR.Character.HumanoidRootPart, sellPart, 0)
                    task.wait(0.1)
                    firetouchinterest(LPLR.Character.HumanoidRootPart, sellPart, 1)
                end
                task.wait(1)
            end

            LOOT_20()
            return true
        end

        local LAST_CASINO_TICK = 0
        local CASINO_RUNNING = false
        ADD_TGL(C_CASINO, "Auto Casino", false, function(v)
            CASINO_RUNNING = v
            if v then
                task.spawn(function()
                    while CASINO_RUNNING do
                        local timeSinceLast = tick() - LAST_CASINO_TICK
                        if timeSinceLast < 300 then
                            local remain = math.ceil(300 - timeSinceLast)
                            NOTIFY("Casino Farm", "Persistent Cooldown: " .. remain .. "s remaining", 5)
                            task.wait(remain)
                        end

                        if not CASINO_RUNNING then break end

                        local success = RUN_CASINO_FARM()
                        if success then
                            LAST_CASINO_TICK = tick()
                            NOTIFY("Casino Farm", "Heist Finished! 5m Cooldown started.", 5)
                        else
                            -- Map is on cooldown, check again in 1 minute instead of spamming every 2s
                            task.wait(60)
                        end
                        task.wait(2)
                    end
                end)
            end
        end)

        -- ── AUTO EXTRACT SYSTEM (BRAIN STRUCTURE) ──────────────────────────────────
        local C_EXTRACT = MK_CARD(FR, "Auto Extract", "rbxassetid://122233645421733")
        local SEL_EXTRACT = "Green Extract"
        local SEL_QTY = 1
        local EXT_RUNNING = false

        local function FIND_AVAILABLE_STATION()
            for _, s in ipairs(workspace.Map.JobModels:GetChildren()) do
                if s:FindFirstChild("StatusPart") and s.StatusPart:FindFirstChild("DrankStatusPrompt") and s.StatusPart.DrankStatusPrompt.Enabled then
                    return s
                end
            end
            return nil
        end

        local function BUY_EXT_STUFF()
            local shops = workspace.Gunshops

            -- 1. Buy Selected Extract
            local e_p = GET_PRP(shops, SEL_EXTRACT)
            if e_p then
                BYPASS_TP(e_p.Parent.Position); task.wait(1)
                for i = 1, SEL_QTY do
                    FORCE_HOLD(e_p); task.wait(3.2)
                end
            end

            -- 2. Buy Water (Remote)
            for i = 1, SEL_QTY do
                game:GetService("ReplicatedStorage").Events.ServerEvent:FireServer("BuyItemTool", "Water", false)
                task.wait(0.3)
            end

            -- 3. Buy Sugar
            local s_p = GET_PRP(shops, "Sugar")
            if s_p then
                BYPASS_TP(s_p.Parent.Position); task.wait(1)
                for i = 1, SEL_QTY do
                    FORCE_HOLD(s_p); task.wait(3.2)
                end
            end

            -- 4. Buy Empty Cups (x2)
            local c_p = GET_PRP(shops, "Empty Cup")
            if c_p then
                BYPASS_TP(c_p.Parent.Position); task.wait(1)
                for i = 1, (SEL_QTY * 2) do
                    FORCE_HOLD(c_p)
                    NOTIFY("Auto Extract", "Buying Cup " .. i .. "/" .. (SEL_QTY * 2), 1)
                    task.wait(3.2)
                end
            end
        end

        ADD_TGL(C_EXTRACT, "Auto Extract", false, function(v)
            EXT_RUNNING = v
            if v then
                task.spawn(function()
                    while EXT_RUNNING do
                        -- 1. Inventory Check
                        local function HAS_ING()
                            local needed = { [SEL_EXTRACT] = 1, ["Water"] = 1, ["Sugar"] = 1, ["Empty Cup"] = 2 }
                            local cur = {}
                            for _, i in ipairs(LPLR.Backpack:GetChildren()) do cur[i.Name] = (cur[i.Name] or 0) + 1 end
                            if LPLR.Character then
                                for _, i in ipairs(LPLR.Character:GetChildren()) do cur[i.Name] = (cur[i.Name] or 0) + 1 end
                            end
                            for item, qty in pairs(needed) do if (cur[item] or 0) < qty then return false end end
                            return true
                        end

                        if not HAS_ING() then
                            NOTIFY("Auto Extract", "Shopping for ingredients...", 3)
                            BUY_EXT_STUFF()
                            task.wait(1)
                        end
                        if not EXT_RUNNING then break end

                        local ACTIVE_STATIONS = {}
                        local to_fill = SEL_QTY

                        NOTIFY("Auto Extract", "Phase 1: Filling " .. SEL_QTY .. " stations...", 3)

                        while to_fill > 0 and EXT_RUNNING do
                            local st = FIND_AVAILABLE_STATION()
                            if st then
                                local already = false
                                for _, used in ipairs(ACTIVE_STATIONS) do
                                    if used == st then
                                        already = true
                                        break
                                    end
                                end

                                if not already then
                                    BYPASS_TP(st.StatusPart.Position); task.wait(0.5)
                                    GET_TOOL("Water"); FORCE_HOLD(st.StatusPart.DrankStatusPrompt); task.wait(1.2)
                                    GET_TOOL("Sugar"); FORCE_HOLD(st.StatusPart.DrankStatusPrompt); task.wait(0.6)
                                    GET_TOOL(SEL_EXTRACT); FORCE_HOLD(st.StatusPart.DrankStatusPrompt)

                                    table.insert(ACTIVE_STATIONS, st)
                                    to_fill = to_fill - 1
                                    NOTIFY("Auto Extract", "Station " .. #ACTIVE_STATIONS .. " started!", 2)
                                else
                                    task.wait(1)
                                end
                            else
                                task.wait(2)
                            end
                        end

                        if not EXT_RUNNING then break end
                        NOTIFY("Auto Extract", "Phase 2: Harvesting...", 3)

                        local done = 0
                        while done < SEL_QTY and EXT_RUNNING do
                            for idx, st in ipairs(ACTIVE_STATIONS) do
                                if st ~= "DONE" then
                                    local cp = st.PlaceCup.DrankPlaceCupPrompt
                                    if cp.Enabled then
                                        BYPASS_TP(st.StatusPart.Position); task.wait(0.4)
                                        -- Step 4: Add Cups
                                        NOTIFY("Auto Extract", "Adding cups to station " .. idx, 2)
                                        for _ = 1, 2 do
                                            GET_TOOL("Empty Cup"); FORCE_HOLD(cp); task.wait(0.6)
                                        end

                                        -- Step 5: Pour
                                        local pourP = st.Water:FindFirstChild("DrankPourPrompt")
                                        if pourP then
                                            while EXT_RUNNING and pourP.Enabled do
                                                FORCE_HOLD(pourP)
                                                task.wait(0.1)
                                            end
                                        end

                                        -- Step 6: Collect (x3 for safety)
                                        for _ = 1, 3 do
                                            FORCE_HOLD(cp)
                                            task.wait(0.5)
                                        end

                                        ACTIVE_STATIONS[idx] = "DONE"
                                        done = done + 1
                                        NOTIFY("Auto Extract", "Batch " .. done .. " collected!", 2)
                                    end
                                end
                            end
                            task.wait(1)
                        end
                        task.wait(2)
                    end
                end)
            end
        end)

        local D_EXTRACT = ADD_DRP(C_EXTRACT, "Select Extract: Green Extract", function(v)
            SEL_EXTRACT = v
        end)
        D_EXTRACT:ADD_MANY({ "Green Extract", "Red Extract", "Blue Extract", "Pink Extract", "Purple Extract" })

        local D_QTY = ADD_DRP(C_EXTRACT, "Extract Qty: 1", function(v)
            SEL_QTY = tonumber(v)
        end)
        D_QTY:ADD_MANY({ "1", "2", "3", "4", "5", "6" })
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
        ADD_ESP_ROW(C1, "Self Chams", ESP_CFG.Chams.Enabled, function(v) ESP_CFG.Chams.Enabled = v end, {
            { VAL = ESP_CFG.Chams.Color1, CB = function(c) ESP_CFG.Chams.Color1 = c end },
            { VAL = ESP_CFG.Chams.Color2, CB = function(c) ESP_CFG.Chams.Color2 = c end }
        })
        ADD_ESP_ROW(C1, "Tool Charms", ESP_CFG.ToolCharms.Enabled, function(v) ESP_CFG.ToolCharms.Enabled = v end, {
            { VAL = ESP_CFG.ToolCharms.Color1, CB = function(c) ESP_CFG.ToolCharms.Color1 = c end },
            { VAL = ESP_CFG.ToolCharms.Color2, CB = function(c) ESP_CFG.ToolCharms.Color2 = c end }
        })
        ADD_ESP_ROW(C1, "Snaplines", ESP_CFG.Snaplines.Enabled, function(v) ESP_CFG.Snaplines.Enabled = v end,
            { { VAL = ESP_CFG.Snaplines.Color, CB = function(c) ESP_CFG.Snaplines.Color = c end } })
        ADD_ESP_ROW(C1, "Off-Screen Lines", ESP_CFG.Snaplines.OffScreen, function(v) ESP_CFG.Snaplines.OffScreen = v end)
        ADD_ESP_ROW(C1, "Skeleton", ESP_CFG.Skeleton.Enabled, function(v) ESP_CFG.Skeleton.Enabled = v end,
            { { VAL = ESP_CFG.Skeleton.Color, CB = function(c) ESP_CFG.Skeleton.Color = c end } })

        -- ── SILENT AIM CARD ────────────────────────────────
        local C2_SA = MK_CARD(VR, "Silent Aim ", "rbxassetid://80029373400221")

        _G.EXE.SILENT_AIM = _G.EXE.SILENT_AIM or {
            Enabled = false,
            Hitbox = "Head",
            ShowFOV = false,
            FOV_Radius = 100,
            WallCheck = true
        }

        ADD_TGL(C2_SA, "Enable Silent Aim", _G.EXE.SILENT_AIM.Enabled, function(v)
            _G.EXE.SILENT_AIM.Enabled = v
        end)

        local SA_HITBOX_DRP = ADD_DRP(C2_SA, "Hitbox: " .. _G.EXE.SILENT_AIM.Hitbox, function(v)
            _G.EXE.SILENT_AIM.Hitbox = v
        end)
        SA_HITBOX_DRP:ADD_MANY({ "Head", "Torso", "Random" })

        ADD_TGL(C2_SA, "Wall Check", _G.EXE.SILENT_AIM.WallCheck, function(v)
            _G.EXE.SILENT_AIM.WallCheck = v
        end)

        ADD_TGL(C2_SA, "Show FOV Circle", _G.EXE.SILENT_AIM.ShowFOV, function(v)
            _G.EXE.SILENT_AIM.ShowFOV = v
        end)

        ADD_SLD(C2_SA, "FOV Size", 10, 500, _G.EXE.SILENT_AIM.FOV_Radius, function(v)
            _G.EXE.SILENT_AIM.FOV_Radius = v
        end, "px")

        -- ── INSTA KILL CARD ────────────────────────────────
        local C3 = MK_CARD(VR, "Insta Kill ⚠️", "rbxassetid://140547169969789")
        for _, v in pairs(C3:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text == "Insta Kill ⚠️" then
                v.TextColor3 = Color3.fromRGB(255, 50, 50)
                break
            end
        end

        _G.EXE.IK_TARGET = "None"
        local IK_DRP = ADD_DRP(C3, "Select Player", function(v)
            _G.EXE.IK_TARGET = v
        end)

        local function UPD_IK_LIST()
            local names = {}
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= LPLR then
                    pcall(function()
                        local C = p.Character or workspace:FindFirstChild(p.Name)
                        local UT = C and C:FindFirstChild("UpperTorso")
                        local isP = false
                        if UT then
                            local rk = UT:FindFirstChild("RKSGui")
                            local sh = UT:FindFirstChild("ShieldGui")
                            isP = (rk and rk.Enabled) or (sh and sh.Enabled)
                        end
                        local displayName = isP and "🛡️ " .. p.Name or p.Name
                        table.insert(names, displayName)
                    end)
                end
            end
            table.sort(names)
            if #names == 0 then
                table.insert(names, "None")
            end
            IK_DRP.REFRESH(names)
        end

        game:GetService("Players").PlayerAdded:Connect(UPD_IK_LIST)
        game:GetService("Players").PlayerRemoving:Connect(UPD_IK_LIST)
        UPD_IK_LIST()

        -- Periodic check for shield status changes
        task.spawn(function()
            while true do
                task.wait(5)
                if MAIN.Visible then
                    UPD_IK_LIST()
                end
            end
        end)

        local hitRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("ValidateHit")
        local shootRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Shoot")
        local gunHitRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("GunHit")

        local function EQUIP_WEAPON()
            local char = LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not (char and hum) then return end

            local current = char:FindFirstChildOfClass("Tool")
            -- Strict check for valid gun
            local function IS_REAL_GUN(tool)
                if not tool:IsA("Tool") then return false end

                -- Explicit Blacklist (NYC Specific)
                local name = tool.Name
                local blacklist = {
                    ["Phone"] = true,
                    ["Fist"] = true,
                    ["BountyCard"] = true,
                    ["GunBuilderServer"] = true,
                    ["Tablet"] = true,
                    ["Wallet"] = true
                }
                if blacklist[name] then return false end

                -- Detection logic
                if tool:GetAttribute("GunMagAmmo") then return true end

                -- Fallback check for gun-specific parts
                local h = tool:FindFirstChild("Handle")
                if h and (h:FindFirstChild("Muzzle") or h:FindFirstChild("Flash") or h:FindFirstChild("Barrel")) then
                    return true
                end
                return false
            end

            if current and IS_REAL_GUN(current) then
                return current
            end

            -- Search in backpack with strictness
            for _, tool in pairs(LPLR.Backpack:GetChildren()) do
                if IS_REAL_GUN(tool) then
                    hum:EquipTool(tool)
                    task.wait(0.2) -- Necessary for server sync
                    return tool
                end
            end
        end

        local function KILL_PLAYER_BURST(targetName)
            if targetName == "None" then return end

            -- Auto-Equip Check
            local weapon = EQUIP_WEAPON()
            if not weapon then
                return NOTIFY("Error", "No weapon found in backpack!", 2)
            end

            -- Clean name from emoji
            local rawName = targetName:gsub("🛡️ ", "")
            local target = game:GetService("Players"):FindFirstChild(rawName)
            local char = target and target.Character

            -- Re-check protection before firing
            local ut = char and char:FindFirstChild("UpperTorso")
            local rk = ut and ut:FindFirstChild("RKSGui")
            local sh = ut and ut:FindFirstChild("ShieldGui")
            if (rk and rk.Enabled) or (sh and sh.Enabled) then
                return NOTIFY("Protected", target.Name .. " has the shield!", 2)
            end

            local head = char and (char:FindFirstChild("HeadHitBox") or char:FindFirstChild("Head"))
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local baseTime = workspace:GetServerTimeNow()
                for i = 1, 15 do -- Small, reliable burst per cycle
                    local uniqueTime = baseTime + (i * 0.01)
                    local pos = head.Position

                    task.spawn(function()
                        shootRemote:FireServer(pos, uniqueTime)
                        hitRemote:FireServer(pos, char, head, uniqueTime)
                        gunHitRemote:FireServer(uniqueTime, true, head.Name)
                    end)
                end
            end
        end

        local function TELE_KILL(targetName)
            if targetName == "None" then return end

            -- Auto-Equip Check
            local weapon = EQUIP_WEAPON()
            if not weapon then
                return NOTIFY("Error", "No weapon found in backpack!", 2)
            end

            -- Clean name from emoji
            local rawName = targetName:gsub("🛡️ ", "")
            local target = game:GetService("Players"):FindFirstChild(rawName)
            local char = target and target.Character

            -- Shield block
            local ut = char and char:FindFirstChild("UpperTorso")
            local rk = ut and ut:FindFirstChild("RKSGui")
            local sh = ut and ut:FindFirstChild("ShieldGui")
            if (rk and rk.Enabled) or (sh and sh.Enabled) then
                return NOTIFY("Protected", target.Name .. " is protected by shield!", 2)
            end

            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if root and hum and LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") then
                local oldCF = LPLR.Character.HumanoidRootPart.CFrame
                NOTIFY("Tele-Kill", "Persistent Pursuit Active: " .. target.Name, 1)

                local isKilling = true

                -- Sticky loop with death check
                task.spawn(function()
                    while isKilling and target.Parent and hum.Health > 0 do
                        -- Re-check shield during loop just in case they turn it on mid-kill
                        if (rk and rk.Enabled) or (sh and sh.Enabled) then
                            isKilling = false
                            NOTIFY("Protected", "Target activated shield!", 2)
                            break
                        end

                        local targetPos = root.Position
                        local myNewPos = (root.CFrame * CFrame.new(0, 0, 3)).Position

                        -- Keep following and facing
                        LPLR.Character.HumanoidRootPart.CFrame = CFrame.new(myNewPos,
                            Vector3.new(targetPos.X, myNewPos.Y, targetPos.Z))

                        -- Fire a burst every cycle
                        KILL_PLAYER_BURST(rawName)

                        task.wait(0.12) -- Essential delay to bypass damage caps
                    end
                    isKilling = false

                    task.wait(0.1)
                    LPLR.Character.HumanoidRootPart.CFrame = oldCF
                    NOTIFY("Tele-Kill", "Target Confirmed Dead.", 2)
                end)
            else
                NOTIFY("Error", "Target or LocalPlayer missing!", 3)
            end
        end

        ADD_BTN(C3, "Tele-Kill Player", function()
            TELE_KILL(_G.EXE.IK_TARGET)
        end)


        local C2 = MK_CARD(VR, "Player Visual Settings", "rbxassetid://10734950309")

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

        -- ── OPTIMIZER CARD ────────────────────────────────
        local C4 = MK_CARD(VL, "Optimizer", "rbxassetid://72339273614687")

        -- Button 1: Lighting & Materials
        local BoosterBtn
        local boosterText = _G.EXE.BOOSTER_ACTIVE and "Booster Applied (Active)" or "Activate FPS Booster"

        BoosterBtn = ADD_BTN(C4, boosterText, function()
            if _G.EXE.BOOSTER_ACTIVE then return NOTIFY("Warning", "Booster already active.", 2) end
            _G.EXE.BOOSTER_ACTIVE = true
            BoosterBtn.Text = "Booster Applied (Active)"
            BoosterBtn.TextColor3 = Color3.fromRGB(150, 150, 150) -- Gray out

            -- Carga el módulo Ultra FPS proporcionado
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Tagger83/FPS2/refs/heads/main/FPS2.lua"))()
            end)
            NOTIFY("Optimizer", "FPS Booster Deployed!", 3)
        end)
        if _G.EXE.BOOSTER_ACTIVE then BoosterBtn.TextColor3 = Color3.fromRGB(150, 150, 150) end

        -- Toggle: FPS Counter
        local fpsCounterGui
        local fpsCounterConnection
        ADD_TGL_KB(C4, "FPS Counter", false, nil, function(v)
            if v then
                if fpsCounterGui then return end

                local gui = Instance.new("ScreenGui")
                gui.Name = "FPSCounter"
                gui.ResetOnSpawn = false
                gui.IgnoreGuiInset = false
                gui.Parent = LPLR:WaitForChild("PlayerGui")

                local label = Instance.new("TextLabel")
                label.Parent = gui
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 8, 0, 5)
                label.Size = UDim2.new(0, 200, 0, 40)

                label.Font = Enum.Font.Arcade
                label.TextStrokeTransparency = 0
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextScaled = true
                label.Text = "FPS: 0"

                local fps = 0
                local frames = 0
                local last = tick()

                local function getColor(fps)
                    if fps >= 60 then
                        return Color3.fromRGB(0, 255, 0)   -- verde
                    elseif fps >= 30 then
                        return Color3.fromRGB(255, 170, 0) -- amarillo
                    else
                        return Color3.fromRGB(255, 0, 0)   -- rojo
                    end
                end

                fpsCounterConnection = RS.RenderStepped:Connect(function()
                    frames = frames + 1
                    if tick() - last >= 1 then
                        fps = frames
                        frames = 0
                        last = tick()
                        label.Text = "FPS: " .. fps
                        label.TextColor3 = getColor(fps)
                    end
                end)
                fpsCounterGui = gui
            else
                if fpsCounterGui then
                    fpsCounterGui:Destroy()
                    fpsCounterGui = nil
                end
                if fpsCounterConnection then
                    fpsCounterConnection:Disconnect()
                    fpsCounterConnection = nil
                end
            end
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

        local C_MOV = MK_CARD(ML, "Movements", "rbxassetid://112687695155477")
        local CPAD = C_MOV:FindFirstChildOfClass("UIPadding")
        if CPAD then
            CPAD.PaddingTop = UDim.new(0, 6)
            CPAD.PaddingBottom = UDim.new(0, 6)
        end
        local CLAY = C_MOV:FindFirstChildOfClass("UIListLayout")
        if CLAY then CLAY.Padding = UDim.new(0, 3) end

        ADD_TGL_KB(C_MOV, "WalkSpeed", false, nil, function(v)
            _G.EXE.GUN_MODS.SpeedBypass = v
            NOTIFY("Movement", "WalkSpeed: " .. (v and "Enabled" or "Disabled"), 2)
        end)
        ADD_SLD(C_MOV, "Speed Value", 0, 1000, _G.EXE.GUN_MODS.WalkBypassSpeed or 50, function(v)
            _G.EXE.GUN_MODS.WalkBypassSpeed = v
        end)
        local flyConnection
        local flyPos
        ADD_TGL_KB(C_MOV, "Player Fly", false, nil, function(v)
            local char = LPLR.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not root or not humanoid then return end

            NOTIFY("Movement", "Player Fly: " .. (v and "Enabled" or "Disabled"), 2)
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
        ADD_SLD(C_MOV, "Fly Speed", 0, 1000, _G.EXE.GUN_MODS.FlySpeed or 50, function(v)
            _G.EXE.GUN_MODS.FlySpeed = v
        end)
        infStaminaActive = false
        ADD_TGL_KB(C_MOV, "Inf Stamina", false, nil, function(v)
            infStaminaActive = v
            NOTIFY("Movement", "Inf Stamina: " .. (v and "Enabled" or "Disabled"), 2)
        end)
        ADD_TGL_KB(C_MOV, "Anti Car Hit", false, nil, function(v)
            antiCarHitActive = v
            NOTIFY("Movement", "Anti Car Hit: " .. (v and "Enabled" or "Disabled"), 2)
        end)

        local C_DRP = MK_CARD(ML, "Dropped Tools", "rbxassetid://10734950309")

        local autoScrapeConn
        ADD_TGL_KB(C_DRP, "Auto Collect Tools", false, nil, function(v)
            if v then
                NOTIFY("Dropped Tools", "Auto Collect Active", 2)
                autoScrapeConn = RS.Heartbeat:Connect(function()
                    local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Only run a lighter scan cycle (game.Workspace.Slugs or direct workspace children)
                        -- to avoid intense frame drops checking every descendant on Heartbeat
                        for _, folder in ipairs({ workspace, workspace:FindFirstChild("Slugs") }) do
                            if folder then
                                for _, item in ipairs(folder:GetChildren()) do
                                    if item:IsA("Tool") and item:FindFirstChild("Handle") then
                                        local handle = item.Handle
                                        if handle:FindFirstChildWhichIsA("TouchTransmitter") then
                                            pcall(function()
                                                firetouchinterest(hrp, handle, 0)
                                                firetouchinterest(hrp, handle, 1)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                NOTIFY("Dropped Tools", "Auto Collect Disabled", 2)
                if autoScrapeConn then
                    autoScrapeConn:Disconnect()
                    autoScrapeConn = nil
                end
            end
        end)



        -- [ UTILITIES ]
        local function FIND_NEAREST_PARK()
            local best = nil
            local dist = math.huge
            local parks = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("VehicleParks") and
                workspace.Map.VehicleParks:FindFirstChild("Spawns")
            if not parks then return nil end

            local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end

            for _, slot in ipairs(parks:GetChildren()) do
                if slot:IsA("BasePart") then
                    local d = (hrp.Position - slot.Position).Magnitude
                    if d < dist then
                        dist = d
                        best = slot
                    end
                end
            end
            return best
        end



        local noclipConnection
        ADD_TGL_KB(C_MOV, "Noclip", false, nil, function(v)
            NOTIFY("Movement", "Noclip: " .. (v and "Enabled" or "Disabled"), 2)
            if v then
                noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                    local char = LPLR.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
            end
        end)

        local C_TOL = MK_CARD(MR, "Car Spawner", "rbxassetid://122122158199543")
        local V_EV = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("VehicleEvent")

        local function GET_MY_CAR()
            local cars = workspace:FindFirstChild("Cars")
            if not cars then return nil end

            local myId = tostring(LPLR.UserId)
            local myName = LPLR.Name

            for _, car in pairs(cars:GetChildren()) do
                if car:IsA("Model") then
                    -- 1. Check Attributes
                    local owner = car:GetAttribute("OwnerId") or car:GetAttribute("Owner") or car:GetAttribute("OwnerID")
                    if tostring(owner) == myId or tostring(owner) == myName then
                        return car
                    end

                    -- 2. Check Name (some games use Car_UserId)
                    if car.Name:find(myId) or car.Name:find(myName) then
                        return car
                    end

                    -- 3. Check for specific children (ValueObjects)
                    local ov = car:FindFirstChild("Owner") or car:FindFirstChild("OwnerId") or
                        car:FindFirstChild("Creator")
                    if ov and (tostring(ov.Value) == myId or tostring(ov.Value) == myName) then
                        return car
                    end

                    -- 4. Deep search in parts (last resort)
                    for _, obj in ipairs(car:GetDescendants()) do
                        if obj:IsA("StringValue") or obj:IsA("NumberValue") or obj:IsA("IntValue") then
                            if tostring(obj.Value) == myId or tostring(obj.Value) == myName then
                                return car
                            end
                        end
                    end
                end
            end
            return nil
        end

        local D_TOL = ADD_DRP(C_TOL, "Car Tools", function(v)
            if v == "Flip Car" then
                local char = LPLR.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local veh = nil

                if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
                    veh = hum.SeatPart.Parent
                else
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Include
                        local carsFolder = workspace:FindFirstChild("Cars")
                        if carsFolder then
                            rayParams.FilterDescendantsInstances = { carsFolder }
                            local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), rayParams)
                            if ray and ray.Instance then
                                veh = ray.Instance:FindFirstAncestorOfClass("Model")
                            end
                        end

                        -- Very strict nearby scan (only 7 studs)
                        if not veh and carsFolder then
                            for _, c in pairs(carsFolder:GetChildren()) do
                                if c:IsA("Model") and c:FindFirstChild("DriveSeat") then
                                    if (hrp.Position - c.DriveSeat.Position).Magnitude < 7 then
                                        veh = c
                                        break
                                    end
                                end
                            end
                        end
                    end
                end

                if veh and veh:IsDescendantOf(workspace:FindFirstChild("Cars") or workspace) then
                    local target = veh:FindFirstChild("PrimaryPart") or veh:FindFirstChild("DriveSeat") or
                        veh:FindFirstChildWhichIsA("BasePart", true)
                    if target then
                        veh:PivotTo(CFrame.new(target.Position + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, 0))
                        NOTIFY("Car Spawner", "Vehicle flipped!", 2)
                    end
                else
                    NOTIFY("Car Spawner", "Get In Ur Car Bro!", 3)
                end
            elseif v == "Tp to Car" then
                local car = GET_MY_CAR()
                if car then
                    LPLR.Character:PivotTo(car:GetPivot() + Vector3.new(0, 5, 0))
                    NOTIFY("Car Spawner", "Teleported to car!", 2)
                else
                    NOTIFY("Car Spawner", "Your car wasn't found!", 3)
                end
            end
        end); D_TOL:ADD_MANY({ "Flip Car", "Tp to Car" })

        local D_MYC
        D_MYC = ADD_DRP(C_TOL, "My Cars", function(v)
            local park = FIND_NEAREST_PARK()
            if park then
                local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = park.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)
                    V_EV:FireServer("SpawnVehicle", v)
                    NOTIFY("Car Spawner", "Spawning " .. v .. " (Teleported)", 3)
                    task.delay(1.5, function()
                        if D_MYC then D_MYC:RESET() end
                    end)
                    return
                end
            end
            V_EV:FireServer("SpawnVehicle", v)
            NOTIFY("Car Spawner", "Spawning " .. v .. "...", 2)
            task.delay(1.5, function()
                if D_MYC then D_MYC:RESET() end
            end)
        end)



        -- [ CAR DEALER SECTION ]
        local C_DEAL = MK_CARD(MR, "Car Dealer", "rbxassetid://121291102761859")
        local sel_deal = ""
        local D_CAR = ADD_DRP(C_DEAL, "Select Vehicle", function(v) sel_deal = v end)
        local ALL_CARS = {
            { "Dodge Charger SRT Hellcat", "79k" }, { "Porsche 911 GT3RS", "96k" }, { "Cadillac CTS-V", "125k" },
            { "Ford Mustang",              "78.5k" }, { "2011 Toyota Camry", "8.5k" }, { "Scat Pack", "82k" },
            { "Cadilac Escalade", "135k" }, { "64 Impala", "64.5k" }, { "Corvette", "95k" },
            { "Chevy 2500",       "40k" }, { "The Hawk", "112k" }, { "Mercedes AMG", "103k" },
            { "Range Rover", "73k" }, { "Urus", "257k" }, { "Lamborghini Veneno", "2.5m" },
            { "Mclaren",     "235k" }, { "Rolls Royce", "547k" }, { "BMW 330I", "49k" },
            { "Lexus LS400",    "9.8k" }, { "Chrysler 300 Hellcat", "45k" }, { "Chevrolet Tahoe", "63k" },
            { "WideBody Demon", "135k" }, { "GTR R35 Widebody", "235k" }, { "DirtBike", "800" },
            { "Harley Davidson Softail", "23k" }, { "Audi R8 Widebody", "245k" }, { "Kawasaki Ninja H2R", "34.6k" },
            { "Ford F-350",              "451k" }, { "BP Brabus B63 6x6", "Game Pass" }, { "1987 Buick Regal GNX", "345k" },
            { "Shelby GT500", "285k" }, { "Maybach S 650", "310k" }, { "2020TRX", "285k" },
            { "Benz CLS 53",  "185k" }, { "Camaro ZL1", "340k" }, { "Alfa Romeo", "295k" },
            { "Bugatti Vision", "3.5m" }, { "Sprinter Van", "55k" }, { "WideBody Supra", "650k" },
            { "GoKart",         "8.5k" }, { "CyberTruck", "445k" }, { "Lamborghini Huracan", "1.8m" },
            { "4 Wheeler",         "6.5k" }, { "RollsRoyce Cullinan", "850k" }, { "Mercedes Benz GLE53", "450k" },
            { "Aston Marton DBX3", "650k" }, { "Mini k Truck", "14k" }, { "Jeep Grand Cherokee srt-8", "46k" },
            { "M4 Comp",    "450k" }, { "Ferrari 812", "3.5m" }, { "Dodge Durango", "195k" },
            { "Chevy Donk", "265k" }, { "Dodge Charger SRT", "175k" }, { "G wagon", "2.8m" },
            { "2011 Lincoln Town Car",                 "32k" }, { "Lincoln Limousine", "210k" }, { "Infiniti G37", "160k" },
            { "2023 Corvette C8 Stingray Convertible", "548k" }, { "Kia 5K GT", "135k" }
        }

        local function RefreshDealerList()
            local displayNames = {}
            for _, car in ipairs(ALL_CARS) do
                table.insert(displayNames, car[1] .. " | " .. car[2])
            end
            pcall(function() D_CAR:REFRESH(displayNames) end)
        end

        ADD_BTN(C_DEAL, "Purchase Vehicle", function()
            if sel_deal ~= "" then
                local realName = sel_deal:split(" | ")[1]
                V_EV:FireServer("BuyVehicle", realName)
                NOTIFY("Car Dealer", "Requesting purchase: " .. realName, 3)
                task.wait(0.5)
                RefreshDealerList()
            end
        end)

        RefreshDealerList()

        -- Monitor owned cars (Using working Utility module)
        task.spawn(function()
            local utility
            pcall(function()
                utility = require(game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Utility"))
            end)

            while task.wait(5) do
                if MAIN.Visible then
                    local names = {}
                    if utility then
                        pcall(function()
                            local data = utility:GetClientData()
                            if data and data.Cars then
                                for _, car in pairs(data.Cars) do
                                    -- Recuperar el nombre real del coche según la tabla del juego
                                    local n = (typeof(car) == "table" and (car.Name or car.VehicleName or car.Model)) or
                                        tostring(car)
                                    table.insert(names, n)
                                end
                            end
                        end)
                    end

                    if #names > 0 then
                        table.sort(names)
                        task.spawn(function()
                            D_MYC:REFRESH(names)
                        end)
                    end
                end
            end
        end)

        -- [ EXTRAS SECTION ]
        local C_EXT = MK_CARD(MR, "Extras", "rbxassetid://106507089706013")

        local selPlr = nil
        local sndAmt = "0"

        local D_PLR = ADD_DRP(C_EXT, "Target Player", function(v)
            selPlr = v
        end)

        local function update_plrs()
            local names = {}
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LPLR then table.insert(names, p.Name) end
            end
            D_PLR:REFRESH(names)
        end

        update_plrs()
        game.Players.PlayerAdded:Connect(update_plrs)
        game.Players.PlayerRemoving:Connect(update_plrs)

        local AMT_INP = ADD_INP(C_EXT, "Amount to Send", "0", function(v)
            sndAmt = v:gsub("[^%d]", "")
        end)

        ADD_BTN(C_EXT, "Send Money", function()
            if not selPlr or selPlr == "" then return NOTIFY("Extras", "Please select a target player first!", 2) end

            local numAmt = tonumber(sndAmt)
            if not numAmt or numAmt <= 0 then return NOTIFY("Extras", "Please input a valid amount to send!", 2) end

            -- NYC limit max per transaccion (Interception constraint)
            if numAmt > 100000 then
                sndAmt = "100000"
                AMT_INP.Text = "100000"
                return NOTIFY("Extras", "Max limit is 100k! Adjusted. Click Send again.", 3)
            end

            pcall(function()
                local event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SendMoney")
                event:FireServer(selPlr, numAmt)
            end)

            NOTIFY("Extras", "Transferred $" .. tostring(numAmt) .. " to " .. selPlr, 3)
        end)

        ADD_BTN(C_EXT, "Clean All Dirty Money", function()
            local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return NOTIFY("Laundromat", "Character Not Found!", 2) end

            -- Guarda la posición original del jugador antes de escaparse a lavar dinero
            local initialPos = hrp.CFrame
            local laundromatPos = CFrame.new(-58, 90, 412)

            NOTIFY("Laundromat", "Teleporting to Laundry...", 2)
            if typeof(DO_TP) == "function" then
                DO_TP(laundromatPos)
            else
                hrp.CFrame = laundromatPos
            end

            task.wait(0.5) -- Pausa mínima para que el servidor procese el TP interior

            local dryers = workspace:FindFirstChild("MoneyDryers")
            if dryers then
                local children = dryers:GetChildren()
                local dryer5 = children[93] and children[93]:FindFirstChild("WashingPromptPart") and
                    children[93].WashingPromptPart:FindFirstChild("ProximityPrompt")
                local dryer4 = children[94] and children[94]:FindFirstChild("WashingPromptPart") and
                    children[94].WashingPromptPart:FindFirstChild("ProximityPrompt")

                if dryer4 and dryer5 then
                    NOTIFY("Laundromat", "Laundering Cash... (Hold)", 2)
                    for _ = 1, 20 do
                        task.spawn(function()
                            pcall(function() fireproximityprompt(dryer5) end)
                        end)
                        task.spawn(function()
                            pcall(function() fireproximityprompt(dryer4) end)
                        end)
                    end
                    task.wait(1.5) -- Darle tiempo a los prompts a quemarse (se activa instantáneo por el x20 override)
                else
                    NOTIFY("Laundromat", "Dryers Not Loaded! Cancelling...", 3)
                end
            else
                NOTIFY("Laundromat", "MoneyDryers Folder Not Found!", 3)
            end

            -- Retorno Físico Invisible
            NOTIFY("Laundromat", "Job Finished! Returning...", 2)
            if typeof(DO_TP) == "function" then
                DO_TP(initialPos)
            else
                hrp.CFrame = initialPos
            end
        end)
    end
    task.spawn(SETUP_MISC)

    local function SETUP_OTHERS()
        local CL, CR = ADD_SPLIT(P_OTH)
        CL.Parent.Size = UDim2.new(1, -10, 1, -10)
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

        local C_CARMODS = MK_CARD(CL, "Cars Mods", "rbxassetid://77304301427389")

        -- Car Fly variables & helpers
        local isCarFlying = false
        local currentVehicle = nil
        local flyBV, flyBG
        local carFlyConnection

        local function get_vic()
            local char = LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
                return hum.SeatPart.Parent, hum.SeatPart
            end
            return nil, nil
        end

        local function cleanupCarFly()
            if flyBV then
                flyBV:Destroy(); flyBV = nil
            end
            if flyBG then
                flyBG:Destroy(); flyBG = nil
            end
            if carFlyConnection then
                carFlyConnection:Disconnect(); carFlyConnection = nil
            end
            isCarFlying = false
        end

        local CarFlyTgl = nil
        CarFlyTgl = ADD_TGL_KB(C_CARMODS, "Car Fly", false, nil, function(v)
            isCarFlying = v
            if not v then
                cleanupCarFly()
                return
            end

            local vic, seat = get_vic()
            if not vic or not seat then
                NOTIFY("Movement", "Please sit in a DriveSeat first!", 3)
                isCarFlying = false
                task.spawn(function() CarFlyTgl:SET(false) end)
                return
            end

            currentVehicle = vic
            local root = vic.PrimaryPart or seat

            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = root

            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyBG.CFrame = root.CFrame
            flyBG.P = 5000
            flyBG.Parent = root

            carFlyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local vic, seat = get_vic()
                if not vic or not isCarFlying then
                    cleanupCarFly()
                    if CarFlyTgl.SET then CarFlyTgl:SET(false) end
                    return
                end

                local root = vic.PrimaryPart or seat
                local camCF = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0, 0, 0)

                local UIS = game:GetService("UserInputService")
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    flyBV.Velocity = moveDir.Unit * _G.EXE.GUN_MODS.CarFlySpeed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end

                flyBG.CFrame = camCF
            end)

            NOTIFY("Movement", "Car Fly Enabled", 2)
        end)

        ADD_SLD(C_CARMODS, "Car Fly Speed", 0, 1000, _G.EXE.GUN_MODS.CarFlySpeed or 150, function(v)
            _G.EXE.GUN_MODS.CarFlySpeed = v
        end)

        -- Car Speed logic
        local carSpeedConnection
        local isCarSpeed = false
        local carSpeedValue = 150

        local CarSpeedTgl = nil
        CarSpeedTgl = ADD_TGL(C_CARMODS, "Car Speed", false, function(v)
            isCarSpeed = v
            if v then
                carSpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local vic, seat = get_vic()
                    if vic and seat then
                        local root = vic.PrimaryPart or seat
                        if seat.Throttle == 1 then
                            local vel = root.CFrame.LookVector * carSpeedValue
                            root.AssemblyLinearVelocity = Vector3.new(vel.X, root.AssemblyLinearVelocity.Y, vel.Z)
                        elseif seat.Throttle == -1 then
                            local vel = -root.CFrame.LookVector * (carSpeedValue * 0.6)
                            root.AssemblyLinearVelocity = Vector3.new(vel.X, root.AssemblyLinearVelocity.Y, vel.Z)
                        end
                    end
                end)
                NOTIFY("Car Mods", "Car Speed Enabled", 2)
            else
                if carSpeedConnection then
                    carSpeedConnection:Disconnect()
                    carSpeedConnection = nil
                end
                NOTIFY("Car Mods", "Car Speed Disabled", 2)
            end
        end)

        ADD_SLD(C_CARMODS, "Car Speed Value", 50, 500, 150, function(v)
            carSpeedValue = v
        end)


        -- Infinite Fuel logic
        local infFuelConnection
        ADD_TGL_KB(C_CARMODS, "Infinite Fuel", false, nil, function(v)
            if v then
                NOTIFY("Car Mods", "Infinite Fuel Enabled", 2)
                infFuelConnection = RS.Heartbeat:Connect(function()
                    local char = LPLR.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
                        pcall(function()
                            local car = hum.SeatPart.Parent
                            local fuelRemote = game:GetService("ReplicatedStorage"):FindFirstChild("FuelRemotes")
                            if fuelRemote and fuelRemote:FindFirstChild("SetFuel") then
                                fuelRemote.SetFuel:FireServer(car, 999999)
                            end
                        end)
                    end
                end)
            else
                NOTIFY("Car Mods", "Infinite Fuel Disabled", 2)
                if infFuelConnection then
                    infFuelConnection:Disconnect()
                    infFuelConnection = nil
                end
            end
        end)

        -- Instant Brake logic
        local instantBrakeConnection
        local isInstantBrake = false
        ADD_TGL(C_CARMODS, "Instant Brake", false, function(v)
            isInstantBrake = v
            if v then
                instantBrakeConnection = game:GetService("UserInputService").InputBegan:Connect(function(input,
                                                                                                         gameProcessedEvent)
                    if gameProcessedEvent then return end
                    if input.KeyCode == Enum.KeyCode.S and isInstantBrake then
                        pcall(function()
                            local char = LPLR.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
                                local car = hum.SeatPart.Parent
                                local root = car.PrimaryPart or hum.SeatPart
                                if root then
                                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end)
                    end
                end)
                NOTIFY("Car Mods", "Instant Brake Enabled", 2)
            else
                if instantBrakeConnection then
                    instantBrakeConnection:Disconnect()
                    instantBrakeConnection = nil
                end
                NOTIFY("Car Mods", "Instant Brake Disabled", 2)
            end
        end)

        -- Auto Backfire logic
        local backfireThread
        local isBackfire = false
        ADD_TGL(C_CARMODS, "Auto Backfire", false, function(v)
            isBackfire = v
            if v then
                backfireThread = task.spawn(function()
                    while isBackfire do
                        pcall(function()
                            local vic, _ = get_vic()
                            if vic then
                                local evt = vic:FindFirstChild("Backfire_FE")
                                if evt then
                                    evt:FireServer("Backfire2")
                                end
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
                NOTIFY("Car Mods", "Auto Backfire Enabled", 2)
            else
                isBackfire = false
                if backfireThread then
                    task.cancel(backfireThread)
                    backfireThread = nil
                end
                NOTIFY("Car Mods", "Auto Backfire Disabled", 2)
            end
        end)
    end
    task.spawn(SETUP_OTHERS)

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
            PL.Padding = UDim.new(0, 4)
            PL.SortOrder = Enum.SortOrder.LayoutOrder

            local PAD = Instance.new("UIPadding", C)
            PAD.PaddingTop, PAD.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
            PAD.PaddingLeft, PAD.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)

            local H = Instance.new("Frame", C)
            H.Name = "Header"
            H.Size = UDim2.new(1, 0, 0, 30)
            H.LayoutOrder = 0
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
        local initialThemeIcon = "🔴"
        for _, th in ipairs(THEME_LIST) do
            if th.name == CurThemeName then
                initialThemeIcon = th.icon
                break
            end
        end
        D_THEME.BTN.Text = "  " .. initialThemeIcon .. "  " .. CurThemeName
        local thH = #THEME_LIST * 30
        D_THEME.SCR.Size = UDim2.new(1, 0, 0, thH)
        D_THEME.OPEN(thH)
        D_THEME.CLOSE()

        for i, t in ipairs(THEME_LIST) do
            local themeName = t.name
            local themeIcon = t.icon
            local ITM = Instance.new("TextButton", D_THEME.SCR)
            ITM.Size = UDim2.new(1, 0, 0, 30)
            ITM.BackgroundTransparency = 1
            ITM.Text = "  " .. themeIcon .. "  " .. themeName
            ITM.TextColor3 = CFG.COL.TXT
            ITM.Font = Enum.Font.Gotham
            ITM.TextSize = 13
            ITM.TextXAlignment = Enum.TextXAlignment.Left
            ITM.ZIndex = 21
            ITM.LayoutOrder = i
            ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
            ITM.MouseLeave:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.TXT }, 0.1) end)
            ITM.MouseButton1Click:Connect(function()
                D_THEME.BTN.Text = "  " .. themeIcon .. "  " .. themeName
                D_THEME.CLOSE()
                APPLY_THEME(themeName)
                NOTIFY("Theme", themeName .. " applied!", 3)
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
        D_FONT.BTN.Text = "  " .. CurFontName
        local fH = #FONT_LIST * 30
        D_FONT.SCR.Size = UDim2.new(1, 0, 0, fH)
        D_FONT.OPEN(fH)
        D_FONT.CLOSE()

        for i, f in ipairs(FONT_LIST) do
            local fontName = f.name
            local fontEnum = f.font
            local ITM = Instance.new("TextButton", D_FONT.SCR)
            ITM.Size = UDim2.new(1, 0, 0, 30)
            ITM.BackgroundTransparency = 1
            ITM.Text = "  " .. fontName
            ITM.TextColor3 = CFG.COL.TXT
            ITM.Font = Enum.Font.Gotham
            ITM.TextSize = 13
            ITM.TextXAlignment = Enum.TextXAlignment.Left
            ITM.ZIndex = 21
            ITM.LayoutOrder = i
            ITM.MouseEnter:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.ACC }, 0.1) end)
            ITM.MouseLeave:Connect(function() TWN(ITM, { TextColor3 = CFG.COL.TXT }, 0.1) end)
            ITM.MouseButton1Click:Connect(function()
                D_FONT.BTN.Text = "  " .. fontName
                D_FONT.CLOSE()
                -- Aplicar fuente al UI completo
                APPLY_FONT_UI(fontEnum)
                -- Actualizar ESP font (usa Enum.Font directamente)
                CurFontName = fontName
                SAVE_CONFIG()
                ESP_CFG.Font = fontEnum
                NOTIFY("Font", fontName .. " applied!", 3)
            end)
        end

        -- ── CUSTOM BACKGROUND CARD ─────────────────────────────
        local BG_CARD = MK_CARD(CL, "Custom Interface", "rbxassetid://10734950309")
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


        -- ── EXTRAS & SERVER UTILITIES CARD ──────────────────────
        local EXTRAS_CARD = MK_CARD(CR, "Extras", "rbxassetid://106507089706013")
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
        ADD_BTN(EXTRAS_CARD, "Join Lowest Server", JoinLowest)
        ADD_BTN(EXTRAS_CARD, "Server Hop", ServerHop)
        ADD_BTN(EXTRAS_CARD, "Rejoin", function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LPLR)
        end)

        -- [ SECURITY SECTION ]
        local C_SEC = MK_CARD(CL, "Security", "rbxassetid://139776974994926")
        C_SEC.LayoutOrder = 11

        local function STYLE_ROW(obj)
            obj.BackgroundColor3 = CFG.COL.BG
            obj.BackgroundTransparency = 0.5
            RND(obj, 8)
            local S = STR(obj, CFG.COL.ACC, 1.2)
            S.Transparency = 0.7

            -- Padding interno para que el texto no pegue al borde
            local P = Instance.new("UIPadding", obj)
            P.PaddingLeft = UDim.new(0, 8)
            P.PaddingRight = UDim.new(0, 8)
        end

        local adminConnection
        local T_ADM = ADD_TOG(C_SEC, "Admin Detector", _G.EXE.SECURITY.AdminDetector, function(v)
            _G.EXE.SECURITY.AdminDetector = v
            local Players = game:GetService("Players")
            local AdminIDs = {
                [193675379] = "Owner",
                [7270095233] = "Admin",
                [6219914993] = "Admin",
                [169641570] = "Admin",
                [167283473] = "Admin",
                [7322940967] = "Admin",
                [4775061] = "Admin",
                [2473529312] = "Admin",
                [154943097] = "Admin",
                [8162310250] = "Admin",
                [3106275464] = "Analytics",
                [1748679794] = "Tester",
                [443186070] = "Tester",
                [2520899372] = "Tester",
                [429393318] = "Tester",
                [8469523389] = "Tester",
                [1257073083] = "Contributor"
            }

            local function KickPlayer()
                Players.LocalPlayer:Kick("Admin detected! Changing server...")
                task.wait(2)

                local HttpService = game:GetService("HttpService")
                local TeleportService = game:GetService("TeleportService")
                local PlaceId = game.PlaceId
                local url = "https://games.roblox.com/v1/games/" .. tostring(PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"

                local function getServers(c)
                    local u = c and (url .. "&cursor=" .. c) or url
                    local s, r = pcall(function() return HttpService:JSONDecode(game:HttpGet(u)) end)
                    return (s and r and r.data) and r or nil
                end

                local serverToHop, cursor = nil, nil
                while not serverToHop do
                    local data = getServers(cursor)
                    if data and data.data then
                        for _, sv in ipairs(data.data) do
                            if type(sv) == "table" and sv.id ~= game.JobId and sv.playing and sv.playing < sv.maxPlayers - 1 then
                                serverToHop = sv.id
                                break
                            end
                        end
                        cursor = data.nextPageCursor
                        if not cursor then break end
                    else
                        break
                    end
                end

                if serverToHop then
                    TeleportService:TeleportToPlaceInstance(PlaceId, serverToHop, Players.LocalPlayer)
                else
                    TeleportService:Teleport(PlaceId, Players.LocalPlayer)
                end
            end

            local function checkAdmin(plr)
                if AdminIDs[plr.UserId] then
                    KickPlayer()
                end
            end

            if v then
                NOTIFY("Security", "Admin Detector: Enabled", 2)
                if not adminConnection then
                    adminConnection = Players.PlayerAdded:Connect(checkAdmin)
                    for _, plr in ipairs(Players:GetPlayers()) do
                        checkAdmin(plr)
                    end
                end
            else
                NOTIFY("Security", "Admin Detector: Disabled", 2)
                if adminConnection then
                    adminConnection:Disconnect()
                    adminConnection = nil
                end
            end
        end, true)
        T_ADM.ROW.LayoutOrder = 1
        STYLE_ROW(T_ADM.ROW)

        local T_ALV = ADD_TOG(C_SEC, "Auto-Leave", _G.EXE.SECURITY.AutoLeave, function(v)
            _G.EXE.SECURITY.AutoLeave = v
            NOTIFY("Security", "Auto-Leave: " .. (v and "Enabled" or "Disabled"), 2)
        end, true)
        T_ALV.ROW.LayoutOrder = 2
        STYLE_ROW(T_ALV.ROW)

        -- [ BETA OPTIONS SECTION ]
        local BETA_CARD = MK_CARD(CL, "Beta Options", "rbxassetid://106507089706013")
        BETA_CARD.LayoutOrder = 12

        local T_BETA = ADD_TOG(BETA_CARD, "Sidebar Tabs (Beta)", CurSidebarTabs, function(v)
            CurSidebarTabs = v
            UPDATE_SIDEBAR_MODE(v)
            SAVE_CONFIG()
        end, true)
        T_BETA.ROW.LayoutOrder = 1
        STYLE_ROW(T_BETA.ROW)

        local T_SMOOTH_DRAG = ADD_TOG(BETA_CARD, "Enable Smooth UI Drag", CurSmoothDrag, function(v)
            CurSmoothDrag = v
            SAVE_CONFIG()
        end, true)
        T_SMOOTH_DRAG.ROW.LayoutOrder = 2
        STYLE_ROW(T_SMOOTH_DRAG.ROW)
    end
    task.spawn(SETUP_CONFIG)

    -- Startup state
    task.spawn(function()
        CUR_BTN = B_HOM
        CUR_PAG = P_HOM
        UPDATE_TAB_VISUALS(B_HOM, true)
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
                    I.Changed:Connect(function()
                        if I.UserInputState == Enum.UserInputState.End then
                            RS_S.ON = false
                            CurSizeX = MAIN.Size.X.Offset
                            CurSizeY = MAIN.Size.Y.Offset
                            SAVE_CONFIG()
                        end
                    end)
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
                if MAIN.Visible and RefreshDealerList then RefreshDealerList() end
            end
        end)

        -- [ MOBILE SUPPORT ]
        do
            if UIS.TouchEnabled then
                local MB_S = { ON = false, ST = nil, PS = nil, IP = nil }
                MAIN.AnchorPoint = Vector2.new(0.5, 0.5)
                MAIN.Position = UDim2.new(0.5, 0, 0.5, 0)
                -- (Size is already safely handled during creation)

                local MTOG = Instance.new("ImageButton", SCR)
                MTOG.Name, MTOG.Size, MTOG.Position = "MTOG", UDim2.new(0, 50, 0, 50), UDim2.new(1, -70, 0.2, 0)
                MTOG.BackgroundColor3, MTOG.BackgroundTransparency, MTOG.Image = CFG.COL.BG, 0.2, CFG.IMG
                MTOG.ImageColor3, MTOG.ZIndex = CFG.COL.ACC, 100
                RND(MTOG, 25); STR(MTOG, CFG.COL.ACC, 2)

                MTOG.MouseButton1Click:Connect(function()
                    MAIN.Visible = not MAIN.Visible
                    if MAIN.Visible and RefreshDealerList then RefreshDealerList() end
                end)
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
        APPLY_THEME(CurThemeName)
        APPLY_FONT_UI(Enum.Font[CurFontName] or Enum.Font.GothamBold)
        pcall(function()
            if MAIN:FindFirstChild("BG") then
                MAIN.BG.ImageTransparency = CurBGTrans
            end
        end)
        pcall(function()
            UPDATE_SIDEBAR_MODE(CurSidebarTabs)
        end)
    end) -- end global init spawn

    NOTIFY("WH01AM", "SCRIPT LOADED!", 4)
end
BUILD_NYH_UI()
