local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GunFinderV9"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
-- Protección
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = game.CoreGui
end
-- ==================== MAIN FRAME ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.8
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame
-- ==================== BACKGROUND IMAGE (DENTRO DEL UI) ====================
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BackgroundImage"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://78950474006105"
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ImageTransparency = 0.25
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame
-- Oscurecer un poco el fondo
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.35
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 0
Overlay.Parent = MainFrame
-- Glass effect gradient
local GlassGradient = Instance.new("UIGradient")
GlassGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
}
GlassGradient.Rotation = 45
GlassGradient.Parent = MainFrame
-- ==================== STAR RAIN (PUNTOS LUMINOSOS) ====================
local StarFrame = Instance.new("Frame")
StarFrame.Name = "StarFrame"
StarFrame.Size = UDim2.new(1, 0, 1, 0)
StarFrame.Position = UDim2.new(0, 0, 0, 0)
StarFrame.BackgroundTransparency = 1
StarFrame.ZIndex = 100
StarFrame.ClipsDescendants = true
StarFrame.Parent = MainFrame
local function createStar()
    -- Frame contenedor para la estrella
    local starContainer = Instance.new("Frame")
    starContainer.Size = UDim2.new(0, 4, 0, 4)
    starContainer.BackgroundTransparency = 1
    starContainer.ZIndex = 101
    starContainer.Parent = StarFrame
    
    -- Núcleo brillante de la estrella
    local starCore = Instance.new("Frame")
    starCore.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    starCore.Position = UDim2.new(0.5, -1, 0.5, -1)
    starCore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    starCore.BackgroundTransparency = 0.2
    starCore.BorderSizePixel = 0
    starCore.ZIndex = 102
    starCore.Parent = starContainer
    
    local coreCorner = Instance.new("UICorner")
    coreCorner.CornerRadius = UDim.new(1, 0)
    coreCorner.Parent = starCore
    
    -- Brillo exterior (glow effect)
    local starGlow = Instance.new("Frame")
    starGlow.Size = UDim2.new(0, math.random(6, 10), 0, math.random(6, 10))
    starGlow.Position = UDim2.new(0.5, -math.random(3, 5), 0.5, -math.random(3, 5))
    starGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    starGlow.BackgroundTransparency = 0.6
    starGlow.BorderSizePixel = 0
    starGlow.ZIndex = 101
    starGlow.Parent = starContainer
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = starGlow
    
    -- Elegir esquina aleatoria
    local corner = math.random(1, 4)
    local startX, startY, endX, endY
    if corner == 1 then -- Top-left
        startX = math.random(0, 10)/100 - 0.05
        startY = math.random(0, 10)/100 - 0.05
        endX = startX + math.random(40, 80)/100
        endY = startY + math.random(40, 80)/100 + 0.1
    elseif corner == 2 then -- Top-right
        startX = 1 - math.random(0, 10)/100 + 0.05
        startY = math.random(0, 10)/100 - 0.05
        endX = startX - math.random(40, 80)/100
        endY = startY + math.random(40, 80)/100 + 0.1
    elseif corner == 3 then -- Bottom-left
        startX = math.random(0, 10)/100 - 0.05
        startY = 1 - math.random(0, 10)/100 + 0.05
        endX = startX + math.random(40, 80)/100
        endY = startY - math.random(40, 80)/100 - 0.1
    else -- Bottom-right
        startX = 1 - math.random(0, 10)/100 + 0.05
        startY = 1 - math.random(0, 10)/100 + 0.05
        endX = startX - math.random(40, 80)/100
        endY = startY - math.random(40, 80)/100 - 0.1
    end
    
    starContainer.Position = UDim2.new(startX, 0, startY, 0)
    
    local duration = math.random(30, 60)/10  -- 3-6 seconds, slower for clean effect
    
    -- Animación de movimiento
    TweenService:Create(starContainer, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(endX, 0, endY, 0)
    }):Play()
    
    -- Fade out al final sin parpadeo
    task.delay(duration - 0.8, function()
        TweenService:Create(starCore, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        TweenService:Create(starGlow, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    end)
    
    task.delay(duration, function()
        starContainer:Destroy()
    end)
end
-- Generar estrellas continuamente, pero menos frecuentes
task.spawn(function()
    while task.wait(math.random(400, 900) / 1000) do  -- 0.4-0.9 seg, menos denso
        if ScreenGui.Parent and MainFrame.Parent then
            createStar()
        else
            break
        end
    end
end)
-- ==================== HEADER ====================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.BackgroundTransparency = 0.45
Header.BorderSizePixel = 0
Header.ZIndex = 2
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 18)
HeaderFix.Position = UDim2.new(0, 0, 1, -18)
HeaderFix.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HeaderFix.BackgroundTransparency = 0.45
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 2
HeaderFix.Parent = Header
local HeaderFixCorner = Instance.new("UICorner")
HeaderFixCorner.CornerRadius = UDim.new(0, 16)
HeaderFixCorner.Parent = HeaderFix
local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = Color3.fromRGB(255, 255, 255)
HeaderStroke.Transparency = 0.85
HeaderStroke.Thickness = 1
HeaderStroke.Parent = Header
-- Icon
local Icon = Instance.new("TextLabel")
Icon.Size = UDim2.new(0, 35, 0, 35)
Icon.Position = UDim2.new(0, 10, 0, 7.5)
Icon.BackgroundTransparency = 1
Icon.Text = "🎯"
Icon.TextSize = 22
Icon.ZIndex = 3
Icon.Parent = Header
-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, -18)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GUN TABLE FINDER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Header
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -110, 0, 14)
Subtitle.Position = UDim2.new(0, 50, 0, 26)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Version 9.0 • Perfect Edition"
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextTransparency = 0.3
Subtitle.ZIndex = 3
Subtitle.Parent = Header
-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -40, 0, 9)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BackgroundTransparency = 0.25
CloseButton.Text = ""
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 3
CloseButton.Parent = Header
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton
local CloseIcon = Instance.new("TextLabel")
CloseIcon.Size = UDim2.new(1, 0, 1, 0)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "✕"
CloseIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseIcon.Font = Enum.Font.GothamBold
CloseIcon.TextSize = 16
CloseIcon.ZIndex = 4
CloseIcon.Parent = CloseButton
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.25}):Play()
end)
CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    wait(0.3)
    ScreenGui:Destroy()
end)
-- ==================== CONTENT AREA ====================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -18, 1, -115)
ContentFrame.Position = UDim2.new(0, 9, 0, 58)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainFrame
-- Left Panel (Options)
local OptionsPanel = Instance.new("ScrollingFrame")
OptionsPanel.Size = UDim2.new(0.44, -5, 1, 0)
OptionsPanel.Position = UDim2.new(0, 0, 0, 0)
OptionsPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OptionsPanel.BackgroundTransparency = 0.5
OptionsPanel.BorderSizePixel = 0
OptionsPanel.ScrollBarThickness = 4
OptionsPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
OptionsPanel.ScrollBarImageTransparency = 0.6
OptionsPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
OptionsPanel.ZIndex = 2
OptionsPanel.Parent = ContentFrame
local OptionsCorner = Instance.new("UICorner")
OptionsCorner.CornerRadius = UDim.new(0, 16)
OptionsCorner.Parent = OptionsPanel
local OptionsStroke = Instance.new("UIStroke")
OptionsStroke.Color = Color3.fromRGB(255, 255, 255)
OptionsStroke.Transparency = 0.85
OptionsStroke.Thickness = 1
OptionsStroke.Parent = OptionsPanel
local OptionsLayout = Instance.new("UIListLayout")
OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
OptionsLayout.Padding = UDim.new(0, 5)
OptionsLayout.Parent = OptionsPanel
local OptionsPadding = Instance.new("UIPadding")
OptionsPadding.PaddingLeft = UDim.new(0, 8)
OptionsPadding.PaddingRight = UDim.new(0, 8)
OptionsPadding.PaddingTop = UDim.new(0, 8)
OptionsPadding.PaddingBottom = UDim.new(0, 8)
OptionsPadding.Parent = OptionsPanel
-- Right Panel (Logs)
local LogPanel = Instance.new("ScrollingFrame")
LogPanel.Size = UDim2.new(0.56, -5, 1, 0)
LogPanel.Position = UDim2.new(0.44, 5, 0, 0)
LogPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogPanel.BackgroundTransparency = 0.5
LogPanel.BorderSizePixel = 0
LogPanel.ScrollBarThickness = 4
LogPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
LogPanel.ScrollBarImageTransparency = 0.6
LogPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
LogPanel.ZIndex = 2
LogPanel.Parent = ContentFrame
local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 16)
LogCorner.Parent = LogPanel
local LogStroke = Instance.new("UIStroke")
LogStroke.Color = Color3.fromRGB(255, 255, 255)
LogStroke.Transparency = 0.85
LogStroke.Thickness = 1
LogStroke.Parent = LogPanel
local LogLayout = Instance.new("UIListLayout")
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 3)
LogLayout.Parent = LogPanel
local LogPadding = Instance.new("UIPadding")
LogPadding.PaddingLeft = UDim.new(0, 8)
LogPadding.PaddingRight = UDim.new(0, 8)
LogPadding.PaddingTop = UDim.new(0, 8)
LogPadding.PaddingBottom = UDim.new(0, 8)
LogPadding.Parent = LogPanel
-- ==================== BOTTOM BUTTONS ====================
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Size = UDim2.new(1, -18, 0, 45)
ButtonFrame.Position = UDim2.new(0, 9, 1, -53)
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.ZIndex = 2
ButtonFrame.Parent = MainFrame
local function createGlassButton(name, text, pos, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.32, -4, 1, 0)
    button.Position = pos
    button.BackgroundColor3 = color
    button.BackgroundTransparency = 0.35
    button.Text = ""
    button.BorderSizePixel = 0
    button.ZIndex = 3
    button.Parent = ButtonFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.75
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.ZIndex = 4
    label.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.45}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.35}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.75}):Play()
    end)
    
    return button
end
local ScanButton = createGlassButton("ScanButton", "🔍 ESCANEAR", UDim2.new(0, 0, 0, 0), Color3.fromRGB(80, 150, 255))
local CopyButton = createGlassButton("CopyButton", "📋 COPIAR", UDim2.new(0.34, 0, 0, 0), Color3.fromRGB(150, 80, 255))
local ApplyButton = createGlassButton("ApplyButton", "✅ APLICAR", UDim2.new(0.68, 0, 0, 0), Color3.fromRGB(80, 255, 150))
-- ==================== DATA STRUCTURES ====================
local scannedData = {}
local toggleStates = {}
local allLogs = {}
-- Configuración de modificaciones (agregadas más keys)
local modificationConfig = {
    -- AMMO
    {category = "💰 MUNICIÓN", key = "LimitedAmmoEnabled", value = false, type = "boolean", desc = "Desactivar límite"},
    {category = "💰 MUNICIÓN", key = "Ammo", value = math.huge, type = "number", desc = "Munición actual"},
    {category = "💰 MUNICIÓN", key = "MaxAmmo", value = math.huge, type = "number", desc = "Munición máxima"},
    {category = "💰 MUNICIÓN", key = "AmmoPerMag", value = math.huge, type = "number", desc = "Balas por cargador"},
    {category = "💰 MUNICIÓN", key = "StoredAmmo", value = math.huge, type = "number", desc = "Munición guardada"},
    {category = "💰 MUNICIÓN", key = "AmmoInGun", value = math.huge, type = "number", desc = "Balas en arma"},
    {category = "💰 MUNICIÓN", key = "MaxStoredAmmo", value = math.huge, type = "number", desc = "Máximo almacenado"},
    {category = "💰 MUNICIÓN", key = "ReserveAmmo", value = math.huge, type = "number", desc = "Munición reserva"},
    {category = "💰 MUNICIÓN", key = "CurrentAmmo", value = math.huge, type = "number", desc = "Munición actual alt"},
    {category = "💰 MUNICIÓN", key = "ClipSize", value = math.huge, type = "number", desc = "Tamaño clip"},
    {category = "💰 MUNICIÓN", key = "MagazineSize", value = math.huge, type = "number", desc = "Tamaño revista"},
    {category = "💰 MUNICIÓN", key = "InfiniteAmmo", value = true, type = "boolean", desc = "Munición infinita"},
    
    -- RECOIL
    {category = "🎯 RECOIL", key = "MinSpread", value = 0, type = "number", desc = "Dispersión mínima"},
    {category = "🎯 RECOIL", key = "MaxSpread", value = 0, type = "number", desc = "Dispersión máxima"},
    {category = "🎯 RECOIL", key = "MinRecoilPower", value = 0, type = "number", desc = "Retroceso mínimo"},
    {category = "🎯 RECOIL", key = "MaxRecoilPower", value = 0, type = "number", desc = "Retroceso máximo"},
    {category = "🎯 RECOIL", key = "AimRecoilReduction", value = 100, type = "number", desc = "Reducción al apuntar"},
    {category = "🎯 RECOIL", key = "AimSpreadReduction", value = 100, type = "number", desc = "Reducción spread"},
    {category = "🎯 RECOIL", key = "Recoil", value = 0, type = "number", desc = "Retroceso general"},
    {category = "🎯 RECOIL", key = "VerticalRecoil", value = 0, type = "number", desc = "Retroceso vertical"},
    {category = "🎯 RECOIL", key = "HorizontalRecoil", value = 0, type = "number", desc = "Retroceso horizontal"},
    {category = "🎯 RECOIL", key = "NoRecoil", value = true, type = "boolean", desc = "Sin retroceso"},
    {category = "🎯 RECOIL", key = "Spread", value = 0, type = "number", desc = "Dispersión general"},
    {category = "🎯 RECOIL", key = "Accuracy", value = 100, type = "number", desc = "Precisión"},
    {category = "🎯 RECOIL", key = "WalkMult", value = 0, type = "number", desc = "Multiplicador caminar"},
    
    -- RELOAD
    {category = "🔄 RECARGA", key = "NoReload", value = true, type = "boolean", desc = "Sin recarga"},
    {category = "🔄 RECARGA", key = "InstantReload", value = true, type = "boolean", desc = "Recarga instantánea"},
    {category = "🔄 RECARGA", key = "ReloadTime", value = 0, type = "number", desc = "Tiempo recarga"},
    
    -- DAMAGE
    {category = "💥 DAÑO", key = "Damage", value = 999, type = "number", desc = "Daño base"},
    {category = "💥 DAÑO", key = "MinDamage", value = 999, type = "number", desc = "Daño mínimo"},
    {category = "💥 DAÑO", key = "MaxDamage", value = 999, type = "number", desc = "Daño máximo"},
    {category = "💥 DAÑO", key = "HeadDamage", value = {999, 999}, type = "table", desc = "Daño cabeza"},
    {category = "💥 DAÑO", key = "TorsoDamage", value = {999, 999}, type = "table", desc = "Daño torso"},
    {category = "💥 DAÑO", key = "LimbDamage", value = {999, 999}, type = "table", desc = "Daño extremidades"},
    
    -- FIRE RATE
    {category = "⚡ CADENCIA", key = "FireRate", value = 0, type = "number", desc = "Cadencia de fuego"},
    {category = "⚡ CADENCIA", key = "ShootRate", value = 0, type = "number", desc = "Velocidad disparo"},
    
    -- BULLETS
    {category = "🚀 BALAS", key = "BulletSpeed", value = math.huge, type = "number", desc = "Velocidad bala"},
    {category = "🚀 BALAS", key = "ProjectileSpeed", value = math.huge, type = "number", desc = "Velocidad proyectil"},
    {category = "🚀 BALAS", key = "Range", value = math.huge, type = "number", desc = "Alcance"},
    {category = "🚀 BALAS", key = "Penetration", value = 100, type = "number", desc = "Penetración"},
    {category = "🚀 BALAS", key = "BulletDrop", value = 0, type = "number", desc = "Caída bala"},
    {category = "🚀 BALAS", key = "GravityFactor", value = 0, type = "number", desc = "Factor gravedad"},
    
    -- FIRE MODES
    {category = "🔫 MODOS", key = "AutoFire", value = true, type = "boolean", desc = "Fuego automático"},
    {category = "🔫 MODOS", key = "BurstFire", value = false, type = "boolean", desc = "Desactivar ráfaga"},
    {category = "🔫 MODOS", key = "FireModes", value = {true, true, true}, type = "table", desc = "Modos de fuego"},
    {category = "🔫 MODOS", key = "CanAuto", value = true, type = "boolean", desc = "Puede auto"},
    {category = "🔫 MODOS", key = "CanBurst", value = true, type = "boolean", desc = "Puede ráfaga"},
    
    -- OTHER
    {category = "🛡️ OTROS", key = "NoSway", value = true, type = "boolean", desc = "Sin balanceo"},
    {category = "🛡️ OTROS", key = "InstantEquip", value = true, type = "boolean", desc = "Equipar instantáneo"},
    {category = "🛡️ OTROS", key = "NoFlinch", value = true, type = "boolean", desc = "Sin retroceso visual"},
    {category = "🛡️ OTROS", key = "EquipTime", value = 0, type = "number", desc = "Tiempo equipar"},
    {category = "🛡️ OTROS", key = "AimSpeed", value = 0, type = "number", desc = "Velocidad apuntar"},
    {category = "🛡️ OTROS", key = "NoBulletDrop", value = true, type = "boolean", desc = "Sin caída bala"},
}
-- ==================== LOG SYSTEM ====================
local function addLog(text, color)
    color = color or Color3.fromRGB(200, 200, 200)
    table.insert(allLogs, text)
    
    local LogLabel = Instance.new("TextLabel")
    LogLabel.Size = UDim2.new(1, -10, 0, 15)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Text = text
    LogLabel.TextColor3 = color
    LogLabel.Font = Enum.Font.Code
    LogLabel.TextSize = 10
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.TextWrapped = true
    LogLabel.TextTransparency = 0.1
    LogLabel.ZIndex = 3
    LogLabel.Parent = LogPanel
    
    task.wait()
    LogPanel.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 16)
    LogPanel.CanvasPosition = Vector2.new(0, LogPanel.CanvasSize.Y.Offset)
end
-- ==================== TOGGLE SYSTEM ====================
local currentCategory = nil
local function createCategoryHeader(category)
    local header = Instance.new("TextLabel")
    header.Name = "CategoryHeader_" .. category
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    header.BackgroundTransparency = 0.92
    header.Text = " " .. category
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.BorderSizePixel = 0
    header.ZIndex = 3
    header.Parent = OptionsPanel
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
end
local function createToggle(key, desc, category, foundValue)
    -- Mostrar valor encontrado de manera mejorada
    local displayValue = tostring(foundValue)
    if type(foundValue) == "table" then
        displayValue = "{" .. table.concat(foundValue, ", ") .. "}"
    end
    
    -- Crear header de categoría si es nuevo
    if currentCategory ~= category then
        createCategoryHeader(category)
        currentCategory = category
    end
    
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle_" .. key
    toggle.Size = UDim2.new(1, 0, 0, 32)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggle.BackgroundTransparency = 0.95
    toggle.BorderSizePixel = 0
    toggle.ZIndex = 3
    toggle.Parent = OptionsPanel
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggle
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Transparency = 0.92
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggle
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, -12)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = desc
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTransparency = 0.15
    label.ZIndex = 4
    label.Parent = toggle
    
    -- Current value indicator
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80, 0, 12)
    valueLabel.Position = UDim2.new(0, 8, 1, -14)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Actual: " .. displayValue
    valueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 8
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextTransparency = 0.35
    valueLabel.ZIndex = 4
    valueLabel.Parent = toggle
    
    -- Toggle Button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 32, 0, 18)
    button.Position = UDim2.new(1, -38, 0.5, -9)
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.BackgroundTransparency = 0.25
    button.Text = ""
    button.BorderSizePixel = 0
    button.ZIndex = 4
    button.Parent = toggle
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 3, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 5
    indicator.Parent = button
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    -- Estado inicial
    toggleStates[key] = false
    
    -- Funcionalidad
    button.MouseButton1Click:Connect(function()
        toggleStates[key] = not toggleStates[key]
        
        if toggleStates[key] then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 255, 150)}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -15, 0.5, -6)}):Play()
            addLog("✅ Activado: " .. desc, Color3.fromRGB(80, 255, 150))
        else
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -6)}):Play()
            addLog("❌ Desactivado: " .. desc, Color3.fromRGB(255, 100, 100))
        end
    end)
end
-- ==================== SCAN FUNCTION ====================
local function scanTables()
    -- Limpiar
    for _, child in ipairs(OptionsPanel:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for _, child in ipairs(LogPanel:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    scannedData = {}
    toggleStates = {}
    allLogs = {}
    currentCategory = nil
    
    addLog("🔍 Iniciando escaneo profundo...", Color3.fromRGB(100, 150, 255))
    
    local foundKeys = {}
    local tableCount = 0
    
    for index, value in pairs(getgc(true)) do
        if type(value) == "table" then
            tableCount = tableCount + 1
            
            -- Buscar cada key del config
            for _, config in ipairs(modificationConfig) do
                local foundValue = rawget(value, config.key)
                
                if foundValue ~= nil and not foundKeys[config.key] then
                    foundKeys[config.key] = {
                        value = foundValue,
                        config = config,
                        tableRef = value,
                        index = index
                    }
                    
                    table.insert(scannedData, {
                        key = config.key,
                        currentValue = foundValue,
                        newValue = config.value,
                        tableRef = value,
                        category = config.category,
                        desc = config.desc
                    })
                    
                    addLog(string.format("✓ Encontrado: %s = %s", config.key, tostring(foundValue)), Color3.fromRGB(100, 255, 150))
                end
            end
        end
    end
    
    addLog(string.format("\n📊 Escaneo completo: %d tablas analizadas", tableCount), Color3.fromRGB(150, 150, 255))
    addLog(string.format("🎯 Keys encontradas: %d/%d\n", #scannedData, #modificationConfig), Color3.fromRGB(255, 150, 255))
    
    -- Crear toggles solo si se encontraron
    if #scannedData > 0 then
        -- Ordenar scannedData por categoría para consistencia
        table.sort(scannedData, function(a, b) return a.category < b.category end)
        
        for _, data in ipairs(scannedData) do
            createToggle(data.key, data.desc, data.category, data.currentValue)
        end
        
        addLog("✅ Opciones cargadas. Activa las que desees y presiona APLICAR", Color3.fromRGB(80, 255, 150))
    else
        addLog("❌ No se encontraron tablas compatibles", Color3.fromRGB(255, 80, 80))
    end
    
    task.wait()
    OptionsPanel.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 16)
end
-- ==================== APPLY FUNCTION ====================
local function applyModifications()
    local appliedCount = 0
    
    addLog("\n🔧 Aplicando modificaciones...", Color3.fromRGB(255, 165, 0))
    
    for _, data in ipairs(scannedData) do
        if toggleStates[data.key] then
            local success = pcall(function()
                rawset(data.tableRef, data.key, data.newValue)
            end)
            
            if success then
                appliedCount = appliedCount + 1
                addLog(string.format(" ✓ %s → %s", data.key, tostring(data.newValue)), Color3.fromRGB(100, 255, 200))
            else
                addLog(string.format(" ✗ Error en %s", data.key), Color3.fromRGB(255, 100, 100))
            end
        end
    end
    
    if appliedCount > 0 then
        addLog(string.format("\n✅ Aplicadas %d modificaciones exitosamente", appliedCount), Color3.fromRGB(50, 255, 50))
    else
        addLog("\n⚠️ No hay opciones activadas para aplicar", Color3.fromRGB(255, 200, 50))
    end
end
-- ==================== BUTTON FUNCTIONS ====================
ScanButton.MouseButton1Click:Connect(function()
    ScanButton.TextLabel.Text = "⏳ ESCANEANDO..."
    task.wait(0.1)
    scanTables()
    task.wait(0.5)
    ScanButton.TextLabel.Text = "🔍 ESCANEAR"
end)
CopyButton.MouseButton1Click:Connect(function()
    local fullText = table.concat(allLogs, "\n")
    if setclipboard then
        setclipboard(fullText)
        CopyButton.TextLabel.Text = "✅ COPIADO"
        task.wait(1.5)
        CopyButton.TextLabel.Text = "📋 COPIAR"
    else
        CopyButton.TextLabel.Text = "❌ ERROR"
        task.wait(1.5)
        CopyButton.TextLabel.Text = "📋 COPIAR"
    end
end)
ApplyButton.MouseButton1Click:Connect(function()
    ApplyButton.TextLabel.Text = "⚙️ APLICANDO..."
    task.wait(0.1)
    applyModifications()
    task.wait(0.5)
    ApplyButton.TextLabel.Text = "✅ APLICAR"
end)
-- ==================== ENTRADA ANIMADA ====================
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 550, 0, 420),
    Position = UDim2.new(0.5, -275, 0.5, -210)
}):Play()
-- Mensaje inicial
task.wait(0.6)
addLog("✨ GUN TABLE FINDER V9 cargado", Color3.fromRGB(150, 100, 255))
addLog("💡 Presiona 'ESCANEAR' para buscar tablas", Color3.fromRGB(200, 200, 200))
addLog("🎯 Activa las opciones que desees y luego 'APLICAR'", Color3.fromRGB(200, 200, 200))
