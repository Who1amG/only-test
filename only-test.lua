-- UI Script - Apple Glass Dark (Expandible + Auto Farm Logic)
-- FIXED: Anti-Duplicate + Game Verification (Obfuscation Safe)

-- ============================================
-- [ VERIFICACIÓN DE JUEGO ] - OBFUSCATION SAFE
-- ============================================
local function verifyGame()
    -- PlaceId correcto extraído de la URL
    local validPlaceId = 129827112113663
    local currentPlaceId = game.PlaceId
    
    -- Verificación con múltiples métodos (anti-obfuscation bypass)
    local isValid = (currentPlaceId == validPlaceId)
    
    if not isValid then
        local player = game:GetService("Players").LocalPlayer
        if player then
            player:Kick("❌ INCORRECT GAME!\n\nThis script only works in Prospecting.\nJoin the correct game to use it.")
        end
        return false
    end
    
    return true
end

-- Ejecutar verificación inmediata
if not verifyGame() then
    return -- Terminar ejecución si no es el juego correcto
end

-- ============================================
-- [ ANTI-DUPLICATE MEJORADO ] - OBFUSCATION SAFE
-- ============================================
-- Verificar si ya existe una instancia previa
if _G.ProspectingHubActive then
    -- Notificar al usuario
    if game:GetService("StarterGui") then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⚠️ Script Already Running",
                Text = "Stopping previous instance...",
                Duration = 3
            })
        end)
    end
    
    -- Llamar función de limpieza si existe
    if _G.ProspectingHubShutdown then
        pcall(_G.ProspectingHubShutdown)
    end
    
    -- Esperar limpieza completa
    task.wait(0.8)
end

-- Marcar como activo INMEDIATAMENTE
_G.ProspectingHubActive = true

-- ============================================
-- [ SERVICIOS Y VARIABLES GLOBALES ]
-- ============================================
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PLS = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LP = PLS.LocalPlayer

-- ============================================
-- [ THEME & SETTINGS SYSTEM ]
-- ============================================
local Themes = {
    Dark = {MainBg = Color3.fromRGB(18, 18, 22), TitleBg = Color3.fromRGB(22, 22, 30), Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(150, 150, 170), Button = Color3.fromRGB(25, 25, 35), Stroke = Color3.fromRGB(90, 90, 110), Accent = Color3.fromRGB(100, 150, 255)},
    Ocean = {MainBg = Color3.fromRGB(10, 20, 30), TitleBg = Color3.fromRGB(15, 30, 45), Text = Color3.fromRGB(220, 240, 255), SubText = Color3.fromRGB(100, 150, 200), Button = Color3.fromRGB(20, 40, 60), Stroke = Color3.fromRGB(40, 80, 120), Accent = Color3.fromRGB(0, 180, 255)},
    Forest = {MainBg = Color3.fromRGB(15, 25, 15), TitleBg = Color3.fromRGB(20, 35, 20), Text = Color3.fromRGB(220, 255, 220), SubText = Color3.fromRGB(120, 180, 120), Button = Color3.fromRGB(25, 45, 25), Stroke = Color3.fromRGB(50, 90, 50), Accent = Color3.fromRGB(80, 220, 120)},
    Crimson = {MainBg = Color3.fromRGB(25, 10, 10), TitleBg = Color3.fromRGB(35, 15, 15), Text = Color3.fromRGB(255, 220, 220), SubText = Color3.fromRGB(180, 100, 100), Button = Color3.fromRGB(50, 20, 20), Stroke = Color3.fromRGB(100, 40, 40), Accent = Color3.fromRGB(255, 80, 80)},
    Gold = {MainBg = Color3.fromRGB(20, 18, 10), TitleBg = Color3.fromRGB(30, 25, 15), Text = Color3.fromRGB(255, 240, 200), SubText = Color3.fromRGB(180, 160, 100), Button = Color3.fromRGB(45, 35, 20), Stroke = Color3.fromRGB(140, 110, 40), Accent = Color3.fromRGB(255, 200, 50)}
}

local Fonts = {
    Modern = {Header = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Scale = 1.0},
    Retro = {Header = Enum.Font.Arcade, Body = Enum.Font.Arcade, Scale = 1.25},
    Tech = {Header = Enum.Font.Michroma, Body = Enum.Font.Code, Scale = 1.0},
    Elegant = {Header = Enum.Font.Garamond, Body = Enum.Font.Garamond, Scale = 1.3}
}

local ThemeRegistry = {MainBg={}, TitleBg={}, Text={}, SubText={}, Button={}, Stroke={}, Accent={}}
local CurrentSettings = {Theme = "Dark", Font = "Modern"}

-- Persistence
local SettingsFile = "Prospecting_Settings.json"
pcall(function()
    if isfile and isfile(SettingsFile) then
        local data = HttpService:JSONDecode(readfile(SettingsFile))
        if data then 
            CurrentSettings = data 
            -- Migration: Classic -> Retro
            if CurrentSettings.Font == "Classic" then CurrentSettings.Font = "Retro" end
        end
    end
end)

local function SaveSettings()
    pcall(function()
        if writefile then writefile(SettingsFile, HttpService:JSONEncode(CurrentSettings)) end
    end)
end

local function RegisterTheme(instance, type)
    if not ThemeRegistry[type] then ThemeRegistry[type] = {} end
    table.insert(ThemeRegistry[type], instance)
    
    local thm = Themes[CurrentSettings.Theme] or Themes.Dark
    local fnt = Fonts[CurrentSettings.Font] or Fonts.Modern
    
    if type == "MainBg" then instance.BackgroundColor3 = thm.MainBg
    elseif type == "TitleBg" then instance.BackgroundColor3 = thm.TitleBg
    elseif type == "Text" then 
        instance.TextColor3 = thm.Text
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then 
            instance.Font = fnt.Header 
            if not instance:GetAttribute("BaseSize") then instance:SetAttribute("BaseSize", instance.TextSize) end
            instance.TextSize = instance:GetAttribute("BaseSize") * (fnt.Scale or 1)
        end
    elseif type == "SubText" then 
        instance.TextColor3 = thm.SubText
        if instance:IsA("TextLabel") or instance:IsA("TextButton") then 
            instance.Font = fnt.Body 
            if not instance:GetAttribute("BaseSize") then instance:SetAttribute("BaseSize", instance.TextSize) end
            instance.TextSize = instance:GetAttribute("BaseSize") * (fnt.Scale or 1)
        end
    elseif type == "Button" then 
        instance.BackgroundColor3 = thm.Button
    elseif type == "Stroke" then instance.Color = thm.Stroke
    elseif type == "Accent" then
        if instance:IsA("ImageLabel") then instance.ImageColor3 = thm.Accent
        else instance.BackgroundColor3 = thm.Accent end
    elseif type == "DarkBg" then
        -- Calcula un color más oscuro basado en MainBg
        instance.BackgroundColor3 = thm.MainBg:Lerp(Color3.new(0, 0, 0), 0.3)
    elseif type == "ScrollBar" then
        instance.ScrollBarImageColor3 = thm.Accent
    end
end

local function UpdateAllThemes()
    local thm = Themes[CurrentSettings.Theme] or Themes.Dark
    local fnt = Fonts[CurrentSettings.Font] or Fonts.Modern
    
    for _, obj in pairs(ThemeRegistry.MainBg or {}) do obj.BackgroundColor3 = thm.MainBg end
    for _, obj in pairs(ThemeRegistry.TitleBg or {}) do obj.BackgroundColor3 = thm.TitleBg end
    for _, obj in pairs(ThemeRegistry.Text or {}) do 
        obj.TextColor3 = thm.Text 
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then 
            obj.Font = fnt.Header 
            if obj:GetAttribute("BaseSize") then
                obj.TextSize = obj:GetAttribute("BaseSize") * (fnt.Scale or 1)
            end
        end
    end
    for _, obj in pairs(ThemeRegistry.SubText or {}) do 
        obj.TextColor3 = thm.SubText 
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then 
            obj.Font = fnt.Body 
            if obj:GetAttribute("BaseSize") then
                obj.TextSize = obj:GetAttribute("BaseSize") * (fnt.Scale or 1)
            end
        end
    end
    for _, obj in pairs(ThemeRegistry.Button or {}) do obj.BackgroundColor3 = thm.Button end
    for _, obj in pairs(ThemeRegistry.Stroke or {}) do obj.Color = thm.Stroke end
    for _, obj in pairs(ThemeRegistry.Accent or {}) do 
        if obj:IsA("ImageLabel") then obj.ImageColor3 = thm.Accent
        else obj.BackgroundColor3 = thm.Accent end
    end
    for _, obj in pairs(ThemeRegistry.DarkBg or {}) do
        -- 30% más oscuro que el MainBg actual
        obj.BackgroundColor3 = thm.MainBg:Lerp(Color3.new(0, 0, 0), 0.3)
    end
    for _, obj in pairs(ThemeRegistry.ScrollBar or {}) do
        obj.ScrollBarImageColor3 = thm.Accent
    end
    
    -- Refrescar botones de pestañas en Marketplace
    if tabsCont then
        for _, btn in ipairs(tabsCont:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Font = fnt.Header
                if btn.Text == currentTab then
                    btn.BackgroundColor3 = thm.Accent
                    btn.TextColor3 = thm.Text
                else
                    btn.BackgroundColor3 = thm.Button
                    btn.TextColor3 = thm.SubText
                end
            end
        end
    end

    -- Refrescar Marketplace si está visible para actualizar items dinámicos
    if StoreUI and StoreUI.Visible then
        loadTab(currentTab)
    end
    
    SaveSettings()
end

-- ============================================
-- [ DISCORD WEBHOOK SYSTEM ]
-- ============================================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1469940422095798477/lc9ZYzBJGm82CWMJYkwWwJvz4UwxynwzxnawGqK3MmtSlq2oKA9BubP7ahokkQ_Qh5KO"

local function sendToWebhook(content, statusType, force)
    -- FILTRO: Si force es true, envía siempre. Si no, solo envía errores.
    if not force and statusType ~= "error" then
        return 
    end

    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not requestFunc then return end

    local color = 16711680 -- Rojo (Error) por defecto
    local title = "⚠️ Error Log"

    if statusType == "success" then
        color = 65280 -- Verde
        title = "✅ Status Report"
    elseif statusType == "warning" then
        color = 16776960 -- Amarillo
        title = "⚠️ Warning Log"
    end

    local embed = {
        {
            ["title"] = title,
            ["description"] = content,
            ["color"] = color,
            ["fields"] = {
                {
                    ["name"] = "Player",
                    ["value"] = LP.Name,
                    ["inline"] = true
                },
                {
                    ["name"] = "Time",
                    ["value"] = os.date("%X"),
                    ["inline"] = true
                },
                {
                    ["name"] = "Game ID",
                    ["value"] = tostring(game.PlaceId),
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Auto Farm Logger"
            }
        }
    }

    local jsonData = HttpService:JSONEncode({embeds = embed})

    task.spawn(function()
        pcall(function()
            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
        end)
    end)
end

-- ============================================
-- [ HEALTH CHECK SYSTEM ]
-- ============================================
local function runHealthCheck()
    local report = {}
    local errors = 0
    
    table.insert(report, "**Initialization Report:**")
    
    -- 1. Verificar Remotes Críticos
    local RS = game:GetService("ReplicatedStorage")
    if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Shop") then
        table.insert(report, "✅ Shop Remotes: OK")
    else
        table.insert(report, "❌ Shop Remotes: MISSING")
        errors = errors + 1
    end
    
    -- 2. Verificar Entorno
    if workspace:FindFirstChild("Purchasable") then
        table.insert(report, "✅ Shop Folder: OK")
    else
        table.insert(report, "⚠️ Shop Folder: NOT FOUND (Map might not be loaded)")
        -- No es error crítico, pero es warning
    end

    -- 3. Estado del Jugador
    if LP.Character then
        table.insert(report, "✅ Character: OK")
    else
        table.insert(report, "❌ Character: NOT FOUND")
        errors = errors + 1
    end

    local finalStatus = errors == 0 and "success" or "error"
    local finalMessage = table.concat(report, "\n")
    
    if errors == 0 then
        finalMessage = finalMessage .. "\n\n🚀 Script loaded successfully with no critical errors."
    else
        finalMessage = finalMessage .. "\n\n⛔ Script loaded with " .. errors .. " critical errors."
    end
    
    -- Enviar reporte forzado
    sendToWebhook(finalMessage, finalStatus, true)
end

-- Detección de dispositivo
local function isDv()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local isMb = isDv()
local scW = isMb and 340 or 520
local scH = isMb and 320 or 440

-- ============================================
-- [ CREAR SCREENGUI ]
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "APUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protección según executor
if syn then
    syn.protect_gui(SG)
    SG.Parent = game.CoreGui
elseif gethui then
    SG.Parent = gethui()
else
    SG.Parent = LP:WaitForChild("PlayerGui")
end

-- Frame Principal
local MF = Instance.new("Frame")
MF.Name = "MF"
MF.Size = UDim2.new(0, scW, 0, scH)
MF.Position = UDim2.new(0.5, -scW/2, 0.5, -scH/2)
MF.BackgroundTransparency = 0.12
MF.BorderSizePixel = 0
MF.ClipsDescendants = true
MF.Parent = SG

RegisterTheme(MF, "MainBg")

-- Efecto Glass
local GE = Instance.new("ImageLabel")
GE.Name = "GE"
GE.Size = UDim2.new(1, 0, 1, 0)
GE.BackgroundTransparency = 1
GE.Image = "rbxassetid://8992230677"
GE.ImageColor3 = Color3.fromRGB(25, 25, 35)
GE.ImageTransparency = 0.75
GE.ScaleType = Enum.ScaleType.Tile
GE.TileSize = UDim2.new(0, 100, 0, 100)
GE.Parent = MF

local CR1 = Instance.new("UICorner")
CR1.CornerRadius = UDim.new(0, isMb and 16 or 18)
CR1.Parent = MF

local STK = Instance.new("UIStroke")
STK.Thickness = 1.2
STK.Transparency = 0.6
STK.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
STK.Parent = MF

RegisterTheme(STK, "Stroke")

local GRD = Instance.new("UIGradient")
GRD.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 140, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 90, 140)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 180))
}
GRD.Rotation = 45
GRD.Parent = STK

-- Barra de Título
local TB = Instance.new("Frame")
TB.Name = "TB"
TB.Size = UDim2.new(1, 0, 0, isMb and 42 or 48)
TB.BackgroundTransparency = 0.25
TB.BorderSizePixel = 0
TB.Parent = MF

RegisterTheme(TB, "TitleBg")

local CR2 = Instance.new("UICorner")
CR2.CornerRadius = UDim.new(0, isMb and 16 or 18)
CR2.Parent = TB

-- Título
local TT = Instance.new("TextLabel")
TT.Name = "TT"
TT.Size = UDim2.new(1, -100, 1, 0)
TT.Position = UDim2.new(0, isMb and 12 or 16, 0, 0)
TT.BackgroundTransparency = 1
TT.Text = "PROSPECTING"
TT.TextSize = isMb and 14 or 16
TT.TextXAlignment = Enum.TextXAlignment.Left
TT.Parent = TB

RegisterTheme(TT, "Text")

-- Subtítulo dispositivo
local STB = Instance.new("TextLabel")
STB.Name = "STB"
STB.Size = UDim2.new(1, -100, 0, 12)
STB.Position = UDim2.new(0, isMb and 12 or 16, 1, -14)
STB.BackgroundTransparency = 1
STB.Text = isMb and "📱 MOBILE" or "💻 DESKTOP"
STB.TextSize = isMb and 9 or 10
STB.TextXAlignment = Enum.TextXAlignment.Left
STB.Parent = TB

RegisterTheme(STB, "SubText")

-- Función crear botones de control
local function crCB(nm, pos, clr, sym)
    local btn = Instance.new("TextButton")
    btn.Name = nm
    btn.Size = UDim2.new(0, isMb and 26 or 30, 0, isMb and 26 or 30)
    btn.Position = pos
    btn.BackgroundColor3 = clr
    btn.BackgroundTransparency = 0.25
    btn.BorderSizePixel = 0
    btn.Text = sym
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = isMb and 16 or 18
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TB
    
    local crn = Instance.new("UICorner")
    crn.CornerRadius = UDim.new(1, 0)
    crn.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TS:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, (isMb and 26 or 30) + 4, 0, (isMb and 26 or 30) + 4)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TS:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.25,
            Size = UDim2.new(0, isMb and 26 or 30, 0, isMb and 26 or 30)
        }):Play()
    end)
    
    return btn
end

-- Botones de control
local MNB = crCB("MNB", UDim2.new(1, isMb and -64 or -72, 0.5, isMb and -13 or -15), Color3.fromRGB(255, 189, 68), "−")
local CLB = crCB("CLB", UDim2.new(1, isMb and -32 or -36, 0.5, isMb and -13 or -15), Color3.fromRGB(255, 95, 86), "×")

-- Contenedor Principal (Dividido)
local CNT = Instance.new("Frame")
CNT.Name = "CNT"
CNT.Size = UDim2.new(1, -16, 1, isMb and -56 or -64)
CNT.Position = UDim2.new(0, 8, 0, isMb and 48 or 54)
CNT.BackgroundTransparency = 1
CNT.Parent = MF

-- Panel Izquierdo (Opciones)
local LFP = Instance.new("Frame")
LFP.Name = "LFP"
LFP.Size = UDim2.new(isMb and 0.5 or 0.48, -4, 1, 0)
LFP.Position = UDim2.new(0, 0, 0, 0)
LFP.BackgroundTransparency = 1
LFP.Parent = CNT

local LFT = Instance.new("TextLabel")
LFT.Name = "LFT"
LFT.Size = UDim2.new(1, 0, 0, isMb and 18 or 22)
LFT.BackgroundTransparency = 1
LFT.Text = "OPTIONS"
LFT.TextColor3 = Color3.fromRGB(200, 200, 220)
LFT.TextSize = isMb and 11 or 12
LFT.Font = Enum.Font.GothamBold
LFT.TextXAlignment = Enum.TextXAlignment.Left
LFT.Parent = LFP

local SCL = Instance.new("ScrollingFrame")
SCL.Name = "SCL"
SCL.Size = UDim2.new(1, 0, 1, isMb and -24 or -28)
SCL.Position = UDim2.new(0, 0, 0, isMb and 22 or 26)
SCL.BackgroundTransparency = 1
SCL.BorderSizePixel = 0
SCL.ScrollBarThickness = 4
SCL.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
SCL.CanvasSize = UDim2.new(0, 0, 0, 0)
SCL.AutomaticCanvasSize = Enum.AutomaticSize.Y
SCL.Parent = LFP

RegisterTheme(SCL, "ScrollBar")

local LYT = Instance.new("UIListLayout")
LYT.Padding = UDim.new(0, isMb and 4 or 6)
LYT.SortOrder = Enum.SortOrder.LayoutOrder
LYT.Parent = SCL

-- Panel Derecho (Logs)
local RTP = Instance.new("Frame")
RTP.Name = "RTP"
RTP.Size = UDim2.new(isMb and 0.5 or 0.48, -4, 1, 0)
RTP.Position = UDim2.new(isMb and 0.5 or 0.52, 4, 0, 0)
RTP.BackgroundTransparency = 1
RTP.Parent = CNT

local RTT = Instance.new("TextLabel")
RTT.Name = "RTT"
RTT.Size = UDim2.new(1, 0, 0, isMb and 18 or 22)
RTT.BackgroundTransparency = 1
RTT.Text = "ACTIVITY LOGS"
RTT.TextColor3 = Color3.fromRGB(200, 200, 220)
RTT.TextSize = isMb and 11 or 12
RTT.Font = Enum.Font.GothamBold
RTT.TextXAlignment = Enum.TextXAlignment.Left
RTT.Parent = RTP

-- Contenedor de Logs
local LGC = Instance.new("Frame")
LGC.Name = "LGC"
LGC.Size = UDim2.new(1, 0, 0.7, 0)
LGC.Position = UDim2.new(0, 0, 0, isMb and 22 or 26)
LGC.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LGC.BackgroundTransparency = 0.3
LGC.BorderSizePixel = 0
LGC.Parent = RTP

RegisterTheme(LGC, "DarkBg")

local CR3 = Instance.new("UICorner")
CR3.CornerRadius = UDim.new(0, isMb and 10 or 12)
CR3.Parent = LGC

local STK2 = Instance.new("UIStroke")
STK2.Color = Color3.fromRGB(60, 60, 80)
STK2.Thickness = 1
STK2.Transparency = 0.7
STK2.Parent = LGC

RegisterTheme(STK2, "Stroke")

local SCR = Instance.new("ScrollingFrame")
SCR.Name = "SCR"
SCR.Size = UDim2.new(1, -8, 1, -8)
SCR.Position = UDim2.new(0, 4, 0, 4)
SCR.BackgroundTransparency = 1
SCR.BorderSizePixel = 0
SCR.ScrollBarThickness = 3
SCR.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
SCR.CanvasSize = UDim2.new(0, 0, 0, 0)
SCR.AutomaticCanvasSize = Enum.AutomaticSize.Y
SCR.Parent = LGC

RegisterTheme(SCR, "ScrollBar")

local LYT2 = Instance.new("UIListLayout")
LYT2.Padding = UDim.new(0, isMb and 4 or 6)
LYT2.SortOrder = Enum.SortOrder.LayoutOrder
LYT2.VerticalAlignment = Enum.VerticalAlignment.Top
LYT2.Parent = SCR

-- Sistema de Logs (AUTO-DELETE DESPUÉS DE 6 SEGUNDOS)
local lgC = 0

local function adLg(txt, typ)
    -- Enviar a Webhook (Solo pasará el filtro si es Error o Dinero)
    sendToWebhook(txt, typ)

    -- RESTAURADO: Mostrar todos los logs visualmente
    -- Se eliminó el filtro restrictivo según solicitud
    
    lgC = lgC + 1
    
    local clrs = {
        info = Color3.fromRGB(100, 150, 255),
        success = Color3.fromRGB(100, 255, 150),
        warning = Color3.fromRGB(255, 200, 100),
        error = Color3.fromRGB(255, 100, 100)
    }
    
    local lgF = Instance.new("Frame")
    lgF.Name = "Log"..lgC
    lgF.Size = UDim2.new(1, -4, 0, isMb and 28 or 32)
    lgF.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    lgF.BackgroundTransparency = 0.4
    lgF.BorderSizePixel = 0
    lgF.LayoutOrder = lgC
    lgF.Parent = SCR
    
    local crL = Instance.new("UICorner")
    crL.CornerRadius = UDim.new(0, isMb and 6 or 8)
    crL.Parent = lgF
    
    local ind = Instance.new("Frame")
    ind.Name = "ind"
    ind.Size = UDim2.new(0, 3, 1, -8)
    ind.Position = UDim2.new(0, 4, 0, 4)
    ind.BackgroundColor3 = clrs[typ] or clrs.info
    ind.BorderSizePixel = 0
    ind.Parent = lgF
    
    local crI = Instance.new("UICorner")
    crI.CornerRadius = UDim.new(1, 0)
    crI.Parent = ind
    
    local tms = os.date("%H:%M:%S")
    local tmL = Instance.new("TextLabel")
    tmL.Name = "tmL"
    tmL.Size = UDim2.new(0, isMb and 45 or 50, 1, 0)
    tmL.Position = UDim2.new(0, isMb and 10 or 12, 0, 0)
    tmL.BackgroundTransparency = 1
    tmL.Text = tms
    tmL.TextColor3 = Color3.fromRGB(120, 120, 140)
    tmL.TextSize = isMb and 8 or 9
    tmL.Font = Enum.Font.GothamMedium
    tmL.TextXAlignment = Enum.TextXAlignment.Left
    tmL.Parent = lgF
    
    local txL = Instance.new("TextLabel")
    txL.Name = "txL"
    txL.Size = UDim2.new(1, isMb and -60 or -68, 1, 0)
    txL.Position = UDim2.new(0, isMb and 58 or 65, 0, 0)
    txL.BackgroundTransparency = 1
    txL.Text = txt
    txL.TextColor3 = Color3.fromRGB(220, 220, 240)
    txL.TextSize = isMb and 9 or 10
    txL.Font = Enum.Font.Gotham
    txL.TextXAlignment = Enum.TextXAlignment.Left
    txL.TextTruncate = Enum.TextTruncate.AtEnd
    txL.Parent = lgF
    
    lgF.Size = UDim2.new(0, 0, 0, isMb and 28 or 32)
    lgF.BackgroundTransparency = 1
    
    TS:Create(lgF, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -4, 0, isMb and 28 or 32),
        BackgroundTransparency = 0.4
    }):Play()
    
    SCR.CanvasPosition = Vector2.new(0, SCR.AbsoluteCanvasSize.Y)
    
    -- AUTO-DELETE DESPUÉS DE 6 SEGUNDOS
    task.spawn(function()
        task.wait(6)
        if lgF and lgF.Parent then
            TS:Create(lgF, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 0, isMb and 28 or 32),
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(0.3)
            lgF:Destroy()
        end
    end)
end

-- Variables para Auto Farm
local pos1 = nil
local pos2 = nil
local afR = false
local afL = nil

-- Función auxiliar para buscar cualquier Pan
local function getPan()
    local targets = {LP.Character, LP.Backpack, LP:FindFirstChild("BackpackTwo")}
    for _, container in pairs(targets) do
        if container then
            for _, item in pairs(container:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name, "Pan") then
                    return item
                end
            end
        end
    end
    return nil
end

-- Función crear sub-botón
local function crSB(txt, ord, par, clk)
    local SBF = Instance.new("Frame")
    SBF.Name = txt.."SF"
    SBF.Size = UDim2.new(1, -12, 0, isMb and 38 or 42)
    SBF.BackgroundTransparency = 0.5
    SBF.BorderSizePixel = 0
    SBF.LayoutOrder = ord
    SBF.Visible = false
    SBF.Parent = par
    
    RegisterTheme(SBF, "Button")

    local crS = Instance.new("UICorner")
    crS.CornerRadius = UDim.new(0, isMb and 8 or 10)
    crS.Parent = SBF
    
    local stS = Instance.new("UIStroke")
    stS.Thickness = 0.8
    stS.Transparency = 0.8
    stS.Parent = SBF
    
    RegisterTheme(stS, "Stroke")

    local btn = Instance.new("TextButton")
    btn.Name = txt.."SB"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = SBF
    
    local txS = Instance.new("TextLabel")
    txS.Name = "txS"
    txS.Size = UDim2.new(1, -20, 1, 0)
    txS.Position = UDim2.new(0, 10, 0, 0)
    txS.BackgroundTransparency = 1
    txS.Text = "→ "..txt
    txS.TextSize = isMb and 10 or 11
    txS.TextXAlignment = Enum.TextXAlignment.Left
    txS.Parent = SBF
    
    RegisterTheme(txS, "SubText")

    btn.MouseEnter:Connect(function()
        TS:Create(SBF, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.35
        }):Play()
        TS:Create(stS, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Transparency = 0.5
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TS:Create(SBF, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.5
        }):Play()
        TS:Create(stS, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Transparency = 0.8
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        TS:Create(SBF, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.2
        }):Play()
        task.wait(0.1)
        TS:Create(SBF, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.35
        }):Play()
        
        if clk then clk() end
    end)
    
    return SBF
end

-- Función crear sub-botón expandible (Categoría)
local function crESB(txt, ord, par, subs)
    local SBF = Instance.new("Frame")
    SBF.Name = txt.."CatF"
    SBF.Size = UDim2.new(1, -12, 0, isMb and 38 or 42)
    SBF.BackgroundTransparency = 0.4
    SBF.BorderSizePixel = 0
    SBF.LayoutOrder = ord
    SBF.Visible = false
    SBF.Parent = par
    
    RegisterTheme(SBF, "Button")

    local crS = Instance.new("UICorner")
    crS.CornerRadius = UDim.new(0, isMb and 8 or 10)
    crS.Parent = SBF
    
    local stS = Instance.new("UIStroke")
    stS.Thickness = 0.8
    stS.Transparency = 0.6
    stS.Parent = SBF
    
    RegisterTheme(stS, "Stroke")

    local btn = Instance.new("TextButton")
    btn.Name = txt.."CatB"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = SBF
    
    local txS = Instance.new("TextLabel")
    txS.Name = "txS"
    txS.Size = UDim2.new(1, -40, 1, 0)
    txS.Position = UDim2.new(0, 10, 0, 0)
    txS.BackgroundTransparency = 1
    txS.Text = "📂 "..txt
    txS.TextSize = isMb and 10 or 11
    txS.TextXAlignment = Enum.TextXAlignment.Left
    txS.Parent = SBF
    
    RegisterTheme(txS, "Text")

    local arr = Instance.new("TextLabel")
    arr.Name = "arr"
    arr.Size = UDim2.new(0, 20, 0, 20)
    arr.Position = UDim2.new(1, -25, 0.5, -10)
    arr.BackgroundTransparency = 1
    arr.Text = "›"
    arr.TextSize = isMb and 16 or 18
    arr.Parent = SBF
    
    RegisterTheme(arr, "SubText")

    local innerC = Instance.new("Frame")
    innerC.Name = txt.."_InnerC"
    innerC.Size = UDim2.new(1, -12, 0, 0)
    innerC.Position = UDim2.new(0, 6, 0, 0)
    innerC.BackgroundTransparency = 1
    innerC.ClipsDescendants = true
    innerC.LayoutOrder = ord + 0.1
    innerC.Parent = par
    
    local innerL = Instance.new("UIListLayout")
    innerL.Padding = UDim.new(0, 4)
    innerL.SortOrder = Enum.SortOrder.LayoutOrder
    innerL.Parent = innerC
    
    if subs then
        for i, sub in ipairs(subs) do
            local sb = crSB(sub.text, i, innerC, sub.onClick)
            sb.Visible = true
            sb.Size = UDim2.new(1, 0, 0, isMb and 36 or 40)
        end
    end
    
    local exp = false
    
    btn.MouseButton1Click:Connect(function()
        exp = not exp
        
        TS:Create(arr, TweenInfo.new(0.3), {Rotation = exp and 90 or 0}):Play()
        
        if exp then
            local h = 0
            for _, c in ipairs(innerC:GetChildren()) do
                if c:IsA("Frame") then
                    h = h + c.Size.Y.Offset + 4
                end
            end
            
            local tw = TS:Create(innerC, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -12, 0, h)
            })
            tw:Play()
            tw.Completed:Connect(function()
                if exp then innerC.AutomaticSize = Enum.AutomaticSize.Y end
            end)
        else
            innerC.AutomaticSize = Enum.AutomaticSize.None
            innerC.Size = UDim2.new(1, -12, 0, innerC.AbsoluteSize.Y)
            TS:Create(innerC, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, -12, 0, 0)
            }):Play()
        end
    end)
    
    return SBF
end

-- Función crear botón expandible
local function crEB(txt, ord, clr, subs, iconId)
    local BF = Instance.new("Frame")
    BF.Name = txt.."F"
    BF.Size = UDim2.new(1, 0, 0, isMb and 36 or 42)
    BF.BackgroundTransparency = 0.45
    BF.BorderSizePixel = 0
    BF.LayoutOrder = ord
    BF.Parent = SCL
    
    RegisterTheme(BF, "Button")

    local crB = Instance.new("UICorner")
    crB.CornerRadius = UDim.new(0, isMb and 8 or 10)
    crB.Parent = BF
    
    local stB = Instance.new("UIStroke")
    stB.Thickness = 1
    stB.Transparency = 0.75
    stB.Parent = BF
    
    RegisterTheme(stB, "Stroke")

    local icn
    local grI
    
    if iconId then
        icn = Instance.new("ImageLabel")
        icn.Name = "icn"
        icn.Size = UDim2.new(0, isMb and 22 or 26, 0, isMb and 22 or 26)
        icn.Position = UDim2.new(0, isMb and 8 or 10, 0.5, isMb and -11 or -13)
        icn.BackgroundTransparency = 1
        icn.Image = "rbxassetid://"..iconId
        icn.Parent = BF
    else
        icn = Instance.new("Frame")
        icn.Name = "icn"
        icn.Size = UDim2.new(0, isMb and 22 or 26, 0, isMb and 22 or 26)
        icn.Position = UDim2.new(0, isMb and 8 or 10, 0.5, isMb and -11 or -13)
        icn.BackgroundColor3 = clr
        icn.BackgroundTransparency = 0.35
        icn.BorderSizePixel = 0
        icn.Parent = BF
        
        local crI = Instance.new("UICorner")
        crI.CornerRadius = UDim.new(0, isMb and 6 or 8)
        crI.Parent = icn
        
        grI = Instance.new("UIGradient")
        grI.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, clr)
        }
        grI.Rotation = 45
        grI.Parent = icn
    end
    
    local btn = Instance.new("TextButton")
    btn.Name = txt.."B"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = BF
    
    local txB = Instance.new("TextLabel")
    txB.Name = "txB"
    txB.Size = UDim2.new(1, isMb and -75 or -80, 1, 0)
    txB.Position = UDim2.new(0, isMb and 36 or 42, 0, 0)
    txB.BackgroundTransparency = 1
    txB.Text = txt
    txB.TextSize = isMb and 10 or 12
    txB.TextXAlignment = Enum.TextXAlignment.Left
    txB.TextTruncate = Enum.TextTruncate.AtEnd
    txB.Parent = BF
    
    RegisterTheme(txB, "Text")

    local arr = Instance.new("TextLabel")
    arr.Name = "arr"
    arr.Size = UDim2.new(0, 20, 0, 20)
    arr.Position = UDim2.new(1, isMb and -28 or -32, 0.5, -10)
    arr.BackgroundTransparency = 1
    arr.Text = "›"
    arr.TextSize = isMb and 18 or 22
    arr.Rotation = 0
    arr.Parent = BF
    
    RegisterTheme(arr, "SubText")

    local exp = false
    local subC = Instance.new("Frame")
    subC.Name = "subC"
    subC.Size = UDim2.new(1, 0, 0, 0)
    subC.BackgroundTransparency = 1
    subC.LayoutOrder = ord + 0.5
    subC.ClipsDescendants = true
    subC.Parent = SCL
    
    local subL = Instance.new("UIListLayout")
    subL.Padding = UDim.new(0, isMb and 6 or 8)
    subL.SortOrder = Enum.SortOrder.LayoutOrder
    subL.Parent = subC
    
    if subs then
        for i, sub in ipairs(subs) do
            if sub.subs then
                crESB(sub.text, i, subC, sub.subs)
            else
                crSB(sub.text, i, subC, sub.onClick)
            end
        end
    end
    
    btn.MouseEnter:Connect(function()
        TS:Create(BF, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.3
        }):Play()
        TS:Create(stB, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Transparency = 0.4
        }):Play()
        
        if grI then grI.Enabled = false end
        if icn:IsA("Frame") then
            TS:Create(icn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        
        TS:Create(icn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, (isMb and 22 or 26) + 4, 0, (isMb and 22 or 26) + 4),
            Rotation = 10
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TS:Create(BF, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.45
        }):Play()
        TS:Create(stB, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Transparency = 0.75
        }):Play()
        
        if grI then grI.Enabled = true end
        if icn:IsA("Frame") then
             TS:Create(icn, TweenInfo.new(0.25), {BackgroundColor3 = clr}):Play()
        end
        
        TS:Create(icn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, isMb and 22 or 26, 0, isMb and 22 or 26),
            Rotation = 0
        }):Play()
    end)
    
    local animDebounce = false

    btn.MouseButton1Click:Connect(function()
        if animDebounce then return end -- Previene clics rápidos durante la transición
        animDebounce = true
        
        exp = not exp
        
        TS:Create(arr, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Rotation = exp and 90 or 0
        }):Play()
        
        if exp then
            local h = 0
            for _, c in ipairs(subC:GetChildren()) do
                if c:IsA("Frame") then
                    c.Visible = true
                    h = h + c.Size.Y.Offset + (isMb and 6 or 8)
                end
            end
            
            local tw = TS:Create(subC, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, h)
            })
            tw:Play()
            tw.Completed:Connect(function()
                if exp then subC.AutomaticSize = Enum.AutomaticSize.Y end
                animDebounce = false
            end)
            
        else
            subC.AutomaticSize = Enum.AutomaticSize.None
            subC.Size = UDim2.new(1, 0, 0, subC.AbsoluteSize.Y)
            local tw = TS:Create(subC, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            })
            tw:Play()
            
            tw.Completed:Connect(function()
                if not exp then -- Doble verificación
                    for _, c in ipairs(subC:GetChildren()) do
                        if c:IsA("Frame") then
                            c.Visible = false
                        end
                    end
                end
                animDebounce = false
            end)
        end
    end)
end

-- Helper para obtener capacidad dinámica
local function getPanCapacity(tool)
    if LP:FindFirstChild("Stats") then
        local cap = LP.Stats:GetAttribute("Capacity")
        if cap then return cap end
    end

    if not tool then return 20 end
    
    local cap = tool:GetAttribute("Capacity") or tool:GetAttribute("MaxFill") or tool:GetAttribute("Max")
    if cap then return cap end
    
    local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings") or tool:FindFirstChild("Config")
    if config then
        cap = config:GetAttribute("Capacity") or config:GetAttribute("MaxFill") or config:GetAttribute("Max")
        if cap then return cap end
        
        local val = config:FindFirstChild("Capacity") or config:FindFirstChild("MaxFill") or config:FindFirstChild("Max")
        if val and (val:IsA("IntValue") or val:IsA("NumberValue")) then
            return val.Value
        end
    end
    
    return 20
end

-- Sistema Anti-Rollback
local isTeleporting = false 

local CONFIG = { 
    TARGET_POS = nil,
    FORCE_DURATION = 3.0,
    CHECK_RATE = 1/120,
    MAX_DISTANCE = 15,
    VOID_DEPTH = -1e7, 
    PRE_TELEPORT_DELAY = 0.2, 
    POST_TELEPORT_STABILIZE = 0.5 
} 

local AntiRollback = { 
    active = false, 
    targetCFrame = nil, 
    connection = nil,
    sellConnection = nil,
    nuclearConnection = nil,
    success = false, 
    attemptCount = 0 
} 

function AntiRollback:startForce(targetCF)
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end

    self.targetCFrame = targetCF 
    self.active = true 
    self.success = false 
    self.attemptCount = 0 
    
    humanoid.PlatformStand = true 
    humanoid.WalkSpeed = 0 
    humanoid.JumpPower = 0 
    
    for _, part in ipairs(char:GetDescendants()) do 
        if part:IsA("BasePart") then 
            part.Anchored = true
        end 
    end 
    
    hrp.CFrame = CFrame.new(0, CONFIG.VOID_DEPTH, 0) 
    task.wait(CONFIG.PRE_TELEPORT_DELAY) 
    
    local startTime = tick() 
    self.connection = RunService.Heartbeat:Connect(function() 
        if not self.active then return end 
        
        self.attemptCount = self.attemptCount + 1 
        
        hrp.CFrame = self.targetCFrame 
        char:PivotTo(self.targetCFrame) 
        
        hrp.AssemblyLinearVelocity = Vector3.zero 
        hrp.AssemblyAngularVelocity = Vector3.zero 
        hrp.Velocity = Vector3.zero 
        
        if self.attemptCount % 10 == 0 then 
            local dist = (hrp.Position - self.targetCFrame.Position).Magnitude 
            if dist < CONFIG.MAX_DISTANCE then 
                self.success = true 
            end 
        end 
        
        if tick() - startTime > CONFIG.FORCE_DURATION then 
            self:stop() 
        end 
    end) 
    
    repeat task.wait() until not self.active 
    
    return self.success 
end 

function AntiRollback:stop() 
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    self.active = false 
    
    if self.connection then 
        self.connection:Disconnect() 
        self.connection = nil 
    end 
    
    if self.sellConnection then
        self.sellConnection:Disconnect()
        self.sellConnection = nil
    end

    if self.nuclearConnection then
        self.nuclearConnection:Disconnect()
        self.nuclearConnection = nil
    end

    if self.returnConnection then
        self.returnConnection:Disconnect()
        self.returnConnection = nil
    end
    
    task.wait(0.1) 
    
    for _, part in ipairs(char:GetDescendants()) do 
        if part:IsA("BasePart") then 
            part.Anchored = false 
        end 
    end 
    
    if humanoid then
        humanoid.PlatformStand = false 
        humanoid.WalkSpeed = 16 
        humanoid.JumpPower = 50 
    end
    
    if hrp and self.targetCFrame then
        hrp.CFrame = self.targetCFrame 
        hrp.AssemblyLinearVelocity = Vector3.zero 
    end
    
    task.wait(CONFIG.POST_TELEPORT_STABILIZE) 
end 

function AntiRollback:nuclearOption(targetCF) 
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local startTime = tick() 
    
    self.nuclearConnection = RunService.Heartbeat:Connect(function() 
        if tick() - startTime > 3 then 
            if self.nuclearConnection then 
                self.nuclearConnection:Disconnect() 
                self.nuclearConnection = nil
            end 
            return 
        end 
        
        hrp.CFrame = targetCF 
        TS:Create(hrp, TweenInfo.new(0.05), {CFrame = targetCF}):Play() 
        
        for i = 1, 5 do 
            hrp.CFrame = targetCF 
        end 
    end) 
    
    task.wait(3) 
    if self.nuclearConnection then 
        self.nuclearConnection:Disconnect() 
        self.nuclearConnection = nil
    end
end 

local function bypassTP(targetCF)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    isTeleporting = true
    
    local success = AntiRollback:startForce(targetCF) 
    
    if not success then 
        AntiRollback:nuclearOption(targetCF) 
    end 
    
    isTeleporting = false
end

local function getClosestMerchant()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LP.Character.HumanoidRootPart.Position
    local closestCF = nil
    local minDst = 999999999
    
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, zone in ipairs(npcFolder:GetChildren()) do
            for _, npc in ipairs(zone:GetChildren()) do
                if (npc:IsA("Model") or npc:IsA("BasePart")) then
                    if string.find(npc.Name, "Merchant") or string.find(npc.Name, "Sell") or npc.Name == "Merchant" then
                        local targetCF = npc:GetPivot()
                        
                        -- CORRECCIÓN DE POSICIÓN: TP ENFRENTE Y ARRIBA
                        -- LookVector * 4: 4 studs enfrente
                        -- UpVector * 6: 6 studs arriba (más alto para asegurar que no quede enterrado)
                        targetCF = targetCF + (targetCF.LookVector * 4) + Vector3.new(0, 6, 0)
                        
                        local dist = (myPos - targetCF.Position).Magnitude
                        
                        if dist < minDst then
                            minDst = dist
                            closestCF = targetCF
                        end
                    end
                end
            end
        end
    end
    
    if closestCF and minDst < 2000 then
        return closestCF
    else
        local starter = workspace.NPCs:FindFirstChild("StarterTown") and workspace.NPCs.StarterTown:FindFirstChild("Merchant")
        if starter then 
            -- Corrección también para el backup
            local cf = starter:GetPivot()
            return cf + (cf.LookVector * 4) + Vector3.new(0, 6, 0)
        end
    end
    
    return nil
end

local function simpleTP(targetCF)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
         LP.Character.HumanoidRootPart.CFrame = targetCF
    end
end

local function performSellAction(actionCallback)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LP.Character.HumanoidRootPart

    local startPos = hrp.CFrame
    local startMoney = 0
    if LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Money") then
        startMoney = LP.leaderstats.Money.Value
    end

    local sellCFrame = getClosestMerchant()
    
    if not sellCFrame then
        adLg("NO MERCHANT FOUND - CANNOT SELL", "error")
        return
    end

    local sold = false
    
    bypassTP(sellCFrame)
    hrp.Anchored = true
    
    local sTime = tick()
    local lastSellAttempt = 0
    
    adLg("FORCE SELLING (LOCK MODE)...", "info")
    
    AntiRollback.sellConnection = RunService.Heartbeat:Connect(function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local h = LP.Character.HumanoidRootPart
        
        h.CFrame = sellCFrame
        h.Velocity = Vector3.zero
        h.AssemblyLinearVelocity = Vector3.zero
        
        if tick() - lastSellAttempt > 0.05 then
            lastSellAttempt = tick()
            task.spawn(function()
                pcall(actionCallback)
            end)
        end
    end)
    
    repeat
        local currentMoney = 0
        if LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Money") then
            currentMoney = LP.leaderstats.Money.Value
        end
        
        if currentMoney > startMoney then
            sold = true
            adLg("SOLD SUCCESSFULLY!", "success")
        end
        
        task.wait(0.1)
    until sold or (tick() - sTime > 8) or (not AntiRollback.sellConnection)
    
    if AntiRollback.sellConnection then 
        AntiRollback.sellConnection:Disconnect() 
        AntiRollback.sellConnection = nil
    end
    hrp.Anchored = false
    task.wait(0.5)

    local endMoney = 0
    if LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Money") then
        endMoney = LP.leaderstats.Money.Value
    end
    
    local profit = endMoney - startMoney
    if profit > 0 then
        adLg("FORCE SELL: +$"..tostring(profit), "success")
        adLg("TOTAL: $"..tostring(endMoney), "info")
    else
        adLg("SELL FAILED", "error")
    end

    adLg("RETURNING...", "info")
    local returnAttempts = 0
    local returned = false
    
    -- FORCE RETURN LOGIC MEJORADA
    local startTime = tick()
    
    AntiRollback.returnConnection = RunService.Heartbeat:Connect(function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local h = LP.Character.HumanoidRootPart
        
        -- Forzar posición constantemente
        h.CFrame = startPos
        h.Velocity = Vector3.zero
        h.AssemblyLinearVelocity = Vector3.zero
        
        -- Verificar si ya llegamos y estamos estables
        local dist = (h.Position - startPos.Position).Magnitude
        if dist < 2 then
             -- Mantener un poco más para asegurar que el servidor lo registre
        end
    end)
    
    repeat
        returnAttempts = returnAttempts + 1
        task.wait(0.2)
        
        local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if h then
            local distReturn = (h.Position - startPos.Position).Magnitude
            if distReturn < 5 then
                -- Esperar un momento para confirmar estabilidad
                task.wait(0.5)
                if (h.Position - startPos.Position).Magnitude < 5 then
                    returned = true
                end
            end
        end
        
        -- Si tarda mucho, intentar re-forzar nuclearmente
        if returnAttempts % 10 == 0 then
             bypassTP(startPos)
        end
        
    until returned or returnAttempts >= 20 -- 4 segundos aprox de intentos fuertes
    
    if AntiRollback.returnConnection then
        AntiRollback.returnConnection:Disconnect()
        AntiRollback.returnConnection = nil
    end
    
    hrp.Anchored = false
    hrp.Velocity = Vector3.zero
    
    if returned then
         adLg("RETURNED SAFELY", "info")
    else
         adLg("RETURN FAILED - TELEPORTING FORCEFULLY", "error")
         -- Último intento desesperado
         hrp.CFrame = startPos
    end
end

local function stAF()
    if afR then
        adLg("AUTO FARM ALREADY RUNNING", "warning")
        return
    end
    
    if not pos1 or not pos2 then
        adLg("POSITIONS NOT SAVED!", "error")
        return
    end
    
    afR = true
    adLg("AUTO FARM STARTED", "success")
    
    afL = task.spawn(function()
        while afR do
            pcall(function()
                simpleTP(pos1)
                task.wait(0.3)
                
                local pan = getPan()

                if pan then
                    if pan.Parent ~= LP.Character then
                        LP.Character.Humanoid:EquipTool(pan)
                        adLg("EQUIPPED: "..pan.Name, "success")
                    else
                         adLg("ALREADY EQUIPPED", "info")
                    end
                    task.wait(0.3)
                    
                    local stT = tick()
                    local lastFill = -1
                    local stuckTime = tick()
                    
                    while tick() - stT < 120 and afR do
                        local evt = LP.Character:FindFirstChildWhichIsA("Tool")
                        if evt and string.find(evt.Name, "Pan") then
                            local fill = evt:GetAttribute("Fill") or 0
                            local capacity = getPanCapacity(evt)

                            if fill ~= lastFill then
                                lastFill = fill
                                stuckTime = tick()
                            end
                            
                            if tick() - stuckTime > 2 then
                                adLg("STUCK COLLECTING (NO FILL)", "warning")
                                break
                            end

                            if fill >= capacity then
                                adLg("PAN FULL ("..fill.."/"..capacity..")", "warning")
                                break 
                            end

                            if evt:FindFirstChild("Scripts") and evt.Scripts:FindFirstChild("Collect") then
                                evt.Scripts.Collect:InvokeServer(100)
                            end
                        else
                             local rePan = getPan()
                             if rePan and rePan.Parent ~= LP.Character then
                                 LP.Character.Humanoid:EquipTool(rePan)
                             end
                        end
                        task.wait(0.1)
                    end
                    adLg("COLLECTING COMPLETE", "success")
                else
                    adLg("NO PAN FOUND!", "error")
                end
                
                task.wait(0.3)
                
                simpleTP(pos2)
                task.wait(0.3)
                
                local pan2 = LP.Character:FindFirstChildWhichIsA("Tool")
                if pan2 and string.find(pan2.Name, "Pan") and pan2:FindFirstChild("Scripts") and pan2.Scripts:FindFirstChild("Pan") then
                    pan2.Scripts.Pan:InvokeServer()
                    adLg("PAN ACTIVATED", "success")
                    task.wait(0.3)
                    
                    local shkT = tick()
                    local maxShakeTime = 300
                    local shakeErrors = 0
                    
                    while tick() - shkT < maxShakeTime and afR do
                        if not pan2 or pan2.Parent ~= LP.Character then
                            local currentTool = LP.Character:FindFirstChildWhichIsA("Tool")
                            if currentTool and string.find(currentTool.Name, "Pan") then
                                pan2 = currentTool
                            else
                                local bpPan = getPan()
                                if bpPan then
                                    LP.Character.Humanoid:EquipTool(bpPan)
                                    pan2 = bpPan
                                    task.wait(0.2)
                                end
                            end
                        end

                        if pan2 and pan2.Parent == LP.Character then
                            local fill = pan2:GetAttribute("Fill")
                            if fill and fill <= 0 then
                                adLg("PAN EMPTY (0)", "success")
                                break
                            end
                            
                            if pan2:FindFirstChild("Scripts") and pan2.Scripts:FindFirstChild("Shake") then
                                local s, e = pcall(function()
                                    pan2.Scripts.Shake:FireServer()
                                end)
                                if not s then
                                    shakeErrors = shakeErrors + 1
                                    if shakeErrors > 10 then
                                        adLg("SHAKE ERRORS - RETRYING...", "warning")
                                        shakeErrors = 0
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                        task.wait(0.01)
                    end
                    adLg("SHAKING COMPLETE", "success")
                else
                    adLg("PAN SCRIPTS NOT FOUND!", "error")
                end
                
                task.wait(0.5)
            end)
        end
    end)
end

local function spAF()
    afR = false
    if afL then
        task.cancel(afL)
    end
    adLg("AUTO FARM STOPPED", "warning")
end

crEB("Auto", 1, Color3.fromRGB(100, 150, 255), {
    {
        text = "Save Sand Position",
        onClick = function()
            pos1 = LP.Character.HumanoidRootPart.CFrame
            adLg("SAND POSITION SAVED", "success")
        end
    },
    {
        text = "Save Water Position",
        onClick = function()
            pos2 = LP.Character.HumanoidRootPart.CFrame
            adLg("WATER POSITION SAVED", "success")
        end
    },
    {
        text = "Start Auto Farm",
        onClick = function()
            stAF()
        end
    },
    {
        text = "Stop Auto Farm",
        onClick = function()
            spAF()
        end
    }
}, "10884449082")

-- Variable Global para Tecla de Fly (Default: F)
_G.FlyKey = Enum.KeyCode.F
_G.FlyActive = false

-- Función Centralizada de Toggle Fly
local function toggleFly()
    if _G.FlyActive then
        _G.FlyActive = false
        adLg("FLY: OFF", "info")
        
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            if root:FindFirstChild("FlyMover") then root.FlyMover:Destroy() end
            if root:FindFirstChild("FlyRotator") then root.FlyRotator:Destroy() end
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
                char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    else
        _G.FlyActive = true
        adLg("FLY: ON", "success")
        
        local char = LP.Character
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        
        local flySpeed = 50
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyMover"
        bv.Parent = root
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyRotator"
        bg.Parent = root
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.D = 100
        
        task.spawn(function()
            while _G.FlyActive and char.Parent do
                -- Ya no necesitamos chequear la tecla aquí dentro para salir
                
                -- Bypass Trust Score
                char:SetAttribute("KM_TELEPORT_TRUST_SCORE", 100)
                char:SetAttribute("KM_SPEED_TRUST_SCORE", 100)
                
                -- Movimiento Cámara
                local cam = workspace.CurrentCamera
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local moveDir = Vector3.new(0,0,0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + look end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - look end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0,1,0) end
                
                -- Soporte Móvil (Joystick Virtual)
                if hum and hum.MoveDirection.Magnitude > 0 then
                    local joyDir = hum.MoveDirection
                    moveDir = moveDir + joyDir
                    
                    -- Volar hacia donde mira la cámara (Camera Relative Height)
                    if math.abs(look.Y) > 0.1 then
                        local flatLook = Vector3.new(look.X, 0, look.Z).Unit
                        local dot = joyDir:Dot(flatLook)
                        
                        if dot > 0.5 then -- Avanzando
                             moveDir = moveDir + Vector3.new(0, look.Y, 0)
                        elseif dot < -0.5 then -- Retrocediendo
                             moveDir = moveDir - Vector3.new(0, look.Y, 0)
                        end
                    end
                end
                
                local currentSpeed = flySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then currentSpeed = flySpeed * 3 end
                
                bg.CFrame = cam.CFrame
                bv.Velocity = moveDir * currentSpeed
                
                if hum then 
                    hum.PlatformStand = true 
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                end
                
                RunService.Heartbeat:Wait()
            end
            
            -- Cleanup al salir del loop
            if root:FindFirstChild("FlyMover") then root.FlyMover:Destroy() end
            if root:FindFirstChild("FlyRotator") then root.FlyRotator:Destroy() end
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end

-- Listener Global de Teclas (Toggle ON/OFF)
if _G.FlyKeyConnection then _G.FlyKeyConnection:Disconnect() end
_G.FlyKeyConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _G.FlyKey then
        toggleFly()
    end
end)

-- Construir botones Misc dinámicamente
local miscBtns = {
    {
        text = "Speed Hack (Toggle)",
        onClick = function()
            if _G.SpeedHackActive then
                _G.SpeedHackActive = false
                if _G.SpeedLoop then _G.SpeedLoop:Disconnect() end
                if LP.Character then
                    LP.Character:SetAttribute("BaseWalkSpeed", 16)
                    if LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = 16 end
                end
                adLg("SPEED: OFF (Legit)", "info")
            else
                _G.SpeedHackActive = true
                adLg("SPEED: ON (Bypass)", "success")
                local RunService = game:GetService("RunService")
                _G.SpeedLoop = RunService.Heartbeat:Connect(function()
                    if not _G.SpeedHackActive then return end
                    local char = LP.Character
                    if char then
                        -- Bypass Method: BaseWalkSpeed Attribute
                        if char:GetAttribute("BaseWalkSpeed") ~= 80 then
                            char:SetAttribute("BaseWalkSpeed", 80)
                        end
                        if char:FindFirstChild("Humanoid") and char.Humanoid.WalkSpeed < 50 then
                            char.Humanoid.WalkSpeed = 80
                        end
                    end
                end)
            end
        end
    },
    {
        text = "Fly Mode (Toggle)",
        onClick = function()
            toggleFly()
        end
    }
}

-- Agregar opción de Keybind solo para PC
if not isMb then
    table.insert(miscBtns, {
        text = "Set Fly Keybind (PC)",
        onClick = function()
            adLg("PRESS ANY KEY NOW...", "warning")
            local input = game:GetService("UserInputService").InputBegan:Wait()
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                _G.FlyKey = input.KeyCode
                adLg("FLY KEY SET TO: " .. input.KeyCode.Name, "success")
            end
        end
    })
end

crEB("Misc", 2, Color3.fromRGB(150, 100, 255), miscBtns, "92660651692951")

crEB("Sell Options", 3, Color3.fromRGB(255, 100, 150), {
    {
        text = "Sell One",
        onClick = function()
            local tool = LP.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                 performSellAction(function()
                     local RS = game:GetService("ReplicatedStorage")
                     
                     if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Shop") and RS.Remotes.Shop:FindFirstChild("SellItem") then
                         pcall(function() RS.Remotes.Shop.SellItem:InvokeServer(tool) end)
                     end
                     
                     if tool:FindFirstChild("Sell") and tool.Sell:IsA("RemoteEvent") then
                         pcall(function() tool.Sell:FireServer() end)
                     end
                 end)
            else
                adLg("EQUIP ITEM TO SELL!", "warning")
            end
        end
    },
    {
        text = "Check Price",
        onClick = function()
            local tool = LP.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                local RS = game:GetService("ReplicatedStorage")
                
                if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Shop") and RS.Remotes.Shop:FindFirstChild("GetInventorySellPrice") then
                     local price = RS.Remotes.Shop.GetInventorySellPrice:InvokeServer(tool)
                     adLg("VALUE: "..(tostring(price) or "?"), "info")
                else
                     adLg("PRICE REMOTE NOT FOUND", "error")
                end
            else
                adLg("EQUIP ITEM FIRST!", "warning")
            end
        end
    },
    {
        text = "Sell All Similar",
        onClick = function()
            local tool = LP.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                if _G.ConfirmSellSimilar then
                    _G.ConfirmSellSimilar = false
                    
                    performSellAction(function()
                        local RS = game:GetService("ReplicatedStorage")
                        if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Shop") and RS.Remotes.Shop:FindFirstChild("SellAll") then
                             pcall(function() RS.Remotes.Shop.SellAll:InvokeServer(tool) end)
                        end
                    end)
                else
                    _G.ConfirmSellSimilar = true
                    adLg("CLICK AGAIN TO CONFIRM", "warning")
                    delay(3, function() _G.ConfirmSellSimilar = false end) 
                end
            else
                adLg("EQUIP ITEM FIRST!", "warning")
            end
        end
    },
    {
        text = "Sell Everything",
        onClick = function()
            if _G.ConfirmSellEverything then
                _G.ConfirmSellEverything = false
                
                performSellAction(function()
                    local RS = game:GetService("ReplicatedStorage")
                    if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Shop") and RS.Remotes.Shop:FindFirstChild("SellAll") then
                         pcall(function() RS.Remotes.Shop.SellAll:InvokeServer() end)
                    end
                end)
            else
                _G.ConfirmSellEverything = true
                adLg("CLICK AGAIN TO CONFIRM", "warning")
                delay(3, function() _G.ConfirmSellEverything = false end)
            end
        end
    }
}, "121468959425922")

local function buyItem(itemName, qty)
    qty = qty or 1
    local shopPath = workspace:FindFirstChild("Purchasable") and workspace.Purchasable:FindFirstChild("RiverTown")
    if not shopPath then
        adLg("SHOP NOT FOUND", "error")
        return
    end

    local item = shopPath:FindFirstChild(itemName)
    if item and item:FindFirstChild("ShopItem") then
        local RS = game:GetService("ReplicatedStorage")
        if RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Shop") and RS.Remotes.Shop:FindFirstChild("BuyItem") then
            task.spawn(function()
                pcall(function()
                    RS.Remotes.Shop.BuyItem:InvokeServer(item.ShopItem, qty)
                    adLg("BOUGHT: x"..qty.." "..itemName, "success")
                end)
            end)
        else
            adLg("BUY REMOTE MISSING", "error")
        end
    else
        adLg("ITEM MISSING: "..itemName, "warning")
    end
end

local StoreUI = Instance.new("Frame")
StoreUI.Name = "StoreUI"
StoreUI.Size = UDim2.new(0, isMb and 300 or 400, 0, isMb and 250 or 300)
StoreUI.Position = UDim2.new(0.5, isMb and -150 or -200, 0.5, isMb and -125 or -150)
StoreUI.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
StoreUI.BackgroundTransparency = 1 -- Transparente para ver imagen
StoreUI.BorderSizePixel = 0
StoreUI.Visible = false
StoreUI.ClipsDescendants = true
StoreUI.Parent = SG
-- StoreUI.Active = true -- Quitamos Active del padre para que el script de drag funcione mejor si usamos input manual, o lo dejamos y usamos input custom
-- StoreUI.Draggable = true -- REMOVIDO: Usaremos sistema custom "Drag Anywhere"

-- Custom Background Image
local storeBG = Instance.new("ImageLabel")
storeBG.Name = "StoreBG"
storeBG.Image = "rbxassetid://94639788970365"
storeBG.Size = UDim2.new(1, 0, 1, 0)
storeBG.BackgroundTransparency = 1
storeBG.ImageTransparency = 0.8 -- Más transparente para que no sea tan brillante
storeBG.ScaleType = Enum.ScaleType.Crop
storeBG.ZIndex = 0
storeBG.Parent = StoreUI

-- Corner para la imagen
local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 12)
bgCorner.Parent = storeBG

-- Overlay para mantener el tema oscuro (Tint)
local storeOverlay = Instance.new("Frame")
storeOverlay.Name = "Overlay"
storeOverlay.Size = UDim2.new(1, 0, 1, 0)
storeOverlay.BackgroundTransparency = 0.3 -- Ajustable
storeOverlay.ZIndex = 0
storeOverlay.Parent = StoreUI

-- Corner para el overlay
local ovCorner = Instance.new("UICorner")
ovCorner.CornerRadius = UDim.new(0, 12)
ovCorner.Parent = storeOverlay

-- Registramos el Overlay para que tome el color del tema DarkBg
RegisterTheme(storeOverlay, "DarkBg")

-- Función de arrastre "Drag Anywhere"
local function enableDrag(frame)
    local dragToggle = nil
    local dragSpeed = 0
    local dragInput = nil
    local dragStart = nil
    local dragPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService("TweenService"):Create(frame, TweenInfo.new(0.1), {Position = position}):Play()
    end
    
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

enableDrag(StoreUI)
enableDrag(MF) -- Drag Anywhere para Main Frame

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = StoreUI

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 80)
uiStroke.Thickness = 1.5
uiStroke.Parent = StoreUI

RegisterTheme(uiStroke, "Stroke")

local storeTitle = Instance.new("TextLabel")
storeTitle.Size = UDim2.new(1, 0, 0, 30)
storeTitle.BackgroundTransparency = 1
storeTitle.Text = "MARKETPLACE"
storeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
storeTitle.Font = Enum.Font.GothamBold
storeTitle.TextSize = 14
storeTitle.Parent = StoreUI

RegisterTheme(storeTitle, "Text")

local closeStore = Instance.new("TextButton")
closeStore.Size = UDim2.new(0, 24, 0, 24)
closeStore.Position = UDim2.new(1, -28, 0, 3)
closeStore.BackgroundTransparency = 1
closeStore.Text = "×"
closeStore.TextColor3 = Color3.fromRGB(255, 80, 80)
closeStore.TextSize = 20
closeStore.Font = Enum.Font.GothamBold
closeStore.Parent = StoreUI
closeStore.MouseButton1Click:Connect(function()
    StoreUI.Visible = false
end)

local tabsCont = Instance.new("ScrollingFrame")
tabsCont.Size = UDim2.new(1, -16, 0, 30)
tabsCont.Position = UDim2.new(0, 8, 0, 35)
tabsCont.BackgroundTransparency = 1
tabsCont.BorderSizePixel = 0
tabsCont.ScrollBarThickness = 2
tabsCont.ScrollingDirection = Enum.ScrollingDirection.X
tabsCont.AutomaticCanvasSize = Enum.AutomaticSize.X
tabsCont.CanvasSize = UDim2.new(0, 0, 0, 0)
tabsCont.Parent = StoreUI

RegisterTheme(tabsCont, "ScrollBar")

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabsCont

local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(1, -16, 1, -80)
itemsScroll.Position = UDim2.new(0, 8, 0, 70)
itemsScroll.BackgroundTransparency = 1
itemsScroll.ScrollBarThickness = 4
itemsScroll.BorderSizePixel = 0
itemsScroll.Parent = StoreUI

RegisterTheme(itemsScroll, "ScrollBar")

local itemsLayout = Instance.new("UIListLayout")
itemsLayout.Padding = UDim.new(0, 5)
itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemsLayout.Parent = itemsScroll

local currentTab = "Potions"

local function clearItems()
    for _, c in ipairs(itemsScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local function createItemBtn(name, price, isPotion)
    local thm = Themes[CurrentSettings.Theme] or Themes.Dark
    local fnt = Fonts[CurrentSettings.Font] or Fonts.Modern

    local itemFr = Instance.new("Frame")
    itemFr.Size = UDim2.new(1, -4, 0, 36)
    -- Color de fondo del item: Un poco más claro que el fondo oscuro principal
    local r, g, b = thm.MainBg.R, thm.MainBg.G, thm.MainBg.B
    itemFr.BackgroundColor3 = Color3.new(r * 0.5, g * 0.5, b * 0.5)
    itemFr.BorderSizePixel = 0
    itemFr.Parent = itemsScroll
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = itemFr
    
    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(0.5, 0, 1, 0) -- Reducimos ancho para dar espacio a botones
    nm.Position = UDim2.new(0, 8, 0, 0)
    nm.BackgroundTransparency = 1
    
    -- Ajuste para nombres largos en móvil
    if isMb then
        nm.Text = name:gsub(" ", "\n") -- Salto de línea en espacios
        nm.TextSize = 10
        nm.TextWrapped = true
    else
        nm.Text = name
        nm.TextSize = 12
    end
    
    nm.TextColor3 = thm.Text
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.Font = fnt.Header
    nm.Parent = itemFr

    local prL = Instance.new("TextLabel")
    prL.Size = UDim2.new(0, 50, 1, 0)
    prL.Position = UDim2.new(0.5, 5, 0, 0) -- Ajustado
    prL.BackgroundTransparency = 1
    prL.Text = "$" .. tostring(price)
    prL.TextColor3 = Color3.fromRGB(255, 215, 0) -- Precio en dorado siempre destaca bien
    prL.Font = fnt.Body
    prL.TextSize = 11
    prL.TextXAlignment = Enum.TextXAlignment.Left
    prL.Parent = itemFr
    
    -- Contenedor derecho para alinear botones
    local rightOffset = -4
    
    -- Botón Comprar
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0, 40, 0, 24)
    buyBtn.Position = UDim2.new(1, rightOffset - 40, 0.5, -12)
    buyBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    buyBtn.Text = "BUY"
    buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyBtn.Font = fnt.Header
    buyBtn.TextSize = 10
    buyBtn.Parent = itemFr
    
    local bC = Instance.new("UICorner")
    bC.CornerRadius = UDim.new(0, 4)
    bC.Parent = buyBtn
    
    rightOffset = rightOffset - 45 -- Espacio para el siguiente elemento
    
    local qtyInput
    if isPotion then
        qtyInput = Instance.new("TextBox")
        qtyInput.Size = UDim2.new(0, 25, 0, 24)
        qtyInput.Position = UDim2.new(1, rightOffset - 25, 0.5, -12)
        qtyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        qtyInput.Text = "1"
        qtyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        qtyInput.Font = fnt.Body
        qtyInput.TextSize = 12
        qtyInput.Parent = itemFr
        
        local qC = Instance.new("UICorner")
        qC.CornerRadius = UDim.new(0, 4)
        qC.Parent = qtyInput
        
        qtyInput.FocusLost:Connect(function()
            local n = tonumber(qtyInput.Text)
            if not n then n = 1 end
            if n < 1 then n = 1 end
            if n > 32 then n = 32 end
            qtyInput.Text = tostring(n)
        end)
        
        rightOffset = rightOffset - 30 -- Espacio tras el input
    end
    
    -- Botón VIEW
    local viewBtn = Instance.new("TextButton")
    viewBtn.Size = UDim2.new(0, 40, 0, 24)
    viewBtn.Position = UDim2.new(1, rightOffset - 40, 0.5, -12)
    viewBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200) -- Azul para diferenciar
    viewBtn.Text = "VIEW"
    viewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    viewBtn.Font = fnt.Header
    viewBtn.TextSize = 10
    viewBtn.Parent = itemFr
    
    local vC = Instance.new("UICorner")
    vC.CornerRadius = UDim.new(0, 4)
    vC.Parent = viewBtn
    
    -- Lógica del botón View
    local viewing = false
    local lastCamCF = nil
    
    viewBtn.MouseButton1Click:Connect(function()
        -- Función de búsqueda robusta
        local function findTargetItem(targetName)
            local searchRoots = {workspace:FindFirstChild("Purchasable"), workspace:FindFirstChild("Shop"), workspace}
            
            -- Normalizar nombre buscado (quitar espacios, minúsculas)
            local cleanTarget = targetName:lower():gsub(" ", "")
            local rawTarget = targetName:lower()
            
            for _, root in pairs(searchRoots) do
                if root then
                    -- 1. Búsqueda directa y transformaciones simples en hijos
                    for _, child in ipairs(root:GetChildren()) do
                        local childName = child.Name:lower()
                        local childClean = childName:gsub(" ", "")
                        
                        -- Coincidencia exacta, sin espacios, o contenida
                        if childName == rawTarget or childClean == cleanTarget or childClean == cleanTarget .. "s" then
                            return child
                        end
                        
                        -- Coincidencia parcial inversa (ej: "Potion" busca en "BasicPotion")
                        if childName:find(cleanTarget) or cleanTarget:find(childName) then
                             -- Verificar si parece un item (tiene ShopItem o Precio)
                             if child:FindFirstChild("ShopItem") or child:FindFirstChild("Price") then
                                 return child
                             end
                        end
                    end
                    
                    -- 2. Búsqueda profunda de modelos con "ShopItem" (Más costosa pero efectiva)
                    if root == workspace then -- Solo hacer deep scan en workspace si falló lo anterior
                        for _, desc in ipairs(root:GetDescendants()) do
                            if desc:IsA("Model") and (desc:FindFirstChild("ShopItem") or desc:FindFirstChild("ShardPrice")) then
                                local dName = desc.Name:lower():gsub(" ", "")
                                if dName == cleanTarget or dName:find(cleanTarget) then
                                    return desc
                                end
                            end
                        end
                    end
                end
            end
            return nil
        end

        local targetItem = findTargetItem(name)
        
        if not targetItem then
            -- Debug info para el usuario (F9 Console)
            print("--- DEBUG VIEW ---")
            print("Searching for:", name)
            local p = workspace:FindFirstChild("Purchasable")
            if p then
                print("Items found in Purchasable:")
                for _, c in ipairs(p:GetChildren()) do
                    print("-", c.Name)
                end
            else
                print("Workspace.Purchasable NOT FOUND")
            end
            print("------------------")
            
            adLg("Item '" .. name .. "' not found! Check F9 console.", "error")
            return 
        end
        
        -- Validación extra: Verificar si está en el Workspace actual (Mapa visible)
        if not targetItem:IsDescendantOf(workspace) then
             adLg("Error: Cannot spectate. Item is not in the current map.", "error")
             return
        end
        
        local cam = workspace.CurrentCamera
        
        if not viewing then
            -- ACTIVAR VIEW
            viewing = true
            viewBtn.Text = "EXIT"
            viewBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            
            -- Guardar posición original
            lastCamCF = cam.CFrame
            cam.CameraType = Enum.CameraType.Scriptable
            
            -- Calcular bounding box y centro
            local cf, size
            if targetItem:IsA("Model") then
                cf, size = targetItem:GetBoundingBox()
            else
                cf = targetItem.CFrame
                size = targetItem.Size
            end
            
            -- === EFECTOS VISUALES (ESP/CHAMS) ===
            local highlight = Instance.new("Highlight")
            highlight.Name = "ViewHighlight"
            highlight.Adornee = targetItem
            highlight.FillColor = Color3.new(1, 1, 1) -- Blanco
            highlight.OutlineColor = Color3.new(1, 1, 1) -- Blanco
            highlight.FillTransparency = 0.75 -- Sutil para ver textura
            highlight.OutlineTransparency = 0.1
            highlight.Parent = targetItem
            
            local bbGui = Instance.new("BillboardGui")
            bbGui.Name = "ViewInfo"
            bbGui.Adornee = targetItem
            bbGui.Size = UDim2.new(0, 200, 0, 50)
            bbGui.StudsOffset = Vector3.new(0, math.max(size.Y, 3) + 2, 0)
            bbGui.AlwaysOnTop = true
            bbGui.Parent = targetItem
            
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, 0, 1, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.new(1, 1, 1)
            infoLabel.TextStrokeTransparency = 0
            infoLabel.Font = Enum.Font.GothamBold
            infoLabel.TextSize = 14
            infoLabel.Text = name
            infoLabel.Parent = bbGui
            -- ====================================
            
            -- Configuración de órbita
            local centerPos = cf.Position
            local radius = math.max(size.X, size.Y, size.Z) * 1.8 + 5 
            local heightOffset = math.max(size.Y, 2) * 0.5
            local angle = 0
            
            -- Conexión de rotación y actualización de info
            local rotConnection
            rotConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
                if not viewing or not viewBtn.Parent then 
                    if rotConnection then rotConnection:Disconnect() end
                    -- Limpieza de emergencia
                    if highlight then highlight:Destroy() end
                    if bbGui then bbGui:Destroy() end
                    return
                end
                
                angle = angle + dt * 0.8
                
                -- Calcular posición orbital
                local offsetX = math.cos(angle) * radius
                local offsetZ = math.sin(angle) * radius
                local camPos = centerPos + Vector3.new(offsetX, heightOffset, offsetZ)
                
                -- Suavizar movimiento de cámara
                local newCF = CFrame.new(camPos, centerPos)
                cam.CFrame = cam.CFrame:Lerp(newCF, 0.1)
                
                -- Actualizar distancia en el texto
                local plr = game.Players.LocalPlayer
                if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - centerPos).Magnitude
                    infoLabel.Text = string.format("%s\n[ %.1f studs ]", name, dist)
                end
            end)
            
            viewBtn:SetAttribute("RotationActive", true)
            viewBtn.MouseButton1Click:Connect(function()
                 if rotConnection then rotConnection:Disconnect() end
                 -- Limpiar efectos al hacer click para salir
                 if highlight then highlight:Destroy() end
                 if bbGui then bbGui:Destroy() end
            end)
            
            adLg("Viewing '" .. name .. "'. Click again to exit.", "info")
        else
            -- SALIR DE VIEW
            viewing = false
            viewBtn.Text = "VIEW"
            viewBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
            
            -- Asegurar limpieza (por si acaso)
            local oldH = targetItem:FindFirstChild("ViewHighlight")
            if oldH then oldH:Destroy() end
            local oldB = targetItem:FindFirstChild("ViewInfo")
            if oldB then oldB:Destroy() end
            
            if lastCamCF then
                local tween = game:GetService("TweenService"):Create(cam, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = lastCamCF})
                tween:Play()
                tween.Completed:Connect(function()
                    if not viewing then
                        cam.CameraType = Enum.CameraType.Custom
                    end
                end)
            else
                 cam.CameraType = Enum.CameraType.Custom
            end
        end
    end)
    
    buyBtn.MouseButton1Click:Connect(function()
        local q = 1
        if qtyInput then
            q = tonumber(qtyInput.Text) or 1
        end
        buyItem(name, q)
    end)
end

local categories = {
    Potions = {
        {Name = "Basic Capacity Potion", Price = '40k'},
        {Name = "Greater Capacity Potion", Price = '20 S'},
        {Name = "Basic Luck Potion", Price = '50k'},
        {Name = "Greater Luck Potion", Price = '30 S'},
        {Name = "Merchant's Potion", Price = '200 S'},
        {Name = "Blitz Potion", Price = '0'},
        {Name = "Instability Potion", Price = '0'},
        {Name = "Quake Potion", Price = '0'}
    },
    Pans = {
        {Name = "Diamond Pan", Price = '10M'},
        {Name = "Golden Pan", Price = '300k'},
        {Name = "Magnetic Pan", Price = '1M'},
        {Name = "Meteoric Pan", Price = '3,5M'}
    },
    Shovels = {
        {Name = "Diamond Shovel", Price = '12M'},
        {Name = "Golden Shovel", Price = '1,33M'},
        {Name = "Meteoric Shovel", Price = '4M'},
        {Name = "The Excavator", Price = '320k'}
    },
    Other = {
        {Name = "Cosmic Resonator", Price = '0'},
        {Name = "Titanic Enchant Book", Price = '0'},
        {Name = "Traveler's Backpack", Price = '0'}
    },
    Sluices = {
        -- Aquí irán los Sluices
    }
}

local function formatNumber(n)
    if not tonumber(n) then return n end
    n = tonumber(n)
    if n >= 1e21 then return string.format("%.1f Sx", n/1e21) end
    if n >= 1e18 then return string.format("%.1f Qi", n/1e18) end
    if n >= 1e15 then return string.format("%.1f Qa", n/1e15) end
    if n >= 1e12 then return string.format("%.1f T", n/1e12) end
    if n >= 1e9 then return string.format("%.1f B", n/1e9) end
    if n >= 1e6 then return string.format("%.1f M", n/1e6) end
    if n >= 1e3 then return string.format("%.1f k", n/1e3) end
    return tostring(n)
end

local function getItemPrice(name)
    local purchasable = workspace:FindFirstChild("Purchasable")
    if not purchasable then return nil end
    
    local item = purchasable:FindFirstChild(name)
    if not item then return nil end
    
    local shopItem = item:FindFirstChild("ShopItem")
    if not shopItem then return nil end
    
    -- Revisar si tiene precio en Shards
    local shardPriceObj = shopItem:FindFirstChild("ShardPrice")
    if shardPriceObj then
        if shardPriceObj:IsA("IntValue") or shardPriceObj:IsA("NumberValue") then
            return formatNumber(shardPriceObj.Value) .. " S"
        elseif shardPriceObj:IsA("StringValue") then
            return shardPriceObj.Value .. " S"
        end
    end
    
    local attrShard = shopItem:GetAttribute("ShardPrice")
    if attrShard then
        return formatNumber(attrShard) .. " S"
    end
    
    -- Revisar precio normal
    local priceObj = shopItem:FindFirstChild("Price")
    if priceObj then
        if priceObj:IsA("IntValue") or priceObj:IsA("NumberValue") then
            return formatNumber(priceObj.Value)
        elseif priceObj:IsA("StringValue") then
            return priceObj.Value
        end
    end
    
    local attrPrice = shopItem:GetAttribute("Price")
    if attrPrice then
        return formatNumber(attrPrice)
    end
    
    return nil
end

local function loadTab(tabName)
    clearItems()
    currentTab = tabName
    local items = categories[tabName] or {}
    for _, it in ipairs(items) do
        local realPrice = getItemPrice(it.Name)
        createItemBtn(it.Name, realPrice or it.Price, tabName == "Potions")
    end
end

local function createTabBtn(name, order)
    local thm = Themes[CurrentSettings.Theme] or Themes.Dark
    local fnt = Fonts[CurrentSettings.Font] or Fonts.Modern

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundColor3 = thm.Button
    btn.Text = name
    btn.TextColor3 = thm.SubText
    btn.Font = fnt.Header
    btn.TextSize = 11
    btn.LayoutOrder = order or 0
    btn.Parent = tabsCont
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local cThm = Themes[CurrentSettings.Theme] or Themes.Dark
        for _, b in ipairs(tabsCont:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = cThm.Button
                b.TextColor3 = cThm.SubText
            end
        end
        btn.BackgroundColor3 = cThm.Accent
        btn.TextColor3 = cThm.Text -- Texto destacado para activo
        loadTab(name)
    end)
    
    return btn
end

local t1 = createTabBtn("Pans", 1)
local t2 = createTabBtn("Shovels", 2)
local t3 = createTabBtn("Potions", 3)
local t5 = createTabBtn("Other", 5)
local t6 = createTabBtn("Sluices", 6)

-- Inicializar pestaña activa con colores del tema
loadTab("Pans")
local thmInit = Themes[CurrentSettings.Theme] or Themes.Dark
t1.BackgroundColor3 = thmInit.Accent
t1.TextColor3 = thmInit.Text

crEB("Open Store", 4, Color3.fromRGB(50, 205, 50), {
    {
        text = "Open Marketplace",
        onClick = function()
            StoreUI.Visible = not StoreUI.Visible
            -- Recargar items al abrir para asegurar precios y tema actualizados
            if StoreUI.Visible then
                loadTab(currentTab)
            end
        end
    }
}, "76035829356840")

-- ============================================
-- [ SETTINGS MENU ]
-- ============================================

local themeSubs = {}
for name, _ in pairs(Themes) do
    table.insert(themeSubs, {
        text = name,
        onClick = function()
            CurrentSettings.Theme = name
            UpdateAllThemes()
            SaveSettings()
            adLg("THEME: "..name, "info")
        end
    })
end

local fontSubs = {}
for name, _ in pairs(Fonts) do
    table.insert(fontSubs, {
        text = name,
        onClick = function()
            CurrentSettings.Font = name
            UpdateAllThemes()
            SaveSettings()
            adLg("FONT: "..name, "info")
        end
    })
end

crEB("AJUSTES", 10, Color3.fromRGB(150, 150, 150), {
    {
        text = "Temas",
        subs = themeSubs
    },
    {
        text = "Fuentes",
        subs = fontSubs
    }
}, "81608653656339")

local isMn = false

local OPN = Instance.new("Frame")
OPN.Name = "OPN"
OPN.Size = UDim2.new(0, isMb and 170 or 190, 0, isMb and 36 or 40)
OPN.Position = UDim2.new(0.5, isMb and -85 or -95, 0.05, 0) 
OPN.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
OPN.BackgroundTransparency = 0.1
OPN.Visible = false
OPN.Parent = SG

local opC = Instance.new("UICorner")
opC.CornerRadius = UDim.new(1, 0) 
opC.Parent = OPN

local opS = Instance.new("UIStroke")
opS.Color = Color3.fromRGB(60, 60, 65)
opS.Thickness = 1.2
opS.Parent = OPN

local dIco = Instance.new("ImageLabel")
dIco.Name = "dIco"
dIco.Size = UDim2.new(0, 28, 0, 28)
dIco.Position = UDim2.new(0, 10, 0.5, -14)
dIco.BackgroundTransparency = 1
dIco.Image = "rbxassetid://104557258924469"
dIco.ImageColor3 = Color3.fromRGB(200, 200, 200)
dIco.Parent = OPN

local sep = Instance.new("Frame")
sep.Name = "Sep"
sep.Size = UDim2.new(0, 1, 0.6, 0)
sep.Position = UDim2.new(0, 48, 0.2, 0)
sep.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sep.BorderSizePixel = 0
sep.Parent = OPN

local icoId = isMb and "rbxassetid://106598108841068" or "rbxassetid://99880982637222"
local mIco = Instance.new("ImageLabel")
mIco.Name = "mIco"
mIco.Size = UDim2.new(0, 28, 0, 28)
mIco.Position = UDim2.new(0, 58, 0.5, -14)
mIco.BackgroundTransparency = 1
mIco.Image = icoId
mIco.Parent = OPN

local opTx = Instance.new("TextLabel")
opTx.Name = "Status"
opTx.Size = UDim2.new(0, 100, 1, 0)
opTx.Position = UDim2.new(0, 92, 0, 0)
opTx.BackgroundTransparency = 1
opTx.Text = "Open Farm UI"
opTx.TextColor3 = Color3.fromRGB(255, 255, 255)
opTx.TextSize = isMb and 12 or 13
opTx.Font = Enum.Font.GothamBold
opTx.TextXAlignment = Enum.TextXAlignment.Left
opTx.Parent = OPN

local opB = Instance.new("TextButton")
opB.Name = "opB"
opB.Size = UDim2.new(1, 0, 1, 0)
opB.BackgroundTransparency = 1
opB.Text = ""
opB.Parent = OPN

local odrg = false
local odrI, omsP, ofrP

opB.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        odrg = true
        omsP = inp.Position
        ofrP = OPN.Position
        
        local startClick = tick()
        
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                odrg = false
                if (tick() - startClick < 0.3) and (inp.Position - omsP).Magnitude < 10 then
                    OPN.Visible = false
                    MF.Visible = true
                    MF.ClipsDescendants = false
                    
                    local tween = TS:Create(MF, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                         Size = UDim2.new(0, scW, 0, scH),
                         BackgroundTransparency = 0.12
                    })
                    tween:Play()
                    
                    tween.Completed:Wait()
                    isMn = false
                end
            end
        end)
    end
end)

opB.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        odrI = inp
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp == odrI and odrg then
        local dlt = inp.Position - omsP
        TS:Create(OPN, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
            Position = UDim2.new(ofrP.X.Scale, ofrP.X.Offset + dlt.X, ofrP.Y.Scale, ofrP.Y.Offset + dlt.Y)
        }):Play()
    end
end)

local drI, msP, frP

TB.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        drg = true
        msP = inp.Position
        frP = MF.Position
        
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                drg = false
            end
        end)
    end
end)

TB.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        drI = inp
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp == drI and drg then
        local dlt = inp.Position - msP
        TS:Create(MF, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(frP.X.Scale, frP.X.Offset + dlt.X, frP.Y.Scale, frP.Y.Offset + dlt.Y)
        }):Play()
    end
end)

CLB.MouseButton1Click:Connect(function()
    spAF()
    adLg("UI CLOSED BY USER", "error")
    task.wait(0.5)
    TS:Create(MF, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.35)
    SG:Destroy()
end)

local ogS = MF.Size

MNB.MouseButton1Click:Connect(function()
    if not isMn then
        isMn = true
        
        MF.ClipsDescendants = true
        
        TS:Create(MF, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.3)
        MF.Visible = false
        
        OPN.Visible = true
        OPN.Position = UDim2.new(0.5, isMb and -85 or -95, 0.1, 0)
        
        OPN.Size = UDim2.new(0, 0, 0, isMb and 36 or 40)
        TS:Create(OPN, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
             Size = UDim2.new(0, isMb and 170 or 190, 0, isMb and 36 or 40)
        }):Play()
        
        adLg("UI MINIMIZED", "info")
    end
end)

MF.Size = UDim2.new(0, 0, 0, 0)
MF.BackgroundTransparency = 1
task.wait(0.15)
TS:Create(MF, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, scW, 0, scH),
    BackgroundTransparency = 0.12
}):Play()

task.spawn(function()
    while MF.Parent do
        TS:Create(GRD, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
            Rotation = 405
        }):Play()
        task.wait(4)
    end
end)

task.wait(0.6)
adLg("SYSTEM INITIALIZED", "success")
adLg("DEVICE: "..(isMb and "MOBILE" or "DESKTOP"), "info")
adLg("READY TO USE", "success")

-- Ejecutar Diagnóstico Inicial y enviar a Discord
task.spawn(runHealthCheck)

print("✨ UI cargado - "..(isMb and "MOBILE" or "DESKTOP"))

-- ============================================
-- [ GLOBAL SHUTDOWN FUNCTION ] - OBFUSCATION SAFE
-- ============================================
_G.ProspectingHubShutdown = function()
    -- Stop all running processes
    afR = false
    if afL then 
        task.cancel(afL) 
        afL = nil
    end
    
    -- Stop Anti-Rollback
    if AntiRollback then
        AntiRollback:stop()
    end
    
    -- Clear global flags
    _G.ProspectingHubActive = false
    _G.AutoFarm = false
    _G.AutoSell = false
    _G.ConfirmSellEverything = false
    _G.ConfirmSellSimilar = false
    
    -- Destroy UI
    if SG then 
        SG:Destroy() 
    end
    
    -- Notify user
    if game:GetService("StarterGui") then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Script Stopped",
                Text = "Previous instance cleaned up successfully.",
                Duration = 2
            })
        end)
    end
    
    -- Clear shutdown function
    _G.ProspectingHubShutdown = nil
end
