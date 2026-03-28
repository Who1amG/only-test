--// CFrame WalkSpeed - PC & Móvil //--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--// CONFIGURACIÓN //--
local settings = {
    speed = 50,
    enable = true,
    noclip = true,
    fly = false,
    smoothness = 0.2
}

--// VARIABLES //--
local velocity = Vector3.zero
local camera = workspace.CurrentCamera
local moveVector = Vector3.zero -- Para PC y móvil

--// DETECTAR DISPOSITIVO //--
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// PARA PC: INPUTS DE TECLADO //--
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then moveVector = moveVector + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveVector = moveVector + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveVector = moveVector + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveVector = moveVector + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space and settings.fly then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftShift and settings.fly then moveVector = moveVector + Vector3.new(0, -1, 0) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then moveVector = moveVector - Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveVector = moveVector - Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveVector = moveVector - Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveVector = moveVector - Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space and settings.fly then moveVector = moveVector - Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftShift and settings.fly then moveVector = moveVector - Vector3.new(0, -1, 0) end
    end)
end

--// PARA MÓVIL: USAR THUMBSTICK //--
if isMobile then
    -- Crear thumbstick visual en pantalla
    local gui = Instance.new("ScreenGui")
    gui.Name = "CFrameMobile"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 150)
    frame.Position = UDim2.new(0, 20, 1, -170)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
    
    local stick = Instance.new("Frame")
    stick.Size = UDim2.new(0, 50, 0, 50)
    stick.Position = UDim2.new(0.5, -25, 0.5, -25)
    stick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    stick.BorderSizePixel = 0
    stick.Parent = frame
    
    local stickCorner = Instance.new("UICorner")
    stickCorner.CornerRadius = UDim.new(1, 0)
    stickCorner.Parent = stick
    
    -- Lógica del thumbstick
    local dragging = false
    local center = Vector2.new(75, 75) -- Centro del frame (150/2)
    local maxDist = 50
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            stick.Position = UDim2.new(0.5, -25, 0.5, -25)
            moveVector = Vector3.zero
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y) - frame.AbsolutePosition
            local offset = (pos - center)
            
            if offset.Magnitude > maxDist then
                offset = offset.Unit * maxDist
            end
            
            stick.Position = UDim2.new(0, center.X + offset.X - 25, 0, center.Y + offset.Y - 25)
            
            -- Normalizar a -1 a 1
            moveVector = Vector3.new(offset.X / maxDist, 0, offset.Y / maxDist)
        end
    end)
    
    -- Botón de salto/volar para móvil
    local jumpBtn = Instance.new("TextButton")
    jumpBtn.Size = UDim2.new(0, 80, 0, 80)
    jumpBtn.Position = UDim2.new(1, -100, 1, -100)
    jumpBtn.Text = "↑"
    jumpBtn.TextSize = 40
    jumpBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    jumpBtn.Parent = gui
    
    jumpBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and settings.fly then
            moveVector = Vector3.new(moveVector.X, 1, moveVector.Z)
        end
    end)
    
    jumpBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            moveVector = Vector3.new(moveVector.X, 0, moveVector.Z)
        end
    end)
end

--// LOOP DE MOVIMIENTO //--
RunService.RenderStepped:Connect(function(dt)
    if not settings.enable or not hrp then return end
    
    local camCF = camera.CFrame
    
    -- Convertir input local a dirección mundial
    local worldMove = Vector3.zero
    if moveVector.Magnitude > 0 then
        local look = camCF.LookVector
        local right = camCF.RightVector
        look = Vector3.new(look.X, 0, look.Z).Unit
        right = Vector3.new(right.X, 0, right.Z).Unit
        
        worldMove = (right * moveVector.X) + (look * moveVector.Z)
        if settings.fly then
            worldMove = worldMove + Vector3.new(0, moveVector.Y, 0)
        end
        worldMove = worldMove.Unit * settings.speed
    end
    
    -- Suavizado
    velocity = velocity:Lerp(worldMove, settings.smoothness)
    
    -- Aplicar
    local newPos = hrp.CFrame.Position + velocity * dt
    hrp.CFrame = CFrame.new(newPos) * CFrame.Angles(0, camCF.Rotation.Y, 0)
    
    if settings.fly then
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    
    -- Noclip
    if settings.noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

--// COMANDOS //--
getgenv().CFrameWalk = {
    SetSpeed = function(s) settings.speed = s end,
    Toggle = function() settings.enable = not settings.enable end,
    SetFly = function(v) settings.fly = v end,
    SetNoclip = function(v) settings.noclip = v end
}

print(isMobile and "📱 Móvil detectado - Thumbstick activado" or "⌨️ PC detectado - WASD activado")
