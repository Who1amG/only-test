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
local LP = PLS.LocalPlayer

-- Detección de dispositivo
local function isDv()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local isMb = isDv()
local scW = isMb and 340 or 520
local scH = isMb and 380 or 440

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
MF.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MF.BackgroundTransparency = 0.12
MF.BorderSizePixel = 0
MF.ClipsDescendants = true
MF.Parent = SG

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
STK.Color = Color3.fromRGB(90, 90, 110)
STK.Thickness = 1.2
STK.Transparency = 0.6
STK.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
STK.Parent = MF

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
TB.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TB.BackgroundTransparency = 0.25
TB.BorderSizePixel = 0
TB.Parent = MF

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
TT.TextColor3 = Color3.fromRGB(255, 255, 255)
TT.TextSize = isMb and 14 or 16
TT.Font = Enum.Font.GothamBold
TT.TextXAlignment = Enum.TextXAlignment.Left
TT.Parent = TB

-- Subtítulo dispositivo
local STB = Instance.new("TextLabel")
STB.Name = "STB"
STB.Size = UDim2.new(1, -100, 0, 12)
STB.Position = UDim2.new(0, isMb and 12 or 16, 1, -14)
STB.BackgroundTransparency = 1
STB.Text = isMb and "📱 MOBILE" or "💻 DESKTOP"
STB.TextColor3 = Color3.fromRGB(150, 150, 170)
STB.TextSize = isMb and 9 or 10
STB.Font = Enum.Font.Gotham
STB.TextXAlignment = Enum.TextXAlignment.Left
STB.Parent = TB

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

local CR3 = Instance.new("UICorner")
CR3.CornerRadius = UDim.new(0, isMb and 10 or 12)
CR3.Parent = LGC

local STK2 = Instance.new("UIStroke")
STK2.Color = Color3.fromRGB(60, 60, 80)
STK2.Thickness = 1
STK2.Transparency = 0.7
STK2.Parent = LGC

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

local LYT2 = Instance.new("UIListLayout")
LYT2.Padding = UDim.new(0, isMb and 4 or 6)
LYT2.SortOrder = Enum.SortOrder.LayoutOrder
LYT2.VerticalAlignment = Enum.VerticalAlignment.Top
LYT2.Parent = SCR

-- Sistema de Logs (AUTO-DELETE DESPUÉS DE 6 SEGUNDOS)
local lgC = 0

local function adLg(txt, typ)
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
    SBF.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    SBF.BackgroundTransparency = 0.5
    SBF.BorderSizePixel = 0
    SBF.LayoutOrder = ord
    SBF.Visible = false
    SBF.Parent = par
    
    local crS = Instance.new("UICorner")
    crS.CornerRadius = UDim.new(0, isMb and 8 or 10)
    crS.Parent = SBF
    
    local stS = Instance.new("UIStroke")
    stS.Color = Color3.fromRGB(60, 60, 80)
    stS.Thickness = 0.8
    stS.Transparency = 0.8
    stS.Parent = SBF
    
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
    txS.TextColor3 = Color3.fromRGB(200, 200, 220)
    txS.TextSize = isMb and 10 or 11
    txS.Font = Enum.Font.Gotham
    txS.TextXAlignment = Enum.TextXAlignment.Left
    txS.Parent = SBF
    
    btn.MouseEnter:Connect(function()
        TS:Create(SBF, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.35
        }):Play()
        TS:Create(stS, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Transparency = 0.5,
            Color = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TS:Create(SBF, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.5
        }):Play()
        TS:Create(stS, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Transparency = 0.8,
            Color = Color3.fromRGB(60, 60, 80)
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
    SBF.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    SBF.BackgroundTransparency = 0.4
    SBF.BorderSizePixel = 0
    SBF.LayoutOrder = ord
    SBF.Visible = false
    SBF.Parent = par
    
    local crS = Instance.new("UICorner")
    crS.CornerRadius = UDim.new(0, isMb and 8 or 10)
    crS.Parent = SBF
    
    local stS = Instance.new("UIStroke")
    stS.Color = Color3.fromRGB(80, 80, 100)
    stS.Thickness = 0.8
    stS.Transparency = 0.6
    stS.Parent = SBF
    
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
    txS.TextColor3 = Color3.fromRGB(220, 220, 240)
    txS.TextSize = isMb and 10 or 11
    txS.Font = Enum.Font.GothamBold
    txS.TextXAlignment = Enum.TextXAlignment.Left
    txS.Parent = SBF
    
    local arr = Instance.new("TextLabel")
    arr.Name = "arr"
    arr.Size = UDim2.new(0, 20, 0, 20)
    arr.Position = UDim2.new(1, -25, 0.5, -10)
    arr.BackgroundTransparency = 1
    arr.Text = "›"
    arr.TextColor3 = Color3.fromRGB(180, 180, 200)
    arr.TextSize = isMb and 16 or 18
    arr.Font = Enum.Font.GothamBold
    arr.Parent = SBF
    
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
    BF.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    BF.BackgroundTransparency = 0.45
    BF.BorderSizePixel = 0
    BF.LayoutOrder = ord
    BF.Parent = SCL
    
    local crB = Instance.new("UICorner")
    crB.CornerRadius = UDim.new(0, isMb and 8 or 10)
    crB.Parent = BF
    
    local stB = Instance.new("UIStroke")
    stB.Color = Color3.fromRGB(70, 70, 90)
    stB.Thickness = 1
    stB.Transparency = 0.75
    stB.Parent = BF
    
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
    txB.TextColor3 = Color3.fromRGB(240, 240, 255)
    txB.TextSize = isMb and 10 or 12
    txB.Font = Enum.Font.GothamMedium
    txB.TextXAlignment = Enum.TextXAlignment.Left
    txB.TextTruncate = Enum.TextTruncate.AtEnd
    txB.Parent = BF
    
    local arr = Instance.new("TextLabel")
    arr.Name = "arr"
    arr.Size = UDim2.new(0, 20, 0, 20)
    arr.Position = UDim2.new(1, isMb and -28 or -32, 0.5, -10)
    arr.BackgroundTransparency = 1
    arr.Text = "›"
    arr.TextColor3 = Color3.fromRGB(180, 180, 200)
    arr.TextSize = isMb and 18 or 22
    arr.Font = Enum.Font.GothamBold
    arr.Rotation = 0
    arr.Parent = BF
    
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
            Transparency = 0.4,
            Color = Color3.fromRGB(255, 255, 255)
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
            Transparency = 0.75,
            Color = Color3.fromRGB(70, 70, 90)
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
    
    btn.MouseButton1Click:Connect(function()
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
            end)
            
            adLg("EXPANDED: "..txt, "info")
        else
            subC.AutomaticSize = Enum.AutomaticSize.None
            subC.Size = UDim2.new(1, 0, 0, subC.AbsoluteSize.Y)
            TS:Create(subC, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            task.wait(0.3)
            for _, c in ipairs(subC:GetChildren()) do
                if c:IsA("Frame") then
                    c.Visible = false
                end
            end
            
            adLg("COLLAPSED: "..txt, "info")
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
        if starter then return starter:GetPivot() end
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
    
    repeat
        returnAttempts = returnAttempts + 1
        
        bypassTP(startPos) 
        hrp.Velocity = Vector3.zero
        hrp.Anchored = true
        task.wait(0.2)
        hrp.Anchored = false
        
        task.wait(0.3)
        
        local distReturn = (hrp.Position - startPos.Position).Magnitude
        if distReturn < 10 then
            returned = true
        else
            adLg("RETURN GLITCHED - RETRYING ("..returnAttempts..")", "warning")
        end
        
    until returned or returnAttempts >= 5
    
    if returned then
         adLg("RETURNED SAFELY", "info")
    else
         adLg("RETURN FAILED - MANUALLY WALK BACK", "error")
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
                            
                            if tick() - stuckTime > 4 then
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

crEB("Speed", 2, Color3.fromRGB(150, 100, 255), {
    {
        text = "Speed x1.5",
        onClick = function()
            LP.Character.Humanoid.WalkSpeed = 24
            adLg("SPEED: 1.5x", "success")
        end
    },
    {
        text = "Speed x2",
        onClick = function()
            LP.Character.Humanoid.WalkSpeed = 32
            adLg("SPEED: 2x", "success")
        end
    },
    {
        text = "Reset Speed",
        onClick = function()
            LP.Character.Humanoid.WalkSpeed = 16
            adLg("SPEED RESET", "info")
        end
    }
}, "92660651692951")

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
StoreUI.BorderSizePixel = 0
StoreUI.Visible = false
StoreUI.ClipsDescendants = true
StoreUI.Parent = SG
StoreUI.Active = true
StoreUI.Draggable = true

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = StoreUI

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 80)
uiStroke.Thickness = 1.5
uiStroke.Parent = StoreUI

local storeTitle = Instance.new("TextLabel")
storeTitle.Size = UDim2.new(1, 0, 0, 30)
storeTitle.BackgroundTransparency = 1
storeTitle.Text = "MARKETPLACE"
storeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
storeTitle.Font = Enum.Font.GothamBold
storeTitle.TextSize = 14
storeTitle.Parent = StoreUI

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

local tabsCont = Instance.new("Frame")
tabsCont.Size = UDim2.new(1, -16, 0, 30)
tabsCont.Position = UDim2.new(0, 8, 0, 35)
tabsCont.BackgroundTransparency = 1
tabsCont.Parent = StoreUI

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Parent = tabsCont

local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(1, -16, 1, -80)
itemsScroll.Position = UDim2.new(0, 8, 0, 70)
itemsScroll.BackgroundTransparency = 1
itemsScroll.ScrollBarThickness = 4
itemsScroll.BorderSizePixel = 0
itemsScroll.Parent = StoreUI

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

local function createItemBtn(name, isPotion)
    local itemFr = Instance.new("Frame")
    itemFr.Size = UDim2.new(1, -4, 0, 36)
    itemFr.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    itemFr.BorderSizePixel = 0
    itemFr.Parent = itemsScroll
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = itemFr
    
    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(0.6, 0, 1, 0)
    nm.Position = UDim2.new(0, 8, 0, 0)
    nm.BackgroundTransparency = 1
    nm.Text = name
    nm.TextColor3 = Color3.fromRGB(220, 220, 220)
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.Font = Enum.Font.GothamMedium
    nm.TextSize = 12
    nm.Parent = itemFr
    
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0, 50, 0, 24)
    buyBtn.Position = UDim2.new(1, -58, 0.5, -12)
    buyBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    buyBtn.Text = "BUY"
    buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 10
    buyBtn.Parent = itemFr
    
    local bC = Instance.new("UICorner")
    bC.CornerRadius = UDim.new(0, 4)
    bC.Parent = buyBtn
    
    local qtyInput
    if isPotion then
        qtyInput = Instance.new("TextBox")
        qtyInput.Size = UDim2.new(0, 30, 0, 24)
        qtyInput.Position = UDim2.new(1, -95, 0.5, -12)
        qtyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        qtyInput.Text = "1"
        qtyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        qtyInput.Font = Enum.Font.Gotham
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
    end
    
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
        "Basic Capacity Potion", "Greater Capacity Potion", 
        "Basic Luck Potion", "Greater Luck Potion", "Merchant's Potion"
    },
    Pans = {
        "Diamond Pan", "Golden Pan", "Magnetic Pan", "Meteoric Pan"
    },
    Shovels = {
        "Diamond Shovel", "Golden Shovel", "Meteoric Shovel"
    },
    Totems = {
        "Luck Totem", "Strength Totem"
    }
}

local function loadTab(tabName)
    clearItems()
    currentTab = tabName
    local items = categories[tabName] or {}
    for _, it in ipairs(items) do
        createItemBtn(it, tabName == "Potions")
    end
end

local function createTabBtn(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = tabsCont
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabsCont:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadTab(name)
    end)
    
    return btn
end

local t1 = createTabBtn("Pans")
local t2 = createTabBtn("Shovels")
local t3 = createTabBtn("Potions")
local t4 = createTabBtn("Totems")

loadTab("Pans")
t1.BackgroundColor3 = Color3.fromRGB(60, 100, 200)

crEB("Open Store", 4, Color3.fromRGB(50, 205, 50), {
    {
        text = "Open Marketplace",
        onClick = function()
            StoreUI.Visible = not StoreUI.Visible
        end
    }
}, "121468959425923")

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
