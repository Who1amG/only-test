local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ==================== ANTI-DUPLICATE CHECK ====================
local GUI_NAME = "GunFinderV9_Retro"
local existingGui = CoreGui:FindFirstChild(GUI_NAME) or (gethui and gethui():FindFirstChild(GUI_NAME))
if existingGui then
    existingGui:Destroy()
end
-- ==============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
-- ==================== MAIN FRAME ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Dark Grey (Apple Style)
MainFrame.BackgroundTransparency = 0.1 -- Slightly opaque
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12) -- Softer corners
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70) -- Subtle border
MainStroke.Transparency = 0
MainStroke.Thickness = 1
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

local BackgroundCorner = Instance.new("UICorner")
BackgroundCorner.CornerRadius = UDim.new(0, 16)
BackgroundCorner.Parent = BackgroundImage

-- Oscurecer un poco el fondo
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.35
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 0
Overlay.Parent = MainFrame

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 16)
OverlayCorner.Parent = Overlay

-- Glass effect gradient
local GlassGradient = Instance.new("UIGradient")
GlassGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
}
GlassGradient.Rotation = 45
GlassGradient.Parent = MainFrame

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
local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0, 5, 0, 0)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxthumb://type=Asset&id=120174329172852&w=150&h=150"
Icon.ScaleType = Enum.ScaleType.Fit
Icon.ZIndex = 3
Icon.Parent = Header
-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, -18)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GUN TABLE FINDER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Arcade
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Header
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -110, 0, 14)
Subtitle.Position = UDim2.new(0, 60, 0, 26)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Version 9.0 • Perfect Edition"
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.Font = Enum.Font.Arcade
Subtitle.TextSize = 14
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextTransparency = 0.3
Subtitle.ZIndex = 3
Subtitle.Parent = Header
-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -40, 0, 9)
CloseButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.BackgroundTransparency = 0
CloseButton.Text = ""
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 3
CloseButton.Parent = Header

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(255, 50, 50)
CloseStroke.Thickness = 2
CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CloseStroke.Parent = CloseButton

local CloseIcon = Instance.new("TextLabel")
CloseIcon.Size = UDim2.new(1, 0, 1, 0)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "X"
CloseIcon.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseIcon.Font = Enum.Font.Arcade
CloseIcon.TextSize = 16
CloseIcon.ZIndex = 4
CloseIcon.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    TweenService:Create(CloseIcon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
    TweenService:Create(CloseIcon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 50, 50)}):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    -- 1. Disable interactions
    CloseButton.Visible = false
    MainFrame.Active = false
    
    -- 2. Clean UI Sequence (Step 1: Elements disappear)
    local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    if ContentFrame then
        TweenService:Create(ContentFrame, fadeInfo, {
            Position = UDim2.new(0, 9, 0, 100), -- Move down
            GroupTransparency = 1 -- If GroupTransparency doesn't exist on Frame (it's a CanvasGroup property), we use loop
        }):Play()
        -- Fallback loop for fading children if not CanvasGroup
        for _, desc in ipairs(ContentFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                TweenService:Create(desc, fadeInfo, {TextTransparency = 1}):Play()
            elseif desc:IsA("ImageLabel") then
                TweenService:Create(desc, fadeInfo, {ImageTransparency = 1}):Play()
            elseif desc:IsA("UIStroke") then
                TweenService:Create(desc, fadeInfo, {Transparency = 1}):Play()
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                TweenService:Create(desc, fadeInfo, {BackgroundTransparency = 1}):Play()
            end
        end
    end
    
    if ButtonFrame then
         for _, desc in ipairs(ButtonFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                TweenService:Create(desc, fadeInfo, {TextTransparency = 1}):Play()
            elseif desc:IsA("UIStroke") then
                TweenService:Create(desc, fadeInfo, {Transparency = 1}):Play()
             elseif desc:IsA("TextButton") then
                 TweenService:Create(desc, fadeInfo, {BackgroundTransparency = 1}):Play()
            end
        end
    end

    task.wait(0.6) -- Wait for clean UI
    
    -- 3. GAME OVER Sequence (Step 2: Appear)
    local GameOverLabel = Instance.new("TextLabel")
    GameOverLabel.Name = "GameOverLabel"
    GameOverLabel.Size = UDim2.new(1, 0, 1, 0) -- Full size
    GameOverLabel.Position = UDim2.new(0, 0, 0, 0)
    GameOverLabel.BackgroundTransparency = 1
    GameOverLabel.Text = [[
        
 


                .,''..'',,;;;;;;,,''..'','
           .,'.,:ldkOKXXXXKXXXXKXXXXKOkdl:,.',.
        ''':okkxl::0XXXXXXx:kkooXXXXXXKc:oxOko:'',
      '.:k0d:.....dXXXXXXXl....:XXXXXXX0.....:d0x:.'
    ..l0k:........cXXXXXX0......kXXXXXXx........;x0c..
   ..OKc...........'ldxd:........;odxo;...........;Kk..
   .dX:............................................'Xo.
   .OX..............................................0k.
    lXo............................................;X:
     oXx......okxo;...lxd:......;dxo'..;okOx,.....cKl
      .xKo'..;XXXXXKxKXXXXO,..,OXXXXXx0XXXXXx...:kx'
        .lOkl;OXXXXXXXXXXXXX;,KXXXXXXXXXXXXKccxkl.
            ,ok0XXXXXXXXXXXXK0XXXXXXXXXXXX0ko;
                 .:ldxkO0KKKXXKKK0Okxdl:.   


        
]]

        
    GameOverLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Softer Red
    GameOverLabel.Font = Enum.Font.Code -- Monospace is essential for ASCII
    GameOverLabel.TextSize = 14 -- Fixed size to prevent distortion
    GameOverLabel.TextXAlignment = Enum.TextXAlignment.Center
    GameOverLabel.TextYAlignment = Enum.TextYAlignment.Center
    GameOverLabel.TextTransparency = 1 -- Start invisible
    GameOverLabel.ZIndex = 20
    GameOverLabel.Parent = MainFrame
    
    -- Fade in Game Over
    TweenService:Create(GameOverLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()
    
    -- Wait 5 seconds (Step 3: Hold)
    task.wait(5)
    
    -- 4. Final Destroy (Step 4: Close)
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
local function createRetroButton(name, text, pos, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.32, -4, 1, 0)
    button.Position = pos
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Darker grey for buttons
    button.BackgroundTransparency = 0
    button.Text = ""
    button.BorderSizePixel = 0
    button.ZIndex = 3
    button.Parent = ButtonFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 80)
    stroke.Transparency = 0
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color -- Keep accent color for text
    label.Font = Enum.Font.Arcade
    label.TextSize = 16
    label.ZIndex = 4
    label.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = color}):Play() -- Highlight border
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(70, 70, 80)}):Play()
    end)
    
    return button
end

local ScanButton = createRetroButton("ScanButton", "🔍 ESCANEAR", UDim2.new(0, 0, 0, 0), Color3.fromRGB(80, 150, 255))
local ApplyAllButton = createRetroButton("ApplyAllButton", "⚡ APLICAR TODO", UDim2.new(0.34, 0, 0, 0), Color3.fromRGB(255, 170, 0))
local ApplyButton = createRetroButton("ApplyButton", "✅ APLICAR", UDim2.new(0.68, 0, 0, 0), Color3.fromRGB(80, 255, 150))
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

-- ==================== DYNAMIC CATEGORY CHECKER ====================
local additionalCategories = {
    {category = "💰 MUNICIÓN", key = "Ammo", value = math.huge, type = "number", desc = "Munición actual"},
    {category = "💰 MUNICIÓN", key = "AmmoPerMag", value = math.huge, type = "number", desc = "Balas por cargador"},
    {category = "💰 MUNICIÓN", key = "LowAmmo", value = 0, type = "number", desc = "Munición baja"},
    {category = "💰 MUNICIÓN", key = "MaxAmmo", value = math.huge, type = "number", desc = "Munición máxima"}
}

for _, newItem in ipairs(additionalCategories) do
    local exists = false
    for _, existingItem in ipairs(modificationConfig) do
        if existingItem.key == newItem.key then
            exists = true
            break
        end
    end
    
    if not exists then
        table.insert(modificationConfig, newItem)
    end
end

-- ==================== LOG SYSTEM ====================
local isLogCleanupScheduled = false
local MAX_LOGS = 30 -- Limit logs to prevent overflow

local function clearLogs()
    for _, child in ipairs(LogPanel:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    allLogs = {}
    LogPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function scheduleLogCleanup()
    if isLogCleanupScheduled then return end
    isLogCleanupScheduled = true
    
    task.spawn(function()
        addLog("⚠️ Eliminando logs en 20s", Color3.fromRGB(255, 165, 0))
        task.wait(20)
        clearLogs()
        isLogCleanupScheduled = false
    end)
end

local function addLog(text, color)
    color = color or Color3.fromRGB(200, 200, 200)
    table.insert(allLogs, text)
    
    -- Rotation System: Remove oldest if over limit
    if #allLogs > MAX_LOGS then
        table.remove(allLogs, 1)
        local children = LogPanel:GetChildren()
        -- Sort by layout order or find the first one (TextLabels)
        -- Since UIListLayout sorts by order, we can't trust GetChildren order directly without filtering
        -- But simplified: just destroy the first text label found or clear old ones.
        -- Better approach: Check count of TextLabels
        local labels = {}
        for _, c in ipairs(children) do
             if c:IsA("TextLabel") then table.insert(labels, c) end
        end
        if #labels >= MAX_LOGS then
            labels[1]:Destroy() -- Destroy oldest (assuming creation order)
        end
    end
    
    local LogLabel = Instance.new("TextLabel")
    LogLabel.Size = UDim2.new(1, -10, 0, 18)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Text = "> " .. text
    LogLabel.TextColor3 = color
    LogLabel.Font = Enum.Font.Arcade
    LogLabel.TextSize = 14
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.TextWrapped = true
    LogLabel.TextTransparency = 0
    LogLabel.ZIndex = 3
    LogLabel.Parent = LogPanel
    
    -- Efecto de sombra retro
    local LogShadow = Instance.new("TextLabel")
    LogShadow.Size = UDim2.new(1, 0, 1, 0)
    LogShadow.Position = UDim2.new(0, 1, 0, 1)
    LogShadow.BackgroundTransparency = 1
    LogShadow.Text = "> " .. text
    LogShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    LogShadow.Font = Enum.Font.Arcade
    LogShadow.TextSize = 14
    LogShadow.TextXAlignment = Enum.TextXAlignment.Left
    LogShadow.TextWrapped = true
    LogShadow.TextTransparency = 0.5
    LogShadow.ZIndex = 2
    LogShadow.Parent = LogLabel
    
    task.wait()
    LogPanel.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 16)
    LogPanel.CanvasPosition = Vector2.new(0, LogPanel.CanvasSize.Y.Offset)
end

-- Clear Logs Button (Manual)
local ClearLogsBtn = Instance.new("TextButton")
ClearLogsBtn.Size = UDim2.new(0, 60, 0, 18)
ClearLogsBtn.Position = UDim2.new(1, -70, 0, 4) -- Top right of LogPanel area
ClearLogsBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ClearLogsBtn.BackgroundTransparency = 0.5
ClearLogsBtn.Text = "BORRAR"
ClearLogsBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
ClearLogsBtn.Font = Enum.Font.Arcade
ClearLogsBtn.TextSize = 10
ClearLogsBtn.BorderSizePixel = 0
ClearLogsBtn.ZIndex = 3
ClearLogsBtn.Parent = ContentFrame -- Parent to ContentFrame so it sits above LogPanel

local ClearLogsStroke = Instance.new("UIStroke")
ClearLogsStroke.Color = Color3.fromRGB(255, 100, 100)
ClearLogsStroke.Thickness = 1
ClearLogsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ClearLogsStroke.Parent = ClearLogsBtn

ClearLogsBtn.MouseButton1Click:Connect(clearLogs)
-- ==================== TOGGLE SYSTEM ====================
local currentCategory = nil
local function createCategoryHeader(category)
    local header = Instance.new("TextLabel")
    header.Name = "CategoryHeader_" .. category
    header.Size = UDim2.new(1, 0, 0, 26)
    header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    header.BackgroundTransparency = 0.92
    header.Text = " " .. category
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.Arcade
    header.TextSize = 16
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
    label.Size = UDim2.new(1, -60, 1, -12) -- Adjusted to avoid overlap with new button size
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = desc
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Arcade
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd -- Prevent overflow
    label.TextTransparency = 0
    label.ZIndex = 4
    label.Parent = toggle
    
    -- Current value indicator
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -60, 0, 12)
    valueLabel.Position = UDim2.new(0, 10, 1, -14)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = displayValue
    valueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    valueLabel.Font = Enum.Font.Arcade
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valueLabel.ZIndex = 4
    valueLabel.Parent = toggle
    
    -- Toggle Button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 40, 0, 22) -- Slightly larger for Apple style
    button.Position = UDim2.new(1, -48, 0.5, -11)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    button.BackgroundTransparency = 0
    button.Text = ""
    button.BorderSizePixel = 0
    button.ZIndex = 4
    button.Parent = toggle
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0) -- Pill shape
    buttonCorner.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 18, 0, 18) -- Larger knob
    indicator.Position = UDim2.new(0, 2, 0.5, -9)
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
            TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(50, 205, 50)}):Play() -- Apple Green
            TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            addLog("✅ Activado: " .. desc, Color3.fromRGB(80, 255, 150))
            scheduleLogCleanup() 
        else
            TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            addLog("❌ Desactivado: " .. desc, Color3.fromRGB(255, 100, 100))
        end
    end)
end
-- ==================== SCAN FUNCTION ====================
local function calculateTableScore(tbl)
    if type(tbl) ~= "table" then return 0 end
    
    local score = 0
    local keysFound = 0
    
    -- Heurística: Si tiene varias keys conocidas, probablemente es una tabla de arma
    for _, config in ipairs(modificationConfig) do
        if rawget(tbl, config.key) ~= nil then
            score = score + 10
            keysFound = keysFound + 1
        end
    end
    
    return score, keysFound
end

local function isTableLinkedToTool(tbl, tool)
    if type(tbl) ~= "table" or not tool then return false, "Invalid Input" end
    
    -- 1. Verificación Estricta
    local strictMatch = false
    pcall(function()
        if rawget(tbl, "gunName") == tool.Name or rawget(tbl, "GunName") == tool.Name then 
            strictMatch = true 
        end
        
        for k, v in pairs(tbl) do
            if typeof(v) == "Instance" and v:IsDescendantOf(tool) then
                strictMatch = true
                break
            end
            if type(v) == "function" then
                local fenv = getfenv(v)
                if fenv and fenv.script and typeof(fenv.script) == "Instance" and fenv.script:IsDescendantOf(tool) then
                    strictMatch = true
                    break
                end
            end
        end
    end)
    
    if strictMatch then return true, "Strict Match" end
    
    -- 2. Verificación Heurística
    local score, keysFound = calculateTableScore(tbl)
    if keysFound >= 3 then
        return true, "Heuristic Match (" .. keysFound .. " keys)"
    end
    
    return false, "No Match"
end

local function scanTables()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local equippedTool = character and character:FindFirstChildOfClass("Tool")
    
    if not equippedTool then
        addLog("❌ ERROR: Equipa una herramienta primero", Color3.fromRGB(255, 80, 80))
        return
    end

    -- Limpiar UI
    for _, child in ipairs(OptionsPanel:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    
    scannedData = {} -- Map: Key -> { {tableRef=t, originalValue=v}, ... }
    toggleStates = {}
    local foundTableRefs = {} 
    local scanStats = {strict = 0, heuristic = 0}
    
    addLog("🔍 Escaneando tool: " .. equippedTool.Name, Color3.fromRGB(100, 150, 255))
    Title.Text = "GUN TABLE FINDER • " .. string.upper(equippedTool.Name)
    
    -- Optimización: Scan por chunks para evitar freeze
    local gc = getgc(true)
    local itemsPerYield = 1000
    local count = 0
    
    for index, value in pairs(gc) do
        count = count + 1
        if count % itemsPerYield == 0 then task.wait() end
        
        if type(value) == "table" and not foundTableRefs[value] then
            local isLinked, matchType = isTableLinkedToTool(value, equippedTool)
            
            if isLinked then
                foundTableRefs[value] = true
                if matchType == "Strict Match" then scanStats.strict = scanStats.strict + 1
                else scanStats.heuristic = scanStats.heuristic + 1 end
                
                -- Agrupar por KEY
                for _, config in ipairs(modificationConfig) do
                    local foundValue = rawget(value, config.key)
                    if foundValue ~= nil then
                        if not scannedData[config.key] then
                            scannedData[config.key] = {
                                config = config,
                                instances = {}
                            }
                        end
                        
                        table.insert(scannedData[config.key].instances, {
                            tableRef = value,
                            currentValue = foundValue
                        })
                    end
                end
            end
        end
    end
    
    addLog(string.format("📊 Tablas: %d estrictas, %d heurísticas", scanStats.strict, scanStats.heuristic), Color3.fromRGB(200, 200, 255))
    
    -- Ordenar y mostrar
    local sortedKeys = {}
    for key, data in pairs(scannedData) do
        table.insert(sortedKeys, data)
    end
    table.sort(sortedKeys, function(a, b) return a.config.category < b.config.category end)
    
    local visibleCount = 0
    for _, data in ipairs(sortedKeys) do
        local instanceCount = #data.instances
        local firstValue = data.instances[1].currentValue
        -- Mostrar solo UN botón por Key, indicando cuántas veces se encontró
        createToggle(data.config.key, data.config.desc .. " (x" .. instanceCount .. ")", data.config.category, firstValue)
        visibleCount = visibleCount + 1
    end
    
    if visibleCount > 0 then
        addLog("✅ " .. visibleCount .. " opciones únicas encontradas.", Color3.fromRGB(80, 255, 150))
    else
        addLog("❌ No se encontraron opciones compatibles", Color3.fromRGB(255, 80, 80))
    end
    
    task.wait()
    OptionsPanel.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 50) -- Margen extra
end
-- ==================== APPLY FUNCTION ====================
local function applyModifications()
    local appliedCount = 0
    
    addLog("\n🔧 Aplicando modificaciones...", Color3.fromRGB(255, 165, 0))
    
    for key, data in pairs(scannedData) do
        if toggleStates[key] then
            local newValue = data.config.value
            local successCount = 0
            
            for _, instance in ipairs(data.instances) do
                local success = pcall(function()
                    rawset(instance.tableRef, key, newValue)
                end)
                if success then successCount = successCount + 1 end
            end
            
            if successCount > 0 then
                appliedCount = appliedCount + 1
                addLog(string.format(" ✓ %s (%d/%d)", key, successCount, #data.instances), Color3.fromRGB(100, 255, 200))
            end
        end
    end
    
    if appliedCount > 0 then
        addLog(string.format("\n✅ Todo aplicado correctamente"), Color3.fromRGB(50, 255, 50))
    else
        addLog("\n⚠️ Nada seleccionado", Color3.fromRGB(255, 200, 50))
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
ApplyAllButton.MouseButton1Click:Connect(function()
    ApplyAllButton.TextLabel.Text = "⚡ ACTIVANDO..."
    
    -- Activar todos los estados (basado en keys agrupadas)
    for key, _ in pairs(scannedData) do
        toggleStates[key] = true
    end
    
    -- Actualizar visualmente los botones
    for _, child in ipairs(OptionsPanel:GetChildren()) do
        if child:IsA("Frame") and child.Name:sub(1, 7) == "Toggle_" then
            local btn = child:FindFirstChildOfClass("TextButton")
            if btn then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 255, 150)}):Play()
                local ind = btn:FindFirstChild("Frame")
                if ind then
                    TweenService:Create(ind, TweenInfo.new(0.2), {Position = UDim2.new(1, -15, 0.5, -6)}):Play()
                end
            end
        end
    end
    
    task.wait(0.1)
    applyModifications()
    task.wait(0.5)
    ApplyAllButton.TextLabel.Text = "⚡ APLICAR TODO"
end)
ApplyButton.MouseButton1Click:Connect(function()
    ApplyButton.TextLabel.Text = "⚙️ APLICANDO..."
    task.wait(0.1)
    applyModifications()
    task.wait(0.5)
    ApplyButton.TextLabel.Text = "✅ APLICAR"
end)

-- ==================== AUTO DETECT SYSTEM ====================
local function monitorEquippedTool()
    local player = game:GetService("Players").LocalPlayer
    
    local function onCharacterAdded(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                ScanButton.TextLabel.Text = "🔍 ESCANEAR " .. string.upper(child.Name)
                addLog("🔫 Detectado: " .. child.Name, Color3.fromRGB(100, 255, 255))
            end
        end)
        
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                ScanButton.TextLabel.Text = "🔍 ESCANEAR"
                addLog("👋 Desequipado: " .. child.Name, Color3.fromRGB(255, 200, 200))
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
        -- Check inicial
        local current = player.Character:FindFirstChildOfClass("Tool")
        if current then
            ScanButton.TextLabel.Text = "🔍 ESCANEAR " .. string.upper(current.Name)
            addLog("🔫 Detectado: " .. current.Name, Color3.fromRGB(100, 255, 255))
        end
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
end

task.spawn(monitorEquippedTool)

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

-- ==================== DIAGNOSTICS ====================
task.spawn(function()
    task.wait(1) -- Esperar a que cargue todo
    local ContentProvider = game:GetService("ContentProvider")
    local iconId = Icon.Image
    
    addLog("🔧 Diagnosticando Icono...", Color3.fromRGB(255, 255, 0))
    
    local success, err = pcall(function()
        ContentProvider:PreloadAsync({Icon})
    end)
    
    if success then
        addLog("✅ Icono validado por el sistema", Color3.fromRGB(0, 255, 0))
    else
        addLog("❌ Error cargando icono: " .. tostring(err), Color3.fromRGB(255, 50, 50))
        addLog("⚠️ Posible ID incorrecto (Decal vs Image)", Color3.fromRGB(255, 100, 100))
    end
end)
